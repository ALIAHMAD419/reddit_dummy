# README

:: Technical Documentation ::  

Ruby version = 3.1.3
Rails version = 7.0.8
Bundler version = 2.4.19

Set Enviroment variables in .env file
DISCOURSE_BASE_URL=https://forum.dryfastingclub.com
DISCOURSE_API_KEY=
DISCOURSE_API_USERNAME=

it will run the rake task every 24 hours from  schedule.rb file
RAILS_ENV=development bundle exec whenever --update-crontab
RAILS_ENV=production bundle exec whenever --update-crontab
to see the cronjobs
crontab -l
To remove jobs entries
crontab -r
