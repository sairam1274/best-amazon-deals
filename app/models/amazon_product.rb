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

  @@client = Vacuum.new
  
  def self.sync_products
    AmazonRssItem.initialize_feed_sync
    AmazonProduct.process_rss_items
    self.delay(run_at: 5.minutes.from_now).sync_products
  end
  
  def self.process_rss_items
    rss_items = AmazonRssItem.all
    AmazonProduct.destroy_all
    rss_items.each do |item|
      lookup_product = self.item_lookup(item.asin)
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
  
  ### API methods
  
  def self.item_lookup(item_asin)
    self.configure_API
    @@client.item_lookup(
      query: { 
        'ItemId' => item_asin, 
        'ResponseGroup' => 'ItemAttributes,Images,OfferSummary,Offers'
      }
    ).dig('ItemLookupResponse', 'Items', 'Item')
  end
  
  def self.item_search(search_index, keyword)
    self.configure_API
    @@client.item_search(
      query: {
        'SearchIndex' => search_index,
        'Keywords' => keyword,
        'Availability' => 'Available',
        'ResponseGroup' => 'ItemAttributes,Images'
      }
    ).dig('ItemSearchResponse', 'Items', 'Item')
  end
  
  # TODO: move into shared method (with other models), store as environment variables
  def self.configure_API
    @@client.configure(
      aws_access_key_id: 'AKIAIUKK6JKNN46NG5CQ',
      aws_secret_access_key: '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',
      associate_tag: 'amaprime00-20'
    )
  end
  
  ### Instance methods
  def prime_eligible?(item)
    true if item['Offers']['TotalOffers'] == "1" and item['Offers']['Offer']['OfferListing']['IsEligibleForPrime'] == "1"
  end
  
end
