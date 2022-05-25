# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_no_authentication, only: %i[new create]
  before_action :require_authentication, only: %i[edit update]
  before_action :set_user!, only: %i[edit update]
  before_action :authorize_user!
  after_action :verify_authorized

  def edit; end

  def update
    if @user.update user_params
      redirect_to edit_user_path(@user), notice: t('flash.profile_update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      redirect_to root_path, notice: "#{t('flash.session_welcome')}, #{current_user.name_or_email}!"
    else
      render :new
    end
  end

  private

  def set_user!
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation, :old_password)
  end

  def authorize_user!
    authorize(@user || User)
  end
end
