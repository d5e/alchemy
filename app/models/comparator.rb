class Comparator
  
  # compares different blends with a reference blend

  DEVIATION = {
    pale: 7e-3,
    green: 3e-2,
    yellow: 15e-2,
    red: 0.9,
    blue: true
  }
  
  
  def initialize(*args)
    @blends = args.to_a.flatten
    @options = args.pop if args.last.is_a?(Hash)
    @options ||= {}
    raise "supplied arguments have to be blends, but found #{@blends.map(&:class).map(&:name).uniq.join(',')}" if @blends.map(&:class).uniq != [Blend]
  end
  
  def blends
    @blends
  end
  
  def ref
    @blends.first
  end
  
  def ref_essence_composition
    @essence_composition ||= ref.essence_composition(:hashed)
  end
  
  def comparables
    cs = blends[1,blends.size-1]
    if block_given?
      cs.map{ |blend| yield(blend) rescue nil }
    else
      cs
    end
  end
  
  def globals
    {
      total_mass: [ ref.total_mass.mg! ] + comparables{ |b| b.total_mass.mg! },
      total_mass_ratio: [ 1.0.factor! ] + comparables{ |b| (b.total_mass / ref.total_mass.to_f * 1.0).factor! },
      concentration: [ ref.concentration.percent! ] + comparables{ |b| b.concentration.percent! },
      concentration_ratio: [ 1.0.factor! ] + comparables{ |b| (b.concentration / ref.concentration.to_f * 1.0).factor! },
    }
  end
  
  def blends_components_by_substance_id
    @blends_components ||= blends.map{ |b| Component.substances_from_blend_by_substance_id b }
  end
  
  def ingredients(sort_by = :name)
    results = {}
    sort(all_substances, sort_by).each do |sub|
      results[sub] = components_for_substance(sub)
    end
    results
  end
  
  def solvents
    []
  end
  
  protected
  
  def deviation_class(a,b)
    return "" if a == b
    v = a / b.to_f
    v = 1.0 / v if v > 1
    DEVIATION.each do |ccl, d|
      return ccl if d == true || v > 1 - d
    end
  end
  
  def components_for_substance(substance)
    fpm = nil
    cs = blends_components_by_substance_id.map do |bch|
      fpm ||= bch[substance.id] if bch[substance.id].try(:mass)
      if bch[substance.id]
        com = bch[substance.id]
        if fpm != bch[substance.id]
          com.color = deviation_class(fpm.proportion, com.proportion) 
        else
          com.color = :bold
        end
        com
      else
        com = Component.new(substance)
        com.color = :blue
        com
      end
    end
    cs
  end
  
  # def first_massive_component(substance)
  #   blends_components_by_substance_id.each_with_index do |bch, i|
  #     return { blend_ix: i, component: bch[substance.id] } if bch[substance.id]
  #   end
  # end
  
  # DEPRECATED
  def first_present_ingredient(substance_id)
    raise "substance_id cannot be #{substance_id.inspect}" unless substance_id
    blends.map(&:ingredients).flatten.each do |ing|
      next if ing.dilution && ing.dilution.concentration == 0.0
      return { substance: ing.substance, substance_id: ing.substance_id, blend_id: ing.blend_id, ing: ing, substance_mass: ing.substance_mass } if ing.substance_id == substance_id && ing.amount > 0
    end
    {}
  end
  
  def all_substances(bs=nil)
    if bs.is_a?(Blend)
        bs = [bs]
    elsif !bs.is_a?(Array)
      bs = blends
    end
    bs.map(&:ingredients).flatten.select{|ing| ing.having_substance_mass? }.map(&:substance).flatten.uniq
  end
  
  def sort(ings, sort_by, up=true)
    i2 = ings.sort{ |a,b| a.send(sort_by) <=> b.send(sort_by) }
    up ? i2 : i2.reverse
  end
  
  
end
