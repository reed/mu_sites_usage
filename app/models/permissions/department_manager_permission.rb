module Permissions
  class DepartmentManagerPermission < SiteManagerPermission
    def initialize(user)
      super(user)
      allow :clients, [:index, :update]
      allow :clients, [:destroy] do |client|
        client.try(:site) 
      end
      allow :sites, [:index, :new, :create]
      allow :sites, [:edit, :update, :destroy] do |site|
        site.try(:department) == user.department
      end
      allow_param :site, [:display_name, :short_name, :name_filter, :enabled, :site_type]
      allow_param :client, [:name, :mac_address, :client_type, :ip_address, :last_checkin, :last_login, 
                                :current_status, :current_user, :current_vm, :enabled, :site_id]
    end
  end
end