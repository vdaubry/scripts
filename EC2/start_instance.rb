require 'aws-sdk'
require 'net/http'
require 'net/ssh'

puts "Initializing AWS conf"
config_file = File.join(File.dirname(__FILE__), "../config.yml")
AWS.config(YAML.load(File.read(config_file)))

puts "Initiate a client in the Ireland region"
ec2 = AWS::EC2.new(:ec2_endpoint => 'ec2.eu-west-1.amazonaws.com')

puts "Request instance"
request = ec2.instances.create(
:image_id => 'ami-4bca0b3c',
:instance_type => 't1.micro',
:count => 1,
:security_groups => ec2.security_groups['sg-e64cad83'], 
:key_pair => ec2.key_pairs['pauletteEC2'],
:instance_initiated_shutdown_behavior => "terminate")
while request.status == :pending do
  puts "Waiting for instance initialization, status = #{request.status}"
  sleep 1 
end
Raise "Request failed, instance status is #{request.status}" if request.status != :running
instance = ec2.instances[request.instance_id]
puts "Request successfull, instance id is : #{instance.id}"

puts "create new elastic ip (max 5)"
ec2.elastic_ips.to_a.last.delete if ec2.elastic_ips.count >= 5
ip = ec2.elastic_ips.create

puts "Associate elastic ip to instance"
instance.associate_elastic_ip(ip)
File.open("#{File.dirname(__FILE__)}/instance.ip", 'w') do |f|
  f.write(ip.to_s)
end

wait_time=40
puts "Instance ready at address : #{instance.ip_address}"
puts "Waiting #{wait_time}sec to be able to ssh..."
wait_time.times { print "."; sleep(1)}