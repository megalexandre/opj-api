# frozen_string_literal: true

class RelativeUrlRootMiddleware
  def initialize(app, root)
    @app = app
    @root = root
  end

  def call(env)
    env['SCRIPT_NAME'] = "#{@root}#{env['SCRIPT_NAME']}"
    @app.call(env)
  end
end
