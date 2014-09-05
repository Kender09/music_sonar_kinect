import arb.soundcipher.*;

SoundCipher[] hitSounds = new SoundCipher[5];

SoundCipher backMusic1;

final int canvasWidth = 512;
final int canvasHeight = 512;
final int halfWidth = canvasWidth/2;
final int halfHeight = canvasHeight/2;
final int setFrameRate = 60;
int countSonar = 0;
int objectCount = 0;

float sonarRadius;

SensedObject[] objects = new SensedObject[20];

class SensedObject {
  int xPos, yPos, preXpos, preYpos, flag;

    SensedObject (int x, int y) {
    xPos = x;
    yPos = y;
    preXpos = x;
    preYpos = y;
    flag = 0;
    objectCount++;
  }
};

void setup() {
    size(canvasWidth, canvasHeight);

    for(int c = 0; c < 5; ++c){
        hitSounds[c] = new SoundCipher(this);
    }

    // backMusic1 = new SoundCipher(this);
    // backMusic1.tempo(80);
    // backMusic1.repeat(16);
    // backMusic1.pan(64);
    // float[] pitches = {64, 66, 71, 73, 74, 66, 64, 73, 71, 66, 74, 73};
    // float[] dynamics = new float[pitches.length];
    // float[] durations = new float[pitches.length];
    // for(int i=0; i<pitches.length; i++) {
    // dynamics[i] = random(20) + 20;
    // durations[i] = 0.25;
    // }
    //backMusic1.playPhrase(pitches, dynamics, durations);

    colorMode(HSB, 255);
    background(255);

    objects[0] = new SensedObject(100, halfHeight);
    objects[1] = new SensedObject(halfWidth, 350);
    frameRate(setFrameRate);
}

void draw() {
    fadeToWhite();
    sonarWrite();
    drawObjects();
    emissionObject();

    moveObject();
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
    sonarRadius = countSonar * 4;
    countSonar++;
    stroke(50, 100, 100);
    strokeWeight(0.8);
    ellipse(halfWidth, halfHeight, sonarRadius, sonarRadius);
}

void drawObjects() {
    noStroke();
    for (int c = 0; c < objectCount; ++c) {
        fill(0, 100, 0, 100);
        ellipse(objects[c].xPos, objects[c].yPos, 10, 10);
    
        if(objects[c].flag == 1){
            float col = calculationDgrees(objects[c].preXpos, objects[c].preYpos);
            col = 255*col/360;
            float transparency = centerDistance(objects[c].preXpos, objects[c].preYpos);
            transparency = 255 - 150*transparency/halfWidth;
            fill(col, 200, 200, transparency);
            ellipse(objects[c].preXpos, objects[c].preYpos, 10, 10);
        }
    } 
}

void detectionObject() {

}

void emissionObject() {
    color col;
    for (int c = 0; c < objectCount; ++c) {
        col = get(objects[c].xPos, objects[c].yPos);
        if(col == 8289918 && objects[c].flag == 0){
            objects[c].flag =1;
            objects[c].preXpos = objects[c].xPos;
            objects[c].preYpos = objects[c].yPos;
            collisionSound(objects[c].preXpos, objects[c].preYpos,c);
        }
    }
}

float centerDistance(float x, float y) {
    return dist(halfWidth, halfHeight, x, y);
}

float calculationDgrees(float x, float y) {
    return abs(degrees(atan2(y-halfHeight, x-halfWidth)));
}

void collisionSound(float x, float y, int c) {
    float range = centerDistance(x, y);
    float pitch = calculationDgrees(x, y);
    pitch = 30*pitch/360 + 62;
    println(pitch);
    float dynamic = 127 - (range/halfWidth)*50;
    float pan = 64 + (((x-(halfWidth))/halfWidth)*64);
    hitSounds[c].playNote(
        0,
        0,
        0,
        pitch,
        dynamic,
        100,
        0.8,
        pan
    );
}

void moveObject() {
    for (int c = 0; c < objectCount; ++c) {
        if(c%2 == 0){
            objects[c].xPos = (objects[c].xPos + 1) % width;
        }
        if(c%2 == 1){
            objects[c].yPos = (objects[c].yPos + 1) % height;
        }
    }
}


