class ScoreentriesController < ApplicationController
  
  
  # GET /scoreentries
  # GET /scoreentries.xml
  def index
    if params[:game_id]
      @game = Game.find(params[:game_id])
      @score_class = @game.score_entry_class
      
      @entries = get_scoped_scores
      
      respond_to do |format|
        format.html # index.html.erb
        format.js 
        format.xml  { render :xml => @entries }
      end
    else
      render :text => "Can't get all scores!", :status => 404
    end
  end
  
  
  # GET /scoreentries/1/edit
  def edit
    @game = Game.find(params[:game_id])
    @score_class = @game.score_entry_class
    @entry = @score_class.find(params[:id])
    
  end
  
  # PUT /scoreentries/1
  # PUT /scoreentries/1.xml
  def update
    @game = Game.find(params[:game_id])
    @score_class = @game.score_entry_class
    @entry = @score_class.find(params[:id])

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        flash[:notice] = 'Score entry was successfully updated.'
        format.html { redirect_to(game_scoreentries_path(@game)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  private
  
  def get_scoped_scores
    #start with an empty scope
    use_scope = @score_class.scoped({})
    #did we ask for current scores? 
    if params[:current] and params[:current] == 'on'
      use_scope = use_scope.scoped(@score_class.send(:current_scores).proxy_options)
    end
    if params[:filters]
      filter_map = params[:filters]
      filter_map.each do |name, value|
        next if not value
        value = [value] unless value.is_a? Array
        value.reject! {|a| not a or a.blank?}
        next if value.empty?
        use_scope = use_scope.scoped(@score_class.scoped(:conditions => {name => value}).proxy_options)
      end
    end
    use_scope
  end
end



