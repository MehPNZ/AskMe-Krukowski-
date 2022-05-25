# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :require_authentication
    before_action :set_user!, only: %i[edit update destroy]
    before_action :authorize_user!
    after_action :verify_authorized

    def index
      respond_to do |format|
        format.html do
          @pagy, @users = pagy User.order(created_at: :desc)
        end

        format.zip do
          UserBulkExportJob.perform_later current_user
          redirect_to admin_users_path, notice: "You'll get an email once this operation is done"
       end
      end
    end

    def create
      if params[:archive].present?
      UserBulkImportJob.perform_later create_blob, current_user
      redirect_to admin_users_path, notice: 'Users imported!'
      end
    end

    def edit
    end

    def update
      if @user.update user_params
        redirect_to admin_users_path, notice: t('flash.user_succes')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, status: 303, notice: t('flash.user_delete')
    end

    private

    def create_blob
      file = File.open params[:archive]
      result = ActiveStorage::Blob.create_and_upload! io: file,
                filename: params[:archive].original_filename
      file.close
      result.key
    end

    def set_user!
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation, :role
      ).merge(admin_edit: true)
    end

    def authorize_user!
      authorize(@user || User)
    end

  end
end
