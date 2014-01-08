require 'test_helper'

class InvoicePaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @invoice_payment1 = invoice_payments(:one)
    @invoice_payment2 = invoice_payments(:two)
  end

  test "default setup" do
    test_created_user @invoice_payment1
    test_common_status @invoice_payment1
  end

end
