module Permissions
  class SiteManagerPermission < AuthenticatedUserPermission
    def initialize(user)
      super(user)
      allow :logs, [:index]
      allow :sites, [:show, :refresh, :popup, :view_internal_sites]
      allow :users, [:index, :new]
      allow :users, [:create]  do |other_user|
        user.assignable_roles.include? other_user[:role]
      end
      allow :users, [:destroy] do |other_user|
        other_user < user
      end
      allow :users, [:edit, :update] do |other_user|
        other_user == user || other_user < user
      end
      allow_param :user, [:username, :name, :email, :role]
    end
  end
end