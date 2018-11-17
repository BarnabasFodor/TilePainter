/*
 * TilePainter
 * Developed by Barnabas Fodor
 * - 2018
 */

// SUPERCLASS : ICON
abstract class Icon {

  // Variables
  protected PVector pos; // (In tile-system)
  protected PImage img;
  protected String name;
  protected boolean active, isClicked, hasBeenClicked, mouseOverIcon, inAction;
  protected float iconStartTime, iconElapsedTime;

  // Constructor
  Icon(PVector p, PImage i, boolean b, String s) {
    this.pos = p;
    this.img = i;
    this.active = b;
    this.name = s;
    this.isClicked = false;
    this.hasBeenClicked = false;
    this.mouseOverIcon = false;
    this.inAction = false;
    this.iconStartTime = 0;
    this.iconElapsedTime = 0;
  }

  // Functions
  void render() {
    imageMode(CORNER);
    // Shade
    if (!mouseOverIcon && active) { // Normal
      tint(220);
    } else if (mouseOverIcon && active) { // Lighter
      tint(255);
    } else if (!active) { // Darker
      tint(30);
    }
    image(img, pos.x*TILESIZE, pos.y*TILESIZE); // Scale up to real-system
  }

  void nameDisplay() {
    if (mouseOverIcon) {
      textSize(TILESIZE/2);
      PVector posRect = new PVector(pos.x*TILESIZE-TILESIZE-textWidth(name), mouseY);
      float boxw = textWidth(name)+TILESIZE/4, boxh = TILESIZE*0.6;
      float offSet = TILESIZE/8;
      rectMode(CORNER);
      strokeWeight(3);
      stroke(0);
      fill(0, 60);
      rect(posRect.x, posRect.y, boxw, boxh);
      textAlign(LEFT);
      fill(0);
      text(name, posRect.x+offSet, posRect.y+TILESIZE/2);
    }
  }

  void update() {
    if (mousePressed && active && (iconElapsedTime >= 300 || !hasBeenClicked) && mouseButton == LEFT && mouseX >= pos.x*TILESIZE && mouseX < (pos.x+1)*TILESIZE && mouseY >= pos.y*TILESIZE && mouseY < (pos.y+1)*TILESIZE) {
      iconStartTime = millis();
      isClicked = true;
      hasBeenClicked = true;
    } else {
      isClicked = false;
    }
    mouseOverIcon = (mouseX >= pos.x*TILESIZE && mouseX < (pos.x+1)*TILESIZE && mouseY >= pos.y*TILESIZE && mouseY < (pos.y+1)*TILESIZE) ? true : false;
    iconElapsedTime = millis() - iconStartTime;
  }

  // The method that the child'll override
  abstract void action();

  // Getters
  PVector getPos() {
    return pos;
  }

  PImage getImg() {
    return img;
  }

  boolean isClicked() {
    return isClicked;
  }

  boolean isActive() {
    return active;
  }

  // Setters
  void setActive(boolean b) {
    active = b;
  }

  void setInAction(boolean b) {
    inAction = false;
  }

}

// CLASS : INFOICON
class InfoIcon extends Icon {

  // Constructor
  InfoIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  @Override
  void render() {
    imageMode(CORNER);
    // Shade
    if ((mouseOverIcon && active) || isInfoVisible) { // Lighter
      if (mouseOverIcon && active && !isInfoVisible) tint(255); // Mouse over only
      if (mouseOverIcon && active && isInfoVisible) tint(0, 255, 0); // Purpose on, mouse over
      if (!mouseOverIcon && isInfoVisible) tint(0, 225, 0); // Purpose on only
    } else if (!mouseOverIcon && active) { // Normal
      tint(220);
    } else if (!active) { // Darker
      tint(30);
    }
    image(img, pos.x*TILESIZE, pos.y*TILESIZE); // Scale up to real-system
  }

  @Override
  void action() {
    if (isClicked) {
      isInfoVisible = !isInfoVisible;
      if (!isInfoVisible) isDetailsVisible = false;
    }
  }
}

// CLASS : DETAILSICON
class DetailsIcon extends Icon {

  // Constructor
  DetailsIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  @Override
  void render() {
    imageMode(CORNER);
    // Shade
    if ((mouseOverIcon && active) || isDetailsVisible) { // Lighter
      if (mouseOverIcon && active && !isDetailsVisible) tint(255); // Mouse over only
      if (mouseOverIcon && active && isDetailsVisible) tint(0, 255, 0); // Purpose on, mouse over
      if (!mouseOverIcon && isDetailsVisible) tint(0, 225, 0); // Purpose on only
    } else if (!mouseOverIcon && active) { // Normal
      tint(220);
    } else if (!active) { // Darker
      tint(30);
    }
    image(img, pos.x*TILESIZE, pos.y*TILESIZE); // Scale up to real-system
  }

  @Override
  void action() {
    if (isClicked) {
      isDetailsVisible = !isDetailsVisible;
    }
    active = (isInfoVisible) ? true : false;
  }

}

// CLASS : SAVEICON
class SaveIcon extends Icon {

  // Constructor
  SaveIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  @Override
  void action() {
    if (isClicked) {
      exportIntoFile();
      notifications.add(new Notification(not_imgs[0])); // Notification
    }
  }

}

// CLASS : OPENICON
class OpenIcon extends Icon {

  // Constructor
  OpenIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  @Override
  void action() {
    if (isClicked && !inAction) {
      selectInput("Select a file to import:", "importFromFileViaIcon");
      inAction = true;
    }
  }

}

// CLASS : OPENICON
class RandomIcon extends Icon {

  // Constructor
  RandomIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  @Override
  void action() {
    if (isClicked) {
      // Tile generation
      if (!isSelecting) {
        // Looping through the main tiles
        if (tilelayerIndex == 1) {
          PImage[] grass = {images[0], images[1], images[2], images[3]};
          for (int i = 0; i < 24; i++) {
            for (int j = 0; j < 32; j++) {
              tilelayers.get(1).getTiles().get(i*32+j).setImg(grass[round(random(0, 3))]);
            }
          }
        // Looping through the decorative tiles
        } else if (tilelayerIndex >= 2) {
          for (int i = 0; i < 24; i++) {
            for (int j = 0; j < 32; j++) {
              PImage[] stone = {images[27], images[28], images[29], images[30], images[31]};
              if (random(0, 1) > 0.98) {
                tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(stone[round(random(0, 4))]);
              }
              PImage[] flower = {images[22], images[23], images[24], images[25], images[26]};
              if (random(0, 1) > 0.95) {
                tilelayers.get(tilelayerIndex).getTiles().get(i*32+j).setImg(flower[round(random(0, 4))]);
              }
            }
          }
        }
      }
    }
  }

}

// CLASS : LAYERICON
class LayerIcon extends Icon {

  // Variables
  private int modVal;

  // Constructor
  LayerIcon(PVector p, PImage i, boolean b, String s, int v) {
    super(p, i, b, s);
    this.modVal = v;
  }

  @Override
  void action() {
    if (isClicked) {
      switch (modVal) {
        case -1:
          if (!(tilelayerIndex <= 2)) {
            tilelayers.remove(tilelayerIndex);
            tilelayerIndex = tilelayers.size()-1;
            for (int i = 1; i < tilelayers.size(); i++) {
              tilelayers.get(i).setIndex(i);
            }
          }
          break;
        case 1:
          if (tilelayers.size() != 10) {
            tilelayers.add(new TileLayer(1, tilelayers.size()));
          }
          break;
      }
    }
    active = ((!(tilelayerIndex <= 2) && modVal == -1) || (tilelayers.size() != 10 && modVal == 1)) ? true : false;
  }

}

// CLASS : EXITICON
class ExitIcon extends Icon {

  // Constructor
  ExitIcon(PVector p, PImage i, boolean b, String s) {
    super(p, i, b, s);
  }

  @Override
  void action() {
    if (isClicked) {
      if (currentMapID != "Untitled") exportIntoFile();
      state = 0;
      currentMapID = "Untitled";
      tilelayerIndex = 1;
      wheelNumber = 0;
      for (int i = tilelayers.size()-1; i >= 1; i--) {
        if (i > 2) {
          tilelayers.remove(i);
        } else {
          for (Tile t : tilelayers.get(i).getTiles()) {
            t.setImg(nullImg);
          }
        }
      }
    }
  }

}
