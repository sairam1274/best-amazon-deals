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
#  percent_discount :integer
#  original_price   :decimal(, )
#  sale_price       :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class AmazonProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
