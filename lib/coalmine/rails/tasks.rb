namespace :coalmine do
  desc "Notify Coalmine of a recent deployment"
  task :deployment, [:version, :author] => [:environment] do |t, args|
    version = Coalmine::VersionNotification.new
    version.version = args[:version]
    version.author = args[:author]
    if Coalmine::Sender.send(version)
      puts "Successfully notified Coalmine of version #{args[:version]}"
    else
      puts "There was an error while notifying Coalmine. Please check the logs for details."
    end
  end
  
  desc "Send a test notification to Coalmine"
  task :test => :environment do
    notification = Coalmine::Notification.new(:message => "Test notification")
    if Coalmine.send(notification)
      puts "Successfully sent notification to Coalmine"
    else
      puts "There was an error while notifying Coalmine. Please check the logs for details"
    end
  end
end