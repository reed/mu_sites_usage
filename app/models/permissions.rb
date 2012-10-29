module Permissions
  
  def self.permission_for(user)
    if user.nil?
      GuestPermission.new
    else
      if user.administrator?
        AdministratorPermission.new(user)
      elsif user.department_manager?
        DepartmentManagerPermission.new(user)
      elsif user.site_manager?
        SiteManagerPermission.new(user)
      else
        AuthenticatedUserPermission.new(user)
      end
    end
  end
  
end