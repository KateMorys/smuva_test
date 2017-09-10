module PullAllUsers
  @queue = :pull_users_queue
  def self.perform()
    TeronParser.all_users
  rescue => error
    if error.class == Selenium::WebDriver::Error::NoSuchElementError
      puts error.inspect
    else
      puts "Something wrong"
    end
  end
end
