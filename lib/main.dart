import 'dart:convert';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// todo:
// use .. to chain method calls instead of using the word
// use ?? and  ? :  where I can
// replace types with var where possible
// remove "new"
// remove types in arguments etc

// explain myself:
// I used flame because I think it's a fair use case

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
  var _protagonist;

  Game() {
    _start();
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

  _loadLevel() async {
    String data = await rootBundle.loadString("assets/level.json");
    var _resultSet = json.decode(data);

    _resultSet["gameElements"].forEach((el) {
      var newEl = GameEl(el["x"], _height, el["width"], el["height"],
          el["speed"], el["color"]);
      el["isForeground"] ? _foreground.add(newEl) : _background.add(newEl);
    });

    var p = _resultSet["protagonist"];
    _protagonist = GameEl(_width / 2 - p["width"] / 2, _height, p["width"],
        p["height"], p["speed"], p["color"]);

    TextConfig regular = TextConfig(color: Color(0xffffffff));

    add(TextComponent(_resultSet["tutorial"]["text"], config: regular)
      ..anchor = Anchor.topCenter
      ..x = _width / 2
      ..y = 50);
  }

  _start() async {
    var size = await Flame.util.initialDimensions();
    _width = size.width;
    _height = size.height;
    _loadLevel();
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

    _background.forEach((el) {
      el.render(canvas);
    });

    _protagonist?.render(canvas);

    _foreground.forEach((el) {
      el.render(canvas);
    });
  }

  @override
  void update(t) {
    super.update(t);

    _velocity += _accel;

    _background.forEach((el) {
      el.update(-_velocity);
    });
    _foreground.forEach((el) {
      el.update(-_velocity);
    });

    _velocity *= 0.9;
    _velocity = num.parse(_velocity.toStringAsFixed(3));
  }
}

class GameEl {
  double _x, _y, _w, _h, _speed;
  var _color;
  GameEl(x, y, w, h, speed, color) {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
    _speed = speed;
    _color = Paint()..color = Color(int.parse(color));
  }

  update(x) {
    _x += x * _speed;
  }

  render(Canvas canvas) {
    var rect = Rect.fromLTWH(_x, _y - _h, _w, _h);
    canvas.drawRect(rect, _color);
  }
}
