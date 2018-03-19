require_relative 'Timer'

##
# File		:: Statistics.rb
# Author	:: COHEN Mehdi
# Licence	:: MIT Licence
# Creation date	:: 01/27/2018
# Last update	:: 01/30/2018
#
# This class represents the player's statistics linked to a map
#
class Statistic

	# +stats+	- player's statistics on a map

	attr_reader :time, :usedHelp, :numberOfStars, :nbClick

	attr_accessor :isFinished

	##
	# Create a new Statistics object
	# * *Arguments* :
	#   - +stats+		-> player's statistics
	def initialize()
		@time = Timer.new()
		self.reset()
	end

	##
	# Set statistic's status to finished
	# and calculate numbers of stars awarded
	def finish(timeToDo)
		# Time ratio / Stars
		#  1    -   - 3
		#  1.25 -   - 2.5
		#  1.5  -   - 2
		#  1.75 -   - 1.5
		#  2    -   - 1
		#  2.25 -   - 0.5
		#  2.5  -  - 0
		@time.pause
		@isFinished = true
		timeToDo = 600 if timeToDo == nil or timeToDo == 0
		ratio = @time.elapsedSeconds * 1.0 / timeToDo
		ratio = (ratio * 4).round / 4
		#return the number of sta##
	# Returns the total number of elapsed seconds since the timer began.
	# It count the time of each run of the timer (pauses).
	# * *Returns* :
	#   - the elapsed seconds (Integer)rs depending on the ratio above
		@numberOfStars = -2*ratio + 5
		if(@numberOfStars > 3) then
			@numberOfStars = 3
		elsif @numberOfStars < 0
			@numberOfStars = 0
		end
	end

	def start()
		@time.start
	end

	##
	# Increments the number of help used
	def useHelp()
		@usedHelp += 1
	end

	##
	# Increments the number of click
	def click()
		@nbClick += 1
	end

	##
	# Reset Statistic
	def reset()
		@time.reset
		@usedHelp = 0
		@numberOfStars = 0
		@isFinished = false
		@nbClick = 0
	end

	##
	# Retuns the statistic to a string, for debug only
	# * *Returns* :
	#   - the statistic into a String object
	def to_s()
		res  = "Printing Statistic -#{self.object_id}-\n\t"
		res += " - Time       : #{@time}\n\t"
		res += " - isFinished : #{@isFinished}\n\t"
		res += " - Used help  : #{@usedHelp}\n\t"
		res += " - Nb Stars   : #{@numberOfStars}\n\t"
		res += " - NbClick    : #{@nbClick}\n\t"
		return res
	end


	##
	# Convert the statistic to an array, allowing Marshal to dump the object.
	# * *Returns* :
	#   - the statistic converted to an array
	def marshal_dump()
		return [@time, @usedHelp, @numberOfStars, @isFinished, @nbClick]
	end

	##
	# Update all the instances variables from the array given,
	# allowing Marshal to load a statistic object.
	# * *Arguments* :
	#   - +array+ -> the array to transform to instances variables
	# * *Returns* :
	#   - the statistic object itself
	def marshal_load(array)
		@time, @usedHelp, @numberOfStars, @isFinished, @nbClick = array
		return self
	end

end
