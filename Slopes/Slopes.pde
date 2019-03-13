//Credit to go to the follow, this code is used for a calculus course to demonstrate slope fields

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following
// Via Reynolds: http://www.red3d.com/cwr/steer/FlowFollow.html

// Using this variable to decide whether to draw all the stuff
boolean debug = true;

int randomNoise = 33;

// Flowfield object
FlowField theFlow;

// An ArrayList of vehicles
ArrayList<Vehicle> vehicles;

int DEFAULT_RES = 35;

int N_SEED = 0;

int NUM_CARS = 100;

void setup() {
  size(800, 460);
  //fullScreen();

  // Make a new flow field with "resolution" of 16
  theFlow = new FlowField(DEFAULT_RES);
  theFlow.init();
  vehicles = new ArrayList<Vehicle>();
  // Make a whole bunch of vehicles with random maxspeed and maxforce values
  for (int i = 0; i < NUM_CARS; i++) {
    vehicles.add(new Vehicle(new PVector(random(width), random(height)), random(2, 5), random(0.1, 0.5)));
  }
}

void draw() {
  background(255);
  //// Display the theFlow in "debug" mode
  if (debug) theFlow.display();
  // Tell all the vehicles to follow the flow field
  for (Vehicle v : vehicles) {
    v.follow(theFlow);
    v.run();
  }
}


void keyPressed() {
  if (key == ' ') {
    debug = !debug;
  }
}

// Make a new theFlow
void mousePressed() {
  N_SEED+=5;
  theFlow.init();
  //theFlow = new FlowField(DEFAULT_RES);
  //theFlow.init();
  //  console.log("mouse pressed");
  
}

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following

class FlowField {

  // A flow field is a two dimensional array of PVectors
  PVector[][] forceField;
  int cols, rows; // Columns and Rows
  int resolution; // How large is each "cell" of the flow field

  FlowField(int r) {
    super();
    resolution = r;
    // Determine the number of columns and rows based on sketch's width and height
    cols = width/resolution;
    rows = height/resolution;
    this.forceField = new PVector[cols][rows];
  }

  public void init() {
    // Reseed noise so we get a new flow field every time
    randomNoise += 23;
    noiseSeed(millis());


    float xoff = 0;
    for (int i = 0; i < forceField.length; i++) {
      float yoff = 0;

      for (int j = 0; j < forceField[0].length; j++) {
        float theta = map(noise(xoff+0.01+N_SEED, yoff+0.01+N_SEED, 1), 0, 1, 0, TWO_PI);
        // Polar to cartesian coordinate transformation to get x and y components of the vector
        PVector vTemp = new PVector(cos(theta), sin(theta));
        PVector[] row = this.forceField[i]; 
        row[j] = vTemp;

        this.forceField[i][j] = vTemp; 
        yoff += 0.1;
      }
      xoff += 0.1;
    }
  }

  // Draw every vector
  void display() {
    for (int i = 0; i < forceField.length; i++) {
      for (int j = 0; j < forceField[0].length; j++) {
        drawVector(forceField[i][j], i*resolution, j*resolution, resolution-2);
      }
    }
  }

  // Renders a vector object 'v' as an arrow and a position 'x,y'
  void drawVector(PVector v, float x, float y, float scayl) {
    if (v==null)
      return;
    pushMatrix();
    float arrowsize = 4;
    // Translate to position to render vector
    translate(x, y);
    stroke(0, 100);
    // Call vector heading function to get direction (note that pointing to the right is a heading of 0) and rotate
    rotate(v.heading2D());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = v.mag()*scayl;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    line(0, 0, len, 0);
    //line(len,0,len-arrowsize,+arrowsize/2);
    //line(len,0,len-arrowsize,-arrowsize/2);
    popMatrix();
  }

  PVector lookup(PVector lookup) {
    int column = int(constrain(lookup.x/resolution, 0, cols-1));
    int row = int(constrain(lookup.y/resolution, 0, rows-1));

    return forceField[column][row].get();
  }
}

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Flow Field Following

class Vehicle {

  // The usual stuff
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Vehicle(PVector l, float ms, float mf) {
    position = l.get();
    r = 3.0;
    maxspeed = ms;
    maxforce = mf;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
  }

  public void run() {
    update();
    borders();
    display();
  }


  // Implementing Reynolds' flow field following algorithm
  // http://www.red3d.com/cwr/steer/FlowFollow.html
  void follow(FlowField flow) {
    // What is the vector at that spot in the flow field?
    PVector desired = flow.lookup(position);
    // Scale it up by maxspeed
    desired.mult(maxspeed);
    // Steering is desired minus velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    applyForce(steer);
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  void display() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    fill(175);
    stroke(0);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }
}
