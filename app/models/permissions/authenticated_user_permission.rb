module Permissions
  class AuthenticatedUserPermission < GuestPermission
    def initialize(user)
      super()
      allow :stats, [:index, :show]
      allow :sites, [:view_client_status_details] do |site|
        site.try(:department) == user.department
      end
    end
  end
end