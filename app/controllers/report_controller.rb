class ReportController < ApplicationController
  include LaytimeUtil
  include PdfUtil
  include TimeUtil

  before_filter :ensure_user_logged_in

  def email_report
    # This involves saving the pdf to the file system
    # and then sending an email.
    unless session[:report]
      redirect_to root_url
      return
    end
    @report = session[:report]
    Prawn::Document.generate("testme.pdf") do |pdf|
      generate_pdf(pdf, @report)
    end

    begin 
    Notifier.deliver_pdf_report
      flash[:notice] = "The report has been emailed successfully"
    rescue
      flash[:notice] = "There was an error sending email. Please try again later"
    end
  end
end
