class CreateMerchantProjects < ActiveRecord::Migration
  def change
    create_table :merchant_projects do |t|
	t.string :merchant_name
	t.string :project_name
	t.string :project_name_short
	t.string :project_intro
      t.timestamps
    end
  end
end
