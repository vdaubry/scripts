sh ../deploy.sh
ssh deploy@54.72.162.77 'cd /srv/www/photo-scrapper/current; nohup ruby scrappers/run_forum2_scrapping.rb >> log/scrapping.log 2>> log/scrapping.log < /dev/null &'