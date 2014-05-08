require 'aws-sdk'
require 'net/http'
require 'net/ssh'

puts "Initializing AWS conf"
config_file = File.join(File.dirname(__FILE__), "config.yml")
AWS.config(YAML.load(File.read(config_file)))

puts "Initiate a client in the Ireland region"
ec2 = AWS::EC2.new(:ec2_endpoint => 'ec2.eu-west-1.amazonaws.com')
group = ec2.security_groups['sg-e64cad83']

puts "Request instance"
request = ec2.instances.create(
:image_id => 'ami-c767a1b0',
:instance_type => 't1.micro',
:count => 1,
:security_groups => group, 
:key_pair => ec2.key_pairs['paulette_ec2'],
:instance_initiated_shutdown_behavior => "terminate")
while request.status == :pending do
  puts "Waiting for instance initialization, status = #{request.status}"
  sleep 1 
end
Raise "Request failed, instance status is #{request.status}" if request.status != :running
instance = ec2.instances[request.instance_id]

puts "Request successfull, instance id is : #{instance.id}"
puts "Associate elastic ip to instance"
ip = ec2.elastic_ips.first
instance.associate_elastic_ip(ip)

puts "Instance ready at address : #{instance.ip_address}"
puts "Waiting 30sec to be able to ssh..."
30.times { print "."; sleep(1)}