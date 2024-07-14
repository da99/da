#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './PublicFile'
require 'json'

# Manage a files for a Bucket.
class Bucket
  class << self
    def file_json
      'bucket_files.json'
    end
  end
  # === class << self

  attr_reader :dir, :files, :bucket

  def initialize(settings, public_files)
    @bucket = settings['bucket_api_url']
    @dir = PublicFile.normalize_dir(settings['static_dir'])
    @files = public_files
  end
  # === def

  def upload_file(new_file)
    cmd = %( bunx wrangler r2 object put "#{File.join(bucket, new_file.public_path)}" --file="#{new_file.path}" )
    puts "\n--- Uploading: #{cmd}"
    exit(1) unless system(cmd)
    new_file.summary
  end

  def upload
    old_etags = files.map { |x| x['etag'] }

    summarys = PublicFile.all(dir).map do |new_file|
      upload_file(new_file) unless old_etags.include?(new_file.etag)
    end

    return false if summarys.empty?

    @files.concat(summarys)
    puts "=== Finished uploading. Saving to: #{self.class.file_json}"
    File.write(self.class.file_json, @files.to_json)
  end
  # === def
end
# === class

if $PROGRAM_NAME == __FILE__
  cmd = ARGV.join(' ')
  case cmd
  when 'upload to bucket'
    settings = JSON.parse(File.read('settings.json'))
    public_files = JSON.parse(File.read('public_files.json'))
    b = Bucket.new(settings, public_files)
    b.upload

  else
    warn "!!! Unknown command: #{cmd}"
    exit 1
  end
end
