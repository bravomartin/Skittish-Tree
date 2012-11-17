// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 10-5: Object-oriented timer

class Timer {
 
  int savedTime; // When Timer started
  int totalTime; // How long Timer should last
  boolean started = false;
  
  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }
  
  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis(); 
    started = true;
  }
  
  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime && started) {
      return true;
    } else {
      return false;
    }
  }
}



boolean isCurrentTime(String t) {
    String time = hour()+":"+minute()+":"+second();
    if (t.equals(time)){
    return true;
    }
    else{
    return false;
  }
}



public float montecarlo(float minimum, float maximum) {
  float range = maximum - minimum;
  // Have we found one yet
  boolean foundone = false;
  int hack = 0;  // let's count just so we don't get stuck in an infinite loop by accident
  while (!foundone && hack < 10000) {
    // Pick two random numbers
    float r1 = (float) random(1);
    float r2 = (float) random(1);
    float y = r1*r1;  // y = x*x (change for different results)
    // If r2 is valid, we'll use this one
    if (r2 < y) {
      foundone = true;
      r1 = 1-r1;
      float result = r1*range + minimum;
      return result;
    }
    hack++;
  }
  // Hack in case we run into a problem (need to improve this)
  return 0;
}
