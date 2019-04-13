color c = color(1);  
int n = 1;
int turnonmarkers = 0;
float x[]={475,75,67,35,100,145,285,375,425,50};
float y[]={45,75,125,175,225,275,325,375,425,50};
float theta[]={5,75,125,175,225,275,325,375,425,5};
float theta_initial[]={0.25,0.1,0.23,0.67,1.23,2.7,1.6,0.7,1.8,0.25};
float te = 0;
float t = 0;
PVector[][] rcmrel = new PVector[10][4];
float sideleng = 25; 
{for (int i=0;i<10;i++){
  theta_initial[i]=theta_initial[i]*((float)Math.PI);
  theta[i] = theta_initial[i];
  rcmrel[i][0]= new PVector ((sideleng/((float)Math.sqrt(2)))*(float)Math.cos(3*(float)Math.PI/4),(sideleng/((float)Math.sqrt(2)))*(float)Math.sin((float)Math.PI/4));
  rcmrel[i][1]= new PVector ((sideleng/((float)Math.sqrt(2)))*(float)Math.cos((float)Math.PI/4),(sideleng/((float)Math.sqrt(2)))*(float)Math.sin((float)Math.PI/4));
  rcmrel[i][2]= new PVector ((sideleng/((float)Math.sqrt(2)))*(float)Math.cos((float)Math.PI/4),(sideleng/((float)Math.sqrt(2)))*(float)Math.sin(-(float)Math.PI/4));
  rcmrel[i][3]= new PVector ((sideleng/((float)Math.sqrt(2)))*(float)Math.cos(-3*(float)Math.PI/4),(sideleng/((float)Math.sqrt(2)))*(float)Math.sin(-3*(float)Math.PI/4));
}
}
float ux[]={-2,2,2,-2,0,0,-4,2,2,4};
float uy[]={-2,2,2,2,4,4,0,2,-2,0};
PVector[] xycm = new PVector[10];
PVector[] vcm = new PVector[10];
PVector[] w = new PVector[10];
PVector[] force = new PVector[10];
PVector[] torque = new PVector[10];
float er=5;
PVector[][] r = new PVector[10][4];
PVector[][] v = new PVector[10][4];
float mass=0.5;
float I=100;
float collision=0;    
float dt = 0.05;
float springk = 30;
float springk2 =  30;
float b1 = 0.2;
float b = 0.2; //b=1;
color[] mycolours = {color(255,255,255),color(255,191,0),color(255,0,255),color(255,255,0),color(64,255,0),color(0,64,255),color(255,64,0),color(128,128,125),color(0,0,0),color(0,255,255)};
Table table;

void setup() {
  for (int i=0;i<10;i++){
    xycm[i] = new PVector(x[i],y[i]);
    vcm[i] = new PVector(2*ux[i],2*uy[i]);
    force[i] = new PVector(0,0);
    torque[i] = new PVector(0,0);
    w[i] = new PVector(0,0,0);
    r[i][0]=new PVector(0,0);
    r[i][1]=new PVector(0,0);
    r[i][2]=new PVector(0,0);
    r[i][3]=new PVector(0,0);
  pushMatrix();
  translate(xycm[i].x, xycm[i].y);
  for (int j=0;j<4;j++){
  rcmrel[i][j].rotate(theta[i]);
  }
  popMatrix();
  }
  size(500,500);
  table = new Table();
    table.addColumn("time");
  table.addColumn("te");
  table.addColumn("message");
  size(500,500);
}

void draw() {
  background(255);
  move();
  saveFrame("images/squares-######.png"); 
  checkwallcollision();
  collisioncheck();

}

void move() {
  te=0;
  for (int i = 0; i < 10; i++){
  vcm[i].y=vcm[i].y+((force[i].y/mass))*dt;
  vcm[i].x=vcm[i].x+((force[i].x/mass))*dt;
  
  xycm[i].x=xycm[i].x+vcm[i].x*dt;
  xycm[i].y=xycm[i].y+vcm[i].y*dt;

  w[i].add(PVector.mult(torque[i],(dt/I)));
  theta[i]+=w[i].z*dt;
  te+=0.5*mass*(vcm[i].x*vcm[i].x+vcm[i].y*vcm[i].y)+0.5*I*w[i].z*w[i].z;
  

  rotater(i);
  for (int j=0;j<4;j++){
    r[i][j]=PVector.add(xycm[i],rcmrel[i][j]);
    v[i][j]=PVector.add(vcm[i],(PVector.sub(r[i][j],xycm[i]).cross(w[i])));

  }
    force[i] = new PVector(0,0);
    torque[i] = new PVector(0,0,0);
  }
  TableRow newRow = table.addRow();
  newRow.setFloat("time", t);
  newRow.setFloat("te", te);
  newRow.setFloat("message", collision);
  saveTable(table, "data/new.csv");
  t+=dt; 
  collision=0;
}

void rotater(int a) {
  pushMatrix();
  translate(xycm[a].x, xycm[a].y);
  for (int j=0;j<4;j++){
  rcmrel[a][j].rotate(w[a].z*dt);
  }
  rotate((theta[a]));
  display(a);
  popMatrix();
  if (turnonmarkers==1){
  fill(color(255,191,0));
  ellipse(r[a][0].x,r[a][0].y,er,er);
  fill(color(64,255,0));
  ellipse(r[a][1].x,r[a][1].y,er,er);
  fill(color(128,128,125));
  ellipse(r[a][2].x,r[a][2].y,er,er);
  fill(color(255,64,0));
  ellipse(r[a][3].x,r[a][3].y,er,er);
  }
}

void collisioncheck() {
  for (int i = 0; i < 9; i++){
   for (int j = i+1; j < 10; j++){
         if ((PVector.sub(xycm[i],xycm[j])).mag()<sideleng*1.414){
           
           for (int k = 0; k < 4; k++){
             if ((PVector.sub(r[i][k],r[j][0]).cross(PVector.sub(r[j][1],r[j][0]).normalize()).mag())<sideleng 
             && (PVector.sub(r[i][k],r[j][1]).cross(PVector.sub(r[j][2],r[j][1]).normalize()).mag())<sideleng 
             && (PVector.sub(r[i][k],r[j][2]).cross(PVector.sub(r[j][3],r[j][2]).normalize()).mag())<sideleng 
             && (PVector.sub(r[i][k],r[j][3]).cross(PVector.sub(r[j][3],r[j][0]).normalize()).mag())<sideleng){
             collisionresponse(i,j,k);
             }
             //else if ((PVector.sub(r[j][k],r[i][0]).cross(PVector.sub(r[i][1],r[i][0]).normalize()).mag())<sideleng 
             //&& (PVector.sub(r[j][k],r[i][1]).cross(PVector.sub(r[i][2],r[i][1]).normalize()).mag())<sideleng 
             //&& (PVector.sub(r[j][k],r[i][2]).cross(PVector.sub(r[i][3],r[i][2]).normalize()).mag())<sideleng 
             //&& (PVector.sub(r[j][k],r[i][3]).cross(PVector.sub(r[i][3],r[i][0]).normalize()).mag())<sideleng){
             //collisionresponse(j,i,k);
             //}

           }
           for (int k = 0; k < 4; k++){
             if ((PVector.sub(r[j][k],r[i][0]).cross(PVector.sub(r[i][1],r[i][0]).normalize()).mag())<sideleng 
             && (PVector.sub(r[j][k],r[i][1]).cross(PVector.sub(r[i][2],r[i][1]).normalize()).mag())<sideleng 
             && (PVector.sub(r[j][k],r[i][2]).cross(PVector.sub(r[i][3],r[i][2]).normalize()).mag())<sideleng 
             && (PVector.sub(r[j][k],r[i][3]).cross(PVector.sub(r[i][3],r[i][0]).normalize()).mag())<sideleng){
             collisionresponse(j,i,k);
             }
           }
         }
   }
  }
}



void collisionresponse(int n1,int n2, int n3){
  collision=10;
  float distance[] = {0,0,0,0};
  float savedist=10;
  int saveu=0;
  int saveu1=0;
  for (int u = 0; u < 4; u++){
    if (u==3){
    distance[u]=PVector.sub(r[n1][n3],r[n2][u]).cross(PVector.sub(r[n2][0],r[n2][u]).normalize()).mag();
    //print(distance[u],"  ");
    if (distance[u]<savedist)
    {
      savedist=distance[u];
      saveu=u;
      saveu1=0;
    }
    }
    else {
    distance[u]=PVector.sub(r[n1][n3],r[n2][u]).cross(PVector.sub(r[n2][u+1],r[n2][u]).normalize()).mag();
    //print(distance[u],"  ");
    if (distance[u]<savedist)
    {
      savedist=distance[u];
      saveu=u;
      saveu1=u+1;
    }
    }
  }
   PVector d = new PVector(0,0,0);
    PVector d_normalized = new PVector(0,0,0);
    d=((PVector.sub(r[n1][n3],r[n2][saveu])).cross(PVector.sub(r[n2][saveu1],r[n2][saveu]).normalize())).cross(PVector.sub(r[n2][saveu1],r[n2][saveu]).normalize());
    d_normalized=(((PVector.sub(r[n1][n3],r[n2][saveu])).cross(PVector.sub(r[n2][saveu1],r[n2][saveu]).normalize())).cross(PVector.sub(r[n2][saveu1],r[n2][saveu]).normalize())).normalize();
    forceresponse(d,d_normalized,n1,n2,n3);
}


void forceresponse(PVector dist, PVector dist_norm, int m1, int m2, int m3){
    PVector vrelm2 = PVector.add(vcm[m2],(PVector.sub(r[m1][m3],xycm[m2]).cross(w[m2])));
    //new PVector (0,0);
    
    force[m1]=PVector.add((PVector.mult(dist,springk2)),(PVector.mult(PVector.mult(dist_norm,(PVector.sub(v[m1][m3],vrelm2)).dot(dist_norm)),-b)));
    force[m2]=PVector.add((PVector.mult(dist,-springk2)),(PVector.mult(PVector.mult(dist_norm,(PVector.sub(v[m1][m3],vrelm2)).dot(dist_norm)),b)));
    torque[m1]=PVector.sub(r[m1][m3],xycm[m1]).cross(force[m1]);
    torque[m2]=PVector.sub(r[m1][m3],xycm[m2]).cross(force[m2]);
    print(PVector.mult(dist,springk2).dot(dist_norm),"   ",(PVector.mult(PVector.mult(dist_norm,(PVector.sub(v[m1][m3],vrelm2)).dot(dist_norm)),-b)).dot(dist_norm),"   ",PVector.sub(v[m1][m3],vrelm2).dot(dist_norm),"   ",dist.dot(dist_norm),"   ",dist.dot(PVector.sub(r[m1][m3],xycm[m1])),"   ",te,"              ");
}


void checkwallcollision(){
  for (int i = 0; i < 10; i++){
    for (int j =0; j<4; j++){
      if (r[i][j].x>500){
        float addforce=-springk*(r[i][j].x-500)-b1*v[i][j].x;
        force[i].x+=addforce;
        torque[i].add(PVector.sub(r[i][j],xycm[i]).cross(new PVector (addforce,0)));
        //print("right   ",vcm[i].x, "   ", i, "   ");
        collision=1;
        //print(collision,"    ",-springk*(r[i][j].x-500),"    ",-b1*v[i][j].x,"     ",te,"                       ");
      }
      if (r[i][j].x<0){
        float addforce=-springk*(r[i][j].x-0)-b1*v[i][j].x;
        force[i].x+=addforce;
        torque[i].add(PVector.sub(r[i][j],xycm[i]).cross(new PVector (addforce,0)));
        collision=2;
        //print(collision,"    ",-springk*(r[i][j].x-0),"    ",-b1*v[i][j].x,"     ",te,"                       ");
      }
      if (r[i][j].y>500){
        float addforce=-springk*(r[i][j].y-500)-b1*v[i][j].y;
        force[i].y+=addforce;
        torque[i].add(PVector.sub(r[i][j],xycm[i]).cross(new PVector (0,addforce)));
        //print("bottom   ",springk*(r[i][j].y-500), "   ",vcm[i].y, "   ",i, "   ");
        collision=3;
        //print(collision,"    ",-springk*(r[i][j].y-500),"    ",-b1*v[i][j].y,"     ",te,"                       ");
      }
      if (r[i][j].y<0){
        float addforce=-springk*(r[i][j].y-0)-b1*v[i][j].y;
        force[i].y+=addforce;
        torque[i].add(PVector.sub(r[i][j],xycm[i]).cross(new PVector (0,addforce)));
        //print("top   ",springk*(r[i][j].y-0), "   ",vcm[i].y, "   ",r[i][j].y, "   ",i, "   ");
        collision=4;
        //print(collision,"    ",-springk*(r[i][j].y-0),"    ",-b1*v[i][j].y,"     ",te,"                       ");
      }
    }
  }
}

void display(int counter) {
  
  //for (int i = 0; i < 10; i++){
  rectMode(CENTER);
  fill(mycolours[counter]);
  rect(0,0,sideleng,sideleng);
  //System.out.println (i);
  //}
}
