class CreatePhotoLogs < ActiveRecord::Migration
  def change
    create_table :photo_logs do |t|
		t.string :upload_type  
		t.string :user_id  
		t.string :merchant_id 
		t.string :photo_id  
		t.string :file_path
		t.string :state  
		t.string :payment_id  
		t.string :payment_email
		t.string :paid_at
		t.string :weixin_url
		t.string :weixin_image_path
		t.text   :description
		t.integer :downloads,:default=>0
      t.timestamps
    end
  end
end
