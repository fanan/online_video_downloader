require 'test_helper'

class SegmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "download" do
    seg = segments(:one)
    seg.download
  end
end
