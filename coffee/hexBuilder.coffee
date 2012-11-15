root = exports ? this

class root.HexBuilder
	constructor: (@height, @hwRatio, @origin) ->
		@width = height / hwRatio
		@sideLength = HexBuilder._buildSideLength(@height/2, @width/2)
		@yOffset = height-(height - @sideLength)/2

	setupDefs: (svg) ->
		if not @isInitialized? or not @isInitialized
			@isInitialized = true
			defs = svg.defs("hexDefs")
			hex = svg.polygon(defs, HexBuilder._buildHexLine(@height, @width, @sideLength))
			$(hex).attr('id', "hexagon")
			square = svg.polygon(defs, HexBuilder._buildSquareLine(@sideLength))
			$(square).attr('id', "resultBox")

	@_gridPlot: (pos, origin, width, yOffset) ->
		[ origin[0] + (pos[0]-pos[1])*0.5*width, origin[1] + (pos[0]+pos[1])*yOffset ].map (coord) -> Math.round(coord*100)/100

	buildLine: (id, svg, start, stop) ->
		[startX, startY] = HexBuilder._gridPlot(start, @origin, @width, @yOffset)
		[stopX, stopY] = HexBuilder._gridPlot(stop, @origin, @width, @yOffset)
		svg.line(null, startX, startY, stopX, stopY);

	buildGrid: (id, svg, start, dimensions) ->
		gridGroup = svg.group(null, id)
		for x in [start[0]...dimensions[0]+start[0]]
			for y in [start[1]...dimensions[1]+start[1]]
				hexGroup = svg.group(gridGroup, id+((x-start[0])+dimensions[0]*(y-start[1])))
				[posX, posY] = HexBuilder._gridPlot([x,y], @origin, @width, @yOffset)
				row = (x+y-(start[0]+start[1]))
				$(hexGroup).addClass("x"+(x-start[0])).addClass("y"+(y-start[1])).addClass("row"+row)

				#hex
				hex = svg.use(hexGroup, posX, posY, null, null, "#hexagon")
				util.drawTextAtPoint(svg, hexGroup, [posX, posY], ""+(1<<row))
				
		gridGroup

	buildBoxes: (id, svg, range, xPos) ->
		group = svg.group(null, id)
		for y in [range[0]...range[1]]
			[ignore, posY] = HexBuilder._gridPlot([0,y], @origin, @width, @yOffset)
			boxGroup = svg.group(group, id+y)
			$(boxGroup).addClass("row"+y)
			box = svg.use(boxGroup, xPos, posY, null, null, "#resultBox")
			util.drawTextAtPoint(svg, boxGroup, [xPos, posY], ""+(1<<y))
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

	@_roundPoints: (pointArray) ->
		pointArray.map (point) -> ( point.map (coord) -> Math.round(coord*100)/100)

	@_buildSquareLine: (sideLength) ->
		half = sideLength/2.0
		HexBuilder._roundPoints(
			[[half, half],
			[half, -half],
			[-half, -half],
			[-half, half]])

	@_buildHexLine: (height, width, sideLength)->
		halfHeight = height/2.0
		halfWidth = width/2.0
		sidePosY = sideLength/2.0
		#rotate clockwise around the hex
		HexBuilder._roundPoints(
			[[0, halfHeight], 		#top
			[halfWidth, sidePosY],
			[halfWidth, -sidePosY],
			[0, -halfHeight], 		#bottom
			[-halfWidth, -sidePosY],
			[-halfWidth, sidePosY]])#end

	@_solveQuadratic: (a,b,c) ->
		base = Math.pow(Math.pow(b,2)-4*a*c,0.5)/2/a
		root1=-b/2/a+base
		root2=-b/2/a-base
		[root1, root2]