require 'test_helper'
require 'unit_helper'

class AccidentTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @accident1 = accident_types(:one)
    @accident2 = accident_types(:two)
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @accident1.valid?
    assert @accident2.valid?
    
    test_created_user @accident1
    test_deleted @accident1
  end
  
  test "test name" do
    assert @accident1.valid?
    @accident1.name = nil
    assert !@accident1.valid?  
    @accident1.name = ""
    assert !@accident1.valid?  
    
    @accident1.name = "A"
    assert @accident1.valid?    
    @accident1.name = "Abc"
    assert @accident1.valid?
    @accident1.name = ""; 51.times {@accident1.name << 'a'}
    assert !@accident1.valid?
    assert_errors @accident1.errors[:name], I18n.translate('errors.messages.too_long', :count => AccidentType::TYPE_MAX_LENGTH)
    @accident1.name = ""; 50.times {@accident1.name << 'a'}
    assert @accident1.valid?   
  end
  
  
  test "test perm" do
    @accident1.perm = true
    assert @accident1.valid?
    @accident1.perm = false
    assert @accident1.valid?

    @accident1.perm = ""
    assert !@accident1.valid?
    assert_errors @accident1.errors[:perm], I18n.translate('errors.messages.inclusion')
    @accident1.perm = nil
    assert !@accident1.valid?
    assert_errors @accident1.errors[:perm], I18n.translate('errors.messages.inclusion')
  end
  
 
end
