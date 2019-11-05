// Face It
// ITP Fall 2013
// Daniel Shiffman
// https://github.com/shiffman/Faces

import processing.video.*;

import gab.opencv.*;
import java.awt.Rectangle;

int camWidth = 640;
int camHeight = 480;
String cameraName = "HUE HD Camera";

OpenCV faceCV;

Capture cam;
int camFrame = 0;

PImage backGrndImg;
PGraphics pass1, pass2;
OpenCV backGrnd;

PImage faceImage;
Rectangle[] faceRects;
// A list of my Face objects
ArrayList<Face> faceList;

// how many have I found over all time
int faceCount = 0;

float moveThreshhold = 1.0;

PGraphics ghostImage;

PShader blur;

void setup() {
  fullScreen(P2D);
  //size(640, 480, P2D);
  setupSound();
  
  String[] camList = Capture.list();
  for(int i = 0; i < camList.length; ++i)
    println(camList[i]);

  
  blur = loadShader("blur.glsl");
  blur.set("blurSize", 9);
  blur.set("sigma", 5.0f); 
  
  cam = new Capture(this, camWidth, camHeight,cameraName);
  
  faceImage = createImage(cam.width, cam.height, RGB);
  faceCV = new OpenCV(this, cam.width, cam.height);
  faceCV.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
  
  backGrndImg = createImage(cam.width, cam.height, RGB);
  backGrnd = new OpenCV(this, cam.width, cam.height);
  backGrnd.startBackgroundSubtraction(5, 3, 0.5);
   
  pass1 = createGraphics(cam.width ,cam.height, P2D);
  pass2 = createGraphics(cam.width ,cam.height, P2D);
  
  faceList = new ArrayList<Face>();
  
  
  cam.start();
}

void updateFaces(Rectangle[] faces) {
  if(faces == null)
    return;

  // SCENARIO 1: faceList is empty
  if (faceList.isEmpty()) {
    // Just make a Face object for every face Rectangle
    for (int i = 0; i < faces.length; i++) {
      faceList.add(new Face(faces[i].x, faces[i].y, faces[i].width, faces[i].height));
    }
    // SCENARIO 2: We have fewer Face objects than face Rectangles found from faceCV
  } 
  else if (faceList.size() <= faces.length) {
    boolean[] used = new boolean[faces.length];
    // Match existing Face objects with a Rectangle
    for (Face f : faceList) {
      // Find faces[index] that is closest to face f
      // set used[index] to true so that it can't be used twice
      float record = 50000;
      int index = -1;
      for (int i = 0; i < faces.length; i++) {
        float d = dist(faces[i].x, faces[i].y, f.r.x, f.r.y);
        if (d < record && !used[i]) {
          record = d;
          index = i;
        }
      }
      // Update Face object location
      used[index] = true;
      f.update(faces[index]);
    }
    // Add any unused faces
    for (int i = 0; i < faces.length; i++) {
      if (!used[i]) {
        faceList.add(new Face(faces[i].x, faces[i].y, faces[i].width, faces[i].height));
      }
    }
    // SCENARIO 3: We have more Face objects than face Rectangles found
  } 
  else {
    // All Face objects start out as available
    for (Face f : faceList) {
      f.available = true;
    } 
    // Match Rectangle with a Face object
    for (int i = 0; i < faces.length; i++) {
      // Find face object closest to faces[i] Rectangle
      // set available to false
      float record = 50000;
      int index = -1;
      for (int j = 0; j < faceList.size(); j++) {
        Face f = faceList.get(j);
        float d = dist(faces[i].x, faces[i].y, f.r.x, f.r.y);
        if (d < record && f.available) {
          record = d;
          index = j;
        }
      }
      // Update Face object location
      Face f = faceList.get(index);
      f.available = false;
      f.update(faces[i]);
    } 
    // Start to kill any left over Face objects
    for (Face f : faceList) {
      if (f.available) {
        f.countDown();
        if (f.dead()) {
          f.delete = true;
        }
      }
    }
  }

  // Delete any that should be deleted
  for (int i = faceList.size()-1; i >= 0; i--) {
    Face f = faceList.get(i);
    if (f.delete) {
      faceList.remove(i);
    }
  }
}

void draw() {
  scale(width/camWidth, height/camHeight);
  background(0);
  //image(cam,0,0);
  
  updateFaces(faceRects);
  
  backGrnd.loadImage(backGrndImg);
  backGrnd.updateBackground();
  
  backGrnd.dilate();
  //opencv.erode();

  blurImage(backGrnd.getOutput());
  
  //blurImage(cam);
  
  for (Face f : faceList) {
    f.display();
  }
  if(frameCount % 300 == 0) {
    println(frameRate);
  }
}

boolean isProcFaces = false;
boolean isProcFlow = false;

void captureEvent(Capture cam) {
  cam.read();
  ++camFrame;
  if(!isProcFaces) {
    isProcFaces = true;
    faceImage.copy(
      cam,
      0, 0,
      cam.width, cam.height,
      0, 0,
      faceImage.width, faceImage.height);
    thread("findFaces");
  }
  backGrndImg.copy(
      cam,
      0, 0,
      cam.width, cam.height,
      0, 0,
      backGrndImg.width, backGrndImg.height);
}

void findFaces() {
  faceCV.loadImage(faceImage);
  faceRects = faceCV.detect();
  isProcFaces = false;
}

void blurImage(PImage src) {
  // Applying the blur shader along the vertical direction   
  blur.set("horizontalPass", 0);
  pass1.beginDraw();            
  pass1.shader(blur);  
  pass1.image(src, 0, 0);
  pass1.endDraw();
  
  // Applying the blur shader along the horizontal direction      
  blur.set("horizontalPass", 1);
  pass2.beginDraw();            
  pass2.shader(blur);  
  pass2.image(pass1, 0, 0);
  pass2.endDraw();    
        
  image(pass2, 0, 0);   
}
 
