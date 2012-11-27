// Generated by CoffeeScript 1.3.3
(function() {
  var __slice = [].slice;

  $.widget("stults.hexElement", {
    options: {
      size: 5,
      hexBuilder: new HexBuilder(50, 1.15, [150, 100]),
      elementId: "board",
      svg: null
    },
    _setOption: function(key, value) {
      if (key === 'size') {
        value = this._constrainSize(value);
      }
      if (key === 'hexBuilder') {
        this.isBuilt = false;
      }
      return this._super(key, value);
    },
    _setOptions: function(options) {
      this._super(options);
      return this.refresh();
    },
    _constrainSize: function(size) {
      if (size < 1) {
        return 1;
      }
      return size;
    },
    _constrainFactor: function(factor) {
      var max;
      if (factor < 0) {
        return 0;
      }
      max = (1 << this.options.size) - 1;
      if (factor > max) {
        return max;
      }
      return factor;
    },
    getChildren: function() {
      return $("#" + this.options.elementId).children();
    },
    setClass: function() {
      var axis, cssClass, selection, value;
      axis = arguments[0], value = arguments[1], cssClass = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      selection = $("#" + this.options.elementId).children().filter($("." + axis + value));
      return selection.addClass(cssClass.join(" "));
    },
    clearClass: function() {
      var cssClass;
      cssClass = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return $("#" + this.options.elementId).children().removeClass(cssClass.join(" "));
    },
    addCallback: function(eventId, callback) {
      return $("#" + this.options.elementId).children().on(eventId, function(event) {
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
    _getSelectedTagsById: function(value, id) {
      var deselect, i, select, tag, _i, _ref;
      select = [];
      deselect = [];
      for (i = _i = 0, _ref = this.options.size; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        tag = id + i;
        if (((1 << i) & value) === 0) {
          deselect.push(tag);
        } else {
          select.push(tag);
        }
      }
      return [select, deselect];
    },
    refresh: function() {
      if (!(this.options.svg != null)) {
        return this.options.svg = this.element.svg('get');
      }
    },
    _create: function() {
      this.element.addClass("hexElement");
      if (!(this.options.svg != null)) {
        this.element.svg();
      }
      return this.refresh();
    }
  });

  $.widget("stults.hexGrid", $.stults.hexElement, {
    options: {
      lhs: 0,
      rhs: 0
    },
    _setOption: function(key, value) {
      if (key === 'lhs' || key === 'rhs') {
        value = $.stults.hexElement.prototype._constrainFactor(value);
        this.isChanged = true;
      }
      return this._super(key, value);
    },
    _updateBoard: function(lhs, rhs) {
      var xDeselect, xSelect, yDeselect, ySelect, _ref, _ref1;
      $("#" + this.options.elementId).children().removeClass("selectX selectY");
      _ref = this._getSelectedTagsById(lhs, ".x"), xSelect = _ref[0], xDeselect = _ref[1];
      $("#" + this.options.elementId).children().filter($(xSelect.join(","))).addClass("selectX");
      _ref1 = this._getSelectedTagsById(rhs, ".y"), ySelect = _ref1[0], yDeselect = _ref1[1];
      return $("#" + this.options.elementId).children().filter($(ySelect.join(","))).addClass("selectY");
    },
    refresh: function() {
      this._super('refresh');
      if ((!(this.isBuilt != null) || !this.isBuilt) && (this.options.hexBuilder != null)) {
        $("#" + this.options.elementId).remove();
        this.options.hexBuilder.buildGrid(this.options.elementId, this.options.svg, [0, 0], [this.options.size, this.options.size]);
        this.isBuilt = true;
      }
      if ((this.isChanged != null) && this.isChanged) {
        this.isChanged = false;
        this._updateBoard(this.options.lhs, this.options.rhs);
        return this._trigger("update", null, {
          value: this.options.lhs * this.options.rhs
        });
      }
    }
  });

  $.widget("stults.hexLine", $.stults.hexElement, {
    options: {
      value: 0,
      axis: 'x'
    },
    _setOption: function(key, value) {
      if (key === 'value') {
        value = $.stults.hexElement.prototype._constrainFactor(value);
      }
      return this._super(key, value);
    },
    _updateBoard: function(value) {
      var deselect, select, _ref;
      _ref = this._getSelectedTagsById(value, "." + this.options.axis), select = _ref[0], deselect = _ref[1];
      $("#" + this.options.elementId).children().filter($(select.join(","))).addClass("select");
      return $("#" + this.options.elementId).children().filter($(deselect.join(","))).removeClass("select");
    },
    _setupClickResponse: function() {
      var that;
      that = this;
      return this.addCallback('click', function(event, tags) {
        that.options.value = that.options.value ^ (1 << tags.row);
        return that.refresh();
      });
    },
    getSelected: function(id) {
      return this._getSelectedTagsById(this.options.value, id);
    },
    refresh: function() {
      var dimensions, origin, _ref;
      this._super('refresh');
      if ((!(this.isBuilt != null) || !this.isBuilt) && (this.options.hexBuilder != null)) {
        $("#" + this.options.elementId).remove();
        _ref = this.options.axis === 'x' ? [[0, -1], [this.options.size, 1]] : [[-1, 0], [1, this.options.size]], origin = _ref[0], dimensions = _ref[1];
        this.options.hexBuilder.buildGrid(this.options.elementId, this.options.svg, origin, dimensions);
        this._setupClickResponse();
        this.isBuilt = true;
      }
      if (this.options.value !== this.lastValue) {
        this.lastValue = this.options.value;
        this._updateBoard(this.options.value);
        return this._trigger("update", null, {
          value: this.options.value
        });
      }
    },
    _create: function() {
      return this._super();
    }
  });

  $.widget("stults.boxLine", $.stults.hexElement, {
    options: {
      value: 0,
      xPos: 300
    },
    _updateBoard: function(value) {
      var deselect, select, _ref;
      _ref = this._getSelectedTagsById(value, ".row"), select = _ref[0], deselect = _ref[1];
      $("#" + this.options.elementId).children().filter($(select.join(","))).addClass("select");
      return $("#" + this.options.elementId).children().filter($(deselect.join(","))).removeClass("select");
    },
    getGroup: function() {
      return this.rootGroup;
    },
    refresh: function() {
      this._super('refresh');
      if ((!(this.isBuilt != null) || !this.isBuilt) && (this.options.hexBuilder != null)) {
        $("#" + this.options.elementId).remove();
        this.rootGroup = this.options.hexBuilder.buildBoxes(this.options.elementId, this.options.svg, [0, this.options.size], this.options.xPos);
        this.isBuilt = true;
      }
      if (this.options.value !== this.lastValue) {
        this.lastValue = this.options.value;
        this._updateBoard(this.options.value);
        return this._trigger("update", null, {
          value: this.options.value
        });
      }
    },
    _create: function() {
      return this._super();
    }
  });

}).call(this);
