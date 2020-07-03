import java.util.Map;

int AMOUNT = 500;//Кол-во частиц
int graph_time = 500;//Время эксперимента
int fps = 300;


int TOUCH = 16;

int objSize = 3;
int windowW = 1920;
int windowH = 1080;
int time = 1;
float velocityMid = 0;

int border = 10;
int minPos = border+objSize/2;
int maxPos = windowH-border-objSize/2-objSize*5;
int plotCount = 0;
PrintWriter logs;
String log_name = "";    

Dot[] dots = new Dot[AMOUNT];
int[] count = new int[AMOUNT];

boolean flag = false;

PFont Font1;
PImage mask;
PrintWriter config;

int startVelocity = 10;

void settings() {
  size(windowW, windowH);
  smooth(8);
}

void setup() {  
  frameRate(fps);
  background(#ffffff);
  mask = loadImage("mask.png");
  noStroke();
  for (int i = 0; i < AMOUNT; i++) {
    
    float velX = random(-startVelocity, startVelocity);
    float velY = sqrt(startVelocity*startVelocity - velX*velX);
    
    float posX = (int)random(border+objSize, windowH-border*2-objSize*2);
    float posY = (int)random(border+objSize, windowH-border*2-objSize*2);
    
    dots[i] = new Dot(posX , posY , velX , velY);
  }
  Font1 = createFont("Arial Bold", 18);
  textFont(Font1);
  strokeWeight(3);
  
    if (log_name == "") {
    log_name = loadStrings("config.txt")[0];
    config = createWriter("config.txt");
    config.println(str(int(log_name)+1));
    config.flush();
  }

  logs = createWriter("logs/log"+log_name+".csv");
  logs.println("\"time\",\"velocity\",\"count\"");
  logs.flush();
}

void draw() {  
  stroke(#000000);  
  fill(#ffffff);
  rect(border, border, windowH-border*2, windowH-border*2);  
  noStroke();
  if( moveObj() )
    exit();
  
}

boolean moveObj() {

  for (int i = 0; i < AMOUNT; i++) {
    for (int j = 0; j < AMOUNT; j++) {
      if (
        i > j &&
        abs(dots[i].position.x - dots[j].position.x)
        *abs(dots[i].position.x - dots[j].position.x)
        + abs(dots[i].position.y - dots[j].position.y)
        *abs(dots[i].position.y - dots[j].position.y)< TOUCH*TOUCH 
        ) {
          
          
          Vector directionI = dots[i].getDirection(dots[j]);
          Vector projectionXI = dots[i].getVelocityProjection(directionI);
          Vector projectionYI = new Vector(dots[i].velocity.x - projectionXI.x , dots[i].velocity.y - projectionXI.y);
                   
          Vector directionJ = dots[j].getDirection(dots[i]);
          Vector projectionXJ = dots[j].getVelocityProjection(directionJ);
          Vector projectionYJ = new Vector(dots[j].velocity.x - projectionXJ.x , dots[j].velocity.y - projectionXJ.y);
         
          
          Vector resultI = new Vector(projectionXJ.x + projectionYI.x , projectionXJ.y + projectionYI.y);
          Vector resultJ = new Vector(projectionXI.x + projectionYJ.x , projectionXI.y + projectionYJ.y);
          
          dots[i].velocity = resultI;
          dots[j].velocity = resultJ;       
      }
    }
  }
  
  velocityMid = 0;
  for(int i = 0 ; i < AMOUNT ; i++)
  {
    velocityMid += dots[i].velocity.getLength()*dots[i].velocity.getLength();
  }
  velocityMid = velocityMid/AMOUNT;

  for (int i = 0; i < AMOUNT; i++) {

    float thisPos = dots[i].velocity.x + dots[i].position.x;
    if (thisPos < minPos ||
      thisPos >= (maxPos-objSize))
      dots[i].velocity.x = -dots[i].velocity.x;
    else
      dots[i].position.x = thisPos;

    thisPos = dots[i].velocity.y + dots[i].position.y;
    if (thisPos < minPos || 
      thisPos >= (maxPos-objSize))
      dots[i].velocity.y = -dots[i].velocity.y;
    else
      dots[i].position.y = thisPos;
  }  
  int maxVelocity = startVelocity*3;
  int[] data = new int[maxVelocity];
  
  if(flag == false && time % graph_time == 0){
  for(int i = 0 ; i < AMOUNT ; i++){
    flag = true;
    
    int k = int(dots[i].velocity.getLength());
    if(k >= maxVelocity - 1 )
    {
      data[maxVelocity - 1]+= 1;
    }else{
    data[k] += 1;
    }
  }
    String l = "";
    for(int i = 0 ; i < maxVelocity ; i++)
    {
      l = time + ","+ i + ","+data[i];
      logs.println(l);
      l = "";
    }

    logs.flush();
  }

  fill(#505050);
  for (int i = 0; i < AMOUNT; i++) {
      image(mask, dots[i].position.x, dots[i].position.y, objSize*5, objSize*5);
  }
  time++;

  fill(#ffffff);
  rect(windowH, 0, windowH+150, 75);
  fill(#505050);
  
  text("Probable:", windowH, 30);
  text(getProb(), windowH+120, 30);
  
  text("Average:", windowH, 45);
  text(getMid(), windowH+120, 45);
  
  text("Rms:", windowH, 60);
  text(getRms(), windowH+120, 60);

  text("Time:", windowH, 75);
  text(time, windowH+120, 75);
  
  return flag;
  
}





class Vector
{
float x;
float y;
public Vector(float x, float y)
{
  this.x = x;
  this.y = y;
}
public Vector()
{
}
  float getLength()
  {
    return sqrt(x*x+y*y);
  }
  Vector normalize()
  {
    float a = sqrt(1/(x*x+y*y));
    Vector normalized = new Vector(a*x , a*y);
    return normalized;
  }
  Vector getNormalVector()
  {
    float yNew = this.y;
    float xNew = this.x;
    Vector v = new Vector(-yNew , xNew);
    return v;
  }
    Vector toLength(float length)
  {
    float a = sqrt((length*length)/(x*x+y*y));
    Vector normalized = new Vector(a*x , a*y);
    return normalized;
  }
}

class Dot
{
  Vector position = new Vector();
  Vector velocity = new Vector();
  public Dot(float xPos , float yPos , float xVelocity , float yVelocity )
{
  this.position.x = xPos;
  this.position.y = yPos;
  this.velocity.x = xVelocity;
  this.velocity.y = yVelocity;
    
}
  Vector getDirection(Dot target)
  {
    float x = target.position.x - this.position.x;
    float y = target.position.y - this.position.y;
    return new Vector(x , y);
  }
  Vector getVelocityProjection(Vector v)
  { 
    float length = this.velocity.getLength();
    float cos = (v.x*this.velocity.x + v.y*this.velocity.y)/(length*v.getLength());
    float projectionVectorLength = abs(length*cos);
    int sign = signFunc(cos);
    Vector vResult = v.toLength(projectionVectorLength);
    return new Vector(sign*vResult.x , sign*vResult.y );
  }
}
int signFunc(float x)
{
  if(x >= 0)return 1;
  return -1;
  
}

float getProb()
  {
  int maxVelocity = startVelocity*3;
  int maxCount = 0;
  int maxValue = 0;
  int[] data = new int[maxVelocity];
        for(int i = 0 ; i < AMOUNT ; i++){
      
      int k = int(dots[i].velocity.getLength());
      if(k >= maxVelocity - 1 )
      {
        data[maxVelocity - 1]+= 1;
      }else{
      data[k] += 1;
      }
    }
            for(int i = 0 ; i < maxVelocity ; i++){
              if(maxCount < data[i])
              {
                maxCount = data[i];
                maxValue = i;
              }
                
    }
    return maxValue;
  }
float getMid()
  {
    float mid = 0;
            for(int i = 0 ; i < AMOUNT ; i++)
          {
            mid += dots[i].velocity.getLength();
          }
    return mid/AMOUNT;
              
  }
float getRms()
  {
    float mid = 0;
            for(int i = 0 ; i < AMOUNT ; i++)
          {
            float length = dots[i].velocity.getLength();
            mid += length*length;
          }
    return mid/AMOUNT;
              
  }
