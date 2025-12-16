class VoiceRequest < ApplicationRecord
  enum status: {
    queued: "queued",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }, _default: "queued"

  validates :text, presence: true
end
