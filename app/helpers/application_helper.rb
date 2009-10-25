# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TimeUtil
  def display_date
    if session[:cp_detail] && session[:cp_detail].created_at
        session[:cp_detail].created_at.strftime('%d/%m/%Y')
    else
      DateTime.now.strftime('%d/%m/%Y')
    end
  end
end
