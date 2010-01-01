class Mail < ActionMailer::Base

  def invite(user,recipient,key)
    # Email header info MUST be added here
    recipients recipient
    from  "accounts@kogbox.com"
    subject "Invitation from "+user.login

    # Email body substitutions go here
    body :inviter => user, :recipient => recipient, :key => key    
  end
    
end
