module BasicHelpers
  def basic_auth(user)
    encoded_username_password = Base64.encode64("#{user[:username]}:#{user[:password]}")
    "Basic #{encoded_username_password}"
  end

  def send_headers(headers)
    headers.each do |k, v|
      header k, v
    end
  end
end

RSpec.configure do |config|
  config.include(BasicHelpers)
end
