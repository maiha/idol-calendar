# -*- coding: utf-8 -*-
require 'google/api_client'

task :update_register => :environment  do
  extractors = [
                ['Extractors::Natokan', '65rbp6hqu4g5abgvpps56pllrc@group.calendar.google.com'],
               ]
  extractors.each do |(klass, cid)|
    LiveUpdate.find_or_create(:cid => cid).update(:extractor_name => klass)
  end
end

task :update_direct => :environment  do
  path = Pathname(Padrino.root("log/update_direct.log"))
  path.parent.mkpath unless path.parent.exist?
  logger = Logger.new(path)
  Sequel::Model.db.loggers = [logger]

  LiveUpdate.each do |lu|
    calendar = Calendar.filter(:cid => lu.cid).first or
      raise "CalendarNotFound: #{cid}"

    extractor = lu.extractor
    events    = extractor.execute

    events.any? or
      raise "EventsNotFound: %s" % lu.inspect

    label = calendar.tags.map(&:name).sort.join("|")
    calendar.update(:label => label, :summary => extractor.source, :source => extractor.source)
    calendar.events.each(&:delete)

    events.each_with_index do |event, i|
      event.id = "%s-%s" % [calendar.id, i+1]
      event.calendar_id  = calendar.id
      event.created = Time.now
      event.updated = Time.now
      event.end     ||= event.start
      event.label   = label
      event.last_updated = DateTime.now
      event.save
    end
  end
end


task :update => :environment  do
  path = Pathname(Padrino.root("log/update.log"))
  path.parent.mkpath unless path.parent.exist?
  logger = Logger.new(path)
  Sequel::Model.db.loggers = [logger]

  email   = ENV['GOOGLE_API_EMAILADDRESS']
  api_key = ENV['GOOGLE_API_KEY']
  client  = Google::APIClient.new(:application_name => 'idol-calendar', :version => '0.0.1')
  client.authorization = Signet::OAuth2::Client.new(
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    :audience             => 'https://accounts.google.com/o/oauth2/token',
    :scope                => 'https://www.googleapis.com/auth/calendar',
    :issuer               => email,
    :signing_key          => OpenSSL::PKey::RSA.new(api_key),
  )

#  if client.authorization.refresh_token && client.authorization.expired?
    client.authorization.fetch_access_token!
#  end
  service = client.discovered_api('calendar', 'v3')

  LiveUpdate.each do |lu|
    cid = lu.cid
    p cid

    e = Event.new
    e.start = Time.local(2013,6,21,16,30).to_datetime
    e.summary = "池袋サンシャインシティ"

    event = {
      'summary'   => e.summary,
      'location'  => 'Somewhere',
      'start'     => {
        'dateTime' => e.start.to_s,
      },
      'end' => {
        'dateTime' => e.start.to_s,
      },
      'attendees' => [],
    }

    event = {
      'summary' => 'Appointment',
      'location' => 'Somewhere',
      'start' => {
        'dateTime' => '2013-06-21T10:00:00.000-07:00',
        'timeZone' => 'America/Los_Angeles'
      },
      'end' => {
        'dateTime' => '2013-06-21T10:25:00.000-07:00',
        'timeZone' => 'America/Los_Angeles'
      },
      'recurrence' => [],
      'attendees' => [],
    }

    
    event = {
      "end" =>  {
        "date" => "2013-06-21"
      },
      "start" =>  {
        "date" => "2013-06-21"
      }
    }

    p event

    data = client.execute(
                          :api_method => service.events.insert,
                          :parameters => { 'calendarId' => cid },
                          :body => JSON.dump(event),
                          :headers => {'Content-Type' => 'application/json'}
                          ).data
    p data
  end
end
