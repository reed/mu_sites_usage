class AddEnabledToSites < ActiveRecord::Migration
  def change
    add_column :sites, :enabled, :boolean, :default => true
  end
end
