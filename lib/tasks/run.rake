namespace :alchemy do

  namespace :elastic do
    desc 'Imports Tables into elasticsearch'
    task :import => :environment do
      Blend.import force: true
      Substance.import force: true
      puts "imported successfully"
    end
  end
  
end