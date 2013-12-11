class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
	t.string :user_name
	t.string :password
      t.timestamps
    end
  end
end
