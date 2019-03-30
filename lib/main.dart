import 'dart:convert';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// todo:
// use .. to chain method calls instead of using the word
// use ?? and  ? :  where I can
// replace types with var where possible
// remove "new"
// remove types in arguments etc

// explain myself

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(Game().widget);
  });
}

class Game extends BaseGame {
  var _width = 100.0;
  var _height = 100.0;
  var _accel = 0.0;
  var _velocity = 0.0;

  var _foreground = [];
  var _background = [];

  Game() {
    _start();
    _loadJSON();
  }

  _setInput(x, y) {
    (x > _width / 2) ? _accel++ : _accel--;
  }

  _forgetInput() {
    _accel = 0;
  }

  _addEventListeners() {
    Flame.util.addGestureRecognizer(TapGestureRecognizer()
      ..onTapDown = ((event) =>
          _setInput(event.globalPosition.dx, event.globalPosition.dy)));

    Flame.util.addGestureRecognizer(
        TapGestureRecognizer()..onTapCancel = (() => _forgetInput()));
  }

  _loadJSON() async {
    String data = await rootBundle.loadString("assets/level.json");
    json.decode(data).forEach((el) {
      if(el["isForeground"]) _foreground.add(GameEl(el["x"], _height, el["width"], el["height"]));
    });
  }

  _start() async {
    var size = await Flame.util.initialDimensions();
    _width = size.width;
    _height = size.height;
    _addEventListeners();
  }

  @override
  void resize(size) {
    super.resize(size);
    _width = size.width;
    _height = size.height;
  }

  @override
  void render(canvas) {
    super.render(canvas);
    var rect = Rect.fromLTWH(_width / 2 - 20, _height - 80, 40, 40);
    canvas.drawRect(rect, BasicPalette.white.paint);

    _foreground.forEach((foregroundElement) {
      foregroundElement.render(canvas);
    });
  }

  @override
  void update(t) {
    super.update(t);

    _velocity += _accel;

    _foreground.forEach((foregroundElement) {
      foregroundElement.update(-_velocity);
    });

    _velocity *= 0.9;
    _velocity = num.parse(_velocity.toStringAsFixed(3));
  }
}

class GameEl {
  double _x, _y, _w, _h;
  var green = new Paint()..color = const Color(0xFF00FF00);
  GameEl(x, y, w, h) {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
  }

  update(x) {
    _x += x;
  }

  render(Canvas canvas) {
    var rect = Rect.fromLTWH(_x, _y - _h, _w, _h);
    canvas.drawRect(rect, green);
  }
}
