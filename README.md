# Voice API (Rails, Sidekiq, Rate Limited)

Voice API is a production-ready Rails 7 JSON API that converts text into speech using the ElevenLabs Text-to-Speech API.

## Design Decisions

- **Background jobs (Sidekiq)**: Prevents blocking HTTP requests during audio generation.
- **Rate limiting (Rack::Attack)**: Protects expensive external API calls.
- **202 Accepted response**: Indicates asynchronous processing.
- **Rails cache-backed throttling**: Keeps implementation simple and fast.
- **Service-oriented job design**: Easy to extend to multiple TTS providers.
`

---

##  Setup

### Prerequisites

Ensure the following are installed:

* Ruby **3.1.5**
* PostgreSQL
* Redis (required for Sidekiq)
* Bundler
* Git

---

##  Installation

```bash
git clone https://github.com/shaikpraveen1/voice-api.git
cd voice-api

# Install gems
bundle install

# Setup database
bin/rails db:create db:migrate

# (Optional) Seed data
# bin/rails db:seed
```

---

##  Environment Variables

Create a .env file or configure environment variables via your platform.

Example:

```bash
ELEVENLABS_API_KEY=your_api_key_here
```

---

##  Running the Application

Start Rails and Sidekiq in **separate terminals**:

```bash
# Rails server
bin/rails server

# Sidekiq (uses config/sidekiq.yml if present)
bundle exec sidekiq
```

By default, the API will be available at:

```
http://localhost:3000
```

---

##  API: `/generate_voice`

### Endpoint Details

* **Method:** `POST`
* **Path:** `/generate_voice`
* **Content-Type:** `application/json`
* **Success Response:** `202 Accepted`
* **Rate Limited Response:** `429 Too Many Requests`

---

### Request Body

```json
{
  "text": "hello"
}
```

---

### Example `curl` Request

```bash
curl -i -X POST http://localhost:3000/generate_voice \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"text":"hello"}'
```

On success:

* A `VoiceRequest` record is created with status `queued`
* A `GenerateVoiceJob` is enqueued to Sidekiq
* The API responds with `202 Accepted`

---

##  Rate Limiting with Rack::Attack

This application uses **Rack::Attack** to throttle requests to the `/generate_voice` endpoint.

### Middleware Setup

`config/application.rb`

```ruby
module MyVoiceApiV2
  class Application < Rails::Application
    # ...
    config.middleware.use Rack::Attack
  end
end
```

This ensures Rack::Attack runs for every request.

---

### Cache Configuration (Development)

Rack::Attack relies on Rails cache to track request counts.

`config/environments/development.rb`

```ruby
config.action_controller.perform_caching = true
config.cache_store = :memory_store
```

This enables in-memory caching so throttling works correctly in development.

---

### Throttle Rule

`config/initializers/rack_attack.rb`

```ruby
class Rack::Attack
  # Limit to 5 POSTs to /generate_voice per IP per minute
  throttle("generate_voice/ip", limit: 5, period: 60) do |req|
    if req.post? && req.path == "/generate_voice"
      req.ip
    end
  end

  self.throttled_responder = lambda do |_request|
    [
      429,
      { "Content-Type" => "application/json" },
      [{ error: "Rate limit exceeded" }.to_json]
    ]
  end
end
```

**Behaviour:**

* First **5 requests/minute/IP** → `202 Accepted`
* Additional requests → `429 Rate limit exceeded`

---

###  Testing the Rate Limit

```bash
for i in $(seq 1 10); do
  echo "Request $i"
  curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST http://localhost:3000/generate_voice \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"text":"hello"}'
done
```

Expected output:

* First 5 requests → `202`
* Remaining requests → `429`

---

##  Git & GitHub

This project is tracked using Git and hosted on GitHub.

```bash
git init
git add .
git commit -m "Initial commit"

git remote add origin https://github.com/shaikpraveen1/voice-api.git
git branch -M main
git push -u origin main
```

 **Authentication Note:**
When pushing over HTTPS, use a **GitHub Personal Access Token (PAT)** with `repo` scope as the password.

---

##  Notes

* Designed as a clean, async-first API
* Easy to extend with additional voice providers
* Production-ready rate limiting & background jobs

---

⭐ If you find this useful, feel free to fork or contribute!
