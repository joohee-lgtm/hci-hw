import java.awt.Image;
import java.util.*;
import processing.core.*;
import TUIO.*;

final static int SCREEN_SIZE_X = 1920;
final static int SCREEN_SIZE_Y = 1100;


TuioClient client = null;
Folder simpson;
Folder avengers;

public void setup() {
  client = new TuioClient();
  client.connect();

  // set folders
  simpson = new Folder("simpson.png", client);
  simpson.init();
  simpson.loadSimpsonImage();
  simpson.getCover().setIPos(SCREEN_SIZE_X/3, SCREEN_SIZE_Y/3);

  avengers = new Folder("avengers.png", client);
  avengers.init();
  avengers.loadAvengersImage();
  avengers.getCover().setIPos(SCREEN_SIZE_X/2, SCREEN_SIZE_Y/2);
  avengers.getCover().setSize((float)avengers.getCover().getImgObj().width/5, (float)avengers.getCover().getImgObj().height/5);
  size(SCREEN_SIZE_X, SCREEN_SIZE_Y);
}

public void draw() {
  background(100);
  updateData();
  simpson.drawFolder();
  simpson.drawImages();
  avengers.drawFolder();
  avengers.drawImages();
} 

public void updateData() {
  simpson.updateFolder();
  simpson.updateImages();
  avengers.updateFolder();
  avengers.updateImages();
}

