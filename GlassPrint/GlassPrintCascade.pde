ArrayList cascades = new ArrayList();

void renderCascade()
{
  noStroke();
  yoffset = 10;
  drawCascadeBlock(0, 10, 10, 0);
}

int yoffset = 0;
void drawCascadeBlock(int i, int x, int s, int c)
{
  int y = yoffset;
  yoffset += s*2;
  fill(150, 100);
  rect(x-s*2, y, 2*s, s);

  Cascade casc = (Cascade)cascades.get(i);
  int cs = casc.getAllChildren();

  rect(x, y, s, cs*s*2+s);


  fill(0);
  text(casc.getName(), x+s+5, y+s);
  rect(x, y, s, s);


  for (int j : casc.getChildren())
  {
    cs--;
    drawCascadeBlock(j, x+s*2, s, cs);
  }
}


void testCascade()
{

  String[] lines = loadStrings("filesys.txt");

  for (String lin : lines)
  {
    int d = lin.lastIndexOf('\\')+1;

    Cascade casc = new Cascade(cascades.size(), lin.substring(d), d);


    for (int i=cascades.size()-1; i>=0; i--)
    {
      Cascade c = (Cascade)cascades.get(i);

      if (!casc.hasParent())
        if (c.getDepth() == d-1)
        {
          println(lin+" gets parent "+i);
          casc.setParent(i);
          continue;
        }
    }

    cascades.add(casc);
  }

  for (int i=cascades.size()-1; i>=0; i--)
  {
    Cascade c = (Cascade)cascades.get(i);

    int p = c.getParent();

    if (p>=0)
      ((Cascade)cascades.get(p)).addChild(i);
  }
}

class Cascade
{
  int index;
  int depth;
  String name;
  int parent = -1;
  int[] children = new int[0]; 

  Cascade(int i, String n, int d)
  {
    index = i;
    name = n;
    depth = d;
  }

  boolean hasParent()
  {
    return parent > -1;
  }

  String getName()
  {
    return name;
  }

  int getDepth()
  {
    return depth;
  }

  int getAllChildren()
  {
    int i = 0;
    for (int c : children) 
    {
      Cascade casc = (Cascade)cascades.get(c);
      i += casc.getAllChildren()+1;
    }

    return i;
  }

  int[] getChildren()
  {
    return children;
  }

  int getParent()
  {
    return parent;
  }

  void setParent(int i)
  {
    parent = i;
  }

  void addChild(int i)
  {
    children =  append(children, i);
  }
}

