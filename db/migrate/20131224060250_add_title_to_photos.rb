class AddTitleToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :title, :text
  end
end
