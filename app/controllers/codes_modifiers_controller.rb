class CodesModifiersController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # GET /codes_modifiers
  # GET /codes_modifiers.json
  def index
    @codes_modifiers = CodesModifier.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @codes_modifiers }
    end
  end

  # GET /codes_modifiers/1
  # GET /codes_modifiers/1.json
  def show
    @codes_modifier = CodesModifier.find(params[:id])
    @show = true
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @codes_modifier }
    end
  end

  # GET /codes_modifiers/new
  # GET /codes_modifiers/new.json
  def new
    @codes_modifier = CodesModifier.new
    @newedit = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @codes_modifier }
    end
  end

  # GET /codes_modifiers/1/edit
  def edit
    @codes_modifier = CodesModifier.find(params[:id])
    @newedit = true
  end

  # POST /codes_modifiers
  # POST /codes_modifiers.json
  def create
    @codes_modifier = CodesModifier.new(params[:codes_modifier])
    @codes_modifier.created_user = current_user.login_name
    
    respond_to do |format|
      if @codes_modifier.save
        format.html { redirect_to @codes_modifier, notice: 'Codes modifier was successfully created.' }
        format.json { render json: @codes_modifier, status: :created, location: @codes_modifier }
      else
        format.html { render action: "new" }
        format.json { render json: @codes_modifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /codes_modifiers/1
  # PUT /codes_modifiers/1.json
  def update
    @codes_modifier = CodesModifier.find(params[:id])
    @codes_modifier.updated_user = current_user.login_name
    
    respond_to do |format|
      if @codes_modifier.update_attributes(params[:codes_modifier])
        format.html { redirect_to @codes_modifier, notice: 'Codes modifier was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @codes_modifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codes_modifiers/1
  # DELETE /codes_modifiers/1.json
  def destroy
    @codes_modifier = CodesModifier.find(params[:id])
    @codes_modifier.destroy

    respond_to do |format|
      format.html { redirect_to codes_modifiers_url }
      format.json { head :no_content }
    end
  end
end
