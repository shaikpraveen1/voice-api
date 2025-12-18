require "aws-sdk-s3"

module VoiceGeneration
  class AudioUploader
    def self.upload_audio!(voice_request, audio_binary)
      s3 = Aws::S3::Resource.new(
        region: ENV.fetch("AWS_REGION"),
        access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
        secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
      )

      key = "voice_requests/#{voice_request.id}.mp3"
      obj = s3.bucket(ENV.fetch("AUDIO_BUCKET_NAME")).object(key)

      obj.put(body: audio_binary, content_type: "audio/mpeg")

      # Store plain object URL (or key) in DB
      obj.public_url
    rescue StandardError => e
      Rails.logger.error("Audio upload error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.take(5).join("\n"))
      raise VoiceGeneration::Errors::StorageError, e.message
    end
  end
end
