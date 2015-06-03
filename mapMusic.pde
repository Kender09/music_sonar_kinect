
class MapMusic {
    final int userPosX = width / 4;
    final int userPosY = height;
    final int maxDistance = (int)dist(userPosX, userPosY, 0, 0);

    final int kinectWidth = 640;
    final int kinectHeight = 480;

    int columnNum;
    int rowNum;

    int countFrame;
    int countUpdateDepth;

    SCScore nearSound;
    SCScore baseSound;
    SCScore drumSound;
    int resetFlag = 0;

    SimpleOpenNI simpleOpenNI;
    int[] depthValues;
    float[] depthMap;

    float[] mapObjects;

    ChordSet chordSet;

//現在の小節
    int measureCount;

    MapMusic(SCScore nearSound, SCScore baseSound, SCScore drumSound, SimpleOpenNI simpleOpenNI) {
        this.nearSound = nearSound;
        // this.nearSound.tempo(80);
        this.nearSound.tempo(180);
        this.nearSound.repeat(0);

        this.baseSound = baseSound;
        this.baseSound.tempo(60);
        this.baseSound.repeat(0);

        this.drumSound = drumSound;
        this.drumSound.tempo(60);
        this.drumSound.repeat(0);

        this.simpleOpenNI = simpleOpenNI;
        this.depthValues = simpleOpenNI.depthMap();
        countUpdateDepth = 0;

        depthMap = new float[6];
        for(int i = 0; i < 6; ++i){
            depthMap[i] = 0;
        }
        mapObjects = new float[6];
        for(int i = 0; i < 6; ++i){
            mapObjects[i] = 0;
        }
        chordSet = new ChordSet();
        measureCount = 1;

        columnNum = 6;
        rowNum = 2;
    }

    void update() {
        countFrame = countFrame % ((int)frameRate * 4);

         // if(countFrame < 10 && resetFlag == 0){
        if(!nearSound.isPlaying() && !baseSound.isPlaying()){
            println("Start [" + measureCount + "] measure!");
            measureCount++;
            setMap();
            soundMusic();
        }
        // if(countFrame > (int)frameRate * 4 -10 && resetFlag == 1){
        //     resetFlag = 0;
        // }
        if(countFrame%10 == 0){
            drawKinectImage();
            updateDepthValues();
        }
        drawLine();
        drawMap();
        countFrame++;
    }

        void initMusic(){
        println("!!Stop music!!");
        this.nearSound.stop();
        this.nearSound.empty();
        this.baseSound.stop();
        this.baseSound.empty();
        countFrame =0;
    }

    void drawLine(){
        stroke(0, 90);
        strokeWeight(0.5);
        line(width/2,  height/5, 0, height/5);
        line(width/2,  3*height/5, 0, 3*height/5);

        line(width/12,  0, width/12, height);
        line(2*width/12,  0, 2*width/12, height);
        line(3*width/12,  0, 3*width/12, height);
        line(4*width/12,  0, 4*width/12, height);
        line(5*width/12,  0, 5*width/12, height);
    }

    void drawMap(){
        for (int c = 0; c < 6; ++c) {
            stroke(100, 100,100, 120);
            strokeWeight(5);
            line(c*width/12, mapObjects[c], (c+1)*width/12, mapObjects[c]);
        }
    }

    void drawKinectImage(){
        noStroke();
        fill(255);
        rectMode(CORNER);
        rect(width/2, 0, width, height);
        this.simpleOpenNI.update();
        PImage depthImage = this.simpleOpenNI.depthImage();
        image(depthImage,width/2, 0);
    }

 void updateDepthValues() {
    float savedepth;
    int countD;
    this.depthValues = this.simpleOpenNI.depthMap();
    for(int c = 0; c < 6; ++c){
        savedepth= 0;
        countD = 0;
        for(int i = 0; i < kinectWidth/12; ++i){
            for(int j = 0; j < 50; ++j){
                savedepth  += this.depthValues[c*kinectWidth/6 + kinectWidth/24 + i + (kinectWidth*kinectHeight/2 +j)]/50.0;
            }
            countD++;
        }
        depthMap[c] += savedepth/ countD;
    }
    countUpdateDepth++;
 }

    void setMap(){
        float thisF;
        for(int i = 0; i < 6; ++i){
            mapObjects[i] = 0;
        }
        for(int c = 0; c<6; ++c){
            if(depthMap[c] != 0){
                thisF = depthMap[c]/countUpdateDepth;
            }else{
                thisF = 0;
            }
            // println("depthMap"+c+ ": "+thisF);
            if(thisF > 4000){
                thisF = 4000;
            }
            mapObjects[c] =   height - 10 - map(thisF, 0, 4000, 0, height-10);
        }

        for(int i = 0; i < 6; ++i){
            depthMap[i] = 0;
        }
        countUpdateDepth = 0;
    }

    void soundMusic(){
        int chordCount = 0;
        int pitchCount = 0;
        float[][] oneBases = new float[3][12];
        float[] oneBasesPan = new float[12];
        float[] base_dynamics = new float[12];
        float base_longtail = 0.0;
        float base_articulation = 0.0;
        float pan;
        float[] phrase = new float[24];
        float[] dynamics = new float[24];
        float[] phrasePans = new float[24];
        float[] longtails = new float[24];
        float[] articulations = new float[24];
        float disPitch  = 0.0;

        float[] savePharse = new float[3];
        this.nearSound.stop();
        this.nearSound.empty();
        this.baseSound.stop();
        this.baseSound.empty();

        for(int c = 0; c < columnNum; ++c){
            if(mapObjects[c] <= 0){
                continue;
            }
            pan = (128/(columnNum-1))*c;
            if(pan>127){
                pan = 127;
            }
            if(height/5<= mapObjects[c] && mapObjects[c] < 3*height/5 && rowNum == 2){
                // float[] chord = chordSet.getCadenceChord(1);
                float[] chord = chordSet.getChord(0, mapObjects[c] - height/5, 2*height/5);
                disPitch = map(mapObjects[c], height/5, 3*height/5, 0, 15);
                oneBases[0][chordCount] = chord[0];
                oneBases[1][chordCount] = chord[1];
                oneBases[2][chordCount] = chord[2];
                oneBasesPan[chordCount] = pan;
                base_dynamics[chordCount] = 50 + disPitch;
                chordCount++;
            }
            if( 3*height/5 <= mapObjects[c] && rowNum == 2){
                float f = chordSet.getPitchB(2, 17,mapObjects[c] - 3*height/5, 2*height/5) -7;
               for (int i = 0; i < 3; ++i) {
                    savePharse[i] = (int)random(-4, 4);
                }
                phrase[pitchCount] = f;
                phrasePans[pitchCount] = pan;
                dynamics[pitchCount] = 70;
                longtails[pitchCount] = 1;
                pitchCount++;
                f = f - savePharse[0];
                phrase[pitchCount] = f;
                phrasePans[pitchCount] = pan;
                dynamics[pitchCount] = 70 - random(5, 15);
                longtails[pitchCount] = 2;
                pitchCount++;
                // f = f - savePharse[1];
                // phrase[pitchCount] = f;
                // phrasePans[pitchCount] = pan;
                // dynamics[pitchCount] = 80 - random(60, 40);
                // pitchCount++;
            }

            if(height/5<= mapObjects[c] && rowNum == 1){
                float f = chordSet.getPitchB(1, 30,mapObjects[c] - height/5, 4*height/5)-7;
                for (int i = 0; i < 3; ++i) {
                    savePharse[i] = (int)random(-4, 4);
                }
                phrase[pitchCount] = f;
                phrasePans[pitchCount] = pan;
                dynamics[pitchCount] = 70;
                longtails[pitchCount] = 1;
                pitchCount++;
                f = f - savePharse[0];
                phrase[pitchCount] = f;
                phrasePans[pitchCount] = pan;
                dynamics[pitchCount] = 70 - random(5, 15);
                longtails[pitchCount] = 2;
                pitchCount++;
            }
        }

        if(pitchCount !=0){
            for(int c= 0 ;  c < pitchCount; ++c){
                longtails[c] = longtails[c] * ((float)columnNum/(pitchCount/2));
                articulations[c] = 0.8;
                // println("longtail: "+longtails[c]);
            }
            /*
            int pitchCountGap = columnNum*2 - pitchCount;
            for (int i = 0; i < pitchCountGap; ++i) {
                phrase[pitchCount + i] = phrase[i % pitchCount];
                phrasePans[pitchCount + i] = phrasePans[i % pitchCount];
                dynamics[pitchCount+ i] = dynamics[i%pitchCount];
                longtails[pitchCount + i] = longtails[i%pitchCount];
                articulations[pitchCount + i] = articulations[i%pitchCount];
            }
            */
            float instrument_near = this.nearSound.ACOUSTIC_GRAND;
            this.nearSound.addPhrase(0, 0, instrument_near, phrase, dynamics, longtails, articulations, phrasePans);
        }

        // if(chordCount==0){
        //         float[] chord2 = chordSet.getRandomMinChord(0);
        //         oneBases[0][0] = chord2[0];
        //         oneBases[1][0] = chord2[1];
        //         oneBases[2][0] = chord2[2];
        //         base_dynamics[0] = 30;
        //         oneBasesPan[0] = 64;
        //         chordCount = 1;
        // }
        base_longtail =   (float)columnNum/chordCount;
        base_articulation = 0.8;

/*
        int chordCountGap = columnNum - chordCount;
        for (int i = 0; i < chordCountGap; ++i) {
            oneBases[0][chordCount + i] = oneBases[0][i % chordCount];
            oneBases[1][chordCount + i] = oneBases[1][i % chordCount];
            oneBases[2][chordCount + i] = oneBases[2][i % chordCount];
            oneBasesPan[chordCount + i] = oneBasesPan[i % chordCount];
            base_dynamics[chordCount + i] = base_dynamics[i % chordCount];
        }
        base_longtail = 1;
        chordCount = columnNum;
*/
        float instrument = this.baseSound.PIANO;
        for(int i=0; i<chordCount; ++i) {
            float[] thisChord = {oneBases[0][i], oneBases[1][i], oneBases[2][i]};
            this.baseSound.addChord(i*base_longtail, instrument, instrument, thisChord, base_dynamics[i], base_longtail, base_articulation, oneBasesPan[i]);
        }
        // if(rowNum == 1){
        //     float[] handChord1  = {35, 38, 42, 45};
        //     this.baseSound.addChord(0, 0, instrument, handChord1, 30, 1, 0.8, 64);
        //     float[] handChord2  = {40, 44, 47, 50};
        //     this.baseSound.addChord(1, 0, instrument, handChord2, 30, 1, 0.8, 64);
        //     float[] handChord3  = {46, 50, 53};
        //     this.baseSound.addChord(2, 0, instrument, handChord3, 30, 1, 0.8, 64);
        // }
        this.baseSound.play();

        if(pitchCount != 0){
            this.nearSound.play();
        }
        backMusic();
         resetFlag = 1;
    }

    void backMusic()
    {
        this.drumSound.stop();
        this.drumSound.empty();
        float[] phrase = new float[24];
        float[] dynamics = new float[24];
        float[] phrasePans = new float[24];
        float[] longtails = new float[24];
        float[] articulations = new float[24];
        for(int i=0; i<columnNum; ++i){
            phrase[i] = 53;
            dynamics[i] = 50;
            phrasePans[i] = 64;
            longtails[i] = 1;
            articulations[i] = 0.8;
        }
        this.drumSound.addPhrase(1/2.0, 9, 0, phrase, dynamics, longtails, articulations, phrasePans);
        phrase = new float[24];
        dynamics = new float[24];
        phrasePans = new float[24];
        longtails = new float[24];
        articulations = new float[24];
        for(int i=0; i<columnNum*4; ++i){
            phrase[i] = 42;
            phrasePans[i] = 64;
            if(i%4 == 0){
                dynamics[i] = 30;
                longtails[i] = 1/2.0;
            }
            if(i%4 == 1){
                dynamics[i] = 30;
                longtails[i] = 1/6.0;
            }
            if(i%4 == 2){
                dynamics[i] = 0;
                longtails[i] = 1/6.0;
            }
            if(i%4 == 3){
                dynamics[i] = 30;
                longtails[i] = 1/6.0;
            }
            articulations[i] = 0.8;
        }
        this.drumSound.addPhrase(0, 9, 0, phrase, dynamics, longtails, articulations, phrasePans);
        phrase = new float[24];
        dynamics = new float[24];
        phrasePans = new float[24];
        longtails = new float[24];
        articulations = new float[24];
         for(int i=0; i<1; ++i){
            phrase[i] = 57;
            dynamics[i] = 40;
            phrasePans[i] = 64;
            longtails[i] = 1;
            articulations[i] = 0.8;
        }
        this.drumSound.addPhrase(0, 9, 0, phrase, dynamics, longtails, articulations, phrasePans);
        this.drumSound.play();
    }

};
