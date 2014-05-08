# encoding: utf-8
#!/usr/bin/env ruby

require 'net/sftp'
require 'pathname'
require 'date'
require "net/http"
require "uri"
require 'digest/md5'
require 'fastimage'
require 'fileutils'

IMAGES_PATH="/home/ftpuser/ftp/images/development/to_sort"
THUMBNAILS_PATH="/home/ftpuser/ftp/images/development/to_sort/thumbnails/300"  
WEBSITE_ID="53613db36d62700468000000"
POST_ID="53613df96d62700471000000"

USER_NAME=ARGV[0]
PASSWORD=ARGV[1]

def image_info(file)
  image_hash = Digest::MD5.file(file).hexdigest
  image_size = FastImage.size(file)
  if image_size
    width = image_size[0]
    height = image_size[1]
  end
  file_size = file.size

  [image_hash, width, height, file_size]
end

def create_image_in_db(key, image_hash, width, height, file_size)
  puts "Creating image #{key}"

  uri = URI.parse("http://localhost:3002/websites/#{WEBSITE_ID}/posts/#{POST_ID}/images.json")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri)
  post_params = {
    "image[source_url]" => "http://localhost/images/#{key}", 
    "image[hosting_url]" => "http://localhost/images/#{key}", 
    "image[key]" => key, 
    "image[status]" => "TO_SORT_STATUS", 
    "image[image_hash]" => image_hash, 
    "image[width]" => width, 
    "image[height]" => height, 
    "image[file_size]" => file_size
  }
  request.set_form_data(post_params)
  response = http.request(request)
end

def upload_image_to_ftp(key, file)
  puts "Uploading image #{key}"

  Net::SFTP.start("92.222.1.55", "#{USER_NAME}", :password => "#{PASSWORD}") do |sftp|
    sftp.upload!(file, "#{IMAGES_PATH}/#{key}")
    sftp.upload!(file, "#{THUMBNAILS_PATH}/#{key}")
  end
end


Dir.glob("/Volumes/Elements/backup.second/").each do |file|

  file_name = Pathname.new(file).basename.to_s
  key = "#{Time.now.to_i}_#{file_name}"

  image_hash, width, height, file_size = image_info(file)
  create_image_in_db(key, image_hash, width, height, file_size)
  upload_image_to_ftp(key, file)
  FileUtils.mv(file, "/Volumes/Elements/backup.second/#{key}")
end
