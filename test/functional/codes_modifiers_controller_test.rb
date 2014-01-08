require 'test_helper'

class CodesModifiersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @codes_modifier = codes_modifiers(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:codes_modifiers)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create codes_modifier" do
    sign_in @admin
    assert_difference('CodesModifier.count') do
      post :create, codes_modifier: { code: @codes_modifier.code, description: @codes_modifier.description, created_user: @codes_modifier.created_user }
    end

    assert_redirected_to codes_modifier_path(assigns(:codes_modifier))
  end

  test "should show codes_modifier" do
    sign_in @admin
    get :show, id: @codes_modifier
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, id: @codes_modifier
    assert_response :success
  end

  test "should update codes_modifier" do
    sign_in @admin
    put :update, id: @codes_modifier, codes_modifier: { code: @codes_modifier.code, description: @codes_modifier.description }
    assert_redirected_to codes_modifier_path(assigns(:codes_modifier))
  end

  test "should destroy codes_modifier" do
    sign_in @admin
    assert_difference('CodesModifier.without_status(:deleted).count', -1) do
      delete :destroy, id: @codes_modifier
    end

    assert_redirected_to codes_modifiers_path
  end
end
