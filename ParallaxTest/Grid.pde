int maxX = 20, maxY = 20, maxZ = 6;

class Grid
{

  Tile[][][] tiles;

  Grid(int x, int y, int z)
  {
    if(x < 1 || y < 1 || z < 1)
      return;

    tiles = new Tile[x][y][z];
    maxX = x;
    maxY = y;
    maxZ = z;
  } 

  void think()
  {
    for(int z=0; z<maxZ; z++)
      for(int x=0; x<maxX; x++)
        for(int y=0; y<maxY; y++)
          if(tiles[x][y][z]!=null)
            tiles[x][y][z].think();

  }

  boolean isValid(int x, int y, int z)
  {
    if(x < 0 || x >= maxX)
      return false;
    if(y < 0 || y >= maxY)
      return false;
    if(z < 0 || z >= maxZ)
      return false;

    return true;
  }

  void setTile(int x, int y, int z, int t)
  {
    if(!isValid(x, y, z))
      return;

    tiles[x][y][z] = new Tile(x,y,z,t);

  }




}



