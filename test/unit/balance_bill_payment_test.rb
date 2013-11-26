require 'test_helper'

class BalanceBillPaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @bb_payment1 = balance_bill_payments(:one)
    @bb_payment2 = balance_bill_payments(:two)
  end

  test "default setup" do
    test_created_user @bb_payment1
    test_common_status @bb_payment1
  end

end
