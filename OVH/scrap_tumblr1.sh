sh /home/ubuntu/scripts/deploy.sh
IP=`cat /home/ubuntu/scripts/EC2/instance.ip`
ssh -oStrictHostKeyChecking=no deploy@$IP 'cd /srv/www/photo-scrapper/current; nohup ruby scrappers/run_tumblr1_scrapping.rb >> log/scrapping.log 2>> log/scrapping.log < /dev/null &'