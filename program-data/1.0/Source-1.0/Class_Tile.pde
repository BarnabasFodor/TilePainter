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
    if (mousePressed && (mouseButton == LEFT) && mouseX >= pos.x*TILESIZE && (pos.x+1)*TILESIZE > mouseX && mouseY >= pos.y*TILESIZE && (pos.y+1)*TILESIZE > mouseY) {
      if (!isPaletteImg) {
        img = paintImg;
      } else {
        paintImg = img;
      }
    // Eraser
    } else if (mousePressed && (mouseButton == RIGHT) && mouseX >= pos.x*TILESIZE && (pos.x+1)*TILESIZE > mouseX && mouseY >= pos.y*TILESIZE && (pos.y+1)*TILESIZE > mouseY) {
      if (!isPaletteImg) {
        img = nullImg;
      }
    }
  }

  char getImgCode() {
    // Get the char code of the image
    for (int i = 0; i < images.length; i++) {
      // Images from images[0] to images[9] (Char code: 0-9)
      for (int j = 0; j < 10; j++) {
        if (img == images[j]) return Integer.toString(j).charAt(0);
      }
      // Images from images[10] to images[31] (Char code: a-z)
      for (int j = 10; j < 32; j++) {
        int asciiVal = j+87;
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
