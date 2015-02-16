module ApiHelpers
  # Warden
  def warden
    env['warden']
  end

  def authenticate
    warden.authenticate scope: :api
    warden_user
  end

  def warden_user
    warden.user(:api)
  end

  # logger
  def logger
    App.logger
  end

  def declared_params
    declared(params, include_missing: false)
  end
end
