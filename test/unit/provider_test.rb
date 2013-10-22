require 'test_helper'

class ProviderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @ther1 = providers(:one)
    @ther2 = providers(:two)
  end
  
  test "validate fixtures" do
    assert @ther1.valid?
    assert @ther2.valid?
    
    test_created_user @ther1
    test_deleted @ther1
  end
  
    test "validate first_name" do
    assert @ther1.valid?
    @ther1.first_name = nil
    assert !@ther1.valid?  
    @ther1.first_name = ""
    assert !@ther1.valid?  
    
    @ther1.first_name = "A"
    assert @ther1.valid?    
    @ther1.first_name = "Abc"
    assert @ther1.valid?
    @ther1.first_name = ""; 41.times {@ther1.first_name << 'a'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:first_name], I18n.translate('errors.messages.too_long', :count => STRING_LRG_LENGTH)
    @ther1.first_name = ""; 40.times {@ther1.first_name << 'a'}
    assert @ther1.valid?    
  end
  
  test "validate last_name" do
    assert @ther1.valid?
    @ther1.last_name = nil
    assert !@ther1.valid?  
    @ther1.last_name = ""
    assert !@ther1.valid?  
    
    @ther1.last_name = "A"
    assert @ther1.valid?    
    @ther1.last_name = "Abc"
    assert @ther1.valid?
    @ther1.last_name = ""; 41.times {@ther1.last_name << 'a'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:last_name], I18n.translate('errors.messages.too_long', :count => STRING_LRG_LENGTH)
    @ther1.last_name = ""; 40.times {@ther1.last_name << 'a'}
    assert @ther1.valid?    
  end
  
  test "validate home phone" do
    assert @ther1.valid?
    #test allow_nil
    @ther1.home_phone = nil
    assert @ther1.valid?    
    #test allow_blank
    @ther1.home_phone = ""
    assert @ther1.valid?
    @ther1.home_phone = ""; 41.times {@ther1.home_phone << '1'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:home_phone], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @ther1.home_phone = "123-1234"
    assert @ther1.valid?
    @ther1.home_phone = "(732) 123-1234"
    assert @ther1.valid?
    @ther1.home_phone = "732 123-1234"
    assert @ther1.valid?      
  end

  test "validate cell phone" do
    assert @ther1.valid?
    #test allow_nil
    @ther1.cell_phone = nil
    assert @ther1.valid?    
    #test allow_blank
    @ther1.cell_phone = ""
    assert @ther1.valid?
    @ther1.cell_phone = ""; 41.times {@ther1.cell_phone << '1'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:cell_phone], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @ther1.cell_phone = "123-1234"
    assert @ther1.valid?
    @ther1.cell_phone = "(732) 123-1234"
    assert @ther1.valid?
    @ther1.cell_phone = "732 123-1234"
    assert @ther1.valid?      
  end

  test "validate provider identifier" do
    assert @ther1.valid?
    @ther1.provider_identifier = nil
    assert @ther1.valid?
    @ther1.provider_identifier = ""
    assert @ther1.valid?
    @ther1.provider_identifier= "12-12345"
    assert @ther1.valid?
      
    @ther1.provider_identifier = ""; 21.times {@ther1.provider_identifier << '1'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:provider_identifier], I18n.translate('errors.messages.too_long', :count => STRING_MED_LENGTH)    
    @ther1.provider_identifier = ""; 20.times {@ther1.provider_identifier << '1'}
    assert @ther1.valid?
  end
  
  test "validate ssn number" do
    assert @ther1.valid?
    @ther1.ssn_number = nil
    assert @ther1.valid?
    @ther1.ssn_number = ""
    assert @ther1.valid?
    @ther1.ssn_number = "123-12-2345"
    assert @ther1.valid?
    
  end


  test "validate ein number" do
    assert @ther1.valid?
    @ther1.ein_number = nil
    assert @ther1.valid?
    @ther1.ein_number = ""
    assert @ther1.valid?
    @ther1.ein_number = "12-12345"
    assert @ther1.valid?
  end
  
  test "validate license number" do
    assert @ther1.valid?
#    @ther1.license_number = nil
#    assert !@ther1.valid?  
#    @ther1.license_number = ""
#    assert !@ther1.valid?  
    @ther1.license_number = "123456"
    assert @ther1.valid?  
    @ther1.license_number = "3A-4BD1234"
    assert @ther1.valid?  
  end
  

  test "upin_usin_id" do
    assert @ther1.valid?
    #test for nil and blank
    @ther1.upin_usin_id = nil
    assert @ther1.valid?
    @ther1.upin_usin_id = ""
    assert @ther1.valid?
    @ther1.upin_usin_id = "1"
    assert @ther1.valid?    
  end


  
  #Regular Expression Testing begins ....
  test "regex test for ssn number" do
    #these will match
    assert_match(REGEX_SSN, "123:12:1234")
    assert_match(REGEX_SSN, "123 12 1234")
    assert_match(REGEX_SSN, "123-12-1234")
    
    #these will also mathc the regex expression
    assert_match(REGEX_SSN, "123-12 1234")
    assert_match(REGEX_SSN, "123-12:1234")
    assert_match(REGEX_SSN, "123:12 1234")
    assert_match(REGEX_SSN, "123:12-1234")
    assert_match(REGEX_SSN, "123 12:1234")
    assert_match(REGEX_SSN, "123 12-1234")
    
    assert_no_match(REGEX_SSN, "123-12")
    assert_no_match(REGEX_SSN, "1")
    assert_no_match(REGEX_SSN, "1-1-1")
    assert_no_match(REGEX_SSN, "1:1:1")
    assert_no_match(REGEX_SSN, "1 1 1")
    assert_no_match(REGEX_SSN, "122#12#1234")
    assert_no_match(REGEX_SSN, "123$12$1234")
    assert_no_match(REGEX_SSN, "aaa-aa-aaaa2")
    assert_no_match(REGEX_SSN, "123-12-aaaa")
    assert_no_match(REGEX_SSN, "aaa:aa:aaaa")
    assert_no_match(REGEX_SSN, "aaa-aa-aaaa")
    assert_no_match(REGEX_SSN, "aaa aa aaaa")
    assert_no_match(REGEX_SSN, "123121234")
  end  
    
  test "regex test for ein number" do
    assert_match(REGEX_EIN, "00-1234567")
    assert_match(REGEX_EIN, "12-1234567")
    
    assert_no_match(REGEX_EIN, "x")
    assert_no_match(REGEX_EIN, "1")
    assert_no_match(REGEX_EIN, "1-1")
    assert_no_match(REGEX_EIN, "123-12345")
    assert_no_match(REGEX_EIN, "12-123456")
    assert_no_match(REGEX_EIN, "123-123456")
    assert_no_match(REGEX_EIN, "ab-abcde")
  end
  
  # tests the regex expression that is used to valid all phone numbers
  test "regex test for phone numbers" do
    assert_match(REGEX_PHONE, "(732) 933-0484")
    assert_match(REGEX_PHONE, "732 933 0484")
    assert_match(REGEX_PHONE, "732-933-0484")
    assert_match(REGEX_PHONE, "732 933-0484")
    assert_match(REGEX_PHONE, "933-0484")
    assert_match(REGEX_PHONE, "933-0484 x123")
    assert_match(REGEX_PHONE, "732 933-0484 x546")
        
    assert_no_match(REGEX_PHONE, "732")
    assert_no_match(REGEX_PHONE, "7329330484")
    assert_no_match(REGEX_PHONE, "what")    
    assert_no_match(REGEX_PHONE, "93-0484")
    assert_no_match(REGEX_PHONE, "933-084")
    assert_no_match(REGEX_PHONE, "732 933-084")
    assert_no_match(REGEX_PHONE, "72 933-084")
  end
end
