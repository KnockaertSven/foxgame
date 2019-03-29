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

  var foreground = [ForegroundElement(200.0, 100.0), ForegroundElement(300.0, 200.0)];

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
    var rect = Rect.fromLTWH(_width/2 - 20, _height - 80, 40, 40);
    canvas.drawRect(rect, BasicPalette.white.paint);

    foreground.forEach((foregroundElement){
      foregroundElement.render(canvas);
    });
  }

  @override
  void update(t) {
    super.update(t);

    _velocity += _accel;

    foreground.forEach((foregroundElement){
      foregroundElement.update(-_velocity);
    });

    _velocity *= 0.9;
    _velocity = num.parse(_velocity.toStringAsFixed(3));
  }
}

class ForegroundElement {
  double _x, _y;
  var green = new Paint()..color = const Color(0xFF00FF00);
  ForegroundElement(x, y) {
    _x = x;
    _y = y;
  }

  update(x) {
    _x += x;
  }

  render(Canvas canvas) {
    var rect = Rect.fromLTWH(_x + 60, _y - 20, 40, 40);
    canvas.drawRect(rect, green);
  }
}
