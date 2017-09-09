class AddAvatarToForumUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :forum_users, :avatar, :string
  end
end
