import arb.soundcipher.*;
import SimpleOpenNI.*;

final int canvasWidth = 640;
final int canvasHeight = 480;
final int userPosX = canvasWidth/2;
final int userPosY = canvasHeight;
final int maxDistance = (int)dist(userPosX, userPosY, 0, 0);
final int setFrameRate = 60;
final int maxObject = 4;
int countSonar = 0;
int objectCount = 0;
float sonarRadius;

SoundCipher[] hitSounds;
SoundCipher backMusic1;

SensedObject[] objects;
LineWave lineWave;

SimpleOpenNI simpleOpenNI;
//kinectの取得できるピクセル(640,480)
//depthMap

class SensedObject {
  float posX, posY, prePosX, prePosY;
  int flag, objectTime;

    SensedObject (float x, float y) {
    posX = x;
    posY = y;
    prePosX = x;
    prePosY = y;
    flag = 0;
    objectTime = 0;
    objectCount++;
  }
};

void setup() {
    size(canvasWidth, canvasHeight);
    colorMode(HSB, 255);
    background(255);

   hitSounds = new SoundCipher[maxObject];
    for(int c = 0; c < maxObject; ++c){
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

    simpleOpenNI = new SimpleOpenNI(this);
    simpleOpenNI.enableDepth();
    lineWave = new LineWave(simpleOpenNI, hitSounds);

    // objects = new SensedObject[maxObject];
    // objects[0] = new SensedObject(100, height/2);
    // objects[1] = new SensedObject(width/2, 350);
    // objects[2] = new SensedObject(width/2, height/2);

    frameRate(setFrameRate);
}

void draw() {
    // sonarWrite();
    // drawObjects();
    // emissionObject();
    update();
}

void update() {
    fadeToWhite();
    // moveObject();
    lineWave.update(lineWave.simpleOpenNI, lineWave.depthValues);
}

void fadeToWhite() {
    noStroke();
    fill(255, 200);
    rectMode(CORNER);
    rect(0, 0, width, height);
}

void sonarWrite() {
    countSonar = countSonar % (setFrameRate*5);
    if(countSonar == 0){
        for (int c = 0; c < objectCount; ++c) {
            objects[c].flag = 0;
        }
    }
    sonarRadius = countSonar * 4;
    countSonar++;
    stroke(50, 100, 100);
    strokeWeight(0.8);
    ellipse(userPosX, userPosY, sonarRadius, sonarRadius);
}

void drawObjects() {
    noStroke();
    float col = 0.0;
    float transparency = 0.0;
    for (int c = 0; c < objectCount; ++c) {
        fill(0, 100, 0, 100);
        ellipse(objects[c].posX, objects[c].posY, 10, 10);
    
        if(objects[c].flag == 1){
            objects[c].objectTime++;
            col = calculationDgrees(objects[c].prePosX, objects[c].prePosY);
            col = 255*col/360;
            transparency = centerDistance(objects[c].prePosX, objects[c].prePosY);
            transparency = 255 - 150*transparency/maxDistance;
            transparency = transparency - objects[c].objectTime;
            fill(col, 200, 200, transparency);
            ellipse(objects[c].prePosX, objects[c].prePosY, 10, 10);
        }
    } 
}

void emissionObject() {
    color col;
    for (int c = 0; c < objectCount; ++c) {
        col = get((int)objects[c].posX, (int)objects[c].posY);
        if(col == 8289918 && objects[c].flag == 0){
            objects[c].flag =1;
            objects[c].prePosX = objects[c].posX;
            objects[c].prePosY = objects[c].posY;
            objects[c].objectTime = 0;
            collisionSound(objects[c].prePosX, objects[c].prePosY,c);
        }
    }
}

float centerDistance(float x, float y) {
    return dist(userPosX, userPosY, x, y);
}

float calculationDgrees(float x, float y) {
    return abs(degrees(atan2(y-userPosY, x-userPosX)));
}

void collisionSound(float x, float y, int c) {
    float range = centerDistance(x, y);
    float angle = calculationDgrees(x, y);
    float pitch = 90 - 100*angle/360;
    println(pitch);
    float dynamic = 127 - (range/maxDistance)*120;
    float pan = 127 - (angle/360)*127;
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

void attenuationSound() {

}


float amount0 = 1;
float amount1 = 0.5;
float amount2X = 0.5;
float amount2Y = 0.5;
void moveObject() {
    for (int c = 0; c < objectCount; ++c) {
        switch (c%maxObject) {
            case 0:
                if(objects[c].posX > width || objects[c].posX < 0){
                    amount0 = amount0*(-1);
                }
                objects[c].posX = objects[c].posX + amount0;
            break;
            case 1:
                if(objects[c].posY > height || objects[c].posY < 0){
                    amount1 = amount1*(-1);
                }
                objects[c].posY = objects[c].posY + amount1;
            break;
            case 2:
                if(objects[c].posX > width || objects[c].posX < 0){
                    amount2X = amount2X*(-1);
                }
                objects[c].posX = objects[c].posX + amount2X;
                if(objects[c].posY > height || objects[c].posY < 0){
                    amount2Y = amount2Y*(-1);
                }
                objects[c].posY = objects[c].posY + amount2Y;
            break;    
        }
    }
}

int bound(float x, float y) {
    int ans = 0;
    if(x > width || x < 0){
        ans = 1;
    }
    if(y > height || y < 0){
        ans = 2;
    }
    return ans; 
}

