root = exports ? this

class root.util
	@getURLParm: (param, def) ->
		matches = location.search.match([param, '=(.+?)(&|$)'].join(''))
		if matches? then return matches[1] else return def
