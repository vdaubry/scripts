eval `ssh-agent -s`
ssh-add
mkdir -p /home/ubuntu/tmp

##############################
#
# Start EC2 instance
#
##############################

echo "Cloning conf repos"
git clone git@92.222.1.55:/home/git/scripts-conf.git
cp scripts-conf/config.yml /home/ubuntu/scripts/config.yml

echo "Request EC2 instance"
ruby /home/ubuntu/scripts/EC2/start_instance.rb

echo "Clean repos"
rm -Rf scripts-conf


##############################
#
# Deploy downloader
#
##############################

echo "Cloning downloader repos"
git clone git@github.com:vdaubry/photo-downloader.git /home/ubuntu/tmp/photo-downloader
git clone git@92.222.1.55:/home/git/downloader-conf.git /home/ubuntu/tmp/downloader-conf

echo "Copy private conf"
cp /home/ubuntu/tmp/downloader-conf/*.yml /home/ubuntu/tmp/photo-downloader/private-conf/
cp /home/ubuntu/tmp/downloader-conf/.env /home/ubuntu/tmp/photo-downloader/private-conf/

echo "remove hold ssh host key"
ssh-keygen -R 54.72.162.77

echo "Deploy downloader to EC2"
cd /home/ubuntu/tmp/photo-downloader
cap production deploy

ssh -oStrictHostKeyChecking=no deploy@54.72.162.77 'cd /srv/www/photo-downloader/current; nohup bundle exec ruby scripts/start_download.rb >> log/download.log 2>> log/download.log < /dev/null &'


##############################
#
# Deploy scrapper
#
##############################

echo "Cloning scrapper repos"
git clone git@github.com:vdaubry/photo-scrapper.git /home/ubuntu/tmp/photo-scrapper
git clone git@92.222.1.55:/home/git/scrapper-conf.git /home/ubuntu/tmp/scrapper-conf

echo "Copy private conf"
cp /home/ubuntu/tmp/scrapper-conf/*.yml /home/ubuntu/tmp/photo-scrapper/private-conf/
cp /home/ubuntu/tmp/scrapper-conf/.env /home/ubuntu/tmp/photo-scrapper/private-conf/

echo "remove hold ssh host key"
ssh-keygen -R 54.72.162.77

echo "Deploy scrapper to EC2"
cd /home/ubuntu/tmp/photo-scrapper
cap production deploy


echo "Clean files"
rm -Rf /home/ubuntu/tmp