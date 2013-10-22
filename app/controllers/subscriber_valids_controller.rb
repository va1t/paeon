#
# contains the validation information for the specific provider and/or group for the specific patient insurance 
# Each provider and/or group needs to be validated if they are in network or out of network.
#
#
class SubscriberValidsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  #
  #
  def new
    # use a unique polymorphic finder for new becuse the second set of parameters identifies the subscriber
    # it is not part of the polymorphic identifier.     
    @validable = find_validable    
    @subscriber_valid = @validable.subscriber_valids.new(:in_network => SubscriberValid::IN_NETWORK, :subscriber_id => params[:subscriber_id])
    @title = "New Validation"

    case @validable.class.name
      when "PatientsProvider"
        @provider = @validable.provider
      when "PatientsGroup"
        @group = @validable.group
    end 
        
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subscriber_valid }
    end
  end


  def edit
    @validable, @name = find_polymorphic    
    @subscriber_valid = SubscriberValid.find(params[:id])    
    @title = "Edit Validation"
  end


  def create
    @validable, @name = find_polymorphic
    @subscriber_valid = @validable.subscriber_valids.new(params[:subscriber_valid])
    @subscriber_valid.created_user = current_user.login_name
      
    respond_to do |format|
      if @subscriber_valid.save
        format.html { redirect_to patient_path(@validable.patient_id), notice: 'Validation was successfully created.' }
        format.json { render json: @subscriber_valid, status: :created, location: @subscriber_valid }
      else
        format.html { render action: "new" }
        format.json { render json: @subscriber_valid.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    @validable, @name = find_polymorphic
    @subscriber_valid = SubscriberValid.find(params[:id])
    @subscriber_valid.updated_user = current_user.login_name

    respond_to do |format|
      if @subscriber_valid.update_attributes(params[:subscriber_valid])
        format.html { redirect_to patient_path(@validable.patient_id), notice: 'Validation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subscriber_valid.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @validable, @name = find_polymorphic
    @subscriber_valid = SubscriberValid.find(params[:id])
    @subscriber_valid.destroy

    respond_to do |format|
      format.html { redirect_to patient_path(@validable.patient_id) }
      format.json { head :no_content }
    end
  end
  
  
  private
  
  #
  # for the new method.  the second parameters are used to identify the subscriber and are not part 
  # of the polymorphic set of variables
  # All other methods can use the default polymorphic routine.
  def find_validable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
  
end
