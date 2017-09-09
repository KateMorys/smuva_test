class ForumUser < ApplicationRecord
  before_save :set_scraped_date

  validates_uniqueness_of :username, :scraped_date

  mount_uploader :avatar, AvatarUploader

  private

  def set_scraped_date
    self.scraped_date = Time.now
  end
end
