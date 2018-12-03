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
  if (state == 1) {
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
}



/*
 * ---   KEYBOARD INPUT ---
 */

 // Certain keyboard inputs
 void keyPressed() {

   // Tilelayer change
   if (Character.getNumericValue(key) >= 1 && Character.getNumericValue(key) < tilelayers.size()) {
     tilelayerIndex = Character.getNumericValue(key);
   }

   // Multi-key detection
   if (key == 'w') up = true;
   if (key == 's') down = true;
   if (key == 'a') left = true;
   if (key == 'd') right = true;
   if (keyCode == SHIFT) shift = true;

   // Tile generation
   if (key == 'r' && !isSelecting) {
     // Looping through the main tiles
     if (tilelayerIndex == 1) {
       PImage[] grass = {images[0], images[1], images[2], images[3]};
       for (int i = 0; i < tilelayerHeight; i++) {
         for (int j = 0; j < tilelayerWidth; j++) {
           tilelayers.get(tilelayerIndex).getTiles().get(i*tilelayerWidth+j).setImg(grass[round(random(0, 3))]);
         }
       }
     // Looping through the decorative tiles
     } else if (tilelayerIndex >= 2) {
       for (int i = 0; i < tilelayerHeight; i++) {
         for (int j = 0; j < tilelayerWidth; j++) {
           PImage[] stone = {images[27], images[28], images[29], images[30], images[31]};
           if (random(0, 1) > 0.98) {
             tilelayers.get(tilelayerIndex).getTiles().get(i*tilelayerWidth+j).setImg(stone[round(random(0, 4))]);
           }
           PImage[] flower = {images[22], images[23], images[24], images[25], images[26]};
           if (random(0, 1) > 0.95) {
             tilelayers.get(tilelayerIndex).getTiles().get(i*tilelayerWidth+j).setImg(flower[round(random(0, 4))]);
           }
         }
       }
     }
   }

   // Layer erase
   if (key == 'e' && !isSelecting && state == 1) {
     for (int i = 0; i < tilelayerHeight; i++) {
       for (int j = 0; j < tilelayerWidth; j++) {
         tilelayers.get(tilelayerIndex).getTiles().get(i*tilelayerWidth+j).setImg(nullImg);
       }
     }
   }

   // Layer fill
   if (key == 'f' && !isSelecting && state == 1) {
     // Main tiles
     for (Tile t : tilelayers.get(tilelayerIndex).getTiles()) {
       t.setImg(paintImg);
     }
   }

   // Map export
   if (key == 10 && state == 1) {
     exportIntoFile();
     notifications.add(new Notification(not_imgs[0])); // Notification
   }

   // Map import
   if (key == 'i' && state == 1) {
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

     // STATES
     if (state == 2) {
       credits.setY(height);
       credits.setSpeed(1);
       credits.setVisible(false);
       state = 0;
     } else if (state == 3) {
       state = 0;
     } else if (state == 4) {
       state = 1;
       fitsScreen = false;
     }
   }
 }

 void keyReleased() {
   // Multi-key detection
   if (key == 'w') up = false;
   if (key == 's') down = false;
   if (key == 'a') left = false;
   if (key == 'd') right = false;
   if (keyCode == SHIFT) shift = false;
 }

 void updateCameraControl() {
   if (up && state == 1)    yOffset += 1;
   if (down && state == 1)  yOffset -= 1;
   if (left && state == 1)  xOffset += 1;
   if (right && state == 1) xOffset -= 1;
 }
