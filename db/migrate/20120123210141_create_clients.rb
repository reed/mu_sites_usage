class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :mac_address
      t.string :client_type
      t.string :ip_address
      t.integer :site_id
      t.boolean :enabled, :default => true
      t.datetime :last_checkin
      t.datetime :last_login
      t.string :current_status, :default => "available"
      t.string :current_user
      t.string :current_vm

      t.timestamps
    end
    add_index :clients, :name, :unique => true
  end
end
