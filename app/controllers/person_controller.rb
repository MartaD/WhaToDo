class PersonController < ApplicationController
  def index
    render(:action => :sign_in)
  end
end
