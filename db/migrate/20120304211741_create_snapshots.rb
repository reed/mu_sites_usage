class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.integer :site_id
      t.date :day
      t.string :time_increment
      t.integer :available
      t.integer :unavailable
      t.integer :offline

      t.timestamps
    end
    add_index :snapshots, :site_id
  end
end
