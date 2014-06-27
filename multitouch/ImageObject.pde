import java.awt.Image;
import java.util.Vector;
import processing.core.*;
import TUIO.*;

public class ImageObject {
  final static float SCREEN_SIZE_X = 1920;
  final static float SCREEN_SIZE_Y = 1100;

  private float iPosX;
  private float iPosY;
  private float iWidth;
  private float iHeight;
  PImage imgObj;
  float before = 0.0f;
  float current = 0.0f;
  float imageRotate = 0.0F;
  float beforeRotate = 0.0F;


  ImageObject(String file) {
    PImage i = loadImage(file);
    this.imgObj = i;
    this.iWidth = i.width/2;
    this.iHeight = i.height/2;
  }

  public void drawImage() {
    pushMatrix();
    translate(iPosX, iPosY);
    rotate(radians(imageRotate));
    translate(- iWidth / 2, - iHeight / 2);
    image(imgObj, 0, 0, iWidth, iHeight);
    popMatrix();
  }
  
  public PImage getImgObj(){
    return this.imgObj;
  }

  public void updateImage(float cursorX, float cursorY) {    
    setIPos(cursorX, cursorY);
  }

  public void updateImage(double cursorX, double cursorY) {    
    setIPos((float)cursorX, (float)cursorY);
  }


  public void updateImage(TuioClient client) {
    TuioCursor tuioCursor1 = null;
    TuioCursor tuioCursor2 = null;
    TuioCursor tuioCursor3 = null;


    int aliveCursor = client.getTuioCursors().size();
    switch (aliveCursor) {
    case 1:
      Vector<TuioCursor> cursors = client.getTuioCursors();
      for (TuioCursor tuioCursor : cursors) {
        float tuioCurSorX = tuioCursor.getX() * SCREEN_SIZE_X;
        float tuioCurSorY = tuioCursor.getY() * SCREEN_SIZE_Y;

        if (0 == tuioCursor.getCursorID() && checkCursorInImage(tuioCurSorX, tuioCurSorY)) {
          iPosX = tuioCursor.getX() * SCREEN_SIZE_X;
          iPosY = tuioCursor.getY() * SCREEN_SIZE_Y;
        }
      }
      break;
    case 2:
      for (TuioCursor tuioCursor : client.getTuioCursors()) {
        if (0 == tuioCursor.getCursorID()) {
          tuioCursor1 = tuioCursor;
        }
        if (1 == tuioCursor.getCursorID()) {
          tuioCursor2 = tuioCursor;
        }
      }
      if (tuioCursor1 != null && tuioCursor2 != null) {
        if (checkCursorInImage(tuioCursor1)) {
          //set image
          iWidth = Math.abs(tuioCursor1.getX() - tuioCursor2.getX())* SCREEN_SIZE_X;
          iHeight = Math.abs(tuioCursor1.getY() - tuioCursor2.getY())* SCREEN_SIZE_Y;
        }
      }
      break;
    case 3:
      for (TuioCursor tuioCursor : client.getTuioCursors()) {
        if (0 == tuioCursor.getCursorID()) {
          tuioCursor1 = tuioCursor;
        }
        if (1 == tuioCursor.getCursorID()) {
          tuioCursor2 = tuioCursor;
        }
      }
      if (tuioCursor1 != null && tuioCursor2 != null) {
        if (checkCursorInImage(tuioCursor1)) {
          float gradient = (tuioCursor1.getY() - tuioCursor2.getY())
            / (tuioCursor1.getX() - tuioCursor2.getX());
          imageRotate = (float)(Math.atan(gradient) * 180.0 /  Math.PI);
        }
      }
      break;

    default:
      break;
    }
  }

  private void imageRotateAngle(TuioCursor tc1, TuioCursor tc2) {
    float x = (tc1.getX() - tc2.getX()) * SCREEN_SIZE_X;
    float y = (tc1.getY() - tc2.getY()) * SCREEN_SIZE_Y;
    imageRotate = (float)(Math.tan(y/x));
    //    if (beforeRotate == 0.0f){
    //      beforeRotate = (float)(Math.tan(y/x));
    //    }
    //    float curRotate = (float)(Math.tan(y/x));
    //    imageRotate = curRotate - beforeRotate;
  }

  private boolean checkCursorInImage(TuioCursor tuioCursor) {
    float tuioCurSorX = tuioCursor.getX() * SCREEN_SIZE_X;
    float tuioCurSorY = tuioCursor.getY() * SCREEN_SIZE_Y;
    return checkCursorInImage(tuioCurSorX, tuioCurSorY);
  }

  private boolean checkCursorInImage(float cursorX, float cursorY) {
    float margin = 50.0f;
    float MinIX = iPosX - getIWidth()/2 - margin;
    float MaxIX = iPosX + getIWidth()/2 + margin ;
    float MinIY = iPosY - getIHeight()/2 - margin;
    float MaxIY = iPosY + getIHeight()/2 + margin;
    if (cursorX < MinIX || cursorX > MaxIX) {
      return false;
    }
    if (cursorY < MinIY || cursorY > MaxIY) {
      return false;
    }
    return true;
  }

  public void setIPos(float x, float y) {
    setIPosX(x);
    setIPosY(y);
  }  
  public void setIPosX(float x) {
    this.iPosX = x;
  }
  public float getIPosX() {
    return this.iPosX;
  }
  public float getIPosY() {
    return this.iPosY;
  }

  public void setIPosY(float y) {
    this.iPosY = y;
  }

  public void setSize(float w, float h) {
    setIWidth(w);
    setIHeight(h);
  }
  public void setIWidth(float w) {
    this.iWidth = w;
  }
  public float getIWidth() {
    return this.iWidth;
  }

  public float getIHeight() {
    return this.iHeight;
  }

  public void setIHeight(float h) {
    this.iHeight = h;
  }
}
}
