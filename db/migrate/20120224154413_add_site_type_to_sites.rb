class AddSiteTypeToSites < ActiveRecord::Migration
  def change
    add_column :sites, :site_type, :string, :default => "general_access"
  end
end
