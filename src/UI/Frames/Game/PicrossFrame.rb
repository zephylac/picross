require_relative '../../../Cell'

require_relative 'Drag'
require_relative 'CellButton'
require_relative 'SolutionNumber'

require_relative 'KeyboardDrag'

##
# File          :: PicrossFrame.rb
# Author        :: PELLOIN Valentin, BROCHERIEUX Thibault
# Licence       :: MIT License
# Creation date :: 02/23/2018
# Last update   :: 02/24/2018
# Version       :: 0.1
#
# This class represents a Frame for the Picross view.
# Inside this frame, there are multiple CellButton that can be clicked (or dragged using the Drag class) to resolve the game.

class PicrossFrame < Frame

	# The grid this frame is working on
	attr_reader :grid
	attr_reader :cells
	attr_reader :user
	attr_reader :drag

	attr_accessor :keyboard


	##
	# Creation of a new PicrossFrame.
	# * *Arguments* :
	#   - +map+  -> the map to be displayed
	#   - +grid+ -> the Grid of the PicrossFrame view
	#   - +user+ -> the user playing on this frame
	def initialize(map, grid, user, frame)
		super()
		self.border_width = 10

		@map  = map
		@grid = grid
		@user = user

		@colorsHyp = user.settings.hypothesesColors
		@frame = frame

		self.createArea

		self.signal_connect('size-allocate') do |widget, event|
			self.setMaxSize(event.width, event.height)
		end
		self.signal_connect('realize') do
			@keyboard = KeyboardDrag.new(self)
		end
		self.setMaxSize(500, 500)
		self.forceResize
	end

	##
	# Ask the frame to force to resize to it's normal size.
	# * *Returns* :
	#   - the object itself
	def forceResize
		@oWidth  = nil
		@oHeight = nil

		# we force to allocate the size as soon as possible
		# otherwise, it's only updated when the user passes it's
		# cursror on the widget, so it's very disturbing... GTK <3
		GLib::Timeout.add(10){
			if self.allocation.width > 10 && self.allocation.height > 10 then
#self.queue_allocate
					self.queue_resize
				false
			else
				true
			end
		}
		return self
	end

	##
	# Updates the maximum size allowed to the frame by changing the size
	# of each cells inside the frame.
	# * *Arguments* :
	#   - +width+  -> the allowed width for the frame
	#   - +height+ -> the allowed height for the frame
	# *Returns* :
	#   - the object itself
	def setMaxSize(width, height)
		if @oWidth != width || @oHeight != height then
			cellX = (width  - 10) / (@grid.columns + @lineOffset)
			cellY = (height - 10) / (@grid.lines + @columnOffset)
			cellSize = [cellX, cellY].min + 1

			CellButton.resize(cellSize, cellSize)

			@cells.each do |cell|
				if cell.kind_of?(CellButton) then
					cell.resize
				end
			end

			@oHeight = height
			@oWidth  = width
		else
		end
		return self
	end

	##
	# Changes the grid to display on the PicrossFrame view.
	# This takes care of everything, it update the Drag, and the cells inside the frame.
	# * *Arguments* :
	#   - +newGrid+ -> the new Grid to display
	# * *Returns* :
	#   - the PicrossFrame itself
	def grid=(newGrid)
		@grid = newGrid
		@drag.grid = @grid

		self.redrawIntern

		@grid.each_cell_with_index do |cell, line, column|
			@cells.get_child_at(@lineOffset + column, @columnOffset + line).cell = cell
		end
		return self
	end

	##
	# Redraw and/or create all the frame for the current picross. This can be
	# used when changing the grid inside the map (for evolving maps for example).
	# * *Returns* :
	#   - the object itself
	def redrawIntern
		@lineSolution   = @map.lneSolution
		@columnSolution = @map.clmSolution

		@cells.children.each { |child| @cells.remove(child) }
		self.computeOffsets

		# adds the numbers to the cells
		createNumbers(@cells, @columnSolution, @lineOffset, @columnOffset, false)
		createNumbers(@cells, @lineSolution,   @lineOffset, @columnOffset, true)

		# creation of all the cells buttons
		@grid.each_cell_with_index do |cell, line, column|
			@cells.attach(
				CellButton.new(cell, @drag, @colorsHyp, self),
				column + @lineOffset, line + @columnOffset,
				1, 1)
		end
		
		self.show_all
		if @map.learning? then
			@frame.setLearningTextWidth(@oWidth)
		end
		self.forceResize
		return self
	end

	##
	# Redraw and/or create all the frame for the current picross. This can be
	# used when changing the grid inside the map (for evolving maps for example).
	# * *Returns* :
	#   - the object itself
	def redraw
		self.redrawIntern
		@drag.reset

		return self
	end

	##
	# Create the PicrossFrame area, with all the CellButton inside
	# * *Returns* :
	#   - the PicrossFrame itself
	def createArea()
		@cells = Gtk::Grid.new
		@drag  = Drag.new(@map, @cells, @frame)
		@cells.visible = true

		self.redraw

		@mainArea = Gtk::EventBox.new()
		@mainArea.events |= (Gdk::EventMask::ENTER_NOTIFY_MASK)
		@mainArea.add(@cells)


		self.add(@mainArea)
		return self
	end

	##
	# Compute the offsets caused by the line and column solution
	# numbers, and update the drag to theses offsets.
	# * *Returns* :
	#   - +the object itself
	def computeOffsets
		@columnOffset = @columnSolution.map(&:length).max
		@lineOffset   = @lineSolution.map(&:length).max
		@drag.setOffsets(@columnOffset, @lineOffset)
		return self
	end

	##
	# Adds all the solution numbers to the grid cells.
	# If +isHorizontal+ equals true, then it adds all the left numbers,
	# otherwise, the top numbers.
	# * *Arguments* :
	#   - +cells+        -> the Gtk::Grid to add the numbers to
	#   - +solution+     -> the array of array of numbers containing the solution
	#   - +lineOffset+   -> the top offset
	#   - +columnOffset+ -> the left offset
	# * *Returns* :
	#   - the PicrossFrame itself
	def createNumbers(cells, solution, lineOffset, columnOffset, isHorizontal)

		isHorizontal ? offset = lineOffset : offset = columnOffset
		i = 0
		solution.each do |n|
			j = 0
			n = n.reverse.fill(n.size..offset - 1){ nil }
			n.reverse.each do |m|
				addNumber(m, isHorizontal, lineOffset, columnOffset, i, j, cells)
				j+= 1
			end
			i+= 1
		end

		return self
	end

	##
	# Create a new SolutionNumber and adds it to the grid
	# * *Arguments* :
	#   - +value+        -> the value of the SolutionNumber
	#   - +isHorizontal+ -> are we doing the horizontal solution, or the vertical solution?
	#   - +lineOffset+   -> the top offset
	#   - +columnOffset+ -> the left offset
	#   - +i+            -> the index of the array in the solution
	#   - +j+            -> the index of the number inside the array
	# * *Returns* :
	#   - the PicrossFrame itself
	def addNumber(value, isHorizontal, lineOffset, columnOffset, i, j, cells)
		number = SolutionNumber.new(value)
		if isHorizontal then
			cells.attach(number,j,i+columnOffset,1,1)
		else
			cells.attach(number,i+lineOffset,j,1,1)
		end
		return self
	end

	##
	# Get an array of SolutionNumber corresponding to the given column number
	# * *Arguments* :
	#   - +column+ -> the column number to search the solutions numbers
	# * *Returns* :
	#   - the array of SolutionNumber matching the column number
	def getColumnNumbers(column)
		column = @lineOffset + column
		return getAllChildsNumbers(column, 0, 0, 1)
	end

	##
	# Get an array of SolutionNumber corresponding to the given line number
	# * *Arguments* :
	#   - +line+ -> the line number to search the solutions numbers
	# * *Returns* :
	#   - the array of SolutionNumber matching the line number
	def getLineNumbers(line)
		line = @columnOffset + line
		return getAllChildsNumbers(0, line, 1, 0)
	end

	##
	# Get an array of SolutionNumber corresponding to the given position
	# * *Arguments* :
	#   - +x+  -> the starting X position
	#   - +x+  -> the starting Y position
	#   - +xI+ -> the X increment at each step
	#   - +xY+ -> the Y increment at each step
	# * *Returns* :
	#   - the array of SolutionNumber matching the numbers
	def getAllChildsNumbers(x, y, xI, yI)
		result = []
		loop do
			cell = @cells.get_child_at(x, y)
			break if not cell.kind_of?(SolutionNumber)

			result.push(cell)
			x += xI
			y += yI
		end
		return result
	end

	##
	# Sets an hover for the given coordinates.
	# * *Arguments* :
	#   - +posX+ -> the cell X position
	#   - +posY+ -> the cell Y position
	#   - +meth+ -> the method to call either setHover or unsetHover
	# * *Returns* :
	#   - the object itself
	def hover(posX, posY, meth)
		cells = getColumnNumbers(posX) + getLineNumbers(posY)
		cells.each do |number|
			if number.kind_of?(SolutionNumber) && number.value != nil then
				number.send(meth)
			end
		end
		return self
	end

	##
	# Sets an hover for the given coordinates.
	# * *Arguments* :
	#   - +posX+ -> the cell X position
	#   - +posY+ -> the cell Y position
	# * *Returns* :
	#   - the object itself
	def setHover(posX, posY)
		hover(posX,posY,:setHover)
	end

	##
	# Unsets the hover for the given coordinates.
	# * *Arguments* :
	#   - +posX+ -> the cell X position
	#   - +posY+ -> the cell Y position
	# * *Returns* :
	#   - the object itself
	def unsetHover(posX, posY)
		hover(posX,posY,:unsetHover)
	end

	##
	# Update all the SolutionNumber in the grid to show whether or not
	# they are completed (done) by the user.
	# * *Returns* :
	#   - the object itself
	def setDoneValues
		setDoneValuesGeneric(@map.alreadyDoneLineSolution,   :getLineNumbers)
		setDoneValuesGeneric(@map.alreadyDoneColumnSolution, :getColumnNumbers)
		return self
	end

	##
	# Update the done property of the SolutionNumber that can be
	# obtained via the method +getNumsMethod+
	# according to the +already+ array of array.
	# * *Arguments* :
	#   - +already+       -> the already done solution number
	#   - +getNumsMethod+ -> a method to obtain numbers (:getLineNumbers or :getColumnNumbers)
	# * *Returns*
	#   - the object itself
	def setDoneValuesGeneric(already, getNumsMethod)
		already.each_index do |i|
			line = already[i]
			nums = self.send(getNumsMethod, i)
			done_i = 0

			nums.each_index do |number_i|
				number = nums[number_i]
				number.unsetDone

				if number.value != nil then
					break if number.value != line[done_i]
					number.setDone
					done_i += 1
				end
			end
		end
		return self
	end

	def childAt(line, column)
		return @cells.get_child_at(@lineOffset + column, @columnOffset + line)
	end

	def click(line, column, button)
		self.childAt(line, column).buttonPress(button)
	end

	def unclick(line, column)
		self.childAt(line, column).buttonUnpress()
	end

	def enterNotify(line, column)
		self.childAt(line, column).enterNotify()
	end

	def leaveNotify(line, column)
		self.childAt(line, column).leaveNotify()
	end

end
