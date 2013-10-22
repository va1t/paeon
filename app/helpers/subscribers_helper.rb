module SubscribersHelper
  
  def subscriber_gender(gender)
    @str = "<select id='subscriber_subscriber_gender' include_blank='true' name='subscriber[subscriber_gender]'>"
    case gender
    when "Male"
      @str += "<option value=''></option><option value='Male' selected='selected'>Male</option><option value='Female'>Female</option>"
    when "Female"
      @str += "<option value=''></option><option value='Male'>Male</option><option value='Female' selected='selected'>Female</option>"
    else
      @str += "<option value='' selected='selected'></option><option value='Male'>Male</option><option value='Female'>Female</option>"
    end
    @str += "</select>"

    return @str.html_safe
  end
end
