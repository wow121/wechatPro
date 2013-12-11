class CreateMerchantCodes < ActiveRecord::Migration
  def change
    create_table :merchant_codes do |t|
	t.string :merchant_id
	t.string :code
      t.timestamps
    end
  end
end
