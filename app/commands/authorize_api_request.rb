class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    user
  end

  private

  attr_reader :headers

  def user
    if payload
      @user = User.find_or_create_by google_id: payload['sub'] do |u|
        u.email = payload['email']
        u.name = payload['name']
      end
    end

    @user || errors.add(:token, 'Invalid Token') && nil
  end

  def payload
    begin
      @payload = GoogleIDToken::Validator.new.check(http_auth_header, ENV['GOOGLE_CLIENT_ID'])
    rescue GoogleIDToken::ValidationError => e
      errors.add(:token, e) && nil
    end
  end

  def http_auth_header
    return headers['Authorization'].split(' ').last if headers['Authorization'].present?

    errors.add(:token, 'Missing Token') && nil
  end
end