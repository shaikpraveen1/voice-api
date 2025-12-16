require "rails_helper"

RSpec.describe GenerateVoiceJob, type: :job do
  let(:voice_request) { VoiceRequest.create!(text: "test text", status: :queued) }

  before do
    allow(VoiceGeneration::ElevenLabsClient)
      .to receive(:generate_audio)
      .with("test text")
      .and_return(["AUDIO_BINARY", 1234])

    allow(VoiceGeneration::AudioUploader)
      .to receive(:upload_audio!)
      .and_return("https://example.com/audio.mp3")
  end

  it "marks request as completed and saves url" do
    described_class.perform_now(voice_request.id)
    voice_request.reload

    expect(voice_request.status).to eq("completed")
    expect(voice_request.audio_url).to eq("https://example.com/audio.mp3")
    expect(voice_request.request_duration_ms).to eq(1234)
  end
end
