class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :display_name
      t.string :short_name

      t.timestamps
    end
  end
end
