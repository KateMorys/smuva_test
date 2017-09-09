class CreateForumUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :forum_users do |t|
      t.string :username
      t.integer :messages_count
      t.datetime :scraped_date

      t.timestamps
    end
  end
end
