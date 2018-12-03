/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

class Tile {

  // Variables
  private PVector pos;
  private PImage img;
  private boolean isPaletteImg;

  // Constructor
  Tile(PVector p, PImage i, boolean b) {
    this.pos = p;
    this.img = i;
    isPaletteImg = b;
  }

  // Functions
  void render() {
    imageMode(CORNER);
    if (!isPaletteImg) {
      noTint();
      image(img, (pos.x+xOffset)*TILESIZE, (pos.y+yOffset)*TILESIZE);
    } else {
      noTint();
      image(img, pos.x*TILESIZE, pos.y*TILESIZE);
    }
  }

  void mousePressed() {

    boolean isOverLapping = ((mouseX >= 0 && mouseX <= width && mouseY >= 0 && mouseY <= TILESIZE) || (mouseX >= width-TILESIZE && mouseX <= width && mouseY >= 0 && mouseY <= height)) ? true : false;

    // If cursor is in the area of this tile and mouse has been clicked
    if (mousePressed && !isOverLapping && !isPaletteImg && !isSelecting && eTime >= 250 && !cursorOverNotification && (mouseButton == LEFT) && mouseX >= (pos.x+xOffset)*TILESIZE && (pos.x+xOffset+1)*TILESIZE > mouseX && mouseY >= (pos.y+yOffset)*TILESIZE && (pos.y+yOffset+1)*TILESIZE > mouseY) {
      img = paintImg;
    // Eraser
    } else if (mousePressed && !isOverLapping && !isPaletteImg && !isSelecting && eTime >= 250 && !cursorOverNotification && (mouseButton == RIGHT) && mouseX >= (pos.x+xOffset)*TILESIZE && (pos.x+xOffset+1)*TILESIZE > mouseX && mouseY >= (pos.y+yOffset)*TILESIZE && (pos.y+yOffset+1)*TILESIZE > mouseY) {
      img = nullImg;
    } else if (mousePressed && isPaletteImg && !cursorOverNotification && mouseX >= pos.x*TILESIZE && (pos.x+1)*TILESIZE > mouseX && mouseY >= pos.y*TILESIZE && (pos.y+1)*TILESIZE > mouseY) {
      paintImg = img;
      for (int i = 0; i < images.length; i++) {
        if (paintImg == images[i]) {
          wheelNumber = i;
        }
      }
    }
    // Cursor
    if (isPaletteImg && !cursorOverNotification && mouseX >= pos.x*TILESIZE && (pos.x+1)*TILESIZE > mouseX && mouseY >= pos.y*TILESIZE && (pos.y+1)*TILESIZE > mouseY) {
      cursorActive = true;
    }
  }

  char getImgCode() {
    // Get the char code of the image
    for (int i = 0; i < images.length; i++) {
      int asciiVal = i+48;
      if (img == images[i]) return (char)asciiVal;
    }
    return '.';
  }

  // Getters
  PImage getImg() {
    return img;
  }

  PVector getPos() {
    return pos;
  }

  // Setters
  void setImg(PImage i) {
    img = i;
  }

}
