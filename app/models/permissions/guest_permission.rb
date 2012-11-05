module Permissions
  class GuestPermission < BasePermission
    def initialize
      allow :departments, [:index, :show]
      allow :sites, [:show, :refresh, :popup]
      allow :clients, [:upload]
      allow :api, [:index, :sites, :counts, :info]
      allow :sessions, [:new, :create, :destroy]
    end
  end
end