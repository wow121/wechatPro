class AddDownloadsToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :downloads, :integer
  end
end
