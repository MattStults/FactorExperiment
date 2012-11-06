root = exports ? this

class root.HexBuilder
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