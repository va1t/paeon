require 'test_helper'

class BalanceBillSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @balance1 = balance_bill_sessions(:one)
    @balance5 = balance_bill_sessions(:five)
  end
  
  
  
end
