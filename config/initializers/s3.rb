# frozen_string_literal: true

Aws.config.update(
  endpoint: ENV.fetch('AWS_S3_ENDPOINT', 'http://localhost:9000'),
  access_key_id: ENV.fetch('AWS_S3_ACCESS_KEY', 'test'),
  secret_access_key: ENV.fetch('AWS_S3_SECRET_KEY', 'test'),
  region: ENV.fetch('AWS_S3_REGION', 'us-east-1'),
  force_path_style: true
)

S3_BUCKET = ENV.fetch('AWS_S3_BUCKET_NAME', 'deploy-board-uploads')

begin
  Aws::S3::Client.new.create_bucket(bucket: S3_BUCKET)
rescue StandardError
  # bucket already exists or S3/MinIO unavailable at boot time
end
