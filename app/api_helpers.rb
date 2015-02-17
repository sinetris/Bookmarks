module ApiHelpers
  extend Grape::API::Helpers
  # Warden
  def warden
    env['warden']
  end

  def authenticate!
    error!(
      {status_code: 401, message: 'Need to authenticate'},
      401
    ) unless authenticated?
    warden.authenticate! scope: :api
    warden_user
  end

  def authenticate
    warden.authenticate scope: :api
    warden_user
  end

  def authenticated?
    warden.authenticated? scope: :api
  end

  def warden_user
    warden.user(:api)
  end

  def current_user
    warden_user || authenticate
  end

  # CanCan
  def current_ability
    @ability ||= Ability.new(current_user)
  end

  def authorize! *args
    current_ability.authorize! *args
  end

  # logger
  def logger
    App.logger
  end

  def declared_params
    declared(params, include_missing: false)
  end

  # shared params
  params :pagination do
    optional :limit,  type: Integer, desc: "Limit", default: Bookmarks::Config::DEFAULT_COLLECTION_LIMIT
    optional :offset, type: Integer, desc: "Offset", default: 0
  end
end
