class AddPhotoCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :photo_count, :integer
  end
end
