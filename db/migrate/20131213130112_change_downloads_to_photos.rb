class ChangeDownloadsToPhotos < ActiveRecord::Migration
  def up
	remove_column :photos,:downloads
	add_column :photos,:downloads,:integer,:default=>0
  end

  def down
  end
end
