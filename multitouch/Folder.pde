import java.awt.Image;
import java.util.Vector;
import processing.core.*;
import TUIO.*;

public class Folder {

  final static float SCREEN_SIZE_X = 1920;
  final static float SCREEN_SIZE_Y = 1100;

  ImageObject cover;
  ArrayList<ImageObject> images = new ArrayList<ImageObject>();
  TuioClient client = null;

  int timeout = 0;
  int beforetap = 0;
  int far = 0;
  boolean isShowImages = false;
  boolean isNearFolder = true;
  double len = 50.0f;
  float prevEachCursorLen = 0.0f;

  Folder(String filename, TuioClient client) {
    this.cover = new ImageObject(filename);
    this.client = client;
  }

  public void init() {
    cover.setIPos(SCREEN_SIZE_X/2, SCREEN_SIZE_Y/2);
    cover.drawImage();
  }

  public void updateFolder() {
    TuioCursor tuioCursor1 = null;
    TuioCursor tuioCursor2 = null;
    TuioCursor tuioCursor3 = null;
    int aliveCursor = client.getTuioCursors().size();
    if (timeout != 0) {
      timeout++;
    }
    if (timeout > 30) {
      timeout = 0;
      beforetap = 0;
    }

    switch(aliveCursor) {
    case 1:
      Vector<TuioCursor> cursors = client.getTuioCursors();
      for (TuioCursor tuioCursor : cursors) {
        float tuioCurSorX = tuioCursor.getX() * SCREEN_SIZE_X;
        float tuioCurSorY = tuioCursor.getY() * SCREEN_SIZE_Y;
        if (0 == tuioCursor.getCursorID() && checkCursorInFolder(tuioCurSorX, tuioCurSorY)) {
          updateIsShowImages();
          cover.updateImage(tuioCurSorX, tuioCurSorY);
        }
      }
      break;
    case 4:
      for (TuioCursor tuioCursor : client.getTuioCursors()) {
        if (0 == tuioCursor.getCursorID()) {
          tuioCursor1 = tuioCursor;
        }
        if (1 == tuioCursor.getCursorID()) {
          tuioCursor2 = tuioCursor;
        }
        if (1 == tuioCursor.getCursorID()) {
          tuioCursor3 = tuioCursor;
        }
      }
      if (tuioCursor1 != null && tuioCursor2 != null && tuioCursor3 !=null) {
        if (squeeze(tuioCursor1, tuioCursor2)) {
          goFarImageFromFolder();
          println("gofar");
        } else {
          println("gonear");
          goNearImageFromFolder();
        }
      }

      break;
    default:
      beforetap = 0;
      break;
    }
  }

  public boolean squeeze(TuioCursor cursor1, TuioCursor cursor2) {
    float curEachCursorLen;
    if (prevEachCursorLen == 0.0f) {
      prevEachCursorLen = eachCursorLen(cursor1, cursor2);
    }
    curEachCursorLen = eachCursorLen(cursor1, cursor2);
    if (prevEachCursorLen < curEachCursorLen) {
      prevEachCursorLen = curEachCursorLen;
      return true;
    } else {
      prevEachCursorLen = curEachCursorLen;
      return false;
    }
  }

  private float eachCursorLen(TuioCursor cursor1, TuioCursor cursor2) {
    float firX = cursor1.getX() * SCREEN_SIZE_X;
    float firY = cursor1.getY() * SCREEN_SIZE_Y;
    float secX = cursor2.getX() * SCREEN_SIZE_X;
    float secY = cursor2.getY() * SCREEN_SIZE_Y;

    float x = firX - secX;
    float y = firY - secY;
    return x*x + y*y;
  }


  private void goFarImageFromFolder() {
    for (int i=0; i<images.size(); i++) {
      if (far <10) {
        double ang = 30*(double)i;
        double x = cover.getIPosX() + len*(far+1)*Math.cos(ang);
        double y = cover.getIPosY() + len*(far+1)*Math.sin(ang);
        images.get(i).updateImage(x, y);
      }
      if (far == 10) {
        far = 10;
      } else {
        far++;
      }
    }
  }

  private void goNearImageFromFolder() {
    for (int i=0; i<images.size(); i++) {
      if (far > 0) {
        double ang = 30*(double)i;
        double x = cover.getIPosX() + len*(far-1)*Math.cos(ang);
        double y = cover.getIPosY() + len*(far-1)*Math.sin(ang);
        images.get(i).updateImage(x, y);
      }

      if (far == 0) {
        far = 0;
      } else {
        far--;
      }
    }
  }


  //        for (int i=0 ; i< images.size(); i++) {
  //          double ang = 30 * (double)i;
  //          if (isNearFolder && far<10){
  //            double x = cover.getIPosX() + len*(far+1)*Math.cos(ang);
  //            double y = cover.getIPosY() + len*(far+1)*Math.sin(ang);
  //            images.get(i).updateImage(x, y);
  //            far++;
  //            if(far == 10){
  //              isNearFolder = false;
  //            }
  //          }
  //          if(!isNearFolder && far>0){
  //            double x = cover.getIPosX() + len*(11)*Math.cos(ang) - len*(far+1)*Math.cos(ang);
  //            double y = cover.getIPosY() + len*(11)*Math.sin(ang) - len*(far+1)*Math.sin(ang);;
  //            images.get(i).updateImage(x, y);
  //            far--;
  //            if(far == 0){
  //              isNearFolder = true;
  //            }
  //          }
  //        }

  public void updateImages() {
    for (int i=0; i<images.size(); i++) {
      images.get(i).updateImage(client);
    }
  }

  public void updateIsShowImages() {
    if (timeout == 0) {
      timeout++;
      isShowImages = true;
      beforetap++;
    } else {
      if (timeout < 30 && beforetap == 0) {
        isShowImages = false;
      }
    }
  }

  public boolean checkCursorInFolder(float cursorX, float cursorY) {
    float margin = 30;
    float MinFX = cover.getIPosX() - cover.getIWidth()/2 - margin;
    float MaxFX = cover.getIPosX() + cover.getIWidth()/2 + margin;
    float MinFY = cover.getIPosY() - cover.getIHeight()/2 - margin;
    float MaxFY = cover.getIPosY() + cover.getIHeight()/2 + margin;
    if (cursorX < MinFX || cursorX > MaxFX) {
      return false;
    }
    if (cursorY < MinFY || cursorY > MaxFY) {
      return false;
    }
    return true;
  }
  
  public ImageObject getCover(){
    return this.cover;
  }


  public void drawFolder() {
    cover.drawImage();
  }

  public void drawImages() {
    if (isShowImages) {
      for (int i=0; i<images.size(); i++) {
        images.get(i).drawImage();
      }
    }
  }


  public void setImages(ArrayList<ImageObject> images) {
    this.images = images;
  }

  public ArrayList<ImageObject> getImages() {
    return this.images;
  }


  public void loadSimpsonImage() {
    ArrayList<String> iTitles = new ArrayList<String>();
    iTitles.add("simpson1.jpg");
    iTitles.add("simpson2.jpg");
    iTitles.add("simpson3.jpg");
    iTitles.add("simpson4.jpg");
    iTitles.add("simpson5.jpg");
    loadImages(iTitles);
  }
  public void loadAvengersImage() {
    ArrayList<String> iTitles = new ArrayList<String>();
    iTitles.add("avengers1.jpg");
    iTitles.add("avengers2.jpg");
    iTitles.add("avengers3.jpg");
    iTitles.add("avengers4.jpg");
    iTitles.add("avengers5.jpg");
    loadImages(iTitles);
  }
  public void loadImages(ArrayList<String> titles) {
    for (int i=0; i<titles.size();i++) {
      ImageObject io = new ImageObject(titles.get(i));
      double ang = 30 * (double)i;
      double x = cover.getIPosX() + 300.0f*Math.cos(ang);
      double y = cover.getIPosY() + 300.0f*Math.sin(ang);
      //images.get(i).updateImage(x, y);
      io.setIPos((float)x, (float)y);
      //io.setIPos(cover.getIPosX() + 100*(i+1), cover.getIPosX() + 20);
      images.add(io);
    }
  }

