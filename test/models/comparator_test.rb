require 'test_helper'

class ComparatorTest < ActiveSupport::TestCase
  
  test "first_present_ingredient" do
    assert_equal 1, c1.send( :first_present_ingredient, 1)[:substance_id]
    assert_equal 100, c1.send( :first_present_ingredient, 1)[:blend_id]
    
    assert_equal 2, c1.send( :first_present_ingredient, 2)[:substance_id]
    assert_equal 100, c1.send( :first_present_ingredient, 2)[:blend_id]

    assert_equal 3, c1.send( :first_present_ingredient, 3)[:substance_id]
    assert_equal 200, c1.send( :first_present_ingredient, 3)[:blend_id]

    assert_equal 4, c1.send( :first_present_ingredient, 4)[:substance_id]
    assert_equal 200, c1.send( :first_present_ingredient, 4)[:blend_id]
  end
  
  
  
  protected
  
  def c1
    Comparator.new blends(:skunk), blends(:sweet)
  end
  
  
end
