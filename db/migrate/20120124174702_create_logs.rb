class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :client_id
      t.string :operation
      t.datetime :login_time
      t.datetime :logout_time
      t.string :user_id
      t.string :vm

      t.timestamps
    end
    add_index :logs, :client_id
  end
end
