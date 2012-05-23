class Task < ActiveRecord::Base
  belongs_to :person
  
  attr_accessible :duration, :name, :person_id
end
