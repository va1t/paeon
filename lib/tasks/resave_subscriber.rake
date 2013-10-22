# rake task resave each subscriber record
# re-run the validations and data error routines
 
namespace :resave do

  desc "Re-Save each subscriber record to force validations to run and data errors to update"
  task :subscriber => :environment do

    puts "Inititiating subscriber re-save"
    @subscribers = Subscriber.all
    
    @subscribers.each do |s|
      if s.save
        puts "#{s.id} updated"
      else
        puts "#{s.id} not updated ****"
      end 
    end
    puts "Completed the Subscriber re-save"
  end
end
