class Branch {
  Particle start,end,pillar1,pillar2, pillar3, pillar4, pillar5, pillar6, fallingStart, fallingEnd;
  VerletConstrainedSpring spring, pillar1_spring, pillar2_spring, pillar3_spring, pillar4_spring, pillar5_spring, pillar6_spring, fallingSpring;
  Vec3D len, pillar1_len, pillar2_len, pillar3_len, pillar4_len, pillar5_len, pillar6_len;
  float thick; // thickness of the branch
  int level, maxperbranch, numbranches, id;

  boolean branched = false;
  boolean leafed = false;
  boolean falling = false;
  boolean trunk = false;

  Timer dieTimer;

  Branch(Particle s, Particle e, float _th, int _l, int _maxb, int _id) {
    start = s;
    end = e;
    maxperbranch = _maxb;
    thick = _th;
    level = _l;
    len = end.sub(start);
    numbranches = 0;
    id = _id;
    dieTimer = new Timer(2000);    

    if (level == 1) {
      trunk = true;
    }

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


    spring = new VerletConstrainedSpring (start,end,len.magnitude(), 0.1 );
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

    pillar1_spring = new VerletConstrainedSpring (pillar1,end,pillar1_len.magnitude(), 0.09/sq(level));
    pillar2_spring = new VerletConstrainedSpring (pillar2,end,pillar2_len.magnitude(), 0.09/sq(level));
    pillar3_spring = new VerletConstrainedSpring (pillar3,end,pillar3_len.magnitude(), 0.09/sq(level));
    pillar4_spring = new VerletConstrainedSpring (pillar4,end,pillar4_len.magnitude(), 0.09/sq(level));
    pillar5_spring = new VerletConstrainedSpring (pillar5,end,pillar5_len.magnitude(), 0.09/sq(level));
    pillar6_spring = new VerletConstrainedSpring (pillar6,end,pillar6_len.magnitude(), 0.09/sq(level));

    physics.addSpring(pillar1_spring);
    physics.addSpring(pillar2_spring);
    physics.addSpring(pillar3_spring);
    physics.addSpring(pillar4_spring);
    physics.addSpring(pillar5_spring);
    physics.addSpring(pillar6_spring);
  }

  void unlock() {
    start.unlock();
    end.unlock();
  }


  void reset() {
    branched = false;
    numbranches = 0;
  }

  int getID () {
    return id;
  }

  // Draw a line at location
  void render() {
    stroke(255);
    strokeWeight(1);


    // ellipse(start.x,start.y, start.z,4,4);
    // ellipse(end.x,end.y, end.z,4,4);


    for (int i = 0; i< thick; i++ ) {
      float h = thick/2;
      stroke(255);

      if (falling == true) {
        line(fallingStart.x+random(-h,h),fallingStart.y+random(-h,h), fallingStart.z+random(-h,h)
          ,end.x+random(-h,h),end.y+random(-h,h), end.z+random(-h,h));
      }
      else {
        line(start.x+random(-h,h),start.y+random(-h,h), start.z+random(-h,h)
          ,end.x+random(-h,h),end.y+random(-h,h), end.z+random(-h,h));
      }
    }
    noStroke();
    fill(255);
    if (debugON) {
      text ("   id: "+id + ", "+ numbranches + " branches", end.x,end.y,end.z);
    }
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

    if(numbranches < 0) {
      numbranches = 0;
    }
  }


  boolean branched() {
    if (branched) {
      return true;
    } 
    else {
      return false;
    }
  }


  // Create a new branch at the current location, but change direction by a given angle
  Branch branch(float angleXY, float angleYZ) {
    // What is my current heading
    float theta = len.headingXY();
    float phi = len.headingYZ();


    float mag = len.magnitude()*ratio*random(0.9,1.1);
    float newthick = thick*ratio;
    int newlevel = level+1;

    int newid = id*10+(numbranches+1);

    // println(id + " " + newid);
    // Turn me
    theta += radians(angleXY);
    phi += radians(angleYZ);

    // polar coordinates to cartesian

    Particle newend = new Particle(mag*cos(theta),mag*sin(theta),mag*cos(phi));
    newend.addSelf(end);

    return new Branch(end,newend, newthick, newlevel, int(random(2,5)), newid);
  }





  void generateBranches() {

    float theta = degrees(len.headingXY());
    float phi = degrees(len.headingYZ());
    float chanceL,chanceR, chanceF, chanceB;


    chanceL = map(constrain(theta+180,85,130),85,130,.99,.3);
    chanceR = map(constrain(theta+180,50,95),95,50,.99,.3);

    chanceB = map(constrain(phi+180,85,130),85,130,.99,.3);
    chanceF = map(constrain(phi+180,50,95),95,50,.99,.3);

    if (numbranches >= maxperbranch) {
      branched = true;
    }
    if (!branched && level < 6) {
      if (a.size() < maxbranches) {

        if (random(1.0) < chanceL/(3*level) && numbranches <= maxperbranch  && random(1) < .05/level ) { 
          a.add(branch(random(5,15)*-5, random(-5,5)*5));   // Add one going left
          numbranches +=1;
        } 
        if (random(1.0) < chanceR/(3*level) && numbranches <= maxperbranch  && random(1) < .05/level ) {  
          a.add(branch(random(5,15)*5, random(-5,5)*5));   // Add one going right
          numbranches +=1;

        }
        if (random(1.0) < chanceF/(3*level)  && numbranches <= maxperbranch  && random(1) < .05/level ) { 
          a.add(branch(random(-5,5)*5, random(5,15)*5));   // Add one going front
          numbranches +=1;
        }
        if (random(1.0) < chanceB/(3*level)  && numbranches <= maxperbranch  && random(1) < .05/level ) { 
          a.add(branch(random(-5,5)*5, random(5,15)*-5));   // Add one going back
          numbranches +=1;
        }
      }
    }
  }

  void generateLeaves(float chance) {
    if(!branched&&!leafed && random(1.0f) < chance ) {
      leaves.add(new Leaf(end));
      leafed = true;
    }
  }


  void fall() {
    physics.removeSpring(pillar1_spring);
    physics.removeSpring(pillar2_spring);
    physics.removeSpring(pillar3_spring);
    physics.removeSpring(pillar4_spring);
    physics.removeSpring(pillar5_spring);
    physics.removeSpring(pillar6_spring);

    physics.removeParticle(pillar1);    
    physics.removeParticle(pillar2);    
    physics.removeParticle(pillar3);    
    physics.removeParticle(pillar4);    
    physics.removeParticle(pillar5);    
    physics.removeParticle(pillar6);    


    fallingStart = new Particle (start.x, start.y, start.z);

    physics.addParticle(fallingStart);

    fallingStart.setWeight(3);
   

    fallingSpring = new VerletConstrainedSpring (fallingStart,end,len.magnitude(), 0.1 );
    physics.addSpring(fallingSpring);
    physics.removeSpring(spring);
    falling = true;
    dieTimer.start();
  }

  boolean isDead = false;

  void die() {
    physics.removeSpring(fallingSpring);
    physics.removeParticle(fallingStart);
    physics.removeParticle(end);
    if (!falling) {
      physics.removeSpring(pillar1_spring);
      physics.removeSpring(pillar2_spring);
      physics.removeSpring(pillar3_spring);
      physics.removeSpring(pillar4_spring);
      physics.removeSpring(pillar5_spring);
      physics.removeSpring(pillar6_spring);

      physics.removeParticle(pillar1);    
      physics.removeParticle(pillar2);    
      physics.removeParticle(pillar3);    
      physics.removeParticle(pillar4);    
      physics.removeParticle(pillar5);    
      physics.removeParticle(pillar6);    

      physics.removeSpring(spring);
      physics.removeParticle(start);
    }
    isDead = true;
  }

  boolean dead () {
    if (!trunk && ( end.x > width/2+300 || end.x < -width/2-300 || end.y < -height-300) ) {
      die();
    }
    if (!trunk && ( end.y > -10 || dieTimer.isFinished() ) ) {
      die();
    }
    return isDead;
  }
}

