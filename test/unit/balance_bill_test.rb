require 'test_helper'

class BalanceBillTest < ActiveSupport::TestCase

  def setup
    @balance1 = balance_bills(:one)
    @balance2 = balance_bills(:two)
  end

  test "default setup" do
    test_created_user @balance1
    test_common_status @balance1
  end

  test "verify balance bill record deleteable" do
    # set the status of balance bills to something > ready, delete should fail


  end

end
