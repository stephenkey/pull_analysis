class Pull
  include ActiveModel::Model
  attr_accessor :all, :list, :find

  BASE_URL = "https://api.github.com/"

  # Get all pulls for an org
  def self.all(*repos)
    results = []
    repos.each do |repo|
      request = list(repo)
      results.push(*request) if request
    end
    results
  end

  # List pulls for a repo
  def self.list(repo)
    Rails.cache.fetch("#{repo}_pulls", expires_in: 2.hours) do
      begin
        response = RestClient.get "#{BASE_URL}repos/#{repo}/pulls"
      rescue RestClient::ExceptionWithResponse => e
        puts "RestClient Error: #{e}"
        return []
      else
        return JSON.parse(response)
      end
    end
  end

  # Get a single pull
  def self.find(repo, number)
    Rails.cache.fetch("#{repo}_pull_#{number}", expires_in: 2.hours) do
      begin
        response = RestClient.get "#{BASE_URL}repos/#{repo}/pulls/#{number}"
      rescue RestClient::ExceptionWithResponse => e
        puts "RestClient Error: #{e}"
        return nil
      else
        return JSON.parse(response)
      end
    end
  end

end
