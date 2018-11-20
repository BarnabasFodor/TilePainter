/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

class Notification {

  // Variables
  private PVector pos, targetPos;
  private float notStartTime, notElapsedTime;
  private float speed;
  private PImage img;

  // Constructor
  Notification(PImage i) {
    this.pos = new PVector(-256, height-100*(notifications.size()+1));
    this.targetPos = new PVector(0, height-100*(notifications.size()+1));
    this.speed = 16;
    this.img = i;
    this.notStartTime = millis();
    this.notElapsedTime = millis() - notStartTime;
  }

  // Functions

  void render() {
    imageMode(CORNER);
    noTint();
    image(img, pos.x, pos.y);
  }

  void move() {
    // Horizontal movement
    if (!(pos.x >= targetPos.x) && !(notElapsedTime > 3000)) {
      pos.x += speed;
    }

    // Clicked refresh
    if (notElapsedTime > 3000 && !mouseAbove()) {
      pos.x -= speed;
    }

    notElapsedTime = millis() - notStartTime;
  }

  boolean mouseAbove() {
    if (mouseX >= pos.x && mouseX <= pos.x+img.width && mouseY >= pos.y && mouseY <= pos.y+img.height) {
      cursorOverNotification = true;
      return true;
    }
    return false;
  }

  // Getters and Setters
  PVector getPos() {
    return pos;
  }

  float getTime() {
    return notElapsedTime;
  }

}
