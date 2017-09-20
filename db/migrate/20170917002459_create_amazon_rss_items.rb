class CreateAmazonRssItems < ActiveRecord::Migration
  def change
    create_table :amazon_rss_items do |t|
      t.string :asin, primary: true
      t.string :title
      t.timestamps null: false
    end
  end
end
