require 'test_helper'
require 'unit_helper'

class CodesCptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @cpt = codes_cpts(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @cpt.valid?        
  end
  
  test "created_user deleted fields" do
    test_created_user @cpt
    test_common_status @cpt
  end  
end
