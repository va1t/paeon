require 'test_helper'

class BalanceBillPaymentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @balance_bill = balance_bills(:one)
    @insurance_session = insurance_sessions(:two)
  end
  

end
