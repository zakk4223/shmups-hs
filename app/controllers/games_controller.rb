class GamesController < ApplicationController
  # GET /games
  # GET /games.xml
  def index
    @games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end

  # GET /games/1
  # GET /games/1.xml

  def show
    @game = Game.find(params[:id])
    @score_class = @game.scores
    @score_scope = get_scoped_scores
    
    respond_to do |format|
      format.html # show.html.erb
      format.js   # show.js.erb
      format.bbcode { scores_with_position = @score_scope.ordered.each_with_index {|sc,idx| sc[:score_position] = idx+1}
                      template_map = @game.attributes.merge({:scores => scores_with_position, :raw_scores => @score_class.current_scores})
                      template_string = @game.scoreboard_template
                      render :text => Mustache.render(template_string, template_map)  
        }
      format.xml  { render :xml => @game }
    end
  end

  # GET /games/new
  # GET /games/new.xml
  def new
    @game = Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @game }
    end
  end

  #POST /games/1/score_entry
  def score_entry
    @game = Game.find(params[:id])
    if @game.create_score_entry(params[:score_entry])
      flash[:notice] = 'Score update successfully added'
    else
      flash[:notice] = 'Score update failed. Wonder why!?!?!'
    end
    redirect_to(@game)
  end
  
  
  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.xml
  def create
    @game = Game.new(params[:game])

    respond_to do |format|
      if @game.save
        flash[:notice] = 'Game was successfully created.'
        format.html { redirect_to(@game) }
        format.xml  { render :xml => @game, :status => :created, :location => @game }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.xml
  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        flash[:notice] = 'Game was successfully updated.'
        format.html { redirect_to(@game) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.xml
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to(games_url) }
      format.xml  { head :ok }
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
