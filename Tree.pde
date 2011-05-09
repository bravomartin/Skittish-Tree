class Tree {
  ArrayList a;
  ArrayList leaves;
  Particle root, trunk;
  Vec2D trunk_;
  int maxbranches;
  float thickness;
  float ratio;

  Tree(Vec3D r, int t, int s, float th, float ratio_) {
    root = new Particle (r.x,r.y, r.z);

    trunk = new Particle (r.x,r.y-t, r.z);
    maxbranches = s;
    thickness = th;
    ratio = ratio_;

    a = new ArrayList();
    leaves = new ArrayList();
    Branch b = new Branch(root,trunk, thickness, 1);
    // Add to arraylist
    //b.lock();
    a.add(b);
    for (int i = 0; i < 9; i++) {
      for (int j = a.size()-1; j >= 0; j--) {
        Branch bb = (Branch) a.get(j);
        bb.generateBranches();
      }
    }
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
      b.unlock();
    }
  }

  void render() {
    for (int i = a.size()-1; i >= 0; i--) {
      // Get the branch, update and draw it
      Branch b = (Branch) a.get(i);
      b.render();
    }
    for (int j = a.size()-1; j >= 0; j--) {
      Branch bb = (Branch) a.get(j);

      if (random(1) < .0001) {
        bb.generateLeaves();
      }
      if (leaves.size() < 5){
      bb.leafed = false;
      }
    }
   // println (leaves.size());


    for (int i = leaves.size()-1; i >= 0;  i--) {
      Leaf leaf = (Leaf) leaves.get(i);
      leaf.display();
      if (leaf.leaf.y > height) {
      leaves.remove(i);
      }
    }
  }

  void fall() {
    for (int i = leaves.size()-1; i >= 0;  i--) {
      Leaf leaf = (Leaf) leaves.get(i);
      if (random(1) < .1) {
        leaf.fall();
      }
    }
  }

