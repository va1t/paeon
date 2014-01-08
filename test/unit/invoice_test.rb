require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @invoice1 = invoices(:one)
    @invoice2 = invoices(:two)
  end

  test "default setup" do
    test_created_user @invoice1
    test_common_status @invoice1
  end

end
