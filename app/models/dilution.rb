class Dilution < ActiveRecord::Base
  
  include ActionView::Helpers::NumberHelper
  
  SOLVENTS = {
    :ETH => "Ethanol (>95%)",
    :DPG => "Dipropylene Glycol",
    :JJ  => "Jojoba Oil",
    :ED50 => "50 % Ethanol / 50 % DPG",
    :ED10 => "10 % Ethanol / 90 % DPG",
    :ED20 => "20 % Ethanol / 80 % DPG",
    :ED40 => "40 % Ethanol / 60 % DPG",
    :ED80 => "80 % Ethanol / 20 % DPG",
    :ED90 => "90 % Ethanol / 10 % DPG",
    :ED04 => "4 % Ethanol / 96 % DPG",
    :ED01 => "1 % Ethanol / 99 % DPG",
    :IPM  => "Isopropyl Myristate",
    :BB   => "Benzyl Benzoate",
    :TEC  => "Triethyl Citrate",
    :EI10 => "10 % Ethanol, 90 % Isopropyl Myristate",
    :EI02 => "2 % Ethanol, 98 % Isopropyl Myristate",
    :MPG  => "Monopropylene Glycol",
    :M1E9  => "10 % MPG, 90 % Ethanol",
    :DME => "Carbitol (CAS 111-90-0)",
    :E80M15I5 => "80 % Ethanol, 15 % MPG, 5 % IPM",
    :E75D20I5 =>  "75 % Ethanol, 20 % DPG, 5 % IPM"
  }
  
  CONCENTRATIONS = [ 1.0, 0.5, 0.25, 0.2, 0.1, 0.05, 0.02, 0.01, 0.001, 0.0001, 0.00001 ]
  
  INTENSITIES = (1..10).to_a

  belongs_to :substance
  has_many :ingredients
  
  validates :concentration, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0 }
  
  # concentration example 0,1 % would be stored as 0.001
  # intensity between 1 and 10

  def solvent_human_name
    SOLVENTS[solvent.to_sym]
  end
  
  def to_s
    if concentration == 0.0
      solvent_human_name
    elsif concentration == 1.0
      "Pure"
    else
      "<strong>#{number_with_precision(concentration * 100, precision: 5, strip_insignificant_zeros: true)} %</strong> in #{solvent_human_name}".html_safe
    end
  end
  
end
