class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
     	t.string :name
        t.string :sku
        t.string :sname
        t.string :description
        t.string :pic

      t.timestamps
    end
  end
end
