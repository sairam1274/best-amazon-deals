# == Schema Information
#
# Table name: products
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  title            :string
#  description      :string
#  product_link     :string
#  image_link       :string
#  percent_discount :integer
#  original_price   :decimal(, )
#  sale_price       :decimal(, )
#

class Product < ActiveRecord::Base

end
