class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
	t.string :key
	t.string :value
      t.timestamps
    end
  end
end
