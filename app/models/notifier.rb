class Notifier < ActionMailer::Base  
    
  def password_reset_instructions(user)  
    subject       "Password Reset Instructions"  
    from          "mahesh@mmurthy.com"  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)  
  end

  def pdf_report
    subject       "Laytime Calculation Report"
    from          "mahesh@mmurthy.com"
    recipients    "searchmahesh@gmail.com"
    sent_on       Time.now
    part          :content_type => "text/html",
                  :body => "Please find the attached report with the details."

    attachment    :body => File.read("testme.pdf"),
                  :filename => "testme.pdf"
  end
end
