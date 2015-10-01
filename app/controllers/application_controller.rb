class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "test", password: "test"
  protect_from_forgery
  helper_method :sort_column, :sort_direction

  protected

  def sort_column
    params[:sort] || 'created_at'
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'desc'
  end
end
