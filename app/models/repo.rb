class Repo
  include ActiveModel::Model
  attr_accessor :all, :find

  BASE_URL = "https://#{Rails.application.secrets.github_username}:#{Rails.application.secrets.github_token}@api.github.com/"

  def initialize(attributes={})
    super({})
    @org ||= attributes[:org]
  end

  # Get all repos for an org
  def all
    Rails.cache.fetch("#{@org}_repos", expires_in: 2.hours) do
      begin
        response = RestClient.get "#{BASE_URL}orgs/#{@org}/repos"
      rescue RestClient::ExceptionWithResponse => e
        puts "RestClient Error: #{e}"
        return []
      else
        return JSON.parse(response)
      end
    end
  end

  # Get a repo for an org
  def find(name)
    Rails.cache.fetch("#{@org}_repo_#{name}", expires_in: 2.hours) do
      begin
        response = RestClient.get "#{BASE_URL}repos/#{@org}/#{name}"
      rescue RestClient::ExceptionWithResponse => e
        puts "RestClient Error: #{e}"
        return nil
      else
        return JSON.parse(response)
      end
    end
  end

end
