class PullsController < ApplicationController
  include Org

  before_action :check_org

  def index
    @pull_requests = Rails.cache.fetch("#{params[:org]}_pulls", expires_in: 2.hours) do
      repo_names = Repo.new(org: params[:org]).all.map { |r| r['full_name'] }
      Pull.all(*repo_names)
    end

    respond_to do |format|
      format.json { render json: @pull_requests.length }
    end
  end

end
