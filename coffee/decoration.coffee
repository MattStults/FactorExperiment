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
			@._build()

	_create: () ->
		@.element.addClass("decoration")
		if not @.options.svg?
			@.element.svg()
		@.refresh()
	}
)

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