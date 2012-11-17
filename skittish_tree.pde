// Reactive Tree
// Martin Bravo <http://www.bravomartin.cl>
// Using code from Daniel Shifmann'sRecursive Tree
// Daniel Shiffman <http://www.shiffman.net>

// Audio Background and Effects by Merche Blasco
// <http://half-half.es/>

import toxi.physics.*;
import toxi.physics.behaviors.*;
import toxi.geom.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.opengl.*;

boolean debugON;
String mode = "totem"; // test, totem, window or paley
Boolean structure = false;


String[] DATA;
int SENSITIVITY, LOWCUT, HIGHCUT;


// start minim and the object for the ambient sounds.
Minim minim;
AudioPlayer ambientSound;

// Reference to physics world
VerletPhysics physics;
Debug debug;


Wind wind;
Fear fear;

Tree t;

void setup() {
  
  noCursor();

  DATA = loadStrings("data/DATA_"+mode.toLowerCase()+".dt");
  
  SENSITIVITY = int(DATA[0]);
  LOWCUT = int(DATA[1]);
  HIGHCUT = int(DATA[2]);
  debugON = boolean(DATA[3]);

  if (mode == "test") {
    size(600, 700, OPENGL);
  } 
  else if (mode == "totem") {
    size(1280, 1024, OPENGL); // tootem
  }
  else if (mode == "window") {
    size(1080, 1960, OPENGL); // JS55
  }
  else if (mode == "paley") {
    size(1280, 800, OPENGL); // Paley Center
    noCursor();
  }

  smooth();
  frameRate(25);


  //Initialize minim
  minim = new Minim(this);
  minim.debugOff(); 
  ambientSound = minim.loadFile("ambient_full_loop.wav", 2048);
  ambientSound.setGain(5);
  ambientSound.loop();  

  // Initialize the physics
  physics=new VerletPhysics();
  physics.setWorldBounds(new AABB(new Vec3D(0, -3000, 0), 3000));
  physics.setDrag(0.02f);
  physics.addBehavior(new GravityBehavior(Vec3D.Y_AXIS.scale(1.9)));

  // the force objects
  wind = new Wind();
  fear = new Fear();

  //Initialize the Debug object
  debug = new Debug();

  if (mode == "test") {
    t = new Tree(new Vec3D(0, 0, 0), 150, 300, 20, .6);
  } 
  else if (mode == "window") {
    t = new Tree(new Vec3D(0, 0, 0), 400, 300, 30, .6);
  }
  else if (mode == "totem") {
    t = new Tree(new Vec3D(0, 0, 0), 250, 300, 25, .6);
  }
  else if (mode == "paley") {
    t = new Tree(new Vec3D(0, 0, 0), 310, 300, 28, .62);
  }
  t.reset();
}

void draw() {
  background(0);
  if (mode == "test") {
    translate(width/2, height-10);
    //scale(float(mouseX)/100);
  }
  else if (mode == "window") {
    translate(width/2, height-400); //JS55
  }
 else if (mode == "paley") {
    translate(80, height/2); //JS55
    rotateZ(PI/2);
  } 
  else if (mode == "totem") {
    translate(180, height/2);
    rotateZ(PI/2);
  }
  // update everything
  wind.update();
  fear.update();
  physics.update();

  // t.update();
  t.render();
  debug.display();

  
  if (isCurrentTime("9:0:0") || isCurrentTime("14:0:0") || physics.particles.size() > 5000 ){
      println("Super Reset");
      setup();
  }
  
  
}




//to see the underlying spring structure.

void keyPressed() {
  
  if (key == 'd') {
    debugON = !debugON;
  }
  if (debugON){
    if (key == 's') {
      structure = !structure;
    }
    if (key == 'r') {
      t.reset();
    }
    if (key == 'f') {
      t.fall(0.5);
      t.fallBranch(0.5);
    }
    if (key == 'w') {
      //super reset!
      setup();
    }
    if (key == 'u') {
      SENSITIVITY*=1.2;
    }
    if (key == 'j') {
      SENSITIVITY*=0.8;
    }
    if (key == 'h' && LOWCUT >= 1) {
      LOWCUT-=1;
    }
    if (key == 'y' && LOWCUT < HIGHCUT) {
      LOWCUT+=1;
    }
    if (key == 'g' && HIGHCUT > LOWCUT) {
      HIGHCUT-=1;
    }
    if (key == 't' && HIGHCUT <= 512) {
      HIGHCUT+=1;
    }
  }  
  DATA[0] = str(SENSITIVITY);
  DATA[1] = str(LOWCUT);
  DATA[2] = str(HIGHCUT);
  DATA[3] = str(debugON);

  saveStrings("data/DATA_"+mode.toLowerCase()+".dt", DATA);

}

void stop() {
  // always close Minim audio classes when you are done with them
  ambientSound.close();
  // always stop Minim before exiting.
  minim.stop();

  super.stop();
}



