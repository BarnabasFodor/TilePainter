/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

class Collider {

  // Variables
  private PVector pos;
  private boolean isActive;

  // Constructor
  Collider(PVector p, boolean b) {
    this.pos = p;
    this.isActive = b;
  }

  // Functions
  void render() {
    if (isActive) {
      noStroke();
      fill(255, 0, 0);
      ellipseMode(CENTER);
      ellipse((pos.x+xOffset)*TILESIZE+TILESIZE/2, (pos.y+yOffset)*TILESIZE+TILESIZE/2, TILESIZE/4, TILESIZE/4);
    }
  }

  void mousePressed() {

    boolean isOverlapping = ((mouseX >= 0 && mouseX <= width && mouseY >= 0 && mouseY <= TILESIZE) || (mouseX >= width-TILESIZE && mouseX <= width && mouseY >= 0 && mouseY <= height)) ? true : false;

    if (mousePressed && mouseButton == LEFT && !isOverlapping && eTime >= 250 && !cursorOverNotification && mouseX >= (pos.x+xOffset)*TILESIZE && (pos.x+xOffset+1)*TILESIZE > mouseX && mouseY >= (pos.y+yOffset)*TILESIZE && (pos.y+yOffset+1)*TILESIZE > mouseY) {
      isActive = true;
    }
    if (mousePressed && mouseButton == RIGHT && !isOverlapping && eTime >= 250 && !cursorOverNotification && mouseX >= (pos.x+xOffset)*TILESIZE && (pos.x+xOffset+1)*TILESIZE > mouseX && mouseY >= (pos.y+yOffset)*TILESIZE && (pos.y+yOffset+1)*TILESIZE > mouseY) {
      isActive = false;
    }

  }

  int getCode() {
    if (isActive) { return 1; } else { return 0; }
  }

  // Getters
  PVector getPos() {
    return pos;
  }

  boolean isActive() {
    return isActive;
  }

  // Setters
  void setActive(boolean b) {
    isActive = b;
  }

}
