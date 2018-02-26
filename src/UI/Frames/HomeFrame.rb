require 'yaml'
require_relative 'ChapterFrame'
require_relative 'OptionFrame'
<<<<<<< HEAD
=======
require_relative 'StatsFrame'

>>>>>>> 20a1e34b6a787a5dfb8e72b161abc7258d0228ab
require_relative '../Frame'

##
# File          :: HomeFrame.rb
# Author        :: BROCHERIEUX Thibault
# Licence       :: MIT License
# Creation date :: 02/16/2018
# Last update   :: 02/16/2018
# Version       :: 0.1
#
# This class represents the HomeFrame which is the main menu after the login
class HomeFrame < Frame

	def initialize(user)
		super()
		self.border_width = 100

		# Retrieve user's language
		lang = user.settings.language
		# Retrieve associated language config file
		configFile = File.expand_path(File.dirname(__FILE__) + '/' + "../../../Config/lang_#{lang}")
		config = YAML.load(File.open(configFile))



		# Create 5 button
		@playBtn = Gtk::Button.new(:label => config["home"]["play"])
		@rankBtn = Gtk::Button.new(:label => config["home"]["rank"])
		@ruleBtn = Gtk::Button.new(:label => config["home"]["rule"])
		@optiBtn = Gtk::Button.new(:label => config["home"]["option"])
		@exitBtn = Gtk::Button.new(:label => config["button"]["exit"])

		# Create vertical box containing 5 boxes
		@vbox = Gtk::Box.new(:vertical, 5)
		@vbox.pack_start(@playBtn, :expand => true, :fill => true, :padding =>2)
		@vbox.pack_start(@rankBtn, :expand => true, :fill => true, :padding =>2)
		@vbox.pack_start(@ruleBtn, :expand => true, :fill => true, :padding =>2)
		@vbox.pack_start(@optiBtn, :expand => true, :fill => true, :padding =>2)
		@vbox.pack_start(@exitBtn, :expand => true, :fill => true, :padding =>2)

		@playBtn.signal_connect("clicked") do
<<<<<<< HEAD
			tmpMapPath = File.expand_path(File.dirname(__FILE__) + '/../../map.tmp/planet.map')
			self.parent.setFrame(ChapterFrame.new(user))
		end

		# Redirecting user towards option menu
		@optiBtn.signal_connect("clicked") do
			self.parent.setFrame(OptionFrame.new(user))
=======
			self.parent.setFrame(ChapterFrame.new(user))
		end

		# Redirecting user towards option menu
		@optiBtn.signal_connect("clicked") do
			self.parent.setFrame(OptionFrame.new(user))
		end

		# Redirecting user towards statistics menu
		@rankBtn.signal_connect("clicked") do
			self.parent.setFrame(StatsFrame.new(user))
>>>>>>> 20a1e34b6a787a5dfb8e72b161abc7258d0228ab
		end

		# Exit programms
		@exitBtn.signal_connect("clicked") do
<<<<<<< HEAD
				Gtk.main_quit
=======
			self.parent.application.action_quit_cb
>>>>>>> 20a1e34b6a787a5dfb8e72b161abc7258d0228ab
		end

		# Add vbox to frame
		add(@vbox)
	end
end