/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

// Tile Selection by mousewheel
void mouseWheel(MouseEvent e) {
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
void keyPressed() {

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
          if (random(0, 1) > 0.98) {
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
