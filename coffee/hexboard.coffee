$.widget( "stults.hexboard", {
	options: {
		size: 5
		lhs: 0
		rhs: 0
		x: 150
		y: 150
		width: 300
		height: 300
		hwRatio: 1.15
		boardId: "board"
		svg: null
	}

	_setOption: (key, value) ->
		if key is 'size' then value = @._constrainSize( value )
		if key is 'lhs' or key is 'rhs' then value = @._constrainFactor( value )
		if key is 'hwRatio' then value = @._constrainRatio( value )
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

	_constrainRatio: (ratio) ->
		@isBuilt = false
		if ratio < 0.1 then return 0.1
		if ratio > 10 then return 10
		return ratio

	_getBoardBySide: (value, id) ->
		select = []
		deselect = []
		for i in [0...@.options.size]
			tag = id + i
			if ((1<<i) & value) == 0
				deselect.push tag
			else
				select.push tag
		[select, deselect]

	_updateBoard: (lhs, rhs) ->
		[xSelect, xDeselect] = @._getBoardBySide(lhs, ".x")
		[ySelect, yDeselect] = @._getBoardBySide(rhs, ".y")
		$("."+@.options.boardId).filter($(xSelect.join(","))).filter($(ySelect.join(","))).addClass("select")
		$((xDeselect.concat(yDeselect)).join(",")).removeClass("select")

	refresh: ->
		if not @.options.svg?
			@.options.svg = @.element.svg('get')
		
		if not @isBuilt? or not @isBuilt
			@.options.svg.clear()
			@hexBuilder = new HexBuilder(50, @.options.hwRatio, [150,100])
			@hexBuilder.buildGrid(@.options.boardId, @.options.svg, [0,0], [@.options.size, @.options.size])
			@isBuilt = true

		value = (@.options.lhs * @.options.rhs)
		if value isnt @lastValue
			@lastValue = value
			@._updateBoard(@.options.lhs, @.options.rhs)
			@._trigger( "update", null, {value: value})

	_create: () ->
		@.element.addClass("hexboard")
		@.element.svg()
		@.refresh()
	}
)

class HexBuilder
	constructor: (@height, @hwRatio, @origin) ->
		@width = height / hwRatio
		@sideLength = HexBuilder._buildSideLength(@height/2, @width/2)
		@hexLine = HexBuilder._buildHexLine(@height, @width, @sideLength)
		@yOffset = height-(height - @sideLength)/2

	@_gridPlot: (pos, origin, width, yOffset) ->
		[ origin[0] + (pos[0]-pos[1])*0.5*width, origin[1] + (pos[0]+pos[1])*yOffset ]

	buildGrid: (id, svg, start, dimensions) ->
		gridGroup = svg.group()
		grid = []
		for x in [start[0]...dimensions[0]+start[0]]
			grid[x] = []
			for y in [start[1]...dimensions[1]+start[1]]
				posX = 0
				posY = 0
				[posX, posY] = HexBuilder._gridPlot([x,y], @origin, @width, @yOffset)
				grid[x][y] = svg.polygon(gridGroup, @hexLine, {transform: "translate("+posX+","+posY+")"})
				$(grid[x][y]).addClass(id).addClass("x"+x).addClass("y"+y).addClass("row"+(x+y))
		gridGroup

	@_buildSideLength: (halfHeight, halfWidth) ->
		#first, find the y position of the side using the quadratic formula.
		#this should create a hex with equal sides
		#.75s^2 + hs - h^2 - w^2
		#a = 0.75, b = h, c = -(h^2+w^2)
		a = 0.75
		b = halfHeight
		c = -(Math.pow(halfHeight,2) + Math.pow(halfWidth, 2))
		
		root1 = 0
		root2 = 0
		[root1, root2] = HexBuilder._solveQuadratic(a,b,c)
		sideLength = 0
		if not root1.isNaN and root1 > 0
			sideLength = root1
		else if not root2.isNaN and root2 > 0
			sideLength = root2
		else 
			sideLength = (Math.sin(Math.PI/6)*halfWidth).toFixed(2)*2
		sideLength


	@_buildHexLine: (height, width, sideLength)->
		halfHeight = height/2
		halfWidth = width/2
		sidePosY = sideLength/2
		#rotate clockwise around the hex
		[[0, halfHeight], 		#top
		[halfWidth, sidePosY],
		[halfWidth, -sidePosY],
		[0, -halfHeight], 		#bottom
		[-halfWidth, -sidePosY],
		[-halfWidth, sidePosY]] #end

	@_solveQuadratic: (a,b,c) ->
		base = Math.pow(Math.pow(b,2)-4*a*c,0.5)/2/a
		root1=-b/2/a+base
		root2=-b/2/a-base
		[root1, root2]


