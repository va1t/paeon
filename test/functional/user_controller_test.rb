require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin =      users(:admin)
    @everyone =   users(:everyone)
    @superadmin = users(:superadmin)
    @invoice =    users(:invoice)  
  end

  test "should get index" do
    sign_in @admin
    get :index
    assert_response :success

    # assert the table is present
    assert_tag :tag => 'th', :content => 'Login ID'
    assert_tag :tag => 'th', :content => 'User Name'
    assert_tag :tag => 'th', :content => 'Email Address'    
    assert_tag :tag => 'th', :content => 'Password'
    
    
    #check for the show links for the 3 fixtures
    assert_tag :tag => "a", :attributes => { :href => "/users/#{@admin.id}" }, 
               :content => "#{@admin.last_name}, #{@admin.first_name}"
    assert_tag :tag => "a", :attributes => { :href => "/users/#{@everyone.id}" }, 
               :content => "#{@everyone.last_name}, #{@everyone.first_name}"
    assert_tag :tag => "a", :attributes => { :href => "/users/#{@everyone.id}" }, 
               :content => "#{@everyone.last_name}, #{@everyone.first_name}"

    #check for the edit link, password reset link and delete link for the admin fixture
    assert_tag :tag => "a", :attributes => { :href => "/users/#{@admin.id}/edit" }
    assert_tag :tag => "a", :attributes => { :href => "/users/#{@admin.id}" }
    assert_tag :tag => "a", :attributes => { :href => "/users/#{@admin.id}/password" }, :content => "Reset"
    
    #tests defined in test_helper.rb
    loggedin_menu_displayed
    
    #display the user sidebar 
    sidebar_menu
  end


  test "should get show" do
    sign_in @admin
    get :show, :id => @everyone
    assert_response :success
    
    #test for user id, name and email fields
    assert_tag :tag => 'div', :attributes => {:class => 'left'}
    assert_tag :tag => 'div', :attributes => {:class => 'right'}
    
    #tests defined in test_helper.rb
    loggedin_menu_displayed
    #display the user sidebar 
    sidebar_menu true
  end


  test "should get new " do
    sign_in @admin
    get :new
    assert_response :success
    
    # validate a form with a commit button is displayed
    assert_tag :tag => 'div', :attributes => {:class => 'button'}
    assert_tag :tag => 'input', :attributes => {:type => 'submit', :name => 'commit', :value => 'Create User'}
    assert_tag :tag => 'div', :attributes =>{:class => 'form'}
    
    #tests defined in test_helper.rb
    loggedin_menu_displayed
    #display the user sidebar 
    sidebar_menu
  end


  test "should get create" do
    sign_in @admin
    post :create, :id => @everyone.id, :user => {"login_name" => @everyone.login_name, "first_name"=> @everyone.first_name, "last_name"=> @everyone.last_name, "email" => @everyone.email}
    assert_response :success
  end

  
  test "should get edit" do
    sign_in @admin
    get :edit, :id => @everyone.id
    assert_response :success
    
    #tests defined in test_helper.rb
    loggedin_menu_displayed
    #display the user sidebar 
    sidebar_menu
  end

  test "should get update" do
    sign_in @admin    
    put :update, :id => @everyone.id, :user => {"login_name" => @everyone.login_name, "first_name"=> @everyone.first_name, "last_name"=> @everyone.last_name, "email" => @everyone.email}
    assert_redirected_to users_path    
  end
  
  test "password reset w/ admin" do
    sign_in @admin
    get :password, :id => @everyone.id
    assert_response :success
    
    put :update_password, :id => @everyone.id, :user => {:password => '123456', :password_confirmation => '123456'}, :commit => 'Update User'
    assert_response :redirect
    assert_redirected_to home_index_path
   
  end

  test "should get destroy" do
    sign_in @admin
    delete :destroy, :id => @everyone.id
    assert_redirected_to users_path
  end
  
  def sidebar_menu(show = false)
    assert_tag :tag => "a", :attributes => { :href => new_user_path }, :content => "Create a New User"
    if show
      assert_tag :tag => "a", :attributes => { :href => edit_user_path }, :content => "Edit User"
      assert_tag :tag => "a", :attributes => { :href => user_path }, :content => "Delete User"
    else
      assert_no_tag :tag => "a", :content => "Edit Group"
      assert_no_tag :tag => "a", :content => "Delete Group"  
    end
  end

end
