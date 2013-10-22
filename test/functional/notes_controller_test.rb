require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
 # all tests are performed froma patient perspective with the polmorphic notes class
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)
    @note = notes(:one)
    @patient = patients(:one)
  end

  test "should get index" do
    sign_in @admin
    get :index, :patient_id => @patient
    assert_response :success
    assert_not_nil assigns(:notes)
  end

  test "should get new" do
    sign_in @admin
    get :new, :patient_id => @patient
    assert_response :success
  end

  test "should create note" do
    sign_in @admin
    assert_difference('Note.count') do
      post :create, :patient_id => @patient, note: { note: @note.note, created_user: @note.created_user }
    end

    assert_redirected_to patient_notes_path(:patient_id => @patient)
  end

  test "should show note" do
    sign_in @admin
    get :show, :patient_id => @patient, id: @note
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get :edit, :patient_id => @patient, id: @note
    assert_response :success
  end

  test "should update note" do
    sign_in @admin
    put :update, patient_id: @patient, id: @note, note: { note: @note.note, created_user: @note.created_user }
    assert_redirected_to patient_notes_path(patient_id: @patient)
  end

  test "should destroy note" do
    sign_in @admin
    assert_difference('Note.count', -1) do
      delete :destroy, :patient_id => @patient, id: @note
    end

    assert_redirected_to patient_notes_path(:patient_id => @patient)
  end
end
