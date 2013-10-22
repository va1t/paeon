class NotesController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user!  
  authorize_resource
  
  # GET /notes
  # GET /notes.json
  def index
    @noteable, @name = find_polymorphic
    @notes = @noteable.notes.order("id DESC")
    @title = @name + " Note"

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notes }
    end
  end

  # GET /notes/1
  # GET /notes/1.json
  def show
    @noteable, @name = find_polymorphic
    @note = Note.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @note }
    end
  end


  # GET /notes/new
  # GET /notes/new.json
  def new
    @noteable, @name = find_polymorphic
    @note = Note.new
    @title = @name + " Note"
    @newedit = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @note }
    end
  end


  # GET /notes/1/edit
  def edit
    @noteable, @name = find_polymorphic
    @note = Note.find(params[:id])
    @title = @name + " Note"
    @newedit = true
  end


  # POST /notes
  # POST /notes.json
  def create
    @noteable, @name = find_polymorphic
    @note = @noteable.notes.build(params[:note])
    @note.created_user = current_user.login_name
    
    respond_to do |format|
      if @note.save
        format.html { redirect_to polymorphic_path([@noteable, :notes]), notice: 'Note was successfully created.' }
        format.json { render json: @note, status: :created, location: @note }
      else
        format.html { render action: "new" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.json
  def update
    @noteable, @name = find_polymorphic
    @note = Note.find(params[:id])
    @note.updated_user = current_user.login_name

    respond_to do |format|
      if @note.update_attributes(params[:note])
        format.html { redirect_to polymorphic_path([@noteable, :notes]), notice: 'Note was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.json
  def destroy
    @noteable, @name = find_polymorphic
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_path([@noteable, :notes]) }
      format.json { head :no_content }
    end
  end
  
end
