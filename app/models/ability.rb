class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    elsif user.persisted? # logged in
      can :manage, User, id: user.id
      can :manage, Bookmark, user_id: user.id
      can :read, :all
    else # guest user
      can :read, :all
    end
  end
end
