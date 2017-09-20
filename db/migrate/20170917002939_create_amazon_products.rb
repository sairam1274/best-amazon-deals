class CreateAmazonProducts < ActiveRecord::Migration
  def change
    create_table :amazon_products do |t|
      t.string :asin, primary: true
      t.string :title
      t.text :description
      t.string :product_link
      t.string :image_link
      t.decimal :percent_discount
      t.decimal :original_price
      t.decimal :sale_price
      t.timestamps null: false
    end
  end
end
