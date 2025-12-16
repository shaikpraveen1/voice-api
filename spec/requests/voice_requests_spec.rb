require "rails_helper"

RSpec.describe "VoiceRequests API", type: :request do
  describe "POST /generate_voice" do
    it "creates a voice_request and enqueues job (JSON)" do
      ActiveJob::Base.queue_adapter = :test

      expect {
        post "/generate_voice",
             params: { text: "hello world" },
             as: :json
      }.to change(VoiceRequest, :count).by(1)
       .and have_enqueued_job(GenerateVoiceJob)

      expect(response).to have_http_status(:accepted)
      body = JSON.parse(response.body)
      expect(body["id"]).to be_present
    end

    it "redirects for HTML" do
      ActiveJob::Base.queue_adapter = :test

      post "/voice_requests", params: { text: "hello world" }

      expect(response).to have_http_status(:redirect)
      expect(response.location).to match(/\/voice_requests\/.+/)
    end
  end
end
