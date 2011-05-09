class Fear {

  AudioInput in;
  AudioPlayer[] susto = new AudioPlayer[5];
  AudioPlayer[] ramas = new AudioPlayer[3];
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
    for (int i = 0; i < 5; i++) {
      susto[i] = minim.loadFile("susto"+i+".wav", 2048);
    }
    for (int i = 0; i < 3; i++) {
      ramas[i] = minim.loadFile("ramas"+i+".wav", 2048);
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

    if (sc > 10000) {
      t[0].fall();
      if (!susto[0].isPlaying() && !susto[1].isPlaying() 
        && !susto[2].isPlaying() && !susto[3].isPlaying() && !susto[4].isPlaying() ) {  
        susto[int(random(5))].play();
      }
      if (sc > 30000) {
        t[0].fall();
        if (!ramas[0].isPlaying() && !ramas[1].isPlaying() 
          && !ramas[2].isPlaying()) {  
          susto[int(random(3))].play();
        }
      }
    }

    for (int i = 0; i < 5; i++) {
      if (susto[i].length() == susto[i].position()) {
        susto[i].rewind();
      }
      for (int j = 0; j < 3; j++) {
        if (ramas[j].length() == ramas[j].position()) {
          ramas[j].rewind();
        }
        }
      }
    }
  }

