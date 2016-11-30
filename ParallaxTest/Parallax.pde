



float camX, camY, camZ;

Grid grid;
PFont font;
void setup()
{
  background(0);
  strokeWeight(1);
  size(500,300);
  font = loadFont("Univers66.vlw.gz");
  textFont(font, 10);
  textAlign(LEFT, CENTER);
  //smooth();

  tilefloor = loadImage("floortile.png");
  tilehole = loadImage("holetile.png");
  tilewall = null;

  if(tilefloor == null)
    println("null tilefloor");
  if(tilehole == null)
    println("null tilehole");

  camX = maxX*0.5; 
  camY = maxY*0.5; 
  camZ = 2;
  grid = new Grid(maxX,maxY,maxZ);
  for(int x=0; x<maxX; x++)
    for(int y=0; y<maxY; y++)
      for(int z=0; z<maxZ; z++)
        grid.setTile(x,y,z,int(random(3)));

}

void draw()
{
  background(0);
  keyListeners();
  corrections();
  grid.think();
  stroke(250);
  noFill();
  ellipse(width/2, height/2, 10,10);

  float tilesx = mouseX;
  tilesx = tilesx/tileSize - 0.5*width/tileSize;
  float tilesy = mouseY;
  tilesy = tilesy/tileSize - 0.5*height/tileSize;

  println(int(camX+tilesx)+","+int(camY+tilesy)+","+int(camZ));

}

int keyPause = 0;
void keyListeners()
{
  if(mouseButton == LEFT)
  {
    //(X-camX)*ts+width/2 = x
    float ts = tileSize/1.2; 


  }
  if(mouseButton == RIGHT)
  {

  }

  float k = 0.1;
  if(keyCode == UP)
  {
    camY-=k;
  }
  if(keyCode == DOWN)
  {
    camY+=k;
  }
  if(keyCode == LEFT)
  {
    camX-=k;
  }
  if(keyCode == RIGHT)
  {
    camX+=k;
  }
  if(keyCode == 34 && keyPause == 0)
  {
    camZ-=1;
    keyPause = 10;
  }
  if(keyCode == 33 && keyPause == 0)
  {
    camZ+=1;
    keyPause = 10;
  }
  keyCode = 0;

  if(keyPause > 0)
    keyPause--;
}

void corrections()
{
  //  if(camX < 0)
  //    camX = 0;
  //  if(camX >= maxX)
  //    camX = maxX-1;
  //
  //  if(camY < 0)
  //    camY = 0;
  //  if(camY >= maxY)
  //    camY = maxY-1;

  if(camZ < 0)
    camZ = 0;
  if(camZ > maxZ-1)
    camZ = maxZ-1;

}








