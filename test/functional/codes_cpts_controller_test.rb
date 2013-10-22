require 'test_helper'

class CodesCptsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @codes_cpt = codes_cpts(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:codes_cpts)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create codes_cpt" do
    sign_in @admin
    assert_difference('CodesCpt.count') do
      post :create, codes_cpt: { code: @codes_cpt.code, created_user: @codes_cpt.created_user, deleted: @codes_cpt.deleted, long_description: @codes_cpt.long_description, short_description: @codes_cpt.short_description, updated_user: @codes_cpt.updated_user }
    end

    assert_redirected_to codes_cpt_path(assigns(:codes_cpt))
  end

  test "should show codes_cpt" do
    sign_in @admin
    get :show, id: @codes_cpt
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @codes_cpt
    assert_response :success
  end

  test "should update codes_cpt" do
    sign_in @admin
    put :update, id: @codes_cpt, codes_cpt: { code: @codes_cpt.code, created_user: @codes_cpt.created_user, deleted: @codes_cpt.deleted, long_description: @codes_cpt.long_description, short_description: @codes_cpt.short_description, updated_user: @codes_cpt.updated_user }
    assert_redirected_to codes_cpt_path(assigns(:codes_cpt))
  end

  test "should destroy codes_cpt" do
    sign_in @admin
    assert_difference('CodesCpt.count', -1) do
      delete :destroy, id: @codes_cpt
    end

    assert_redirected_to codes_cpts_path
  end
end
