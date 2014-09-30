
class LineWave{
	int countWave = 0;
	float[] lines;
	int congestion = 16;
	int maxValue = width/congestion;

	int countFrame = 0;

    SimpleOpenNI simpleOpenNI;
    int[] depthValues;

    int[] useValues;

    SoundCipher[] lineSounds;

    LineWave(SimpleOpenNI simpleOpenNI, SoundCipher[] lineSounds) {
        this.simpleOpenNI = simpleOpenNI;
        this.depthValues = simpleOpenNI.depthMap();
        lines = new float[maxValue+1];
        for(int c = 0; c <= maxValue; ++c){
        	lines[c] = 0.0;
 	    }
 	    useValues = new int[maxValue + 1];
        for(int c = 0; c <= maxValue; ++c){
        	useValues[c] = 0;
 	    }

 	    this.lineSounds = lineSounds;
    }

    void update(SimpleOpenNI simpleOpenNI, int[] depthValues) {
    	simpleOpenNI.update();
    	countFrame = countFrame%60;
    	if(countFrame%5 == 0){
			updateDepthValues(simpleOpenNI, depthValues);
		}
		drawWave();
    	decrease();
    	countFrame++;
    }

    void updateDepthValues(SimpleOpenNI simpleOpenNI, int[] depthValues) {
    	depthValues = simpleOpenNI.depthMap();
    	float lineLengthR = 0.0;
    	float lineLengthL = 0.0;
    	int getPosition[] = new int[5];
    	int elementNumberR;
    	int elementNumberL;
    	countWave = countWave % (width/2 - congestion);

    	// for (int i = 1; i <= maxValue; ++i) {
    	// 	useValues[i] += constrain(depthValues[i + (640*height/2)],  0, 4000);
    	// }

    	//右側
	    getPosition[0] = width/2 + (countWave+1) + (640*height/2);
	    getPosition[1] = width/2 + 1 + (countWave+1) + (640*height/2);
	    getPosition[2] = width/2 - 1 + (countWave+1) + (640*height/2);
	    getPosition[3] = width/2 + (countWave+1) + (640*(height/2 + 1));
	    getPosition[4] = width/2 + (countWave+1) + (640*(height/2 - 1));
	    for (int i = 0; i < 5; ++i) {
			lineLengthR += depthValues[getPosition[i]];	    	
	    }
	    lineLengthR = lineLengthR/5;
	    elementNumberR = (width/2)/congestion + (countWave/congestion+1);
	    // lineLengthR = useValues[elementNumberR]/(maxValue/2);
	    // useValues[elementNumberR] = 0;
	    lineLengthR =  height - 20 - map(lineLengthR, 0, 4000, 0, height - 20);
	    lines[elementNumberR] = lineLengthR;
	    //line(width/2 + (countWave+1), height - 5, width/2 + (countWave+1), lineLength);
	    //collisionSound(lineLength, elementNumber, 0);

	    //左側
	    getPosition[0] = width/2 - (countWave+1) + (640*height/2);
	    getPosition[1] = width/2 + 1 - (countWave+1) + (640*height/2);
	    getPosition[2] = width/2 - 1 - (countWave+1) + (640*height/2);
	    getPosition[3] = width/2 - (countWave+1) + (640*(height/2 + 1));
	    getPosition[4] = width/2 - (countWave+1) + (640*(height/2 - 1));
	    for (int i = 0; i < 5; ++i) {
			lineLengthL += depthValues[getPosition[i]];	    	
	    }
	    lineLengthL = lineLengthL/5;
	    elementNumberL = (width/2)/congestion - (countWave/congestion+1);
	    // lineLengthL = useValues[elementNumberL]/(maxValue/2);
	    // useValues[elementNumberL] = 0;
	    lineLengthL = height - 20 - map(lineLengthL, 0, 4000, 0, height - 20);
	    lines[elementNumberL] =lineLengthL;
	    //line(width/2 - (countWave+1), height - 5, width/2 - (countWave+1), lineLength);
	    collisionSound(lineLengthR, elementNumberR, lineLengthL, elementNumberL, (countWave/congestion)%4);
	    println("L: "+lineLengthL + " R: "+ lineLengthR);
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
 	    // lineSounds[0].play();
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

