class AmazonApi < ActiveRecord::Base
  def initialize
    @client = Vacuum.new
    @client.configure(
      aws_access_key_id: ENV["AWS_SECRET_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      associate_tag: 'amaprime00-20'
    )
  end
  
  def item_lookup(item_asin)
    @client.item_lookup(query: { 'ItemId' => item_asin, 'ResponseGroup' => 'ItemAttributes,Images,OfferSummary,Offers'}).dig('ItemLookupResponse', 'Items', 'Item')
  end
  
  def item_search(search_index, keyword)
    @client.item_search(
      query: {
        'SearchIndex' => search_index,
        'Keywords' => keyword,
        'Availability' => 'Available',
        'ResponseGroup' => 'ItemAttributes,Images'
      }
    ).dig('ItemSearchResponse', 'Items', 'Item')
  end
  
end
