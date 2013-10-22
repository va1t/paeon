require 'test_helper'

class ReferredTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @reftype = referred_types(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @reftype.valid?    
   
    test_created_user @reftype
    test_deleted @reftype
  end
  
end
