class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
	t.string :subscribe
	t.string :openid
	t.string :nickname
	t.string :sex
	t.string :language
	t.string :city
	t.string :province
	t.string :country
	t.string :headimgurl
	t.string :subscribe_time
      t.timestamps
    end
  end
end
