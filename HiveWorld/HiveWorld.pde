//author:    Lucas Hedinger
//version:   1.0
//contact:   lucas27@umd.edu

int WIDTH = 200;
int HEIGHT = 100;
int SIZE = 4;
float RECK = 0.55;

Creature[] creatures = new Creature[45];
color[][] world = new color[HEIGHT][WIDTH];

//ENUM VALUES
final static int HIVE = -1, WORKER = 0, SOLDIER = 1;

int frequency = 1;
boolean oldschool = false;
boolean paused = false;

int red_x, red_y;
int blue_x, blue_y;
int green_x, green_y;

final color impassable = color(0);
final color earth = color(50);
final color space = color(255);
final color border = color(30);
final color red_creature = color(150,0,0);
final color blue_creature = color(0,150,0);
final color green_creature = color(0,0,150);
//v------------------------------------------------------------SETUP

void setup()
{
  background(150);
  size(WIDTH*SIZE, HEIGHT*SIZE);

  initialize();
}

void initialize()
{
  for(int r=0; r<HEIGHT; r++)
    for(int c=0; c<WIDTH; c++)
      world[r][c] = earth; 

  int x, y;

  RECK = 0.7;
  for(int j=0; j<50; j++)
    drawCluster(int(random(WIDTH)),int(random(HEIGHT)),impassable);
  RECK = 0.6;
  for(int j=0; j<50; j++)
    drawCluster(int(random(WIDTH)),int(random(HEIGHT)),space);

  red_x = int(random(WIDTH));
  red_y = int(random(HEIGHT));
  drawCluster(red_x,red_y,space);
  creatures[0] = new Hive(red_x, red_y, red_creature);
  for(int d=1; d<15; d++)
  {
    creatures[d] = new Worker(red_x, red_y, red_creature);
  }
  green_x = int(random(WIDTH));
  green_y = int(random(HEIGHT));
  drawCluster(green_x,green_y,space);
  creatures[15] = new Hive(green_x, green_y, green_creature);
  for(int d=16; d<30; d++)
  {
    creatures[d] = new Worker(green_x, green_y, green_creature);
  }
  blue_x = int(random(WIDTH));
  blue_y = int(random(HEIGHT));
  drawCluster(blue_x,blue_y,space);
  creatures[30] = new Hive(blue_x, blue_y, blue_creature);
  for(int d=31; d<45; d++)
  {
    creatures[d] = new Worker(blue_x, blue_y, blue_creature);
  }
}

void mousePressed()
{
  RECK = 0.55;
  if(mouseButton == LEFT)
    drawCluster(mouseX/SIZE, mouseY/SIZE, impassable); 
  else
    drawCluster(mouseX/SIZE, mouseY/SIZE, space); 
}

void mouseDragged()
{
  RECK = 0.95;
  if(mouseButton == LEFT)
    drawCluster(mouseX/SIZE, mouseY/SIZE, impassable); 
  else
    drawCluster(mouseX/SIZE, mouseY/SIZE, space); 
}

void keyPressed()
{
  if(keyCode == 'R')
    initialize();
  if(keyCode == 'O')
    oldschool = !oldschool;
  if(keyCode == 'P')
    paused = !paused;
  if(keyCode == 'A')
    if(frequency > 1)
      frequency--;
  if(keyCode == 'Z')
    if(frequency < 10)
      frequency++;

}

//v------------------------------------------------------------DRAW

void draw()
{
  if(!paused && frameCount%frequency == 0)
  {
    for(int i=0; i<creatures.length; i++)
    {
      if(creatures[i] != null)
        creatures[i].run();   
    }

    for(int r=0; r<HEIGHT; r++)
      for(int c=0; c<WIDTH; c++)
      { 
        color col = world[r][c];

        set(c*SIZE  , r*SIZE  , col);
        set(c*SIZE  , r*SIZE+1, col);
        set(c*SIZE  , r*SIZE+2, col);
        set(c*SIZE  , r*SIZE+3, col);
        set(c*SIZE+1, r*SIZE  , col);
        set(c*SIZE+2, r*SIZE  , col);
        set(c*SIZE+3, r*SIZE  , col);

        set(c*SIZE+1, r*SIZE+1, col);
        set(c*SIZE+1, r*SIZE+2, col);

        set(c*SIZE+2, r*SIZE+1, col);
        set(c*SIZE+2, r*SIZE+2, col);


        if(!oldschool)
          col = border;   
        set(c*SIZE+1, r*SIZE+3, col);
        set(c*SIZE+2, r*SIZE+3, col);  
        set(c*SIZE+3, r*SIZE+1, col);
        set(c*SIZE+3, r*SIZE+2, col);
        set(c*SIZE+3, r*SIZE+3, col);
      }
  }
}
//v------------------------------------------------------------CLASSES




class Creature
{
  int X;
  int Y;
  int dx;
  int dy;

  int type;

  color prev;

  color team;
  color team_path;

  Creature(int x, int y, int t, color tm) 
  {
    X = x;
    Y = y;
    if(t >= -1 && t < 3)
      type = t;
    else
      type = 0;

    team = tm;
    team_path = color(red(tm)+100, green(tm)+100, blue(tm)+100);

    prev = space;
  }

  int randomDir()
  {
    int n = (int)(random(3));
    
     if(n == 2)
       return -1;
    
    return n;
  }

  void run()
  {
    think();

    if(dx > 1)
      dx = 1;
    if(dx < -1)
      dx = -1;
    if(dy > 1)
      dy = 1;
    if(dy < -1)
      dy = -1;  

    if(collision(X+dx, Y+dy))
    {
      int tempx = randomDir();
      int tempy = randomDir();
      
      dx = 0;
      dy = 0;

      if(!collision(X+tempx, Y+tempy))
      {
        dx = tempx;
        dy = tempy;
      }
      
    }

    wset(X,Y,prev);

    X += dx;
    Y += dy;

    wset(X,Y,team);

  }

  boolean collision(int x, int y)
  {
    return false;
  }

  void think()
  {

  }

  void navigateTo(int x, int y)
  {


  }

  int moveTo(int x, int y, int xdest, int ydest)
  {

    int a = moveTo(x-1, y  , xdest, ydest);
    int b = moveTo(x  , y-1, xdest, ydest);
    int c = moveTo(x  , y+1, xdest, ydest);
    int d = moveTo(x+1, y  , xdest, ydest);

    if(wget(x,y) != space && wget(x,y) != team_path)
    {
      return 9999;  
    }
    return int(dist(X, Y, x, x));
  }


}


class Hive extends Creature
{
  Hive(int x, int y, color tm)
  {
    super(x, y, HIVE, tm);
  }

  void think()
  {
    wset(X-1, Y-1, team);
    wset(X+1, Y-1, team);
    wset(X, Y, team);
    wset(X-1, Y+1, team);
    wset(X+1, Y+1, team);
  }

}

class Digger extends Creature
{
  int hiveX,hiveY;
  boolean carrying = false;
  color team_gray;

  Digger(int x, int y, color tm)
  {
    super(x, y, WORKER, tm);
    hiveX = x;
    hiveY = y;
    team_gray = color(red(tm)-100, green(tm)-100, blue(tm)-100);

  }

  boolean collision(int x, int y)
  {
    //if(wget(x,y) == space)
      //return false;
    if( wget(x,y) == earth)
      return false;
    if(wget(x,y) == team_path)
      return false;

    return true;
  }

  void think()
  {
    dx = 0;
    dy = 0;


    if(abs(X-hiveX) <= 2 && abs(Y-hiveY) <= 2)
      carrying = false;

    if(!carrying)
    {
      int r = int(random(5));

      if(r == 0)
      {
        dx = 0; 
        dy = 0; 
      }
      if(r == 1)
      {
        dx = 1; 
        dy = 0; 
      }    
      if(r == 2)
      {
        dx = 0; 
        dy = 1; 
      }    
      if(r == 3)
      {
        dx = -1; 
        dy = 0; 
      }
      if(r == 4)
      {
        dx = 0; 
        dy = -1; 
      }
    }
    else
      toHive();

    if(X+dx < 0 || X+dx > WIDTH)
    {
      dx = 0;
      //println("hit Xbound");
    }
    if(Y+dy < 0 || Y+dy > HEIGHT)
    {
      dy = 0;
      //println("hit Ybound");
    }

    if(carrying && wget(X+dx, Y+dy) == earth)
    {
      dx = 0;
      dy = 0; 
    }
    if(wget(X+dx,Y+dy) == earth)
      carrying = true;


    if(!carrying)
      prev = space;
    else
      prev = space;
  }

  void toHive()
  {

    if(dist(X,Y,hiveX, hiveY)/dist(X+dx, Y+dy, hiveX, hiveY) > 1.2)
    {
      dx = 0;
      dy = 0;
      carrying = false;
    }
    else
    {
      float dir = atan2(hiveY-Y, hiveX-X); 

      dx = round(2*cos(dir));
      dy = round(2*sin(dir));
    }

  }

}

class Worker extends Creature
{
   int hiveX,hiveY;
  boolean carrying = false;
  color team_gray;

  Worker(int x, int y, color tm)
  {
    super(x, y, WORKER, tm);
    hiveX = x;
    hiveY = y;
    team_gray = color(red(tm)-100, green(tm)-100, blue(tm)-100);

  }

  boolean collision(int x, int y)
  {
    if(wget(x,y) == space)
      return false;
    if( wget(x,y) == earth)
      return false;
    if(wget(x,y) == team_path)
      return false;

    return true;
  }

  void think()
  {
    dx = 0;
    dy = 0;


    if(abs(X-hiveX) <= 2 && abs(Y-hiveY) <= 2)
      carrying = false;

    if(!carrying)
    {
      int r = int(random(5));

      if(r == 0)
      {
        dx = 0; 
        dy = 0; 
      }
      if(r == 1)
      {
        dx = 1; 
        dy = 0; 
      }    
      if(r == 2)
      {
        dx = 0; 
        dy = 1; 
      }    
      if(r == 3)
      {
        dx = -1; 
        dy = 0; 
      }
      if(r == 4)
      {
        dx = 0; 
        dy = -1; 
      }
    }
    else
      toHive();

    if(X+dx < 0 || X+dx > WIDTH)
    {
      dx = 0;
      //println("hit Xbound");
    }
    if(Y+dy < 0 || Y+dy > HEIGHT)
    {
      dy = 0;
      //println("hit Ybound");
    }

    if(carrying && wget(X+dx, Y+dy) == earth)
    {
      dx = 0;
      dy = 0; 
    }
    if(wget(X+dx,Y+dy) == earth)
      carrying = true;


    if(!carrying)
      prev = team_path;
    else
      prev = space;
  }

  void toHive()
  {

    if(dist(X,Y,hiveX, hiveY)/dist(X+dx, Y+dy, hiveX, hiveY) > 1.2)
    {
      dx = 0;
      dy = 0;
      carrying = false;
    }
    else
    {
      float dir = atan2(hiveY-Y, hiveX-X); 

      dx = round(2*cos(dir));
      dy = round(2*sin(dir));
    }

  }
  
}

class Soldier extends Creature
{

  Soldier(int x, int y, color tm)
  {
    super(x, y, SOLDIER, tm);
  } 

  void think()
  {
    int r = int(random(5));
    if(r == 0)
    {
      dx = 0; 
      dy = 0; 
    }
    if(r == 1)
    {
      dx = 1; 
      dy = 0; 
    }    
    if(r == 2)
    {
      dx = 0; 
      dy = 1; 
    }    
    if(r == 3)
    {
      dx = -1; 
      dy = 0; 
    }
    if(r == 4)
    {
      dx = 0; 
      dy = -1; 
    }

    if(X+dx < 0 || X+dx > WIDTH)
    {
      dx = 0;
      println("hit Xbound");
    }
    if(Y+dy < 0 || Y+dy > HEIGHT)
    {
      dy = 0;
      println("hit Ybound");
    }

    if(wget(X+dx,Y+dy) != team_path)
    {
      dx = 0;
      dy = 0; 
      //println("could not move");     
    }

    if(prev == space)
      prev = team_path;
    if(prev == earth)
      prev = space;

    wset(X,Y,prev);
    X += dx;
    Y += dy;
    prev = wset(X,Y,team);
  }


}


boolean drawCluster(int x, int y, color col)
{
  if(x < 0 || y < 0)
    return false;
  if(x >= WIDTH || y >= HEIGHT)
    return false;

  wset(x,y,col);

  if(random(1) > RECK && wget(x-1, y  ) != col)
    drawCluster(x-1, y,   col);
  if(random(1) > RECK && wget(x,   y-1) != col)
    drawCluster(x,   y-1, col);
  if(random(1) > RECK && wget(x,   y+1) != col)
    drawCluster(x,   y+1, col);
  if(random(1) > RECK && wget(x+1, y  ) != col)
    drawCluster(x+1, y,   col);

  return true;
}

color wget(int x, int y)
{
  if(x<0 || y<0)
    return impassable;
  if(x>=WIDTH || y>= HEIGHT)
    return impassable;

  return world[y][x];
}

color wset(int x, int y, color col)
{
  color original;
  if(x<0 || y<0)
    return impassable;
  if(x>=WIDTH || y>= HEIGHT)
    return impassable;
  original = world[y][x];
  world[y][x] = col;
  return original;
}






























