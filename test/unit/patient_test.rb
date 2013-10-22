require 'test_helper'

class PatientTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
    
  def setup
    @patient1 = patients(:one)
    @patient2 = patients(:two)
  end
  
  test "validate fixtures" do
    assert @patient1.valid?
    assert @patient2.valid?    
  end
  
  test "createduser_deleted_fields" do    
    test_created_user @patient1
    test_deleted @patient1
  end
  

  test "validate first_name" do
    assert @patient1.valid?
    @patient1.first_name = nil
    assert !@patient1.valid?  
    @patient1.first_name = ""
    assert !@patient1.valid?  
    
    @patient1.first_name = "A"
    assert @patient1.valid?    
    @patient1.first_name = "Abc"
    assert @patient1.valid?
    @patient1.first_name = ""; 41.times {@patient1.first_name << 'a'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:first_name], I18n.translate('errors.messages.too_long', :count => STRING_LRG_LENGTH)
    @patient1.first_name = ""; 40.times {@patient1.first_name << 'a'}
    assert @patient1.valid?    
  end
  
  test "validate last_name" do
    assert @patient1.valid?
    @patient1.last_name = nil
    assert !@patient1.valid?  
    @patient1.last_name = ""
    assert !@patient1.valid?  
    
    @patient1.last_name = "A"
    assert @patient1.valid?    
    @patient1.last_name = "Abc"
    assert @patient1.valid?
    @patient1.last_name = ""; 41.times {@patient1.last_name << 'a'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:last_name], I18n.translate('errors.messages.too_long', :count => STRING_LRG_LENGTH)
    @patient1.last_name = ""; 40.times {@patient1.last_name << 'a'}
    assert @patient1.valid?    
  end
  
  
  #validates both address1
  test "validate address1" do
    assert @patient1.valid?
    @patient1.address1 = nil
    assert !@patient1.valid?  
    @patient1.address1 = ""
    assert !@patient1.valid?  
    
    @patient1.address1 = "A"
    assert @patient1.valid?    
    @patient1.address1 = "Abcd"
    assert @patient1.valid?
    @patient1.address1 = ""; 41.times {@patient1.address1 << 'a'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:address1], I18n.translate('errors.messages.too_long', :count => STRING_LRG_LENGTH)
    @patient1.address1 = ""; 40.times {@patient1.address1 << 'a'}
    assert @patient1.valid?
  end
  
  test "validate address2" do
    assert @patient1.valid?
    @patient1.address2 = nil
    assert @patient1.valid?  
    @patient1.address2 = ""
    assert @patient1.valid?  
    
    @patient1.address2 = "A"
    assert @patient1.valid?
    @patient1.address2 = ""; 41.times {@patient1.address2 << 'a'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:address2], I18n.translate('errors.messages.too_long', :count => STRING_LRG_LENGTH)
    @patient1.address2 = ""; 40.times {@patient1.address2 << 'a'}
    assert @patient1.valid?    
  end
  
  test "validate city" do
    assert @patient1.valid?
    @patient1.city = nil
    assert !@patient1.valid?  
    @patient1.city = ""
    assert !@patient1.valid?  
    
    @patient1.city = "A"
    assert @patient1.valid?    
    @patient1.city = "Abcd"
    assert @patient1.valid?
    @patient1.city = ""; 21.times {@patient1.city << 'a'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:city], I18n.translate('errors.messages.too_long', :count => STRING_MED_LENGTH)
    @patient1.city = ""; 20.times {@patient1.city << 'a'}
    assert @patient1.valid?
  end
  
  test "validate state" do
    assert @patient1.valid?
    @patient1.state = nil
    assert !@patient1.valid?  
    @patient1.state = ""
    assert !@patient1.valid?  
    @patient1.state = "new jersey"
    assert @patient1.valid?  
    @patient1.state = "NJ"
    assert @patient1.valid?      
  
    @patient1.state = "A"
    assert !@patient1.valid?
    assert_errors @patient1.errors[:state], I18n.translate('errors.messages.too_short', :count => STATE_MIN_LENGTH)
    @patient1.state = "Abcd"
    assert @patient1.valid?
    @patient1.state = ""; 16.times {@patient1.state << 'a'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:state], I18n.translate('errors.messages.too_long', :count => STRING_SML_LENGTH)
    @patient1.state = ""; 15.times {@patient1.state << 'a'}
    assert @patient1.valid?
  end
  
    
  test "validate zip" do
    assert @patient1.valid?
    @patient1.zip = nil
    assert !@patient1.valid?
    #test allow_blank
    @patient1.zip = ""
    assert !@patient1.valid?
    @patient1.zip = "A"
    assert !@patient1.valid?
    assert_errors @patient1.errors[:zip], I18n.translate('errors.messages.too_short', :count => ZIP_MIN_LENGTH)
    
    @patient1.zip = ""; 16.times {@patient1.zip << 'a'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:zip], I18n.translate('errors.messages.too_long', :count => ZIP_MAX_LENGTH)        
    @patient1.zip ="12345"
    assert @patient1.valid?
    @patient1.zip = "12345-1234"
    assert @patient1.valid?
  end
  
  #test the nil and blank
  test "validate work phone" do
    assert @patient1.valid?
    #test allow_nil
    @patient1.work_phone = nil
    assert @patient1.valid?    
    #test allow_blank
    @patient1.work_phone = ""
    assert @patient1.valid?
    @patient1.work_phone = ""; 41.times {@patient1.work_phone << '1'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:work_phone], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @patient1.work_phone = "123-1234"
    assert @patient1.valid?
    @patient1.work_phone = "(732) 123-1234"
    assert @patient1.valid?
    @patient1.work_phone = "732 123-1234"
    assert @patient1.valid?      
  end

  test "validate home phone" do
    assert @patient1.valid?
    #test allow_nil
    @patient1.home_phone = nil
    assert @patient1.valid?    
    #test allow_blank
    @patient1.home_phone = ""
    assert @patient1.valid?
    @patient1.home_phone = ""; 41.times {@patient1.home_phone << '1'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:home_phone], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @patient1.home_phone = "123-1234"
    assert @patient1.valid?
    @patient1.home_phone = "(732) 123-1234"
    assert @patient1.valid?
    @patient1.home_phone = "732 123-1234"
    assert @patient1.valid?      
  end

  test "validate cell phone" do
    assert @patient1.valid?
    #test allow_nil
    @patient1.cell_phone = nil
    assert @patient1.valid?    
    #test allow_blank
    @patient1.cell_phone = ""
    assert @patient1.valid?
    @patient1.cell_phone = ""; 41.times {@patient1.cell_phone << '1'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:cell_phone], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @patient1.cell_phone = "123-1234"
    assert @patient1.valid?
    @patient1.cell_phone = "(732) 123-1234"
    assert @patient1.valid?
    @patient1.cell_phone = "732 123-1234"
    assert @patient1.valid?      
  end

  
  test "validate ssn number" do
    assert @patient1.valid?
    @patient1.ssn_number = nil
    assert @patient1.valid?
    @patient1.ssn_number = ""
    assert @patient1.valid?
    @patient1.ssn_number = "123-12-2345"
    assert @patient1.valid?
    
    @patient1.ssn_number = ""; 21.times {@patient1.ssn_number << '1'}
    assert !@patient1.valid?
    assert_errors @patient1.errors[:ssn_number], I18n.translate('errors.messages.too_long', :count => SSN_LENGTH)    
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
    
  #test regex exp for zip
  test "regex test for zip codes" do
    assert_match(REGEX_ZIP, "07738")
    assert_match(REGEX_ZIP, "07738-1234")
 
    assert_no_match(REGEX_ZIP, "07738-12")
    assert_no_match(REGEX_ZIP, "0773")
    assert_no_match(REGEX_ZIP, "")
    assert_no_match(REGEX_ZIP, "-1234")
    assert_no_match(REGEX_ZIP, "aaaaa-aaaa")
    assert_no_match(REGEX_ZIP, "aaaaa")
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
