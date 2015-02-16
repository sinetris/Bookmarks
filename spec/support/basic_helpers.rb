module BasicHelpers
  def send_headers(headers)
    headers.each do |k, v|
      header k, v
    end
  end
end

RSpec.configure do |config|
  config.include(BasicHelpers)
end
