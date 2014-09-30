
class SonarWave {
    final int userPosX = width / 2;
    final int userPosY = height;
    final int maxDistance = (int)dist(userPosX, userPosY, 0, 0);

    int countSonar;
    int objectCount;

    SoundCipher[] hitSounds;

    SensedObject[] objects;

    SonarWave(SoundCipher[] hitSounds, TestObject[] objects) {
        countSonar = 0;
        objectCount = 3;
        this.hitSounds = hitSounds;
        this.objects = new SensedObject[objectCount];
        for (int c = 0; c < objectCount; ++c) {
            this.objects[c] = new SensedObject(objects[c].x, objects[c].y);
        }
    }

    void update(TestObject[] objects) {
        for (int c = 0; c < objectCount; ++c) {
            this.objects[c].posX = objects[c].x;
            this.objects[c].posY = objects[c].y;
        }
        sonarWrite();
        drawObjects();
        emissionObject();
    }

    void sonarWrite() {
        float sonarRadius;

        countSonar = countSonar % ((int)frameRate * 5);
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
                col = 255 * col / 360;
                transparency = centerDistance(objects[c].prePosX, objects[c].prePosY);
                transparency = 255 - 150 * transparency / maxDistance;
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
            if(col == 10000536 && objects[c].flag == 0){
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
        return abs(degrees(atan2(y - userPosY, x - userPosX)));
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

};

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
  }
};
