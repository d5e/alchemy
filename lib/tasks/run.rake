namespace :alchemy do

  namespace :elastic do
    desc 'Imports Tables into elasticsearch'
    task :import => :environment do
      Blend.import force: true
      Substance.import force: true
      puts "imported successfully"
    end
  end
  
  namespace :migrate do
    
    desc 'switch solvents from symbol system to relational system'
    task solvents: :environment do
      # test if IDs match
      new_mapping = {"H2O"=>1, "ETH"=>2, "MEK"=>3, "IPN"=>4, "DNB"=>5, "EDN"=>6, "E96"=>7, "MPG"=>8, "DPG"=>9, "IPM"=>10, "TEC"=>11, "BB"=>12, "TPM"=>13, "DME"=>14, "JJO"=>15, "UNK"=>16, "XCO"=>17} 
      symbols = Solvent.where( id: new_mapping.values ).pluck(:symbol)
      expected = new_mapping.keys
      raise "symbols don't match \n#{symbols.inspect} \n#{expected.inspect}" if symbols != expected
      
      old_new_mapping = { BB: "BB", DME: "DME", DPG: "DPG", ETH: "EDN", IPM: "IPM", JJ: "JJO", MPG: "MPG", TEC: "TEC", TPM: "TPM", UNK: "UNK" }
      
      old_new_mapping.each do |old, nw|
        next unless new_mapping[nw]
        Dilution.where( "solvent = '#{old.to_s}'" ).update_all( solvent_id: new_mapping[nw] )
      end
      
    end
    
  end
  
end