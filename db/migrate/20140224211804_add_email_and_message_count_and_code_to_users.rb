class AddEmailAndMessageCountAndCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    add_column :users, :message_count, :integer
    add_column :users, :code, :string
  end
end
