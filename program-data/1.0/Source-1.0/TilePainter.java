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
int tilelayerIndex = 1;
int wheelNumber = 0;

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

  public char getImgCode() {
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
  // Up-switch
  if (wheelNumber != 39 && -e.getCount() == 1) {
    wheelNumber += round(constrain(-e.getCount(), -39, 39));
  // Down-switch
  } else if (wheelNumber != 0 && -e.getCount() == -1) {
    wheelNumber += round(constrain(-e.getCount(), -39, 39));
  }

  // Palette tiles
  if (wheelNumber > TILESIZE) {
    for (int i = 0; i < tiles0.size(); i++) {
      if ((i+TILESIZE) >= images.length-1) {
        tiles0.get(i).setImg(nullImg);
      } else {
        tiles0.get(i).setImg(images[i+TILESIZE+1]);
      }
    }
  } else if (wheelNumber <= TILESIZE) {
    for (int i = 0; i <= TILESIZE; i++) {
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

  // Grass generation
  if (key == 'r') {
    // Looping through the main tiles
    if (tilelayerIndex == 1) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          PImage[] array = {images[0], images[1], images[2], images[3]};
          tiles1.get(i*32+j).setImg(array[round(random(0, 3))]);
        }
      }
    } else if (tilelayerIndex == 2) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          PImage[] array = {images[27], images[28], images[29], images[30], images[31]};
          if (random(0, 1) > 0.98f) {
            tiles2.get(i*32+j).setImg(array[round(random(0, 4))]);
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
    if (tilelayerIndex == 2) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 32; j++) {
          tiles2.get(i*32+j).setImg(nullImg);
        }
      }
    }
  }

  // Map export
  if (key == 10) {
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

  // Mousewheel-selected tile
  rectMode(CORNER);
  strokeWeight(3);
  noFill();
  stroke(255);
  if (wheelNumber < TILESIZE+1) {
    rect(wheelNumber*TILESIZE, 0, TILESIZE, TILESIZE);
  } else {
    rect((wheelNumber-TILESIZE-1)*TILESIZE, 0, TILESIZE, TILESIZE);
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
    writer.write("-"); // TileMap break
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TilePainter" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
