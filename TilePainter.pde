/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

import java.awt.Dimension;
import java.awt.Toolkit;
import javax.swing.JFileChooser;
import java.io.*;

// Screen optimization
Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
double w = screenSize.getWidth()/1.275;
double h = screenSize.getHeight()/1.275;
int post_w = (int) w;
int post_h = (int) h;

// Program Variables
int state = -1;
ArrayList<Notification> notifications = new ArrayList<Notification>();
float startTime = millis();
float elapsedTime = millis() - startTime;
String currentMapID = "Untitled";
PFont font;

// Tilesize and post screen optimization
final int TILESIZE = (post_w/33+post_h/25)/2;
int width = int(TILESIZE*33);
int height = int(TILESIZE*25);

// Tiles
ArrayList<Tile> tiles0 = new ArrayList<Tile>(); // Palette tiles [Always active]
ArrayList<Tile> tiles1 = new ArrayList<Tile>(); // Main tiles [tilelayerIndex:1]
ArrayList<Tile> tiles2 = new ArrayList<Tile>(); // Decorative tiles [tilelayerIndex:2]

// Images
PImage[] not_imgs = new PImage[4];
PImage[] ico_imgs = new PImage[5];
PImage[] images= new PImage[55];
PImage paintImg, nullImg, animation, homescreen;

// Painting variables
int tilelayerIndex = 1;
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
void settings() {
  size(width, height);
}

// Setup
void setup() {

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
  for (int i = 1; i <= 5; i++) {
    ico_imgs[i-1] = loadImage("icon_"+Integer.toString(i)+".png");
    ico_imgs[i-1].resize(TILESIZE, TILESIZE);
  }
  paintImg = images[0]; // Paint Image
  nullImg = loadImage("nullimg.png"); // Empty Image
  animation = loadImage("company.png"); // Animation Image
  animation.resize(width, height);
  homescreen = loadImage("homescreen.png");
  homescreen.resize(width, height);

  // Setup : Tile Layers
  // -> Palette Tiles
  for (int x = 0; x < 32; x++) {
    tiles0.add(new Tile(
      new PVector(x, 0),
      images[x],
      true));
  }
  // -> Main Tiles
  for (int y = 1; y < 25; y++) {
    for (int x = 0; x < 32; x++) {
      tiles1.add(new Tile(
        new PVector(x, y),
        nullImg,
        false));
    }
  }
  // -> Decorative Tiles
  for (int y = 1; y < 25; y++) {
    for (int x = 0; x < 32; x++) {
      tiles2.add(new Tile(
        new PVector(x, y),
        nullImg,
        false));
    }
  }

  // Setup : Fonts
  font = loadFont("OCRAStd-32.vlw");
  textFont(font);

  // Setup : Icons
  icons.add(new InfoIcon(
    new PVector(32, 0),
    ico_imgs[0],
    true));
  icons.add(new DetailsIcon(
    new PVector(32, 1),
    ico_imgs[1],
    true));
  icons.add(new SaveIcon(
    new PVector(32, 2),
    ico_imgs[2],
    true));
  icons.add(new OpenIcon(
    new PVector(32, 3),
    ico_imgs[3],
    true));
  icons.add(new RandomIcon(
    new PVector(32, 4),
    ico_imgs[4],
    true));

  // Setup : Buttons
  // >>> State 1 - Main Menu <<< //
  // 'New' button
  buttons.add(new Button(
    new PVector(12, 11),
    "New Project",
    0,
    1
    ));
}

// Main loop
void draw() {

  // Background and grid
  background(100);

  // Startup
  if (state == -1) {

    // Logo animation
    if ((elapsedTime = millis() - startTime) < 1000) { // 1s delay
      imageMode(CENTER);
      image(animation, width/2, height/2);
    } else {
      state = 0;
    }

  // Main menu
  } else if (state == 0) {

    /* Buttons
    for (Button b : getCurrentButtons(0)) {
      b.render();
      b.mousePressed();
    }*/
    buttons.get(0).render();
    buttons.get(0).mousePressed();

  // Program
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

    // Looping through the arraylists
    for (int i = 0; i < tiles1.size(); i++) {
      // -> Main tiles
      if (tilelayerIndex == 1) tiles1.get(i).mousePressed();
      tiles1.get(i).render();
      // -> Decorative tiles
      if (tilelayerIndex == 2) tiles2.get(i).mousePressed();
      tiles2.get(i).render();
    }
    // Box to hide lower layers (preventing the palette tiles to render right over other tile layers)
    rectMode(CORNER);
    noStroke();
    fill(100);
    rect(0, 0, width, TILESIZE);
    for (Tile t : tiles0) { // -> Palette Tiles
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
      drawSelectionBox();
      displayInfo();
    }

    // Icons
    for (Icon i : icons) {
      i.update();
      i.render();
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

  }
}
