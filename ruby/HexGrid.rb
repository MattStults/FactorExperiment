#!/usr/bin/env ruby

require "rexml/document"

class RubyInk

	def initialize
		@arguments = {
			:size => 5,
			:hex => {:height => 50, :width => 43.5},
			:origin => {:x => 350.0, :y => 100},
			:id => 'factor'
		}
		@doc = @doc = REXML::Document.new(
			"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"+
			'<svg width="744.09448" height="1052.3622" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"></svg>')
		ARGV.each do |arg|
			case arg
			when /--?(.+?)=(\d*\.\d*)/
				@arguments[$1.to_sym] = $2.to_f
			when /--?(.+?)=(\d+)/
				@arguments[$1.to_sym] = $2.to_i
			when /--(.*)=\{\s*(\D+):(\d*\.\d*),?\s*(\D+):(\d*\.\d*)\s*\}/
				@arguments[$1.to_sym] = {$2.to_sym => $3.to_f, $4.to_sym => $5.to_f}
			when /--file=(.*)/
				@doc = REXML::Document.new File.new($1)
			when /--?(.+?)=(.*)/
				@arguments[$1.to_sym] = $2
			else
				$stderr.puts "Unrecognized argument: #{arg}"
			end
		end
	end
	def to_s
		str = ""
		@doc.write str, 5
		str
	end
end

class HexGrid < RubyInk
	def initialize
		super
		hexInput = @arguments[:hex]
		@hex = Hex.new(hexInput[:height], hexInput[:width])
		size = @arguments[:size] * 2 - 1
		defs = setupDefs
		buildDefs defs, size, "hexagon", "path", {"d" => "M #{@hex.line.join(" ")} Z"}
		buildDefs defs, size, "lhs", "use", {"xlink:href" => "#hexagon"}
		buildDefs defs, size, "rhs", "use", {"xlink:href" => "#hexagon"}
		buildDefs defs, size+1, "resultBox", "path", {"d" => "M #{_buildBoxLine(@hex.sideLength).join(" ")} Z"}
		buildDefs defs, size+1, "goalBox", "use", {"xlink:href" => "#resultBox"}
		originInput = @arguments[:origin]
		origin = [originInput[:x], originInput[:y]]
		factorSize = @arguments[:size]
		idInput = @arguments[:id]
		buildGrid(
			idInput, 
			"hexagon",
			origin,
			[0,0],
			[factorSize,factorSize])
		buildGridLines(
			"#{idInput}-lines",
			origin,
			[0,0],
			[factorSize,factorSize])
		buildGrid(
			"#{idInput}-lhs", 
			"lhs",
			origin,
			[0,-1],
			[factorSize,1])
		buildGrid(
			"#{idInput}-rhs", 
			"rhs",
			origin,
			[-1,0],
			[1,factorSize])
		buildBoxes(
			"#{idInput}-result",
			"resultBox",
			origin,
			size+1)
		buildBoxes(
			"#{idInput}-goal",
			"goalBox",
			origin,
			size+1)
	end

	def self._gridPlot (pos, origin, width, yOffset)
		x = origin[0] + (pos[0]-pos[1])*0.5*width
		y = origin[1] + (pos[0]+pos[1])*yOffset
		[x,y].map { |coord| coord.to_f().to_precision(2)}
	end

	def setupDefs
		#required for xlink for use in inkscape
		@doc.root.attributes['xmlns:xlink'] = "http://www.w3.org/1999/xlink"
		defs = @doc.root.elements["defs"]
		if defs == nil
			defs = @doc.root.add_element "defs"
		end
		defs
	end

	def buildDefs (defs, size, id, type, attributes)
		attributes['id'] = id
		defs.add_element type, attributes
		_buildRows defs, id, size
	end

	def _buildRows(parent, id, size)
		for i in 0...size
			gId = "#{id}-row-#{i}"
			g = parent.add_element "g", {"id" => gId}
			g.add_element "use", {"xlink:href" => "##{id}"}
			text = g.add_element("text", 
				{"style" =>"text-anchor: middle; dominant-baseline: central;"})
			text.text = (2 ** i).to_s
		end
	end

	def _buildBoxLine(sideLength)
		half = sideLength/2
		[[half, half],
		[half, -half],
		[-half, -half],
		[-half, half]].map{ |point| "#{point[0].to_f().to_precision(2)},#{point[1].to_f().to_precision(2)}"}
	end

	def buildBoxes(id, reference, origin, size)
		boxGroup = @doc.root.add_element "g", {"id" => id}
		for row in 0...size
			ignore, posY = HexGrid._gridPlot([0,row], origin, @hex.width, @hex.yOffset)
			boxGroup.add_element "use", {"xlink:href" => "##{reference}-row-#{row}", "x" => origin[0], "y" => posY, "class" => "x-1 y#{row} row#{row}"}
		end
	end

	def self._gridPlotEdge(prevPos, pos, origin, width, yOffset)
		pstartX, pstartY = HexGrid._gridPlot(prevPos, origin, width, yOffset)
		startX, startY = HexGrid._gridPlot(pos, origin, width, yOffset)
		[(startX+pstartX)/2.0, (startY+pstartY)/2.0]
	end

	def self._drawLine(parent, x1, y1, x2, y2, axis, count)
		parent.add_element "line", {
			"x1" => x1, "y1" => y1, 
			"x2" => x2, "y2" => y2,
			"class" => "#{axis}#{count} row#{count}"}
	end

	def buildGridLines(id, origin, start, dimensions)
		lineGroup = @doc.root.add_element "g", {"id" => id}
		for x in start[0]...(dimensions[0]+start[0])
			startX, startY = HexGrid._gridPlotEdge([x,start[1]-1], [x,start[1]], origin, @hex.width, @hex.yOffset)
			endX, endY = HexGrid._gridPlotEdge([x,start[1]+dimensions[1]-1], [x,start[1]+dimensions[1]], origin, @hex.width, @hex.yOffset)
			HexGrid._drawLine(lineGroup, startX, startY, endX, endY, 'x', x)
		end
		for y in start[1]...(dimensions[1]+start[1])
			startX, startY = HexGrid._gridPlotEdge([start[0]-1, y], [start[0], y], origin, @hex.width, @hex.yOffset)
			endX, endY = HexGrid._gridPlotEdge([start[0]+dimensions[0]-1, y], [start[0]+dimensions[0], y], origin, @hex.width, @hex.yOffset)
			HexGrid._drawLine(lineGroup, startX, startY, endX, endY, 'y', y)
		end
	end

	def buildGrid (id, reference, origin, start, dimensions)
		gridGroup = @doc.root.add_element "g", {"id" => id}
		for x in start[0]...(dimensions[0]+start[0])
			for y in start[1]...(dimensions[1]+start[1])
				row = (x+y-(start[0]+start[1]))
				posX, posY = HexGrid._gridPlot([x,y], origin, @hex.width, @hex.yOffset)
				gridGroup.add_element "use", {"xlink:href" => "##{reference}-row-#{row}", "x" => posX, "y" => posY, "class" => "x#{x-start[0]} y#{y-start[1]} row#{row}"}
			end
		end
		gridGroup
	end
end

class Float
	def to_precision (precision)
		mult = 10 ** precision
		(to_f()*mult).round()/mult.to_f
	end
end


class Hex
	def initialize (height, width)
		@height = height
		@width = width
		@sideLength = Hex._buildSideLength(@height/2, @width/2)
		@yOffset = (@height+@sideLength)/2
		@line = Hex._buildHexLine(@height, @width, @sideLength)
	end

	attr_reader :height, :width, :yOffset, :line, :sideLength

	def self._buildHexLine (height, width, sideLength)
		halfHeight = height/2.0
		halfWidth = width/2.0
		sidePosY = sideLength/2.0
		#rotate clockwise around the hex
		[[0, halfHeight], 		#top
		[halfWidth, sidePosY],
		[halfWidth, -sidePosY],
		[0, -halfHeight], 		#bottom
		[-halfWidth, -sidePosY],
		[-halfWidth, sidePosY]].map{ |point| "#{point[0].to_f().to_precision(2)},#{point[1].to_f().to_precision(2)}"}
	end

	def self._buildSideLength (halfHeight, halfWidth)
		#first, find the y position of the side using the quadratic formula.
		#this should create a hex with equal sides
		#.75s^2 + hs - h^2 - w^2
		#a = 0.75, b = h, c = -(h^2+w^2)
		a = 0.75
		b = halfHeight
		c = -(halfHeight ** 2 + halfWidth ** 2)
		
		root1, root2 = Hex._solveQuadratic(a,b,c)
		sideLength = 0.0
		if not root1.nan? and root1 > 0
			sideLength = root1
		elsif not root2.nan? and root2 > 0
			sideLength = root2
		else 
			sideLength = (Math.sin(Math::PI/6)*halfWidth).to_precision(2)*2
		end
		sideLength.to_precision(2)
	end

	def self._solveQuadratic (a,b,c)
		base = (((b**2)-4*a*c)**0.5)/2/a
		root1=-b/2/a+base
		root2=-b/2/a-base
		[root1, root2]
	end
end

puts HexGrid.new().to_s