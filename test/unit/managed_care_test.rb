require 'test_helper'

class ManagedCareTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @managecare = managed_cares(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @managecare.valid?    
   
    test_created_user @managecare
    test_deleted @managecare
  end
  

end
