class ChangeColumnTypeForMerchantProjects < ActiveRecord::Migration
  def up
     remove_column :merchant_projects, :merchant_name
     add_column :merchant_projects, :merchant_id, :integer
  end

  def down
  end
end
