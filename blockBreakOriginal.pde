// block Break Original
// by narumincho 2018/ 1/ 8

final int blockNum = 20;
Planet planet = new Planet();
Ball ball = new Ball();
Enemy[] enemyList = new Enemy[blockNum];
boolean beforeMousePressed = false;
int time = 0;
boolean gemeClear = false;

void setup() {
  size(800, 800);
  for (int i=0; i<enemyList.length; i++) {
    enemyList[i] = new Enemy();
  }
}

void draw() {
  // update
  planet.update();
  ball.update();
  for (int i=0; i<enemyList.length; i++) {
    enemyList[i].update();
  }
  if (!gemeClear) {
    time+=1;
  }
  checkClear();
  beforeMousePressed = mousePressed;
  // draw
  background(#000000);
  planet.draw();
  ball.draw();
  for (int i=0; i<enemyList.length; i++) {
    enemyList[i].draw();
  }
  drawHowToUse();
  drawTime();
  if (gemeClear) {
    drawClearMessage();
  }
}

class Planet {
  PVector position = new PVector(0, 0);
  final int radius = 50;
  boolean isVacuum = true;
  int flareCount = 0;
  final int flareNum = 4;
  final int flareLimit = 120;

  void update() {
    position.set(mouseX, height/2);
    if (!beforeMousePressed && mousePressed) {
      isVacuum = !isVacuum;
    }
    if (isVacuum) {
      flareCount = (flareCount - 1 + flareLimit) % flareLimit;
    } else {
      flareCount = (flareCount + 1) % flareLimit;
    }
  }
  void draw() {
    fill(planetColor());
    circle(position, radius);
    noFill();
    strokeWeight(4);
    for (int i=0; i<flareNum; i++) {
      final float per = (i+(float)flareCount/flareLimit)/flareNum;
      for (int j=0; j<8; j++) {
        stroke(planetColor(), 255*(1-per)*(isVacuum ? 8-j : j)/8);
        circle(position, radius - 40 + 200*per + 4 * j);
      }
    }
  }

  color planetColor() {
    if (isVacuum) {
      return #33aaff;
    } else {
      return #ff3333;
    }
  }
}

class Enemy {
  PVector position = new PVector(random(0, width), random(0, height));
  final int radius = 25;
  boolean broken = false;
  void update() {
    if (broken) {
      return;
    }
    if ( position.dist(ball.position) < radius+ball.radius ) {
      broken = true;
    }
  }
  void draw() {
    if (broken) {
      return;
    }
    fill(#9C27B0);
    noStroke();
    circle(position, 25);
    fill(#000000);
    triangle(position.x - 20, position.y - 10, position.x - 15, position.y, position.x - 2, position.y);
    triangle(position.x + 20, position.y - 10, position.x + 15, position.y, position.x + 2, position.y);
  }
}

class Ball {
  PVector position = new PVector(30, 0);
  PVector velocity = new PVector(0, 0);
  PVector[] predictionOrbit = new PVector[240];
  final int radius = 10;
  void update() {
    gravitation(position, velocity);
    wallCollision(position, velocity);

    predictionOrbit[0] = position.copy();
    final PVector vel = velocity.copy();
    for (int i=0; i<predictionOrbit.length - 1; i++) {
      final PVector pos = predictionOrbit[i].copy();
      gravitation(pos, vel);
      wallCollision(pos, vel);      
      predictionOrbit[i+1]= pos;
    }
  }
  void gravitation(PVector position, PVector velocity) {
    final float distance = planet.position.copy().sub(position).mag();
    final PVector toPlanet = planet.position.copy().sub(position).normalize();
    if (planet.isVacuum) {
      velocity.add(toPlanet.setMag(50/distance));
    } else {
      velocity.sub(toPlanet.setMag(50/distance));
    }
    if (10<velocity.mag()) {
      velocity.setMag(10);
    }
    position.add(velocity);
  }

  void wallCollision(PVector position, PVector velocity) {
    if (position.x < 0) {
      position.x = 0;
      velocity.x = abs(velocity.x);
    }
    if (width < position.x) {
      position.x = width;
      velocity.x = -abs(velocity.x);
    }
    if (position.y < 0) {
      position.y = 0;
      velocity.y = abs(velocity.y);
    }
    if (height < position.y) {
      position.y = height;
      velocity.y = -abs(velocity.y);
    }
  }
  void draw() {
    fill(#00ffff);
    stroke(#00ffff);
    circle(position, radius);
    for (int i=0; i<predictionOrbit.length-1; i++) {
      stroke(#ffffff, 128-i/2);
      line(predictionOrbit[i], predictionOrbit[i+1]);
    }
  }
}

void checkClear() {
  int brokenNum = 0;
  for (int i=0; i<enemyList.length; i++) {
    if (enemyList[i].broken) {
      brokenNum += 1;
    }
  }
  if (brokenNum==enemyList.length) {
    gemeClear = true;
  }
}

void drawHowToUse() {
  fill(#ffffff);
  textSize(40);
  if (planet.isVacuum) {
    text("click <<o>>", 0, height-40);
  } else {
    text("click >>o<<", 0, height-40);
  }
}

void drawTime() {
  fill(#ffffff);
  textSize(50);
  text("time="+str(time), 0, 50);
}


void drawClearMessage() {
  fill(#F44336);
  textSize(70);
  textAlign(CENTER, CENTER);
  text("Game Clear! time="+str(time), width/2, height/2);
}
void circle(PVector position, float radius) {
  ellipse(position.x, position.y, radius*2, radius*2);
}

void rect(PVector position, PVector size) {
  rect(position.x, position.y, size.x, size.y);
}

void line(PVector position0, PVector position1) {
  line(position0.x, position0.y, position1.x, position1.y);
}