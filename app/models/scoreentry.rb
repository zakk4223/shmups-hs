class Scoreentry < ActiveRecord::Base
  self.abstract_class = true
  named_scope :current_scores, :conditions => {:current => true}
  named_scope :ordered, :order => "score DESC"
  
  before_create :set_current_score
  
  #a game model should have the following attributes/columns at a minimum
  #player - the player name: string
  #score - the score: some sort of numeric, but it just has to be comparable  
  #current - a flag that indicates this is the current score for a player; it is up to the individual
  #          model(s) to determine additional scopes where this matters (multiple modes/difficulties etc)



  def formatted_score
    #this is from ActionView's NumberHelper, number_with_delimiter
    delimiter = ','
    begin
      parts = score.to_s.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
      parts.join '.'
    rescue
      number
    end
  end
  
  def self.values_for(column_name)
    self.find(:all, :select => "DISTINCT #{column_name}").map {|a| a[column_name]}
  end
  
  def score=(score_value)
    if score_value.is_a? String
      self[:score] = score_value.gsub(',', '')
    else
      self[:score] = score_value
    end    
  end
  
  def self.filter_columns
    self.content_columns.reject { |c| ['score', 'created_at', 'updated_at', 'raw_entry', 'current'].include? c.name }
    
  end
  def set_current_score
    self.class.update_all("current = 'f'", ['lower(player) = lower(?) ', self.player])
    self.current = true
  end

end