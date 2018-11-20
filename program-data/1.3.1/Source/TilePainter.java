import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.Dimension; 
import java.awt.Toolkit; 
import javax.swing.JFileChooser; 
import java.io.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TilePainter extends PApplet {

/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */






// Screen optimization
Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
double w = screenSize.getWidth()/1.275f;
double h = screenSize.getHeight()/1.275f;
int post_w = (int) w;
int post_h = (int) h;

// Program Variables
String VERSION = "1.3.1";
int state = -1;
ArrayList<Notification> notifications = new ArrayList<Notification>();
float startTime = millis();
float elapsedTime = millis() - startTime;
String currentMapID = "Untitled";
PFont font;

// Tilesize and post screen optimization
final int TILESIZE = (post_w/33+post_h/25)/2;
int width = PApplet.parseInt(TILESIZE*33);
int height = PApplet.parseInt(TILESIZE*25);

// Tiles
ArrayList<TileLayer> tilelayers = new ArrayList<TileLayer>(); // Tilelayer arraylist
int tilelayerIndex = 1;

// Images
Credits credits = new Credits();
PImage[] not_imgs = new PImage[4];
PImage[] ico_imgs = new PImage[8];
PImage[] images= new PImage[55];
PImage paintImg, nullImg, animation, homescreen, creditsscreen;

// Painting variables
int wheelNumber = 0;
float sTime, eTime; // <- Selection and Buttons also use these variables
boolean cursorOverNotification = false;
boolean shouldReset = false;
/* Fill by selecting area */
boolean isSelecting = false;
PVector startSelect = null, endSelect = null;

// Camera variables
int xOffset = 0, yOffset = 0;
boolean right = false, left = false, up = false, down = false;
boolean shift = false;

// Icons' variables
ArrayList<Icon> icons = new ArrayList<Icon>();
boolean isInfoVisible = true;
boolean isDetailsVisible = false;

// Buttons
ArrayList<Button> buttons = new ArrayList<Button>();

// Screen setup
public void settings() {
  size(width, height);
}

// Setup
public void setup() {

  // Setup : Window Location
  surface.setLocation((int)screenSize.getWidth()/2-width/2, 0);

  // Setup : Images
  for (int i = 1; i <= 55; i++) {
    images[i-1] = loadImage("tile_"+Integer.toString(i)+".png");
    images[i-1].resize(TILESIZE, TILESIZE);
  }
  for (int i = 1; i <= 4; i++) {
    not_imgs[i-1] = loadImage("not_"+Integer.toString(i)+".png");
  }
  for (int i = 1; i <= 8; i++) {
    ico_imgs[i-1] = loadImage("icon_"+Integer.toString(i)+".png");
    ico_imgs[i-1].resize(TILESIZE, TILESIZE);
  }
  paintImg = images[0]; // Paint Image
  nullImg = loadImage("nullimg.png"); // Empty Image
  animation = loadImage("company.png"); // Animation Image
  animation.resize(width, height);
  homescreen = loadImage("homescreen.png");
  homescreen.resize(width, height);
  creditsscreen = loadImage("creditsscreen.png");
  creditsscreen.resize(width, height);

  // Setup : Tile Layers
  tilelayers.add(new TileLayer(0, 0)); // Palette tilelayer
  tilelayers.add(new TileLayer(1, 1)); // Main tilelayer
  tilelayers.add(new TileLayer(1, 2)); // 1st decorative tilelayer

  // Setup : Fonts
  font = loadFont("OCRAStd-32.vlw");
  textFont(font);

  // Setup : Icons
  icons.add(new InfoIcon(
    new PVector(32, 0),
    ico_imgs[0],
    true,
    "Information"));
  icons.add(new DetailsIcon(
    new PVector(32, 1),
    ico_imgs[1],
    true,
    "Details"));
  icons.add(new SaveIcon(
    new PVector(32, 2),
    ico_imgs[2],
    true,
    "Save map"));
  icons.add(new OpenIcon(
    new PVector(32, 3),
    ico_imgs[3],
    true,
    "Open map"));
  icons.add(new RandomIcon(
    new PVector(32, 4),
    ico_imgs[4],
    true,
    "Generate tiles"));
  icons.add(new LayerIcon(
    new PVector(32, 5),
    ico_imgs[5],
    true,
    "Add layer",
    1));
  icons.add(new LayerIcon(
    new PVector(32, 6),
    ico_imgs[6],
    true,
    "Remove layer",
    -1));
  icons.add(new ExitIcon(
    new PVector(32, 24),
    ico_imgs[7],
    true,
    "Main Menu"
    ));

  // Setup : Buttons
  // >>> State 1 - Main Menu <<< //
  // 'New Project' button
  buttons.add(new Button(
    new PVector(width/2/TILESIZE, height/2/TILESIZE),
    "New Project",
    0,
    1
    ));
  // 'Credits' button
  buttons.add(new Button(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+1.2f),
    "Credits",
    0,
    2
    ));
  // 'Quit' button
  buttons.add(new Button(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+2.4f),
    "Quit",
    0,
    -2
    ));
}

// Main loop
public void draw() {

  // Background and grid
  background(100);

  // QUIT
  if (state == -2) {

    exit();

  // STARTUP
  } else if (state == -1) {

    // Logo animation
    if ((elapsedTime = millis() - startTime) < 2500) { // 2.5s delay
      imageMode(CENTER);
      image(animation, width/2, height/2);
    } else {
      state = 0;
    }

  // MAIN MENU
  } else if (state == 0) {

    // Background
    imageMode(CORNER);
    image(homescreen, 0, 0, width, height);

    // Buttons
    for (Button b : getCurrentButtons(0)) {
      b.mousePressed();
      b.render();
    }

  // PROGRAM
  } else if (state == 1) {

    // Notifications (Logical operations)
    shouldReset = true;
    for (int i = notifications.size()-1; i >= 0; i--) {
      Notification n = notifications.get(i);
      n.move();
      if (n.mouseAbove()) {
        shouldReset = false;
      }
      if (n.getPos().x < -260) {
        notifications.remove(n);
      }
    }

    // Camera update
    updateCameraControl();

    // Selection fill function
    selectionFill();

    // Looping through the tilelayers (excluding the palette tilelayer)
    for (int i = 1; i < tilelayers.size(); i++) {
      tilelayers.get(i).update();
    }
    // Box to hide lower layers (preventing the palette tiles to render right over other tile layers)
    rectMode(CORNER);
    noStroke();
    fill(100);
    rect(0, 0, width, TILESIZE);
    // Palette Tiles
    for (Tile t : tilelayers.get(0).getTiles()) {
      t.mousePressed();
      t.render();
    }

    // Information text and draw functions
    if (keyPressed && key == 't') {
      xOffset = 0;
      yOffset = 0;
      captureScreen();
    } else {
      drawGrid();
      displayInfo();
      drawSelectionBox();
    }

    // Icons
    for (Icon i : icons) {
      i.update();
      i.render();
      i.nameDisplay();
      i.action();
    }

    // Map highlight
    if (xOffset != 0 || yOffset != 0) {
      cornerDraw();
    }

    // Notifications (Graphical operations)
    for (Notification n : notifications) {
      n.render();
    }

    // Boolean reset (cursorOverNotification)
    if (shouldReset == true) {
      cursorOverNotification = false;
      shouldReset = false;
    }

    eTime = millis()-sTime; // Time limit

  // CREDITS
  } else if (state == 2) {

    // Background
    imageMode(CORNER);
    image(creditsscreen, 0, 0, width, height);

    // Updating text
    credits.move();
    credits.render();

  }
}
class Button {

  // Primary Variables
  private PVector pos;
  private String text;
  private int startState, transferState;
  private boolean mouseOn, clicked;

  // Design Variables
  private int c;
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
    this.c = color(255, 30);
    this.boxw = 8;
    this.boxh = 1;
  }

  // Render function
  public void render() {
    // Box
    imageMode(CENTER);
    image(createBox((int)boxw*TILESIZE, (int)boxh*TILESIZE), pos.x*TILESIZE, pos.y*TILESIZE);
    // Text
    textAlign(CENTER);
    textSize(TILESIZE*0.6f);
    fill(0);
    text(text, pos.x*TILESIZE, pos.y*TILESIZE+TILESIZE/4);
  }

  // Function that passes a PGraphics variable to render function
  public PImage createBox(int w, int h) {
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
  public void mousePressed() {
    // Button clicked
    if (mousePressed && mouseButton == LEFT && (pos.x-boxw/2)*TILESIZE <= mouseX && (pos.x+boxw/2)*TILESIZE >= mouseX && (pos.y-boxh/2)*TILESIZE <= mouseY && (pos.y+boxh/2)*TILESIZE >= mouseY) {

      // Transfer and
      state = transferState;

      // Trigger activation variable
      clicked = true;

      // Reset click-timelimit
      sTime = millis();
      eTime = 0;

    // Mouse on
    } else if ((pos.x-boxw/2)*TILESIZE <= mouseX && (pos.x+boxw/2)*TILESIZE >= mouseX && (pos.y-boxh/2)*TILESIZE <= mouseY && (pos.y+boxh/2)*TILESIZE >= mouseY) {

      mouseOn = true;
      c = color(80, 30);

    // Reset
    } else {
      mouseOn = false;
      c = color(255, 60);
    }
  }

  // Getters
  public PVector getPos() {
    return pos;
  }

  public boolean isClicked() {
    return clicked;
  }

  public String getText() {
    return text;
  }

  public int getTransferState() {
    return transferState;
  }

  public int getStartState() {
    return startState;
  }

  // Setters
  public void setClicked(boolean b) {
    clicked = b;
  }

}
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
    this.pos = new PVector(width/2, height);
    this.notVisible = false;
    this.speed = 1;
    this.text = new String[]{
      "TilePainter",
      "Version "+VERSION,
      "————————————————————————————————————————————————————————————————————",
      "A",
      "PROGRAMMING UNIVERSE",
      "PRODUCTION",
      "————————————————————————————————————————————————————————————————————",
      "Developer:",
      "Barnabás Fodor",
      "————————————————————————————————————————————————————————————————————",
      "Program tester:",
      "Simon Nikovics",
      "————————————————————————————————————————————————————————————————————",
      "Iconset: Google Material Design Icons",
      "https://github.com/google/material-design-icons/releases",
      "————————————————————————————————————————————————————————————————————",
      "————————————————— 2018 —————————————————"
    };
  }

  // Functions

  // Render
  public void render() {
    fill(0);
    textAlign(CENTER);
    textSize(TILESIZE*0.6f);
    for (int i = 0; i < text.length; i++) {
      text(text[i], pos.x, pos.y+TILESIZE*i);
    }
  }

  // Move
  public void move(){
    pos.y -= speed;
    if (pos.y+((text.length-1)*TILESIZE) <= 0) {
      notVisible = true;
      pos.y = height;
      speed = 1;
    }

    if (mousePressed) {
      speed += 0.2f;
    } else if (!(speed <= 1)) {
      speed -= 0.2f;
    }
  }

  // Setters
  public void setY(float f) {
    pos.y = f;
  }

  public void setSpeed(float f) {
    speed = f;
  }

  public void setVisible(boolean b) {
    notVisible = b;
  }
}
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

  public void render() {
    imageMode(CORNER);
    noTint();
    image(img, pos.x, pos.y);
  }

  public void move() {
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

  public boolean mouseAbove() {
    if (mouseX >= pos.x && mouseX <= pos.x+img.width && mouseY >= pos.y && mouseY <= pos.y+img.height) {
      cursorOverNotification = true;
      return true;
    }
    return false;
  }

  // Getters and Setters
  public PVector getPos() {
    return pos;
  }

  public float getTime() {
    return notElapsedTime;
  }

}
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
  public void render() {
    imageMode(CORNER);
    if (!isPaletteImg) {
      noTint();
      image(img, (pos.x+xOffset)*TILESIZE, (pos.y+yOffset)*TILESIZE);
    } else {
      noTint();
      image(img, pos.x*TILESIZE, pos.y*TILESIZE);
    }
  }

  public void mousePressed() {
    // If cursor is in the area of this tile and mouse has been clicked
    if (mousePressed && !isPaletteImg && !isSelecting && eTime >= 250 && !cursorOverNotification && (mouseButton == LEFT) && mouseX >= (pos.x+xOffset)*TILESIZE && (pos.x+xOffset+1)*TILESIZE > mouseX && mouseY >= (pos.y+yOffset)*TILESIZE && (pos.y+yOffset+1)*TILESIZE > mouseY) {
      img = paintImg;
    // Eraser
    } else if (mousePressed && !isSelecting && eTime >= 250 && !cursorOverNotification && (mouseButton == RIGHT) && mouseX >= (pos.x+xOffset)*TILESIZE && (pos.x+xOffset+1)*TILESIZE > mouseX && mouseY >= (pos.y+yOffset)*TILESIZE && (pos.y+yOffset+1)*TILESIZE > mouseY) {
      if (!isPaletteImg) {
        img = nullImg;
      }
    } else if (mousePressed && isPaletteImg && !cursorOverNotification &&  mouseX >= pos.x*TILESIZE && (pos.x+1)*TILESIZE > mouseX && mouseY >= pos.y*TILESIZE && (pos.y+1)*TILESIZE > mouseY) {
      paintImg = img;
      for (int i = 0; i < images.length; i++) {
        if (paintImg == images[i]) {
          wheelNumber = i;
        }
      }
    }
  }

  public char getImgCode() {
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
  public PImage getImg() {
    return img;
  }

  public PVector getPos() {
    return pos;
  }

  // Setters
  public void setImg(PImage i) {
    img = i;
  }

}
class TileLayer {

  // Variables
  private ArrayList<Tile> tiles;
  private int index;
  private int type;

  // Constructor
  TileLayer(int t, int i) {
    this.type = t;
    this.index = i;
    this.tiles = setupList();
  }

  // Functions
  public void update() {
    for (Tile t : tiles) {
      t.render();
      if (isActive()) t.mousePressed();
    }
  }

  public ArrayList<Tile> setupList() {
    // Variable that the function will return
    ArrayList<Tile> temp = new ArrayList<Tile>();
    switch (type) {
      // Palette tilelayer
      case 0:
        for (int x = 0; x < 32; x++) {
          temp.add(new Tile(
            new PVector(x, 0),
            images[x],
            true));
        }
        break;
      // Normal tilelayer
      case 1:
        for (int y = 1; y < 25; y++) {
          for (int x = 0; x < 32; x++) {
            temp.add(new Tile(
              new PVector(x, y),
              nullImg,
              false));
          }
        }
        break;
    }
    // Return
    return temp;
  }

  // Getters
  public ArrayList<Tile> getTiles() {
    return tiles;
  }

  public int getIndex() {
    return index;
  }

  public int getType() {
    return type;
  }

  public boolean isActive() {
    if (tilelayerIndex == index) return true;
    return false;
  }

  // Setters
  public void setIndex(int i) {
    index = i;
  }
}
/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

/*
 * ---   MOUSE INPUT   ---
 */

// Tile Selection by mousewheel
public void mouseWheel(MouseEvent e) {
  int max = images.length-1;
  // Up-switch
  if (wheelNumber != max && -e.getCount() == 1) {
    wheelNumber += round(constrain(-e.getCount(), -max, max));
  // Down-switch
  } else if (wheelNumber != 0 && -e.getCount() == -1) {
    wheelNumber += round(constrain(-e.getCount(), -max, max));
  // Start-switch
  } else if (wheelNumber == 0 && -e.getCount() == -1) {
    wheelNumber = max;
  // End-switch
  } else if (wheelNumber == max && -e.getCount() == 1) {
    wheelNumber = 0;
  }

  // Palette tiles
  if (wheelNumber > 31) {
    for (int i = 0; i < tilelayers.get(0).getTiles().size(); i++) {
      if ((i+31) >= max) {
        tilelayers.get(0).getTiles().get(i).setImg(nullImg);
      } else {
        tilelayers.get(0).getTiles().get(i).setImg(images[i+32]);
      }
    }
  } else if (wheelNumber <= 31) {
    for (int i = 0; i < 32; i++) {
      tilelayers.get(0).getTiles().get(i).setImg(images[i]);
    }
  }

  paintImg = images[wheelNumber];
}

/*
 * ---   PAINTING FUNCTIONS   ---
 */

// Selection brush
public void selectionFill() {

  // START SELECTING
  if (shift && !isSelecting && mousePressed && mouseButton == LEFT &&
     mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= 32 && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= 25) {

    // Update variables
    isSelecting = true;
    startSelect = new PVector(mouseX/TILESIZE-xOffset, mouseY/TILESIZE-yOffset);

  // END SELECTING
  } else if (shift && isSelecting && mousePressed && mouseButton == RIGHT &&
     mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= 32 && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= 25) {

    // Update variables
    endSelect = new PVector(mouseX/TILESIZE-xOffset, mouseY/TILESIZE-yOffset);
    PVector sPos = new PVector(0, 0), ePos = new PVector(0, 0);

    // Optimize variables
    if (startSelect.x >= endSelect.x) { // Horizontal positions
      sPos.x = endSelect.x;
      ePos.x = startSelect.x;
    } else {
      sPos.x = startSelect.x;
      ePos.x = endSelect.x;
    }
    if (startSelect.y >= endSelect.y) { // Vertical positions
      sPos.y = endSelect.y;
      ePos.y = startSelect.y;
    } else {
      sPos.y = startSelect.y;
      ePos.y = endSelect.y;
    }

    // Painting
    for (int y = PApplet.parseInt(sPos.y); y <= PApplet.parseInt(ePos.y); y++) {
      for (int x = PApplet.parseInt(sPos.x); x <= PApplet.parseInt(ePos.x); x++) {
        tilelayers.get(tilelayerIndex).getTiles().get((y-1)*32+x).setImg(paintImg); // -> Current tilelayer
      }
    }

    // Reset variables
    sTime = millis();
    eTime = 0;
    isSelecting = false;

  // SELECTION ERASE
  } else if (keyPressed && key == 'e' && isSelecting &&
     mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= 32 && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= 25) {

    // Update variables
    endSelect = new PVector(mouseX/TILESIZE-xOffset, mouseY/TILESIZE-yOffset);
    PVector sPos = new PVector(0, 0), ePos = new PVector(0, 0);

    // Optimize variables
    if (startSelect.x >= endSelect.x) { // Horizontal positions
      sPos.x = endSelect.x;
      ePos.x = startSelect.x;
    } else {
      sPos.x = startSelect.x;
      ePos.x = endSelect.x;
    }
    if (startSelect.y >= endSelect.y) { // Vertical positions
      sPos.y = endSelect.y;
      ePos.y = startSelect.y;
    } else {
      sPos.y = startSelect.y;
      ePos.y = endSelect.y;
    }

    // Painting
    for (int y = PApplet.parseInt(sPos.y); y <= PApplet.parseInt(ePos.y); y++) {
     for (int x = PApplet.parseInt(sPos.x); x <= PApplet.parseInt(ePos.x); x++) {
       tilelayers.get(tilelayerIndex).getTiles().get((y-1)*32+x).setImg(nullImg); // -> Current tilelayer
     }
    }

    // Reset variables
    sTime = millis();
    eTime = 0;
    isSelecting = false;

  // TILE GENERATION
  } else if (keyPressed && key == 'r' && isSelecting &&
     mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= 32 && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= 25) {

    // Update variables
    endSelect = new PVector(mouseX/TILESIZE-xOffset, mouseY/TILESIZE-yOffset);
    PVector sPos = new PVector(0, 0), ePos = new PVector(0, 0);

    // Optimize variables
    if (startSelect.x >= endSelect.x) { // Horizontal positions
      sPos.x = endSelect.x;
      ePos.x = startSelect.x;
    } else {
      sPos.x = startSelect.x;
      ePos.x = endSelect.x;
    }
    if (startSelect.y >= endSelect.y) { // Vertical positions
      sPos.y = endSelect.y;
      ePos.y = startSelect.y;
    } else {
      sPos.y = startSelect.y;
      ePos.y = endSelect.y;
    }

    // Painting
    PImage[] grass = {images[0], images[1], images[2], images[3]};
    PImage[] flower = {images[22], images[23], images[24], images[25], images[26]};
    PImage[] stone = {images[27], images[28], images[29], images[30], images[31]};
    for (int y = PApplet.parseInt(sPos.y); y <= PApplet.parseInt(ePos.y); y++) {
      for (int x = PApplet.parseInt(sPos.x); x <= PApplet.parseInt(ePos.x); x++) {
        if (tilelayerIndex == 1) {
          tilelayers.get(tilelayerIndex).getTiles().get((y-1)*32+x).setImg(grass[round(random(0, 3))]);
        }
        if (tilelayerIndex >= 2) {
          if (random(0, 1) > 0.98f) {
            tilelayers.get(tilelayerIndex).getTiles().get((y-1)*32+x).setImg(stone[round(random(0, 4))]);
          }
          if (random(0, 1) > 0.95f) {
            tilelayers.get(tilelayerIndex).getTiles().get((y-1)*32+x).setImg(flower[round(random(0, 4))]);
          }
        }
      }
    }

    // Reset variables
    sTime = millis();
    eTime = 0;
    isSelecting = false;

  }

}

// Screen capture (Partial screenshot)
public void captureScreen() {
  PImage screenShot = get(0, TILESIZE, 31*TILESIZE, 24*TILESIZE); // Get art
  String docs = new JFileChooser().getFileSystemView().getDefaultDirectory().toString(); // Path to the 'Documents' directory
  String path = docs + "\\TilePainterMaps\\Screenshots\\"; // Final path
  File folder = new File(path);
  if (!folder.exists()) folder.mkdir(); // Make directories if they don't exist
  screenShot.save(path+"screenshot_"+month()+"-"+day()+"-"+year()+"--"+hour()+"-"+minute()+"-"+second()+".png"); // Save!
}

public void displayInfo() {
  // Details text
  if (isDetailsVisible) {
    textSize(TILESIZE/2);
    PVector posRect = new PVector(29*TILESIZE-textWidth(currentMapID), TILESIZE);
    float boxw = 32*TILESIZE-(29*TILESIZE-textWidth(currentMapID))-1.5f, boxh = 4.5f*TILESIZE;
    float offSet = TILESIZE/8;
    String brushMode = (isSelecting) ? "SELECT" : "PAINT";
    rectMode(CORNER);
    strokeWeight(3);
    stroke(255);
    fill(120, 60);
    rect(posRect.x, posRect.y, boxw, boxh);
    textAlign(LEFT);
    fill(255);
    text("|Project:\n\n|Brush mode:\n\n|Camera offset:", posRect.x+offSet, posRect.y+TILESIZE);
    text("\n "+currentMapID+"\n\n "+brushMode+"\n\n {"+nf(-yOffset, 2)+","+nf(-xOffset, 2)+"}\n\n ", posRect.x+offSet, posRect.y+TILESIZE);
  }

  // Information text
  if (isInfoVisible) {
    textAlign(CENTER);
    textSize(TILESIZE);
    fill(0);
    if (wheelNumber+1 > 9) {
      text("Layer: "+tilelayerIndex+"/"+(tilelayers.size()-1)+" | Tile: "+(wheelNumber+1), width/2, height-TILESIZE);
    } else {
      text("Layer: "+tilelayerIndex+"/"+(tilelayers.size()-1)+" | Tile: 0"+(wheelNumber+1), width/2, height-TILESIZE);
    }
  }

  // Selection text
  if (isSelecting && isInfoVisible) {
    textAlign(CENTER);
    textSize(TILESIZE);
    noStroke();
    fill(0, 255, 0);
    rectMode(CORNER);
    rect(width/2-textWidth("12345678"), height-3*TILESIZE, textWidth("E"), TILESIZE+TILESIZE/5);
    rect(width/2-textWidth("12345"), height-3*TILESIZE, textWidth("R"), TILESIZE+TILESIZE/5);
    rect(width/2-textWidth("12"), height-3*TILESIZE, textWidth("ESC"), TILESIZE+TILESIZE/5);
    rect(width/2+textWidth("12345"), height-3*TILESIZE, textWidth("SHIFT+RMB"), TILESIZE+TILESIZE/5);
    fill(0);
    text("PRESS E, R, ESC OR SHIFT+RMB", width/2, height-2*TILESIZE);
  }
}

// Selection box function
public void drawSelectionBox() {

  // SELECTION BOX
  if (isSelecting && mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= 32 && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= 25) {

    // Update variables
    PVector currentEndSelect = new PVector(mouseX/TILESIZE, mouseY/TILESIZE);
    PVector convStartSelect = new PVector(startSelect.x+xOffset, startSelect.y+yOffset);
    PVector sP = new PVector(0, 0), eP = new PVector(0, 0);

    // Optimize variables
    if (convStartSelect.x >= currentEndSelect.x) { // Horizontal positions
      sP.x = currentEndSelect.x;
      eP.x = convStartSelect.x;
    } else {
      sP.x = convStartSelect.x;
      eP.x = currentEndSelect.x;
    }
    if (convStartSelect.y >= currentEndSelect.y) { // Vertical positions
      sP.y = currentEndSelect.y;
      eP.y = convStartSelect.y;
    } else {
      sP.y = convStartSelect.y;
      eP.y = currentEndSelect.y;
    }

    noStroke();
    fill(255, 194, 0, 90);
    rect(sP.x*TILESIZE, sP.y*TILESIZE, (eP.x-sP.x+1)*TILESIZE, (eP.y-sP.y+1)*TILESIZE);

  }

}

// Grid draw function
public void drawGrid() {

  // Grid
  stroke(140);
  strokeWeight(1);
  for (int y = TILESIZE; y < height; y += TILESIZE) {
    for (int x = 0; x < 32*TILESIZE; x += TILESIZE) {
      line(x, TILESIZE, x, height); // Vertical lines
    }
    line(0, y, 32*TILESIZE, y); // Horizontal lines
  }

  // Separator
  strokeWeight(3);
  stroke(150, 190, 255);
  line(0, TILESIZE, 32*TILESIZE-1.5f, TILESIZE); // HORIZONTAL
  line(32*TILESIZE-1.5f, 0, 32*TILESIZE-1.5f, height); // VERTICAL

  // Selected tile's rectangle
  rectMode(CORNER);
  strokeWeight(3);
  noFill();
  stroke(255);
  if (wheelNumber < 32) {
    rect(wheelNumber*TILESIZE, 0, TILESIZE, TILESIZE);
  } else {
    rect((wheelNumber-32)*TILESIZE, 0, TILESIZE, TILESIZE);
  }

}

// Corner draw
public void cornerDraw() {
  noFill();
  stroke(255, 0, 0);
  pushMatrix();
  translate(xOffset*TILESIZE, yOffset*TILESIZE);
  // TOP-RIGHT
  line(0, TILESIZE, TILESIZE, TILESIZE);
  line(0, TILESIZE, 0, 2*TILESIZE);
  // BOTTOM-RIGHT
  line(0, 25*TILESIZE, TILESIZE, 25*TILESIZE);
  line(0, 25*TILESIZE, 0, 24*TILESIZE);
  // TOP-LEFT
  line(32*TILESIZE, TILESIZE, 32*TILESIZE-1*TILESIZE, TILESIZE);
  line(32*TILESIZE, TILESIZE, 32*TILESIZE, 2*TILESIZE);
  // BOTTOM-LEFT
  line(32*TILESIZE, 25*TILESIZE, 32*TILESIZE-1*TILESIZE, 25*TILESIZE);
  line(32*TILESIZE, 25*TILESIZE, 32*TILESIZE, 24*TILESIZE);
  popMatrix();
}

/*
 * ---   KEYBOARD INPUT ---
 */

 // Certain keyboard inputs
 public void keyPressed() {

   // Tilelayer change
   if (Character.getNumericValue(key) >= 1 && Character.getNumericValue(key) < tilelayers.size()) {
     tilelayerIndex = Character.getNumericValue(key);
   }

   // Multi-key detection
   if (keyCode == RIGHT) {
     right = true;
   }
   if (keyCode == LEFT) {
     left = true;
   }
   if (keyCode == UP) {
     up = true;
   }
   if (keyCode == DOWN) {
     down = true;
   }
   if (keyCode == SHIFT) {
     shift = true;
   }

   // Tile generation
   if (key == 'r' && !isSelecting) {
     // Looping through the main tiles
     if (tilelayerIndex == 1) {
       PImage[] grass = {images[0], images[1], images[2], images[3]};
       for (int i = 0; i < 24; i++) {
         for (int j = 0; j < 32; j++) {
           tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(grass[round(random(0, 3))]);
         }
       }
     // Looping through the decorative tiles
     } else if (tilelayerIndex >= 2) {
       for (int i = 0; i < 24; i++) {
         for (int j = 0; j < 32; j++) {
           PImage[] stone = {images[27], images[28], images[29], images[30], images[31]};
           if (random(0, 1) > 0.98f) {
             tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(stone[round(random(0, 4))]);
           }
           PImage[] flower = {images[22], images[23], images[24], images[25], images[26]};
           if (random(0, 1) > 0.95f) {
             tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(flower[round(random(0, 4))]);
           }
         }
       }
     }
   }

   // Layer erase
   if (key == 'e' && !isSelecting) {
     for (int i = 0; i < 24; i++) {
       for (int j = 0; j < 32; j++) {
         tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(nullImg);
       }
     }
   }

   // Layer fill
   if (key == 'f' && !isSelecting) {
     // Main tiles
     for (Tile t : tilelayers.get(tilelayerIndex).getTiles()) {
       t.setImg(paintImg);
     }
   }

   // Map export
   if (key == 10) {
     exportIntoFile();
     notifications.add(new Notification(not_imgs[0])); // Notification
   }

   // Map import
   if (key == 'i') {
     selectInput("Select a file to import:", "importFromFile");
   }

   // Camera offset reset
   if (key == 32) {
     xOffset = 0;
     yOffset = 0;
   }

   // 'ESC' handle
   if (key == 27) {

     // SELECTION
     if (!isSelecting) {
       key = 0;
     } else {
       key = 0;
       isSelecting = false;
       startSelect = null;
       endSelect = null;
     }

     // CREDIT SCREEN
     if (state == 2) {
       credits.setY(height);
       credits.setSpeed(0);
       credits.setVisible(false);
       state = 0;
     }
   }
 }

 public void keyReleased() {
   // Multi-key detection
   if (keyCode == UP) up = false;
   if (keyCode == DOWN) down = false;
   if (keyCode == LEFT) left = false;
   if (keyCode == RIGHT) right = false;
   if (keyCode == SHIFT) shift = false;
 }

 public void updateCameraControl() {
   if (up) yOffset += 1;
   if (down) yOffset -= 1;
   if (left) xOffset += 1;
   if (right) xOffset -= 1;
 }

/*
 * ---   MAP FUNCTIONS   ---
 */

// Map export function
public void exportIntoFile() {

  try {
    String docs = new JFileChooser().getFileSystemView().getDefaultDirectory().toString(); // Path to the 'Documents' directory
    String path = docs + "\\TilePainterMaps"; // Final path
    // -------------------------------------------------------------- //
    /*                     CREATING THE DIRECTORY                     */
    File folder = new File(path);
    if (!folder.exists()) folder.mkdir();
    // -------------------------------------------------------------- //
    /*                     COUNTING THE TEXTIFLES                     */
    int queueNum = folder.listFiles().length;
    // -------------------------------------------------------------- //
    String fileName = (currentMapID != "Untitled") ? currentMapID : "map_"+nf(queueNum, 4)+".map";
    BufferedWriter writer = new BufferedWriter(new FileWriter(path+"\\"+fileName, true)); // Writer
    // -------------------------------------------------------------- //
    /*                 DELETING THE CONTENT OF THE FILE               */
    RandomAccessFile raf = new RandomAccessFile(path+"\\"+fileName, "rw");
    raf.setLength(0);
    raf.close();
    raf = null;
    // -------------------------------------------------------------- //
    String tileNums = "";
    // Looping through the tilelayers
    for (int n = 1; n < tilelayers.size(); n++) {
      TileLayer tl = tilelayers.get(n);
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          tileNums += tl.getTiles().get(i*32+j).getImgCode();
        }
        writer.write(tileNums);
        writer.newLine();
        tileNums = "";
      }
      writer.write("-"); // Tilelayer break
      if (n != tilelayers.size()-1) writer.newLine(); // New Line
    }
    writer.close();
    currentMapID = fileName;

  } catch (IOException e) {
    println('e');
  }

}

// Map import function
public void importFromFile(File selection) {
  try {

    // Variables
    String line = "";
    int j = 0, tlCounter = 1;

    // Compatibility check (No import - null)
    if (selection == null) {
      return;
    }

    // Compatibility check (Text file)
    if (selection.getName().endsWith(".map") != true && selection.getName().endsWith(".txt") != true) { // If last element isn't 'txt'
      notifications.add(new Notification(not_imgs[1]));
      return;
    }

    // Compatibility check (Form)
    BufferedReader check = new BufferedReader(new FileReader(selection)); // Check Reader
    while ((line = check.readLine()) != null) {
      j++;
    }
    check.close();
    check = null;
    if (!(j <= 225)) { // If the number of lines isn't 225
      notifications.add(new Notification(not_imgs[2]));
      return;
    }

    // Actual import
    BufferedReader reader = new BufferedReader(new FileReader(selection)); // Reader
    // Reset variables
    line = "";
    j = 0;

    currentMapID = selection.getName();

    while ((line = reader.readLine()) != null) {
      if (!line.contains("-")) {
        char[] chars = line.toCharArray();
        // Go through the tilelayers
        for (int i = 0; i < chars.length; i++) {
          if (chars[i] >= 48) { // Images from 0 to images.length
            // Not correct form
            if ((int)chars[i]-48 >= images.length) {
              notifications.add(new Notification(not_imgs[3]));
              return;
            }
            tilelayers.get(tlCounter).getTiles().get(j*32+i).setImg(images[(int)chars[i]-48]);
          } else {
            tilelayers.get(tlCounter).getTiles().get(j*32+i).setImg(nullImg);
          }
        }
        j++;
      } else {
        tlCounter++;
        if (tlCounter == tilelayers.size()) tilelayers.add(new TileLayer(1, tilelayers.size()));
        j = 0;
      }
    }

    // Post-import actions
    tilelayers.remove(tilelayers.size()-1);
    currentMapID = selection.getName();
    reader.close();
    notifications.add(new Notification(not_imgs[3])); // Notifications
  } catch (IOException e) {
    println("ee");
  }
}

// Import from file via icon
public void importFromFileViaIcon(File selection) {
  importFromFile(selection);
  icons.get(3).setInAction(false); // Icon logical reset
  int temp = wheelNumber;
  wheelNumber = temp;
}

/*
 * ---   OTHER FUNCTIONS   ---
 */

 // Filter function
 public ArrayList<Button> getCurrentButtons(int currentState) {
   ArrayList<Button> returnVar = new ArrayList<Button>();
   for (Button b : buttons) {
     if (b.getStartState() == currentState) {
       returnVar.add(b);
     }
   }
   return returnVar;
 }
/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

// SUPERCLASS : ICON
abstract class Icon {

  // Variables
  protected PVector pos; // (In tile-system)
  protected PImage img;
  protected String name;
  protected boolean active, isClicked, hasBeenClicked, mouseOverIcon, inAction;
  protected float iconStartTime, iconElapsedTime;

  // Constructor
  Icon(PVector p, PImage i, boolean b, String s) {
    this.pos = p;
    this.img = i;
    this.active = b;
    this.name = s;
    this.isClicked = false;
    this.hasBeenClicked = false;
    this.mouseOverIcon = false;
    this.inAction = false;
    this.iconStartTime = 0;
    this.iconElapsedTime = 0;
  }

  // Functions
  public void render() {
    imageMode(CORNER);
    // Shade
    if (!mouseOverIcon && active) { // Normal
      tint(220);
    } else if (mouseOverIcon && active) { // Lighter
      tint(255);
    } else if (!active) { // Darker
      tint(30);
    }
    image(img, pos.x*TILESIZE, pos.y*TILESIZE); // Scale up to real-system
  }

  public void nameDisplay() {
    if (mouseOverIcon) {
      textSize(TILESIZE/2);
      PVector posRect = new PVector(pos.x*TILESIZE-TILESIZE-textWidth(name), mouseY);
      float boxw = textWidth(name)+TILESIZE/4, boxh = TILESIZE*0.6f;
      float offSet = TILESIZE/8;
      rectMode(CORNER);
      strokeWeight(3);
      stroke(0);
      fill(0, 60);
      rect(posRect.x, posRect.y, boxw, boxh);
      textAlign(LEFT);
      fill(0);
      text(name, posRect.x+offSet, posRect.y+TILESIZE/2);
    }
  }

  public void update() {
    if (mousePressed && active && (iconElapsedTime >= 300 || !hasBeenClicked) && mouseButton == LEFT && mouseX >= pos.x*TILESIZE && mouseX < (pos.x+1)*TILESIZE && mouseY >= pos.y*TILESIZE && mouseY < (pos.y+1)*TILESIZE) {
      iconStartTime = millis();
      isClicked = true;
      hasBeenClicked = true;
    } else {
      isClicked = false;
    }
    mouseOverIcon = (mouseX >= pos.x*TILESIZE && mouseX < (pos.x+1)*TILESIZE && mouseY >= pos.y*TILESIZE && mouseY < (pos.y+1)*TILESIZE) ? true : false;
    iconElapsedTime = millis() - iconStartTime;
  }

  // The method that the child'll override
  public abstract void action();

  // Getters
  public PVector getPos() {
    return pos;
  }

  public PImage getImg() {
    return img;
  }

  public boolean isClicked() {
    return isClicked;
  }

  public boolean isActive() {
    return active;
  }

  // Setters
  public void setActive(boolean b) {
    active = b;
  }

  public void setInAction(boolean b) {
    inAction = false;
  }

}

// CLASS : INFOICON
class InfoIcon extends Icon {

  // Constructor
  InfoIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  public @Override
  void render() {
    imageMode(CORNER);
    // Shade
    if ((mouseOverIcon && active) || isInfoVisible) { // Lighter
      if (mouseOverIcon && active && !isInfoVisible) tint(255); // Mouse over only
      if (mouseOverIcon && active && isInfoVisible) tint(0, 255, 0); // Purpose on, mouse over
      if (!mouseOverIcon && isInfoVisible) tint(0, 225, 0); // Purpose on only
    } else if (!mouseOverIcon && active) { // Normal
      tint(220);
    } else if (!active) { // Darker
      tint(30);
    }
    image(img, pos.x*TILESIZE, pos.y*TILESIZE); // Scale up to real-system
  }

  public @Override
  void action() {
    if (isClicked) {
      isInfoVisible = !isInfoVisible;
      if (!isInfoVisible) isDetailsVisible = false;
    }
  }
}

// CLASS : DETAILSICON
class DetailsIcon extends Icon {

  // Constructor
  DetailsIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  public @Override
  void render() {
    imageMode(CORNER);
    // Shade
    if ((mouseOverIcon && active) || isDetailsVisible) { // Lighter
      if (mouseOverIcon && active && !isDetailsVisible) tint(255); // Mouse over only
      if (mouseOverIcon && active && isDetailsVisible) tint(0, 255, 0); // Purpose on, mouse over
      if (!mouseOverIcon && isDetailsVisible) tint(0, 225, 0); // Purpose on only
    } else if (!mouseOverIcon && active) { // Normal
      tint(220);
    } else if (!active) { // Darker
      tint(30);
    }
    image(img, pos.x*TILESIZE, pos.y*TILESIZE); // Scale up to real-system
  }

  public @Override
  void action() {
    if (isClicked) {
      isDetailsVisible = !isDetailsVisible;
    }
    active = (isInfoVisible) ? true : false;
  }

}

// CLASS : SAVEICON
class SaveIcon extends Icon {

  // Constructor
  SaveIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  public @Override
  void action() {
    if (isClicked) {
      exportIntoFile();
      notifications.add(new Notification(not_imgs[0])); // Notification
    }
  }

}

// CLASS : OPENICON
class OpenIcon extends Icon {

  // Constructor
  OpenIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  public @Override
  void action() {
    if (isClicked && !inAction) {
      selectInput("Select a file to import:", "importFromFileViaIcon");
      inAction = true;
    }
  }

}

// CLASS : OPENICON
class RandomIcon extends Icon {

  // Constructor
  RandomIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  public @Override
  void action() {
    if (isClicked) {
      // Tile generation
      if (!isSelecting) {
        // Looping through the main tiles
        if (tilelayerIndex == 1) {
          PImage[] grass = {images[0], images[1], images[2], images[3]};
          for (int i = 0; i < 24; i++) {
            for (int j = 0; j < 32; j++) {
              tilelayers.get(1).getTiles().get(i*32+j).setImg(grass[round(random(0, 3))]);
            }
          }
        // Looping through the decorative tiles
        } else if (tilelayerIndex >= 2) {
          for (int i = 0; i < 24; i++) {
            for (int j = 0; j < 32; j++) {
              PImage[] stone = {images[27], images[28], images[29], images[30], images[31]};
              if (random(0, 1) > 0.98f) {
                tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(stone[round(random(0, 4))]);
              }
              PImage[] flower = {images[22], images[23], images[24], images[25], images[26]};
              if (random(0, 1) > 0.95f) {
                tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(flower[round(random(0, 4))]);
              }
            }
          }
        }
      }
    }
  }

}

// CLASS : LAYERICON
class LayerIcon extends Icon {

  // Variables
  private int modVal;

  // Constructor
  LayerIcon(PVector p, PImage i, boolean b, String s, int v) {
    super(p, i, b, s);
    this.modVal = v;
  }

  public @Override
  void action() {
    if (isClicked) {
      switch (modVal) {
        case -1:
          if (!(tilelayerIndex <= 2)) {
            tilelayers.remove(tilelayerIndex);
            tilelayerIndex = tilelayers.size()-1;
            for (int i = 1; i < tilelayers.size(); i++) {
              tilelayers.get(i).setIndex(i);
            }
          }
          break;
        case 1:
          if (tilelayers.size() != 10) {
            tilelayers.add(new TileLayer(1, tilelayers.size()));
          }
          break;
      }
    }
    active = ((!(tilelayerIndex <= 2) && modVal == -1) || (tilelayers.size() != 10 && modVal == 1)) ? true : false;
  }

}

// CLASS : EXITICON
class ExitIcon extends Icon {

  // Constructor
  ExitIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  public @Override
  void action() {
    if (isClicked) {
      if (currentMapID != "Untitled") exportIntoFile();
      state = 0;
      currentMapID = "Untitled";
      tilelayerIndex = 1;
      wheelNumber = 0;
      for (int i = tilelayers.size()-1; i >= 1; i--) {
        if (i > 2) {
          tilelayers.remove(i);
        } else {
          for (Tile t : tilelayers.get(i).getTiles()) {
            t.setImg(nullImg);
          }
        }
      }
    }
  }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TilePainter" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
