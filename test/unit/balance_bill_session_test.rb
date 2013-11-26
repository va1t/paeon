require 'test_helper'

class BalanceBillSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @balance1 = balance_bill_sessions(:one)
    @balance5 = balance_bill_sessions(:five)
  end

  test "default setup" do
    test_created_user @balance1
    test_common_status @balance1
  end


end
