// global variables
float averageLeft, averageRight, dif, scaleLeftAvg, scaleRightAvg, scaleLeft,scaleRight;
  
class Fear {

  AudioInput in;
  FFT fftLeft;
  FFT fftRight;

  AudioPlayer[] susto1 = new AudioPlayer[3];
  AudioPlayer[] susto2 = new AudioPlayer[3];
  AudioPlayer[] susto3 = new AudioPlayer[3];





  ConstantForceBehavior fearForceLeft, fearForceRight;
  Vec3D fearLeft, fearRight;

  float n,r,s;




  Fear() {
    fearLeft = new Vec3D(0.001,0,0);
    fearRight = new Vec3D(-0.001,0,0);

    fearForceLeft = new ConstantForceBehavior(fearLeft);
    fearForceRight = new ConstantForceBehavior(fearRight);

    physics.addBehavior(fearForceLeft);
    physics.addBehavior(fearForceRight);


    



    // get a line in from Minim, default bit depth is 16
    in = minim.getLineIn(Minim.STEREO, 512);
    fftLeft = new FFT(in.bufferSize(), in.sampleRate());
    fftRight = new FFT(in.bufferSize(), in.sampleRate());

    // load files
    for (int i = 0; i < 3; i++) {
      susto1[i] = minim.loadFile("susto_nivel1-"+i+".wav", 2048);
      susto2[i] = minim.loadFile("susto_nivel2-"+i+".wav", 2048);
      susto3[i] = minim.loadFile("susto_nivel3-"+i+".wav", 2048);
      susto3[i].setGain(10);
    }
  }

  Vec3D f() {
    Vec3D fear = fearLeft.add(fearRight);

    return fear;
  }

  void update() {

    averageLeft = averageRight = 0;

    fftLeft.forward(in.left);
    fftRight.forward(in.right);

    fftLeft.window(FFT.HAMMING);
    fftRight.window(FFT.HAMMING);

    int resolution = 0; 

    for(int i = LOWCUT; i < HIGHCUT - 1; i++)
    {
      averageLeft +=fftLeft.getBand(i)*4;
      averageRight +=fftRight.getBand(i)*4;
      resolution++;

      if(debugON) {
        stroke(255);
        line(i-width/2, -height+top+220, 0, i-width/2, -height+top+220 - fftLeft.getBand(i)*4, 0);
        line(i-width/2, -height+top+260, 0, i-width/2, -height+top+260 - fftRight.getBand(i)*4, 0);
      }
    }

    averageLeft = averageLeft/resolution;
    averageRight = averageRight/resolution;

    dif = abs(averageLeft-averageRight);  
    if(averageLeft > averageRight) {
      averageRight *= .1;
    } 
    else {   
      averageLeft *= .1;
    }


    scaleLeft = averageLeft*averageLeft*SENSITIVITY;
    scaleRight = averageRight*averageRight*SENSITIVITY;

    if (debugON) {
      noStroke();
      fill(255);



  
      
    }

    //println ("avg left = "+averageLeft + " avg Right = " + averageRight);

    if (mode == "totem"){
    n = random(-PI, PI); 
    r = random(-PI, PI); 
    s = random(-PI, PI); 
    }else{
    n = random(-PI/4, PI/4); 
    r = random(-PI/4, PI/4); 
    s = random(-PI/4, PI/4); 
    }
    fearLeft.set(0.001,0,0);
    fearLeft.rotateX(n); 
    fearLeft.rotateY(r); 
    fearLeft.rotateZ(s); 

    fearLeft = fearLeft.scale(scaleLeft);
    fearForceLeft.setForce(fearLeft);
    //println (sc);



   if (mode == "totem"){
    n = random(-PI, PI); 
    r = random(-PI, PI); 
    s = random(-PI, PI); 
    }else{
    n = random(-PI/4, PI/4); 
    r = random(-PI/4, PI/4); 
    s = random(-PI/4, PI/4); 
    }
    fearRight.set(-0.001,0,0);
    fearRight.rotateX(n); 
    fearRight.rotateY(r); 
    fearRight.rotateZ(s); 

    fearRight = fearRight.scale(scaleRight);
    fearForceRight.setForce(fearRight);
    //println (sc);



    if (scaleLeft > 25000 || scaleRight > 25000) {
      if (!susto1[0].isPlaying() && !susto1[1].isPlaying() && !susto1[2].isPlaying() ) {  
        susto1[int(random(3))].play();
      }
    }
    if (scaleLeft > 40000 || scaleRight > 40000 ) {
      t.fall(0.1);
      if (!susto2[0].isPlaying() && !susto2[1].isPlaying() && !susto2[2].isPlaying() ) {  
        susto2[int(random(3))].play();
      }
    }
    if (scaleLeft > 55000 || scaleRight > 55000) {
      t.fall(.4);
      t.fallBranch(0.2);  
      if (!susto3[0].isPlaying() && !susto3[1].isPlaying() && !susto3[2].isPlaying() ) {  
        susto3[int(random(3))].play();
      }
    }


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

