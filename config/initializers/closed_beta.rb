beta_config = YAML.load_file(Rails.root.join("config/beta_users.yml"))

TeemosCasino::Application.config.beta_whitelist = beta_config
TeemosCasino::Application.config.closed_beta = ENV['CLOSED_BETA'] == "true"
