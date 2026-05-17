# frozen_string_literal: true

require 'image_processing/mini_magick'

module ImageCompressible
  extend ActiveSupport::Concern

  MAX_DIMENSION = 200
  QUALITY = 80

  class_methods do
    def compress_image(field)
      before_save -> { compress_base64_image(field) },
                  if: -> { send(:"#{field}_changed?") && send(field).present? }
    end
  end

  private

  def compress_base64_image(field)
    header, data = send(field).split(',', 2)
    return unless data

    mime = header[%r{data:(image/\w+);}, 1] || 'image/png'
    ext  = mime.split('/').last

    source = Tempfile.new(['image', ".#{ext}"])
    source.binmode
    source.write(Base64.decode64(data))
    source.flush

    result = ImageProcessing::MiniMagick
             .source(source)
             .convert(ext)
             .resize_to_limit(MAX_DIMENSION, MAX_DIMENSION)
             .saver(quality: QUALITY)
             .call

    send(:"#{field}=", "data:#{mime};base64,#{Base64.strict_encode64(result.read)}")
  ensure
    result&.close
    result&.unlink
    source&.close
    source&.unlink
  end
end
