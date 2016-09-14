class EmberApplicationController < EmberCli::EmberController
  skip_before_action :authenticate

  def api_not_found
    render status: 404, nothing: true
  end
end
