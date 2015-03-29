class Comparator
  
  # compares different blends with a reference blend
  
  def initialize(*args)
    @blends = args
    @options = args.pop if args.last.is_a?(Hash)
    @options ||= {}
    raise "supplied arguments have to be blends, but was #{@blends.inspect}" if @blends.map(&:class).uniq != [Blend]
  end
  
  def ref
    @blends.first
  end
  
  def ref_essence_composition
    @essence_composition ||= ref.essence_composition
  end
  
  def comparables
    cs = @blends[1,@blends.size-2]
    if block_given?
      cs.map{ |blend| yield(blend) rescue nil }
    else
      cs
    end
  end
  
  def comparables_essences
    @comparables_essences ||= comparables.map(&:essence_composition)
  end
  
  def globals
    {
      total_mass: [ ref.total_mass.mg! ] + comparables{ |b| (b.total_mass / ref.total_mass.to_f).percent! },
      concentration: [ ref.concentration.percent! ] + comparables{ |b| (b.concentration / ref.concentration.to_f).percent! },
    }
  end
  
  def ingredients(sort_by = :name)
    sort(all_substances, sort_by).each do |sub|
      ref_amount = ref_essence_composition[sub.id].to_f rescue 0.0
      if ref_amount > 0.0
        [ref_amount.mg!] + comparables_essences{ |ec| (ec[sub.id] / ref_amount.to_f).percent! }
      else
        fps = first_present_substance(sub.id)
        result = [ 0.0.percent! ]
        comparables_essences.each_with_index do |ec,i|
          result << fps.first == i ? ec.amount.to_f.mg! : (ec[sub.id] / fps.last.to_f).percent!
        end
      end
    end
  end
  
  def solvents
    []
  end
  
  protected
  
  def first_present_substance(substance_id)
    comparables_essences.each_with_index do |ce, i|
      amount = ce[substance_id]
      return [i, amount] if amount > 0.0
    end
  end
  
  def all_substances
    cs.map(&:substances).flatten
  end
  
  def sort(ings, sort_by, up=true)
    i2 = ings.sort{ |a,b| a.send(sort_by) <=> b.send(sort_by) }
    up ? i2 : i2.reverse
  end
  
  
end
