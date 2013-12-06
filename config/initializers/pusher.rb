pusher_config = YAML.load_file(Rails.root.join("config/pusher.yml"))[::Rails.env]

Pusher.app_id = pusher_config['app_id']
Pusher.key = pusher_config['key']
Pusher.secret = pusher_config['secret']
Pusher.logger = Rails.logger

class PusherClient
  def self.global(event, message)
    unless Rails.configuration.deliver_pusher
      Rails.logger.info "[PusherClient] Ignoring push message" and return
    end
    Pusher.trigger('global', event, message)
  end

  def self.message(user, event, message)
    unless Rails.configuration.deliver_pusher
      Rails.logger.info "[PusherClient] Ignoring push message" and return
    end
    Pusher.trigger("user.#{user.id}", event, message)
  end
end
