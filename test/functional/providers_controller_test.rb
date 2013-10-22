require 'test_helper'

class ProvidersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @providers = providers(:one)
    @deletable = providers(:three)
  end

  # test "the truth" do
  #   assert true
  # end
  
  test "should delete provider" do
    sign_in @admin
    assert_difference('Provider.count', -1) do
      delete :destroy, id: @deletable
    end
    assert_redirected_to providers_path
  end
  
  test "should not delete provider" do
    sign_in @admin
    assert_difference('Provider.count', 0) do
      delete :destroy, id: @providers
    end
    assert_redirected_to providers_path
  end

end
