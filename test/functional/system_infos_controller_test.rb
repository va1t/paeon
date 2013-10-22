require 'test_helper'

class SystemInfosControllerTest < ActionController::TestCase
  include Devise::TestHelpers
 
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @system_info = system_infos(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :redirect
    assert_redirected_to edit_system_info_path(@system_info)
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @system_info
    assert_response :success
  end

  test "should update system_info" do
    sign_in @admin
    put :update, id: @system_info, 
        system_info: { address1: @system_info.address1, address2: @system_info.address2, city: @system_info.city, ein_number: @system_info.ein_number, 
                       email: @system_info.email, fax_phone: @system_info.fax_phone, first_name: @system_info.first_name, last_name: @system_info.last_name, 
                       organization_name: @system_info.organization_name, work_phone: @system_info.work_phone, state: @system_info.state, zip: @system_info.zip,
                       created_user: @system_info.created_user }
    assert_redirected_to maint_index_path
  end

end
