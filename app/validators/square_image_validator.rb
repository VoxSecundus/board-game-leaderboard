class SquareImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.attached?

    pending = record.attachment_changes[attribute.to_s]

    if pending
      # New upload: file not on disk yet (upload happens in after_commit) — read from original IO
      check_from_attachable(record, attribute, pending.attachable)
    else
      # Already uploaded: use stored metadata (analyze if somehow not yet done)
      blob = value.blob
      blob.analyze unless blob.analyzed?
      check_from_metadata(record, attribute, blob)
    end
  end

  private

  def check_from_attachable(record, attribute, attachable)
    io = extract_io(attachable)
    return unless io

    begin
      require "vips"
      image = Vips::Image.new_from_buffer(io.read, "")
      w, h = image.width, image.height
      record.errors.add(attribute, "must be square (uploaded image is #{w}×#{h})") if w != h
    rescue Vips::Error
      record.errors.add(attribute, "could not be analyzed")
    ensure
      io.rewind if io.respond_to?(:rewind) && !io.closed?
    end
  end

  def check_from_metadata(record, attribute, blob)
    w = blob.metadata["width"]
    h = blob.metadata["height"]
    if w.nil? || h.nil?
      record.errors.add(attribute, "could not be analyzed")
    elsif w != h
      record.errors.add(attribute, "must be square (uploaded image is #{w}×#{h})")
    end
  end

  def extract_io(attachable)
    case attachable
    when Hash
      attachable[:io]
    when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
      attachable.open
    when File, IO, StringIO
      attachable
    when Pathname
      attachable.open
    end
  end
end
