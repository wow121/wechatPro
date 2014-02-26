class CreateUserActivityLogs < ActiveRecord::Migration
  def change
    create_table :user_activity_logs do |t|
	t.string :open_id
	t.string :event
	t.string :content
      t.timestamps
    end
  end
end
