module ApplicationHelper
  
  def copyright_text
    # use html_safe to stop rails from escaping the copyright symbol
    "Copyright &copy; 2011-#{Date.today.year}, P & D Technologies. All Rights Reserved.".html_safe
  end

  # displays the group link at the top of the content area
  def display_group_link
    regexp = /^\/groups\/\d+$/
    if regexp.match request.fullpath
      link = link_to session[:group_name], edit_group_path(session[:group])
    else
      link = link_to session[:group_name], group_path(session[:group])
    end
    return ("Group: " + link).html_safe
  end
  
  
  # displays the provider link at the top of the content area
  def display_provider_link
    regexp = /^\/Providers\/\d+$/
    if regexp.match request.fullpath
      link = link_to session[:provider_name], edit_provider_path(session[:provider])
    else
      link = link_to session[:provider_name], provider_path(session[:provider])
    end
    return ("Provider: " + link).html_safe
  end
  
  
  # displays the patient link at the top of the content area
  def display_patient_link
    regexp = /^\/patients\/\d+\??(therap=\d+|group=\d+)?$/

    if regexp.match request.fullpath
      link= link_to session[:patient_name], edit_patient_path(session[:patient])
    else
      link = link_to session[:patient_name], patient_path(session[:patient])  
    end
    return ("Patient: " + link).html_safe
  end


  # used for ajax calls to update the header notices of errors
  # forms use a different error display that sits on the top of each form  
  def update_notice
    if @msg
      return "<div class='flash'><div class='notice'>#{@msg}</div></div>".html_safe
    end
  end

  
  
  # Put this in your view layout <%= controller_stylesheet_link_tag %>
  def controller_stylesheet_link_tag
    stylesheet = "#{params[:controller]}.css"
      
    if Monalisa::Application.assets.find_asset(stylesheet)
    #if File.exists?(File.join(Rails.public_path, 'stylesheets', stylesheet))
      stylesheet_link_tag stylesheet
    end
  end


  # Put this in your view layout <%= controller_javascript_include_tag %>
  def controller_javascript_include_tag
    javascript = "#{params[:controller]}.js"
      
    if Monalisa::Application.assets.find_asset(javascript)
      javascript_include_tag javascript
    end
  end
  
  
end
