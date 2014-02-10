class UserService
  USER_ATTRIBUTES = %w(id full_name email phone_number)

  def get_all_users()
    call { User.all.map &method(:to_serializable) }
  end

  def get_user_by_id(id)
    call { to_serializable User.find(id) }
  end

  def delete_user_by_id(id)
    call { !!User.destroy(id) }
  end

  def update_user_by_id(id, user_properties)
    call do
      user = User.find(id)
      user.update!(user_properties)
      to_serializable user
    end
  end

  def create_user(user_properties)
    call { to_serializable(User.create!(user_properties)) }
  end

private
  def to_serializable(user_model)
    user_model.serializable_hash.slice *USER_ATTRIBUTES
  end

  def call
    begin
      yield
    rescue ActiveRecord::RecordNotFound => e
      raise Barrister::RpcException.new(101, e.message)
    rescue ActiveRecord::RecordInvalid => e
      raise Barrister::RpcException.new(100, e.message)
    end
  end
end
