/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

class Notification {

  // Variables
  private PVector pos, targetPos;
  private float speed;
  private boolean clicked;
  private PImage img;

  // Constructor
  Notification(PImage i) {
    this.pos = new PVector(-256, height-100*(notifications.size()+1));
    this.targetPos = new PVector(0, height-100*(notifications.size()+1));
    this.speed = 16;
    this.img = i;
    this.clicked = false;
  }

  // Functions

  void render() {
    imageMode(CORNER);
    image(img, pos.x, pos.y);
  }

  void move() {
    // Horizontal movement
    if (!(pos.x >= targetPos.x) && !clicked) {
      pos.x += speed;
    }
    // Vertical movement (Only after horizontal movement is done)
    if ((pos.x >= targetPos.x) && !(pos.y >= targetPos.y) && !clicked) {
      pos.y += speed;
    }
    // Clicked refresh
    if (clicked) {
      pos.x -= speed;
    }
  }

  boolean isClicked() {
    if (mousePressed && mouseX >= pos.x && mouseX <= pos.x+256 && mouseY >= pos.y && mouseY <= pos.y+90) {
      cursorOverNotification = true;
      return true;
    } else if (mouseX >= pos.x && mouseX <= pos.x+256 && mouseY >= pos.y && mouseY <= pos.y+90) {
      cursorOverNotification = true;
      return false;
    } else {
      return false;
    }
  }

  // Getters and Setters
  PVector getPos() {
    return pos;
  }

  void setClicked(boolean b) {
    clicked = b;
  }

}
