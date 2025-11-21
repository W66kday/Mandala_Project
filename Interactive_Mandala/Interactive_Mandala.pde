// Spinning Radial Mandala with Rotation & Translation
// New features: translate(), rotate(), pushMatrix(), popMatrix(), colorMode(HSB)

int numRings = 6;       // how many rings of shapes
float baseRadius = 40;  // distance of the first ring from the center

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 100); // easier color control for mandala
  background(0);
  noStroke();
}

void draw() {
  // Slight fade so you get a soft trail effect
  fill(0, 0, 0, 10);    // black with low alpha
  rect(0, 0, width, height);

  // Move origin to the center of the canvas (NEW: translate)
  translate(width/2, height/2);

  // Time value used for animation
  float t = frameCount * 0.02;

  // Interactivity:
  // mouseX controls how many “petals” per ring
  int petals = int(map(mouseX, 0, width, 6, 60));

  // mouseY controls how fast the whole mandala spins (NEW: rotate)
  float spinSpeed = map(mouseY, 0, height, -0.03, 0.03);
  rotate(frameCount * spinSpeed);

  for (int ring = 0; ring < numRings; ring++) {
    float ringRadius = baseRadius + ring * 60;

    for (int i = 0; i < petals; i++) {
      pushMatrix();  // save the current transform state (NEW: matrix stack)

      // Angle for this petal
      float angle = TWO_PI * i / petals;
      rotate(angle);

      // Little breathing/pulsing motion along the radius
      float pulse = sin(t + ring * 0.5 + i * 0.1);
      float r = ringRadius + pulse * 15;
      float size = map(pulse, -1, 1, 10, 40);

      // Color in HSB so hue wraps around the circle nicely
      float hue = (angle * 180 / PI + t * 60) % 360;
      float sat = map(ring, 0, numRings - 1, 40, 100);
      float bri = map(pulse, -1, 1, 40, 100);

      fill(hue, sat, bri, 85);
      ellipse(r, 0, size, size);

      popMatrix(); // restore transform, ensures the next petal starts clean
    }
  }
}
