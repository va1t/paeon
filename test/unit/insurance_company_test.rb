require 'test_helper'

class InsuranceCompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @inscomp = insurance_companies(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @inscomp.valid?    
   
    test_created_user @inscomp
    test_deleted @inscomp
  end
  
  
end
