class AddProfileUrlToForumUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :forum_users, :profile_url, :string
  end
end
