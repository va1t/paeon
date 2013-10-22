require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  
  # test "the truth" do
  #   assert true
  # end
  
  def setup 
    @ther1 = groups(:one)
    @ther2 = groups(:two)
  end
  
  test "validate fixtures" do
    assert @ther1.valid?
    assert @ther2.valid?
    
    test_created_user @ther1
    test_deleted @ther1
  end  
  
  test "validate group_name" do
    assert @ther1.valid?
    @ther1.group_name = nil
    assert !@ther1.valid?  
    @ther1.group_name = ""
    assert !@ther1.valid?  
    
    @ther1.group_name = "A"
    assert @ther1.valid?
    @ther1.group_name = "Abc"
    assert @ther1.valid?
    @ther1.group_name = ""; 41.times {@ther1.group_name << 'a'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:group_name], I18n.translate('errors.messages.too_long', :count => STRING_LRG_LENGTH)
    @ther1.group_name = ""; 40.times {@ther1.group_name << 'a'}
    assert @ther1.valid?    
  end
  
  #test the nil and blank
  test "validate phone" do
    assert @ther1.valid?
    #test allow_nil
    @ther1.office_phone = nil
    assert @ther1.valid?    
    #test allow_blank
    @ther1.office_phone = ""
    assert @ther1.valid?
    @ther1.office_phone = ""; 41.times {@ther1.office_phone << '1'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:office_phone], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @ther1.office_phone = "123-1234"
    assert @ther1.valid?
    @ther1.office_phone = "(732) 123-1234"
    assert @ther1.valid?
    @ther1.office_phone = "732 123-1234"
    assert @ther1.valid?      
  end
  
  #test the nil and blank
  test "validate fax" do
    assert @ther1.valid?
    #test allow_nil
    @ther1.office_fax = nil
    assert @ther1.valid?    
    #test allow_blank
    @ther1.office_fax = ""
    assert @ther1.valid?    
    @ther1.office_fax = ""; 41.times {@ther1.office_fax << '1'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:office_fax], I18n.translate('errors.messages.too_long', :count => PHONE_MAX_LENGTH)
    @ther1.office_fax = "123-1234"
    assert @ther1.valid?
    @ther1.office_fax = "(732) 123-1234"
    assert @ther1.valid?
    @ther1.office_fax = "732 123-1234"
    assert @ther1.valid?
  end
  
  test "valid website" do
    assert @ther1.valid?
    @ther1.web_site = ""
    assert @ther1.valid?
    @ther1.web_site = nil
    assert @ther1.valid?
    @ther1.web_site = "http://www.test.com"
    assert @ther1.valid?
    @ther1.web_site = "http://test.com"
    assert @ther1.valid?
    @ther1.web_site = "www.test.com"
    assert @ther1.valid?
    @ther1.web_site = "https://www.test.com"
    assert @ther1.valid?
  end

  test "validate ein number" do
    assert @ther1.valid?
    @ther1.ein_number = nil
    assert @ther1.valid?
    @ther1.ein_number = ""
    assert @ther1.valid?
    @ther1.ein_number = "12-1234567"
    assert @ther1.valid?
    
    @ther1.ein_number = ""; 21.times {@ther1.ein_number << '1'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:ein_number], I18n.translate('errors.messages.too_long', :count => STRING_MED_LENGTH)
  end
  
  test "validate license number" do
    assert @ther1.valid?
    @ther1.license_number = ""
    assert @ther1.valid?  
    @ther1.license_number = "123456"
    assert @ther1.valid?  
    @ther1.license_number = "3A-4BD1234"
    assert @ther1.valid?  

    @ther1.license_number = ""; 21.times {@ther1.license_number << '1'}
    assert !@ther1.valid?
    assert_errors @ther1.errors[:license_number], I18n.translate('errors.messages.too_long', :count => STRING_MED_LENGTH)
    @ther1.license_number = ""; 20.times {@ther1.license_number << '1'}
    assert @ther1.valid?    
  end
  

  #Regular Expression Testing begins ....
    
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
  
  
  #good websites start with http:// and have a recognized domain name
  test "regex test for website" do
    assert_match(REGEX_WEBSITE, "http://www.some.com")
    assert_match(REGEX_WEBSITE, "www.some.com")
    assert_match(REGEX_WEBSITE, "http://some.com")
    assert_match(REGEX_WEBSITE, "some.net")
    assert_match(REGEX_WEBSITE, "http://www.some.ws")
    assert_match(REGEX_WEBSITE, "https://www.some.com")

    assert_no_match(REGEX_WEBSITE, "http://www.some.xxx")
    assert_no_match(REGEX_WEBSITE, "www.some.xxx")
    assert_no_match(REGEX_WEBSITE, "xxxxxxxxxx")
    assert_no_match(REGEX_WEBSITE, "ftp://www.some.xxx")
    assert_no_match(REGEX_WEBSITE, "http://")
    assert_no_match(REGEX_WEBSITE, "http://xxx")
    assert_no_match(REGEX_WEBSITE, "http://com")        
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
