// Processing 3.0x template for receiving raw points from
// Kyle McDonald's FaceOSC v.1.1 
// https://github.com/kylemcdonald/ofxFaceTracker
//
// Adapted by Kaleb Crawford and Golan Levin, 2016-7, after:
// 2012 Dan Wilcox danomatika.com
// for the IACD Spring 2012 class at the CMU School of Art
// adapted from from Greg Borenstein's 2011 example
// https://gist.github.com/1603230

import oscP5.*;
OscP5 oscP5;
import processing.video.*;
Capture cam;

int found;
float[] rawArray;
int highlighted; //which point is selected
float[][] beardArray;
float[][] oldBeardArray;
float[][] beardPoints;
boolean init = false;
Vehicle[] vehicles;
boolean init_vehicles = false;

int numBeardPoints = 500;

//--------------------------------------------
void setup() {
  size(640, 480);
  frameRate(30);
  
  cam = new Capture(this, 640, 480, 30);
  cam.start();

  rawArray = new float[132]; 
  beardArray = new float[22][2];
  beardPoints = new float[numBeardPoints][2];
  oldBeardArray = new float[22][2];
  vehicles = new Vehicle[numBeardPoints];

  oscP5 = new OscP5(this, 8338);
  oscP5.plug(this, "found", "/found");
  oscP5.plug(this, "rawData", "/raw");
}

//--------------------------------------------
void draw() {  
  background(255);
  noStroke();
  
  if(cam.available()) {
    cam.read();
  }
  
  image(cam,0,0);
  
  if (found != 0) {
    //drawFacePoints(); 
    //drawFacePolygons();
    oldBeardArray = copy_beard_array(beardArray);
    getBeardPoints();
    
    if(init_vehicles == false){
      initializeVehicles();
      init_vehicles = true;
    }
    
    else if(init_vehicles == true){
      drawVehicles();
      
      int[] point_difference = getPointDifference(oldBeardArray,beardArray);
      int tol = 1;
      
      if( abs(point_difference[0]) > tol || abs(point_difference[1]) > tol ||init == false){
        randomSeed(0);
        init = true;
        populateBeard();
      }    
    }
    //drawBeardPoints();
  }
  
  else{
    init_vehicles = false;
    init = false;
  }
}

//--------------------------------------------
void drawFacePoints() {
  int nData = rawArray.length;
  for (int val=0; val<nData; val+=2) {
    if (val == highlighted) { 
      fill(255, 0, 0);
      ellipse(rawArray[val], rawArray[val+1], 11, 11);
    } else {
      fill(100);
      ellipse(rawArray[val], rawArray[val+1], 8, 8);
    }
  }
}
void initializeVehicles(){
  for(int i=0; i<numBeardPoints; i++){
    Vehicle new_vehicle = new Vehicle(random(width), random(height));
    vehicles[i] = new_vehicle;
  }
  
  for(int i=0; i<numBeardPoints; i++){
    Vehicle v = vehicles[i];
    PVector random_location = new PVector(random(width), random(height));
    v.arrive(random_location);
    v.update();
    v.display();
  }
}

void drawVehicles(){ 
  for(int i=0; i<numBeardPoints; i++){
    Vehicle v = vehicles[i];
    PVector new_location = new PVector(beardPoints[i][0], beardPoints[i][1]);
    v.arrive(new_location);
    v.update();
    v.display();
  }
}

//--------------------------------------------


void getBeardPoints(){
 for (int i=6; i<28; i+=2){
   int j = i-6;
   beardArray[j/2][0] = rawArray[i];
   beardArray[j/2][1] = rawArray[i+1];
 }
 
 for(int i=0; i<12; i++){
   float[] curPoint = beardArray[i];
   float newPointX = curPoint[0];
   float newPointY = curPoint[1]+(curPoint[1]*0.5);
   int newIndex = 21 - i;
   beardArray[newIndex][0] = newPointX;
   beardArray[newIndex][1] = newPointY;    
 }
}

public boolean checkIfInside(float[] testPoint){
  //first make all the lines going rightward; 
  float[][] rightwardLine = new float[2][2];
  rightwardLine[0][0] = testPoint[0];
  rightwardLine[0][1] = testPoint[1];
  rightwardLine[1][0] = testPoint[0]+600; //arbitrarily large movement to the right
  rightwardLine[1][1] = testPoint[1];  
  int num_intersections = 0;  
  for(int i=0; i<21; i++){
    float[][] cur_line = new float[2][2];
    cur_line[0] = beardArray[i];
    cur_line[1] = beardArray[i+1];    
    float[] intersection_point = findIntersection(rightwardLine, cur_line);
    if(intersection_point[0] > 1){//checks if an intersection was found;
      num_intersections++;
    }
  }
  if(num_intersections%2 == 1){return true;}  
  else{return false;}  
}


void populateBeard(){
  //Lets get an idea of the extents of the beard first - so we can use our random function wisely;
  float x_min = beardArray[0][0];
  float x_max = beardArray[11][0];
  float y_min = beardArray[0][1];
  float y_max = beardArray[17][1];
  
  //now, while we havent populated out beard fully - make new random points and check if they are
  //in the beard - keep doing this till we have enough points;
  int total_inside_points = 0;
  while(total_inside_points < numBeardPoints){    
    float random_x= random(x_min, x_max);
    float random_y= random(y_min, y_max);
    float[] testPoint = new float[2];
    testPoint[0] = random_x;
    testPoint[1] = random_y;
    
    if(checkIfInside(testPoint) == true){
      beardPoints[total_inside_points][0] = random_x;
      beardPoints[total_inside_points][1] = random_y;
      total_inside_points++;
    }  
  }
}

void drawBeardPoints(){
  fill(100); 
  stroke(100); 
  for(int i=0; i<numBeardPoints; i++){
    ellipse(beardPoints[i][0],beardPoints[i][1],4,4);
  }
  for(int j=0; j<22; j++){
    ellipse(beardArray[j][0],beardArray[j][1],4,4);
  }
}

void drawFacePolygons() {
  noFill(); 
  stroke(100); 
 
  // Face outline
  beginShape();
  for (int i=0; i<34; i+=2) {
    if(6 <= i && i < 27){
      
    }
    vertex(rawArray[i], rawArray[i+1]);
  }
  for (int i=52; i>32; i-=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  endShape(CLOSE);
  
  // Eyes
  beginShape();
  for (int i=72; i<84; i+=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  endShape(CLOSE);
  beginShape();
  for (int i=84; i<96; i+=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  endShape(CLOSE);
  
  // Upper lip
  beginShape();
  for (int i=96; i<110; i+=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  for (int i=124; i>118; i-=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  endShape(CLOSE);
  
  // Lower lip
  beginShape();
  for (int i=108; i<120; i+=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  vertex(rawArray[96], rawArray[97]);
  for (int i=130; i>124; i-=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  endShape(CLOSE);
  
  // Nose bridge
  beginShape();
  for (int i=54; i<62; i+=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  endShape();
  
  // Nose bottom
  beginShape();
  for (int i=62; i<72; i+=2) {
    vertex(rawArray[i], rawArray[i+1]);
  }
  endShape();
}


//--------------------------------------------
public void found(int i) {
  found = i;
}
public void rawData(float[] raw) {
  rawArray = raw; // stash data in array
}

//--------------------------------------------
void keyPressed() {
  int len = rawArray.length; 
  if (keyCode == RIGHT) {
    highlighted = (highlighted + 2) % len;
  }
  if (keyCode == LEFT) {
    highlighted = (highlighted - 2 + len) % len;
  }
}
