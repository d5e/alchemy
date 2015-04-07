require 'test_helper'

class BlendTest < ActiveSupport::TestCase

  test "create" do

  end

  test "update" do

  end
  
  test "validations" do
    assert false, "some blend validations missing"
  end
  

  test "composition_of_sweet" do
    sweet = [
      [1, 80.0],
      [3, 22.0],
      [4, 30.0],
      ['solvent_2', 808],
      ['solvent_3', 2970]
    ]
    blends(:sweet).composition.each do |k,v|
      c = sweet.shift
      assert_equal c.first, k
      assert_equal c.last, v.amount
      assert_equal c.first, v.substance_id unless k.is_a?(String)
      assert_equal c.first, "solvent_#{v.dilution.solvent_id}" if k.is_a?(String)
    end
  end


  test "composition_of_skunk" do  
    sweet = [
      [1, 60.0],
      [2, 1.5],
      ['solvent_2', 688.5],
    ]
    blends(:skunk).composition.each do |k,v|
      c = sweet.shift
      assert_equal c.first, k
      assert_equal c.last, v.amount
      assert_equal c.first, v.substance_id unless k.is_a?(String)
      assert_equal c.first, "solvent_#{v.dilution.solvent_id}" if k.is_a?(String)
    end
  end
  
  test "essence_composition" do
  end

  test "character_proportions" do

  end

  test "raw_price" do

  end

  test "price_per_gram(m=100000)" do

  end

  test "total_mass" do
    assert_equal 750.0, blends(:skunk).total_mass
    assert_equal 3910.0, blends(:sweet).total_mass
  end

  test "essence_mass" do
    assert_equal 61.5, blends(:skunk).essence_mass
    assert_equal 132.0, blends(:sweet).essence_mass
  end

  test "ingredient_weight" do

  end

  test "concentration" do
    assert_equal 0.082, blends(:skunk).concentration
    assert_equal 0.03376, blends(:sweet).concentration.round(5)
  end

  test "resize!_mg" do
    b = blends(:sweet)
    ec = b.essence_composition
    c = b.concentration
    assert_equal 3910.0, b.total_mass
    b.resize!( mg: 100 )
    assert_equal 100.0, b.total_mass
    assert_equal c, b.concentration
    assert_equal ec, b.essence_composition
  end

  test "resize!_factor" do
    b = blends(:sweet)
    ec = b.essence_composition
    c = b.concentration
    b.resize!( factor: 0.5 )
    assert_equal 66.0, b.essence_mass
    assert_equal 1955.0, b.total_mass
    assert_equal c, b.concentration
    assert_equal ec, b.essence_composition
  end


  test "additional_solvents_amount" do
    assert_equal 0.0, blends(:skunk).additional_solvents_amount
    assert_equal 0.0, blends(:sweet).additional_solvents_amount
  end

  test "max_concentration" do
    # as these two blends don't contain additional solvents, the max_concentration equals concentration
    assert_equal 0.082, blends(:skunk).concentration
    assert_equal 0.03376, blends(:sweet).concentration.round(5)
  end

  test "adjust!(new_concentration)" do

  end

  test "adjust_solvents_by!(ratio)" do

  end

  test "unlock_silent" do

  end

  test "before_destroy" do

  end

  test "careful_save" do

  end

  test "careful_save_allowed" do

  end

  test "just_locked" do

  end

  test "locked_changeable" do

  end
  
end
