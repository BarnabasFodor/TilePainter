class TileLayer {

  // Variables
  private ArrayList<Tile> tiles;
  private int index;
  private int type;

  // Constructor
  TileLayer(int t, int i) {
    this.type = t;
    this.index = i;
    this.tiles = setupList();
  }

  // Functions
  void update() {
    for (Tile t : tiles) {
      t.render();
      if (isActive()) t.mousePressed();
    }
  }

  void artView() {
    for (Tile t : tiles) {
      t.render();
    }
  }

  ArrayList<Tile> setupList() {
    // Variable that the function will return
    ArrayList<Tile> temp = new ArrayList<Tile>();
    switch (type) {
      // Palette tilelayer
      case 0:
        for (int x = 0; x < 32; x++) {
          temp.add(new Tile(
            new PVector(x, 0),
            images[x],
            true));
        }
        break;
      // Normal tilelayer
      case 1:
        for (int y = 1; y < tilelayerHeight+1; y++) {
          for (int x = 0; x < tilelayerWidth; x++) {
            temp.add(new Tile(
              new PVector(x, y),
              nullImg,
              false));
          }
        }
        break;
    }
    // Return
    return temp;
  }

  // Getters
  ArrayList<Tile> getTiles() {
    return tiles;
  }

  int getIndex() {
    return index;
  }

  int getType() {
    return type;
  }

  boolean isActive() {
    if (tilelayerIndex == index) return true;
    return false;
  }

  // Setters
  void setIndex(int i) {
    index = i;
  }
}
