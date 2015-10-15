class AccessRequestsController < ApplicationController
  before_action :check_if_enabled

  def self.feature_enabled?
    ENV['REQUEST_ACCESS_FEATURE'].present?
  end

  def new
    session[:access_request_back_to] ||= request.referer
  end

  def create
    AccessRequestMailer.access_request_email(
        request.base_url, current_user, params[:manager_email], params[:reason]).deliver_now
    current_user.update!(access_request_pending: true)
    flash[:success] = 'Access request email sent.'
    redirect_to session.delete(:access_request_back_to)
  end

  private

  def check_if_enabled
    raise ActionController::RoutingError.new('Not Found') unless self.class.feature_enabled?
  end
end
