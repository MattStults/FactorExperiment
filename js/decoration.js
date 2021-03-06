// Generated by CoffeeScript 1.3.3
(function() {
  var __slice = [].slice;

  $.widget("stults.decoration", {
    options: {
      element: null,
      elementId: "board",
      svg: null
    },
    _setOption: function(key, value) {
      if (key === 'element') {
        this.isBuilt = false;
      }
      return this._super(key, value);
    },
    _setOptions: function(options) {
      this._super(options);
      return this.refresh();
    },
    _build: function() {},
    refresh: function() {
      if (!(this.options.svg != null)) {
        this.options.svg = this.element.svg('get');
      }
      if (!(this.isBuilt != null) || !this.isBuilt) {
        this.isBuilt = true;
        return this._build();
      }
    },
    _create: function() {
      this.element.addClass("decoration");
      if (!(this.options.svg != null)) {
        this.element.svg();
      }
      return this.refresh();
    }
  });

  $.widget("stults.gridHover", $.stults.decoration, {
    options: {
      lhs: null,
      rhs: null,
      statusTags: ["on", "off"]
    },
    _buildLine: function(group, positions) {
      var first, last, mid, offset, second, _i;
      first = positions[0], second = positions[1], mid = 4 <= positions.length ? __slice.call(positions, 2, _i = positions.length - 1) : (_i = 2, []), last = positions[_i++];
      offset = {
        x: (second.x - first.x) / 2,
        y: (second.y - first.y) / 2
      };
      return this.options.svg.line(group, first.x + offset.x, first.y + offset.y, last.x + offset.x, last.y + offset.y);
    },
    getChildren: function() {
      return $("#" + this.options.elementId).children();
    },
    _getGridPositions: function(hexes, size) {
      var cols, i, j, pos, rows, _i, _j, _k;
      rows = [];
      cols = [];
      for (i = _i = 0; 0 <= size ? _i < size : _i > size; i = 0 <= size ? ++_i : --_i) {
        rows[i] = [];
        cols[i] = [];
      }
      for (i = _j = 0; 0 <= size ? _j < size : _j > size; i = 0 <= size ? ++_j : --_j) {
        for (j = _k = 0; 0 <= size ? _k < size : _k > size; j = 0 <= size ? ++_k : --_k) {
          pos = util.getElemCenter(hexes.filter($(".x" + i)).filter($(".y" + j))[0]);
          rows[i][j] = pos;
          cols[j][i] = pos;
        }
      }
      return [rows, cols];
    },
    _setupLines: function(grid) {
      var col, cols, hexes, i, lhs, lineGroup, rhs, row, rows, size, _i, _j, _k, _len, _len1, _ref, _results;
      hexes = this.options.element.hexGrid("getChildren");
      size = this.options.element.hexGrid("option", "size");
      _ref = this._getGridPositions(hexes, size), rows = _ref[0], cols = _ref[1];
      lineGroup = this.options.svg.group(null, this.options.elementId);
      lhs = this.options.lhs.hexLine("getChildren");
      rhs = this.options.rhs.hexLine("getChildren");
      for (i = _i = 0; 0 <= size ? _i < size : _i > size; i = 0 <= size ? ++_i : --_i) {
        cols[i] = [util.getElemCenter(rhs.filter($(".row" + i))[0])].concat(cols[i]);
        rows[i] = [util.getElemCenter(lhs.filter($(".row" + i))[0])].concat(rows[i]);
      }
      for (i = _j = 0, _len = rows.length; _j < _len; i = ++_j) {
        row = rows[i];
        $(this._buildLine(lineGroup, row)).addClass("x" + i);
      }
      _results = [];
      for (i = _k = 0, _len1 = cols.length; _k < _len1; i = ++_k) {
        col = cols[i];
        _results.push($(this._buildLine(lineGroup, col)).addClass("y" + i));
      }
      return _results;
    },
    _isTurnOn: function(tags) {
      var x, xBit, y, yBit;
      x = this.options.lhs.hexLine("option", "value");
      y = this.options.rhs.hexLine("option", "value");
      xBit = 1 << tags.x;
      yBit = 1 << tags.y;
      return [(x & xBit) === 0 || (y & yBit) === 0, x, xBit, y, yBit];
    },
    _getStatusClass: function(tags) {
      if (this._isTurnOn(tags)[0]) {
        return this.options.statusTags[0];
      } else {
        return this.options.statusTags[1];
      }
    },
    _removeHover: function() {
      var toRemove;
      toRemove = ["hover", "hoverX", "hoverY", "display"].concat(this.options.statusTags);
      $("#" + this.options.element.hexGrid("option", "elementId")).children().removeClass(toRemove.join(" "));
      $("#" + this.options.lhs.hexLine("option", "elementId")).children().removeClass(toRemove.join(" "));
      $("#" + this.options.rhs.hexLine("option", "elementId")).children().removeClass(toRemove.join(" "));
      return $("#" + this.options.elementId).children().removeClass(toRemove.join(" "));
    },
    _updateHover: function(elementId, selects, classIds) {
      var classesToAdd, pool, sSelector;
      pool = $("#" + elementId);
      sSelector = pool.find(selects.length > 0 ? $("." + selects.join(",.")) : "");
      classesToAdd = classIds.join(" ");
      pool.children().not(sSelector).removeClass(classesToAdd);
      return sSelector.addClass(classesToAdd);
    },
    _addHover: function(tags) {
      var gridId, ignore, selectedLines, selectedXLines, selectedYLines, status, _ref, _ref1;
      status = this._getStatusClass(tags);
      gridId = this.options.element.hexGrid("option", "elementId");
      this._updateHover(gridId, ["x" + tags.x], ["hoverX"]).addClass(status);
      this._updateHover(gridId, ["y" + tags.y], ["hoverY"]).addClass(status);
      this._updateHover(this.options.lhs.hexLine("option", "elementId"), ["row" + tags.x], ["hover", status]);
      this._updateHover(this.options.rhs.hexLine("option", "elementId"), ["row" + tags.y], ["hover", status]);
      this._updateHover(this.options.elementId, ["x" + tags.x, "y" + tags.y], ["hover"]);
      _ref = this.options.lhs.hexLine("getSelected", "x"), selectedXLines = _ref[0], ignore = _ref[1];
      _ref1 = this.options.rhs.hexLine("getSelected", "y"), selectedYLines = _ref1[0], ignore = _ref1[1];
      selectedLines = selectedXLines.concat(selectedYLines);
      return this._updateHover(this.options.elementId, selectedLines, ["display"]);
    },
    _select: function(tags) {
      var isTurnOn, x, xBit, y, yBit, _ref;
      this._removeHover();
      if (tags.x >= 0 && tags.y >= 0) {
        _ref = this._isTurnOn(tags), isTurnOn = _ref[0], x = _ref[1], xBit = _ref[2], y = _ref[3], yBit = _ref[4];
        if (isTurnOn) {
          x |= xBit;
          y |= yBit;
        } else {
          x &= ~xBit;
          y &= ~yBit;
        }
        this.options.lhs.hexLine("option", "value", x);
        this.options.rhs.hexLine("option", "value", y);
      }
      return this._addHover(tags);
    },
    _addClassCallback: function(selector, eventId, callback) {
      return selector.on(eventId, function(event) {
        var classes, identity;
        classes = ($(this).attr('class')).split(' ');
        identity = classes.reduce(function(x, y) {
          var parts;
          parts = /(\D+)(\d+)/.exec(y);
          if ((parts != null) && parts.length > 2) {
            x[parts[1]] = parts[2];
          }
          return x;
        }, {});
        return callback(event, identity);
      });
    },
    _build: function() {
      var grid, lhs, rhs, that;
      that = this;
      lhs = $("#" + this.options.lhs.hexLine("option", "elementId")).children();
      this._addClassCallback(lhs, 'mouseenter', function(event, tags) {
        tags.x = tags.row;
        tags.y = -1;
        return that._addHover(tags);
      });
      this._addClassCallback(lhs, 'click', function(event, tags) {
        tags.x = tags.row;
        tags.y = -1;
        return that._select(tags);
      });
      rhs = $("#" + this.options.rhs.hexLine("option", "elementId")).children();
      this._addClassCallback(rhs, 'mouseenter', function(event, tags) {
        tags.y = tags.row;
        tags.x = -1;
        return that._addHover(tags);
      });
      this._addClassCallback(rhs, 'click', function(event, tags) {
        tags.y = tags.row;
        tags.x = -1;
        return that._select(tags);
      });
      grid = $("#" + this.options.element.hexGrid("option", "elementId")).children();
      this._addClassCallback(grid, 'mouseenter', function(event, tags) {
        return that._addHover(tags);
      });
      this._addClassCallback(grid, 'click', function(event, tags) {
        return that._select(tags);
      });
      $("#game").on('mouseleave', function(event) {
        return that._removeHover();
      });
      return this._setupLines();
    }
  });

  $.widget("stults.decorationBox", $.stults.decoration, {
    options: {
      title: "",
      value: 0,
      textOffset: [0, -20],
      lineOffset: [5, 5]
    },
    _setOption: function(key, value) {
      if (key === 'element') {
        this.isBuilt = false;
      }
      return this._super(key, value);
    },
    _setOptions: function(options) {
      this._super(options);
      return this.refresh();
    },
    _build: function() {
      var base, bound, _ref;
      base = (_ref = this.options.element) != null ? _ref.boxLine("getGroup") : void 0;
      if (!(base != null)) {
        return false;
      }
      if (this.rootGroup != null) {
        this.options.svg.remove(this.rootGroup);
      }
      bound = base.getBBox();
      this.rootGroup = this.options.svg.group(base, this.options.elementId);
      $(this.rootGroup).addClass("decoration");
      return this.text = util.drawTextAtPoint(this.options.svg, this.rootGroup, [bound.x + bound.width / 2 + this.options.textOffset[0], bound.y + this.options.textOffset[1]], this.options.title + ": " + this.options.value);
    },
    refresh: function() {
      this._super('refresh');
      if (this.text != null) {
        return this.text.text(this.options.title + ": " + this.options.value);
      }
    }
  });

}).call(this);
