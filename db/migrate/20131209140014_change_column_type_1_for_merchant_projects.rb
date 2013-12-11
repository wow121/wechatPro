class ChangeColumnType1ForMerchantProjects < ActiveRecord::Migration
  def up
	remove_column :merchant_projects,:merchant_id
	add_column :merchant_projects,:merchant_id,:string
	add_column :merchant_projects,:code,:string
  end

  def down
  end
end
