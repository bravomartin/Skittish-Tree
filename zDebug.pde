// global variable
int top;

class Debug {
  PFont courier; 
  Timer timer;  


  Debug() {
    if (mode == "test") {
      top = 30;
    }
    else if (mode == "totem") {
      top = 30;
    }
    else if (mode == "window") {
      top = 500;
    }
    else if (mode == "paley") {
      top = 30;
    }

    courier = loadFont("data/courier-12.vlw"); 
    timer = new Timer(300);    
    timer.start();
  }

  void display() {

    if(debugON) {
    pushMatrix();
      if(mode == "paley"){
      translate(255, 580);
      }
      if(mode == "totem"){
      translate(150, 100);
      }      if (timer.isFinished()) {
        scaleLeftAvg = scaleLeft;
        scaleRightAvg = scaleRight;  
        timer.start();
      }

      textFont(courier); 
      text ("Debug mode ON [D]", -width/2+10,-height+top,0);
      text ("sensitivity [+U | -J] : "+SENSITIVITY, -width/2+10,-height+top+20,0);
      text ("LOWCUT [+Y | -H]      : "+LOWCUT, -width/2+10,-height+top+40,0);
      text ("HIGHCUT [+G | -T]     : "+HIGHCUT, -width/2+10,-height+top+60,0);
      text ("left                  : "+scaleRightAvg, -width/2+10,-height+top+80,0);
      text ("right                 : "+scaleLeftAvg, -width/2+10,-height+top+100,0);
      text ("R to reset, F to try leaves and branches falling.", -width/2+10,-height+top+120,0);
      text (t.a.size()+ " branches, " + t.leaves.size() + " leaves", -width/2+10,-height+top+140,0);
      text ("Frame Rate: "+ int(frameRate) + ", "+ physics.particles.size() +" particles", -width/2+10,-height+top+160,0 );
      text ("Frame Rate: "+ int(frameRate) + ", "+ physics.springs.size() +" springs", -width/2+10,-height+top+180,0 );

      String timertext;
      if (twoMinutes.isFinished()) {
        timertext = "Ready to reset!";
      } 
      else {
        timertext = "Not ready to reset.";
      }
      text (timertext, -width/2+10,-height+top+200,0 );
    popMatrix();
    }
  }
}

