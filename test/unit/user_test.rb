require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @admin = users(:admin)    
    @read = users(:everyone)        
  end
  
  test "validate fixtures for user" do
    #ensure valid input from the fixtures before other tests
    assert @admin.valid?    
    assert @read.valid?
  end
  
  test "validate user name" do
    assert @read.valid?
    # test short length
    @read.login_name = "A"
    assert !@read.valid?
    assert_errors @read.errors[:login_name], I18n.translate('errors.messages.too_short', :count => User::MIN_LENGTH)
    #test equal to min length
    @read.login_name = "Al"
    assert @read.valid?
    #test equal to max length
    @read.login_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCD" 
    assert @read.valid?
    #test long length
    @read.login_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDE" 
    assert !@read.valid?
    assert_errors @read.errors[:login_name], I18n.translate('errors.messages.too_long', :count => User::MAX_LENGTH)
  end
  
  test "validate first name" do
    assert @read.valid?
    #test short length
    @read.first_name = "A"
    assert !@read.valid?
    assert_errors @read.errors[:first_name], I18n.translate('errors.messages.too_short', :count => User::MIN_LENGTH)
    #test equal to min length
    @read.first_name = "Al"
    assert @read.valid?
    #test equal to max length
    @read.first_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCD" 
    assert @read.valid?
    #test long length
    @read.first_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDE" 
    assert !@read.valid?
    assert_errors @read.errors[:first_name], I18n.translate('errors.messages.too_long', :count => User::MAX_LENGTH)
  end
  
  test "validate last name" do
    assert @read.valid?
    #test short length
    @read.last_name = "A"
    assert !@read.valid?
    assert_errors @read.errors[:last_name], I18n.translate('errors.messages.too_short', :count => User::MIN_LENGTH)
    #test equal to min length
    @read.last_name = "Al"
    assert @read.valid?
    #test equal to max length
    @read.last_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCD" 
    assert @read.valid?
    #test long length
    @read.last_name = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDE" 
    assert !@read.valid?
    assert_errors @read.errors[:last_name], I18n.translate('errors.messages.too_long', :count => User::MAX_LENGTH)
  end
  
  test "validate email" do
    assert @read.valid?
    #test !allow_nil
    @read.email = nil
    assert !@read.valid?    
    assert_errors @read.errors[:email], I18n.translate('errors.messages.blank')
    #test !allow_blank
    @read.email = ""
    assert !@read.valid?
    assert_errors @read.errors[:email], I18n.translate('errors.messages.blank')
    #make sure right error message is displayed for bad email
    @read.email = "me@domain"
    assert !@read.valid?
    assert_errors @read.errors[:email], I18n.translate('errors.messages.invalid')    
  end
  
  #test good email addresses against regex
  test "good email address" do
    assert_match(REGEX_EMAIL, "me@usa.domain.com")
    assert_match(REGEX_EMAIL, "me@domain.com")
    assert_match(REGEX_EMAIL, "dd.dd.dd.dd.dd.dd@domain.com")
    assert_match(REGEX_EMAIL, "dd.dd.dd.dd.dd.dd@domain.ws")
  end

  #test bad formatted email addresses against regex
  test "bad email address" do 
    assert_no_match(REGEX_EMAIL, "me@domain")
    assert_no_match(REGEX_EMAIL, "me@.com")
    assert_no_match(REGEX_EMAIL, "me@")
    assert_no_match(REGEX_EMAIL, "me")
    assert_no_match(REGEX_EMAIL, "@mydomain.com")
  end
  
  #test the nil and blank
  test "validate home phone" do
    assert @read.valid?
    #test allow_nil
    @read.home_phone = nil
    assert @read.valid?    
    #test allow_blank
    @read.home_phone = ""
    assert @read.valid?  
  end
  
  #test the nil and blank
  test "validate cell phone" do
    assert @read.valid?
    #test allow_nil
    @read.cell_phone = nil
    assert @read.valid?    
    #test allow_blank
    @read.cell_phone = ""
    assert @read.valid?    
  end
  
  
  # tests the regex expression that is used to valid all phone numbers
  test "good phone numbers" do
    assert_match(REGEX_PHONE, "(732) 933-0484")
    assert_match(REGEX_PHONE, "732 933 0484")
    assert_match(REGEX_PHONE, "732-933-0484")
    assert_match(REGEX_PHONE, "732 933-0484")
    assert_match(REGEX_PHONE, "933-0484")
    assert_match(REGEX_PHONE, "933-0484 x123")
    assert_match(REGEX_PHONE, "732 933-0484 x546")
        
  end

  # tests the regex expression that is used to valid all phone numbers
  test "bad phone numbers" do
    assert_no_match(REGEX_PHONE, "732")
    assert_no_match(REGEX_PHONE, "7329330484")
    assert_no_match(REGEX_PHONE, "what")    
    assert_no_match(REGEX_PHONE, "93-0484")
    assert_no_match(REGEX_PHONE, "933-084")
    assert_no_match(REGEX_PHONE, "732 933-084")
    assert_no_match(REGEX_PHONE, "72 933-084")
  end
  
end
