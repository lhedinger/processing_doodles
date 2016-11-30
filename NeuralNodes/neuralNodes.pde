//author:    Lucas Hedinger
//version:   1.0
//contact:   lucas27@umd.edu



PFont font;
int SIZE = 32;

Node[] nodes; // ordering matters! the ID of each Node marks its slot
Signal[] signals;

int deadSignals = 0;

int num_nodes = 0;
int num_connections = 0;
int num_signals = 0;
//v------------------------------------------------------------SETUP

void setup()
{
  size(800,600);
  font = loadFont("Univers66.vlw.gz");
  textAlign(CENTER,CENTER);
  textFont(font, 18);
  smooth();

  signals = new Signal[0];
  nodes = new Node[SIZE];

  createRandom();
  //createEmpty();
}

void createRandom()
{
  signals = new Signal[0];
  nodes = new Node[SIZE];

  nodes[0] = new Node(0, false);
  for(int i=1; i<SIZE; i++)
    nodes[i] = new Node(i,true);
}

void createEmpty()
{
  nodes = new Node[SIZE];
  signals = new Signal[0];

  for(int i=0; i<SIZE; i++)
    nodes[i] = new Node(i,false); 
}
//v------------------------------------------------------------DRAW

void draw()
{
  background(0);
  println(frameRate+" "+num_signals+"/"+num_connections+" ("+num_nodes+")");

  strokeWeight(1);
  stroke(250, 250);

  num_signals = 0;
  num_connections = 0;
  num_nodes = 0;

  drawNodes();
  drawSignals();
}

//DRAW NODES
void drawNodes()
{
  int selectedalpha;
  Node n;
  int n_t;
  int[] n_c;
  Node n_cn;

  //Draw Node Body
  for(int i=0; i<nodes.length; i++)
  {
    num_nodes++;

    n = nodes[i];
    n_t = nodes[i].Type();

    strokeWeight(1);
    if(i == selected)
      strokeWeight(3);

    //determine node color
    if(n_t == 0)//empty node  
      fill(0,0,0,200);//black
    if(n_t == 1)//counter node  
      fill(250,250,250,200);//white
    if(n_t == 2)//relay node
      fill(0,0,150,200);//blue
    if(n_t == 3)//alternator node
      fill(150,0,0,200); //red
    if(n_t == 4)//capacity node
      fill(0,150,0,200); //green
    if(n_t == 5)//converter node
      fill(50,50,50,200);//gray

    if(n_t >= 0 && n_t <= 5)
    {
      //draw node color
      ellipse(n.X(),n.Y(),n.R()*2,n.R()*2);
      //draw node origin
      fill(250);
      ellipse(n.X(),n.Y(),5,5);
    }
  }

  //Draw Node Connections
  strokeWeight(1);
  stroke(255);
  for(int i=0; i<nodes.length; i++)
  {
    n = nodes[i];
    n_c = n.Connections();

    for(int c=0; c<n_c.length; c++)
    {
      n_cn = nodes[n_c[c]];

      if(n_cn != null)
      {
        num_connections++;
        //draw node lines
        line(n.X(),n.Y(),n_cn.X(),n_cn.Y());

        float dir = atan2(n_cn.Y()-n.Y(), n_cn.X()-n.X());

        //draw node pointers
        fill(250);
        if(n.Type() == 3)//alternator node
        {
          if(n.getCounter() != c)
            fill(0,0);
        }

        ellipse(n.dirX(dir),n.dirY(dir),5,5);
      }
    }

    if(n.Type() == 1)//counter node
    {
      fill(0);
      text(n.getCounter(), n.X(), n.Y());
    }

  }

}



void drawSignals()
{
  fill(250);

  deadSignals = 0;
  for(int i=0; i<signals.length; i++)
  {
    if(signals[i].think())
    {
      ellipse(signals[i].X(), signals[i].Y(), 5, 5);
      num_signals++; 
    }
    else
      deadSignals++;
  }
  if(deadSignals > 400)
  {
    Signal[] temp = new Signal[signals.length];
    int temp_length = 0;
    for(int i=0; i<signals.length; i++)
      if(!signals[i].isDead())
      {
        temp[temp_length] = signals[i];
        temp_length++;
      }
    signals = (Signal[])subset(temp, 0, temp_length);
  }
}

//v------------------------------------------------------------LISTENERS

void keyPressed()
{
  if(key == ENTER)
  { 
    if(selected >= 0 && selected < nodes.length)
      nodes[selected].ping(int(random(16)+1));
    else
    {
      for(int i=0; i<nodes.length; i++)
        nodes[i].ping(int(random(16)+1));
    }
  }
  if(key == BACKSPACE)
  {
    signals = new Signal[0];
    for(int i=0; i<nodes.length; i++)
      nodes[i].reset();
  }

  if(keyCode == 'R')
    createRandom(); 
  if(keyCode == 'E')
    createEmpty(); 

  if(keyCode == 'T')
  {
    signals = new Signal[0];
    if(selected >= 0 && selected < nodes.length)
      nodes[selected].toogleType();
  }
  if(keyCode == 'Y')
  {
    signals = new Signal[0];
    if(selected >= 0 && selected < nodes.length)
      nodes[selected].setType(0);
  }
}

int selected = -1;
int target = -1;

void mousePressed()
{
  if(mouseButton == LEFT)
  {
    selected = -1;
    for(int i=0; i<nodes.length; i++)
      if(dist(mouseX, mouseY, nodes[i].X(), nodes[i].Y()) < nodes[i].R())
        selected = i;
  }

  if(mouseButton == RIGHT)
  {
    target = -1;

    for(int i=0; i<nodes.length; i++)
    {
      if(dist(mouseX, mouseY, nodes[i].X(), nodes[i].Y()) < nodes[i].R())
        target = i;
    } 
    if(target != selected)
      if(target >= 0 && target < nodes.length && selected >=0 && selected < nodes.length)
      { 
        signals = new Signal[0];
        nodes[selected].toogleConnection(target);
      }
  }
}

void mouseDragged()
{
  if(mouseButton == LEFT)
  {
    if(selected >= 0 && selected < nodes.length)
    {
      signals = new Signal[0];
      nodes[selected].setXY(mouseX,mouseY);
    }
    else
      for(int i=0; i<nodes.length; i++)
      {
        if(dist(mouseX, mouseY, nodes[i].X(), nodes[i].Y()) < nodes[i].R())
          selected = i;
      } 

  }
}

void removeLocalSignals()
{
  for(int i = 0; i<signals.length; i++)
  {
    if(signals[i].contains(selected))
      signals[i].die(); 

  }

}

//===========================================================================
//==CLASSES=CLASSES=CLASSES=CLASSES=CLASSES=CLASSES=CLASSES=CLASSES=CLASSES==
//===========================================================================

class Node
{
  int ID;
  float X;
  float Y;
  float radius;

  int type;
  // 0 = void node           0   ports 
  // 1 = counter node        0-1 ports
  // 2 = relay node          1+  ports
  // 3 = alternator node     2+  ports 
  // 4 = capacity node       2+  ports 
  // 5 = converter node      1 port
  // 6 = ??                  1 port

  int counter = 0;

  int[] connections; // array of Node IDs; only keeps track of outgoing connections

    Node(int index, boolean cons)
  {
    ID = index;
    X = random(width);
    Y = random(height);
    radius = random(20,40);
    connections = new int[0];



    int c = int(random(0, 5));
    for(int i=0; i<c; i++)
      toogleConnection(int(random(SIZE)));
    if(random(0,2) == 0)
      toogleConnection(0);
    setType(int(random(1,5)));

    if(!cons)
      setType(0);
  } 

  void ping(int val)
  {
    if(type == 1 || type == 2)
    {
      counter = val;
      for(int i=0; i<connections.length; i++)
        signals = (Signal[])append(signals, new Signal(ID, connections[i], val));
    }
    if(type == 3)
    {
      counter++;
      
      if(counter >= connections.length) {
        counter= 0;
      }
      
      signals = (Signal[])append(signals, new Signal(ID, connections[counter], val));  
    }
    if(type == 4)
    {
      if(counter >= val)
        counter -= val;
      else
        counter += val;
        
      for(int i=0; i<connections.length; i++)
        signals = (Signal[])append(signals, new Signal(ID, connections[i], counter));
    }
  }

  void reset()
  {
    counter = 0;
    if(type == 4)
      radius = 20;
  }

  void setType(int t)
  {
    counter = 0;
    radius = random(20,40);

    if(t == 0)//void node
    {
      type = 0; 
      connections = new int[0];
      radius = 40;
    }
    if(t == 1)//counter node
    {
      type = 1;
      radius = 20;
    }
    if(t == 2)//relay node
    {
      type = 2;
    }
    if(t == 3)//alternator node
    {
      type = 3; 
    }
    if(t == 4)//capacity node
    {
      type = 4;  
      radius = 20;
    }
    if(t == 5)
    {
      type = 5; 
      radius = 10;
    }

    fixType();

  }

  void toogleType()
  {
    if(connections.length < 1)
    {
      if(type == 0)
        type = 1;
      else
        type = 0;
    }
    if(connections.length == 1)
    {
      if(type == 2)
        type = 1;
      else
        type = 2;
    }
    if(connections.length > 1)
    {
      if(type == 2)
        type = 3;
      else if(type == 3)
        type = 4;
      else
        type = 2;
    } 
    radius = 20 + connections.length*2;
  }

  void fixType()
  {
    if(connections.length < 1)
    {
      if(type > 1)
        type = int(random(0, 2));
    }
    if(connections.length == 1)
    {
      if(type > 2 || type == 0)
        type = int(random(1, 3));
    }
    if(connections.length > 1)
    {
      if(type < 2)
        type = int(random(2, 5));
    }
    if(type != 0)
    radius = 20 + connections.length*2;
  }

  void toogleConnection(int index)
  {
    counter = 0;
    if(validConnection(index))
    {
      if(uniqueConnection(index))
      {
        connections = append(connections, index);
      }
      else
      {
        int[] temp = new int[0];
        for(int i=0; i<connections.length; i++)
        {
          if(connections[i] != index)
            temp = (int[])append(temp, connections[i]);
        }
        connections = temp;
      }
      fixType();
    }
  }

  boolean validConnection(int index)
  {
    if(index < 0 || index > nodes.length)
      return false;
    if(index == ID)
      return false;  

    return true;
  }

  boolean uniqueConnection(int index)
  {
    for(int i=0; i<connections.length; i++)
    {
      if(connections[i] == index)
        return false;
    }
    return true; 
  }

  int[] Connections()
  {
    return connections; 
  }
  int getCounter()
  {
    return counter;
  }
  float X()
  {
    return X;
  }
  float Y()
  {
    return Y;
  }
  void setXY(int x, int y)
  {
    X = x;
    Y = y;    
  }
  float R()
  {
    return radius; 
  }
  float dirX(float dir)
  {
    return X+radius*cos(dir);
  }
  float dirY(float dir)
  {
    return Y+radius*sin(dir);
  }
  int ID()
  {
    return ID; 
  }
  int Type()
  {
    return type; 
  }
}

class Signal
{
  int start;
  int end;
  float direction;
  float X;
  float Y;
  float x;
  float y;
  boolean dead = false;
  int value;

  Signal(int s, int e, int v)
  {
    start = s;
    end = e;
    X = nodes[start].X();
    Y = nodes[start].Y();
    x = nodes[end].X();
    y = nodes[end].Y();
    direction = atan2(y-Y, x-X);
    value = v;
  } 

  boolean think()
  {
    if(dead)
      return false;
    if(dist(X,Y,x,y) < nodes[end].R())
    {
      nodes[end].ping(value);
      dead = true;
      return false;
    }
    x = nodes[end].X();
    y = nodes[end].Y();
    direction = atan2(y-Y, x-X);
    X += 2*cos(direction);
    Y += 2*sin(direction);
    return true;
  }

  boolean isDead()
  {
    return dead; 
  }
  void die()
  {
    dead = true; 
  }
  float X()
  {
    return X;
  }
  float Y()
  {
    return Y;
  }
  int value()
  {
    return value;
  }
  boolean contains(int i)
  {
    if(i == start || i == end)
      return true;

    return false; 

  }

}



