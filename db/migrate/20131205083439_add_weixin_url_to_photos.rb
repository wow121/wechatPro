class AddWeixinUrlToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :weixin_url, :string
  end
end
