# encoding: UTF-8
class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.json
  
  def index
    if current_person
      @tasks = current_person.tasks
      
      #calendar_controler:
      @month = (params[:month] || (Time.zone || Time).now.month).to_i
      @year = (params[:year] || (Time.zone || Time).now.year).to_i
      
      @shown_month = Date.civil(@year, @month)
      
      @event_strips = Task.event_strips_for_month(@shown_month)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tasks }
      end
    else
      redirect_to "/people/sign_in"
    end
    
    
    
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])
    @person = Person.find_by_id(@task.person_id)
    @priority = ["Brak priorytetu", "Pilne Ważne", "Pilne Nieważne", "Niepilne Ważne", "Niepilne Ważne"]
    @status = ["Nieprzydzielone", "Przydzielone"]
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @priority = ["Brak priorytetu", "Pilne Ważne", "Pilne Nieważne", "Niepilne Ważne", "Niepilne Ważne"]
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = current_person.tasks.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    @task = Task.find(params[:id])
    #użytkownik nie może zmienić końca taska - tutaj dbamy o to, żeby koniec był zawsze zaktualizowany
    @task.end_at = @task.start_at + 60*60*@task.duration

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end
  
  def set_priority
    @task = Task.find(params[:id])
    @task.update_attribute(:priority, params[:priority])
    if(:priority == 0)
      @task.update_attribute(:status, 0)
    else
      @task.update_attribute(:status, 1)
    end
    render :nothing => true
  end
  
  def wtd_task
    @task = Task.find(params[:id])
    @person = Person.find_by_id(@task.person_id)
    @priority = ["Brak priorytetu", "Pilne Ważne", "Pilne Nieważne", "Niepilne Ważne", "Niepilne Ważne"]
    @status = ["Nieprzydzielone", "Przydzielone"]
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
    #TO DO:
    #zrobić coś z tą funkcją, żeby się wywoływała w ogóle, a potem ja stworzyć
  end
  
  def wtd_week
    #TO DO:
    #zrobić coś z tą funkcją, żeby się wywoływała w ogóle, a potem ja stworzyć
  end
  
end
