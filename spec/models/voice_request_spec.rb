require "rails_helper"

RSpec.describe VoiceRequest, type: :model do
  it "is valid with text" do
    vr = VoiceRequest.new(text: "hello")
    expect(vr).to be_valid
  end

  it "is invalid without text" do
    vr = VoiceRequest.new(text: nil)
    expect(vr).not_to be_valid
    expect(vr.errors[:text]).to be_present
  end

  it "has expected statuses" do
    expect(VoiceRequest.statuses.keys).to match_array(
      %w[queued processing completed failed]
    )
  end
end
