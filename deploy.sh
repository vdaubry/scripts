echo "Request EC2 instance"
ruby /home/ubuntu/scripts/EC2/start_instance.rb


##############################
#
# Deploy downloader
#
##############################

echo "Cloning repos"
git clone git@github.com:vdaubry/photo-downloader.git
git clone git@92.222.1.55:/home/git/downloader-conf.git

echo "Copy private conf"
cp downloader-conf/*.yml photo-downloader/private-conf/
cp downloader-conf/.env photo-downloader/private-conf/

echo "remove hold ssh host key"
ssh-keygen -R 54.72.162.77

echo "Deploy app to EC2"
cd photo-downloader
cap production deploy

echo "Clean repos"
rm -Rf ../photo-downloader
rm -Rf ../downloader-conf

ssh deploy@54.72.162.77 'cd /srv/www/photo-downloader/current; nohup ruby scripts/start_download.rb $1 >> log/download.log 2>> log/download.log < /dev/null &'


##############################
#
# Deploy scrapper
#
##############################

echo "Cloning repos"
git clone git@github.com:vdaubry/photo-scrapper.git
git clone git@92.222.1.55:/home/git/scrapper-conf.git

echo "Copy private conf"
cp scrapper-conf/*.yml photo-scrapper/private-conf/
cp scrapper-conf/.env photo-scrapper/private-conf/

echo "remove hold ssh host key"
ssh-keygen -R 54.72.162.77

echo "Deploy app to EC2"
cd photo-scrapper
cap production deploy

echo "Clean repos"
rm -Rf ../photo-scrapper
rm -Rf ../scrapper-conf