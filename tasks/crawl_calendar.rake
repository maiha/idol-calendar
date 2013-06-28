# -*- coding: utf-8 -*-
require 'google/api_client'

task :crawling => :environment  do
  log = Logger.new(STDOUT)
  client = Google::APIClient.new(:application_name => 'idol-calendar', :version => '0.0.1')
  client.authorization = Signet::OAuth2::Client.new(
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    :audience             => 'https://accounts.google.com/o/oauth2/token',
    :scope                => 'https://www.googleapis.com/auth/calendar.readonly',
    :issuer               => ENV['GOOGLE_API_EMAILADDRESS'],
    :signing_key          => OpenSSL::PKey::RSA.new(ENV['GOOGLE_API_KEY']),
  )
  client.authorization.fetch_access_token!

  today = Date.today.to_datetime
  Calendar.each do |calendar|
    log.info(calendar.cid)
    label = calendar.tags.map(&:name).sort.join("|")
    data = client.execute(
      :api_method => client.discovered_api('calendar', 'v3').calendars.get,
      :parameters => { 'calendarId' => calendar.cid },
    ).data
    # get events
    items = client.execute(
      :api_method => client.discovered_api('calendar', 'v3').events.list,
      :parameters => {
        'calendarId'   => calendar.cid,
        'singleEvents' => true,
        'orderBy'      => 'startTime',
        'timeMin'      => today,
        'timeMax'      => today >> 1,
      },
    ).data.items

    if calendar.source.blank? or items.any?
      calendar.update(
        :source      => 'https://www.google.com/calendar/embed?src=' + CGI.escape(calendar.cid),
      )
    end

    calendar.update(
      :summary     => data.summary,
      :description => data.description,
      :label       => label,
    )

    items.each do |item|
      filter = /(?:イベント|ライブ|live|公演|ツアー|出演|開場|開演|open|start|握手|チェキ|サイン)/i
      next unless (item.summary && item.summary.match(filter) || (item.description && item.description.match(filter)))
      start_datetime = item.start.date_time || item.start.date
      end_datetime   = item.end.date_time   || item.end.date
      Event.find_or_create(:id => item.id).update(
        :calendar_id  => calendar.id,
        :created      => item.created,
        :updated      => item.updated,
        :summary      => item.summary,
        :description  => item.description,
        :location     => item.location,
        :htmlLink     => item.htmlLink,
        :start        => start_datetime,
        :end          => end_datetime,
        :label        => label,
        :last_updated => DateTime.now,
      )
      log.info('%s: %s' % [item.id, item.summary[0 .. 31]])
    end
  end
  # 更新されなかったものは削除
  Event.filter{ (start >= today) & (last_updated <= (today - 1)) }.delete
end
