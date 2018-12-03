/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;
import javax.swing.JFileChooser;
import java.io.*;

// Screen optimization
Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
double w = screenSize.getWidth()/1.275;
double h = screenSize.getHeight()/1.275;
int post_w = (int) w;
int post_h = (int) h;

// Program Variables
String VERSION = "1.3.2";
int state = -1;
ArrayList<Notification> notifications = new ArrayList<Notification>();
float startTime = millis();
float elapsedTime = millis() - startTime;
String currentMapID = "Untitled";
boolean cursorActive = false, fitsScreen = true;
Credits credits = new Credits();
PFont font;

// Tilesize and post screen optimization
int TILESIZE = (post_w/33+post_h/25)/2;
PImage artView;
int width   = int(TILESIZE*33);
int height  = int(TILESIZE*25);

// Tiles
ArrayList<TileLayer> tilelayers = new ArrayList<TileLayer>(); // Tilelayer arraylist
int tilelayerIndex = 1;
int tilelayerWidth = 32, tilelayerHeight = 24;

// Images
PImage[] not_imgs = new PImage[4];
PImage[] ico_imgs = new PImage[9];
PImage[] images   = new PImage[55];
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

// Icons
ArrayList<Icon> icons = new ArrayList<Icon>();
boolean isInfoVisible     = true;
boolean isDetailsVisible  = false;

// Buttons
ArrayList<Button> buttons = new ArrayList<Button>();

// Settings
void settings() {
  size(width, height);
}

// Setup
void setup() {

  // Setup : Window
  surface.setLocation((int)screenSize.getWidth()/2-width/2, 0);
  changeAppIconAndTitle(loadImage("appicon.png"), "TilePainter v"+VERSION);

  // Setup : Images
  for (int i = 1; i <= 55; i++) {
    images[i-1] = loadImage("tile_"+Integer.toString(i)+".png");
    images[i-1].resize(TILESIZE, TILESIZE);
  }
  for (int i = 1; i <= 4; i++) {
    not_imgs[i-1] = loadImage("not_"+Integer.toString(i)+".png");
  }
  for (int i = 1; i <= 9; i++) {
    ico_imgs[i-1] = loadImage("icon_"+Integer.toString(i)+".png");
    ico_imgs[i-1].resize(TILESIZE, TILESIZE);
  }
  paintImg = images[0];
  nullImg       = loadImage("nullimg.png");
  animation     = loadImage("company.png");
  homescreen    = loadImage("homescreen.png");
  creditsscreen = loadImage("creditsscreen.png");
  animation.resize(width, height);
  homescreen.resize(width, height);
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
  icons.add(new ButtonIcon(
    new PVector(32, 7),
    ico_imgs[8],
    true,
    "View art",
    4
    ));
  icons.add(new ExitIcon(
    new PVector(32, 24),
    ico_imgs[7],
    true,
    "Main Menu"
    ));

  // Setup : Buttons
  // >>> State 1 - Main Menu <<< //

  // 'New Project' button
  buttons.add(new StateButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE),
    "New Project",
    0,
    3
    ));
  // 'Credits' button
  buttons.add(new StateButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+1.2),
    "Credits",
    0,
    2
    ));
  // 'Quit' button
  buttons.add(new StateButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+2.4),
    "Quit",
    0,
    -2
    ));

  // 32x24 button
  buttons.add(new SizeButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE),
    "32x24",
    3,
    32,
    24
    ));
  // 32x32 button
  buttons.add(new SizeButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+1.2),
    "32x32",
    3,
    32,
    32
    ));
  // 64x32 button
  buttons.add(new SizeButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+2.4),
    "64x32",
    3,
    64,
    32
    ));
  // 64x32 button
  buttons.add(new SizeButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+3.6),
    "64x48",
    3,
    64,
    48
    ));
  // 64x64 button
  buttons.add(new SizeButton(
    new PVector(width/2/TILESIZE, height/2/TILESIZE+4.8),
    "64x64",
    3,
    64,
    64
    ));
}

// Draw
void draw() {

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

    eTime = millis()-sTime; // Time limit

  // PROGRAM
  } else if (state == 1) {

    // Resize art to fit in the screen (Logical operations)
    if (!fitsScreen) {
      makeMapFitScreen(0);
      fitsScreen = true;
    }

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

    // Map highlight
    if (xOffset != 0 || yOffset != 0) {
      cornerDraw();
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
    drawGrid();
    displayInfo();
    drawSelectionBox();

    // Box to hide lower layers (preventing the icons to render over anything else)
    rectMode(CORNER);
    noStroke();
    fill(100);
    rect(width-TILESIZE, 0, width, height);

    // Icons
    for (Icon i : icons) {
      i.update();
      i.render();
      i.nameDisplay();
      i.action();
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

  // PROJECT CUSTOMIZATION PAGE
  } else if (state == 3) {

    // Background
    imageMode(CORNER);
    image(homescreen, 0, 0, width, height);

    // Text
    textAlign(CENTER);
    textSize(TILESIZE*0.8);
    fill(0);
    text("Choose project size:", width/2, height/2-TILESIZE*1.8);

    // Buttons
    for (Button b : getCurrentButtons(3)) {
      b.mousePressed();
      b.render();
    }

    eTime = millis()-sTime; // Time limit

  // ART-VIEWER
  } else if (state == 4) {

    // Resize art to fit in the screen (Logical operations)
    if (!fitsScreen) {
      makeMapFitScreen(1);
      fitsScreen = true;
    }

    // Rendering the art-view image (what the function above created)
    imageMode(CENTER);
    image(artView, width/2, height/2);

    // Screenshot
    if (keyPressed && keyCode == KeyEvent.VK_F12) {
      xOffset = 0;
      yOffset = 0;
      captureScreen(artView);
    } else {
      int x = (post_w/33+post_h/25)/2;
      textAlign(CENTER);
      textSize(x);
      noStroke();
      fill(0, 255, 0);
      rectMode(CORNER);
      rect(width/2-textWidth("ES"), height-3*x, textWidth("ESC"), x+x/5);
      rect(width/2+textWidth("OR   "), height-3*x, textWidth("F12"), x+x/5);
      fill(0);
      text("PRESS ESC OR F12", width/2, height-2*x);
    }
  }

  // Cursor
  if (cursorActive) {
    surface.setCursor(12);
    cursorActive = false;
  } else {
    surface.setCursor(0);
  }
}
