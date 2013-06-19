# Helper methods defined here can be accessed in any controller or view in the application

IdolCalendar.helpers do
  def current_events(tag)
    gateway = Event.filter{ start >= Date.today }
    gateway = gateway.filter( :calendar_id => tag.calendars.map(&:id).flatten) if tag and ! tag.all?
    events  = gateway.order(:start, :end).paginate(params[:page].to_i.nonzero? || 1, 200)
    return events
  end
end
