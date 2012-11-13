$.widget( "stults.primeGame", {
	options: {
		size: 5
		hexBuilder: new HexBuilder(50, 1.15, [150,100])
		elementId: "primeGame"
		goalValue: 77
		svg: null
	}

	_setOption: (key, value) ->
		if key is 'size' then value = @._constrainSize( value )
		if key is 'hexBuilder' then @isBuilt = false
		@._super( key, value)

	_setOptions: ( options ) ->
		@._super( options )
		@.refresh()

	_constrainSize: (size) ->
		if size < 1 then return 1
		size

	refresh: ->
		if not @.options.svg?
			@.options.svg = @.element.svg('get')

		if @goal? and @.options.goalValue isnt @goal.boxLine("option", "value")
			@goal.boxLine("option", "value", @.options.goalValue)

	_create: () ->
		@.element.addClass("primeGame")
		if not @.options.svg?
			@.element.svg()

		that = @

		@goal = $("<div></div>").appendTo(@.element).boxLine({
			elementId: @.options.elementId + "Goal"
			svg: @.options.svg
			#position is just hacked in for now.
			xPos: 375
			size: @.options.size*2
			value: @.options.goalValue
			hexBuilder: @.options.hexBuilder
		})
		@result = $("<div></div>").appendTo(@.element).boxLine({
			elementId: @.options.elementId + "Result"
			svg: @.options.svg
			#position is just hacked in for now.
			xPos: 325
			size: @.options.size*2
			value: 0
			hexBuilder: @.options.hexBuilder
		})
		@grid = $("<div></div>").appendTo(@.element).hexGrid({
			elementId: @.options.elementId + "Board"
			svg: @.options.svg
			hexBuilder: @.options.hexBuilder
			update: (event, data) ->
				that.result.boxLine("option", "value", data.value)
		})
		@rhs = $("<div></div>").appendTo(@.element).hexLine({
			elementId: @.options.elementId + "Rhs"
			svg: @.options.svg
			hexBuilder: @.options.hexBuilder
			axis: 'y'
			update: (event, data) ->
				that.grid.hexGrid("option", "rhs", data.value)
		})
		@lhs = $("<div></div>").appendTo(@.element).hexLine({
			elementId: @.options.elementId + "Lhs",
			svg: @.options.svg,
			hexBuilder: @.options.hexBuilder,
			axis: 'x',
			update: (event, data) ->
				that.grid.hexGrid("option", "lhs", data.value);
		})
		@.refresh()
	}
)