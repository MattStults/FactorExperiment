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
		[first, second, mid..., last] = positions
		offset = {
			x: (second.x - first.x)/2
			y: (second.y - first.y)/2
		}
		@.options.svg.line(group, first.x+offset.x, first.y+offset.y, last.x+offset.x, last.y+offset.y)

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

	_removeHover: () ->
		toRemove = ["hover", "hoverX", "hoverY", "display"].concat(@.options.statusTags)
		$("#"+@.options.element.hexGrid("option", "elementId")).children().removeClass(toRemove.join(" "))
		$("#"+@.options.lhs.hexLine("option", "elementId")).children().removeClass(toRemove.join(" "))
		$("#"+@.options.rhs.hexLine("option", "elementId")).children().removeClass(toRemove.join(" "))
		$("#"+@.options.elementId).children().removeClass(toRemove.join(" "))

	_updateHover: (elementId, selects, classIds) ->
		pool = $("#"+elementId)
		sSelector = pool.find(if selects.length > 0 then $("."+selects.join(",.")) else "")
		classesToAdd = classIds.join(" ")

		pool.children().not(sSelector).removeClass(classesToAdd)
		sSelector.addClass(classesToAdd)

	_addHover: (tags) ->
		status = @._getStatusClass(tags)
		gridId = @.options.element.hexGrid("option", "elementId")
		@._updateHover(gridId, ["x"+tags.x], ["hoverX"]).addClass(status)
		@._updateHover(gridId, ["y"+tags.y], ["hoverY"]).addClass(status)
		@._updateHover(@.options.lhs.hexLine("option", "elementId"), ["row"+tags.x], ["hover", status])
		@._updateHover(@.options.rhs.hexLine("option", "elementId"), ["row"+tags.y], ["hover", status])
		@._updateHover(@.options.elementId, ["x"+tags.x, "y"+tags.y], ["hover"])
		[selectedXLines, ignore] = @.options.lhs.hexLine("getSelected", "x")
		[selectedYLines, ignore] = @.options.rhs.hexLine("getSelected", "y")
		selectedLines = selectedXLines.concat(selectedYLines)
		@._updateHover(@.options.elementId, selectedLines, ["display"])

	_select: (tags) ->
		@._removeHover()
		if tags.x >= 0 and tags.y >= 0
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

	_addClassCallback: (selector, eventId, callback) ->
		selector.on(eventId, (event)->
			classes = ($(@).attr('class')).split(' ')
			identity = classes.reduce (x, y) ->
				parts = /(\D+)(\d+)/.exec y
				if parts? and parts.length > 2 then x[parts[1]] = parts[2]
				x
			, {}

			callback(event, identity))
		

	_build: () ->
		that = @
		lhs = $("#"+@.options.lhs.hexLine("option", "elementId")).children()
		@._addClassCallback(lhs, 'mouseenter', (event, tags) ->
			tags.x = tags.row
			tags.y = -1
			that._addHover(tags)
			)
		@._addClassCallback( lhs, 'click', (event, tags) ->
			tags.x = tags.row
			tags.y = -1
			that._select(tags)
			)
		rhs = $("#"+@.options.rhs.hexLine("option", "elementId")).children()
		@._addClassCallback(rhs, 'mouseenter', (event, tags) ->
			tags.y = tags.row
			tags.x = -1
			that._addHover(tags)
			)
		@._addClassCallback( rhs, 'click', (event, tags) ->
			tags.y = tags.row
			tags.x = -1
			that._select(tags)
			)
		grid =$("#"+@.options.element.hexGrid("option", "elementId")).children()
		@._addClassCallback( grid, 'mouseenter', (event, tags) ->
			that._addHover(tags)
			)
		@._addClassCallback( grid, 'click', (event, tags) ->
			that._select(tags)
			)
		$("#game").on('mouseleave', (event) ->
			that._removeHover()
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