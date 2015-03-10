# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

h2o  = Solvent.create name: "Aqua",    symbol: "H2O", cas: "7732-18-5", price: 1, importance: -4, notes: "VP 17.4733 mmHg @ 20 °C"
eth  = Solvent.create name: "Ethanol (pure)", symbol: "ETH", cas: "64-17-5", logP: -0.190, price: 27, notes: "Ethanol, rein >99,5 %, 1511 U, Trinkalkohol, unvergällt; VP 44.600000 mm/Hg @ 20.00 °C"
mek  = Solvent.create name: "2-Butanone", symbol: "MEK", cas: "78-93-3", price: 10, importance: -5, notes: "Methyl Ethyl Ketone"
ipn  = Solvent.create name: "2-Propanol", symbol: "IPN", cas: "67-63-0", price: 3, importance: -5, notes: "Isopropanol"
btx  = Solvent.create name: "Bitrex",     symbol: "DNB", cas: "3734-33-6", price: 50, importance: -5, notes: "Denatonium Benzoate, the most bitter chemical compound known, with bitterness thresholds of 0.05 ppm"

#ethd = Solvent.create name: "Ethanol (EU denat., 94%)", symbol: "EDN", cas: "64-17-5", price: 3, importance: 5, composition: { 0.943188 => eth.id, 0.0288 => mek.id, 0.028 => ipn.id, 0.000012 => btx.id }, notes: "Ethanol, vollständig vergällt nach EU 162/2013"
ethd = Solvent.create name: "Ethanol (EU denat., 94%)", symbol: "EDN", cas: "64-17-5", price: 3, importance: 5, notes: "Ethanol, vollständig vergällt nach EU 162/2013",
        solvent_ingredients_attributes: [ 
          { amount: 100.0, ingredient_id: eth.id, _destroy: false },
          { amount: 3.0,   ingredient_id: mek.id, _destroy: false },
          { amount: 3.0,   ingredient_id: ipn.id, _destroy: false },
          { amount: 0.00125, ingredient_id: btx.id, _destroy: false }
        ]


# ethn = Solvent.create name: "Ethanol 96.6 %", symbol: "E96", cas: "64-17-5", price: 26, importance: 4, composition: { 0.966 => eth.id, 0.033 => h2o.id }, notes: "Ethanol, Trinkalkohol unvergällt;  96,6 % Reinheit, 1411 U"
ethn = Solvent.create name: "Ethanol 96.6 %", symbol: "E96", cas: "64-17-5", price: 26, importance: 4, notes: "Ethanol, Trinkalkohol unvergällt;  96,6 % Reinheit, 1411 U", 
        solvent_ingredients_attributes: [ 
          { amount: 966, ingredient_id: eth.id, _destroy: false },
          { amount: 34,   ingredient_id: h2o.id, _destroy: false }
        ]


mpg = Solvent.create name: "Monopropylene Glycol",  symbol: "MPG", cas: "57-55-6", price: 18, logP: -0.92, notes: "Propane-1,2-diol"
dpg = Solvent.create name: "Dipropylene Glycol",    symbol: "DPG", cas: "25265-71-8", price: 16, logP: -0.589 
ipm = Solvent.create name: "Isopropyl Myristate",   symbol: "IPM", cas: "110-27-0", price: 63, logP: 7.2
tec = Solvent.create name: "Triethyl Citrate", symbol: "TEC", cas: "77-93-0", price: 82, logP: 1.267, notes: "Slightly soluble in water; miscible with ethanol and ether; Vapor Pressure 0.000175 mm/Hg @ 25.00 °C. (est)"
bb  = Solvent.create name: "Benzyl Benzoate",  symbol: "BB", cas: "120-51-4", price: 118, logP: 3.97, notes: "ocurring naturally in Tolu Balsam and Ceylon cinnamon; light balsamic odor; miscible in alcohol, chloroform, ether, oils; soluble in acetone, benzene; insoluble in glycerol"
tpm = Solvent.create name: "Dowanol TPM",    symbol: "TPM", cas: "25498-49-1", price: 100, logP: 0.309, notes: "Tripropylenglykolmonomethylether, VP 0.01 mmHg @ 20 °C"
dme = Solvent.create name: "Carbitol",  symbol: "DME", cas: "111-90-0", price: 100, logP: -0.54, notes: "Diethylene Glycol Monoethyl Ether, VP 0.07 mmHG @ 20 °C, miscible with water in any ratio"
jjo = Solvent.create name: "Jojobaoil", symbol: "JJO", price: 44
unk = Solvent.create name: "Unknown",   symbol: "UNK", notes: "Unknown Solvents"

Solvent.create name: "Hydroxycitronellol", symbol: "XCO", cas: "107-75-5", notes: "not a classic solvent, but a good stabilizer for Hydroxycitronellal @ 75 %", importance: -2