module Permissions
  class AdministratorPermission < DepartmentManagerPermission
    def initialize(user)
      super(user)
      allow_all
    end
  end
end