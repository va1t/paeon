require 'test_helper'
require 'unit_helper'

class PatientsGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @group1 = patients_groups(:one)    
    @admin = users(:admin)
  end
  
  test "validate fixtures" do
    assert @group1.valid?    
  end
  
  test "deleted_fields" do    
    test_deleted @group1    
  end
  
  test "id links to other tables" do
    test_table_links(@group1, "patient_id")
    test_table_links(@group1, "group_id")    
  end  

end
