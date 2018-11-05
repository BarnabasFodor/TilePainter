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
    image(img, (pos.x*TILESIZE), (pos.y*TILESIZE));
  }

  void mousePressed() {
    // If cursor is in the area of this tile and mouse has been clicked
    if (mousePressed && eTime >= 250 && !cursorOverNotification && (mouseButton == LEFT) && mouseX >= pos.x*TILESIZE && (pos.x+1)*TILESIZE > mouseX && mouseY >= pos.y*TILESIZE && (pos.y+1)*TILESIZE > mouseY) {
      if (!isPaletteImg) {
        img = paintImg;
      } else {
        paintImg = img;
        for (int i = 0; i < images.length; i++) {
          if (paintImg == images[i]) {
            wheelNumber = i;
          }
        }
      }
    // Eraser
    } else if (mousePressed && eTime >= 250 && !cursorOverNotification && (mouseButton == RIGHT) && mouseX >= pos.x*TILESIZE && (pos.x+1)*TILESIZE > mouseX && mouseY >= pos.y*TILESIZE && (pos.y+1)*TILESIZE > mouseY) {
      if (!isPaletteImg) {
        img = nullImg;
      }
    }
  }

  char getImgCode() {
    // Get the char code of the image
    for (int i = 0; i < images.length; i++) {
      for (int j = 0; j < images.length; j++) {
        int asciiVal = j+48;
        if (img == images[j]) return (char)asciiVal;
      }
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
