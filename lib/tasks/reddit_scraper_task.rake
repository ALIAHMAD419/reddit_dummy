require './lib/reddit_scraper'
require 'cgi'

namespace :reddit do
  desc 'Scrape Reddit posts from a subreddit'
  task scrape: :environment do
    subreddit = 'dryfasting'
    scraper = RedditScraper.new(subreddit)
    posts = scraper.scrape

    discourse_client = DiscourseApi::Client.new(ENV['DISCOURSE_BASE_URL'])
    discourse_client.api_key = ENV['DISCOURSE_API_KEY']
    discourse_client.api_username = ENV['DISCOURSE_API_USERNAME']

    flair_categories = { 'Experience' => 11, 'Question' => 7, 'Questions' => 7, 'Science' => 12 }

    posts.each do |post|
      begin
        category = flair_categories[post[:flair]] || 4
        discourse_client.create_topic(
          category: category,
          title: post[:title],
          raw: CGI.unescapeHTML(post[:description])
        )
        puts "post created post_url: #{post[:url]}"
      rescue StandardError => e
        puts "Error creating post: #{e.message} post_url: #{post[:url]}"
      end
    end
  end
end
