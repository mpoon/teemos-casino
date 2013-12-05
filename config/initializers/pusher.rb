Pusher.app_id = '59700'
Pusher.key = '7cdb1cc4d12f8d5a1959'
Pusher.secret = '67e982af15429cab74e3'

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
