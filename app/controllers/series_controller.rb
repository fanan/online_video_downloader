require 'open-uri'

class SeriesController < ApplicationController
  # GET /series
  # GET /series.json
  def index
    @series = Series.all
    @new_series = Series.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @series }
    end
  end

  # GET /series/1
  # GET /series/1.json
  def show
    @series = Series.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @series }
    end
  end

  # GET /series/new
  # GET /series/new.json
  def new
    @series = Series.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @series }
    end
  end

  # GET /series/1/edit
  def edit
    @series = Series.find(params[:id])
  end

  # POST /series
  # POST /series.json
  def create
    @series = Series.new(params[:series])

    respond_to do |format|
      if @series.save
        @series.unify_url
        format.html { redirect_to @series, notice: 'Series was successfully created.' }
        format.json { render json: @series, status: :created, location: @series }
      else
        format.html { render action: "new" }
        format.json { render json: @series.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /series/1
  # PUT /series/1.json
  def update
    @series = Series.find(params[:id])

    respond_to do |format|
      if @series.update_attributes(params[:series])
        format.html { redirect_to @series, notice: 'Series was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @series.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /series/1
  # DELETE /series/1.json
  def destroy
    @series = Series.find(params[:id])
    @series.destroy

    respond_to do |format|
      format.html { redirect_to series_index_url }
      format.json { head :no_content }
    end
  end

  def parse
    #TODO
    #need to handle hidden episodes here
    @series = Series.find(params[:id])
    doc = Nokogiri::HTML(open @series.url)
    doc.css('div#episode ul>li>a').each do |anchor|
      ep = Episode.new(:url=>anchor.attribute('href').value, :title=>anchor.attribute('title').value)
      if ep.save
        @series.episodes << ep
      end
    end
    redirect_to series_path(@series)
  end

  def play
    @series = Series.find(params[:id])
    s = ""
    @series.episodes.each do |episode|
      s << episode.playlist
    end
    send_data(s, {:filename=>"#{@series.title}.m3u", :disposition=>"attatchment"})
  end

  def download
    @series = Series.find(params[:id])
    #binding.pry
    @series.download
    #TODO
    #notice
    redirect_to series_index_url
  end
end
