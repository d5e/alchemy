require 'test_helper'

class ComponentTest < ActiveSupport::TestCase
  
  
  test "should_component_from_substance" do
    c = Component.new Substance.first
    assert_equal 0.0, c.mass
    assert_equal Substance.first, c.molecule
    assert_equal 0.0.percent!.blue!, c.proportion
  end
  
  test "should_component_from_ingredient_substance" do
    c = Component.new Ingredient.first
    assert_equal 60.0, c.mass
    assert_equal Ingredient.first.substance, c.molecule
    assert_equal nil, c.proportion
  end

  test "should_component_from_ingredient_solvent" do
  end
  
  test "should_component_from_component" do
  end
  
  test "should_component_from_params" do
  end
  
  # test "the truth" do
  #   assert true
  # end
end
