# encoding: utf-8
#!/usr/bin/env ruby

require 'net/http'
require 'yaml'

conf = YAML.load_file("config.yml")

2.times do
  url = URI.parse(conf["website_url"])
  req = Net::HTTP::Get.new(url.path)
  req.basic_auth(conf["user"], conf["password"])
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }

  n = rand(20..30)
  puts "sleep #{n} seconds"
  sleep n
end