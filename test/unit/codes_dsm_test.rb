require 'test_helper'
require 'unit_helper'

class CodesDsmTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @dsm = codes_dsms(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @dsm.valid?    
  end

  test "created_user deleted fields" do
    test_created_user @dsm
    test_deleted @dsm    
  end
  
end
