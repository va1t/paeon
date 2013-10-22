require 'test_helper'

class CodesDsmsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @codes_dsm = codes_dsms(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:codes_dsms)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create codes_dsm" do
    sign_in @admin
    assert_difference('CodesDsm.count') do
      post :create, codes_dsm: { category: @codes_dsm.category, code: @codes_dsm.code, created_user: @codes_dsm.created_user, deleted: @codes_dsm.deleted, long_description: @codes_dsm.long_description, short_description: @codes_dsm.short_description, updated_user: @codes_dsm.updated_user, version: @codes_dsm.version }
    end

    assert_redirected_to codes_dsm_path(assigns(:codes_dsm))
  end

  test "should show codes_dsm" do
    sign_in @admin
    get :show, id: @codes_dsm
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @codes_dsm
    assert_response :success
  end

  test "should update codes_dsm" do
    sign_in @admin
    put :update, id: @codes_dsm, codes_dsm: { category: @codes_dsm.category, code: @codes_dsm.code, created_user: @codes_dsm.created_user, deleted: @codes_dsm.deleted, long_description: @codes_dsm.long_description, short_description: @codes_dsm.short_description, updated_user: @codes_dsm.updated_user, version: @codes_dsm.version }
    assert_redirected_to codes_dsm_path(assigns(:codes_dsm))
  end

  test "should destroy codes_dsm" do
    sign_in @admin
    assert_difference('CodesDsm.count', -1) do
      delete :destroy, id: @codes_dsm
    end

    assert_redirected_to codes_dsms_path
  end
end
