int tree_select = -1;
int tree_select_pre = -1;


void renderTree()
{
  if (nodes == null)
    return;

  TNode root = nodes.get(0);
  if (tree_select >= 0 && tree_select < nodes.size())
  {
    println(tree_select);
    nodes.get(tree_select).toggleRender();
    tree_select = -1;
  }

  stroke(0);
  strokeWeight(1);
  noFill();

  root.updateAll(); //recursive

  root.renderAll_Group();
  textFont(LOG_FONT, 12);
  root.renderAll_Lines(); //recursive
  root.renderAll_Nodes(); //recursive
  root.renderAll_Names(); //recursive


  //root.optimizeTree();
  int i=0;
  tree_select_pre = -1;
  for (TNode node : nodes)
  {
    if (dist(node.getX(), node.getY(), mouseX+camX, mouseY+camY) < 10)
      tree_select_pre = i;
    i++;
  }
}


ArrayList<TNode> nodes;

void generateRandomNode()
{
  TNode node = new TNode(names[int(random(30))], nodes.get(int(random(nodes.size()))));

  if (random(10) < 1)
    node.addShortcut(nodes.get(int(random(nodes.size()))));

  nodes.add(node);
}

void testTree()
{
  nodes = new ArrayList<TNode>();

  TNode zero = new TNode("ROOT", width/2, height/2, 100);
  nodes.add(zero);

  for (int i=0; i<20; i++)
    generateRandomNode();
}



class TNode
{
  String name;
  float x=0, y=0;
  float a=0, d=0;
  float maxd = 0;
  TNode root;
  TNode parent;
  boolean render = true;
  float render_d = 0;
  ArrayList<TNode> children = new ArrayList<TNode>();
  ArrayList<TNode> shortcuts = new ArrayList<TNode>();


  TNode(String _name, int _x, int _y, int _d)
  {
    root = this;
    parent = null;
    name = _name; 
    x = _x;
    y = _y;
    d = _d;
  }

  TNode(String _name, TNode _parent)
  {
    name = _name;
    parent = _parent;
    root = parent.getRoot();
    if (parent != null)
    {
      int xp = round(parent.getX());
      int yp = round(parent.getY());

      println(parent.getName()+" gets "+name);
      parent.addChild(this);

      a = radians(random(180)-90) + parent.getA();
      d = parent.getD()-10;

      if (parent.getParent() == null)
        a = radians(random(360));

      x = xp+d*cos(a);
      y = yp+d*sin(a);
    }
  }

  TNode getRoot()
  {
    return root;
  }

  void setRender(boolean r)
  {
    render = r;
  }

  void toggleRender()
  {
    if (render)
      collapse();
    else
      expand();
  }

  void collapse()
  {
    render = false;

    for (TNode child : children)
      child.collapse();
  }

  void expand()
  {
    render = true;

    for (TNode child : children)
      child.setRender(true);

    if (parent != null)
      parent.expandP();
  }

  void expandP()
  {
    render = true;
    if (parent != null)
      parent.expandP();
  }

  boolean render()
  {
    return render;
  }

  void renderAll_Lines()
  {
    fill(150);
    strokeWeight(1);

    if (render)
      stroke(0);
    else
      stroke(0, 50);

    if (parent != null)
      line(x-camX, y-camY, parent.getX()-camX, parent.getY()-camY);

    noFill();
    for (TNode node : shortcuts)
      arc2(x-camX, y-camY, node.getX()-camX, node.getY()-camY, 0.3);

    for (TNode child : children)
      child.renderAll_Lines();
  }

  void line2(int x, int y, int x2, int y2)
  {
    float mx = x - x2;
    float my = y - x2;

    float a = atan2(my, mx)+PI;
    float d = dist(mx, my, 0, 0);

    float segs = 10;
    for (int i=1; i<=segs; i++)
    { 
      float r = i;
      r = segs/r/10 ;

      line(x, y, x+round(r*d*cos(a)), y+round(r*d*sin(a)));
    }
  }

  void renderAll_Nodes()
  {
    if (render)
    {
      fill(150);
      strokeWeight(1);
    }
    else
    {
      fill(150, 150);
      strokeWeight(0);
    }
    stroke(0);
    ellipse(x-camX, y-camY, 4, 4);



    for (TNode child : children)
      child.renderAll_Nodes();
  }

  void renderAll_Names()
  {
    if (render)
    {
      fill(250, 200);
      noStroke();
      rect(x-camX, y-10-camY, textWidth(toString()), 10);
      fill(0);
      text(toString(), x-camX, y-camY);
    }

    for (TNode child : children)
      child.renderAll_Names();
  }

  void renderAll_Group()
  {
    textFont(LOG_FONT, 100);
    String n = "GROUP NAME";

    float s = textWidth(n);

    s = maxd/s;

    textFont(LOG_FONT, round(s*200));
    fill(200);
    noStroke();
    ellipse(x-camX, y-camY, maxd*2+8, maxd*2+8);
    fill(255);
    text("GROUP NAME", x-textWidth(n)/2-camX, y+round(s*100)-camY);
  }

  void updateAll()
  {
    if (parent == null)
      maxd = 0;

    update();

    for (TNode child : children)
    {
      child.updateAll();
      int d = child.getMaxD();

      if (d > maxd)
        maxd = d;
    }
  }

  void update()
  {
    if (parent != null)
    {
      float c = parent.getChildren().size();
      float i = parent.getChildIndex(this);

      if (i < 0)
        println("CHILD INDEX ERROR");

      float r = (i+1)/c;

      if (parent.getParent() == null)
        a = TWO_PI*r;
      else
        a = PI*((i+1)/(c+1)) - PI/2 + parent.getA();

      int xp = round(parent.getX());
      int yp = round(parent.getY());

      if (render)
        render_d += 0.2;
      else
        render_d -= 0.2;

      if (render_d > 1)
        render_d = 1;
      if (render_d < 0.3)
        render_d = 0.3;

      x = xp+d*cos(a)*render_d;
      y = yp+d*sin(a)*render_d;

      if (root != null)
        maxd = dist(root.getX(), root.getY(), x, y);
    }
  }

  void updatePolar()
  {
    //d = dist(x, y, xp, yp);   
    //a = atan2(x-xp, y-yp);
  }

  String toString()
  {
    return name+"  <"+round(degrees(a));
  }

  float getA()
  {
    return a;
  }

  float getD()
  {
    return d;
  }

  int getMaxD()
  {
    return round(maxd);
  }

  int getX()
  {
    return round(x);
  }

  int getY()
  {
    return round(y);
  }

  void setXY(int _x, int _y)
  {
    x =_x;
    y =_y;
  }

  String getName()
  {
    return name;
  }  

  TNode getParent()
  {
    return parent;
  }

  ArrayList<TNode> getChildren()
  {
    return children;
  }

  int getChildIndex(TNode child)
  {
    int i = 0;
    for (TNode n : children)
    {

      if (n.equals(child))
        return i;
      i++;
    }

    return -1;
  }

  void addShortcut(TNode node)
  {
    shortcuts.add(node);
  }

  void addChild(TNode node)
  {
    children.add(node);
  }

  boolean belongsTo(TNode n)
  {
    if (n.equals(this))
      return false; 

    if (parent == null)
      return false;

    if (parent.equals(n))
      return true;

    return parent.belongsTo(n);
  }

  void optimizeTree()
  {

    int c = children.size();
    float minD = -1;
    float minA = a;
    for (TNode n : children)
    {
      int _x = n.getX();
      int _y = n.getY();
      float d = dist(x, y, _x, _y);

      if (minD == -1 || d < minD)
      { 
        minD = d;
        minA = n.getA();
      }
    }

    while (a > TWO_PI)
      a = a - TWO_PI;

    while (a < 0)
      a = a + TWO_PI;

    while (minA > TWO_PI)
      minA = minA - TWO_PI;

    while (minA < 0)
      minA = minA + TWO_PI;


    float dA = minA-a;

    if (dA > PI)
      dA = dA- TWO_PI;
    if (dA < -PI)
      dA = dA+ TWO_PI;

    float r = 180;

    if (degrees(dA) == 0)
      r = 0;
    else
      r = 1/degrees(dA);

    r = r*0.1;


    a -= r;


    if (a > TWO_PI)
      a = a - TWO_PI;

    if (a < 0)
      a = a + TWO_PI;


    for (TNode n : children)
    {
      n.optimizeTree();
    }
  }
}

