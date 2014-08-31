final int canvasWidth = 512;
final int canvasHeight = 512;
final int setFrameRate = 60;
int countSonar = 0;
int objectCount = 0;

SensedObject[] objects = new SensedObject[20];

class SensedObject {
  int xPos, yPos,flag;

    SensedObject (int x, int y) {
    xPos = x;
    yPos = y;
    flag = 0;
    objectCount++;
  }
};

void setup() {
    size(canvasWidth, canvasHeight);

    colorMode(HSB, 255);
    background(255);

    objects[0] = new SensedObject(100, 100);
    objects[1] = new SensedObject(400, 350);
    frameRate(setFrameRate);
}

void draw() {
    fadeToWhite();
    sonarWrite();
    drawObjects();
    emissionObject();
}

void fadeToWhite() {
    noStroke();
    fill(255, 100);
    rectMode(CORNER);
    rect(0, 0, width, height);
}

void sonarWrite() {
    countSonar = countSonar % (setFrameRate*3);
    if(countSonar == 0){
        for (int c = 0; c < objectCount; ++c) {
            objects[c].flag = 0;
        }
    }
    float radius = countSonar * 4;
    countSonar++;
    stroke(50, 100, 100);
    strokeWeight(0.8);
    ellipse(width/2, height/2, radius, radius);
}

void drawObjects() {
    noStroke();
    for (int c = 0; c < objectCount; ++c) {
        if(objects[c].flag == 0){
            fill(0, 100, 0, 100);
            ellipse(objects[c].xPos, objects[c].yPos, 10, 10);
            continue;
        }
        if(objects[c].flag == 1){
            fill(objects[c].xPos%255, 200, 200, 200);
            ellipse(objects[c].xPos, objects[c].yPos, 10, 10);
        }
    } 
}

void detectionObject() {

}

void emissionObject() {
    for (int c = 0; c < objectCount; ++c) {
        color col = get(objects[c].xPos, objects[c].yPos);
        if(col == 8289918){
            objects[c].flag =1;
        }
    }
}