# frozen_string_literal: true

class UploadsController < ApplicationController
  before_action :set_upload, only: %i[download destroy]

  # POST /uploads
  # multipart: item_id + files[] (um ou mais arquivos)
  def create
    item_id = params.expect(:item_id)
    files   = Array(params[:files])

    storage = StorageService.new
    uploads = files.map do |file|
      key    = "#{item_id}/#{SecureRandom.uuid}-#{file.original_filename}"
      result = storage.upload(key: key, io: file, content_type: file.content_type)

      Upload.create!(
        item_id: item_id,
        filename: file.original_filename,
        s3_url: result[:url],
        s3_key: key,
        size: file.size
      )
    end

    render json: uploads.map { |u| UploadSerializer.new(u).as_json }, status: :created
  end

  # GET /uploads?item_id=<uuid>
  def index
    item_id  = params.expect(:item_id)
    @uploads = apply_access_scope(Upload.where(item_id: item_id))
    render json: @uploads.map { |u| UploadSerializer.new(u).as_json }
  end

  # GET /uploads/:id/download
  def download
    obj = StorageService.new.download(key: @upload.s3_key)
    send_data(obj.body.read, filename: @upload.filename, type: obj.content_type, disposition: 'attachment')
  end

  # DELETE /uploads/:id
  def destroy
    s3_key = @upload.s3_key
    @upload.destroy!
    StorageService.new.delete(key: s3_key)
    head :no_content
  end

  # DELETE /uploads/by_item/:item_id
  def destroy_by_item
    uploads = Upload.where(item_id: params.expect(:item_id))
    count   = uploads.count
    storage = StorageService.new
    uploads.each { |u| storage.delete(key: u.s3_key) }
    uploads.delete_all
    render json: { deleted: count }
  end

  private

  def set_upload
    @upload = Upload.find(params.expect(:id))
    authorize_record!(@upload)
  end
end
