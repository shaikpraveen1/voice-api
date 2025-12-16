class GenerateVoiceJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 2

  def perform(voice_request_id)
    voice_request = VoiceRequest.find(voice_request_id)
    voice_request.update!(status: :processing)

    audio_binary, duration_ms = VoiceGeneration::ElevenLabsClient.generate_audio(voice_request.text)
    audio_url = VoiceGeneration::AudioUploader.upload_audio!(voice_request, audio_binary)
    puts "#{audio_url}"

    voice_request.update!(
      status: :completed,
      audio_url: audio_url,
      request_duration_ms: duration_ms
    )
  rescue StandardError => e
    # Rails.logger.error("GenerateVoiceJob failed: #{e.inspect}")

    safe_message =
      e.message.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
              .delete("\x00")

    voice_request.update!(
      status: :failed,
      error_message: "Unexpected error: #{safe_message}"
    ) if voice_request

    raise
  end
end
