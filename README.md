### development ###

    $ git clone git://github.com/sugyan/idol-calendar.git
    $ cd idol-calendar
    $ bundle install --path vendor/gems

    $ cp config/apps.rb.sample config/apps.rb
    (edit config/apps.rb with your envs)

    $ cp config/database.rb.sample config/database.rb
    (edit config/database.rb with your envs)
    $ bundle exec padrino rake sq:migrate:auto

    $ cp db/cals.tsv.sample db/cals.tsv
    (edit db/cals.tsv with your favorite calendars)
    $ bundle exec padrino rake seed
    $ foreman start

### deploy ###

    $ heroku apps:create
    $ heroku config:set TZ=Asia/Tokyo
    $ heroku config:set GOOGLE_API_EMAILADDRESS=*********************************************@developer.gserviceaccount.com
    $ heroku config:set GOOGLE_API_KEY="-----BEGIN RSA PRIVATE KEY-----
    ...
    -----END RSA PRIVATE KEY-----"
    $ git push heroku master
    $ heroku run bundle exec padrino rake sq:migrate:auto
    $ heroku run bundle exec padrino rake seed
    $ heroku restart

### tasks ###

crawling (use scheduler:standard)

    $ bundle exec padrino rake crawling
