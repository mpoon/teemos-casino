commercial_config = YAML.load_file(Rails.root.join("config/commercial.yml"))[::Rails.env]

Rails.application.config.commercials = ActiveSupport::InheritableOptions.new(commercial_config)
