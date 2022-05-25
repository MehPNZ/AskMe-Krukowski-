class PasswordResetsController < ApplicationController
  before_action :require_no_authentication
  before_action :set_user, only: %i[edit update]

  def create
    @user = User.find_by email: params[:email]
    
    if @user.present?
      @user.set_password_reset_token

      PasswordResetsMailer.with(user: @user).reset_email.deliver_later
    end

    redirect_to new_session_path, notice: t('.success')
  end

  def edit
  end

  def update
    if @user.update user_params
      redirect_to new_session_path, notice: t('.succes')
    else
    render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation).merge(skip_old_password: true)
  
  end

  def set_user
    redirect_to(new_session_path, notice: t('password_resets.fail')) and return unless params[:user].present?

    @user = User.find_by email: params[:user][:email],
                          password_reset_token: params[:user][:password_reset_token]

    redirect_to(new_session_path, notice: t('password_resets.fail')) unless @user&.password_reset_period_valid?
  end
end