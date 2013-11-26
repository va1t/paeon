require 'test_helper'

class BalanceBillDetailsTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @balance1 = balance_bill_details(:one)
    @balance2 = balance_bill_details(:two)
  end


  test "default setup" do
    test_created_user @balance1
    test_common_status @balance1
  end


end
