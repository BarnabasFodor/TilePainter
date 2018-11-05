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
double w = screenSize.getWidth() / 1.875f;
double h = screenSize.getHeight() / 1.35f;
int post_w = (int) w;
int post_h = (int) h;

// Program Variables
int state = -1;
ArrayList<Notification> notifications = new ArrayList<Notification>();
float startTime = millis();
float elapsedTime = millis() - startTime;

// Tilesize and post screen optimization
final int TILESIZE = (post_w/32+post_h/25)/2;
int width = PApplet.parseInt(TILESIZE*32);
int height = PApplet.parseInt(TILESIZE*25);

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
public void settings() {
  size(width, height);
}

// Setup
public void setup() {

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
public void draw() {

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
/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

class Notification {

  // Variables
  private PVector pos, targetPos;
  private float speed;
  private boolean clicked;
  private PImage img;

  // Constructor
  Notification(PImage i) {
    this.pos = new PVector(-256, height-100*(notifications.size()+1));
    this.targetPos = new PVector(0, height-100*(notifications.size()+1));
    this.speed = 16;
    this.img = i;
    this.clicked = false;
  }

  // Functions

  public void render() {
    imageMode(CORNER);
    image(img, pos.x, pos.y);
  }

  public void move() {
    // Horizontal movement
    if (!(pos.x >= targetPos.x) && !clicked) {
      pos.x += speed;
    }
    // Vertical movement (Only after horizontal movement is done)
    if ((pos.x >= targetPos.x) && !(pos.y >= targetPos.y) && !clicked) {
      pos.y += speed;
    }
    // Clicked refresh
    if (clicked) {
      pos.x -= speed;
    }
  }

  public boolean isClicked() {
    if (mousePressed && mouseX >= pos.x && mouseX <= pos.x+256 && mouseY >= pos.y && mouseY <= pos.y+90) {
      cursorOverNotification = true;
      return true;
    } else if (mouseX >= pos.x && mouseX <= pos.x+256 && mouseY >= pos.y && mouseY <= pos.y+90) {
      cursorOverNotification = true;
      return false;
    } else {
      return false;
    }
  }

  // Getters and Setters
  public PVector getPos() {
    return pos;
  }

  public void setClicked(boolean b) {
    clicked = b;
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
    image(img, (pos.x*TILESIZE), (pos.y*TILESIZE));
  }

  public void mousePressed() {
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
/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
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
  }

  // Palette tiles
  if (wheelNumber > 31) {
    for (int i = 0; i < tiles0.size(); i++) {
      if ((i+31) >= max) {
        tiles0.get(i).setImg(nullImg);
      } else {
        tiles0.get(i).setImg(images[i+32]);
      }
    }
  } else if (wheelNumber <= 31) {
    for (int i = 0; i < 32; i++) {
      tiles0.get(i).setImg(images[i]);
    }
  }

  paintImg = images[wheelNumber];
}

// Certain keyboard inputs
public void keyPressed() {

  // Tilelayer change
  if (key == '1') {
    tilelayerIndex = 1;
  } else if (key == '2') {
    tilelayerIndex = 2;
  }

  // Tile generation
  if (key == 'r') {
    // Looping through the main tiles
    if (tilelayerIndex == 1) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          PImage[] grass = {images[0], images[1], images[2], images[3]};
          tiles1.get(i*32+j).setImg(grass[round(random(0, 3))]);
        }
      }
    // Looping through the decorative tiles
    } else if (tilelayerIndex == 2) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          PImage[] stone = {images[27], images[28], images[29], images[30], images[31]};
          if (random(0, 1) > 0.98f) {
            tiles2.get(i*32+j).setImg(stone[round(random(0, 4))]);
          }
          PImage[] flower = {images[22], images[23], images[24], images[25], images[26]};
          if (random(0, 1) > 0.95f) {
            tiles2.get(i*32+j).setImg(flower[round(random(0, 4))]);
          }
        }
      }
    }
  }

  // Layer erase
  if (key == 'e') {
    // Main tiles
    if (tilelayerIndex == 1) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          tiles1.get(i*32+j).setImg(nullImg);
        }
      }
    }
    // Decorative tiles
    if (tilelayerIndex == 2) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          tiles2.get(i*32+j).setImg(nullImg);
        }
      }
    }
  }

  // Layer fill
  if (key == 'f') {
    // Main tiles
    if (tilelayerIndex == 1) {
      for (Tile t : tiles1) {
        t.setImg(paintImg);
      }
    }
    // Decorative tiles
    if (tilelayerIndex == 2) {
      for (Tile t : tiles2) {
        t.setImg(paintImg);
      }
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

  // Exit
  if (key == 27) {
    key = 0;
    exportIntoFile();
    exit();
  }
}

// Grid draw function
public void drawGrid() {

  // Grid
  stroke(140);
  strokeWeight(1);
  for (int y = 0; y < height; y += TILESIZE) {
    for (int x = 0; x < width; x += TILESIZE) {
      line(x, 0, x, height); // Vertical lines
    }
    line(0, y, width, y); // Horizontal lines
  }

  // Separator
  strokeWeight(3);
  stroke(0);
  line(0, TILESIZE, width, TILESIZE);

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
    BufferedWriter writer = new BufferedWriter(new FileWriter(path+"\\map.txt", true)); // Writer
    // -------------------------------------------------------------- //
    /*                 DELETING THE CONTENT OF THE FILE               */
    RandomAccessFile raf = new RandomAccessFile(path+"\\map.txt", "rw");
    raf.setLength(0);
    raf.close();
    raf = null;
    // -------------------------------------------------------------- //
    String tileNums = "";
    // Looping through the arraylists
    for (int i = 0; i < 24; i++) { // -> Main Tiles
      for (int j = 0; j < 32; j++) {
        tileNums += tiles1.get(i*32+j).getImgCode();
      }
      writer.write(tileNums);
      writer.newLine();
      tileNums = "";
    }
    writer.write("-"); // Tilelayer break
    writer.newLine(); // New Line
    for (int i = 0; i < 24; i++) { // -> Decorative Tiles
      for (int j = 0; j < 32; j++) {
        tileNums += tiles2.get(i*32+j).getImgCode();
      }
      writer.write(tileNums);
      writer.newLine();
      tileNums = "";
    }
    writer.close();

  } catch (IOException e) {
    println('e');
  }

}

// Map import function
public void importFromFile(File selection) {
  try {

    // Variables
    String line = "";
    int j = 0;

    // Compatibility check (No import - null)
    if (selection == null) {
      return;
    }

    // Compatibility check (Text file)
    if (selection.getName().endsWith(".txt") != true) { // If last element isn't 'txt'
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
    if (j != 49) { // If the number of lines isn't 49
      notifications.add(new Notification(not_imgs[2]));
      return;
    }

    // Actual import
    BufferedReader reader = new BufferedReader(new FileReader(selection)); // Reader
    // Reset variables
    line = "";
    j = 0;

    while ((line = reader.readLine()) != null) {
      if (line != "-") {
        char[] chars = line.toCharArray();
        if (j < 24) { // -> Main Tiles
          for (int i = 0; i < chars.length; i++) {
            if (chars[i] >= 48) { // Images from 0 to images.length
              if ((int)chars[i]-48 >= images.length) {
                notifications.add(new Notification(not_imgs[3]));
                return;
              }
              tiles1.get(j*32+i).setImg(images[(int)chars[i]-48]);
            } else {
              tiles1.get(j*32+i).setImg(nullImg);
            }
          }
        } else if (j > 24) { // -> Decorative Tiles
          for (int i = 0; i < chars.length; i++) {
            if (chars[i] >= 48) { // Images from 0 to images.lenght
              if ((int)chars[i]-48 >= images.length) {
                notifications.add(new Notification(not_imgs[3]));
                return;
              }
              tiles2.get((j-25)*32+i).setImg(images[(int)chars[i]-48]);
            } else {
              tiles2.get((j-25)*32+i).setImg(nullImg);
            }
          }
        }
      }
      j++;
    }
    reader.close();
    notifications.add(new Notification(not_imgs[3])); // Notifications
  } catch (IOException e) {
    println('e');
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
