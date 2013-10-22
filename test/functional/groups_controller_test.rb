require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice) 
    
    @group1 = groups(:one)
    @group2 = groups(:two) 
    @deletable = groups(:three)
  end

  
  test "get index" do
    sign_in @admin
    get :index
    
    assert_response :success
    #check for the table headers
    assert_tag :tag => 'th', :content => 'Group Name'
    assert_tag :tag => 'th', :content => 'Office Phone'
    assert_tag :tag => 'th', :content => 'Group NPI'
    assert_tag :tag => 'th', :content => 'EIN'
    assert_tag :tag => 'th', :content => 'License'    
    
    #check for the two links tothe show page for the two fixtures
    assert_tag :tag => "a", :attributes => { :href => "/groups/#{@group1.id}" }, :content => @group1.group_name
    assert_tag :tag => "a", :attributes => { :href => "/groups/#{@group2.id}" }, :content => @group2.group_name
    #check for the edit links
    assert_tag :tag => "a", :attributes => { :href => "/groups/#{@group1.id}/edit" }
    assert_tag :tag => "a", :attributes => { :href => "/groups/#{@group2.id}/edit" }
    #check for the delete links
    assert_tag :tag => "a", :attributes => { :href => "/groups/#{@group1.id}" }
    assert_tag :tag => "a", :attributes => { :href => "/groups/#{@group2.id}" }
    
    #admin_menu tests defined in test_helper.rb
    loggedin_menu_displayed
    
    #test the sidebar menu
    sidebar_menu
  end
  
  
  test "get index - logged off" do
      sign_out @admin
      get :index
      
      #should redirect to users/sign_in
      assert :redirect
      assert_redirected_to new_user_session_path
  end
  
  
  test "get show" do
    sign_in @admin
    get :show, :id => @group1.id
    assert_response :success
    
    #admin_menu tests defined in test_helper.rb
    loggedin_menu_displayed
    
    #test the sidebar menu
    sidebar_menu(true)
  end
  
  
  test "get show - logged out" do
    sign_out @admin
    get :show, :id => @group1.id
    
    #should redirect to users/sign_in
    assert :redirect
    assert_redirected_to new_user_session_path
  end
  
  test "create a new group" do
    
  end
  
  test "create new group w/bad data" do
    
  end
  
  test "edit a group" do
    
  end
  
  test "edit group w/ bad data" do
    
  end
  
  test "should delete a group" do
    sign_in @admin
    assert_difference('Group.count', -1) do
      delete :destroy, id: @deletable
    end
    assert_redirected_to groups_path
  end
  
  test "should not delete a group" do
    sign_in @admin
    assert_difference('Group.count', 0) do
      delete :destroy, id: @group1
    end
    assert_redirected_to groups_path
  end
  
  
  def sidebar_menu(show = false)
    assert_tag :tag => "a", :attributes => { :href => new_group_path }, :content => "Create a New Group"
    assert_no_tag :tag => "a", :content => "Delete Group"
    if show
      assert_tag :tag => "a", :attributes => { :href => edit_group_path }, :content => "Edit Group"
    else
      assert_no_tag :tag => "a", :content => "Edit Group"     
    end
  end
  
end
