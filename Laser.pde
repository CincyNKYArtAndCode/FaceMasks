import processing.sound.*;
import java.util.*;


SoundFile sound[];


void setupSound() {
  sound = new SoundFile[7];
  for(int i = 0; i < 7; ++ i)
    sound[i] = new SoundFile(FaceMasks2.this, "wings" + Integer.toString(i + 1) + ".wav");
}

class Laser {
  
  float y;
  float lx;
  float rx;
  
  float angle = 0;
  float dist = 5;
  
  PImage batL;
  PImage batR;
  PImage batL2;
  PImage batR2;
  PImage batL3;
  PImage batR3;
  
  ArrayList<PImage> batLs;
  ArrayList<PImage> batRs;
  
  int counter = 0;
  
  Laser(float y, float lx, float rx) {
    this.y = y;
    this.lx = lx;
    this.rx = rx;
    this.batLs = new ArrayList<PImage>();
    this.batRs = new ArrayList<PImage>();
    
    this.batL = loadImage("batL.png");
    this.batR = loadImage("batR.png");
    this.batL2 = loadImage("batL2.png");
    this.batR2 = loadImage("batR2.png");
    this.batL3 = loadImage("batL3.png");
    this.batR3 = loadImage("batR3.png");
    
    this.batLs.add(this.batL);
    this.batLs.add(this.batL2);
    this.batLs.add(this.batL3);
    this.batRs.add(this.batR);
    this.batRs.add(this.batR2);
    this.batRs.add(this.batR3);
    
    int si = (int)random(7);
    sound[si].play();
  }
  
  int draw() {
    //stroke(255, 0, 0);
    //strokeWeight(3);
    
    float dlx = lx + cos(angle) * dist;
    float dly = y + sin(angle) * dist;
    float drx = rx + cos(angle + PI) * dist;
    float dry = y + sin(angle + PI) * dist;
    image(batLs.get(counter), dlx, dly, 75, 30);
    image(batRs.get(counter), drx, dry, 75, 30);
    //line(lx, y, lx - 15, y + 15);
    //line(rx, y, rx + 15, y + 15);
    
    angle = 2*PI * millis()/1000;
    dist *= 1.2;
    
    ++counter;
    if(counter > 2) counter = 0;
    
    if(dist > 100) {
      return 0;
    }
    return 1;
  }
  
}
