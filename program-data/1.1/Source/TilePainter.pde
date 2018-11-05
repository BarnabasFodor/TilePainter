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
double w = screenSize.getWidth() / 1.875;
double h = screenSize.getHeight() / 1.35;
int post_w = (int) w;
int post_h = (int) h;

// Program Variables
int state = -1;
ArrayList<Notification> notifications = new ArrayList<Notification>();
float startTime = millis();
float elapsedTime = millis() - startTime;

// Tilesize and post screen optimization
final int TILESIZE = (post_w/32+post_h/25)/2;
int width = int(TILESIZE*32);
int height = int(TILESIZE*25);

// Tiles
ArrayList<Tile> tiles0 = new ArrayList<Tile>(); // Palette tiles [Always active]
ArrayList<Tile> tiles1 = new ArrayList<Tile>(); // Main tiles [tilelayerIndex:1]
ArrayList<Tile> tiles2 = new ArrayList<Tile>(); // Decorative tiles [tilelayerIndex:2]

// Painting variables
PImage paintImg, nullImg, animation;
PImage[] images = new PImage[40];
PImage[] not_imgs = new PImage[4];
int tilelayerIndex = 1;
int wheelNumber = 0;
float sTime, eTime;
boolean cursorOverNotification = false;
boolean shouldReset = false;

// Screen setup
void settings() {
  size(width, height);
}

// Setup
void setup() {

  // Setup : Images
  for (int i = 1; i <= 40; i++) {
    images[i-1] = loadImage("tile_"+Integer.toString(i)+".png");
    images[i-1].resize(TILESIZE, TILESIZE);
  }
  for (int i = 1; i <= 4; i++) {
    not_imgs[i-1] = loadImage("not_"+Integer.toString(i)+".png");
  }
  paintImg = images[0]; // Paint Image
  nullImg = loadImage("nullimg.png"); // Empty Image
  animation = loadImage("company.png"); // Animation Image
  animation.resize(width, height);

  // Setup : Tile Layers
  // -> Palette Tiles
  for (int x = 0; x < 32; x++) {
    tiles0.add(new Tile(new PVector(x, 0), images[x], true));
  }
  // -> Main Tiles
  for (int y = 1; y < 25; y++) {
    for (int x = 0; x < 32; x++) {
      tiles1.add(new Tile(new PVector(x, y), nullImg, false));
    }
  }
  // -> Decorative Tiles
  for (int y = 1; y < 25; y++) {
    for (int x = 0; x < 32; x++) {
      tiles2.add(new Tile(new PVector(x, y), nullImg, false));
    }
  }
}

// Main loop
void draw() {

  // Background and grid
  background(100);

  if (state == -1) {

    // Logo animation
    if ((elapsedTime = millis() - startTime) < 1000) { // 6s delay
      imageMode(CENTER);
      image(animation, width/2, height/2);
    } else {
      state = 0;
    }

  } else if (state == 0) {

    // Notifications (Logical operations)
    for (int i = notifications.size()-1; i >= 0; i--) {
      Notification n = notifications.get(i);
      n.move();
      if (n.isClicked()) {
        n.setClicked(true);
        shouldReset = true;
      }
      if (n.getPos().x < -260) {
        notifications.remove(n);
      }
    }

    // Looping through the arraylists
    for (Tile t : tiles0) { // -> Palette Tiles
      t.mousePressed();
      t.render();
    }
    for (Tile t : tiles1) { // -> Main Tiles
      if (tilelayerIndex == 1) t.mousePressed();
      t.render();
    }
    for (Tile t : tiles2) { // -> Decorative Tiles
      if (tilelayerIndex == 2) t.mousePressed();
      t.render();
    }

    // Tilelayer Index text and Grid draw
    if (keyPressed && key == 't') {
      saveFrame("Screenshot-####.png");
    } else {
      drawGrid();
      textAlign(CENTER);
      textSize(TILESIZE);
      fill(0);
      text("Layer: "+tilelayerIndex+" | Tile: "+(wheelNumber+1), width/2, height-(2*TILESIZE));
    }

    // Notifications (Graphical operations)
    for (Notification n : notifications) {
      n.render();
    }

    // Boolean reset (cursorOverNotification)
    if (shouldReset == true) {
      cursorOverNotification = false;
      sTime = millis();
      shouldReset = false;
    }
    eTime = millis()-sTime; // Time limit
  }
}
