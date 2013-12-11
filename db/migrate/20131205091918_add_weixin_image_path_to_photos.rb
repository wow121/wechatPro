class AddWeixinImagePathToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :weixin_image_path, :string
  end
end
