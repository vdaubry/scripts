require 'aws-sdk'
require 'yaml'

conf = YAML.load_file(File.expand_path(File.dirname(__FILE__))+"/../config.yml")
    
AWS.config({
  :access_key_id => conf["access_key_id"],
  :secret_access_key => conf["secret_access_key"],
  :region => "eu-west-1"
})

sqs = AWS::SQS.new 

@queue = begin
          sqs.queues.named(conf["website_queue_name"])
        rescue AWS::SQS::Errors::NonExistentQueue => e
          sqs.queues.create(conf["website_queue_name"],
            :visibility_timeout => 3600,
            :message_retention_period => 1209600)
        end

scrappers = []

if ARGV[0]
  scrappers << ARGV[0]
else 
  #Scrap forums
  (1..5).each { |i| scrappers << "forum#{i}" }

  #Scrap websites
  (1..2).each { |i| scrappers << "website#{i}" }

  #Scrap tumblrs
  (1..9).each { |i| scrappers << "tumblr#{i}" }
end


scrappers.each do |key| 
  json = {:website_key => key}.to_json
  @queue.send_message("#{json}")
end