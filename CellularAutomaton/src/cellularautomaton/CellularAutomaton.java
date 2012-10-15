package cellularautomaton;

import java.util.*;

import processing.core.*;


public class CellularAutomaton extends PApplet {
  int[][] m, m2;
  int NX = 250;
  int NY = 250;
  int M = 6;
  
  double[] pdeg;
  double[] pdif;
  
  HashMap<Integer,Rule> rules;
  
  void makeRules(){
    /* Conway's life game (M=2)
    for(int i=0; i<M; i++) pdeg[i] = 0;
    for(int i=0; i<M; i++) pdif[i] = 0;
    addRule(0, new int[]{5, 3}, 1, 1);
    addRule(1, new int[]{6, 2}, 1, 1);
    addRule(1, new int[]{5, 3}, 1, 1);
    addRule(1, new int[]{8, 0}, 0, 1);
    addRule(1, new int[]{7, 1}, 0, 1);
    addRule(1, new int[]{4, 4}, 0, 1);
    addRule(1, new int[]{3, 5}, 0, 1);
    addRule(1, new int[]{2, 6}, 0, 1);
    addRule(1, new int[]{1, 7}, 0, 1);
    addRule(1, new int[]{0, 8}, 0, 1);
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        m[i][j] = (int)(M*Math.random());
      }
    }
    */
    /* cell (M=3)
    pdeg = new double[]{0, 0.01, 0.001};
    pdif = new double[]{0.0, 0.25, 0.01};
    addRule(0, new int[]{6, 1, 1}, 1, 0.1);
    addRule(0, new int[]{5, 2, 1}, 2, 0.001);
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        m[i][j] = (int)(2.004*Math.random());
      }
    }
    */
    /* cycle (M=4)
    pdeg = new double[]{0, 0.01, 0.01, 0.01};
    pdif = new double[]{0.0, 0.1, 0.1, 0.1};
    addRule(0, new int[]{6, 1, 1, 0}, 2, 0.05);
    addRule(0, new int[]{6, 0, 1, 1}, 3, 0.05);
    addRule(0, new int[]{6, 1, 0, 1}, 1, 0.05);
    addRule(0, new int[]{4, 2, 2, 0}, 2, 0.1);
    addRule(0, new int[]{4, 0, 2, 2}, 3, 0.1);
    addRule(0, new int[]{4, 2, 0, 2}, 1, 0.1);
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        m[i][j] = (int)(4.000*Math.random());
      }
    }
    */
    //* cycle (M=6)
    pdeg = new double[]{0, 0.015, 0.015, 0.015, 0.015, 0.015};
    pdif = new double[]{0.0, 0.1, 0.1, 0.1, 0.1, 0.1};
    addRule(0, new int[]{6, 1, 1, 0, 0, 0}, 2, 0.05);
    addRule(0, new int[]{6, 0, 1, 1, 0, 0}, 3, 0.05);
    addRule(0, new int[]{6, 0, 0, 1, 1, 0}, 4, 0.05);
    addRule(0, new int[]{6, 0, 0, 0, 1, 1}, 5, 0.05);
    addRule(0, new int[]{6, 1, 0, 0, 0, 1}, 1, 0.05);
    addRule(0, new int[]{4, 2, 2, 0, 0, 0}, 2, 0.05);
    addRule(0, new int[]{4, 0, 2, 2, 0, 0}, 3, 0.05);
    addRule(0, new int[]{4, 0, 0, 2, 2, 0}, 4, 0.05);
    addRule(0, new int[]{4, 0, 0, 0, 2, 2}, 5, 0.05);
    addRule(0, new int[]{4, 2, 0, 0, 0, 2}, 1, 0.05);
    addRule(0, new int[]{2, 3, 3, 0, 0, 0}, 2, 0.05);
    addRule(0, new int[]{2, 0, 3, 3, 0, 0}, 3, 0.05);
    addRule(0, new int[]{2, 0, 0, 3, 3, 0}, 4, 0.05);
    addRule(0, new int[]{2, 0, 0, 0, 3, 3}, 5, 0.05);
    addRule(0, new int[]{2, 3, 0, 0, 0, 3}, 1, 0.05);
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        m[i][j] = (int)(6.000*Math.random());
      }
    }
    //*/
  }
  
  class State{
    int cent;
    int hash;
    State(int c0, int h0){
      cent = c0; hash = h0;
    }
  }
  
  class Rule{
    int t;
    double p;
    Rule(int t0, double p0){
      t = t0; p = p0;
    }
  }
  
  
  int encode(int cent, int[] neig){
    int ans = 0;
    int b = 1;
    for(int i=0; i<M; i++){
      ans += b*neig[i];
      b*=10;
    }
    ans += b*cent;
    return ans;
  }
  
  void addRule(int cent, int[] neig, int targ, double p){
    int s = encode(cent, neig);
    Rule r = new Rule(targ, p);
    rules.put(s, r);
  }
  
  int applyRule(int cent, int[] neig){
//    System.out.println(cent + " " + encode(neig));
    Rule r = rules.get(encode(cent, neig));
    if(r == null){
      return cent;
    }
    else{
//      System.out.println(r.p+" "+r.t);
      if(Math.random() < r.p){
        return r.t;
      }else{
        return cent;
      }
    }
  }
  
  void periodic_boundary(){
    // periodic boundary
    for(int i=0; i<NX+2; i++){
      m[i][0] = m[i][NY];
      m[i][NY+1] = m[i][1];
    }
    for(int j=0; j<NY+2; j++){
      m[0][j] = m[NX][j];
      m[NX+1][j] = m[1][j];
    }
    m[0][0] = m[NX][NY];
    m[0][NY+1] = m[1][NY];
    m[NX+1][0] = m[NX][1];
    m[NX+1][NY+1] = m[1][1];
  }
  
  void timeStep(){
    periodic_boundary();
    // diffusion (swap)
    for(int i=1; i<NX; i+=2){
      for(int j=1; j<=NY; j++){
        if(Math.random()<pdif[m[i][j]]+pdif[m[i+1][j]]){
          int swp = m[i][j]; m[i][j]=m[i+1][j]; m[i+1][j]=swp;
        }
      }
    }
    for(int i=1; i<=NX; i++){
      for(int j=1; j<NY; j+=2){
        if(Math.random()<pdif[m[i][j]]+pdif[m[i][j+1]]){
          int swp = m[i][j]; m[i][j]=m[i][j+1]; m[i][j+1]=swp;
        }
      }
    }
    periodic_boundary();
    for(int i=2; i<=NX; i+=2){
      for(int j=1; j<=NY; j++){
        if(Math.random()<pdif[m[i][j]]+pdif[m[i+1][j]]){
          int swp = m[i][j]; m[i][j]=m[i+1][j]; m[i+1][j]=swp;
        }
      }
    }
    for(int i=1; i<=NX; i++){
      for(int j=2; j<NY; j+=2){
        if(Math.random()<pdif[m[i][j]]+pdif[m[i][j+1]]){
          int swp = m[i][j]; m[i][j]=m[i][j+1]; m[i][j+1]=swp;
        }
      }
    }
    periodic_boundary();
    // deg
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        if(Math.random()<pdeg[m[i][j]]){
          m[i][j] = 0;
        }
      }
    }
    periodic_boundary();
    // evol
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        int[] tmp = new int[M];
        for(int ii=i-1; ii<=i+1; ii++){
          for(int jj=j-1; jj<=j+1; jj++){
            tmp[m[ii][jj]]++;
          }
        }
        tmp[m[i][j]]--;
        m2[i][j] = applyRule(m[i][j], tmp);
      }
    }
    // cpy
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        m[i][j] = m2[i][j];
      }
    }
  }
  
  void initialize(){
    m = new int[NX+2][NY+2];
    m2 = new int[NX+2][NY+2];
    pdeg = new double[M];
    pdif = new double[M];
    rules = new HashMap<Integer, CellularAutomaton.Rule>();
    makeRules();
  }

  PGraphics pg;
  public void setup() {
    size(500, 500);
    initialize();
    frameRate(30);
    pg = createGraphics(500, 500, P2D);
  }

  public void draw() {
    for(int k=0; k<10; k++){
      timeStep();
    }
    pg.beginDraw();
    pg.colorMode(HSB, 100);
    pg.background(0);
    for(int i=1; i<=NX; i++){
      for(int j=1; j<=NY; j++){
        pg.noStroke();
        if(m[i][j]==0) ;
        else{
          pg.fill((m[i][j]-1)*70/(M-1), 100, 100);
          pg.rect(i*2, j*2, 2, 2);
        }
      }
    }
    pg.endDraw();
    image(pg, 0, 0);
  }
}
