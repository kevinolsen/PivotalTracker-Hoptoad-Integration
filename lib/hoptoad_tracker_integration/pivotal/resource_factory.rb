require "rest_client"

module HoptoadTrackerIntegration
  module Pivotal
    class ResourceFactory
      API_URL = "https://www.pivotaltracker.com/services/v3"

      def self.project
        resource_path = "#{API_URL}/projects/#{Config[:project_id]}"
        RestClient::Resource.new(resource_path, :headers => {'X-TrackerToken' => Config[:api_key]})
      end
    end
  end
end