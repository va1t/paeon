require 'test_helper'

class EobDetailsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @eob = eobs(:one)
    @eob_detail = eob_details(:one)
  end

  test "should get destroy" do
    sign_in @admin
    get :destroy, eob_id: @eob.id, id: @eob_detail.id     
    assert_redirected_to edit_eob_path(@eob.id)
  end

end
