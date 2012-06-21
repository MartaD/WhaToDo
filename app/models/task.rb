class Task < ActiveRecord::Base
  has_event_calendar
  
  belongs_to :person
  
  attr_accessible :duration, :name, :person_id, :priority
  
  class << self
    def with_priority(_prio)
      find(:all, :conditions => "priority = #{_prio}")
    end
  end
  
end