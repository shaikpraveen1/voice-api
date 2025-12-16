module VoiceGeneration
  class ElevenLabsClient
    DEFAULT_VOICE_ID =  ENV.fetch("ELEVENLABS_DEFAULT_VOICE_ID")

    def self.generate_audio(text, voice_id: DEFAULT_VOICE_ID)
      client = Elevenlabs::Client.new(api_key: ENV.fetch("ELEVENLABS_API_KEY"))
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      audio_binary = client.text_to_speech(voice_id, text)
      duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).to_i

      [audio_binary, duration_ms]
    rescue StandardError => e
      raise VoiceGeneration::Errors::ProviderError, e.message
    end
  end
end
