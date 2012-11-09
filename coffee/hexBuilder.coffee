root = exports ? this

class root.HexBuilder
	constructor: (@height, @hwRatio, @origin) ->
		@width = height / hwRatio
		@sideLength = HexBuilder._buildSideLength(@height/2, @width/2)
		@hexLine = HexBuilder._buildHexLine(@height, @width, @sideLength)
		@squareLine = HexBuilder._buildSquareLine(@sideLength)
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
				$(grid[x][y]).attr('id', id+((x-start[0])+dimensions[0]*(y-start[1]))).addClass(id).addClass("x"+(x-start[0])).addClass("y"+(y-start[1])).addClass("row"+(x+y-(start[0]+start[1])))
		gridGroup

	buildBoxes: (id, svg, range, xPos) ->
		group = svg.group()
		for y in [range[0]...range[1]]
			[ignore, posY] = HexBuilder._gridPlot([0,y], @origin, @width, @yOffset)
			box = svg.polygon(group, @squareLine, {transform: "translate("+xPos+","+posY+")"})
			$(box).attr('id', id+y).addClass(id).addClass("row"+y)
		group

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

	@_buildSquareLine: (sideLength) ->
		half = sideLength/2.0
		[[half, half],
		[half, -half],
		[-half, -half],
		[-half, half]]

	@_buildHexLine: (height, width, sideLength)->
		halfHeight = height/2.0
		halfWidth = width/2.0
		sidePosY = sideLength/2.0
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