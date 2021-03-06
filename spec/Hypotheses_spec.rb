require 'spec_helper'

describe Grid do

	hypotheses = Hypotheses.new(10,10)

	defaultHypothesis      = Hypothesis.new(nil, 0)
	defaultGrid            = Grid.new(10, 10, defaultHypothesis)
	defaultHypothesis.grid = defaultGrid

	it "initialize hypotheses" do
		expect(hypotheses).to eq hypotheses
	end

	it "create a new hypothesis" do
		expect(hypotheses.addNewHypothesis).to eq 1
	end

	it "check that the cells hypothesis are still the old hypothesis" do
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).hypothesis.id).to eq defaultHypothesis.id
	end

	it "changes the state on the new hypothesis" do
		hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state = Cell::CELL_BLACK
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state).to eq Cell::CELL_BLACK
	end

	it "check that the cells hypothesis are now the new hypothesis" do
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).hypothesis.id).to eq hypotheses.getWorkingHypothesis.id
	end

	it "reject the last hypothesis" do
		expect(hypotheses.reject(1)).to eq hypotheses
	end

	it "reject unexistent hypothesis" do
		expect{hypotheses.reject(10)}.to raise_error(ArgumentError)
	end

	it "reject hypothesis 0 (impossible)" do
		expect{hypotheses.reject(0)}.to raise_error(ArgumentError)
	end

	it "accept unexistent hypothesis" do
		expect{hypotheses.validate(10)}.to raise_error(ArgumentError)
	end

	it "accept hypothesis 0 (validate all)" do
		expect(hypotheses.validate(0)).to eq hypotheses
	end

	it "should have rollbacked the state and the id" do
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state).to eq Cell::CELL_WHITE
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).hypothesis.id).to eq defaultHypothesis.id
	end

	it "check the id become correct when validating an hypothesis" do
		expect(hypotheses.addNewHypothesis).to eq 1
		hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state = Cell::CELL_BLACK
		hypotheses.validate(1)
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state).to eq Cell::CELL_BLACK
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).hypothesis.id).to eq defaultHypothesis.id
		hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state = Cell::CELL_WHITE
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state).to eq Cell::CELL_WHITE
	end

	it "check multiple new hypotheses and validating all" do

		hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state = Cell::CELL_BLACK
		expect(hypotheses.addNewHypothesis).to eq 1

		hypotheses.getWorkingHypothesis.grid.getCellPosition(1, 0).state = Cell::CELL_BLACK
		expect(hypotheses.addNewHypothesis).to eq 2

		hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state = Cell::CELL_WHITE
		expect(hypotheses.addNewHypothesis).to eq 3

		hypotheses.getWorkingHypothesis.grid.getCellPosition(1, 1).state = Cell::CELL_BLACK
		expect(hypotheses.addNewHypothesis).to eq 4

		hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state = Cell::CELL_BLACK
		hypotheses.validate(4)
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).state).to eq Cell::CELL_BLACK
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(1, 1).state).to eq Cell::CELL_BLACK
		expect(hypotheses.getWorkingHypothesis.grid.getCellPosition(0, 0).hypothesis.id).to eq defaultHypothesis.id
	end

	it "loop over all hypothesis" do
		hyps = []

		hypotheses.addNewHypothesis
		hyps.push(hypotheses.workingHypothesis)

		hypotheses.addNewHypothesis
		hyps.push(hypotheses.workingHypothesis)

		hypotheses.addNewHypothesis
		hyps.push(hypotheses.workingHypothesis)

		index = 0
		hypotheses.each do |hyp|
			expect(hyp).to eq hyps[index]
			index += 1
		end
	end

	# it "test marshal load/dump" do
	# 	temp = Marshal.dump(hypotheses)
	# 	temp2 = Marshal.load(temp)
	# 	expect(hypotheses).to eq temp2
	# end


end
