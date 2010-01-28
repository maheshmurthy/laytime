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
    file_name = current_user.username + "_" + rand(100000).to_s + ".pdf"
    @report = session[:report]
    Prawn::Document.generate(file_name) do |pdf|
      generate_pdf(pdf, @report)
    end

    @email = Email.new
    @email.file_name = file_name
    @email.body = "The laytime calculation report has been attached with the mail."
  end

  def send_email
    email = params[:email]
    begin
      Notifier.deliver_pdf_report(email[:recipients], email[:body], email[:file_name])
      flash[:notice] = "The report has been emailed successfully"
    rescue => e
      logger.info e.inspect
      logger.info e.backtrace
      flash[:notice] = "There was an error sending email. Please try again later"
    end
    redirect_to root_url
  end
end
