require 'net/http'
require 'json'


class RedditScraper
  def initialize(subreddit)
    @subreddit = subreddit
  end

  def scrape
    uri = URI("https://www.reddit.com/r/#{@subreddit}/.json")
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      extract_posts(data)
    else
      puts "Failed to fetch data from Reddit. Status code: #{response.code}"
      []
    end
  end

  private

  def extract_posts(data)
    posts = []
    data['data']['children'].each do |child|
      post_data = child['data']
      title = post_data['title']
      url = post_data['url']
      flair = post_data['link_flair_text'] || 'No flair'
      body = post_data['selftext']
      description = post_data['selftext_html'] # This field might contain HTML
      creation_date = Time.at(post_data['created_utc'])

      flairs = ["Science", "Experience", "Question", "General", "Questions"].freeze
      # Check if post is within the last 24 hours
      next unless (creation_date >= 24.hours.ago && flairs.include?(flair))

        posts << {
          title: title,
          url: url,
          flair: flair,
          body: body,
          description: description,
          creation_date: creation_date
        }
    end
    posts
  end
end
