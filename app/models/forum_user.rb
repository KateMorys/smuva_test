class ForumUser < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  validates_uniqueness_of :username, :scraped_date
  before_save :set_scraped_date

  private

  def set_scraped_date
    self.scraped_date = Time.now
  end
end
