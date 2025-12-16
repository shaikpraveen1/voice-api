require "rails_helper"

RSpec.describe VoiceGeneration::AudioUploader do
  let(:voice_request) { VoiceRequest.create!(text: "x", status: :queued) }

  it "uploads to S3 and returns URL" do
    resource = instance_double(Aws::S3::Resource)
    bucket   = instance_double(Aws::S3::Bucket)
    object   = instance_double(Aws::S3::Object, public_url: "https://bucket/obj")

    allow(Aws::S3::Resource).to receive(:new).and_return(resource)
    allow(resource).to receive(:bucket).and_return(bucket)
    allow(bucket).to receive(:object).and_return(object)
    allow(object).to receive(:put).with(
      body: "AUDIO",
      content_type: "audio/mpeg"
    )

    url = described_class.upload_audio!(voice_request, "AUDIO")

    expect(url).to eq("https://bucket/obj")
  end
end
