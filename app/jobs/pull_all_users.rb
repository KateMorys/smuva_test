module PullAllUsers
  @queue = :pull_users_queue
  def self.perform()
    TeronParser.all_users
  end
end
