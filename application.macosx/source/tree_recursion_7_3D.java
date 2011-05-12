import processing.core.*; 
import processing.xml.*; 

import toxi.physics.*; 
import toxi.physics.behaviors.*; 
import toxi.geom.*; 
import ddf.minim.*; 
import processing.opengl.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class tree_recursion_7_3D extends PApplet {

// Reactive Tree
// Martin Bravo <http://www.bravomartin.cl>
// Based on code from Daniel Shifmann'sRecursive Tree
// and Jer Thorp's Sperical Coordinates Tutorial
// Daniel Shiffman <http://www.shiffman.net>
// Jer Thorp http://blog.blprnt.com/blog/blprnt/processing-tutorial-spherical-coordinates

// we first import the libraries







// We startminim and the object for the ambient sounds.
Minim minim;
AudioPlayer ambientSound;

// Reference to physics world
VerletPhysics physics;
ConstantForceBehavior mouseForce;
Wind wind;
Fear fear;

// an aray of trees
Tree[] t = new Tree[1];

public void setup() {
  size(1280,800,OPENGL);
  smooth();
  frameRate(20);

  //Initialize minim
  minim = new Minim(this);
  minim.debugOn(); 
  ambientSound = minim.loadFile("ambient_full_loop.wav", 2048);
  ambientSound.setGain(5);
  ambientSound.loop();  

  // Initialize the physics
  physics=new VerletPhysics();
  physics.setDrag(0.02f);
  physics.addBehavior(new GravityBehavior(Vec3D.Y_AXIS.scale(1.5f)));

  // and the force objects
  wind = new Wind();
  fear = new Fear();


  for (int i = 0; i < 1; i++) {
    t[i] = new Tree(new Vec3D(i*400,height/2,i*-200), 180-(i*20), 300-(i*30), 36-(i*4), .65f);
    t[i].reset();
  }
}
float rotationY = 0;
public void draw() {
  background(0);
  translate(width/2,height/2);
  rotateY(rotationY);
 // rotationY+=.001;

  // update everything
  wind.update();
  fear.update();
  physics.update();
  for (int i = 0; i < 1; i++) {
    t[i].render();
  }
}




//to see the underlying spring structure.
Boolean structure = false;
public void keyPressed() {
  if (key == 's') {
    structure = !structure;
  }
  
  if (key == 'r') {
    t[0].reset();
  }
}

public void stop()
{
  // always close Minim audio classes when you are done with them
  ambientSound.close();
  // always stop Minim before exiting.
  minim.stop();

  super.stop();
}

class Tree {
  ArrayList a;
  ArrayList leaves;
  Particle root, trunk;
  Vec2D trunk_;
  int maxbranches;
  float thickness;
  float ratio;

  Tree(Vec3D r, int t, int s, float th, float ratio_) {
    root = new Particle (r.x,r.y, r.z);

    trunk = new Particle (r.x,r.y-t, r.z);
    maxbranches = s;
    thickness = th;
    ratio = ratio_;

    a = new ArrayList();
    leaves = new ArrayList();
    Branch b = new Branch(root,trunk, thickness, 1);
    // Add to arraylist
    //b.lock();
    a.add(b);
    for (int i = 0; i < 9; i++) {
      for (int j = a.size()-1; j >= 0; j--) {
        Branch bb = (Branch) a.get(j);
        bb.generateBranches();
      }
    }
  }




  public ArrayList a() {
    return a;
  }

  public ArrayList leaves() {
    return leaves;
  }

  public void reset() {
    for (int i = a.size()-1; i >= 1; i--) { 
      Branch b = (Branch) a.get(i);
      b.unlock();
    }
  }

  public void render() {
    for (int i = a.size()-1; i >= 0; i--) {
      // Get the branch, update and draw it
      Branch b = (Branch) a.get(i);
      b.render();
    }
    for (int j = a.size()-1; j >= 0; j--) {
      Branch bb = (Branch) a.get(j);

      if (random(1) < .0001f) {
        bb.generateLeaves();
      }
      if (leaves.size() < 5){
      bb.leafed = false;
      }
    }
   // println (leaves.size());


    for (int i = leaves.size()-1; i >= 0;  i--) {
      Leaf leaf = (Leaf) leaves.get(i);
      leaf.display();
      if (leaf.leaf.y > height) {
      leaves.remove(i);
      }
    }
  }

  public void fall(float j) {
    for (int i = leaves.size()-1; i >= 0;  i--) {
      Leaf leaf = (Leaf) leaves.get(i);
      if (random(1) < j) {
        leaf.fall();
      }
    }
  }



class Branch {
  Particle start,end,pillar1,pillar2, pillar3, pillar4, pillar5, pillar6;

  Vec3D len, pillar1_len, pillar2_len, pillar3_len, pillar4_len, pillar5_len, pillar6_len;
  float thick; // thickness of the branch
  int level;

  boolean branched = false;
  boolean leafed = false;

  Branch(Particle s, Particle e, float _th, int _l) {
    start = s;
    end = e;
    thick = _th;
    level = _l;
    len = end.sub(start);


    pillar1 = new Particle (end.x, end.y, end.z+level*30);
    pillar2 = new Particle (end.x+level*30, end.y, end.z);
    pillar3 = new Particle (end.x, end.y+level*30, end.z);
    pillar4 = new Particle (end.x, end.y, end.z-level*30);
    pillar5 = new Particle (end.x-level*30, end.y, end.z);
    pillar6 = new Particle (end.x, end.y-level*30, end.z);
    pillar1_len = end.sub(pillar1);
    pillar2_len = end.sub(pillar2);
    pillar3_len = end.sub(pillar3);
    pillar4_len = end.sub(pillar4);
    pillar5_len = end.sub(pillar5);
    pillar6_len = end.sub(pillar6);

    if (!start.inPhysics) {
      physics.addParticle(start);
      start.inPhysics = true;
      start.lock();
    }
    if (!end.inPhysics) {
      physics.addParticle(end);
      end.inPhysics = true;
    }


    VerletConstrainedSpring spring = new VerletConstrainedSpring
      (start,end,len.magnitude(), 0.01f,len.magnitude() );
    physics.addSpring(spring);

    //structural support

    physics.addParticle(pillar1);
    physics.addParticle(pillar2);
    physics.addParticle(pillar3);
    physics.addParticle(pillar4);
    physics.addParticle(pillar5);
    physics.addParticle(pillar6);

    pillar1.lock();    
    pillar2.lock();
    pillar3.lock();
    pillar4.lock();    
    pillar5.lock();
    pillar6.lock();
    VerletConstrainedSpring pillar1_spring = new VerletConstrainedSpring
      (pillar1,end,pillar1_len.magnitude(), 0.09f/sq(level),pillar1_len.magnitude() );
    VerletConstrainedSpring pillar2_spring = new VerletConstrainedSpring
      (pillar2,end,pillar2_len.magnitude(), 0.09f/sq(level),pillar2_len.magnitude() );
    VerletConstrainedSpring pillar3_spring = new VerletConstrainedSpring
      (pillar3,end,pillar3_len.magnitude(), 0.09f/sq(level),pillar3_len.magnitude() );
    VerletConstrainedSpring pillar4_spring = new VerletConstrainedSpring
      (pillar4,end,pillar4_len.magnitude(), 0.09f/sq(level),pillar4_len.magnitude() );
    VerletConstrainedSpring pillar5_spring = new VerletConstrainedSpring
      (pillar5,end,pillar5_len.magnitude(), 0.09f/sq(level),pillar5_len.magnitude() );
    VerletConstrainedSpring pillar6_spring = new VerletConstrainedSpring
      (pillar6,end,pillar6_len.magnitude(), 0.09f/sq(level),pillar6_len.magnitude() );
    physics.addSpring(pillar1_spring);
    physics.addSpring(pillar2_spring);
    physics.addSpring(pillar3_spring);
    physics.addSpring(pillar4_spring);
    physics.addSpring(pillar5_spring);
    physics.addSpring(pillar6_spring);
  }

  public void unlock() {
    start.unlock();
    end.unlock();
  }


  public void reset() {
    branched = false;
  }

  // Draw a line at location
  public void render() {
    stroke(255);
    strokeWeight(1);


    // ellipse(start.x,start.y, start.z,4,4);
    // ellipse(end.x,end.y, end.z,4,4);
    
    for (int i = 0; i< thick; i++ ){
      float h = thick/2;
    line(start.x+random(-h,h),start.y+random(-h,h), start.z+random(-h,h)
      ,end.x+random(-h,h),end.y+random(-h,h), end.z+random(-h,h));
    }
    
    noStroke();
    fill(0);

    float theta = degrees(len.headingXY());
    float phi = degrees(len.headingYZ());
    String txt = "theta:"+theta+" phi:"+phi+";";
    fill(255);
    //  text(txt, end.x, end.y, end.z);

    stroke(255, 100);
    strokeWeight(1);
    if (structure) {
      line(end.x,end.y,end.z, pillar1.x, pillar1.y,pillar1.z);
      line(end.x,end.y,end.z, pillar2.x, pillar2.y,pillar2.z);
      line(end.x,end.y,end.z, pillar3.x, pillar3.y,pillar3.z);
      line(end.x,end.y,end.z, pillar4.x, pillar4.y,pillar4.z);
      line(end.x,end.y,end.z, pillar5.x, pillar5.y,pillar5.z);
      line(end.x,end.y,end.z, pillar6.x, pillar6.y,pillar6.z);
    }
  }


  public boolean branched() {
    if (branched) {
      return true;
    } 
    else {
      return false;
    }
  }



  public void endpoint() {
    branched = true;
  }

  // Create a new branch at the current location, but change direction by a given angle
  public Branch branch(float angleXY, float angleYZ) {
    // What is my current heading
    float theta = len.headingXY();
    float phi = len.headingYZ();




    float mag = len.magnitude()*ratio*random(0.8f,1.2f);
    float newthick = thick*ratio;
    int newlevel = level+1;
    // Turn me
    theta += radians(angleXY);
    phi += radians(angleYZ);

    // polar coordinates to cartesian


    Particle newend = new Particle(mag*cos(theta),mag*sin(theta),mag*cos(phi));
    newend.addSelf(end);
    branched = true;
    return new Branch(end,newend, newthick, newlevel);
  }



  public void generateBranches() {

    float theta = degrees(len.headingXY());
    float phi = degrees(len.headingYZ());
    float chanceL,chanceR, chanceF, chanceB;
 
   
    chanceL = map(constrain(theta+180,85,180),5,180,.99f,.3f);
    chanceR = map(constrain(theta+180,0,95),95,0,.99f,.3f);
     
    chanceB = map(constrain(phi+180,85,180),5,180,.99f,.3f);
    chanceF = map(constrain(phi+180,0,95),95,0,.99f,.3f);
    
    
    //println  ("theta:"+theta+" phi:"+phi+"; chancey:"+chancey+" chancez:"+chancez);

    if (!branched) {
      if (a.size() < maxbranches) {

        if (random(1.0f) < chanceL ) { 
          a.add(branch(random(5,15)*-5, random(-5,5)*5));   // Add one going left
        } 
        if (random(1.0f) < chanceR ) {  
          a.add(branch(random(5,15)*5, random(-5,6)*5));   // Add one going right
        }
        if (random(1.0f) < chanceF ) { 
          a.add(branch(random(-5,6)*5, random(5,15)*5));   // Add one going front
        }
        if (random(1.0f) < chanceB ) { 
          a.add(branch(random(-5,6)*5, random(5,15)*-5));   // Add one going back
        }
      }
    }
  }

  public void generateLeaves() {
    if(!branched&&!leafed) {
      leaves.add(new Leaf(end));
      leafed = true;
    }
  }
}

class Leaf {
  Particle leaf, end;
  VerletSpring spring;
  float d;

  Leaf(Particle l) {
    end = l;
    leaf = new Particle (l.x, l.y, l.y);
    physics.addParticle(leaf);

    spring = new VerletSpring(l,leaf,.001f, 1);
    physics.addSpring(spring);
  }

  public void display() {
    noStroke();
    ellipseMode(CENTER);
    rectMode(CENTER);
    fill(255);
    strokeWeight(1);
    stroke(255);
    pushMatrix();
    translate(leaf.x,leaf.y,leaf.z);
    for (int i = 0; i < d; i++) {
      line(random(d),random(d),random(d),random(d),random(d),random(d));
    }
    popMatrix();
    if (d< 14) {
      d+=.1f;
    }
  }


  public void fall() {
    physics.removeSpring(spring);
  }
}


}
class Particle extends VerletParticle {
  boolean inPhysics = false;

  Particle(float x, float y, float z) {
    super(x,y, z);
  }

  public void display() {
    point(x,y, z);
  }
}

class Wind {
  ConstantForceBehavior wind;
  Vec3D w;
  float n,r,s, xoff,yoff,zoff,d;
  Wind() {
    w = new Vec3D(0.2f,0,0);
    wind = new ConstantForceBehavior(w);
    physics.addBehavior(wind);
    xoff = 13354;
    yoff = 30045;
    zoff = 2033;
  }

  public void update() {
    n = map(noise(xoff), 0,1,-.0001f,.0001f); 
    xoff+= .01f;
    r = map(noise(yoff), 0,1,-.01f,.01f); 
    yoff+= .01f;
    s = map(noise(zoff), 0,1,-.0001f,.0001f); 
    zoff+= .01f;
    w.rotateX(n); 
    w.rotateY(r); 
    w.rotateZ(s); 
    w.scale(.975f+(noise(xoff)/20));

    wind.setForce(w);
  }
}

class Fear {

  AudioInput in;
  AudioPlayer[] susto1 = new AudioPlayer[3];
  AudioPlayer[] susto2 = new AudioPlayer[3];
  AudioPlayer[] susto3 = new AudioPlayer[3];

  float average = 0;
  ConstantForceBehavior fear;
  Vec3D f;
  float n,r,s, sc;

  Fear() {
    f = new Vec3D(0.001f,0,0);
    fear = new ConstantForceBehavior(f);
    physics.addBehavior(fear);

    // get a line in from Minim, default bit depth is 16
    in = minim.getLineIn(Minim.STEREO, 512);

    // load files
    for (int i = 0; i < 3; i++) {
      susto1[i] = minim.loadFile("susto_nivel1-"+i+".wav", 2048);
      susto2[i] = minim.loadFile("susto_nivel2-"+i+".wav", 2048);
      susto3[i] = minim.loadFile("susto_nivel3-"+i+".wav", 2048);
      susto3[i].setGain(10);
    }
    
  }

  public void update() {

    for(int i = 0; i < in.bufferSize() - 1; i++) {
      average +=abs(in.mix.get(i)*50);
    }
    average = average/in.bufferSize();
    sc = PApplet.parseInt(average*3000);



    n = random(0,TWO_PI); 
    r = random(0,TWO_PI); 
    s = random(0,TWO_PI); 

    f.rotateX(n); 
    f.rotateY(r); 
    f.rotateZ(s); 
    fear.setForce(f.scale(sc));
    println (sc);

    if (sc > 25000) {
      if (!susto1[0].isPlaying() && !susto1[1].isPlaying() && !susto1[2].isPlaying() ) {  
        susto1[PApplet.parseInt(random(3))].play();
      }
    }
    if (sc > 40000) {
      t[0].fall(.03f);
      if (!susto2[0].isPlaying() && !susto2[1].isPlaying() && !susto2[2].isPlaying() ) {  
        susto2[PApplet.parseInt(random(3))].play();
      }
    }
    if (sc > 55000) {
      t[0].fall(.2f);
      if (!susto3[0].isPlaying() && !susto3[1].isPlaying() && !susto3[2].isPlaying() ) {  
        susto3[PApplet.parseInt(random(3))].play();
      }
    }
  text(sc, -300,-200);

    for (int i = 0; i < 3; i++) {
      if (susto1[i].length() == susto1[i].position()) {
        susto1[i].rewind();
      }
      if (susto2[i].length() == susto2[i].position()) {
        susto2[i].rewind();
      }
      if (susto3[i].length() == susto3[i].position()) {
        susto3[i].rewind();
      }
    }
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#000000", "--stop-color=#222222", "tree_recursion_7_3D" });
  }
}
