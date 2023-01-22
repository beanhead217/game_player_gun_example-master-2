import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:game_player_with_hands/kevin_spritesheet.dart';
import 'package:game_player_with_hands/player/hands/base_hands.dart';
import 'package:game_player_with_hands/player/hands/hands.dart';

class Kelvin extends SimplePlayer with ObjectCollision {
  BaseHands? hand;

  ///------------------------ ADDED CODE
  int _hAxisInput = 0;
  bool _jumpInput = false;
  bool _isOnGround = true;
  bool onFloor = false;

  final double _gravity = 20;
  final double _jumpSpeed = 400;
  final double _moveSpeed = 64;

  final Vector2 _up = Vector2(0, -1);
  final Vector2 _velocity = Vector2.zero();

  //Limits for clamping player.
  late Vector2 _minClamp;
  late Vector2 _maxClamp;

  late Rect levelBounds;
  ///---------------------


  Kelvin({
    required super.position,
  }) : super(
          size: Vector2.all(32),
          speed: 80,
          animation: SimpleDirectionAnimation(
            idleRight: KevinSpriteSheet.idleRight,
            runRight: KevinSpriteSheet.runRight,
          ),
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: size / 2.5,
            align: Vector2(size.x / 3, size.y / 2),
          ),
        ],
      ),
    );
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      hand?.playAction();
    }
    if (event.id == 2 && event.event == ActionEvent.DOWN) {
      jump();
      hand?.playReload();
    }
    super.joystickAction(event);
  }

  void changeHand(BaseHands newHand) {
    hand?.removeFromParent();
    add(hand = newHand);
  }

  @override
  void onMount() {
    add(hand = Hands(size));

    ///------------------------ ADDED CODE
    final halfSize = size / 2;
    _minClamp = Vector2(0, 0) + halfSize; //levelBounds.topLeft.toVector2() + halfSize;
    _maxClamp = Vector2(320, 320) - halfSize;
    ///------------------------
    super.onMount();
  }

///------------------------ ADDED CODE


// Makes the player jump forcefully.
void jump() {
  _jumpInput = true;
  _isOnGround = true;
}


@override
void update(double dt) {

  // Modify components of velocity based on
  // inputs and gravity.
  _velocity.x = _hAxisInput * _moveSpeed;
  _velocity.y += _gravity;

  // Allow jump only if jump input is pressed
  // and player is already on ground.
  if (_jumpInput) {
    if (_isOnGround) {
      // AudioManager.playSfx('Jump_15.wav');
      _velocity.y = -_jumpSpeed;
      _isOnGround = false;
    }
    _jumpInput = false;
  }

  // Clamp velocity along y to avoid player tunneling
  // through platforms at very high velocities.
  _velocity.y = _velocity.y.clamp(-_jumpSpeed, 150);

  // delta movement = velocity * time
  position += _velocity * dt;

  // Keeps player within level bounds.
  position.clamp(_minClamp, _maxClamp);

  super.update(dt);
}
///------------------------


}
