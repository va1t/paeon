require 'test_helper'

class EobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @eob1 = eobs(:one)
    @eob2 = eobs(:two)
  end
  
  test "named scope unassigned" do
    #test to see if the count increases by one
    assert_difference('Eob.unassigned.count') do
      @eob1.update_attributes(:insurance_billing_id => nil) 
    end
  end
  
  test "named scope assigned" do
    @eob1.update_attributes(:insurance_billing_id => nil)
    assert_difference('Eob.assigned.count') do
      #should increase by one.
      @eob1.update_attributes(:insurance_billing_id => 1)
    end
  end
end
