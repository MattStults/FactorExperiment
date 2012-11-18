root = exports ? this

class root.util
	@getURLParm: (param, def) ->
		matches = location.search.match([param, '=(.+?)(&|$)'].join(''))
		if matches? then return matches[1] else return def

	@drawTextAtPoint: (svg, parent, pos, text) ->
		text = svg.text(parent, text)
		bound = text.getBBox()
		$(text).attr("x", pos[0] - bound.width/2).attr("y",pos[1] + bound.height/4)

	@getElemCenter: (elem) ->
		bbox = elem.getBBox()
		{
			x: bbox.x + bbox.width/2
			y: bbox.y + bbox.height/2
		}

