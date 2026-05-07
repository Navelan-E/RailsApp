class InternalApi::MechanicsService
  BASE_URL = "http://localhost:3000/api/v1"

  def self.index(token, query = '')
    response = connection(token).get("mechanics", { q: query })

    return [] unless response.success?
    JSON.parse(response.body)
  rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
    Rails.logger.error("API Error: #{e.message}")
    []
  end

    def self.connection(token)
    Faraday.new(url: BASE_URL) do |f|
      f.headers["Authorization"] = "Bearer #{token}"
      f.headers["Content-Type"] = "application/json"
      f.options.open_timeout = 2
      f.options.timeout = 5
      f.adapter Faraday.default_adapter
    end
  end
end