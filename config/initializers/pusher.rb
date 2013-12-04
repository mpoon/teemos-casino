Pusher.app_id = '59700'
Pusher.key = '7cdb1cc4d12f8d5a1959'
Pusher.secret = '67e982af15429cab74e3'

Pusher.logger = Rails.logger

class PusherClient
  def self.global(event, message)
    Pusher.trigger('global', event, message)
  end
end
