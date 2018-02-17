module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      command = AuthorizeApiRequest
        .call({ 'Authorization': request.params[:access_token] })

      if command.success?
        command.result 
      else
        reject_unauthorized_connection
      end
    end
  end
end
