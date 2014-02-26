class UserMailer < ActionMailer::Base
  default from: "m13162506113@163.com"



  def send_mail(subject,email,body)
    @url  = 'http://example.com/login'
    mail( :subject => subject, 
          :to => email, 
          :from => 'm13162506113@163.com', 
          :date => Time.now,
	  :body=>body
        ) 
  end 
end
