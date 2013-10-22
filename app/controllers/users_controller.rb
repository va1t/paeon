class UsersController < ApplicationController
  # users is a grouped controller under the Admin functions
  # url for the user admin functions are under /admin/users
  
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource

  #display the list of users defined in the system
  def index
    @user = User.order(:last_name).all()
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user }
    end
  end
  
  
  #display the details of a single user, including thier rights
  def show
    @user = User.find(params[:id])
    @show = true
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end    
  end


  #displays the new user form for entering user data
  def new
    @user = User.new    
    logger.debug @user.login_name
    logger.debug @roles
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end
  
  
  #handles the post method from new 
  def create
    @user = User.new(params[:user])    
    @user.created_user = current_user.login_name
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, :notice => 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end  
  
  
  #displays the edit form for entering user data, prefilled with the selected user information
  def edit
    @user = User.find(params[:id])
    logger.debug @user.login_name
    logger.debug @roles
  end


  #handles the put method from edit user
  def update    
    @user = User.find(params[:id])    
    @user.updated_user = current_user.login_name
            
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_path, :notice => 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def password
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # password.html.erb
      format.json { render json: @user }
    end

  end
  
  
  def update_password
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to home_index_path, :notice => 'User password was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "password" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  #handles the delete method 
  def destroy
    @user = User.find(params[:id])    
    # then delete the user
    @user.destroy    
    
    respond_to do |format|
      format.html { redirect_to users_path }
      format.json { head :no_content }
    end
  end

end
