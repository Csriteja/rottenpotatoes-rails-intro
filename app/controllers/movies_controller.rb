class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    
    redirect_flag = 0
    @ratings_to_show = []
    @all_ratings = Movie.all_ratings
    if params[:button_clicked]
      session[:ratings]=params[:ratings]
      if params[:ratings].nil? && params[:sort].nil?
        session[:sort]=nil
      end
    end
    
    if params[:sort]
      @sort_by = params[:sort]
      session[:sort] = @sort_by
    elsif session[:sort]
      @sort_by = session[:sort]
      redirect_flag = 1
    else
      @sort_by = nil
    end
    
    if params[:ratings]
      @ratings = params[:ratings]
      session[:ratings] = @ratings
    elsif session[:ratings]
      @ratings = session[:ratings]
      redirect_flag = 1
    else
      @ratings = nil
    end
    
    if @ratings.nil?
      @ratings = Hash.new
      @all_ratings.each do |rating|
        @ratings[rating] = 1
      end
    else
      @ratings_to_show = @ratings.keys
    end
    
    if redirect_flag == 1
      flash.keep
      redirect_to movies_path :sort => @sort_by, :ratings => @ratings
    end
    
    if @ratings && @sort_by
      @movies = Movie.get_sorted_ratings(@ratings.keys, @sort_by)
    elsif @ratings
      @movies = Movie.get_ratings(@ratings.keys)
    elsif @sort_by
      @movies = Movie.all.order(@sort_by)
    else
      @movies = Movie.all
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
