class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :display_name
      t.string :short_name
      t.string :name_filter
      t.integer :department_id

      t.timestamps
    end
  end
end
