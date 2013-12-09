COMMERCIAL_CONFIG = YAML.load_file(Rails.root.join("config/commercial.yml"))[::Rails.env]
