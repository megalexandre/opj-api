# frozen_string_literal: true

class StorageService
  def initialize(bucket: S3_BUCKET)
    @client = Aws::S3::Client.new
    @bucket = bucket
  end

  def upload(key:, io:, content_type:)
    @client.put_object(bucket: @bucket, key: key, body: io, content_type: content_type)
    { url: object_url(key) }
  end

  def download(key:)
    @client.get_object(bucket: @bucket, key: key)
  end

  def delete(key:)
    @client.delete_object(bucket: @bucket, key: key)
  end

  private

  def object_url(key)
    "#{ENV.fetch('AWS_S3_ENDPOINT', 'http://localhost:9000')}/#{@bucket}/#{key}"
  end
end
