require 'test_helper'

class InvoiceDetailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @invoice_detail1 = invoice_details(:one)
    @invoice_detail2 = invoice_details(:two)
  end

  test "default setup" do
    test_created_user @invoice_detail1
    test_common_status @invoice_detail1
  end

end
