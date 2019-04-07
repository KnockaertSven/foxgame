import 'dart:convert';
import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as C;
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Game().widget,
      debugShowCheckedModeBanner: false,
    );
  }
}

class Game extends BaseGame {
  var _width = 100.0;
  var _height = 100.0;
  var _velocity = 0.0;
  var _scale = 1.0;
  var _x = 0;

  var _foreground = [];
  var _background = [];
  var _floor;
  var _farmer;
  var _f = [];
  var _color = Paint()..color = Color(int.parse("0xFF5B4510"));
  var _walking = false;
  var _canMove = true;
  C.Animation _anim = null;

  Game() {
    _start();
  }

  _setInput(x, y) {
    if (x > _width / 2 && _canMove) {
      _walking = true;
      _velocity = -5;
      _x += 5;
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
    _anim = C.Animation.sequenced('spritesheet.png', 14,
        textureWidth: 744, textureHeight: 351);
    _floor = Rect.fromLTWH(0, _height - 10, _width, 10);
    var data = await rootBundle.loadString("assets/level.json");
    var resultSet = json.decode(data);

    var f = resultSet["farmer"];
    _f = f["x"];
    _farmer = GameEl(
      _f[0],
      _height / 2 - ((f["height"] * _scale) / 2),
      f["width"] * _scale,
      f["height"] * _scale,
      f["speed"],
      f["image"],
    );
    resultSet["gameElements"].forEach((el) {
      var newEl = GameEl(
          el["x"],
          _height - el["height"] * _scale,
          el["width"] * _scale,
          el["height"] * _scale,
          el["speed"],
          el["image"]);
      el["isForeground"] ? _foreground.add(newEl) : _background.add(newEl);
    });

    var config = TextConfig(color: Color(0xFF000000));
    add(TextComponent(resultSet["tutorial"]["text"], config: config)
      ..anchor = Anchor.topCenter
      ..x = _width / 2
      ..y = 50);
    _farmer.setX(1000.0);
  }

  _start() async {
    var size = await Flame.util.initialDimensions();
    _width = size.width;
    _height = size.height;
    _scale = (_height / 1440);
    _loadLevel();
    _addEventListeners();
    _canMove = true;
  }

  _restart() async {
    _canMove = false;
    _x = 0;
    _background = [];
    _foreground = [];
    _start();
  }

  @override
  void resize(size) {
    super.resize(size);
    _scale = (_height / 1440);
    _width = size.width;
    _height = size.height;
  }

  _renderProtagonist(canvas) {
    if (_anim != null) {
      _anim.currentFrame.sprite.renderPosition(
          canvas,
          Position((_width / 2) - (744 * _scale * 1.4),
              (_height) - (351 * _scale * 1.4)),
          Position((744 * _scale * 1.4), (351 * _scale * 1.4)));
    }
  }

  @override
  void render(canvas) {
    super.render(canvas);
    _background.forEach((el) {
      el.render(canvas);
    });
    _farmer?.render(canvas);
    if (_floor != null) canvas.drawRect(_floor, _color);
    _renderProtagonist(canvas);
    _foreground.forEach((el) {
      el.render(canvas);
    });
  }

  _handleFarmerChecks() {
    if (_farmer == null) return;
    if (!_walking) return;
    if ((_x + _width - 150) > _f[0] && _walking) {
      _restart();
    }
    if ((_x + _width) > _f[0] &&
        (_x + _width) < _f[0] + 200) {
      Future.delayed(const Duration(seconds: 1), () {
        _f[0] = 10000.0;
        _farmer.setX(10000.0);
      });
    }
  }

  @override
  void update(t) {
    super.update(t);
    _background.forEach((el) {
      el.update(_velocity);
    });
    _foreground.forEach((el) {
      el.update(_velocity);
    });
    _farmer?.update(_velocity);
    if (_walking) _anim?.update(t);
    if (_walking) _x += 5;
    var limit = 3000 - _width / 2;
    if (_x > limit) _restart();
    _handleFarmerChecks();
  }
}

class GameEl {
  var _x, _y, _w, _h, _speed;
  Sprite _img;

  GameEl(x, y, w, h, s, src) {
    _x = x;
    _y = y;
    _w = w;
    _h = h;
    _speed = s;
    _img = Sprite(src);
  }

  update(x) {
    _x += x * _speed;
  }

  setX(x) {
    _x = x;
  }

  render(canvas) {
    _img?.renderPosition(canvas, Position(_x, _y), Position(_w, _h));
  }
}
