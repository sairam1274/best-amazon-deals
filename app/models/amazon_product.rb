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
    self.process_rss_items
  end
  
  def self.process_rss_items
    rss_items = AmazonRssItem.all
    rss_items.each do |item|
      begin
        lookup_product = AmazonApi.api_item_lookup(item.asin)
        self.process_API_item(lookup_product) if lookup_product
      ensure
        sleep(2.seconds)
      end
    end
  end
  
  def self.process_API_item(item)
    if item['OfferSummary']['TotalNew'].to_i > 0
      record = self.find_or_initialize_by(asin: item['ASIN'])
      begin
        record.title = item['ItemAttributes']['Title']
        record.product_link = item['ItemLinks']['ItemLink'].select{|x| x['Description'] == 'Technical Details'}[0]['URL']
        record.image_link = item['MediumImage']['URL']
        record.original_price = item['ItemAttributes']['ListPrice']['FormattedPrice'].delete('$ ,')
        record.sale_price = item['OfferSummary']['LowestNewPrice']['FormattedPrice'].delete('$ ,')
        record.percent_discount = ((record.original_price - record.sale_price) / record.original_price).round(2)
        if record.percent_discount != 0 && record.sale_price != 0 && record.prime_eligible?(item)
          AmazonProduct.first.destroy if AmazonProduct.count > 50
          record.save 
          puts "processed Amazon product #{record.asin} - #{record.title}"
        end
      rescue
        puts "couldn't process #{record.asin}-#{record.title}"
      end
    end
  end
  
  ### Instance methods
  
  def prime_eligible?(item)
    true if item['Offers']['TotalOffers'] == "1" and item['Offers']['Offer']['OfferListing']['IsEligibleForPrime'] == "1"
  end
  
end
