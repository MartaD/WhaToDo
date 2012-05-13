 class AuthController < ApplicationController
 
 def index
  #przypisanie parametrów logowania z formularza
  @email = params[:email]
  @pass = params[:pass]
 
  #poszukiwanie użytkownika po zadanych parametrach
  @user = User.find_by_email_and_pass(@email,@pass)
 
  #jeżeli użytkownik został odnaleziony
  if(@user)
   #utwórz wpis w tablicy sesji z ID użytkownika
   session[:user_id] = @user.id
  end
 
  #jeżeli istnieje wpis w tablicy sesji
  if(session[:user_id])
   #przekieruj na stronę dla zalogowanych
   redirect_to(:action => "secret_method")
  end
 end
 
 def logout
  #dopóki nie ma wpisu w tablicy sesji
  unless session[:user_id]
   #przekieruj do strony logowania
   redirect_to(:action => "index")
  end
 
  #jeżeli jest wpis z ID użytkownika, usuń go (wylogowanie)
  session[:user_id]=nil
 end
 
 def secret_method
  #jeżeli jest wpis w tablicy sesji
  if(session[:user_id])
   @user = User.find(session[:user_id])
   #przypisz do zmiennej nazwe użytkownika
   @logged_as = @user.name
  else
   redirect_to(:action => "index")
  end
 end
end