$.widget( "stults.hexElement", {
	options: {
		size: 5
		hexBuilder: new HexBuilder(50, 1.15, [150,100])
		elementId: "board"
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

	_constrainFactor: (factor) ->
		if factor < 0 then return 0
		max = ((1 << @.options.size)-1)
		if factor > max then return max
		return factor

	setClass: (axis, value, cssClass) ->
		selection = $("#"+@.options.elementId).children().filter($("."+axis+value))
		selection.addClass(cssClass)

	clearClass: (cssClass) ->
		$("#"+@.options.elementId).children().removeClass(cssClass)

	addCallback: (eventId, callback) ->
		$("#"+@.options.elementId).children().on(eventId, (event)->
			classes = ($(@).attr('class')).split(' ')
			identity = classes.reduce (x, y) ->
				parts = /(\D+)(\d+)/.exec y
				if parts? and parts.length > 2 then x[parts[1]] = parts[2]
				x
			, {}

			callback(event, identity))

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
		if not @.options.svg?
			@.element.svg()
		@.refresh()
	}
)

$.widget( "stults.hexGrid", $.stults.hexElement, {
	options: {
		lhs: 0
		rhs: 0
	}

	_setOption: (key, value) ->
		if key is 'lhs' or key is 'rhs' then value = $.stults.hexElement.prototype._constrainFactor( value )
		@._super( key, value)

	_updateBoard: (lhs, rhs) ->
		[xSelect, xDeselect] = @._getSelectedTagsById(lhs, ".x")
		[ySelect, yDeselect] = @._getSelectedTagsById(rhs, ".y")
		$("#"+@.options.elementId).children().filter($(xSelect.join(","))).filter($(ySelect.join(","))).addClass("select")
		$("#"+@.options.elementId).children().filter($(xDeselect.concat(yDeselect).join(","))).removeClass("select")

	refresh: ->
		@._super('refresh')
		
		if (not @isBuilt? or not @isBuilt) and @.options.hexBuilder?
			$("#"+@.options.elementId).remove()
			@.options.hexBuilder.buildGrid(@.options.elementId, @.options.svg, [0,0], [@.options.size, @.options.size])
			@isBuilt = true

		value = (@.options.lhs * @.options.rhs)
		if value isnt @lastValue
			@lastValue = value
			@._updateBoard(@.options.lhs, @.options.rhs)
			@._trigger( "update", null, {value: value})
	}
)

$.widget( "stults.hexLine", $.stults.hexElement, {
	options: {
		value: 0
		axis: 'x'
	}

	_setOption: (key, value) ->
		if key is 'value' then value = $.stults.hexElement.prototype._constrainFactor( value )
		@._super( key, value)

	_updateBoard: (value) ->
		[select, deselect] = @._getSelectedTagsById(value, "."+@.options.axis)
		$("#"+@.options.elementId).children().filter($(select.join(","))).addClass("select")
		$("#"+@.options.elementId).children().filter($(deselect.join(","))).removeClass("select")

	_setupClickResponse: () ->
		that = @
		@.addCallback('click', (event, tags) ->
			that.options.value = that.options.value ^ (1 << tags.row)
			that.refresh()
			)

	refresh: ->
		@._super('refresh')
		
		if (not @isBuilt? or not @isBuilt) and @.options.hexBuilder?
			$("#"+@.options.elementId).remove()
			[origin, dimensions] = if @.options.axis is 'x' then [[0, -1],[@.options.size, 1]] else [[-1, 0],[1, @.options.size]]
			@.options.hexBuilder.buildGrid(@.options.elementId, @.options.svg, origin, dimensions)
			@._setupClickResponse()
			@isBuilt = true

		if @.options.value isnt @lastValue
			@lastValue = @.options.value
			@._updateBoard(@.options.value)
			@._trigger( "update", null, {value: @.options.value})

	_create: () ->
		@._super()
	}
)

$.widget( "stults.boxLine", $.stults.hexElement, {
	options: {
		value: 0
		xPos: 300
	}

	_updateBoard: (value) ->
		[select, deselect] = @._getSelectedTagsById(value, ".row")
		$("#"+@.options.elementId).children().filter($(select.join(","))).addClass("select")
		$("#"+@.options.elementId).children().filter($(deselect.join(","))).removeClass("select")

	getGroup: -> 
		@rootGroup

	refresh: ->
		@._super('refresh')
		
		if (not @isBuilt? or not @isBuilt) and @.options.hexBuilder?
			$("#"+@.options.elementId).remove()
			@rootGroup = @.options.hexBuilder.buildBoxes(@.options.elementId, @.options.svg, [0,@.options.size], @.options.xPos)
			@isBuilt = true

		if @.options.value isnt @lastValue
			@lastValue = @.options.value
			@._updateBoard(@.options.value)
			@._trigger( "update", null, {value: @.options.value})

	_create: () ->
		@._super()
	}
)


