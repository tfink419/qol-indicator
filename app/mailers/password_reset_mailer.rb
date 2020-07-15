class PasswordResetMailer < ApplicationMailer
  def send_reset_password
    @username = params[:username]
    @url = "#{ENV['URL']}/reset-password?uuid=#{params[:uuid]}"
    mail(to: params[:email], subject: 'Reset Password')
  end
end
