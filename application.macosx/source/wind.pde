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

  void update() {
    n = map(noise(xoff), 0,1,-.0001,.0001); 
    xoff+= .01;
    r = map(noise(yoff), 0,1,-.01,.01); 
    yoff+= .01;
    s = map(noise(zoff), 0,1,-.0001,.0001); 
    zoff+= .01;
    w.rotateX(n); 
    w.rotateY(r); 
    w.rotateZ(s); 
    w.scale(.975+(noise(xoff)/20));

    wind.setForce(w);
  }
}

