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
		statusTags: ["on", "off"]
	}

	_buildLine: (group, positions) ->
		[first, mid..., last] = positions
		@.options.svg.line(group, first.x, first.y, last.x, last.y)

	getChildren: () ->
		$("#"+@.options.elementId).children()

	_getGridPositions: (hexes, size) ->
		rows = []
		cols = []
		for i in [0...size]
			rows[i] = []
			cols[i] = []
		for i in [0...size]
			for j in [0...size]
				pos = util.getElemCenter(hexes.filter($(".x" + i)).filter($(".y"+j))[0])
				rows[i][j] = pos
				cols[j][i] = pos
		[rows, cols]

	_setupLines: (grid) ->
		hexes = @.options.element.hexGrid("getChildren")
		size = @.options.element.hexGrid("option", "size")
		[rows, cols] = @._getGridPositions(hexes, size)
		lineGroup = @.options.svg.group(null, @.options.elementId)

		lhs = @.options.lhs.hexLine("getChildren")
		rhs = @.options.rhs.hexLine("getChildren")
		for i in [0...size]
			cols[i] = [util.getElemCenter(rhs.filter($(".row" + i))[0])].concat cols[i]
			rows[i] = [util.getElemCenter(lhs.filter($(".row" + i))[0])].concat rows[i]

		$(@._buildLine(lineGroup, row)).addClass("x"+i) for row, i in rows
		$(@._buildLine(lineGroup, col)).addClass("y"+i) for col, i in cols

	_isTurnOn: (tags) ->
		x = @.options.lhs.hexLine("option", "value")
		y = @.options.rhs.hexLine("option", "value")
		xBit = 1 << tags.x
		yBit = 1 << tags.y
		[(x & xBit) is 0 or (y & yBit) is 0,
		x, xBit,
		y, yBit]

	_getStatusClass: (tags) ->
		if @._isTurnOn(tags)[0] then @.options.statusTags[0] else @.options.statusTags[1]

	_removeHover: (tags) ->
		toRemove = ["hover", "hoverX", "hoverY"].concat(@.options.statusTags)
		@.options.element.hexGrid("clearClass", toRemove...)
		@.options.lhs.hexLine("clearClass", toRemove...)
		@.options.rhs.hexLine("clearClass", toRemove...)
		@.getChildren().removeClass("hover")

	_addHover: (tags) ->
		status = @._getStatusClass(tags)
		@.options.element.hexGrid("setClass", "x", tags.x, "hoverX", status)
		@.options.element.hexGrid("setClass", "y", tags.y, "hoverY", status)
		@.options.lhs.hexLine("setClass", "row", tags.x, "hover", status)
		@.options.rhs.hexLine("setClass", "row", tags.y, "hover", status)
		lines = @.getChildren()
		lines.filter($(".x"+tags.x)).addClass("hover")
		lines.filter($(".y"+tags.y)).addClass("hover")

	_select: (tags) ->
		@._removeHover(tags)
		[isTurnOn, x, xBit, y, yBit] = @._isTurnOn(tags)
		if isTurnOn
			x |= xBit
			y |= yBit
		else
			x &= ~xBit
			y &= ~yBit
		@.options.lhs.hexLine("option", "value", x)
		@.options.rhs.hexLine("option", "value", y)
		
		@._addHover(tags)
		

	_build: () ->
		that = @
		@.options.element.hexGrid('addCallback', 'mouseenter', (event, tags) ->
			that._addHover(tags)
			)
		@.options.element.hexGrid('addCallback', 'mouseleave', (event, tags) ->
			that._removeHover(tags)
			)
		@.options.element.hexGrid('addCallback', 'click', (event, tags) ->
			that._select(tags)
			)
		@._setupLines()
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