class ChangeTypeToMessage < ActiveRecord::Migration
  def up
 	remove_column :messages,:value
	add_column :messages,:value,:text 
  end

  def down
  end
end
