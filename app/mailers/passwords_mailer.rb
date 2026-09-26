class PasswordsMailer < ApplicationMailer
  def reset
    @user = params[:user]
    mail to: @user.email_address
  end
end
