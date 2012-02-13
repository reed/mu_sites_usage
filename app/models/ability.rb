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
          site.try(:department) == user.department
        end
      end
      if user.site_manager?
        can :manage, StatsController
        can :manage, Log
        can :create, User
        can :manage, User, User.beneath_me(user) do |other_user|
          other_user.try(:department) == user.department
        end 
      end
      if user.authenticated_user?
        can :view_client_status_details, Site do |site|
          site.try(:department) == user.department
        end
      end
      can :read, Department
      #can :read, Site
    end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
