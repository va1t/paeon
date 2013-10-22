require 'test_helper'
require 'unit_helper'

class PatientsProviderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
    def setup
    @ct1 = patients_providers(:one)
    @ct2 = patients_providers(:two)
  end
  
  test "validate fixtures" do
    assert @ct1.valid?
    assert @ct2.valid?    
  end

  test "deleted_fields" do    
    test_deleted @ct1
  end

end
