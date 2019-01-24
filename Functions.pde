/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

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

// Resize map function
void resizeMap() {
  for (int i = tilelayers.size()-1; i >= 0; i--) {
    tilelayers.remove(i);
  }
  tilelayers.add(new TileLayer(0, 0));
  tilelayers.add(new TileLayer(1, 1));
  tilelayers.add(new TileLayer(1, 2));
  for (int i = colliders.size()-1; i >= 0; i--) {
    colliders.remove(colliders.remove(i));
  }
  for (int y = 1; y < tilelayerHeight+1; y++) {
    for (int x = 0; x < tilelayerWidth; x++) {
      colliders.add(new Collider(new PVector(x, y), false));
    }
  }
}

// Application icon and title change function
void changeAppIconAndTitle(PImage img, String title) {
  surface.setIcon(img);
  surface.setTitle(title);
}

// Art-viewer function
void makeMapFitScreen(int pState) {
  switch (pState) {
    // Resize map to fit program state
    case 0:
      TILESIZE = (post_w/33+post_h/25)/2;
      break;

    // Resize map to fit art-viewer state
    case 1:
      TILESIZE = (height <= width) ? (height/tilelayerWidth+height/tilelayerHeight)/2 : (width/tilelayerWidth+width/tilelayerHeight)/2;
      xOffset = 0;
      yOffset = 0;
      PGraphics pg = createGraphics(TILESIZE*tilelayerWidth, TILESIZE*tilelayerHeight);
      pg.beginDraw();
      pg.background(100);
      pg.imageMode(CORNER);
      for (int i = 1; i < tilelayers.size(); i++) {
        TileLayer tl = tilelayers.get(i);
        for (Tile t : tl.getTiles()) {
          pg.image(t.getImg(), t.getPos().x*TILESIZE, (t.getPos().y-1)*TILESIZE, TILESIZE, TILESIZE);
        }
      }
      pg.endDraw();
      artView = pg.get();
      break;
  }
}
