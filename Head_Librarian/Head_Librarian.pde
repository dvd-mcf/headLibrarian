import org.openkinect.processing.*;

Kinect2 kinect2;

int frameLength = 0;
int chop = 200;

float magnitudeL = 0.1;
float velocityL = 0.6;
float accelerationL = 0.1;
float motionMultiplier = 0.0005;
int blueRandom = 4;

int lineHeight = 30;

// Create an image for both the webcam and the previous webcam frame

PImage originalFrame;

PImage cameraFrame;

PImage lastFrame;
// How far from the right margin is the dedication?
int dedicationOffset = 20;

float totalSaturation;
float totalMotion;
float xoff = 0.1;

int endWidth = 1080;
int endHeight = 1000;
int minimumMotion = 1;
float tChange = 1;


  float heightRatio; 
  float widthRatio;


//Declare fonts
PFont poemFont;
PFont titleFont;
PFont dedicationFont;
PFont chineseFont;

  int skip = 5;

//The poem
String Librarian = "/n /n /n /n The librarian was snorkelling in 800, pondering Africa /n when the husky-wolfhound-girl bust in the doors, /n armour freshly beaten, incisors capped with silver, /n harbouring a question within her left hind tibia. /n  /n if you were lunging for the future, it’s OK if you trip, /n  /n The librarian licks the air and tastes foaming cordite /n brimming. He saunters behind the octobass, keeps an eye. /n Untempered disdain makes her burp up a dragonfly. /n  /n I sing louder than my own pain. /n  /n They move like opposing magnets. She lightly mauls /n a book, but that query in her tibia’s still there, /n  /n 你的饱腹感 /n your sense of satiety /n 有时是因为对逃逸的满足 /n sometimes derived from the thrill of escape /n 有时是因为灯光的填充 /n sometimes from the mallow of lamp-light /n  /n so he shakes out his wings, performs a lazy tour en l’air, /n then karate-chops a watermelon, and can tell from her paws /n she’s a little bit impressed; she surrenders /n the gnawed pieces of a post-it: title and author. /n  /n The book has already lived through its troubles. /n  /n The request canters towards them and flops on the counter. /n  /n 拉起两条人命 /n two drenched human lives /n  /n They stand looking at it. Aversion blooms. Very slowly /n he slides the book behind the velvet drapery, /n very gently, eases onto the counter a new story, /n shaped like a plum tree covered in snow. /n  /n i usta mi światłem nasyca /n Light will fill my mouth soon. /n  /n She stoops to sniff; volcanic peaks rise in the shadows, /n she looks to the high pass over the mountain. /n  /n an envelope to slip me in gently /n Syncope, a moment of disruption – let us fall into this temporary dispossession /n return to see the real world look strange. /n  /n Japanese Literature, 895.6, just there, left of the window /n says the librarian, and bends to clear up the watermelon. /n  /n Lecz jest serce w tym wielkim pałacu, /n co potrafi dotrzymać ci placu. /n Daj mi rączkę w mitence z pajęczyn... /n  /n Yet in this great palace there is one heart /n that beats time with yours, comprehends your art. /n Give me your small hand in its cobweb glove... /n /n /n /n /n /n /n";
// String Bear = "We're going on a bear hunt/n We're going to catch a big one/n What a beautiful day! We're not scared/n  Uh-oh! Grass/n Long wavy grass/n  We can't go over it/n We can't go under it/n Oh no! We've got to go through it!/n  Swishy swashy! Swishy swashy! Swishy swashy!/n  We're going on a bear hunt/n We're going to catch a big one/n What a beautiful day! We're not scared/n  Uh-oh! A river! A deep, cold river/n  We can't go over it/n We can't go under it/n Oh no! We've got to go through it!/n  Splash splosh! Splash splosh! Splash splosh! /n We're going on a bear hunt/n We're going to catch a big one/n What a beautiful day! We're not scared/n  Uh-oh! Mud!";

//How many empty lines at the start?
int breaks = 4;

//Split the poem
String[] lines = split(Librarian, "/n");


ArrayList<Integer> oldSaturations;
ArrayList<poemLine> poemLines;

int historySize = 5;
int totalRows;



Boolean frameRateToggle = false;

Boolean imageToggle = false;
Boolean imageToggle2 = false;

void setup() {
  fullScreen(  2);
//  size (1080, 1920);
  kinect2 = new Kinect2(this);
  kinect2.initVideo();
  kinect2.initDevice();
  cameraFrame = new PImage(endWidth, endHeight);
  lastFrame = new PImage(endWidth, endHeight);

  titleFont = loadFont("CalendasPlus-Bold-40.vlw");
  dedicationFont = loadFont("Bould-ExtraLightItalic-40.vlw");
  poemFont = loadFont("Argesta.vlw");
  chineseFont = createFont("Simsum", 30);


  oldSaturations = new ArrayList<Integer>();
  poemLines = new ArrayList<poemLine>();
  
totalRows = lines.length;
  for (int i = 0; i < totalRows; i++) {
    poemLines.add(new poemLine(i));
  }
  
  originalFrame = kinect2.getVideoImage();
  
  
  

  
} 

void draw() {
  

  heightRatio = height/float(endHeight);
   widthRatio = width/float(endWidth);
      
  background(255);


  //Initialise Camera
  originalFrame.loadPixels();
  cameraFrame.loadPixels();
  lastFrame.loadPixels();
  
   lastFrame.copy(originalFrame, chop, 0, originalFrame.width, originalFrame.height, 0, 0, endWidth, endHeight);


   originalFrame = kinect2.getVideoImage();
   pushMatrix();
   translate(width,0);
   rotate(radians(90));
  if (imageToggle == true) { 

image(cameraFrame,0,0);
  }
  
    if (imageToggle2 == true) { 

image(originalFrame,0,0);
  }
  
popMatrix();
 cameraFrame.copy(originalFrame, chop, 0, originalFrame.width, originalFrame.height, 0, 0, endWidth, endHeight);

    
    frameLength = cameraFrame.pixels.length;


  for (int row = 0; row < totalRows; row += 1) {
    
    int start = (cameraFrame.width  / totalRows) * row;
    int end = (cameraFrame.width / totalRows) * (row + 1);

    //The running count of average brightness for the row
    float totalRowXPosition = 0;
    float avgRowXPosition = width/2;

    //The count of pixels tracked in the row
    int count = 0;

    //The average motion ???
    float avgRowMotion = 0;
    //The total motion ???
    float totalRowMotion = 0;
    //Iterate through pixels in this row
    if (lastFrame.pixels.length > 0) {
    for (int y = 0; y < cameraFrame.height; y += skip) {
      for (int x = start; x < end; x += skip) {

        //Index of the pixels
        int index = x + y * cameraFrame.width;

        //Brightness of pixels
        int b = int(brightness (cameraFrame.pixels[index]));
        //Brightness from previous frame
        int oldB = int(brightness (lastFrame.pixels[index]));

        //Difference between frames
        float d = b - oldB;
        //If the difference between the old and new frames is greater than X, draw it, add to average X
        if (d > minimumMotion) {
          stroke (0, 0, 140, d / 30) ;
          strokeWeight(map(d, minimumMotion, 100, 0, 25)) ;
         point (width-((y * widthRatio) + random(blueRandom) - blueRandom/2), (x * heightRatio) + random(blueRandom) - blueRandom/2);
          totalRowXPosition += y ;
          totalRowMotion += d ;
          count++ ;
          
          
        }
        updatePixels();
      }
    }
  }

    // Calculate average motion for the row
    avgRowMotion = (abs(totalRowMotion)  * motionMultiplier );

    if (count > 0) {
      avgRowXPosition = (width - totalRowXPosition  / count);
    }
 
    poemLine p = poemLines.get(row);
    p.Change(avgRowXPosition, avgRowMotion);


  }
  
  int margin = 40;
   translate(0, margin);
  // Set the left and top margin
  


  
  textAlign(LEFT);  


  for (poemLine w : poemLines) {
    w.update();
    w.display();
  }
  textAlign(CENTER);

  fill(0);
  textFont(titleFont);
  textSize(40 / tChange);
  String title = "The Librarian Conducts A Reference Interview";
  text(title, width/2, 30);
  fill (255, 0, 0 );
  if (frameRateToggle == true) { 
  text(frameRate, width/2, 80);
  }
  strokeWeight(2);
  stroke (70);

  //line(width/2 - textWidth(title)/2, 40, width/2 + textWidth(title)/2, 40);
  


  fill(100);
    strokeWeight(1);

    line(0, height - 210, width, height-210);

  
  textFont(dedicationFont);
  textSize(23 / tChange);
  textAlign(LEFT);
  text ("Commissioned for the @MCRCityofLit #FestivalofLibraries and Manchester Poetry Library", dedicationOffset, height - (lineHeight * 8));
  text ("Technology by David McFarlane (@dvd_mcf)", dedicationOffset, height -(lineHeight * 7));
  text ("Poetry by Charlotte Wetton (@CharPoetry)", dedicationOffset, height - (lineHeight * 6));
  text ("with Naomi Shihab Nye, Jennifer Lee Tsai, Roma Havers, Andrew Oldham, Yu Yoyo", dedicationOffset, height - (lineHeight * 5));
  text ("& translated by Dave Haysom, Maria Pawlikowska-Jasnorzewska, Barbara Bogoczek and Tony Howard", dedicationOffset, height - (lineHeight * 4));
  text ("With thanks to Future Everything and The Writing Squad", dedicationOffset, height - (lineHeight * 2));

//Green spot in front 

//  textFont(poemFont);
  
}







class poemLine {

  PVector avgX ;
  int line;
  float magnitude;
  PVector CVelocity;
  PVector oldCVelocity;

  PVector CLocation;
  PVector oldCLocation; 

  PVector CAccel;


  PVector XDisp;

  PVector velocity;
  PVector acceleration;
  PVector runningAcceleration;

  PVector oldAcceleration;


  PVector location;
  PVector target;
  String[] words ;

  poemLine(Integer index) {

    CLocation = new PVector (0, 0);
    oldCLocation = new PVector (0, 0);
    CVelocity = new PVector (0, 0);
    oldCVelocity = new PVector (0, 0);

    velocity = new PVector (0, 0);
    acceleration = new PVector (0, 0);
    oldAcceleration = new PVector (0, 0);
    runningAcceleration = new PVector (0, 0);


    location = new PVector( width / 2, (height/lines.length) * index);
    words = split(lines[index], " ");
    line = index;
    target = new PVector (width/2, (height/lines.length) * index);
    avgX = location;
    magnitude = 1;
  }


  void Change(float newXDisp, float newMagnitude) {

      // float magnitudeL = float(mouseX)/float(width);

    
    if (newMagnitude < 0.2) {
      newMagnitude = 0;
    }

    magnitude = lerp (newMagnitude, magnitude, magnitudeL);


    CVelocity.lerp(oldCVelocity, velocityL);

    CLocation = new PVector (newXDisp, 0);
    //Calculate the speed of the centroid by comparing it with the previous frame
    CVelocity = oldCLocation.sub(CLocation);
    //Don't let it get bigger than 100

    CVelocity.mult(magnitude);
    CVelocity.limit(600);
    //Calculate the acceleration of the centroid by comparing it with the previous frame
    //if (acceleration.x < 5) {
     // acceleration.x = 0;
    // }
    acceleration =  oldCVelocity.sub(CVelocity);


    runningAcceleration = runningAcceleration.lerp(acceleration, accelerationL);


    oldCVelocity = CVelocity;
    oldCLocation = CLocation;
    oldAcceleration = acceleration;
  }



  void update() {
    velocity.add(runningAcceleration);
    location.add(velocity);
    if (location.x < 30) {
      location.x = width + 30;
    }
  }

  void display() {

    int wordsLength = words.length;

    float lineWidth =  0;
    float wordWidth = 0;
    int textSize = 20;
    textSize(textSize / tChange);

    if (wordsLength > 0) {
      noStroke();
      fill(0, 255, 0);
      fill(0, 0, 255);

      for (int x = 0; x < words.length; x += 1) {
        String word = words[x];
        wordWidth = textWidth(word);
      }

        textFont(poemFont);

      for (int x = 0; x < words.length; x += 1) {

        String word = words[x];
        fill(0, 0, 0);
        textSize(25 / tChange);
        if ((line == 5 + breaks) || (line == 11 + breaks) || (line ==16 + breaks ) || (line == 17 + breaks ) || (line ==18 + breaks ) || (line ==19  + breaks) || (line == 20 + breaks ) || (line == 21 + breaks ) || (line == 28 + breaks )|| (line ==32 + breaks ) ||(line ==33 + breaks )||(line ==40 + breaks )||(line ==41 + breaks )||(line ==46  + breaks) ||(line ==47  + breaks ) ||(line ==48  + breaks ) ||(line ==49  + breaks ) ||(line >=(53  + breaks) )) {
          fill(100);
 if ((line == 16 + breaks ) || (line ==18 + breaks ) || (line== 20  + breaks) || (line ==24 + breaks ) || (line ==32 + breaks )) {
textFont(chineseFont);
 }
          textSize(textSize / tChange );
        }

        wordWidth = textWidth(word);
        text(word, (location.x + lineWidth + noise(x + xoff)) % (width - 80), location.y, 0);
        lineWidth += (wordWidth + 15);
      }
    }
  }
}

String[] linebreak(String poem1) {
  String[] poemArray;
  poemArray = split(poem1, "/n");
  return poemArray;
};



void keyPressed() {
 if (key == 'r') {
    frameRateToggle =! frameRateToggle;
  }
  
   if (key == 'i') {
    imageToggle =! imageToggle;
  }
   if (key == 'j') {
    imageToggle2 =! imageToggle2;
  }  
}
