class UserService

  RETURN_MAPPINGS = {
    'create_user' => {
      'is_array' => false,
      'type' => User
    },
    'delete_user_by_id' => {
      'is_array' => false
    },
    'get_all_users' => {
      'is_array' => true,
      'type' => User
    },
    'get_user_by_id' => {
      'is_array' => false,
      'type' => User
    },
    'update_user_by_id' => {
      'is_array' => false,
      'type' => User
    }
  }

  def self.client
    proxy_service = lambda do
      trans  = Barrister::HttpTransport.new("http://localhost:3001/user_service")
      client = Barrister::Client.new(trans)
      client.UserService
    end

    @@service ||= proxy_service.call()
  end

  def self.call(operation, *args)
    result = self.client.send operation, *args

    custom_type = RETURN_MAPPINGS[operation]['type']

    if custom_type
      self.cast operation, result, custom_type
    else
      result
    end
  end

  def self.cast(operation, result, type_klass)
    if RETURN_MAPPINGS[operation]['is_array']
      result.map { |hash| type_klass.new(hash) }
    else
      type_klass.new(result)
    end
  end
end
