class Notifier < ActionMailer::Base  
    
  def password_reset_instructions(user)  
    subject       "Password Reset Instructions"  
    from          "mahesh@mmurthy.com"  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)  
  end

  def confirmation_email(user)
    subject       "Account Created"
    from          "mahesh@mmurthy.com"
    recipients    user.email
    sent_on       Time.now
    body          :edit_confirmation_url => default_url_options[:host] +
      "/password_resets/" + user.perishable_token + "/edit"
  end

  def pdf_report(to, body, filename)
    subject       "Laytime Calculation Report"
    from          "mahesh@mmurthy.com"
    recipients    to 
    sent_on       Time.now
    part          :content_type => "text/html",
                  :body => body

    attachment    :body => File.read(filename),
                  :filename => filename
  end
end
