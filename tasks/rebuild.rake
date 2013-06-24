# -*- coding: utf-8 -*-

task :rebuild do
  require 'fileutils'

  system("dropdb idol_calendar_dev")
  system("createdb idol_calendar_dev")
  system("bundle exec padrino rake sq:migrate:auto") # This fails if first time
  system("bundle exec padrino rake sq:migrate:auto")

  Rake::Task["environment"].invoke
  
  files = [
           %w( config/apps.rb.sample config/apps.rb ),
           %w( config/database.rb.sample config/database.rb ),
           %w( db/cals.tsv.sample db/cals.tsv ),
          ]
  files.each do |(src, dst)|
    src = Pathname(Padrino.root(src))
    dst = Pathname(Padrino.root(dst))
    next if dst.exist?
    FileUtils.cp(src.to_s, dst.to_s)
  end

  Rake::Task["seed"].invoke
  Rake::Task["update:seed"].invoke
end
