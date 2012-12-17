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
  float h;
  Tri(Vec w0, Vec w1, Vec w2){
    v0 = new Vec(w0);
    v1 = new Vec(w1);
    v2 = new Vec(w2);
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
  
void setup(){
  size(200, 200);
  colorMode(HSB, 100);
  frameRate(10);
}

void draw(){
  Vec ori = new Vec(0, (width/2-mouseX)/100.0, (height/2-mouseY)/100.0);
  Vec dir = new Vec(1, 0, 0);
  Vec v0 = new Vec(10, 1, 1);
  Vec v1 = new Vec(10, -1, 1);
  Vec v2 = new Vec(10, 0, -1);
//  Ray r = new Ray(ori, dir);
  Tri t = new Tri(v0, v1, v2);
//  Vec tuv = cross(r, t);
//  println(tuv.x +" "+ tuv.y +" "+ tuv.z);
  float G = (1+sqrt(5))/2;
  Tri[] tris = new Tri[20];
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
  
  for(int i=0; i<20; i++){
    tris[i].h = i*3;
    tris[i].v0 = tris[i].v0.mult(-1);
    tris[i].v1 = tris[i].v1.mult(-1);
    tris[i].v2 = tris[i].v2.mult(-1);
    tris[i].v0 = tris[i].v0.add(new Vec(10, 0, 0));
    tris[i].v1 = tris[i].v1.add(new Vec(10, 0, 0));
    tris[i].v2 = tris[i].v2.add(new Vec(10, 0, 0));
  }
  
  Screen sc = new Screen(new Vec(4, 1, 1), new Vec(0, -2, 0), new Vec(0, 0, -2));
  
  PImage pi = createImage(width, height, HSB);
  pi.loadPixels();
  for(int i=0; i<pi.height; i++){
    for(int j=0; j<pi.width; j++){
      color c;
      float kx = (float)j/pi.width;
      float ky = (float)i/pi.height;
      Vec scp = (sc.ori.add(sc.dx.mult(kx))).add(sc.dy.mult(ky));
      Ray ry = new Ray(ori, scp.sub(ori));
      ry.normalize();
      c = color(0);
      float tmpt = INF;
      for(int k=0; k<20; k++){
        Vec tuv = cross(ry, tris[k]);
        if(tuv.x < tmpt){
          c = color(tris[k].h, 100, 100);
          tmpt = tuv.x;
        }
      }
      pi.pixels[i*pi.width+j] = c;
    }
  }
  image(pi, 0, 0);
}


