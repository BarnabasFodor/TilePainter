/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

// SUPERCLASS : BUTTON
abstract class Button {

  // Primary Variables
  protected PVector pos;
  protected String text;
  protected int startState;
  protected boolean mouseOn, clicked;

  // Design Variables
  protected color c;
  protected float boxw, boxh;

  // Constructor
  Button(PVector p, String t, int sS) {
    // Primary
    this.pos = p;
    this.text = t;
    this.startState = sS;
    this.mouseOn = false;
    // Design
    this.c = color(255, 30);
    this.boxw = 8;
    this.boxh = 1;
  }

  // Render function
  void render() {
    // Box
    imageMode(CENTER);
    image(createBox((int)boxw*TILESIZE, (int)boxh*TILESIZE), pos.x*TILESIZE, pos.y*TILESIZE);
    // Text
    textAlign(CENTER);
    textSize(TILESIZE*0.6);
    fill(0);
    text(text, pos.x*TILESIZE, pos.y*TILESIZE+TILESIZE/4);
  }

  // Function that passes a PGraphics variable to render function
  PImage createBox(int w, int h) {
    PGraphics pg = createGraphics(w*2,h*2);
    pg.beginDraw();
    pg.background(255, 0);
    pg.fill(c);
    pg.rect(w/2+w/40,h/2,w-w/40,h);
    pg.filter(NORMAL);
    pg.fill(c);
    pg.noStroke();
    pg.rectMode(CORNER);
    pg.rect(w/2,h/2+w/40,w,h-w/40);
    pg.filter(BLUR, w/40);
    pg.endDraw();
    return pg.get();
  }

  // Mouse pressed function
  void mousePressed() {
    // Button clicked
    if (mousePressed && mouseButton == LEFT && eTime >= 250 && (pos.x-boxw/2)*TILESIZE <= mouseX && (pos.x+boxw/2)*TILESIZE >= mouseX && (pos.y-boxh/2)*TILESIZE <= mouseY && (pos.y+boxh/2)*TILESIZE >= mouseY) {

      // Action
      action();

      // Trigger activation variable
      clicked = true;

      // Reset click-timelimit
      sTime = millis();
      eTime = 0;

    // Mouse on
    } else if ((pos.x-boxw/2)*TILESIZE <= mouseX && (pos.x+boxw/2)*TILESIZE >= mouseX && (pos.y-boxh/2)*TILESIZE <= mouseY && (pos.y+boxh/2)*TILESIZE >= mouseY) {

      mouseOn = true;
      c = color(80, 30);
      cursorActive = true;

    // Reset
    } else {
      mouseOn = false;
      c = color(255, 60);
    }
  }

  // This method that the child'll override
  abstract void action();

  // Getters
  PVector getPos() {
    return pos;
  }

  boolean isClicked() {
    return clicked;
  }

  String getText() {
    return text;
  }

  int getStartState() {
    return startState;
  }

  // Setters
  void setClicked(boolean b) {
    clicked = b;
  }

}

// CLASS : STATEBUTTON
class StateButton extends Button {

  // Variables
  private int startState, transferState;

  // Constructor
  StateButton(PVector p, String t, int sS, int tS) {
    super(p, t, sS);
    this.transferState = tS;
  }

  // Action
  @Override
  void action() {
    state = transferState;
  }

  int getTransferState() {
    return transferState;
  }
}

// CLASS : SIZEBUTTON
class SizeButton extends Button {

  // Variables
  private int tlW, tlH;

  // Constructor
  SizeButton(PVector p, String t, int sS, int w, int h) {
    super(p, t, sS);
    this.tlW = w;
    this.tlH = h;
  }

  // Action
  @Override
  void action() {
    tilelayerWidth = tlW;
    tilelayerHeight = tlH;
    resizeMap();
    state = 1;
  }

}
