// Which Face Is Which
// Daniel Shiffman
// http://www.shiffman.net

class Face {
  
  // A Rectangle
  Rectangle r;
  
  PImage cat;
  
  // Am I available to be matched?
  boolean available;
  
  // Should I be deleted?
  boolean delete;
  
  // How long should I live if I have disappeared?
  int totalTime = 127;
  int timer = totalTime;
  
  // Assign a number to each face
  int id;
  
  ArrayList<Laser> laserList;
  
  // Make me
  Face(int x, int y, int w, int h) {
    cat = loadImage("cat.png");
    r = new Rectangle(x,y,w,h);
    available = true;
    delete = false;
    id = faceCount;
    faceCount++;
    laserList = new ArrayList<Laser>();
  }

  // Show me
  void display() {
    //fill(0,0,255,map(timer,0,10,0,100));
    //stroke(0,0,255);
    image(cat, r.x,r.y,r.width, r.height);
    //fill(255);
    //text(""+id,r.x*scl+10,r.y*scl+30);
    
    if(int(random(10)) == 1) {
      laserList.add(new Laser(r.y + (r.height/2), r.x + (0 * r.width), r.x + (.72 * r.width)));
    }
    
    for(int i = 0; i < laserList.size(); ++i) {
      int result = laserList.get(i).draw();
      if(result != 1) {
        laserList.remove(i);
      }
    }
  }

  // Give me a new location / size
  // Oooh, it would be nice to lerp here!
  void update(Rectangle newR) {
    r = (Rectangle) newR.clone();
    timer = totalTime;
  }

  // Count me down, I am gone
  void countDown() {
    timer--;
  }

  // I am deed, delete me
  boolean dead() {
    if (timer < 0) return true;
    return false;
  }
}
