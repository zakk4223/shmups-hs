class Game < ActiveRecord::Base
  
  
  
  

  def after_initialize
    if self.short_name
      self.class.create_scores_association(self.short_name)
    end
  end
  
  def score_entry_class
    if self.short_name
      self.short_name.capitalize.constantize
    end
  end
  
  def create_score_entry(entry_string)
    return if not entry_string or entry_string.empty?
    return if not self.entry_order
    exploded_entry_order = self.entry_order.split(',')
    
    #first, split the entry based on the split character; require spaces on either side; first pass of this code requires
    #sane input..
    my_score_class = self.scores
    score_entry_attribute_map = {}
    score_entry_attribute_map['raw_entry'] = entry_string if my_score_class
    entry_parts = entry_string.split(/\s+#{Regexp.quote(self.entry_split)}\s+/)
    if entry_parts.size <= exploded_entry_order.size
      entry_parts.each_index do |entry_idx|
        score_entry_attribute_map[exploded_entry_order[entry_idx]] = entry_parts[entry_idx].strip    
      end
      my_score_class.create(score_entry_attribute_map)
      return true
    end    
    return false
  end


#  def scores
#    begin
#      score_class = self.short_name.capitalize.constantize
#      return score_class
#    rescue
#      return nil
#    end
#  end
  
  def self.create_scores_association(game_name)
    unless reflect_on_aggregation(:scores)
      reflection = create_reflection(:has_many, :scores, {:class_name => game_name.capitalize}, self)
      collection_accessor_methods(reflection, HasManyAssociation)
    end
  end
end
