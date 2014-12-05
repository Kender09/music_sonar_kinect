
class MapMusic {
    final int userPosX = width / 4;
    final int userPosY = height;
    final int maxDistance = (int)dist(userPosX, userPosY, 0, 0);

    int countFrame;
    int objectCount;

    SCScore nearSound;
    SCScore baseSound;
    int resetFlag = 0;

    TestObject[] objects;

    float[] mapObjects;

    ChordSet chordSet;

    MapMusic(SCScore nearSound, SCScore  baseSound,TestObject[] objects, int objectCount, int maxObject) {
        this.objectCount = objectCount;
        this.nearSound = nearSound;
        this.nearSound.tempo(60);
        this.nearSound.repeat(-1);

        this.baseSound = baseSound;
        this.baseSound.tempo(60);
        this.baseSound.repeat(-1);

        // baseSound();
        this.objects = new TestObject[maxObject];
        for (int c = 0; c < this.objectCount; ++c) {
            this.objects[c] = new TestObject(objects[c].x, objects[c].y);
        }
        mapObjects = new float[5];
        for(int i = 0; i < 5; ++i){
            mapObjects[i] = -1;
        }
        chordSet = new ChordSet();
    }

    void update(TestObject[] objects, int objectCount) {
        countFrame = countFrame % ((int)frameRate * 4);

         if(countFrame < 10 && resetFlag == 0){
            setMap();
            soundMusic();
        }
        if(countFrame > (int)frameRate * 4 -10 && resetFlag == 1){
            resetFlag = 0;
        }
        for(;;){
            if (this.objectCount == objectCount) {
                break;
            }
            if (this.objectCount > objectCount) {
                this.objects[this.objectCount-1] = null;
                this.objectCount--;
            }
            if (this.objectCount < objectCount) {
                this.objects[this.objectCount] = new TestObject(objects[this.objectCount].x, objects[this.objectCount].y);
                this.objectCount++;
            }
        }
        for (int c = 0; c < this.objectCount; ++c) {
            this.objects[c].x = objects[c].x;
            this.objects[c].y = objects[c].y;
        }
        drawLine();
        drawMap();
        countFrame++;
    }

    void drawLine(){
        stroke(0, 90);
        strokeWeight(0.5);
        line(width/2,  height/5, 0, height/5);
        line(width/2,  3*height/5, 0, 3*height/5);

        line(width/10,  0, width/10, height);
        line(2*width/10,  0, 2*width/10, height);
        line(3*width/10,  0, 3*width/10, height);
        line(4*width/10,  0, 4*width/10, height);
    }

    void drawMap(){
        for (int c = 0; c < objectCount; ++c) {
            fill(0, 100, 0, 120);
            ellipse(objects[c].x, objects[c].y, 10, 10);
        }
    }

    void setMap(){
        for(int i = 0; i < 5; ++i){
            mapObjects[i] = -1;
        }
         for(int c = 0; c<this.objectCount; ++c){
                if(0 <= objects[c].x  && objects[c].x < width/10){
                    if(mapObjects[0]  < objects[c].y){
                        mapObjects[0] = objects[c].y;
                    }
                }
                if(width/10 <= objects[c].x && objects[c].x < 2*width/10){
                    if(mapObjects[1]  < objects[c].y){
                        mapObjects[1] = objects[c].y;
                    }
                }
                if(2*width/10 <= objects[c].x && objects[c].x < 3*width/10){
                    if(mapObjects[2]  < objects[c].y){
                        mapObjects[2] = objects[c].y;
                    }
                }
                if(3*width/10 <= objects[c].x && objects[c].x < 4*width/10){
                    if(mapObjects[3]  < objects[c].y){
                        mapObjects[3] = objects[c].y;
                    }
                }
                if(4*width/10 <= objects[c].x && objects[c].x <= 5*width/10){
                    if(mapObjects[4]  < objects[c].y){
                        mapObjects[4] = objects[c].y;
                    }
                }
         }
    }
    void soundMusic(){
        int chordCount = 0;
        int pitchCount = 0;
        float pan;
        float[] phrase = new float[10];
        float[] dynamics = new float[10];
        float[] phrasePans = new float[10];
        float[] longtails = new float[10];
        float[] articulations = new float[10];
        this.baseSound.stop();
        this.nearSound.stop();
        this.baseSound.empty();
        this.nearSound.empty();
        for(int c = 0; c < 5; ++c){
            if(mapObjects[c] == -1){
                continue;
            }
            pan = 32*c;
            if(c==5){
                pan = 127;
            }
            if(height/5<= mapObjects[c] && mapObjects[c] < 3*height/5){
                float[] chord = chordSet.getRandomChord();
                this.baseSound.addChord(chordCount, 1, 0, chord, 100, 3, 0.8, pan);
                chordCount++;
            }
            if( 3*height/5 <= mapObjects[c]){
                float f = chordSet.getPitch(2, mapObjects[c] - 3*height/5, 2*height/5);
                phrase[pitchCount] = f;
                phrasePans[pitchCount] = pan;
                pitchCount++;
                phrase[pitchCount] = f -2;
                phrasePans[pitchCount] = pan;
                pitchCount++;
            }
        }
        float longtail = 2- pitchCount * 0.5;
        if(longtail < 0.5){
            longtail = 0.5;
        }
        for(int c= 0 ;  c < pitchCount; ++c){
            longtails[c] = longtail;
            articulations[c] = 0.8;
            dynamics[c] = 60;
            if(c%2 ==1){
                dynamics[c] = 40;
            }
        }
        for(int c = 0;  c < pitchCount; ++c){
            this.nearSound.addPhrase(0, 0, 0, phrase, dynamics, longtails, articulations, phrasePans);
        }
        if(chordCount==0){
                float[] chord = chordSet.getRandomChord();
                this.baseSound.addChord(0, 1, 0, chord, 80, 5, 0.8, 64);
        }
        this.baseSound.play();

        if(pitchCount != 0){
            this.nearSound.play();
        }
         resetFlag = 1;
    }

};
