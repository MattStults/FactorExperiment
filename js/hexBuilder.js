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
      this.hexLine = HexBuilder._buildHexLine(this.height, this.width, this.sideLength);
      this.yOffset = height - (height - this.sideLength) / 2;
    }

    HexBuilder._gridPlot = function(pos, origin, width, yOffset) {
      return [origin[0] + (pos[0] - pos[1]) * 0.5 * width, origin[1] + (pos[0] + pos[1]) * yOffset];
    };

    HexBuilder.prototype.buildGrid = function(id, svg, start, dimensions) {
      var grid, gridGroup, posX, posY, x, y, _i, _j, _ref, _ref1, _ref2, _ref3, _ref4;
      gridGroup = svg.group();
      grid = [];
      for (x = _i = _ref = start[0], _ref1 = dimensions[0] + start[0]; _ref <= _ref1 ? _i < _ref1 : _i > _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        grid[x] = [];
        for (y = _j = _ref2 = start[1], _ref3 = dimensions[1] + start[1]; _ref2 <= _ref3 ? _j < _ref3 : _j > _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
          posX = 0;
          posY = 0;
          _ref4 = HexBuilder._gridPlot([x, y], this.origin, this.width, this.yOffset), posX = _ref4[0], posY = _ref4[1];
          grid[x][y] = svg.polygon(gridGroup, this.hexLine, {
            transform: "translate(" + posX + "," + posY + ")"
          });
          $(grid[x][y]).attr('id', id + ((x - start[0]) + dimensions[0] * (y - start[1]))).addClass(id).addClass("x" + (x - start[0])).addClass("y" + (y - start[1])).addClass("row" + (x + y - (start[0] + start[1])));
        }
      }
      return gridGroup;
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

    HexBuilder._buildHexLine = function(height, width, sideLength) {
      var halfHeight, halfWidth, sidePosY;
      halfHeight = height / 2;
      halfWidth = width / 2;
      sidePosY = sideLength / 2;
      return [[0, halfHeight], [halfWidth, sidePosY], [halfWidth, -sidePosY], [0, -halfHeight], [-halfWidth, -sidePosY], [-halfWidth, sidePosY]];
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
