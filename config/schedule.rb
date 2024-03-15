set :environment, :development

every 1.day, at: '0:00 am' do
  rake "reddit:scrape"
end