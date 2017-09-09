require "resque/tasks"
require 'resque/scheduler/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  require 'resque'
  require 'resque-scheduler'
  Resque.schedule = YAML.load_file(Rails.root.join 'config', 'resque_schedule.yml')
end
