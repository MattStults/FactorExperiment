$.widget( "stults.decoration", {
	options: {
		element: null
		elementId: "board"
		svg: null
	}

	_setOption: (key, value) ->
		if key is 'element' then @isBuilt = false
		@._super( key, value)

	_setOptions: ( options ) ->
		@._super( options )
		@.refresh()

	_build: () ->

	refresh: ->
		if not @.options.svg?
			@.options.svg = @.element.svg('get')
		if not @isBuilt? or not @isBuilt
			@isBuilt = true;
			@._build()

	_create: () ->
		@.element.addClass("decoration")
		if not @.options.svg?
			@.element.svg()
		@.refresh()
	}
)

$.widget( "stults.gridHover", $.stults.decoration, {
	options: {
		lhs: null
		rhs: null
	}

	_build: () ->
		that = @
		@.options.element.hexGrid('addCallback', 'mouseenter', (event, tags) ->
			that.options.element.hexGrid("setClass", "x", tags.x, "hover")
			that.options.element.hexGrid("setClass", "y", tags.y, "hover")
			that.options.lhs.hexLine("setClass", "row", tags.x, "hover")
			that.options.rhs.hexLine("setClass", "row", tags.y, "hover")
			)
		@.options.element.hexGrid('addCallback', 'mouseleave', (event, tags) ->
			that.options.element.hexGrid("clearClass", "hover")
			that.options.lhs.hexLine("clearClass", "hover")
			that.options.rhs.hexLine("clearClass", "hover")
			)
		@.options.element.hexGrid('addCallback', 'click', (event, tags) ->
			x = that.options.lhs.hexLine("option", "value")
			xBit = 1 << tags.x
			y = that.options.rhs.hexLine("option", "value")
			yBit = 1 << tags.y
			if (x & xBit) is 0 or (y & yBit) is 0
				x |= xBit
				y |= yBit
			else
				x &= ~xBit
				y &= ~yBit
			that.options.lhs.hexLine("option", "value", x)
			that.options.rhs.hexLine("option", "value", y)
			)
	})

$.widget( "stults.decorationBox", $.stults.decoration,{
	options: {
		title: ""
		value: 0
		textOffset: [0, -20]
		lineOffset: [5,5]
	}

	_setOption: (key, value) ->
		if key is 'element' then @isBuilt = false
		@._super( key, value)

	_setOptions: ( options ) ->
		@._super( options )
		@.refresh()

	_build: () -> 
		base = @.options.element?.boxLine("getGroup")
		if not base? then return false
		if @rootGroup? then @.options.svg.remove(@rootGroup)
		bound = base.getBBox()
		@rootGroup = @.options.svg.group(base, @.options.elementId)
		$(@rootGroup).addClass("decoration")
		@text = util.drawTextAtPoint(@.options.svg, @rootGroup, [bound.x+bound.width/2+@.options.textOffset[0], bound.y+@.options.textOffset[1]], @.options.title + ": " + @.options.value)
		

	refresh: ->
		@._super('refresh')
		if @text? then @text.text( @.options.title + ": " + @.options.value)
	}
)