namespace :ts do
  desc 'The current version of Thinking Sphinx'
  task :version do
    puts "Thinking Sphinx v#{ThinkingSphinx::VERSION}"
  end

  desc 'Generate the Sphinx configuration file'
  task :configure => :environment do
    interface.configure
  end

  desc 'Generate the Sphinx configuration file and process all indices'
  task :index => :environment do
    interface.index
  end

  desc 'Stop Sphinx, index and then restart Sphinx'
  task :rebuild => [:stop, :index, :start]
  desc 'Restart the Sphinx daemon'
  task :restart => [:stop, :start]

  desc 'Start the Sphinx daemon'
  task :start => :environment do
    interface.start
  end

  desc 'Stop the Sphinx daemon'
  task :stop => :environment do
    interface.stop
  end

  def interface
    @interface ||= ThinkingSphinx::RakeInterface.new
  end
end
