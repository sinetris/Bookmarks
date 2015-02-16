module ApiHelpers
  # logger
  def logger
    App.logger
  end

  def declared_params
    declared(params, include_missing: false)
  end
end
