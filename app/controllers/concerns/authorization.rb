module Authorization
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:notice] = "You a not right's"#t("global.not_authorized")
      redirect_to(request.referer || root_path)
    end
  end
end