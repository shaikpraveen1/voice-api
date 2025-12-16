class CreateVoiceRequests < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :voice_requests, id: :uuid do |t|
      t.text    :text, null: false
      t.string  :status, null: false, default: "queued"
      t.string  :audio_url
      t.string  :provider, null: false, default: "elevenlabs"
      t.string  :voice_id
      t.text    :error_message
      t.inet    :requested_ip
      t.integer :request_duration_ms

      t.timestamps
    end

    add_index :voice_requests, :status
    add_index :voice_requests, :created_at
    add_index :voice_requests, :requested_ip
  end
end