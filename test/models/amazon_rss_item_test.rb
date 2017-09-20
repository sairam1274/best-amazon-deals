# == Schema Information
#
# Table name: amazon_rss_items
#
#  id         :integer          not null, primary key
#  asin       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class AmazonRssItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
