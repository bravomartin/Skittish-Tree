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
    f = new Vec3D(0.001,0,0);
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

  void update() {

    for(int i = 0; i < in.bufferSize() - 1; i++) {
      average +=abs(in.mix.get(i)*50);
    }
    average = average/in.bufferSize();
    sc = int(average*3000);



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
        susto1[int(random(3))].play();
      }
    }
    if (sc > 40000) {
      t[0].fall(.03);
      if (!susto2[0].isPlaying() && !susto2[1].isPlaying() && !susto2[2].isPlaying() ) {  
        susto2[int(random(3))].play();
      }
    }
    if (sc > 55000) {
      t[0].fall(.2);
      if (!susto3[0].isPlaying() && !susto3[1].isPlaying() && !susto3[2].isPlaying() ) {  
        susto3[int(random(3))].play();
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

