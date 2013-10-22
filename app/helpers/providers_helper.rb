module ProvidersHelper
  
    
  #
  # creates the html code to be inserted into the seach_dialog div 
  # jquery dialog then uses this html inside a dialog popup box
  def provider_search(providers)   
    @str = ""
    providers.each do |t|
      @str += link_to "#{t.last_name}, #{t.first_name}", provider_path(t.id) 
      @str += "<br />"
    end      
    return @str.html_safe  
  end
  
end
