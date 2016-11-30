int graph_select = -1;
int graph_select_pre = -1;

void renderGraph()
{
  stroke(0);
  strokeWeight(1);
  noFill();

  if (graph_select >= 0 && graph_select < group_nodes.size())
  {
    println(graph_select);
    group_nodes.get(graph_select).toggleRender();
    graph_select = -1;
  }

  for (GNode node : group_nodes)
    node.updateAll(); //recursive

  for (GNode node : group_nodes)
    node.renderAll_Group();

  textFont(LOG_FONT, 12);

  for (GNode node : group_nodes)
    node.renderAll_Lines(); //recursive
  for (GNode node : group_nodes)
    node.renderAll_Nodes(); //recursive
  for (GNode node : group_nodes)
    node.renderAll_Names(); //recursive


  int i=0;
  graph_select_pre = -1;
  for (GNode node : group_nodes)
  {
    if (dist(node.getX(), node.getY(), mouseX, mouseY) < 20)
      graph_select_pre = i;

    i++;
  }
}


ArrayList<GNode> group_nodes;


void generateRandomNode(GNode root)
{
  VNode node = new VNode(names[int(random(30))], root);

  if (random(2) < 1 && root.connections()>0)
    node.addConnection(root.getConnections().get(int(random(root.connections()))));

  root.addConnection(node);
}

void testGraph()
{
  group_nodes = new ArrayList<GNode>();

  GNode zero = new GNode("ZERO", width/2, height/2, 50);
  group_nodes.add(zero);

  GNode alph = new GNode("ALPHA", zero);
  group_nodes.add(alph);


  for (int i=0; i<20; i++)
    generateRandomNode(zero);

  for (int i=0; i<20; i++)
    generateRandomNode(alph);
}




class GNode
{
  String name;
  float x=0, y=0;
  float a=0, d=0;
  float maxd = 0;
  float r=0;
  boolean render = true;
  float render_d = 0;

  GNode root;
  GNode parent;
  ArrayList<VNode> connections = new ArrayList<VNode>();
  ArrayList<GNode> children = new ArrayList<GNode>();


  GNode(String _name, int _x, int _y, int _d)
  {
    root = this;
    parent = null;
    name = _name; 
    x = _x;
    y = _y;
    d = _d;
  }

  GNode(String _name, GNode _parent)
  {
    name = _name;
    parent = _parent;
    root = parent.getRoot();
    if (parent != null)
    {
      int xp = round(parent.getX());
      int yp = round(parent.getY());

      parent.addChild(this);

      a = radians(random(180)-90) + parent.getA();
      d = parent.getD();

      if (parent.getParent() == null)
        a = radians(random(360));

      x = xp+d*cos(a);
      y = yp+d*sin(a);
    }
  }

  GNode getRoot()
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

    //for (GNode child : children)
     // child.collapse();
  }

  void expand()
  {
    render = true;

    //for (GNode child : children)
      //child.setRender(true);

   // if (parent != null)
     // parent.expandP();
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
    for (VNode node : connections)
      node.render_Line();
  }

  void renderAll_Nodes()
  {
    fill(0, 150);
    noStroke();
    ellipse(x, y, 20*render_d, 20*render_d);

    for (VNode node : connections)
      node.render_Node();
  }

  void renderAll_Names()
  {
    for (VNode node : connections)
      node.render_Name();
  }

  void renderAll_Group()
  {
    textFont(LOG_FONT, 100);
    String n = name;

    float s = textWidth(n);

    s = r/s;

    textFont(LOG_FONT, round(s*200));
    fill(200);
    noStroke();
    ellipse(x, y, r*2+8, r*2+8);
    fill(255);
    text(n, x-textWidth(n)/2, y+round(s*100));
  }

  void updateAll()
  {

    if (render)
      render_d += 0.1;
    else
      render_d -= 0.1;

    if (render_d > 1)
      render_d = 1;
    if (render_d < 0.3)
      render_d = 0.3;

    int k = 3;

    int lvl2 = 1;
    int s = 0;

    int lvl=1;
    for (int i=0; i<connections.size(); i++)
    {
      VNode node = connections.get(i);

      if (pow(k, lvl2) <= i)
      {
        s = i;
        lvl2++;
      }

      if (i<4)
        lvl = 1;
      else
        lvl = int(log(i)/log(k))+1;

      int n = int(pow(k, lvl));
      int np = 0;
      if (lvl>1)
        np = int(pow(k, lvl-1));

      int npd = n-np;

      float ra = (i-np);

      if (connections.size()-i-1 < n-i)
        npd = connections.size() - np;

      ra = ra/(npd);

      node.update(ra*TWO_PI, d*lvl*render_d);
    }

    r = (lvl+0.5)*d*render_d;

    if (parent != null)
    {
      int xp = round(parent.getX());
      int yp = round(parent.getY());

      int dp = parent.getR()+getR();
      x = xp+dp*cos(a);
      y = yp+dp*sin(a);
    }
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

  int getR()
  {
    return round(r);
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

  GNode getParent()
  {
    return parent;
  }

  int connections()
  {
    return connections.size();
  }

  void addConnection(VNode node)
  {
    connections.add(node);
  }

  ArrayList<VNode> getConnections()
  {
    return connections;
  }


  void addChild(GNode node)
  {
    children.add(node);
  }

  ArrayList<GNode> getChildren()
  {
    return children;
  }

  boolean belongsTo(GNode n)
  {
    if (n.equals(this))
      return false; 

    if (parent == null)
      return false;

    if (parent.equals(n))
      return true;

    return parent.belongsTo(n);
  }
}

///////////////////////////////////////////////////////////////////////////////////

class VNode
{
  String name;
  float x=0, y=0;
  float a=0, d=0;
  float maxd = 0;
  GNode root;
  boolean render = true;
  float render_d = 0;
  ArrayList<VNode> connections = new ArrayList<VNode>();


  VNode(String _name, GNode _root)
  {
    root = _root;
    name = _name;
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
    if (!render)
      return;

    render = false;

    for (VNode node : connections)
      node.collapse();
  }

  void expand()
  {
    if (render)
      return;

    render = true;

    for (VNode node : connections)
      node.setRender(true);
  }

  boolean render()
  {
    return render;
  }

  void render_Line()
  {
    noFill();
    strokeWeight(1);

    if (render)
      stroke(0);
    else
      stroke(100);

    for (VNode node : connections)
      arc2(x, y, node.getX(), node.getY(), 0.15);
  }


  void render_Node()
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
    ellipse(x, y, 4, 4);
  }

  void render_Name()
  {
    if (render)
    {
      fill(250, 200);
      noStroke();
      rect(x, y-10, textWidth(name), 10);
      fill(0);
      text(name, x, y);
    }
  }

  int update(float a, float d)
  {
    int xp = round(root.getX());
    int yp = round(root.getY());

    x = xp+d*cos(a);
    y = yp+d*sin(a);
    
    render = root.render();
    
    return round(dist(root.getX(), root.getY(), x, y));
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

  GNode getRoot()
  {
    return root;
  }

  ArrayList<VNode> getConnections()
  {
    return connections;
  }

  void addConnection(VNode node)
  {
    connections.add(node);
  }
}

