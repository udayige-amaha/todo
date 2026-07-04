class HelloWorldJob
  include Sidekiq::Job

  def perform(arg1, arg2)
    puts "Hello, World! This is a Sidekiq job.#{[ arg1, arg2 ].inspect}"
  end
end
