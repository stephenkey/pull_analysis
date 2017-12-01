class ReposController < ApplicationController
  include Org

  before_action :check_org

  def index
    @repo = Repo.new(org: 'octokit')
    respond_to do |format|
      format.json { render json: @repo.all }
    end
  end

end
