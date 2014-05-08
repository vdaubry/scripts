# encoding: utf-8
#!/usr/bin/env ruby

require 'net/http'

2.times do
  url = URI.parse('http://app.herokuapp.com/')
  req = Net::HTTP::Get.new(url.path)
  req.basic_auth("user", "password")
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }

  n = rand(20..30)
  puts "sleep #{n} seconds"
  sleep n
end