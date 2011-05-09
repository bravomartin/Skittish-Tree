// Reactive Tree
// Martin Bravo <http://www.bravomartin.cl>
// Based on code from Daniel Shifmann'sRecursive Tree
// and Jer Thorp's Sperical Coordinates Tutorial
// Daniel Shiffman <http://www.shiffman.net>
// Jer Thorp http://blog.blprnt.com/blog/blprnt/processing-tutorial-spherical-coordinates

// we first import the libraries
import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.geom.*;
import ddf.minim.*;
import processing.opengl.*;


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

void setup() {
  size(1280,800,OPENGL);
  smooth();
  frameRate(20);

  //Initialize minim
  minim = new Minim(this);
  minim.debugOn(); 
  ambientSound = minim.loadFile("bosque1.wav", 2048);
  ambientSound.loop();  

  // Initialize the physics
  physics=new VerletPhysics();
  physics.setDrag(0.02f);
  physics.addBehavior(new GravityBehavior(Vec3D.Y_AXIS.scale(1.5)));

  // and the force objects
  wind = new Wind();
  fear = new Fear();


  for (int i = 0; i < 1; i++) {
    t[i] = new Tree(new Vec3D(i*300,height/2,i*-300), 180, 300, 33, .60);
    t[i].reset();
  }
}
float rotationY = 0;
void draw() {
  background(0);
  translate(width/2,height/2);
  rotateY(rotationY);
  rotationY+=.001;

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
void keyPressed() {
  if (key == 's') {
    structure = !structure;
  }
  
  if (key == 'r') {
    t[0].reset();
  }
}

void stop()
{
  // always close Minim audio classes when you are done with them
  ambientSound.close();
  // always stop Minim before exiting.
  minim.stop();

  super.stop();
}

