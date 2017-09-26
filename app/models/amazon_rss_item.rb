# == Schema Information
#
# Table name: amazon_rss_items
#
#  id         :integer          not null, primary key
#  asin       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AmazonRssItem < ActiveRecord::Base
  def self.initialize_feed_sync
    self.get_goldbox_rss_results
  end
  
  def self.get_goldbox_rss_results
    require 'rss'
    rss = RSS::Parser.parse('https://rssfeeds.s3.amazonaws.com/goldbox', false)
    case rss.feed_type
      when 'rss'
        rss.items[0..100].each do |item| 
          AmazonRssItem.first.destroy if AmazonRssItem.count > 50
          AmazonRssItem.process_item(item)
        end
      when 'atom'
        rss.items[0..100].each { |item| AmazonRssItem.process_item(item) }
    end
    # TODO: remove old entries (by timestamp?)
  end
  
  def self.process_item(item)
    if item.link.include?("/dp/")
      record = self.find_or_initialize_by(asin: self.get_asin_from_feed_entry(item))
      record.title = item.title
      record.save
      puts "processed RSS item #{record.asin} - #{record.title}"
    end
  end
  
  def self.get_asin_from_feed_entry(item)
    parsed_array = item.link.split("/")
    index_of_dp = parsed_array.index("dp")
    parsed_array[index_of_dp + 1]
  end
end
