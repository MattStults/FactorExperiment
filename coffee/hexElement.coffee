$.widget( "stults.hexElement", {
	options: {
		size: 5
		hexBuilder: new HexBuilder(50, 1.15, [150,100])
		boardId: "board"
		svg: null
	}

	_setOption: (key, value) ->
		if key is 'size' then value = @._constrainSize( value )
		if key is 'lhs' or key is 'rhs' then value = @._constrainFactor( value )
		if key is 'hexBuilder' then @isBuilt = false
		@._super( key, value)

	_setOptions: ( options ) ->
		@._super( options )
		@.refresh()

	_constrainSize: (size) ->
		if size < 1 then return 1
		size

	_constrainFactor: (factor) ->
		if factor < 0 then return 0
		max = ((1 << @.options.size)-1)
		if factor > max then return max
		return factor

	_getSelectedTagsById: (value, id) ->
		select = []
		deselect = []
		for i in [0...@.options.size]
			tag = id + i
			if ((1<<i) & value) == 0
				deselect.push tag
			else
				select.push tag
		[select, deselect]

	refresh: ->
		if not @.options.svg?
			@.options.svg = @.element.svg('get')

	_create: () ->
		@.element.addClass("hexElement")
		@.element.svg()
		@.refresh()
	}
)

$.widget( "stults.hexGrid", $.stults.hexElement, {
	options: {
		lhs: 0
		rhs: 0
	}

	_updateBoard: (lhs, rhs) ->
		[xSelect, xDeselect] = @._getSelectedTagsById(lhs, ".x")
		[ySelect, yDeselect] = @._getSelectedTagsById(rhs, ".y")
		$("."+@.options.boardId).filter($(xSelect.join(","))).filter($(ySelect.join(","))).addClass("select")
		$((xDeselect.concat(yDeselect)).join(",")).removeClass("select")

	refresh: ->
		if not @.options.svg?
			@.options.svg = @.element.svg('get')
		
		if (not @isBuilt? or not @isBuilt) and @.options.hexBuilder?
			@.options.svg.clear()
			@.options.hexBuilder.buildGrid(@.options.boardId, @.options.svg, [0,0], [@.options.size, @.options.size])
			@isBuilt = true

		value = (@.options.lhs * @.options.rhs)
		if value isnt @lastValue
			@lastValue = value
			@._updateBoard(@.options.lhs, @.options.rhs)
			@._trigger( "update", null, {value: value})
	}
)




