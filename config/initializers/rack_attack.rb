class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    error_handler: ->(method:, returning:, exception:) {
      Rails.logger.warn "Redis cache store failed to #{method} with #{exception.class}: #{exception.message}"
      Raven.capture_exception(exception, level: "warning", tags: { method: method, returning: returning })
    }
  )

  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip
  end

  throttle("login/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/api/auth/sign_in" && req.post?
  end

  throttle("login/email", limit: 5, period: 20.seconds) do |req|
    req.params["email"].presence if req.path == "/api/auth/sign_in" && req.post?
  end

  throttle("news/ip", limit: 10, period: 1.hour) do |req|
    req.ip if req.path == "/api/v2/news" && req.get?
  end

  BLOCKED_USER_AGENTS = %w[
    sqlmap
    nikto
    nessus
    masscan
    zgrab
    dirbuster
    havij
    acunetix
  ].freeze

  blocklist("block bad user agents") do |req|
    agent = req.user_agent.to_s.downcase
    agent && BLOCKED_USER_AGENTS.any? { |bad_agent| agent.include?(bad_agent) }
  end

  blocklist("block-sql-injection") do |req|
    path = req.path.downcase
    query = req.query_string.downcase

    sql_patterns = `/union\s+select|drop\s+table|insert\s+into|or\s+'1'='1|;\s*--|\/\*.*\*\//x`

    path_traversal = `/\.\.\/|\.\.\\|%2e%2e/`

    query.match?(sql_patterns) || path.match?(path_traversal)
  end

  self.blocklisted_response = lambda do |env|
    [
      403,
      { "Content-Type" => "application/json" },
      [ {
        error: "Forbidden",
        message: "Your request has been blocked due to suspicious activity."
      }.to_json ]
    ]
  end
  self.throttled_response = lambda do |env|
    match_data = env["rack.attack.match_data"]
    now = match_data[:epoch_time]
    period = match_data[:period]
    retry_after = (period - (now % period)).to_i

    [
      429,
      { "Content-Type" => "application/json", "Retry-After" => retry_after.to_s },
      [ { error: "Throttle limit reached. Retry later." }.to_json ]
    ]
  end
end
