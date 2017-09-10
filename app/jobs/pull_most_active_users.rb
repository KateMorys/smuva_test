module PullMostActiveUsers
  @queue = :pull_users_queue
  def self.perform()
    TeronParser.most_active_users
  rescue => error
    if error.class == Selenium::WebDriver::Error::NoSuchElementError
      puts error.inspect
    else
      puts "Something wrong"
    end
  end
end
