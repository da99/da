#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

def run_cmd(s_cmd)
  warn "--- Running: #{s_cmd}"
  `#{s_cmd}`.strip
end

# Represents a file in the public directory.
class PublicFile
  class << self
    def add_etag_to_file_name(etag, path)
      return path if path[%r|/lib.index.[^\.]{8,16}.mjs|]
      pieces = path.split('/')
      last = pieces.pop
      pieces.push("#{etag[0..ETAG_SIZE]}.#{last}")
      pieces.join('/')
    end

    def all(raw_dir)
      dir = normalize_dir(raw_dir)
      PublicFile.dir_exist!(dir)
      `find #{dir} -type f`
        .strip
        .split("\n")
        .map { |l| PublicFile.new(dir, l.strip) }
    end
    # --- def

    def normalize_dir(raw)
      raw.sub(%r{^\.?/}, '')
    end

    def dir_exist!(raw)
      dir = normalize_dir(raw)
      unless Dir.exist?(dir)
        warn "!!! Directory not found: #{dir}"
        exit 1
      end
      dir
    end

    def write_raw_manifest(settings)
      static_dir = normalize_dir(settings['STATIC_DIR'])
      file_name = 'tmp/raw_files.json'
      raw = `find "#{static_dir}" -type f -not -iname '.*'`
            .strip
            .split("\n")
            .map { |x| x.sub(static_dir, '').sub(/\.html.mts$/, '.html').sub(/\.ts/, '.js').sub(/\.mts/, '.mjs') }
            .each_with_object({}) { |x, o| o[x] = x }
      `mkdir -p tmp`
      File.write(file_name, JSON.pretty_generate(raw))
      puts "=== Wrote: #{file_name}"
    end

    def manifest(raw_dir)
      dir = normalize_dir(raw_dir)
      all(dir).each_with_object({}) do |new_file, memo|
        data = {
          'Origin' => new_file.path,
          'Key' => new_file.public_path,
          'ETag' => new_file.etag,
          'LastModified' => new_file.created_at,
          'mime' => `da www mime '#{new_file.raw}'`.strip
        }

        memo[new_file.path.sub(dir, '')] = data
        memo
      end
    end

    def write_manifest(settings)
      file_path = 'tmp/public_files.json'
      public_files = manifest(File.join(settings['BUILD_DIR']))
      json = JSON.pretty_generate(public_files)
      File.write(file_path, json)
      puts "=== Wrote: #{file_path}"
    end

    def upload_list
      uploaded = JSON.parse(File.read('tmp/public_files_uploaded.json'))['Contents']
      up_keys = uploaded.map { |x| x['Key'] }
      local_files = JSON.parse(File.read('tmp/public_files.json'))
      local_keys = local_files.values.map { |x| "#{ENV['BUILD_TARGET']}#{x['Key']}" }
      need_to_upload = local_keys - up_keys
      # each_with_object([]) do |lf, arr|
      #   arr.push(lf) unless up_keys.include?(lf)
      # end

      local_files.values.select { |x| need_to_upload.include?("#{ENV['BUILD_TARGET']}#{x['Key']}") }
    end

  end
  # --- class << self

  attr_reader :dir, :raw, :etag, :path, :created_at, :public_path

  ETAG_SIZE = 8

  def initialize(raw_dir, raw)
    @dir = PublicFile.normalize_dir(raw_dir)
    @raw = raw
    @path = raw.sub(@dir, '')
    @etag = `md5sum "#{raw}"`.split.first
    @created_at = `stat -c "%W" "#{raw}"`.strip
    @public_path = PublicFile.add_etag_to_file_name(etag, path)
  end
  # --- def

  def summary
    Hash.new(
      'path' => path,
      'dir' => dir,
      'public_path' => public_path,
      'etag' => etag
    )
  end
end
# --- class

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
if $PROGRAM_NAME == __FILE__
  cmd = ARGV.join(' ')
  case cmd

  when 'build mjs'
    # bun build \
    #   --target browser \
    #   --outdir "$PWD"/Public/section \
    #   --splitting \
    #   --entry-naming "[dir]/[name].mjs" \
    #   $index_mts
    # rm $index_mts

    raw_files = `find Public/section -type f -name index.mts`.strip.split("\n")
    case raw_files.size
    when 0
      warn '--- No .mts scripts found.'
    when 1
      raw = raw_files.first
      run_cmd %( bun build "#{raw}" > "#{raw.sub('.mts', '.mjs')}" )
      run_cmd %( rm "#{raw}")
    else
      run_cmd %( bun build Public/section/*/index.mts --splitting --outdir=Public/section --outbase=./ )
      raw_files.each do |x|
        run_cmd "mv #{x.sub('.mts', '.js')} #{x.sub('.mts', '.mjs')}"
        File.unlink(x)
        warn "--- File removed: #{x}"
      end
    end

  when 'upload list'
    PublicFile.upload_list.each { |lf| puts "#{lf['Origin']} => #{ENV['BUILD_TARGET']}#{lf['Key']}" }

  when /upload dir (.+)/
    build_target = ENV['BUILD_TARGET'] or raise("BUILD_TARGET not specified")
    settings = JSON.parse(File.read('settings.json'))
    bucket_name = settings['BUCKET_NAME']
    dir = Regexp.last_match(1)
    `find '#{dir}' -type f`.strip.split("\n").each do |file|
      cmd = %Q(bun x wrangler r2 object put "#{bucket_name}/#{build_target}#{file.sub(/^build\//, '/')}" --file "#{file}" --content-type "#{`da www mime '#{file}'`.strip}")
      puts "--- #{cmd}"
      exit($?.exitstatus) unless system(cmd)
    end

  when "upload"
    build_target = ENV['BUILD_TARGET'] or raise("BUILD_TARGET not specified")
    settings = JSON.parse(File.read('settings.json'))
    bucket_name = settings['BUCKET_NAME']
    PublicFile.upload_list.each { |lf|
      cmd = %Q(bun x wrangler r2 object put "#{bucket_name}/#{build_target}#{lf['Key']}" --file "build#{lf['Origin']}" --content-type "#{lf['mime']}")
      puts "--- #{cmd}"
      exit($?.exitstatus) unless system(cmd)
    }

  when 'update raw file manifest'
    j = JSON.parse(File.read('settings.json'))
    PublicFile.write_raw_manifest(j)

  when 'update file manifest'
    j = JSON.parse(File.read('settings.json'))
    PublicFile.write_manifest(j)

  when /^set src to (.+)$/i
    dir = 'dist'
    domain = Regexp.last_match(1)
    manifest = PublicFile.manifest(dir)
    files = `find "#{dir}" -type f -name '*.html'`.strip.split('\n')
    if files.empty?
      puts "--- No files found for: setting #{dir}"
    else
      puts "--- Setting #{dir} to https://#{domain}..."
    end
    files.each do |raw_file|
      origin = File.read(raw_file)
      new_body = origin.gsub(/(src|href)="([^"]+)"/) do |match|
        attr = Regexp.last_match(1)
        new_val = manifest[Regexp.last_match(2)]
        if new_val
          %(#{attr}="https://#{File.join domain, new_val['public_path']}")
        else
          match
        end
      end
      # ====origin.gsub
      if origin == new_body
        warn "--- Skipping: #{raw_file}"
        next
      end
      warn "=== Updated: #{raw_file}"
      File.write(raw_file, new_body)
    end
    # === files.each

  else
    warn "!!! Unknown command: #{cmd}"
    exit 1
  end
end
