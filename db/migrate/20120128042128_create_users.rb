class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :email
      t.integer :department_id
      t.string :role
      t.integer :logins, :default => 0

      t.timestamps
    end
    add_index :users, :username, :unique => true
  end
end
