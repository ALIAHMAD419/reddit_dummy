require './lib/reddit_scraper'
require 'cgi'

namespace :reddit do
  desc 'Scrape Reddit posts from a subreddit'
  task scrape: :environment do
    hours, minutes = check_and_update_time_log
    if hours >= 24
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
      save_timestamp_to_file
    else
      puts "There is still time remaining for 24 hours."
      puts "Remaining time: #{23 - hours} hours and #{60 - minutes} minutes."
    end
  end
end




# # Save current timestamp to time.log file
def save_timestamp_to_file
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  File.open("time.log", "w") do |file|
    file.puts(timestamp)
  end
end


# Calculate time difference in hours and minutes
def time_difference_in_hours_and_minutes(timestamp)
  current_time = Time.now
  stored_time = Time.parse(timestamp)
  difference = current_time - stored_time
  hours = (difference / 3600).to_i
  minutes = ((difference % 3600) / 60).to_i
  [hours, minutes]
end

# Check if 24 hours have passed since the last timestamp
def check_and_update_time_log
  stored_timestamp = File.read("time.log").strip
  hours, minutes = time_difference_in_hours_and_minutes(stored_timestamp)
end
