Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }
config = YAML.load(File.open("#{Rails.root}/config/resque_schedule.yml"))[Rails.env]
Resque.redis = Redis.new(host: "localhost", port: "6379")

# worker: bundle exec rake resque:work
# scheduler: bundle exec rake resque:scheduler
