# set the state field for the stte machine
# each model has a specific task defined within the namespace

namespace :set_state do

  desc "Set the state for codes_carc model"
  task :codes_carc => :environment do

    puts "Loading codes_carc"
    begin
      @codes = CodesCarc.unscoped.all
      @codes.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating codes_carc failed #{e.inspect}"
    end
  end


  desc "Set the state for codes_cpt model"
  task :codes_cpt => :environment do

    puts "Loading codes_cpt"
    begin
      @codes = CodesCpt.unscoped.all
      @codes.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating codes_cpt failed #{e.inspect}"
    end
  end

  desc "Set the state for codes_dsm model"
  task :codes_dsm => :environment do

    puts "Loading codes_dsm"
    begin
      @codes = CodesDsm.unscoped.all
      @codes.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating codes_dsm failed #{e.inspect}"
    end
  end


  desc "Set the state for codes_icd9 model"
  task :codes_icd9 => :environment do

    puts "Loading codes_icd9"
    begin
      @codes = CodesIcd9.unscoped.all
      @codes.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating codes_icd9 failed #{e.inspect}"
    end
  end


  desc "Set the state for codes_modifier model"
  task :codes_modifier => :environment do

    puts "Loading codes_modifier"
    begin
      @codes = CodesModifier.unscoped.all
      @codes.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating codes_modifier failed #{e.inspect}"
    end
  end


  desc "Set the state for codes_pos model"
  task :codes_pos => :environment do

    puts "Loading codes_pos"
    begin
      @codes = CodesPos.unscoped.all
      @codes.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating codes_pos failed #{e.inspect}"
    end
  end


  desc "Set the state for codes_rarc model"
  task :codes_rarc => :environment do

    puts "Loading codes_rarc"
    begin
      @codes = CodesRarc.unscoped.all
      @codes.each do |a|
        a.init_record
        if a.perm
          a.lock_record
        elsif a.deleted
          a.delete_record
        end
        puts "id: #{a.id} updated state: #{a.status}"
      end
    rescue => e
      puts "updating codes_rarc failed #{e.inspect}"
    end
  end

end