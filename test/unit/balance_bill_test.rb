require 'test_helper'

class BalanceBillTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @balance1 = balance_bills(:one)
    @balance2 = balance_bills(:two)
  end
  
  test "verify balance bill record deleteable" do  
    @balance1.update_attributes(:status => BalanceBillFlow::INITIATE, :skip_callbacks => true)
    assert @balance1.deleteable?
    @balance1.update_attributes(:status => BalanceBillFlow::READY, :skip_callbacks => true)
    assert @balance1.deleteable? 
    
    @balance1.update_attributes(:status => BalanceBillFlow::INVOICED, :skip_callbacks => true)
    assert !@balance1.deleteable?
    @balance1.update_attributes(:status => BalanceBillFlow::BALANCE, :skip_callbacks => true)
    assert !@balance1.deleteable?
    @balance1.update_attributes(:status => BalanceBillFlow::CLOSED, :skip_callbacks => true)
    assert !@balance1.deleteable?
  end

end
