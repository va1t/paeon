require 'test_helper'

class CodesCarcTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @codes1 = codes_carcs(:one)
  end

  test "validate fixtures" do
    assert @codes1.valid?

    test_created_user @codes1
    test_common_status @codes1
  end

end
