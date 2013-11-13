class CreateSessionHistories < ActiveRecord::Migration
  def change
    create_table :session_histories do |t|
      t.string :user_name
			t.string :session_info

      t.timestamps
    end


		add_index :session_histories, :user_name
  end
end
