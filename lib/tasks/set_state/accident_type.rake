# set the state field for the stte machine
# each model has a specific task defined within the namespace

namespace :set_state do

  desc "Set the state for accident_type model"
  task :accident_type => :environment do

    puts "Loading accident_types"
    begin
      @accidents = AccidentType.unscoped.all
      @accidents.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating accident types failed #{e.inspect}"
    end
  end



end