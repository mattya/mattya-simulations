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
    this.normalize();
  }
  void normalize(){
    dir.normalize();
  }
}

class Obj{
  color cdif, cref, cemit;
  float ref;
  PImage texture;
  Vec getN(Vec cp){
    return null;
  }
  Vec cross(Ray r){
    return null;
  }
  color getTexColor(float u, float v){
    return color(0, 0, 0);
  }
}

class Sphere extends Obj{
  Vec c;
  float r;
  Sphere(Vec c0, float r0){
    c = new Vec(c0);
    r = r0;
  }
  Vec getN(Vec cp){
    Vec ret = cp.sub(c);
    ret.normalize();
    return ret;
  }
  Vec cross(Ray ry){
    float vc = ry.dir.dot(ry.ori.sub(c));
    float D = vc*vc - ry.ori.sub(c).dot(ry.ori.sub(c)) + r*r;
    if(D<0) return new Vec(INF, INF, INF);
    float t1 = -vc-sqrt(D);
    float t2 = -vc+sqrt(D);
    if(t1<t2){
      if(t2<0) return new Vec(INF, INF, INF);
      if(t1<0) return new Vec(t2, 0, 0);
      return new Vec(t1, 0, 0);
    }else{
      if(t1<0) return new Vec(INF, INF, INF);
      if(t2<0) return new Vec(t1, 0, 0);
      return new Vec(t2, 0, 0);
    }
  }
}

class Tri extends Obj{
  Vec v0, v1, v2;
  Tri(Vec w0, Vec w1, Vec w2){
    v0 = new Vec(w0);
    v1 = new Vec(w1);
    v2 = new Vec(w2);
    ref = 0;
    texture = null;
  }
  Vec getN(Vec cp){
    Vec ret = ((v1.sub(v0)).cross(v2.sub(v0)));
    ret.normalize();
    return ret;
  }
  color getTexColor(float u, float v){
    int x = (int)(u*texture.width);
    int y = (int)(v*texture.height);
    return texture.pixels[y*texture.width+x];
  }
  /*
    Thomas's algorithm
    written in "Fast, Minimum Storage Ray/Triangle Intersection"
    see http://www.graphics.cornell.edu/pubs/1997/MT97.pdf
  */
  Vec cross(Ray r){
    Vec e1 = v1.sub(v0);
    Vec e2 = v2.sub(v0);
    
    Vec pv, tv, qv;
    float t, u, v;
    
    pv = r.dir.cross(e2);
    float det = pv.dot(e1);
    
    if(det > 1e-3){
      tv = r.ori.sub(v0);
      u = tv.dot(pv);
      if(u<0.0 || u>det) return new Vec(INF, INF, INF);
      qv = tv.cross(e1);
      v = r.dir.dot(qv);
      if(v<0.0 || u+v>det) return new Vec(INF, INF, INF);
    }else if(det < -1e-3){
      tv = r.ori.sub(v0);
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
}


class Screen{
  Vec ori, dx, dy;
  Screen(Vec o0, Vec x0, Vec y0){
    ori = new Vec(o0);
    dx = new Vec(x0);
    dy = new Vec(y0);
  }
  
}

int N = 24;
PImage tex;

int getCrossPoint(Ray r, Obj[] objlist, Vec ans){
  float tmpt = INF;
  int tmpk = -1;
  for(int k=0; k<N; k++){
    Vec tuv = objlist[k].cross(r);
    if(tuv.x>0 && tuv.x < tmpt){
      tmpt = tuv.x;
      tmpk = k;
      ans.x = tuv.x; ans.y=tuv.y; ans.z=tuv.z;
    }
  }
  return tmpk;
}



color getColor(Ray r, Obj[] objlist, Vec lightVec, float rr){
  Vec tuv = new Vec(0, 0, 0);
  color c;
  int f = getCrossPoint(r, objlist, tuv);
  if(f==-1){
    c = color(10, 10, 10);
  }else{
    Vec kouten = (r.dir.mult(tuv.x)).add(r.ori);
    Vec nvec = objlist[f].getN(kouten);
    kouten = kouten.add(nvec.mult(0.01));
    Obj target = objlist[f];
    if(target.texture==null){
      c = target.cdif;
    }else{
      c = target.getTexColor(tuv.y, tuv.z);
    }
    // kougenn ni mukau line ga aruka ?
    float a = target.getN(kouten).angle(lightVec);
    if(-cos(a)>0.1){
      Vec dirLight = lightVec.mult(-1.0);
      Vec tuv2 = new Vec(0, 0, 0);
      int f2 = getCrossPoint(new Ray(kouten, dirLight), objlist, tuv2);
      if(f2 == -1) {
        c = color(red(c)*(-cos(a)), green(c)*(-cos(a)), blue(c)*(-cos(a)));
      }else{
        c = color(red(c)*0.1, green(c)*0.1, blue(c)*0.1);
      }
    }else{
      c = color(red(c)*0.1, green(c)*0.1, blue(c)*0.1);
    }
    
    // hansha no shori
    if(rr*target.ref > 0.1 && cos(a)<0){
      color c2 = getColor(new Ray(kouten, (r.dir.sub(nvec.mult(2.0*r.dir.dot(nvec)/nvec.abs()/nvec.abs())))), objlist, lightVec,  rr*target.ref);
      c = color((1.0-target.ref)*red(c) + target.ref*red(c2)*red(target.cref)/100,
                (1.0-target.ref)*green(c) + target.ref*green(c2)*green(target.cref)/100,
                (1.0-target.ref)*blue(c) + target.ref*blue(c2)*blue(target.cref)/100);
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
  Vec ori = new Vec(-1, (width/2-mouseX)/100.0, 2+(height/2-mouseY)/100.0);
  Vec dir = new Vec(1, 0, 0);
  Vec v0 = new Vec(10, 1, 1);
  Vec v1 = new Vec(10, -1, 1);
  Vec v2 = new Vec(10, 0, -1);
//  Ray r = new Ray(ori, dir);
  Tri t = new Tri(v0, v1, v2);
//  Vec tuv = cross(r, t);
//  println(tuv.x +" "+ tuv.y +" "+ tuv.z);
  float G = (1+sqrt(5))/2;
  Obj[] objs = new Obj[100];
  objs[0] = new Tri(new Vec(G, 0, 1), new Vec(G, 0, -1), new Vec(1, G, 0));
  objs[1] = new Tri(new Vec(G, 0, -1), new Vec(G, 0, 1), new Vec(1, -G, 0));
  objs[2] = new Tri(new Vec(-G, 0, -1), new Vec(-G, 0, 1), new Vec(-1, G, 0));
  objs[3] = new Tri(new Vec(-G, 0, 1), new Vec(-G, 0, -1), new Vec(-1, -G, 0));
  
  objs[4] = new Tri(new Vec(1, G, 0), new Vec(-1, G, 0), new Vec(0, 1, G));
  objs[5] = new Tri(new Vec(-1, G, 0), new Vec(1, G, 0), new Vec(0, 1, -G));
  objs[6] = new Tri(new Vec(-1, -G, 0), new Vec(1, -G, 0), new Vec(0, -1, G));
  objs[7] = new Tri(new Vec(1, -G, 0), new Vec(-1, -G, 0), new Vec(0, -1, -G));
  
  objs[8] = new Tri(new Vec(0, 1, G), new Vec(0, -1, G), new Vec(G, 0, 1));
  objs[9] = new Tri(new Vec(0, -1, G), new Vec(0, 1, G), new Vec(-G, 0, 1));
  objs[10] = new Tri(new Vec(0, -1, -G), new Vec(0, 1, -G), new Vec(G, 0, -1));
  objs[11] = new Tri(new Vec(0, 1, -G), new Vec(0, -1, -G), new Vec(-G, 0, -1));
  
  objs[12] = new Tri(new Vec(G, 0, 1), new Vec(1, G, 0), new Vec(0, 1, G));
  objs[13] = new Tri(new Vec(G, 0, -1), new Vec(0, 1, -G), new Vec(1, G, 0));
  objs[14] = new Tri(new Vec(G, 0, 1), new Vec(0, -1, G), new Vec(1, -G, 0));
  objs[15] = new Tri(new Vec(G, 0, -1), new Vec(1, -G, 0), new Vec(0, -1, -G));
  
  objs[16] = new Tri(new Vec(-G, 0, -1), new Vec(-1, G, 0), new Vec(0, 1, -G));
  objs[17] = new Tri(new Vec(-G, 0, 1), new Vec(0, 1, G), new Vec(-1, G, 0));
  objs[18] = new Tri(new Vec(-G, 0, -1), new Vec(0, -1, -G), new Vec(-1, -G, 0));
//  objs[19] = new Tri(new Vec(INF, INF, INF), new Vec(INF, INF, INF), new Vec(INF, INF, INF));
  objs[19] = new Tri(new Vec(-G, 0, 1), new Vec(-1, -G, 0), new Vec(0, -1, G));
  
  objs[20] = new Tri(new Vec(3, 10, -G), new Vec(3, -10, -G), new Vec(15, 0, -G));
  objs[20].cdif = color(100, 100, 100);
  objs[20].cref = color(100, 100, 100);
  objs[20].ref = 0.0;
  objs[20].texture = tex;
  objs[21] = new Tri(new Vec(15, 0, -G), new Vec(3, -10, -G), new Vec(15, 0, 20));
  objs[21].cdif = color(100, 100, 100);
  objs[21].cref = color(100, 100, 100);
  objs[21].ref = 0.8;
  objs[22] = new Tri(new Vec(3, 10, -G), new Vec(15, 0, -G), new Vec(15, 0, 20));
  objs[22].cdif = color(100, 100, 100);
  objs[22].cref = color(100, 100, 100);
  objs[22].ref = 0.8;
  
  objs[23] = new Sphere(new Vec(6, 1.5, 0.5), 1.0);
  objs[23].cdif = color(100, 100, 100);
  objs[23].cref = color(100, 100, 100);
  objs[23].ref = 0.5;
  
  for(int i=0; i<20; i++){
    objs[i].cdif = color(98, 82, 27);
    objs[i].cref = color(100, 100, 54);
    objs[i].ref = 0.3;
    ((Tri)objs[i]).v0 = ((Tri)objs[i]).v0.add(new Vec(7, -2, 0));
    ((Tri)objs[i]).v1 = ((Tri)objs[i]).v1.add(new Vec(7, -2, 0));
    ((Tri)objs[i]).v2 = ((Tri)objs[i]).v2.add(new Vec(7, -2, 0));
  }
  
  Screen sc = new Screen(new Vec(2, 2, 4), new Vec(0, -4, 0), new Vec(0, 0, -4));
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
      
      pi.pixels[i*pi.width+j] = getColor(ry, objs, lightVec, 1.0);
    }
  }
  image(pi, 0, 0);
}


