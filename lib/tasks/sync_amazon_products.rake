require 'rake'

task :sync_amazon_products => :environment do
  AmazonProduct.sync_products
end