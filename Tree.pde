Timer twoMinutes;

class Tree {
  ArrayList a;
  ArrayList leaves;
  Particle root, trunk;
  Vec2D trunk_;
  int maxbranches;
  float thickness;
  float ratio;


  Tree(Vec3D r, int t, int s, float th, float ratio_) {
    twoMinutes = new Timer(120000);
    twoMinutes.start();
    root = new Particle (r.x, r.y, r.z);

    trunk = new Particle (r.x, r.y-t, r.z);
    maxbranches = s;
    thickness = th;
    ratio = ratio_;

    a = new ArrayList(300);
    leaves = new ArrayList(300);


    Branch b = new Branch(root, trunk, thickness, 1, int(random(3, 5)), 1 );
    // Add to arraylist
    //b.lock();
    a.add(b);
  }




  ArrayList a() {
    return a;
  }

  ArrayList leaves() {
    return leaves;
  }

  void reset() {
    for (int i = a.size()-1; i >= 1; i--) { 
      Branch b = (Branch) a.get(i);
      a.remove(b);
    }
    for (int j = 0; j < a.size(); j++) { 
      Branch b = (Branch) a.get(j);
      b.reset();
    }

    for (int i = leaves.size()-1; i >= 0;  i--) {
      Leaf leaf = (Leaf) leaves.get(i);
      leaf.fall();
    }
  }


  void render() {


    for (int i = a.size()-1; i >= 0; i--) {
      Branch b = (Branch) a.get(i);

      if (a.size() < maxbranches) {        
        b.generateBranches();
      }
      if (b.dead()) {
        a.remove(i);
      }

      b.generateLeaves(.0003);

      if (a.size() <= 1) {
        killDescendence(b.id, 6);
        b.reset();

        if (twoMinutes.isFinished() ) {
          setup();
          twoMinutes.start();
        }
      }
      killHorphans(b.id);
      relieveParent(b.id);

      if (leaves.size() < 5) {
        b.leafed = false;
      }

      b.render();
    }





    for (int i = leaves.size()-1; i >= 0;  i--) {
      Leaf leaf = (Leaf) leaves.get(i);
      leaf.display();

      if (leaf.leaf.y > -30 & random(1) < .01) {
        leaves.remove(i);
      }
    }
  }

  void fall(float chance) {
    for (int i = leaves.size()-1; i >= 0;  i--) {
      Leaf leaf = (Leaf) leaves.get(i);
      if (random(1) < chance) {
        leaf.fall();
      }
    }
  }

  void fallBranch(float chance) {

    for (int i = a.size()-1; i >= 1;  i--) {
      Branch b = (Branch) a.get(i);

      if (random(1) < chance && b.numbranches == 0) {
        println(b.numbranches);
        b.fall();

        killDescendence(b.id, 6);
      }
    }
  }

  void killDescendence(int parentID, int generations) {
    if (generations > 0) {
      generations -= 1;
      for (int i = a.size()-1; i >= 0;  i--) {
        Branch c = (Branch) a.get(i);
        if ( parentID == c.id/10) {
          c.die();
          killDescendence(c.id, generations);
          println("killing " + c.id+ "!");
        }
      }
    }
  }

  void relieveParent (int parentID) {
    int children = 0;
    for (int i = a.size()-1; i >= 0;  i--) {
      Branch b = (Branch) a.get(i);
      if ( b.id/10 == parentID) {
        children+=1;
      }
    }
    for (int j = a.size()-1; j >= 0;  j--) {
      Branch p = (Branch) a.get(j);
      if (p.id == parentID) {
        p.numbranches = children;
        if (p.numbranches < p.maxperbranch) {
          p.branched = false;
        }
      }
    }
  }

  void killHorphans (int id) {
    //horphan until otherwise proven.
    boolean horphan = true;
    int parentID = id/10;
    for (int i = a.size()-1; i >= 0;  i--) {
      Branch p = (Branch) a.get(i);
      if ( p.id == parentID) {
        //has a parent? not an horphan!
        horphan = false;
      }
    }

    if (horphan) {
      // we run this loop only if we have an horphan.
      for (int j = a.size()-1; j >= 0;  j--) {
        Branch b = (Branch) a.get(j);
        if (id == b.id && !b.trunk) {
          b.die();
        }
      }
    }
  }

