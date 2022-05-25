# frozen_string_literal: true
require 'uri'

class SessionsController < ApplicationController
  include Internationalization
  before_action :require_no_authentication, only: %i[new create]
  before_action :require_authentication, only: :destroy
  before_action :set_user, only: :create

  def new; end

  def create
    if @user&.authenticate(params[:password])
      do_sign_in @user
      remember(user) if params[:remember_me] == '1'
      redirect_to root_path, notice: "#{current_user.name_or_email}!"
    else
      flash.now[:alert] = t('flash.session_alert')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to root_path, status: 303, notice: t('flash.session_close')
  end

  private

  def set_user
    @user = User.find_by email: params[:email]
  end

  def do_sign_in(user)
    sign_in user
    remember(user) if params[:remember_me] == '1'
  end

end
