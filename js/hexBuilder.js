// Generated by CoffeeScript 1.3.3
(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.HexBuilder = (function() {

    function HexBuilder(height, hwRatio, origin) {
      this.height = height;
      this.hwRatio = hwRatio;
      this.origin = origin;
      this.width = height / hwRatio;
      this.sideLength = HexBuilder._buildSideLength(this.height / 2, this.width / 2);
      this.yOffset = height - (height - this.sideLength) / 2;
    }

    HexBuilder.prototype.setupDefs = function(svg) {
      var defs, hex, square;
      if (!(this.isInitialized != null) || !this.isInitialized) {
        this.isInitialized = true;
        defs = svg.defs("hexDefs");
        hex = svg.polygon(defs, HexBuilder._buildHexLine(this.height, this.width, this.sideLength));
        $(hex).attr('id', "hexagon");
        square = svg.polygon(defs, HexBuilder._buildSquareLine(this.sideLength));
        return $(square).attr('id', "resultBox");
      }
    };

    HexBuilder._gridPlot = function(pos, origin, width, yOffset) {
      return [origin[0] + (pos[0] - pos[1]) * 0.5 * width, origin[1] + (pos[0] + pos[1]) * yOffset].map(function(coord) {
        return Math.round(coord * 100) / 100;
      });
    };

    HexBuilder.prototype.buildLine = function(id, svg, start, stop) {
      var startX, startY, stopX, stopY, _ref, _ref1;
      _ref = HexBuilder._gridPlot(start, this.origin, this.width, this.yOffset), startX = _ref[0], startY = _ref[1];
      _ref1 = HexBuilder._gridPlot(stop, this.origin, this.width, this.yOffset), stopX = _ref1[0], stopY = _ref1[1];
      return svg.line(null, startX, startY, stopX, stopY);
    };

    HexBuilder.prototype.buildGrid = function(id, svg, start, dimensions) {
      var gridGroup, hex, hexGroup, posX, posY, row, text, x, y, _i, _j, _ref, _ref1, _ref2, _ref3, _ref4;
      gridGroup = svg.group(null, id);
      for (x = _i = _ref = start[0], _ref1 = dimensions[0] + start[0]; _ref <= _ref1 ? _i < _ref1 : _i > _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        for (y = _j = _ref2 = start[1], _ref3 = dimensions[1] + start[1]; _ref2 <= _ref3 ? _j < _ref3 : _j > _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
          hexGroup = svg.group(gridGroup, id + ((x - start[0]) + dimensions[0] * (y - start[1])));
          _ref4 = HexBuilder._gridPlot([x, y], this.origin, this.width, this.yOffset), posX = _ref4[0], posY = _ref4[1];
          row = x + y - (start[0] + start[1]);
          $(hexGroup).addClass("x" + (x - start[0])).addClass("y" + (y - start[1])).addClass("row" + row);
          hex = svg.use(hexGroup, posX, posY, null, null, "#hexagon");
          text = svg.text(hexGroup, "" + (1 << row));
          $(text).attr("x", posX - text.offsetWidth / 2).attr("y", posY + text.offsetHeight / 4);
        }
      }
      return gridGroup;
    };

    HexBuilder.prototype.buildBoxes = function(id, svg, range, xPos) {
      var box, group, ignore, posY, y, _i, _ref, _ref1, _ref2;
      group = svg.group(null, id);
      for (y = _i = _ref = range[0], _ref1 = range[1]; _ref <= _ref1 ? _i < _ref1 : _i > _ref1; y = _ref <= _ref1 ? ++_i : --_i) {
        _ref2 = HexBuilder._gridPlot([0, y], this.origin, this.width, this.yOffset), ignore = _ref2[0], posY = _ref2[1];
        box = svg.use(group, xPos, posY, null, null, "#resultBox");
        $(box).attr('id', id + y).addClass("row" + y);
      }
      return group;
    };

    HexBuilder._buildSideLength = function(halfHeight, halfWidth) {
      var a, b, c, root1, root2, sideLength, _ref;
      a = 0.75;
      b = halfHeight;
      c = -(Math.pow(halfHeight, 2) + Math.pow(halfWidth, 2));
      root1 = 0;
      root2 = 0;
      _ref = HexBuilder._solveQuadratic(a, b, c), root1 = _ref[0], root2 = _ref[1];
      sideLength = 0;
      if (!root1.isNaN && root1 > 0) {
        sideLength = root1;
      } else if (!root2.isNaN && root2 > 0) {
        sideLength = root2;
      } else {
        sideLength = (Math.sin(Math.PI / 6) * halfWidth).toFixed(2) * 2;
      }
      return sideLength;
    };

    HexBuilder._roundPoints = function(pointArray) {
      return pointArray.map(function(point) {
        return point.map(function(coord) {
          return Math.round(coord * 100) / 100;
        });
      });
    };

    HexBuilder._buildSquareLine = function(sideLength) {
      var half;
      half = sideLength / 2.0;
      return HexBuilder._roundPoints([[half, half], [half, -half], [-half, -half], [-half, half]]);
    };

    HexBuilder._buildHexLine = function(height, width, sideLength) {
      var halfHeight, halfWidth, sidePosY;
      halfHeight = height / 2.0;
      halfWidth = width / 2.0;
      sidePosY = sideLength / 2.0;
      return HexBuilder._roundPoints([[0, halfHeight], [halfWidth, sidePosY], [halfWidth, -sidePosY], [0, -halfHeight], [-halfWidth, -sidePosY], [-halfWidth, sidePosY]]);
    };

    HexBuilder._solveQuadratic = function(a, b, c) {
      var base, root1, root2;
      base = Math.pow(Math.pow(b, 2) - 4 * a * c, 0.5) / 2 / a;
      root1 = -b / 2 / a + base;
      root2 = -b / 2 / a - base;
      return [root1, root2];
    };

    return HexBuilder;

  })();

}).call(this);
