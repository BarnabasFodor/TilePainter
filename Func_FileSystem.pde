/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

/*
 * ---   FILESYSTEM   ---
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
      for (int i = 0; i < tilelayerHeight; i++) {
        for (int j = 0; j < tilelayerWidth; j++) {
          tileNums += tl.getTiles().get(i*tilelayerWidth+j).getImgCode();
        }
        writer.write(tileNums);
        writer.newLine();
        tileNums = "";
      }
      if (n != tilelayers.size()-1) { writer.write("-"); } else { writer.write("--"); } // Break
      writer.newLine(); // New Line
    }
    // Looping through the colliders
    for (int i = 0; i < tilelayerHeight; i++) {
      for (int j = 0; j < tilelayerWidth; j++) {
        tileNums += colliders.get(i*tilelayerWidth+j).getCode();
      }
      writer.write(tileNums);
      if (i != tilelayerHeight-1) writer.newLine();
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
    boolean hasColliderLayer = false;
    int j = 0, tlCounter = 0;
    int tlW = 0;

    // Compatibility check (No import - null)
    if (selection == null) {
      return;
    }

    // Compatibility check (Text file)
    if (!selection.getName().endsWith(".map") && !selection.getName().endsWith(".txt")) { // If last element isn't '.txt' or '.map'
      notifications.add(new Notification(not_imgs[1]));
      return;
    }

    // Compatibility check (Form)
    BufferedReader check = new BufferedReader(new FileReader(selection)); // Check Reader
    while ((line = check.readLine()) != null) {
      // Tilelayer-width define
      tlW = (line.toCharArray().length > tlW) ? line.toCharArray().length : tlW;
      // Counting lines
      if (!line.contains("-")) {
        j++;
      } else if (line.trim().equals("-")) {
        tlCounter++;
      } else if (line.trim().equals("--")) {
        hasColliderLayer = true;
      }
    }
    check.close();
    check = null;
    // Check for requirements
    if (tlCounter > 9) {
      notifications.add(new Notification(not_imgs[2]));
      return;
    } else if (tlCounter == 0) {
      notifications.add(new Notification(not_imgs[2]));
      return;
    } else if (!hasColliderLayer) {
      notifications.add(new Notification(not_imgs[2]));
      return;
    }

    // Pre-import actions
    // Set the values of tilelayer-width and tilelayer-height
    tilelayerWidth = tlW;
    tilelayerHeight = j / tlCounter;
    resizeMap();
    xOffset = 0;
    yOffset = 0;

    // Actual import
    BufferedReader reader = new BufferedReader(new FileReader(selection)); // Reader
    // Reset variables
    line = "";
    j = 0;
    tlCounter = 1;
    hasColliderLayer = false;

    currentMapID = selection.getName();

    while ((line = reader.readLine()) != null) {
      if (!line.contains("-")) {
        char[] chars = line.toCharArray();
        // Tilelayer load
        if (!hasColliderLayer) {
          // Go through the tilelayers
          for (int i = 0; i < chars.length; i++) {
            if (chars[i] >= 48) { // Images from 0 to images.length
              // Not correct form
              if ((int)chars[i]-48 >= images.length) {
                notifications.add(new Notification(not_imgs[3]));
                return;
              }
              tilelayers.get(tlCounter).getTiles().get(j*tilelayerWidth+i).setImg(images[(int)chars[i]-48]);
            } else {
              tilelayers.get(tlCounter).getTiles().get(j*tilelayerWidth+i).setImg(nullImg);
            }
          }
        // Collider load
        } else if (hasColliderLayer) {
          // Go through the colliders
          for (int i = 0; i < chars.length; i++) {
            if (chars[i] != '0' && chars[i] != '1') {
              notifications.add(new Notification(not_imgs[3]));
              println("Failed collider!");
              return;
            }
            switch (chars[i]) {
              case '0':
              colliders.get(j*tilelayerWidth+i).setActive(false);
              break;
              case '1':
              colliders.get(j*tilelayerWidth+i).setActive(true);
              break;
            }
          }
        }
        j++;
      } else if (line.trim().equals("-")) {
        tlCounter++;
        if (tlCounter == tilelayers.size()) tilelayers.add(new TileLayer(1, tilelayers.size()));
        j = 0;
      } else if (line.trim().equals("--")) {
        hasColliderLayer = true;
        j = 0;
      }
    }

    // Post-import actions
    //tilelayers.remove(tilelayers.size()-1);
    currentMapID = selection.getName();
    reader.close();
    notifications.add(new Notification(not_imgs[3])); // Notifications
  } catch (IOException e) {
    println("ee");
  }
}

// Import from file via icon
void importFromFileViaIcon(File selection) {
  importFromFile(selection);
  icons.get(3).setInAction(false); // Icon logical reset
  int temp = wheelNumber;
  wheelNumber = temp;
}
