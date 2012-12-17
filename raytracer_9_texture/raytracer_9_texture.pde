class Vec{
  float x, y, z;
  Vec(float x0, float y0, float z0){
    x = x0; y = y0; z = z0;
  }
  Vec(Vec v0){
    x = v0.x; y = v0.y; z = v0.z;
  }
  Vec add(Vec v){
    return new Vec(x+v.x, y+v.y, z+v.z);
  }
  Vec sub(Vec v){
    return new Vec(x-v.x, y-v.y, z-v.z);
  }
  Vec cross(Vec v){
    return new Vec(y*v.z-z*v.y, z*v.x-x*v.z, x*v.y-y*v.x);
  }
  float dot(Vec v){
    return x*v.x+y*v.y+z*v.z;
  }
  Vec mult(float k){
    return new Vec(k*x, k*y, k*z);
  }
  float abs(){
    return sqrt(x*x+y*y+z*z);
  }
  void normalize(){
    float a = this.abs();
    x/=a; y/=a; z/=a;
  }
  float angle(Vec v){
    return acos(this.dot(v)/this.abs()/v.abs());
  }
}

float INF = 1001001001;

class Ray{
  Vec ori, dir;
  Ray(Vec o0, Vec d0){
    ori = new Vec(o0);
    dir = new Vec(d0);
  }
  void normalize(){
    dir.normalize();
  }
}

class Tri{
  Vec v0, v1, v2;
  color cdif, cref, cemit;
  float ref;
  PImage texture;
  Tri(Vec w0, Vec w1, Vec w2){
    v0 = new Vec(w0);
    v1 = new Vec(w1);
    v2 = new Vec(w2);
    ref = 0;
    texture = null;
  }
  Vec getN(){
    Vec ret = ((v1.sub(v0)).cross(v2.sub(v0)));
    ret.normalize();
    return ret;
  }
  color getTexColor(float u, float v){
    int x = (int)(u*texture.width);
    int y = (int)(v*texture.height);
    return texture.pixels[y*texture.width+x];
  }
}

/*
  Thomas's algorithm
  written in "Fast, Minimum Storage Ray/Triangle Intersection"
  see http://www.graphics.cornell.edu/pubs/1997/MT97.pdf
*/
Vec cross(Ray r, Tri tr){
  Vec e1 = tr.v1.sub(tr.v0);
  Vec e2 = tr.v2.sub(tr.v0);
  
  Vec pv, tv, qv;
  float t, u, v;
  
  pv = r.dir.cross(e2);
  float det = pv.dot(e1);
  
  if(det > 1e-3){
    tv = r.ori.sub(tr.v0);
    u = tv.dot(pv);
    if(u<0.0 || u>det) return new Vec(INF, INF, INF);
    qv = tv.cross(e1);
    v = r.dir.dot(qv);
    if(v<0.0 || u+v>det) return new Vec(INF, INF, INF);
  }else if(det < -1e-3){
    tv = r.ori.sub(tr.v0);
    u = tv.dot(pv);
    if(u>0.0 || u<det) return new Vec(INF, INF, INF);
    qv = tv.cross(e1);
    v = r.dir.dot(qv);
    if(v>0.0 || u+v<det) return new Vec(INF, INF, INF);
  }else{
    return new Vec(INF, INF, INF);
  }
  
  float idet = 1.0/det;
  t = e2.dot(qv)*idet;
  u *= idet;
  v *= idet;
  return new Vec(t, u, v);
}

class Screen{
  Vec ori, dx, dy;
  Screen(Vec o0, Vec x0, Vec y0){
    ori = new Vec(o0);
    dx = new Vec(x0);
    dy = new Vec(y0);
  }
  
}

int N = 23;
PImage tex;

int getCrossPoint(Ray r, Tri[] trilist, Vec ans){
  float tmpt = INF;
  int tmpk = -1;
  for(int k=0; k<N; k++){
    Vec tuv = cross(r, trilist[k]);
    if(tuv.x>0 && tuv.x < tmpt){
      tmpt = tuv.x;
      tmpk = k;
      ans.x = tuv.x; ans.y=tuv.y; ans.z=tuv.z;
    }
  }
  return tmpk;
}



color getColor(Ray r, Tri[] trilist, Vec lightVec, float rr){
  Vec tuv = new Vec(0, 0, 0);
  color c;
  int f = getCrossPoint(r, trilist, tuv);
  if(f==-1){
    c = color(10, 10, 10);
  }else{
    Vec nvec = trilist[f].getN();
    Vec kouten = (r.dir.mult(tuv.x)).add(r.ori).add(nvec.mult(0.01));
    if(trilist[f].texture==null){
      c = trilist[f].cdif;
    }else{
      c = trilist[f].getTexColor(tuv.y, tuv.z);
    }
    // kougenn ni mukau line ga aruka ?
    float a = trilist[f].getN().angle(lightVec);
    if(-cos(a)>0.1){
      Vec dirLight = lightVec.mult(-1.0);
      Vec tuv2 = new Vec(0, 0, 0);
      int f2 = getCrossPoint(new Ray(kouten, dirLight), trilist, tuv2);
      if(f2 == -1) {
        c = color(red(c)*(-cos(a)), green(c)*(-cos(a)), blue(c)*(-cos(a)));
      }else{
        c = color(red(c)*0.1, green(c)*0.1, blue(c)*0.1);
      }
    }else{
      c = color(red(c)*0.1, green(c)*0.1, blue(c)*0.1);
    }
    
    // hansha no shori
    if(rr*trilist[f].ref > 0.1 && cos(a)<0){
      color c2 = getColor(new Ray(kouten, (r.dir.sub(nvec.mult(2.0*r.dir.dot(nvec)/nvec.abs()/nvec.abs())))), trilist, lightVec,  rr*trilist[f].ref);
      c = color((1.0-trilist[f].ref)*red(c) + trilist[f].ref*red(c2)*red(trilist[f].cref)/100,
                (1.0-trilist[f].ref)*green(c) + trilist[f].ref*green(c2)*green(trilist[f].cref)/100,
                (1.0-trilist[f].ref)*blue(c) + trilist[f].ref*blue(c2)*blue(trilist[f].cref)/100);
    }
  }
  return c;
}
  
void setup(){
  size(200, 200);
  colorMode(RGB, 100);
  frameRate(10);
  
  tex = loadImage("../tex.jpg");
  tex.loadPixels();
}

void draw(){
  Vec ori = new Vec(1, (width/2-mouseX)/100.0, 2+(height/2-mouseY)/100.0);
  Vec dir = new Vec(1, 0, 0);
  Vec v0 = new Vec(10, 1, 1);
  Vec v1 = new Vec(10, -1, 1);
  Vec v2 = new Vec(10, 0, -1);
//  Ray r = new Ray(ori, dir);
  Tri t = new Tri(v0, v1, v2);
//  Vec tuv = cross(r, t);
//  println(tuv.x +" "+ tuv.y +" "+ tuv.z);
  float G = (1+sqrt(5))/2;
  Tri[] tris = new Tri[100];
  tris[0] = new Tri(new Vec(G, 0, 1), new Vec(G, 0, -1), new Vec(1, G, 0));
  tris[1] = new Tri(new Vec(G, 0, -1), new Vec(G, 0, 1), new Vec(1, -G, 0));
  tris[2] = new Tri(new Vec(-G, 0, -1), new Vec(-G, 0, 1), new Vec(-1, G, 0));
  tris[3] = new Tri(new Vec(-G, 0, 1), new Vec(-G, 0, -1), new Vec(-1, -G, 0));
  
  tris[4] = new Tri(new Vec(1, G, 0), new Vec(-1, G, 0), new Vec(0, 1, G));
  tris[5] = new Tri(new Vec(-1, G, 0), new Vec(1, G, 0), new Vec(0, 1, -G));
  tris[6] = new Tri(new Vec(-1, -G, 0), new Vec(1, -G, 0), new Vec(0, -1, G));
  tris[7] = new Tri(new Vec(1, -G, 0), new Vec(-1, -G, 0), new Vec(0, -1, -G));
  
  tris[8] = new Tri(new Vec(0, 1, G), new Vec(0, -1, G), new Vec(G, 0, 1));
  tris[9] = new Tri(new Vec(0, -1, G), new Vec(0, 1, G), new Vec(-G, 0, 1));
  tris[10] = new Tri(new Vec(0, -1, -G), new Vec(0, 1, -G), new Vec(G, 0, -1));
  tris[11] = new Tri(new Vec(0, 1, -G), new Vec(0, -1, -G), new Vec(-G, 0, -1));
  
  tris[12] = new Tri(new Vec(G, 0, 1), new Vec(1, G, 0), new Vec(0, 1, G));
  tris[13] = new Tri(new Vec(G, 0, -1), new Vec(0, 1, -G), new Vec(1, G, 0));
  tris[14] = new Tri(new Vec(G, 0, 1), new Vec(0, -1, G), new Vec(1, -G, 0));
  tris[15] = new Tri(new Vec(G, 0, -1), new Vec(1, -G, 0), new Vec(0, -1, -G));
  
  tris[16] = new Tri(new Vec(-G, 0, -1), new Vec(-1, G, 0), new Vec(0, 1, -G));
  tris[17] = new Tri(new Vec(-G, 0, 1), new Vec(0, 1, G), new Vec(-1, G, 0));
  tris[18] = new Tri(new Vec(-G, 0, -1), new Vec(0, -1, -G), new Vec(-1, -G, 0));
//  tris[19] = new Tri(new Vec(INF, INF, INF), new Vec(INF, INF, INF), new Vec(INF, INF, INF));
  tris[19] = new Tri(new Vec(-G, 0, 1), new Vec(-1, -G, 0), new Vec(0, -1, G));
  
  tris[20] = new Tri(new Vec(3, 10, -G), new Vec(3, -10, -G), new Vec(15, 0, -G));
  tris[20].cdif = color(100, 100, 100);
  tris[20].cref = color(100, 100, 100);
  tris[20].ref = 0.0;
  tris[20].texture = tex;
  tris[21] = new Tri(new Vec(15, 0, -G), new Vec(3, -10, -G), new Vec(15, 0, 20));
  tris[21].cdif = color(100, 100, 100);
  tris[21].cref = color(100, 100, 100);
  tris[21].ref = 0.8;
  tris[22] = new Tri(new Vec(3, 10, -G), new Vec(15, 0, -G), new Vec(15, 0, 20));
  tris[22].cdif = color(100, 100, 100);
  tris[22].cref = color(100, 100, 100);
  tris[22].ref = 0.8;
  
  for(int i=0; i<20; i++){
    tris[i].cdif = color(98, 82, 27);
    tris[i].cref = color(100, 100, 54);
    tris[i].ref = 0.3;
    tris[i].v0 = tris[i].v0.add(new Vec(10, 0, 0));
    tris[i].v1 = tris[i].v1.add(new Vec(10, 0, 0));
    tris[i].v2 = tris[i].v2.add(new Vec(10, 0, 0));
  }
  
  Screen sc = new Screen(new Vec(4, 2, 4), new Vec(0, -4, 0), new Vec(0, 0, -4));
  Vec lightVec = new Vec(0.8, 0.6, -1.3);
  lightVec.normalize();
  
  PImage pi = createImage(width, height, HSB);
  pi.loadPixels();
  for(int i=0; i<pi.height; i++){
    for(int j=0; j<pi.width; j++){
      color c;
      float kx = (float)j/pi.width;
      float ky = (float)i/pi.height;
      Vec scp = (sc.ori.add(sc.dx.mult(kx))).add(sc.dy.mult(ky));
      Vec ldir = scp.sub(ori);
      ldir.normalize();
      Ray ry = new Ray(ori, ldir);
      ry.normalize();
      c = color(0);
      
      pi.pixels[i*pi.width+j] = getColor(ry, tris, lightVec, 1.0);
    }
  }
  image(pi, 0, 0);
}


