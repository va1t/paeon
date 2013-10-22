class EobDetailsController < ApplicationController
  # user must be logged into the system
  before_filter :authenticate_user! 
  authorize_resource
  
  # DELETE /eobs_details/1
  # DELETE /eobs_details/1.json
  def destroy
    @eob_detail = EobDetail.find(params[:id])
    @eob_detail.destroy

    respond_to do |format|
      format.html { redirect_to edit_eob_path(params[:eob_id]) }
      format.json { head :no_content }
    end
  end
  
end
