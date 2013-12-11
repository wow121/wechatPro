class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
	t.string :upload_type  
	t.string :user_id  
	t.string :merchant_id 
	t.string :photo_id  
	t.string :file_path
	t.string :state  
    t.string :payment_id  
    t.string :payment_email
	t.string :paid_at
      t.timestamps
    end
  end
end
