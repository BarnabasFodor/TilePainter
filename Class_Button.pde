class Button {

  // Primary Variables
  private PVector pos;
  private String text;
  private int startState, transferState;
  private boolean mouseOn;

  // Design Variables
  private color c;
  private float boxw, boxh;

  // Constructor
  Button(PVector p, String t, int sS, int tS) {
    // Primary
    this.pos = p;
    this.text = t;
    this.startState = sS;
    this.transferState = tS;
    this.mouseOn = false;
    // Design
    this.c = color(0);
    this.boxw = 8;
    this.boxh = 1;
  }

  // Functions

  // Render function
  void render() {
    // Box
    rectMode(CENTER);
    stroke(255);
    fill(c);
    rect(pos.x*TILESIZE, pos.y*TILESIZE, boxw*TILESIZE, boxh*TILESIZE);
    // Text
    textAlign(CENTER);
    textSize(TILESIZE*0.6);
    fill(255);
    text(text, pos.x*TILESIZE, pos.y*TILESIZE+TILESIZE/4);
  }

  // Mouse pressed function
  void mousePressed() {
    // Button clicked
    if (mousePressed && mouseButton == LEFT && mouseX >= pos.x*TILESIZE && mouseX < (pos.x)*TILESIZE && mouseY >= pos.y*TILESIZE && mouseY < (pos.y+boxh)*TILESIZE) {

      state = transferState;
      startTime = millis();
      elapsedTime = 0;

    // Mouse on
    } else if (mouseX >= pos.x*TILESIZE && mouseX < (pos.x+boxw)*TILESIZE && mouseY >= pos.y*TILESIZE && mouseY < (pos.y+boxh)*TILESIZE) {

      mouseOn = true;
      c = color(80);

    // Reset
    } else {
      mouseOn = false;
      c = color(0);
    }
  }

  // Getters
  PVector getPos() {
    return pos;
  }

  int getTransferState() {
    return transferState;
  }

  int getStartState() {
    return startState;
  }

}
