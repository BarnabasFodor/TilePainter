/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

/*
 * ---   MOUSE INPUT   ---
 */

// Tile Selection by mousewheel
void mouseWheel(MouseEvent e) {
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

/*
 * ---   PAINTING FUNCTIONS   ---
 */

// Selection brush
void selectionFill() {

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
    for (int y = int(sPos.y); y <= int(ePos.y); y++) {
      for (int x = int(sPos.x); x <= int(ePos.x); x++) {
        if (tilelayerIndex == 1) tiles1.get((y-1)*32+x).setImg(paintImg); // -> Main Tiles
        if (tilelayerIndex == 2) tiles2.get((y-1)*32+x).setImg(paintImg); // -> Decorative Tiles
      }
    }

    // Reset variables
    sTime = millis();
    eTime = 0;
    isSelecting = false;

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
    for (int y = int(sPos.y); y <= int(ePos.y); y++) {
     for (int x = int(sPos.x); x <= int(ePos.x); x++) {
       if (tilelayerIndex == 1) tiles1.get((y-1)*32+x).setImg(nullImg); // -> Main Tiles
       if (tilelayerIndex == 2) tiles2.get((y-1)*32+x).setImg(nullImg); // -> Decorative Tiles
     }
    }

    // Reset variables
    sTime = millis();
    eTime = 0;
    isSelecting = false;

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
    for (int y = int(sPos.y); y <= int(ePos.y); y++) {
      for (int x = int(sPos.x); x <= int(ePos.x); x++) {
        if (tilelayerIndex == 1) {
          tiles1.get((y-1)*32+x).setImg(grass[round(random(0, 3))]);
        }
        if (tilelayerIndex == 2) {
          if (random(0, 1) > 0.98) {
            tiles2.get((y-1)*32+x).setImg(stone[round(random(0, 4))]);
          }
          if (random(0, 1) > 0.95) {
            tiles2.get((y-1)*32+x).setImg(flower[round(random(0, 4))]);
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
void captureScreen() {
  PImage screenShot = get(0, TILESIZE, 31*TILESIZE, 25*TILESIZE);
  screenShot.save("screenshot_"+month()+"-"+day()+"-"+year()+"--"+hour()+"-"+minute()+"-"+second()+".png");
  println("Saved as "+"screenshot_"+month()+"-"+day()+"-"+year()+"--"+hour()+"-"+minute()+"-"+second()+".png"+"!");
}

void displayInfo() {
  // Information text
  if (isInfoVisible) {
    textAlign(CENTER);
    textSize(TILESIZE);
    fill(0);
    if (wheelNumber+1 > 9) {
      text("Layer: "+tilelayerIndex+" | Tile: "+(wheelNumber+1), width/2, height-TILESIZE);
    } else {
      text("Layer: "+tilelayerIndex+" | Tile: 0"+(wheelNumber+1), width/2, height-TILESIZE);
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

  // Details text
  if (isDetailsVisible) {
    PVector pos = new PVector(26*TILESIZE, TILESIZE);
    float boxw = 6*TILESIZE-1.5, boxh = 4.5*TILESIZE;
    float offSet = TILESIZE/8;
    String brushMode = (isSelecting) ? "SELECT" : "PAINT";
    strokeWeight(3);
    stroke(255);
    rectMode(CORNER);
    fill(120, 60);
    rect(pos.x, pos.y, boxw, boxh);
    textAlign(LEFT);
    textSize(TILESIZE/2);
    fill(255);
    text("|Project:\n\n|Brush mode:\n\n|Camera offset:", pos.x+offSet, pos.y+TILESIZE);
    text("\n "+currentMapID+"\n\n "+brushMode+"\n\n {"+nf(-yOffset, 2)+","+nf(-xOffset, 2)+"}\n\n ", pos.x+offSet, pos.y+TILESIZE);
  }
}

// Selection box function
void drawSelectionBox() {

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
void drawGrid() {

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
  line(0, TILESIZE, 32*TILESIZE-1.5, TILESIZE); // HORIZONTAL
  line(32*TILESIZE-1.5, 0, 32*TILESIZE-1.5, height); // VERTICAL

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
void cornerDraw() {
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
 void keyPressed() {

   // Tilelayer change
   if (key == '1') {
     tilelayerIndex = 1;
   } else if (key == '2') {
     tilelayerIndex = 2;
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
           tiles1.get(i*32+j).setImg(grass[round(random(0, 3))]);
         }
       }
     // Looping through the decorative tiles
     } else if (tilelayerIndex == 2) {
       for (int i = 0; i < 24; i++) {
         for (int j = 0; j < 32; j++) {
           PImage[] stone = {images[27], images[28], images[29], images[30], images[31]};
           if (random(0, 1) > 0.98) {
             tiles2.get(i*32+j).setImg(stone[round(random(0, 4))]);
           }
           PImage[] flower = {images[22], images[23], images[24], images[25], images[26]};
           if (random(0, 1) > 0.95) {
             tiles2.get(i*32+j).setImg(flower[round(random(0, 4))]);
           }
         }
       }
     }
   }

   // Layer erase
   if (key == 'e' && !isSelecting) {
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
   if (key == 'f' && !isSelecting) {
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

   // Camera offset reset
   if (key == 32) {
     xOffset = 0;
     yOffset = 0;
   }

   // 'ESC' handle
   if (key == 27) {
     if (!isSelecting) {
       key = 0;
     } else {
       key = 0;
       isSelecting = false;
       startSelect = null;
       endSelect = null;
     }
   }
 }

 void keyReleased() {
   // Multi-key detection
   if (keyCode == UP) up = false;
   if (keyCode == DOWN) down = false;
   if (keyCode == LEFT) left = false;
   if (keyCode == RIGHT) right = false;
   if (keyCode == SHIFT) shift = false;
 }

 void updateCameraControl() {
   if (up) yOffset += 1;
   if (down) yOffset -= 1;
   if (left) xOffset += 1;
   if (right) xOffset -= 1;
 }

/*
 * ---   MAP FUNCTIONS   ---
 */

// Map export function
void exportIntoFile() {

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
    String fileName = (currentMapID != "Untitled") ? currentMapID : "map_"+nf(queueNum, 4)+".txt";
    BufferedWriter writer = new BufferedWriter(new FileWriter(path+"\\"+fileName, true)); // Writer
    // -------------------------------------------------------------- //
    /*                 DELETING THE CONTENT OF THE FILE               */
    RandomAccessFile raf = new RandomAccessFile(path+"\\"+fileName, "rw");
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
    currentMapID = fileName;

  } catch (IOException e) {
    println('e');
  }

}

// Map import function
void importFromFile(File selection) {
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
    currentMapID = selection.getName();
    reader.close();
    notifications.add(new Notification(not_imgs[3])); // Notifications
  } catch (IOException e) {
    println('e');
  }
}

// Import from file via icon
void importFromFileViaIcon(File selection) {
  importFromFile(selection);
  icons.get(3).setInAction(false); // Icon logical reset
  int temp = wheelNumber;
  wheelNumber = temp;
}

/*
 * ---   OTHER FUNCTIONS   ---
 */

 // Filter function
 ArrayList<Button> getCurrentButtons(int currentState) {
   ArrayList<Button> returnVar = new ArrayList<Button>();
   for (Button b : buttons) {
     if (b.getStartState() == currentState) {
       returnVar.add(b);
     }
   }
   return returnVar;
 }
