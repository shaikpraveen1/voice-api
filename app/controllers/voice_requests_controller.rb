class VoiceRequestsController < ApplicationController
  helper_method :presigned_url_for

  def new
    @voice_request = VoiceRequest.new
    @recent_requests = VoiceRequest.order(created_at: :desc).limit(10)
  end

  def create
    text = params[:text].to_s.strip

    if text.blank?
      @voice_request = VoiceRequest.new(text: text)
      @error_message = "Text can't be blank"

      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { error: @error_message }, status: :unprocessable_entity }
      end

      return
    end

    @voice_request = VoiceRequest.create!(
      text: text,
      status: :queued
    )

    GenerateVoiceJob.perform_later(@voice_request.id)

    respond_to do |format|
      format.html { redirect_to voice_request_path(@voice_request) }
      format.json { render json: { id: @voice_request.id }, status: :accepted }
    end
  end

  def show
    @voice_request = VoiceRequest.find(params[:id])

    if @voice_request.completed? && @voice_request.audio_url.present?
      @audio_play_url = presigned_url_for(@voice_request.audio_url)
    end
  end

  def index
    @voice_requests = VoiceRequest.order(created_at: :desc).page(params[:page]).per(20)

    @audio_play_urls = {}
    @voice_requests.each do |req|
      next unless req.completed? && req.audio_url.present?
      @audio_play_urls[req.id] = presigned_url_for(req.audio_url)
    end
  end


   private

  def presigned_url_for(public_url_or_key)
    key =
      if public_url_or_key.start_with?("http")
        uri = URI.parse(public_url_or_key)
        uri.path.sub(%r{\A/}, "") # strip leading slash
      else
        public_url_or_key
      end

    client = Aws::S3::Client.new(
      region: ENV.fetch("AWS_REGION"),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
    )

    presigner = Aws::S3::Presigner.new(client: client)

    presigner.presigned_url(
      :get_object,
      bucket: ENV.fetch("AUDIO_BUCKET_NAME"),
      key: key,
      expires_in: 3600
    )
  end

end
