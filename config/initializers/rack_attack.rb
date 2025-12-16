class Rack::Attack
  throttle("generate_voice/ip", limit: 5, period: 60) do |req|
    if req.post? && req.path == "/generate_voice"
      req.ip
    end
  end

  self.throttled_responder = lambda do |request|
    [
      429,
      { "Content-Type" => "application/json" },
      [{ error: "Rate limit exceeded" }.to_json]
    ]
  end
end
