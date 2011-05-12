

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
      (start,end,len.magnitude(), 0.01,len.magnitude() );
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
      (pillar1,end,pillar1_len.magnitude(), 0.09/sq(level),pillar1_len.magnitude() );
    VerletConstrainedSpring pillar2_spring = new VerletConstrainedSpring
      (pillar2,end,pillar2_len.magnitude(), 0.09/sq(level),pillar2_len.magnitude() );
    VerletConstrainedSpring pillar3_spring = new VerletConstrainedSpring
      (pillar3,end,pillar3_len.magnitude(), 0.09/sq(level),pillar3_len.magnitude() );
    VerletConstrainedSpring pillar4_spring = new VerletConstrainedSpring
      (pillar4,end,pillar4_len.magnitude(), 0.09/sq(level),pillar4_len.magnitude() );
    VerletConstrainedSpring pillar5_spring = new VerletConstrainedSpring
      (pillar5,end,pillar5_len.magnitude(), 0.09/sq(level),pillar5_len.magnitude() );
    VerletConstrainedSpring pillar6_spring = new VerletConstrainedSpring
      (pillar6,end,pillar6_len.magnitude(), 0.09/sq(level),pillar6_len.magnitude() );
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
  }

  // Draw a line at location
  void render() {
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


  boolean branched() {
    if (branched) {
      return true;
    } 
    else {
      return false;
    }
  }



  void endpoint() {
    branched = true;
  }

  // Create a new branch at the current location, but change direction by a given angle
  Branch branch(float angleXY, float angleYZ) {
    // What is my current heading
    float theta = len.headingXY();
    float phi = len.headingYZ();




    float mag = len.magnitude()*ratio*random(0.8,1.2);
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



  void generateBranches() {

    float theta = degrees(len.headingXY());
    float phi = degrees(len.headingYZ());
    float chanceL,chanceR, chanceF, chanceB;
 
   
    chanceL = map(constrain(theta+180,85,180),85,180,.99,.3);
    chanceR = map(constrain(theta+180,0,95),95,0,.99,.3);
     
    chanceB = map(constrain(phi+180,85,180),85,180,.99,.3);
    chanceF = map(constrain(phi+180,0,95),95,0,.99,.3);
    
    
    //println  ("theta:"+theta+" phi:"+phi+"; chancey:"+chancey+" chancez:"+chancez);

    if (!branched) {
      if (a.size() < maxbranches) {

        if (random(1.0) < chanceL ) { 
          a.add(branch(random(5,15)*-5, random(-5,5)*5));   // Add one going left
        } 
        if (random(1.0) < chanceR ) {  
          a.add(branch(random(5,15)*5, random(-5,6)*5));   // Add one going right
        }
        if (random(1.0) < chanceF ) { 
          a.add(branch(random(-5,6)*5, random(5,15)*5));   // Add one going front
        }
        if (random(1.0) < chanceB ) { 
          a.add(branch(random(-5,6)*5, random(5,15)*-5));   // Add one going back
        }
      }
    }
  }

  void generateLeaves() {
    if(!branched&&!leafed) {
      leaves.add(new Leaf(end));
      leafed = true;
    }
  }
}

