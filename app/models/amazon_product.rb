# == Schema Information
#
# Table name: amazon_products
#
#  id               :integer          not null, primary key
#  asin             :string
#  title            :string
#  description      :text
#  product_link     :string
#  image_link       :string
#  percent_discount :decimal(, )
#  original_price   :decimal(, )
#  sale_price       :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class AmazonProduct < ActiveRecord::Base
  
  def self.sync_products
    AmazonRssItem.initialize_feed_sync
    self.destroy_all
    self.process_rss_items
    self.delay(run_at: 5.minutes.from_now).sync_products
  end
  
  def self.process_rss_items
    @api_client = AmazonApi.new
    rss_items = AmazonRssItem.all
    rss_items.each do |item|
      lookup_product = @api_client.item_lookup(item.asin)
      self.process_API_item(lookup_product)
      sleep(5.seconds)
    end
  end
  
  def self.process_API_item(item)
    record = self.find_or_initialize_by(asin: item['ASIN'])
    record.title = item['ItemAttributes']['Title']
    record.product_link = item['ItemLinks']['ItemLink'].select{|x| x['Description'] == 'Technical Details'}[0]['URL']
    record.image_link = item['MediumImage']['URL']
    record.original_price = item['ItemAttributes']['ListPrice']['FormattedPrice'].delete('$ ,')
    record.sale_price = item['OfferSummary']['LowestNewPrice']['FormattedPrice'].delete('$ ,')
    record.percent_discount = ((record.original_price - record.sale_price) / record.original_price).round(2)
    record.save if record.percent_discount != 0 && record.prime_eligible?(item)
  end
  
  ### Instance methods
  
  def prime_eligible?(item)
    true if item['Offers']['TotalOffers'] == "1" and item['Offers']['Offer']['OfferListing']['IsEligibleForPrime'] == "1"
  end
  
end
