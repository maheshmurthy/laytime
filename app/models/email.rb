class Email
  attr_accessor :recipients, :body, :file_name

  def initialize(recipients, body, file_name)
    @recipients = recipients
    @body = body
    @file_name = file_name  
  end

  def initialize
  end
end
