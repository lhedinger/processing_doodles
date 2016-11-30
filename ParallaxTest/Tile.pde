int tileSize = 50;

PImage tilefloor, tilehole, tilewall;

//ENUM TILETYPE
static final int TILE_EMPTY = 0;
static final int TILE_WALL = 1;
static final int TILE_FLOOR = 2;


class Tile
{
  int X, Y, Z;
  float liquid;  //percentage of liquid height 0-1
  int type;
  //8+9+9 = 26
  int[] connected;

  Tile(int x, int y, int z, int t)
  {
    X = x;
    Y = y;
    Z = z;
    liquid = 0;
    type = t;
  }

  void think()
  {
    float zk = camZ - Z + 1;
   
    //float ts = zk*tileSize/(zk+1); cool pop-in effect...future use?
    float ts = (tileSize/pow(zk,0.05)); 

    if(zk > 0)
    {
      fill(0,0);

      if(type == TILE_EMPTY)
      {
        //if(tilehole != null)
          //image(tilehole,(X-camX)*ts+width/2,(Y-camY)*ts+height/2, ts, ts);
      }
      if(type == TILE_FLOOR)
      {
        fill((0.5*150/zk)*2);
        stroke(0);
        rect((X-camX)*ts+width/2,(Y-camY)*ts+height/2, ts, ts);
        //if(tilefloor != null)
          //image(tilefloor,(X-camX)*ts+width/2,(Y-camY)*ts+height/2, ts, ts);
      }
      if(type == TILE_WALL)
      {
        fill((0.5*100/zk)*2);
        stroke(0);
        rect((X-camX)*ts+width/2,(Y-camY)*ts+height/2, ts, ts);
        line((X-camX)*ts+width/2,(Y-camY)*ts+height/2, (X-camX)*ts+width/2 + ts,(Y-camY)*ts+height/2 + ts);
        line((X-camX)*ts+width/2,(Y-camY)*ts+height/2 + ts, (X-camX)*ts+width/2 + ts,(Y-camY)*ts+height/2);
        fill((0.5*160/zk)*2);
        rect((X-camX)*ts+width/2+5,(Y-camY)*ts+height/2+5, ts-10, ts-10);
        
      }
    }
  }

  int getType()
  {
    return type;
  }

  int[] getconnected()
  {
    return null;
  }





}








