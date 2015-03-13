class Dilution < ActiveRecord::Base
  
  include ActionView::Helpers::NumberHelper
  
  SOLVENTS = {
    ETH:    "Ethanol (>95%, MEK verg.)",
    ETH100: "Ethanol 100%",
    MPG:    "Monopropylene Glycol",
    DPG:    "Dipropylene Glycol",
    IPM:    "Isopropyl Myristate",
    TEC:    "Triethyl Citrate",
    BB:     "Benzyl Benzoate",
    TPM:    "Dowanol TPGME (CAS 25498-49-1)",
    DME:    "Carbitol (CAS 111-90-0)",
    JJ:     "Jojoba Oil",

    ED50:   "50 % Ethanol / 50 % DPG",
    ED10:   "10 % Ethanol / 90 % DPG",
    ED20:   "20 % Ethanol / 80 % DPG",
    ED40:   "40 % Ethanol / 60 % DPG",
    ED80:   "80 % Ethanol / 20 % DPG",
    ED90:   "90 % Ethanol / 10 % DPG",
    ED04:   "4 % Ethanol / 96 % DPG",
    ED01:   "1 % Ethanol / 99 % DPG",

    EI10:   "10 % Ethanol, 90 % IPM",
    EI02:   "2 % Ethanol, 98 % IPM",
    EI90:   "90 % Ethanol, 10 % IPM",
    EI70:   "70 % Ethanol, 30 % IPM",
    M1E9:   "10 % MPG, 90 % Ethanol",
    M1E99:  "1 % MPG, 99 % Ethanol",
    E80M15I5: "80 % Ethanol, 15 % MPG, 5 % IPM",
    E75D20I5: "75 % Ethanol, 20 % DPG, 5 % IPM",
    
    UNK:     "Unknown Solvents"
    
  }
  
  CONCENTRATIONS = [ 1.0, 0.5, 0.25, 0.2, 0.1, 0.05, 0.02, 0.01, 0.001, 0.0001, 0.00001 ]
  
  INTENSITIES = (1..10).to_a

  belongs_to :substance
  belongs_to :solvent
  
  has_many :ingredients
  
  validates :concentration, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
  validate :check_for_duplicates
  
  # concentration example 0,1 % would be stored as 0.001
  # intensity between 1 and 10

  def solvent_human_name
    SOLVENTS[self[:solvent].to_sym] rescue self[:solvent].inspect
  end
  
  def to_s
    if concentration == 0.0
      solvent
    elsif concentration == 1.0
      "Pure"
    else
      "<strong>#{number_with_precision(concentration * 100, precision: 5, strip_insignificant_zeros: true)} %</strong> in #{solvent}".html_safe
    end
  end
  
  protected
  
  def check_for_duplicates
    return if persisted?
    errors.add :concentration, :exists if Dilution.where(solvent_id: solvent_id || solvent.id, substance_id: substance_id || substance.id).where("round(concentration,8) = ? ", concentration.round(8)).exists?
  end
  
end
