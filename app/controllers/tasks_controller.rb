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
    
    respond_to do |format|
      if @task.update_attributes(params[:task])
        #użytkownik nie może zmienić końca taska - tutaj dbamy o to, żeby koniec był zawsze zaktualizowany
        @task.update_attribute(:end_at, @task.start_at + 60*60*@task.duration)
        
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
    render :nothing => true
  end
  
  def wtd_task
    # odpalanie: task/:id/wtd -> zaczyna szukać od aktualnej godziny
    # albo:      task/:id/wtd/:shift -> dodatkowy parametr z przesunięciem czasowym,
    #                                   wykorzystywany przy wyszukiwaniu kolejnego
    #                                   dostępnego terminu (gdy jakiś nie pasował)
    @task = Task.find(params[:id])
    @person = Person.find_by_id(@task.person_id)
    
    #godziny w jakich można przydzielać taski:
    @day_starts_at = 8
    @day_ends_at = 16
    
    
    if @task.status == 1
      #nic nie rób - zadanie ma już określony termin
    elsif @task.duration > (@day_ends_at-@day_starts_at)
      #WARN: poniższa funkcja działa dla tasków, które są w stanie zmieścić się w ciągu
      #jednego dnia roboczego!
    else
      
      #jeżeli jest określony parametr to bierz godzinę z niego, jeżeli nie to aktualny czas
      if params[:seconds].to_i == 0
        @start_time = Time.current
      else
        @start_time = Time.at(params[:seconds].to_i)
        #są jakieś głupie problemy ze strefami czasowymi... :/ nie mam czasu z tym walczyć :/
        @start_time = @start_time - @start_time.gmt_offset
      end
      
      # godzina startu wyszukiwania zaokrąglona do najbliższej pełnej godziny
      @start_time = Time.gm(@start_time.year, @start_time.month, @start_time.day, @start_time.hour+1, 0, 0, 0)
      
      @end_time_hour = @start_time.hour + @task.duration
      #czy godzina mieści się w zakresie?
      if @start_time.hour < @day_starts_at
        #zmiana godziny na początek dnia
        @start_time = Time.gm(@start_time.year, @start_time.month, @start_time.day, @day_starts_at,
          @start_time.min, @start_time.sec, @start_time.usec)
      elsif @end_time_hour > @day_ends_at
        #zmiana godziny na początek następnego dnia
        @start_time = Time.gm(@start_time.year, @start_time.month, @start_time.day+1, @day_starts_at,
          @start_time.min, @start_time.sec, @start_time.usec)
      end
      #obliczane ponownie na wypadek zmian start_time
      @end_time = Time.gm(@start_time.year, @start_time.month, @start_time.day, @start_time.hour+@task.duration, 0, 0, 0)
      
      #czy jest przed deadline?
      if @end_time > @task.deadline
        @after_deadline = true
        
      else
        # sprawdź czy któryś task z już przydzielonych ma przedział, który
        # pokrywa się z naszym przedziałem 
        tasks = Task.all(:conditions => { :status => 1 } )
        for @other_task in tasks do
          #jeżeli pokrywa -> ustal godzinę na godzinę zakończenia tego pokrywającego się i szukaj od początku
          if ( ( @other_task.start_at < @end_time ) && ( @start_time < @other_task.end_at ) )
            params[:seconds] = (@other_task.end_at-1).strftime("%s")
            wtd_task
            return
          end
        end
      
        # w przypadku akceptacji: zmień godzinę startu na znalezioną, zmień status na 1
        # wykonywane jest to przez funkcję set_time_and_status wywołaną w widoku
      
      
        # w przypadku szukania dalej:
        # aktualnie znaleziony czas rozpoczęcia zwiększony o 1 godzinę (60*60)
        # -1 to zabezpieczenie na wypadek gdyby znaleziono pełną godzinę, aby zaokrąglanie na początku
        # tej funkcji nie spowodowało przesunięcia o kolejną godzinę do przodu (chamskie, ale działa)
        @new_start_time = @start_time+(60*60)-1
      
      end
      
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @task }
    end
  end
  
  
  def set_time_and_status
    @task = Task.find(params[:id])
    @task.update_attribute(:start_at, Time.at(params[:seconds].to_i))
    @task.update_attribute(:end_at, @task.start_at + 60*60*@task.duration)
    @task.update_attribute(:status, 1)
    redirect_to @task, notice: 'Task time was successfully updated.'
  end
  
  
  def wtd_week
    #TO DO:
    #zrobić coś z tą funkcją, żeby się wywoływała w ogóle, a potem ja stworzyć
  end
  
end
