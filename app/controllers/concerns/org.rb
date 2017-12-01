module Org
  extend ActiveSupport::Concern

  private

  def check_org
    unless params.key?(:org) and params[:org].present?
      respond_to do |format|
        format.json { render json: [] }
      end
    end
  end

end
