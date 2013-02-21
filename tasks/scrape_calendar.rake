require 'google/api_client'

task :scraping do
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

  Calendar.each do |calendar|
    log.info(calendar.cid)
    data = client.execute(
      :api_method => client.discovered_api('calendar', 'v3').calendars.get,
      :parameters => { 'calendarId' => calendar.cid },
    ).data
    calendar.update(
      :summary     => data.summary,
      :description => data.description,
    )
    calendar.events_dataset.delete
    # get events
    client.execute(
      :api_method => client.discovered_api('calendar', 'v3').events.list,
      :parameters => {
        'calendarId'   => calendar.cid,
        'singleEvents' => true,
        'orderBy'      => 'startTime',
        'timeMin'      => DateTime.now,
        'timeMax'      => DateTime.now >> 1,
      },
    ).data.items.each do |item|
      start_datetime = item.start.date_time || item.start.date
      end_datetime   = item.end.date_time   || item.end.date
      Event.find_or_create(:id => item.id).update(
        :calendar_id => calendar.id,
        :created     => item.created,
        :updated     => item.updated,
        :summary     => item.summary,
        :description => item.description,
        :location    => item.location,
        :htmlLink    => item.htmlLink,
        :start       => start_datetime,
        :end         => end_datetime,
      )
      log.info(item.id)
    end
  end
end