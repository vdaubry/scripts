sh /home/ubuntu/scripts/deploy.sh
ssh -oStrictHostKeyChecking=no deploy@54.72.162.77 'cd /srv/www/photo-scrapper/current; nohup ruby scrappers/run_website2_page_scrapping.rb $1 >> log/scrapping.log 2>> log/scrapping.log < /dev/null &'