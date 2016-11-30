/**
 * Java Visualizer
 * 
 * Scans through java project files and finds all the dependencies and references of the classes and methods
 * Lucas Hedinger
 */


//======================================================================VARIABLES, FINAL

final String[] roots;

final String[] root_package;

Node rootN;
Node[] node_ptrs = new Node[0];
HashMap nodemap = new HashMap();

final int LOG_SCROLL = 30;
final int LOG_SIZE = 14;
final String LOG_FILENAME = "log.txt";
final String LOG_HEADER =">>>";
final String LOG_WARN = "[!] WARNING:";

final int SIZE_W = 800;
final int SIZE_H = 600;
final int BORDER = 0;

final int CAM_SPEED = 5;
final float CAM_ZOOM = 0.01;

final color COL_FOREGROUND = color(0);
final color COL_BACKGROUND = color(255);
final color COL_LOGTEXT = color(60);
final color COL_LOGWARN = color(255, 0, 0);
final color COL_NODE = color(0);



//======================================================================VARIABLES, GLOBAL

String[] logtxt = {
  LOG_HEADER+"Start of LOG (Press L to save)", ""
};
int logtxt_scroll = 0;

//variables for scanning the directory
String[] filenames = new String[0];
String[] file_ROOTS = new String[0];
String[][] imports = new String[0][];


//variables for scanning the java files
HashMap packageptr = new HashMap();

Class_Ent[] classes;

PFont LOG_FONT;
PFont NODE_FONT;

float camZ = 1;
float camX=0, camY=0;

//File browser;
PGraphics pg;

//======================================================================SETUP
import java.awt.event.*;
void setup() {
  size(SIZE_W, SIZE_H);
  smooth();
  frameRate(20);
  LOG_FONT = createFont("", 11);
  NODE_FONT = createFont("", 11);

  pg = createGraphics(5000, 5000, JAVA2D);

  scanForJavaFiles();
  printLogH("Scanning Files DONE");

  rootN = new Node("ROOT");
  rootN.addNode(null);

  classes = new Class_Ent[filenames.length];


  println("==== end of setup ====");

  something();
}

void something()
{
  testCascade();
  testTree();
  testGraph();
  
  println("==== end of init ====");
}

int java_i=0;

void draw() {
  fill(COL_BACKGROUND);
  stroke(0);
  rect(0, 0, width, height);


  //renderOrbitals();
  //renderCascade();
  renderTree();
  //renderGraph();
  
  if (showLog)
  {
    fill(255, 200);
    rect(0, 0, width, height);
    renderLogDisp();
  }

  stroke(1);
  textFont(LOG_FONT, 12);
  text(frameRate, width-50, 20);
  //(packageptr.toString());
  java_i++;
}

//======================================================================DISPOSE

void dispose() {
  saveStrings("log.txt", logtxt);
}

//======================================================================LISTENERS

boolean showLog = false;

float mx1, my1, mx2, my2;

void mouseDragged() 
{
  graph_select_pre = -1;

  if (mouseButton == LEFT)
  {
    camX = (mx1-mouseX)/camZ;
    camY = (my1-mouseY)/camZ;
  }
  if (mouseButton == RIGHT)
  {
    camZ = (my2-mouseY)*0.01;
  }

  if (camZ < 1)
    camZ = 1;
}

void mouseReleased() {
  tree_select = tree_select_pre;
  graph_select = graph_select_pre;

}

void mousePressed() {

  if (mouseButton == LEFT)
  {
    mx1 = mouseX+camX*camZ;
    my1 = mouseY+camY*camZ;
  }
  if (mouseButton == RIGHT)
  {
    my2 = mouseY;
  }
}

void mouseWheel(int delta) {
  float f = camZ;

  camZ -= delta*0.1*camZ;

  if (camZ < 1)
    camZ = 1;
}


void keyPressed() {
  if (keyCode == 'Q')
    logtxt_scroll +=LOG_SCROLL;
  if (keyCode == 'A')
    logtxt_scroll -=LOG_SCROLL;

  if (keyCode == LEFT)
    camX+=CAM_SPEED;
  if (keyCode == RIGHT)
    camX-=CAM_SPEED;
  if (keyCode == UP)
    camY+=CAM_SPEED;
  if (keyCode == DOWN)
    camY-=CAM_SPEED;

  if (keyCode == 'Z')
    camZ+=CAM_ZOOM; 

  if (keyCode == 'X')
    camZ-=CAM_ZOOM;

  if (keyCode == 'T')
  {
    loadPixels();
    println(pixels.length);
  }

  if (keyCode == 'R')
    something();

  if (keyCode == 'L')
  {  
    if (showLog) 
      saveStrings(LOG_FILENAME, logtxt);
    showLog = !showLog;
  }

  if (logtxt_scroll < 0)
    logtxt_scroll = 0;
  if (camZ < 1)
    camZ = 1;
}

//======================================================================UTILITIES



void arc2(float x1, float y1, float x2, float y2, float r)
{
  if (abs(r) >= 1)
  {
    line(x1, y1, x2, y2);
    return;
  }

  float ratio = abs(r);
  
  ratio = 1/ratio;

  float d = 0.5*dist(x1, y1, x2, y2);
  float a = atan2(y2-y1, x2-x1);

  float rad = d*ratio;

  float c = acos(d/rad);

  float cc = (PI/2 - c);
 
  //line(x1, y1, x2, y2);

  if (r < 0)
    arc(x1+rad*cos(a+c), y1+rad*sin(a+c), rad*2, rad*2, a-PI/2-cc, a-PI/2+cc);
  else
    arc(x2+rad*cos(a+c+PI), y2+rad*sin(a+c+PI), rad*2, rad*2, a+PI/2-cc, a+PI/2+cc);
}


//======================================================================RENDERERS

void renderLogDisp()
{
  textAlign(LEFT);
  textFont(LOG_FONT);
  int y = 0;
  int h = logtxt.length*LOG_SIZE;

  if (h > height)
    y = height - h + logtxt_scroll;

  for (int i=0; i<logtxt.length; i++)
  {
    fill(COL_LOGTEXT);
    if (logtxt[i].trim().startsWith(LOG_WARN))
      fill(COL_LOGWARN);

    y+=LOG_SIZE;    
    text(logtxt[i], 10, y);
  }
}




//======================================================================PARSERS

void parseJavaFile(int j)
{
  if (j<0 || j>=filenames.length)
    return;

  BufferedReader reader = createReader(file_ROOTS[j]+""+filenames[j]);   

  printLog("");
  printLog("Reading "+filenames[j]+"...");

  boolean body = false;
  String liner;
  String pack = null;
  String name = null;
  imports = (String[][])append(imports, new String[0]);

  do {

    try {
      liner = reader.readLine();
      if (liner != null)
        liner = liner.trim();
    }
    catch (Exception e) {
      printLogH("Exception when reading "+filenames[j]+"!");
      println(e);
      liner = null;
    }

    if (liner == null)
      continue;

    String para = null;
    if (!body)
    {
      if ((para = getPackage(liner)) != null)
      { 
        if (pack != null)
          printLogWarn("already has package");
        else
          pack = para; 
        printLog("    package= "+para);
      }
      else if ((para = getImport(liner)) != null)
      {
        String[] imps = imports[j];
        imps = append(imps, para);
        imports[j] = imps;	  
        printLog("    import= "+para);
      }
      else if ((para = getClass(liner)) != null)
      {
        if (name != null)
          printLogWarn("already has name");
        else
          name = para.split(" ")[0];
        printLog("    class= "+name);
      }
      else if ((para = getInterface(liner)) != null)
      {
        if (name != null)
          printLogWarn("already has name");
        else
          name = para.split(" ")[0];
        printLog("    interface= "+name);
      }

      if (liner.contains("{"))
      {
        if (name == null || pack == null)
        {
          return;
        }
        body = true;
      }
    }
    else
    {
      if ((para = getMethod(liner)) != null)
      {
        printLog("    method= "+para);
      }
    }
  }
  while (liner != null);

  classes[j] = new Class_Ent(pack, name, file_ROOTS[j]+""+filenames[j]);
  String[] chain = pack.split("\\.");
  chain = append(chain, name);

  if (registerNode(chain))
    nodeCount++;
}

void parseNodeRefs(int j)
{
  if (j<0 || j>=node_ptrs.length)
    return;

  String[] imps = imports[j];

  Node node = node_ptrs[j];

  println("--NODE "+node.getNameStr());
  for (String imp : imps)
  {
    println("      "+imp);
  }
}

//======================================================================PARSER-HELPERS

boolean registerNode(String[] sa)
{
  for (int i=0; i<root_package.length; i++)
  {
    if (!sa[i].equals(root_package[i]))
    {
      println("WARNING: "+sa[i] +" does not match "+root_package[i]);
      return false;
    }
  }
  Node ptr = rootN.addNode(sa);

  if (ptr == null)
    return false;

  nodemap.put(join(sa, "."), node_ptrs.length);
  node_ptrs = (Node[])append(node_ptrs, ptr);
  return true;
}

String getPackage(String s)
{
  if (s.startsWith("package "))
    return s.substring(8, s.length()-1).trim();
  return null;
}

String getClass(String s)
{
  int i = 0;
  if (s.endsWith("{"))
    i = 1;

  if (s.startsWith("public abstract class "))
    return s.substring(22, s.length()-i).trim();
  if (s.startsWith("public class "))
    return s.substring(13, s.length()-i).trim();

  return null;
}

String getInterface(String s)
{
  int i = 0;
  if (s.endsWith("{"))
    i = 1;

  if (s.startsWith("public interface "))
    return s.substring(17, s.length()-i).trim();
  if (s.startsWith("public abstract interface "))
    return s.substring(26, s.length()-i).trim();

  return null;
}

String getMethod(String s)
{
  if (s.startsWith("public") || s.startsWith("protected"))
  {
    String[] words = s.split(" ");
    int i;
    if (words.length < 3)
      return null;
    if ((i = words[2].indexOf("(")) < 0)
      return null;

    return words[2].substring(0, i);
  }
  return null;
}

String getImport(String s)
{
  if (s.startsWith("import") && s.endsWith(";"))
  {
    return s.substring(7, s.length()-1).trim();
  }
  return null;
}


//======================================================================SCANNERS

void scanForJavaFiles()
{
  printLogH("Scan results for the following directories ("+ROOTS.length+")");

  int len=0;
  for (int i=0; i<ROOTS.length; i++)
  {
    if (ROOTS[i].endsWith("/"))
      ROOTS[i] = ROOTS[i].substring(0, ROOTS[i].length()-1);

    printLog(ROOTS[i]);
    findJavaFiles(ROOTS[i], "");
    printLog( "("+(filenames.length-len)+")");
    printLog(subset(filenames, len, filenames.length));
    len = filenames.length;
  }
  //lines = loadStrings(root);
  printLogH("Found the following files ("+filenames.length+")");

  printLog( filenames);
}

void findJavaFiles(String root, String path) {
  File file = new File(root+"/"+path);

  if (file.isFile())
    return;

  String[] javas = file.list(javaFilter);
  String[] dirs = file.list(folderFilter);


  if (javas != null)
  {
    String[] ROOTS = new String[javas.length];
    for (int i=0; i<javas.length; i++)
    {   
      javas[i] = path+"/"+javas[i];
      ROOTS[i] = root;
    }
    filenames = concat(filenames, javas);
    file_ROOTS = concat(file_ROOTS, ROOTS);
  }

  if (dirs != null)
    for (int i=0; i<dirs.length; i++)
      findJavaFiles(root, path+"/"+dirs[i]);
}

//======================================================================LOGGERS

void printLog(String s)
{
  if (s.startsWith(">>>"))
    if (!logtxt[logtxt.length-1].startsWith(">>>"))
      logtxt = append(logtxt, "");

  logtxt = append(logtxt, s);
  if (s.startsWith(">>>"))
    logtxt = append(logtxt, "");
}

void printLogH(String s)
{
  printLog(LOG_HEADER+" "+s);
}

void printLogWarn(String s)
{
  printLog(LOG_WARN+" "+s);
}

void printLog(String[] sa)
{
  logtxt = concat(logtxt, sa);
  logtxt = append(logtxt, "");
}

//======================================================================FILTERS

java.io.FilenameFilter javaFilter = new java.io.FilenameFilter() {
  boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(".java");
  }
};

java.io.FilenameFilter folderFilter = new java.io.FilenameFilter() {
  boolean accept(File dir, String name) {
    return (!name.toLowerCase().contains("."));
  }
};

//======================================================================CLASSES, INNER

int nodeCount = 0;
public class Node {

  String name;
  Node parent;
  Node[] children = new Node[0];
  Node[] connections = new Node[0];
  float xcoord, ycoord;
  int r;

  public Node(String n) {
    name = n;
  }

  public Node addNode(String[] sa)
  {
    if (sa == null)
      return null;
    if (sa.length == 0)
      return null;
    if (sa.length == 1)
    {
      Node n = new Node(sa[0]);
      children = (Node[])append(children, n);
      return n;
    }

    if (sa[0].equals(name))
      return addNode(subset(sa, 1));

    Node next = null;

    for (Node n : children)
    {
      if (n.getNameStr().equals(sa[0]))
      {
        return n.addNode(subset(sa, 1));
      }
    }

    next = new Node(sa[0]);
    children = (Node[])append(children, next);

    return next.addNode(subset(sa, 1));
  }

  public int children()
  {
    return children.length;
  }

  public Node[] getChildrens()
  {
    return children;
  }

  public int connections()
  {
    return connections.length;
  }

  public Node[] getConnections()
  {
    return connections;
  }

  public int size()
  {
    int sum = 1;
    for (Node n : children)
    {
      sum += n.size();
    }
    return (sum);
  }

  public int getDepth()
  {
    int max = 0;
    for (Node n : children)
    {
      int d = n.getDepth();

      if (d > max)
        max = d;
    }
    return (max+1);
  }

  public String getNameStr()
  {
    return name;
  }

  public void addConnection(Node n)
  {
    connections = (Node[])append(connections, n);
  }

  public String toString()
  {
    String out = name+"{";

    for (Node n : children)
      out += n.toString()+",";

    if (children.length > 0)
      out = out.substring(0, out.length()-1);

    return out+"}";
  }

  public void setXY(float x, float y)
  {
    xcoord = x;
    ycoord = y;
  }
  public float getX()
  {
    return xcoord;
  }
  public float getY()
  {
    return ycoord;
  }
}

class Class_Ent {

  String pack;
  String name;
  String path;

  String[] extd = new String[0]; //extends
  String impl = null; //implements

  String[] methods = new String[0]; //methods

  public Class_Ent(String k, String n, String p) {
    pack = k;
    name = n;
    path = p;
  }

  public String toString() {
    return pack+"."+name;
  }
}

