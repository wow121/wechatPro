class AddCorpNameandLocNameAndOfficeNameToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :corp_name, :string
    add_column :merchants, :loc_name, :string
    add_column :merchants, :office_name, :string
  end
end
