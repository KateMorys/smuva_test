module PullMostActiveUsers
  @queue = :pull_users_queue
  def self.perform()
    TeronParser.most_active_users
  end
end
