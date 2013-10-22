require 'test_helper'
require 'unit_helper'

class SubscriberTest < ActiveSupport::TestCase
  
  def setup
    @insured1 = subscribers(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @insured1.valid?       
  end

  test "created user deleted fields" do    
    test_created_user @insured1
    test_deleted @insured1
  end

  test "id links to other tables" do    
    test_table_links(@insured1, "insurance_company_id")    
  end  
  
  test "ins_co_id" do
    
  end
  
  test "ins group" do
    
  end
  
  test "ins policy" do
    
   
  end
  
  test "ins priority" do
    
  end
  
  test "type patient and description" do
    
  end
  
  test "type insurance and decription" do
    
  end 
  
  test "employer phone" do
    assert @insured1.valid?
    #test allow_nil
    @insured1.employer_phone = nil
    assert @insured1.valid?    
    #test allow_blank
    @insured1.employer_phone = ""
    assert @insured1.valid?
    @insured1.employer_phone = ""; 41.times {@insured1.employer_phone << '1'}
    assert !@insured1.valid?
    assert_errors @insured1.errors[:employer_phone], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @insured1.employer_phone = "123-1234"
    assert @insured1.valid?
    @insured1.employer_phone = "(732) 123-1234"
    assert @insured1.valid?
    @insured1.employer_phone = "732 123-1234"
    assert @insured1.valid?      
  end
  
end
