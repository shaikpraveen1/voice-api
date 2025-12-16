require "rails_helper"

RSpec.describe VoiceGeneration::ElevenLabsClient do
  it "calls Elevenlabs client and returns audio + duration" do
    fake_client = instance_double("Elevenlabs::Client")

    allow(Elevenlabs::Client).to receive(:new).and_return(fake_client)
    allow(fake_client).to receive(:text_to_speech)
      .with("VOICE_ID", "hello")
      .and_return("BINARY")

    stub_const(
      "VoiceGeneration::ElevenLabsClient::DEFAULT_VOICE_ID",
      "VOICE_ID"
    )

    audio, duration = described_class.generate_audio("hello")

    expect(audio).to eq("BINARY")
    expect(duration).to be_a(Integer)
  end
end
