## 
# This class represents a cell in a Picross  

class Cell

	##
	# Cell states : either CELL_EMPTY, CELL_CROSSED, or CELL_FULL
	CELL_EMPTY   = 0 # white
	CELL_FULL    = 1 # black
	CELL_CROSSED = 2 # cross 

	# List of all possible states in a ordered array
	@@listCells  = [CELL_EMPTY, CELL_FULL, CELL_CROSSED]

	# @state     - The state of the cell
	# @nextCells - The array of the nexts cells after rotation

	attr_reader :state

	##
	# Create a new cell
	# The default state is CELL_EMPTY 
	def initialize()
		@nextCells = Array.new(@@listCells)
		stateRotate()
	end

	##
	# Change the cell state to state
	# If state is not valid (CELL_EMPTY, CELL_CROSSED, CELL_FULL), raise an ArgumentError exception
	def state=(state)
		if state != CELL_EMPTY and state != CELL_CROSSED and state != CELL_FULL then
			raise ArgumentError, 'Argument state should be a valid state!'
		else
			@state = state
		end
	end

	##
	# Change the state to the next one (EMPTY -> FULL -> CROSSED -> EMPTY ...)
	def stateRotate()
		self.state = @nextCells.first
		@nextCells.rotate!	
	end

	##
	# Return the cell to a printable String
	def to_s()
		case @state
			when CELL_EMPTY
				return "░"
			when CELL_CROSSED
				return "X"
			when CELL_FULL
				return "█"
		end
		raise "Wrong cell state"
	end
	
end
