class Particle extends VerletParticle {
  boolean inPhysics = false;

  Particle(float x, float y, float z) {
    super(x,y, z);
  }

  void display() {
    point(x,y, z);
  }
}

