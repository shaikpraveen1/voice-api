require "elevenlabs"

Rails.application.config.to_prepare do
  Elevenlabs.configure do |config|
    # config.api_key = ENV.fetch("ELEVENLABS_API_KEY")
    config.api_key = Rails.application.credentials.dig(:elevenlabs, :api_key)
  end
end
