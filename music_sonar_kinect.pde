import arb.soundcipher.*;
import SimpleOpenNI.*;

final int canvasWidth = 640;
final int canvasHeight = 480;
final int setFrameRate = 30;
final int maxObject = 4;

// SensedObject[] objects;
TestObject[] objects;
int objectCount = 1;

SoundCipher[] sounds;
// SoundCipher baseSound;
SCScore baseSound;
SCScore nearSound;
SCScore drumSound;

LineWave lineWave;
SonarWave sonarWave;
MapMusic mapMusic;

SimpleOpenNI simpleOpenNI;
//kinectの取得できるピクセル(640,480)
//depthMap

int modeNum = 0;
int stopFlag = 0;

int moveObNum = 0;

class TestObject {
    float x, y;

    TestObject (float x, float y) {
        this.x = x;
        this.y = y;
    }
};

void setup() {
    size(canvasWidth*2, canvasHeight);

    colorMode(HSB, 255);
    background(255);

   sounds = new SoundCipher[maxObject];
    for(int c = 0; c < maxObject; ++c){
        sounds[c] = new SoundCipher(this);
    }
    baseSound = new SCScore();
    nearSound = new SCScore();
    drumSound = new SCScore();
    simpleOpenNI = new SimpleOpenNI(this);
    simpleOpenNI.enableDepth();
    // lineWave = new LineWave(simpleOpenNI, sounds);

    mapMusic =new MapMusic(nearSound, baseSound, drumSound, simpleOpenNI);

    frameRate(setFrameRate);
}

void draw() {
    update();
}

void update() {
    fadeToWhite();
    if(stopFlag == 1){
        if(modeNum != 1){
            mapMusic.drawKinectImage();
            mapMusic.drawLine();
            mapMusic.drawMap();
        }
        textSize(40);
        fill(250,200,200);
        text("STOP", width/2 + 200, 300);
        return;
    }
    if(modeNum == 1){
        lineWave.update();
        return;
    }
    // moveObject();
    // sonarWave.update(objects, objectCount);
    mapMusic.update();
}

void fadeToWhite() {
    noStroke();
    fill(255, 200);
    rectMode(CORNER);
    rect(0, 0, width/2, height);

    // noStroke();
    // fill(255);
    // rectMode(CORNER);
    // rect(width/2, 0, width, height);
}

void keyPressed() {
    if(key == 'c' || key == 'C'){
        // modeNum = (modeNum + 1 ) % 2;
        return;
    }
    if(key == 'z' || key == 'Z'){
        // moveObNum = (moveObNum + 1) % objectCount;
    }
    if(key == 'e' || key == 'E'){
        noLoop();
        exit();
        return;
    }
    if(key == '+'){
        // createObject();
        return;
    }
    if(key == '-'){
        // deleteObject();
        return;
    }
    if(key == 's' || key == 'S'){
        stopFlag = (stopFlag  + 1) % 2;
        mapMusic.initMusic();
    }
    // textSize(12);
    // fill(0);
    // text("key: " + key, width/2 + 100, 200);
}

/*
void mousePressed() {
    int ch_x = mouseX;
    if(ch_x >= width/2){
        ch_x = width/2;
    }
    objects[moveObNum].x = ch_x;
    objects[moveObNum].y = mouseY;
}

void createObject() {
    if(objectCount >= maxObject){
        return;
    }
    objects[objectCount] = new TestObject(width/4, height/2);
    objectCount++;
}

void deleteObject() {
    if(objectCount <= 1){
        return;
    }
    objects[objectCount - 1] = null;
    objectCount--;
    moveObNum = moveObNum % objectCount;
}

void drawsetting() {
    textSize(12);
    fill(0);
    text("moveObjectNum: " + moveObNum, width/2 + 100, 50);
    for(int i = 0; i < objectCount; ++i){
        text("objectNum:" + i + "  x:" + objects[i].x + " y:" + objects[i].y, width/2 + 100, 100 + 20*i);
    }
    stroke(0);
    strokeWeight(1);
    line(width/2, 0, width/2, height);
}
*/
void exit() {
    for(int c = 0; c < maxObject; ++c){
        sounds[c].stop();
    }
    println("EXIT");
    super.exit();
}




