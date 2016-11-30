void renderOrbitals()
{
  if (java_i < filenames.length)
  {
    parseJavaFile(java_i);
  }
  else if (java_i < filenames.length*2)
  {
    parseNodeRefs(java_i-filenames.length);
  }
  else if (java_i == filenames.length*2)
  {
    printLogH("Parsing Java Files DONE");
    println(rootN.getDepth());
  }

  renderNodeTree();
}




void renderNodeTree()
{
  renderNodes(rootN, width/2+camX*camZ, height/2+camY*camZ, 300*camZ, null);
}

void renderNodes(Node root, float X, float Y, float R, String[] stacked)
{
  int len = root.getChildrens().length;
  int i=0;
  float d = TWO_PI/(len);
  textAlign(CENTER);
  if (R/50 > 1)
    strokeWeight(R/50);
  else
    strokeWeight(1);

  root.setXY(X, Y);

  if (R < 5)
  {
    ellipse(X, Y, R*2, R*2);
    fill(COL_FOREGROUND);
    text(root.getNameStr(), X, Y, R, R);
    return;
  }

  if ( X+R < BORDER || X-R > width - BORDER)
  {
    if (Y+R < BORDER || Y-R > height - BORDER)
    {
      return;
    }
  }
  if (len == 1)
  {
    String[] stack = new String[0];
    if (stacked == null)
      stack = append(stack, root.getNameStr());
    else
      stack = append(stacked, root.getNameStr());
    renderNodes(root.getChildrens()[0], X, Y, R, stack);
    return;
  }




  //String[][] saa = new String[(packageptr.keySet().size())][];

  ellipse(X, Y, R*2, R*2);
  fill(COL_FOREGROUND);
  textFont(NODE_FONT, R*0.2);
  String str ="";
  if (stacked != null)
    for (int j=0; j<stacked.length; j++)
      str+=stacked[j]+".";
  rectMode(CENTER);
  text(str+""+root.getNameStr(), X, Y, R, R);
  rectMode(CORNER);

  for (Node n : root.getConnections())
  {
    float x = n.getX();
    float y = n.getY();

    if (x != 0 || y != 0)
    {
      stroke(COL_NODE);
      strokeWeight(2*camZ);
      line(X, Y, x, y);
    }
  }

  for (Node n : root.getChildrens())
  {
    String s = n.getNameStr();
    float x, y;

    x = R*cos(d*i)+X;
    y = R*sin(d*i)+Y;

    fill(COL_BACKGROUND);
    stroke(COL_NODE);
    strokeWeight(2*camZ);



    renderNodes(n, x, y, R/5, null);

    i++;
  }
}

