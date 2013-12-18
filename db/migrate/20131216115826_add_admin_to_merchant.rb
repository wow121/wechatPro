class AddAdminToMerchant < ActiveRecord::Migration
  def change
    add_column :merchants, :admin, :integer
  end
end
