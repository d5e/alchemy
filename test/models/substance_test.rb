require 'test_helper'

class SubstanceTest < ActiveSupport::TestCase
  
  test "exist currencies" do
    assert_equal [:GBP, :EUR, :USD], Substance::CURRENCIES.keys
  end
  
  test "update substance" do
    ex = substances(:exaltolide)
    assert_difference "ex.reload.price_per_quantity", 10 do
      ex.price_per_quantity = 30
      ex.save
      assert ex.errors.blank?, "substance has errors #{ex.errors.full_messages}"
    end
  end

  test "price_in_currency_per_100g" do
    ex = substances(:exaltolide)
    assert_equal 40.0, ex.price_in_currency_per_100g
  end

  test "price_in_eur_per_100g" do
    RATE = Substance::CURRENCIES[:GBP]
    ex = substances(:exaltolide)
    assert_equal ex.price_in_currency_per_100g / RATE, ex.price_in_eur_per_100g
  end

  test "to_s" do
    substances(:exaltolide).to_s == substances(:exaltolide).name
  end

  test "cas" do
    ex = substances(:isoesuper)
    assert_equal "54464-57-2 166090-45-5, 68155-66-8", ex.cas
    a = []
    ex.cas{ |c| a << c }
    assert_equal ["54464-57-2", "166090-45-5", "68155-66-8"], a
  end
  
  test "validations" do
    assert false, "substance validations not tested yet"
  end


end