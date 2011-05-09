class Leaf {
  Particle leaf, end;
  VerletSpring spring;
  float d;

  Leaf(Particle l) {
    end = l;
    leaf = new Particle (l.x, l.y, l.y);
    physics.addParticle(leaf);

    spring = new VerletSpring(l,leaf,.001, 1);
    physics.addSpring(spring);
  }

  void display() {
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
      d+=.1;
    }
  }


  void fall() {
    physics.removeSpring(spring);
  }
}


}
