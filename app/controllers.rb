# -*- coding: utf-8 -*-
IdolCalendar.controllers  do
  get :index do
    @tag    = Tag.filter("name <> 'ALL'").order(:id).first
    @events = current_events(@tag)
    render 'index'
  end

  get :event, :with => :id do
    if @event = Event[params[:id]]
      render 'event'
    else
      error 404
    end
  end

  get :tag, :with => :name do
    if @tag = Tag.find(:name => params[:name].to_s)
      @events = current_events(@tag)
      render 'tag'
    else
      error 404
    end
  end

  get :search do
    render 'search'
  end

  get :result, :map => '/search/result' do
    cond = Sequel.expr(:calendar_id => params[:cid])
    params[:word].split(/\s/).each do |word|
      cond = Sequel.|(cond, Sequel.ilike(:summary, "%#{ word }%"), Sequel.ilike(:description, "%#{ word }%"))
    end
    @events = Event.filter(Sequel.expr{ start >= Date.today }, cond).order(:start, :end).paginate(params[:page].to_i.nonzero? || 1, 200)
    render 'result'
  end

  get :about do
    render 'about'
  end
end
