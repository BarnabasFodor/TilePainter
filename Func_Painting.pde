/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

 /*
  * ---   PAINTING FUNCTIONS   ---
  */

 // Selection brush
 void selectionFill() {

   // START SELECTING
   if (shift && !isSelecting && mousePressed && mouseButton == LEFT &&
      mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= tilelayerWidth && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= tilelayerHeight) {

     // Update variables
     isSelecting = true;
     startSelect = new PVector(mouseX/TILESIZE-xOffset, mouseY/TILESIZE-yOffset);

   // END SELECTING
   } else if (shift && isSelecting && mousePressed && mouseButton == RIGHT &&
      mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= tilelayerWidth && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= tilelayerHeight) {

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
         tilelayers.get(tilelayerIndex).getTiles().get((y-1)*tilelayerWidth+x).setImg(paintImg); // -> Current tilelayer
       }
     }

     // Reset variables
     sTime = millis();
     eTime = 0;
     isSelecting = false;

   // SELECTION ERASE
   } else if (keyPressed && key == 'e' && isSelecting &&
      mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= tilelayerWidth && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= tilelayerHeight) {

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
        tilelayers.get(tilelayerIndex).getTiles().get((y-1)*tilelayerWidth+x).setImg(nullImg); // -> Current tilelayer
      }
     }

     // Reset variables
     sTime = millis();
     eTime = 0;
     isSelecting = false;

   // TILE GENERATION
   } else if (keyPressed && key == 'r' && isSelecting &&
      mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= tilelayerWidth && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= tilelayerHeight) {

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
           tilelayers.get(tilelayerIndex).getTiles().get((y-1)*tilelayerWidth+x).setImg(grass[round(random(0, 3))]);
         }
         if (tilelayerIndex >= 2) {
           if (random(0, 1) > 0.98) {
             tilelayers.get(tilelayerIndex).getTiles().get((y-1)*tilelayerWidth+x).setImg(stone[round(random(0, 4))]);
           }
           if (random(0, 1) > 0.95) {
             tilelayers.get(tilelayerIndex).getTiles().get((y-1)*tilelayerWidth+x).setImg(flower[round(random(0, 4))]);
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
 void captureScreen(PImage i) {
   String docs = new JFileChooser().getFileSystemView().getDefaultDirectory().toString(); // Path to the 'Documents' directory
   String path = docs + "\\TilePainterMaps\\Screenshots\\"; // Final path
   File folder = new File(path);
   if (!folder.exists()) folder.mkdir(); // Make directories if they don't exist
   i.save(path+"screenshot_"+month()+"-"+day()+"-"+year()+"--"+hour()+"-"+minute()+"-"+second()+".png"); // Save!
 }

 void displayInfo() {
   // Details text
   if (isDetailsVisible) {
     textSize(TILESIZE/2);
     PVector posRect = new PVector(29*TILESIZE-textWidth(currentMapID), TILESIZE);
     float boxw = 32*TILESIZE-(29*TILESIZE-textWidth(currentMapID))-1.5, boxh = 5.5*TILESIZE;
     float offSet = TILESIZE/8;
     String brushMode = "";
     if (isSelecting) {
       brushMode = "SELECT";
     } else if (ctrl) {
       brushMode = "COLLIDER";
     } else {
       brushMode = "PAINT";
     }
     rectMode(CORNER);
     strokeWeight(3);
     stroke(255);
     fill(120, 60);
     rect(posRect.x, posRect.y, boxw, boxh);
     textAlign(LEFT);
     fill(255);
     text("|Project:\n\n|Brush mode:\n\n|Camera offset:\n\n|Dimensions:", posRect.x+offSet, posRect.y+TILESIZE);
     text("\n "+currentMapID+"\n\n "+brushMode+"\n\n {"+nf(-yOffset, 2)+","+nf(-xOffset, 2)+"}\n\n "+tilelayerWidth+", "+tilelayerHeight+"\n\n", posRect.x+offSet, posRect.y+TILESIZE);
   }

   // Information text
   if (isInfoVisible) {
     textAlign(CENTER);
     textSize(TILESIZE);
     float alpha = 0;
     if (mouseX <= width/2-textWidth("Layer: "+tilelayerIndex+"/"+(tilelayers.size()-1)+" | Tile: "+(wheelNumber+1))/2 && mouseX >= width/2+textWidth("Layer: "+tilelayerIndex+"/"+(tilelayers.size()-1)+" | Tile: "+(wheelNumber+1))/2 &&
          mouseY <= height && mouseY >= height-TILESIZE*2) {
            alpha = 125;
          } else {
            alpha = 255;
          }
     fill(0, alpha);
     if (wheelNumber+1 > 9) {
       text("Layer: "+tilelayerIndex+"/"+(tilelayers.size()-1)+" | Tile: "+(wheelNumber+1), width/2, height-TILESIZE);
     } else {
       text("Layer: "+tilelayerIndex+"/"+(tilelayers.size()-1)+" | Tile: 0"+(wheelNumber+1), width/2, height-TILESIZE);
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
 }

 // Selection box function
 void drawSelectionBox() {

   // SELECTION BOX
   if (isSelecting && mouseX/TILESIZE-xOffset >= 0 && mouseX/TILESIZE-xOffset <= tilelayerWidth && mouseY/TILESIZE-yOffset >= 1 && mouseY/TILESIZE-yOffset <= tilelayerHeight) {

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
   line(0, (tilelayerHeight+1)*TILESIZE, TILESIZE, (tilelayerHeight+1)*TILESIZE);
   line(0, (tilelayerHeight+1)*TILESIZE, 0, tilelayerHeight*TILESIZE);
   // TOP-LEFT
   line(tilelayerWidth*TILESIZE, TILESIZE, tilelayerWidth*TILESIZE-1*TILESIZE, TILESIZE);
   line(tilelayerWidth*TILESIZE, TILESIZE, tilelayerWidth*TILESIZE, 2*TILESIZE);
   // BOTTOM-LEFT
   line(tilelayerWidth*TILESIZE, (tilelayerHeight+1)*TILESIZE, tilelayerWidth*TILESIZE-1*TILESIZE, (tilelayerHeight+1)*TILESIZE);
   line(tilelayerWidth*TILESIZE, (tilelayerHeight+1)*TILESIZE, tilelayerWidth*TILESIZE, tilelayerHeight*TILESIZE);
   popMatrix();
 }
