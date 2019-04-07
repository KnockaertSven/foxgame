import 'dart:convert';
import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as CustomAnimation;
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
  var _velocity = 0.0;

  var _foreground = [];
  var _background = [];
  var _backdrop;
  var _protagonist;
  var _chicken;
  bool _walking = false;
  CustomAnimation.Animation _anim;

  Game() {
    _start();
  }

  _setInput(x, y) {
    if(x > _width / 2){
      _walking = true;
      _velocity = -5;
    }
  }

  _forgetInput() {
    _velocity = 0;
    _walking = false;
  }

  _addEventListeners() {
    Flame.util.addGestureRecognizer(TapGestureRecognizer()
      ..onTapDown = ((event) =>
          _setInput(event.globalPosition.dx, event.globalPosition.dy)));

    Flame.util.addGestureRecognizer(
        TapGestureRecognizer()..onTapCancel = (() => _forgetInput()));
  }

  _loadLevel() async {
    _anim = CustomAnimation.Animation.sequenced('spritesheet.png', 14, textureWidth: 744, textureHeight: 351);
    print('$_width and $_height');

    _backdrop = GameEl(0.0, _height, _width, _height, 0.0, "0xFFFFFFFF");

    var data = await rootBundle.loadString("assets/level.json");
    var resultSet = json.decode(data);

    resultSet["gameElements"].forEach((el) {
      var newEl = GameEl(el["x"], _height, el["width"], el["height"],
          el["speed"], el["color"]);
      el["isForeground"] ? _foreground.add(newEl) : _background.add(newEl);
    });

    var p = resultSet["protagonist"];
    _protagonist = GameEl(_width / 2 - p["width"] / 2, _height, p["width"],
        p["height"], p["speed"], p["color"]);

    var c = resultSet["chicken"];
    _chicken = GameEl(
        c["x"], _height, c["width"], c["height"], c["speed"], c["color"]);

    var config = TextConfig(color: Color(0xFF000000));
    add(TextComponent(resultSet["tutorial"]["text"], config: config)
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
    _backdrop?.render(canvas);
    super.render(canvas);
    _background.forEach((el) {
      el.render(canvas);
    });
    _chicken?.render(canvas);
    _protagonist?.render(canvas);
    _foreground.forEach((el) {
      el.render(canvas);
    });
    _anim?.currentFrame.sprite.render(canvas, 250, 120);
  }

  @override
  void update(t) {
    super.update(t);

    _background.forEach((el) {
      el.update(_velocity);
    });
    _chicken?.update(_velocity);
    _foreground.forEach((el) {
      el.update(_velocity);
    });

    if(_walking) _anim?.update(t);
  }
}

class GameEl {
  var _x, _y, _w, _h, _speed, _color;

  GameEl(x, y, w, h, s, c) {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
    _speed = s;
    _color = Paint()..color = Color(int.parse(c));
  }

  update(x) {
    _x += x * _speed;
  }

  render(canvas) {
    var rect = Rect.fromLTWH(_x, _y - _h, _w, _h);
    canvas.drawRect(rect, _color);
  }
}
