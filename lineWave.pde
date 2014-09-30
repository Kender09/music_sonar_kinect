
class LineWave{
	final int congestion = 16;
	final int maxValue = width/congestion;

	int countWave;
	int countFrame;

    SimpleOpenNI simpleOpenNI;
    int[] depthValues;
    float[] lines;

    SoundCipher[] lineSounds;

    LineWave(SimpleOpenNI simpleOpenNI, SoundCipher[] lineSounds) {
        countWave = 0;
        countFrame = 0;

        this.simpleOpenNI = simpleOpenNI;
        this.depthValues = simpleOpenNI.depthMap();
        lines = new float[maxValue+1];
        for(int c = 0; c <= maxValue; ++c){
        	lines[c] = 0.0;
 	    }
 	    
 	    this.lineSounds = lineSounds;
    }

    void update() {
    	this.simpleOpenNI.update();
    	countFrame = countFrame % (int)frameRate;
    	if(countFrame % 5 == 0){
			updateDepthValues();
		}
		drawWave();
    	decrease();
    	countFrame++;
    }

    void updateDepthValues() {
    	this.depthValues = this.simpleOpenNI.depthMap();
    	float lineLengthR = 0.0;
    	float lineLengthL = 0.0;
    	int getPosition[] = new int[5];
    	int elementNumberR;
    	int elementNumberL;
    	countWave = countWave % (width/2 - congestion);

    	//右側
	    getPosition[0] = width/2 + (countWave+1) + (640*height/2);
	    getPosition[1] = width/2 + 1 + (countWave+1) + (640*height/2);
	    getPosition[2] = width/2 - 1 + (countWave+1) + (640*height/2);
	    getPosition[3] = width/2 + (countWave+1) + (640*(height/2 + 1));
	    getPosition[4] = width/2 + (countWave+1) + (640*(height/2 - 1));
	    for (int i = 0; i < 5; ++i) {
			lineLengthR += this.depthValues[getPosition[i]];	    	
	    }
	    lineLengthR = lineLengthR/5;
	    elementNumberR = (width/2)/congestion + (countWave/congestion+1);
	    lineLengthR =  height - 20 - map(lineLengthR, 0, 4000, 0, height - 20);
	    lines[elementNumberR] = lineLengthR;

	    //左側
	    getPosition[0] = width/2 - (countWave+1) + (640*height/2);
	    getPosition[1] = width/2 + 1 - (countWave+1) + (640*height/2);
	    getPosition[2] = width/2 - 1 - (countWave+1) + (640*height/2);
	    getPosition[3] = width/2 - (countWave+1) + (640*(height/2 + 1));
	    getPosition[4] = width/2 - (countWave+1) + (640*(height/2 - 1));
	    for (int i = 0; i < 5; ++i) {
			lineLengthL += this.depthValues[getPosition[i]];	    	
	    }
	    lineLengthL = lineLengthL/5;
	    elementNumberL = (width/2)/congestion - (countWave/congestion+1);
	    lineLengthL = height - 20 - map(lineLengthL, 0, 4000, 0, height - 20);
	    lines[elementNumberL] =lineLengthL;


	    collisionSound(lineLengthR, elementNumberR, lineLengthL, elementNumberL, (countWave/congestion)%4);
	    // println("L: "+lineLengthL + " R: "+ lineLengthR);
	    countWave = countWave + congestion;
    }

    void drawWave() {
    	stroke(50, 100, 100);
	 	strokeWeight(0.8);
 	    for(int c = 1; c <= maxValue; ++c){
 	    	line(c * congestion, height - 10, c * congestion, (height-10) - lines[c]);
 	    }
 	    
    }

    void decrease() {
    	 for(int c = 1; c <= maxValue; ++c){
 	    	lines[c] = lines[c] * 0.98;
 	    	if(lines[c] < 0){
 	    		lines[c] = 0;
 	    	}
 	    }
    }

    void collisionSound(float lR, float xR,float lL, float xL, int c) {
    	double dynamic[] = new double[2];
    	double pan[] = new double[2];
    	double pitch[] = new double[2];
    	double durations[] = {100, 100};
    	double articulations[] = {0.8, 0.8};

    	// dynamic[0] = map(lR, 0, height - 20, 50, 127);
    	pan[0] = map(xR, 0, maxValue, 0, 127);
    	// pitch[0] = map((float)dynamic[0] + (float)pan[0], 0, 127*2, 60, 90);
    	// pitch[0] = random(62, 77);
    	pitch[0] = map(lR, 0, height - 20, 60, 80);
    	dynamic[0] = random(40) + 70;

    	// dynamic[1] = map(lL, 0, height - 20, 50, 127);
    	pan[1] = map(xL, 0, maxValue, 0, 127);
    	// pitch[1] = map((float)dynamic[1] + (float)pan[1], 0, 127*2, 60, 90);
    	//pitch[1] = random(62, 77);
    	pitch[1] = map(lL, 0, height - 20, 60, 80);
    	dynamic[1] = random(40) + 70;

    	lineSounds[c].playPhrase(
    		(double)0,
    		(double)0,
    		(double)0,
    		pitch,
    		dynamic,
    		durations,
    		articulations,
    		pan
    	);
    	// lineSounds[0].playNote(
	    //     0,
	    //     0,
	    //     0,
	    //     pitch,
	    //     dynamic,
	    //     100,
	    //     0.8,
	    //     pan
    	// );
    }


};

