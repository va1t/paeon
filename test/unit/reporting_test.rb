require 'test_helper'

class ReportingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @report1 = reportings(:one)
  end

  test "validate fixtures" do
    assert @report1.valid?

    test_created_user @report1
    test_common_status @report1
  end



end
