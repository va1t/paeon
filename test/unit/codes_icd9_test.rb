require 'test_helper'
require 'unit_helper'

class CodesIcd9Test < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @icd9 = codes_icd9s(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @icd9.valid?    
  end

  test "created_user delete fields" do
    test_created_user @icd9
    test_common_status @icd9    
  end  
end
