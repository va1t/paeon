require 'test_helper'

class ProviderInsuranceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @provins = provider_insurances(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @provins.valid?    
   
    test_created_user @provins
    test_deleted @provins
  end
  
  test "id links to other tables" do
   # need a different test for the xor
   # test_table_links(@provins, "provider_id")
   # test_table_links(@provins, "group_id")    
    test_table_links(@provins, "insurance_company_id")
  end  
  
end
