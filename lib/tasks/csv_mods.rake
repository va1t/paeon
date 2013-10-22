# rake task to import procedure modifiers in csv format.
# csv file to be column A: code, column B: description
# modifiers to be stored in a directory seeds under db.
 
namespace :csv do

  desc "Import Procedure Modifiers Codes in CSV format"
  task :mods => :environment do

    require 'csv'

    csv_file_path = "#{Rails.root}/db/seeds/modifiers.csv"
    puts "Loading CSV: #{csv_file_path}"
  
    if CodesModifier.count == 0
      puts "Cleanup & prepare to load Modifiers"
      
      #reload from the csv file
      CSV.foreach(csv_file_path) do |col|
          if !(col[0] == "code" || col[0] == "Code")
            row = CodesModifier.create!({:code => col[0], :description  => col[1], :created_user => 'admin'})
          end
      end
    else
      puts "Modifier codes already seeded, codes not loaded"
    end
    puts "Completed Modifier load"
  end
end
