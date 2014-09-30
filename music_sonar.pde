import arb.soundcipher.*;
import SimpleOpenNI.*;

final int canvasWidth = 640;
final int canvasHeight = 480;
final int setFrameRate = 60;
final int maxObject = 4;

// SensedObject[] objects;
TestObject[] objects;

SoundCipher[] sounds;
// SoundCipher backMusic1;

LineWave lineWave;
SonarWave sonarWave;

SimpleOpenNI simpleOpenNI;
//kinectの取得できるピクセル(640,480)
//depthMap

int modeNum = 0;

class TestObject {
    float x, y;

    TestObject (float x, float y) {
        this.x = x;
        this.y = y;
    }
};

void setup() {
    size(canvasWidth, canvasHeight);
    colorMode(HSB, 255);
    background(255);

   sounds = new SoundCipher[maxObject];
    for(int c = 0; c < maxObject; ++c){
        sounds[c] = new SoundCipher(this);
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
    lineWave = new LineWave(simpleOpenNI, sounds);

    objects = new TestObject[maxObject];
    objects[0] = new TestObject(100, height/2);
    objects[1] = new TestObject(width/2, 350);
    objects[2] = new TestObject(width/2, height/2);
    sonarWave = new SonarWave(sounds, objects);

    frameRate(setFrameRate);
}

void draw() {
    update();
}

void update() {
    fadeToWhite();
    if(modeNum == 1){
        lineWave.update();
        return;
    }
    moveObject();
    sonarWave.update(objects);
}

void fadeToWhite() {
    noStroke();
    fill(255, 200);
    rectMode(CORNER);
    rect(0, 0, width, height);
}

void keyPressed() {
    if(key == 'c' || key == 'C'){
        modeNum = (modeNum + 1 ) % 2;
    }else if(key == 'e' || key == 'E'){
        noLoop();
        exit();
    }
}

void exit() {
    for(int c = 0; c < maxObject; ++c){
        sounds[c].stop();
    }
    println("EXIT");
    super.exit();
}


//test用
float amount0 = 1;
float amount1 = 0.5;
float amount2X = 0.5;
float amount2Y = 0.5;
void moveObject() {
    for (int c = 0; c < 3; ++c) {
        switch (c%maxObject) {
            case 0:
                if(objects[c].x > width || objects[c].x < 0){
                    amount0 = amount0*(-1);
                }
                objects[c].x = objects[c].x + amount0;
            break;
            case 1:
                if(objects[c].y > height || objects[c].y < 0){
                    amount1 = amount1*(-1);
                }
                objects[c].y = objects[c].y + amount1;
            break;
            case 2:
                if(objects[c].x > width || objects[c].x < 0){
                    amount2X = amount2X*(-1);
                }
                objects[c].x = objects[c].x + amount2X;
                if(objects[c].y > height || objects[c].y < 0){
                    amount2Y = amount2Y*(-1);
                }
                objects[c].y = objects[c].y + amount2Y;
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

