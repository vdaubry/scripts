#!/bin/bash
mkdir -p /home/ubuntu/tmp

echo "Clone private conf"
git clone git@92.222.1.55:/home/git/downloader-conf.git /home/ubuntu/tmp/downloader-conf

echo "Copy private conf"
cp /home/ubuntu/tmp/downloader-conf/*.yml /srv/www/photo-downloader/current/private-conf/
cp /home/ubuntu/tmp/downloader-conf/.env /srv/www/photo-downloader/current/private-conf/

echo "Update source code"
cd /srv/www/photo-downloader/current
git pull
bundle install

echo "start downloader"
nohup god -c /home/deploy/god/downloader.god.rb -D >> /home/deploy/god/log/god.log 2>> /home/deploy/god/log/god.log < /dev/null &