class AmazonApi < ActiveRecord::Base
  
  def self.api_item_lookup(item_asin)  
    begin
      $amazon_api_client.item_lookup(query: { 'ItemId' => item_asin, 'ResponseGroup' => 'ItemAttributes,Images,OfferSummary,Offers'}).dig('ItemLookupResponse', 'Items', 'Item')
    rescue
      puts "API error looking up #{item_asin}"
    end
  end
  
  # def item_search(search_index, keyword)
  #   @client.item_search(
  #     query: {
  #       'SearchIndex' => search_index,
  #       'Keywords' => keyword,
  #       'Availability' => 'Available',
  #       'ResponseGroup' => 'ItemAttributes,Images'
  #     }
  #   ).dig('ItemSearchResponse', 'Items', 'Item')
  # end
  
end
