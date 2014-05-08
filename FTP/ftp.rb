# encoding: utf-8
#!/usr/bin/env ruby

require 'net/sftp'
require 'pathname'

Dir.glob("../files/completed/*").select { |fn| File.file?(fn) }.each do |file|
  Net::SFTP.start("ip", "user_name", :password => "password") do |sftp|
    file_name = Pathname.new(file).basename.to_s
    total_size = 0
    previous_percent = -1
    sftp.upload!(file, "source_dir/#{file_name}") do | event, uploader, *args |
      case event
        when :open then
          total_size = args[0].size
          puts "starting upload: #{args[0].local} -> #{args[0].remote} ( #{total_size} :bytes)"
        when :put then
          written_bytes = args[1]
          percent=(written_bytes.to_f/total_size.to_f*100).to_i
          puts "#{percent}%" if percent > previous_percent
          previous_percent = percent
        when :close then
          puts "finished writing #{args[0].remote}"
        when :mkidr then
          puts "making directory #{args[0]}"
        when :finish then
          puts "all done!"
      end
    end
  end
end
