// Calming Randomized Mandala
// w66kday66

Mandala mandala;

float globalRotation = 0;
float rotationSpeed = 0.0015;     // slower spin
int bgHue = 200;                  // softer background
int lastRegenerateMillis = 0;
int regenerateInterval = 20000;   // 20 seconds between redesign of mandala

void setup() {
  size(800, 800);
  smooth(8);

  colorMode(HSB, 360, 100, 100, 100);
  noStroke();

  mandala = new Mandala();
  bgHue = int(random(180, 240));   // calm blue/teal range
  lastRegenerateMillis = millis();
}

void draw() {
  // gentle breathing background shift
  float bgShift = sin(frameCount * 0.005) * 6;
  background((bgHue + bgShift + 360) % 360, 30, 12);

  // slow infrequent full redesigns
  if (millis() - lastRegenerateMillis > regenerateInterval) {
    mandala.randomize();
    bgHue = int(random(180, 240));
    lastRegenerateMillis = millis();
  }

  globalRotation += rotationSpeed;

  translate(width / 2, height / 2);
  rotate(globalRotation);

  mandala.display();
}

// SPACE = instantly new calm mandala
// 's'   = save current frame
void keyPressed() {
  if (key == ' ') {
    mandala.randomize();
    bgHue = int(random(180, 240));
    lastRegenerateMillis = millis();
  } else if (key == 's' || key == 'S') {
    saveFrame("calm-mandala-####.png");
  }
}

// ---------------------------------------------------
// Mandala + Ring
// ---------------------------------------------------

class Mandala {
  ArrayList<Ring> rings;
  float paletteHue;   // central hue for whole mandala

  Mandala() {
    rings = new ArrayList<Ring>();
    randomize();
  }

  void randomize() {
    rings.clear();

    // pick one calm hue family (blue/green)
    paletteHue = random(170, 230);

    int ringCount = int(random(4, 8));  // fewer rings = less visual noise
    float maxR = min(width, height) * 0.5f - 40;

    for (int i = 0; i < ringCount; i++) {
      float t = map(i, 0, ringCount - 1, 0.2f, 1.0f);
      float r = t * maxR;

      Ring ring = new Ring();

      ring.radius = r;
      ring.segmentCount = int(random(10, 24));    // more petals, smoother feel
      ring.baseSize = random(18, 60);
      ring.shapeType = int(random(0, 3));         // fewer crazy shapes (0,1,2)

      // colors close to paletteHue, low-ish saturation
      float baseHue = paletteHue + random(-15, 15);
      float sat = random(25, 55);
      float bri = random(60, 95);

      ring.baseHue = baseHue;
      ring.baseSat = sat;
      ring.baseBri = bri;

      // softer motion
      ring.wobbleAmp = random(2, 10);
      ring.wobbleSpeed = random(0.003, 0.015);
      ring.wobblePhase = random(TWO_PI);

      ring.jitterAmp = random(0, 4); // almost no jitter

      rings.add(ring);
    }
  }

  void display() {
    for (Ring r : rings) {
      r.display();
    }
  }
}

class Ring {
  float radius;
  int segmentCount;
  float baseSize;
  int shapeType;

  float baseHue, baseSat, baseBri;

  float wobbleAmp;
  float wobbleSpeed;
  float wobblePhase;

  float jitterAmp;

  void display() {
    float time = frameCount;
    float wobble = sin(time * wobbleSpeed + wobblePhase) * wobbleAmp;
    float jitter = (noise(time * 0.005f + radius) - 0.5f) * jitterAmp;

    float currentRadius = radius + wobble + jitter;

    // very subtle hue drift
    float hueShift = sin(time * 0.004f + wobblePhase) * 8.0f;
    float hue = (baseHue + hueShift + 360) % 360;

    for (int i = 0; i < segmentCount; i++) {
      float angle = TWO_PI * i / segmentCount;

      pushMatrix();
      rotate(angle);

      // slow size pulsing
      float sizePulse = map(sin(time * 0.008f + i * 0.4f), -1, 1, 0.8f, 1.2f);
      float s = baseSize * sizePulse;

      // soft alpha gradient
      float alpha = map(i, 0, segmentCount - 1, 30, 80);
      fill(hue, baseSat, baseBri, alpha);

      drawShape(shapeType, currentRadius, 0, s);

      popMatrix();
    }
  }

  void drawShape(int type, float x, float y, float s) {
    switch (type) {

    case 0: // soft ellipse "petals"
      ellipse(x, y, s, s);
      break;

    case 1: // rounded rectangle leaf
      pushMatrix();
      translate(x, y);
      rotate(sin(frameCount * 0.005f + wobblePhase) * 0.25f);
      rectMode(CENTER);
      rect(0, 0, s * 1.1f, s * 0.6f, s * 0.4f);
      popMatrix();
      break;

    case 2: // simple triangle petal
      pushMatrix();
      translate(x, y);
      beginShape();
      vertex(-s * 0.35f, s * 0.3f);
      vertex(0, -s * 0.9f);
      vertex(s * 0.35f, s * 0.3f);
      endShape(CLOSE);
      popMatrix();
      break;
    }
  }
}
