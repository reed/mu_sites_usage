class AddVmipAddressToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :vm_ip_address, :string
  end
end
