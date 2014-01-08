require 'test_helper'
require 'unit_helper'

class CodesModifierTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @mods = codes_modifiers(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @mods.valid?    
  end

  test "created_user delete fields" do
    test_created_user @mods
    test_common_status @mods
  end  


end
