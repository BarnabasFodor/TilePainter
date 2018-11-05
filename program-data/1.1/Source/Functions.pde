/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
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
void keyPressed() {

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
void drawGrid() {

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
void exportIntoFile() {

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
    reader.close();
    notifications.add(new Notification(not_imgs[3])); // Notifications
  } catch (IOException e) {
    println('e');
  }
}
