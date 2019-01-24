/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

class Credits {

  // Variables
  private PVector pos;
  private float speed;
  private String[] text;
  private boolean notVisible;

  // Consturctor
  Credits() {
    this.pos = new PVector(WIDTH/2, HEIGHT);
    this.notVisible = false;
    this.speed = 1;
    this.text = new String[]{
      "TilePainter",
      "Version "+VERSION,
      "____________________________________________________________________",
      "A",
      "PROGRAMMING UNIVERSE",
      "PRODUCTION",
      "____________________________________________________________________",
      "Developer:",
      "Barnabás Fodor",
      "____________________________________________________________________",
      "Program tester:",
      "Simon Nikovics",
      "____________________________________________________________________",
      "Iconset: Google Material Design Icons",
      "https://github.com/google/material-design-icons/releases",
      "____________________________________________________________________",
      "Tileset: Zelda-like Tilesets And Sprites",
      "https://opengameart.org/content/zelda-like-tilesets-and-sprites",
      "____________________________________________________________________",
      "_________________ 2019 _________________"
    };
  }

  // Functions

  // Render
  void render() {
    fill(0);
    textAlign(CENTER);
    textSize(TILESIZE*0.6);
    for (int i = 0; i < text.length; i++) {
      text(text[i], pos.x, pos.y+TILESIZE*i);
    }
  }

  // Move
  void move(){
    pos.y -= speed;
    if (pos.y+((text.length-1)*TILESIZE) <= 0) {
      notVisible = true;
      pos.y = height;
      speed = 1;
    }

    if (mousePressed) {
      speed += 0.2;
    } else if (!(speed <= 1)) {
      speed -= 0.2;
    }
  }

  // Setters
  void setY(float f) {
    pos.y = f;
  }

  void setSpeed(float f) {
    speed = f;
  }

  void setVisible(boolean b) {
    notVisible = b;
  }
}
