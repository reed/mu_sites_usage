class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new 
    if user.administrator?
      can :manage, :all
    else
      if user.department_manager?
        can :manage, Client
        cannot :destroy, Client, :site => nil        
        can :create, Site
        can :manage, Site, Site.scoped_by_department_id(user.department_id) do |site|
          site.try(:department_id) == user.department_id
        end
      end
      if user.site_manager?
        can :manage, Log
        can :create, User
        can :manage, User, User.beneath_me(user) do |other_user|
          return true if other_user.nil?
          other_user <= user
        end 
      end
      if user.authenticated_user?
        can :manage, StatsController
        can :view_client_status_details, Site do |site|
          site.try(:department) == user.department
        end
      end
      can :read, Department
      #can :read, Site
    end
  end
end
