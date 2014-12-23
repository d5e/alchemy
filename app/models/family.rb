class Family < ActiveRecord::Base
  
  scope :root, lambda { where :parent_id => nil }
  scope :visible, lambda { root }
  scope :hidden, lambda { where :parent_id => true }
  
  belongs_to :parent, class_name: "Family", foreign_key: :parent_id
  has_many :children, class_name: "Family", foreign_key: :parent_id
  has_and_belongs_to_many :blends
  
  validates :name, uniqueness: true, presence: true
  
  def to_s
    name
  end
  
  def selected_blend_ids
    blends.pluck "concat('blend_', blend_id)"
  end
  
  def selected_blend_ids=(seds)
    ids = seds.split(" ").map{|s| s.gsub(/\Ablend_/, '').to_i if s[/\Ablend_/] }.compact
    seds = ids.dup
    ids -= blend_ids
    rems = blend_ids - seds
    blends << Blend.where( id: ids )
    blends.delete Blend.where( id: rems )
  end

end
