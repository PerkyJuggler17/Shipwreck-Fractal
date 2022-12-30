// step 1: illustrate Mandlebrot set ...done!
// step 2: enable zoom in and zoom out ...done!
// step 3: enable up, dpwn, left, right move ...done!
// step 4: enable changing the maxIther by scrolling up or down ...done!
// step 5: show the max iteration count and zoom rate ...done!
// step 6: colour the space according to iteration count ...done!
// step 7: add another color setting and enable screenshot ...done!
// step 8: see the effect in fullscreen ...done!

int maxIter = 128;
double minRe = -2.5, maxRe = 1;
double minIm = -1, maxIm = 1;
double zoom = 1.0;

boolean leftPressed = false, rightPressed = false;

color[] colors;

void zoomWindow(double z) {
  // set new center point at mouse point
  double cr = minRe + (maxRe - minRe) * mouseX/width;
  double ci = minIm + (maxIm - minIm) * mouseY/height;
  // zoom
  double tempMinr = cr - (maxRe - minRe) /2/z;
  maxRe = cr + (maxRe - minRe) /2/z;
  minRe = tempMinr;
  
  double tempMini = ci - (maxIm - minIm) /2/z;
  maxIm = ci + (maxIm - minIm) /2/z;
  minIm = tempMini;
}

void mouseReleased() {
  if (leftPressed) leftPressed = false;
  if (rightPressed) rightPressed = false;
}

void mouseWheel(MouseEvent event) {
  if (event.getCount() > 0) maxIter /= 2;
  if (event.getCount() < 0) maxIter *= 2;
  
  //maxIter = constrain(maxIter, 1, 2048);
}

void keyPressed() {
  double w = (maxRe - minRe) * 0.01;
  double h = (maxIm - minIm) * 0.01;
  
  if (keyCode == UP) {
    maxIm -= h;
    minIm -= h;
  } else if (keyCode == DOWN) {
    maxIm += h;
    minIm += h;
  } else if (keyCode == LEFT) {
    maxRe -= w;
    minRe -= w;
  } else if (keyCode == RIGHT) {
    maxRe += w;
    minRe += w;
  } else if (key == ' ') {
    saveFrame("ScreenShot-####.png");
  }
}

void setup() {
  //fullScreen();
  size(960, 540);
  colors = new color[]{
  color(0, 7, 100), color(332, 107, 203),
  color(237, 255, 255), color(255, 107, 0), color(0, 2, 0)
  };
  
  //colors = new color[]{
  //color(0), color(213, 67, 31),
  //color(251, 255, 121), color(62, 223, 89), color(43, 30, 218),
  //color(0, 255, 247)
  //};
}

void draw() {
  if (mousePressed && mouseButton == LEFT && !leftPressed) {
    leftPressed = true;
    zoomWindow(5.0);
    zoom *= 5.0;
  } else if (mousePressed && mouseButton == RIGHT && !rightPressed) {
    rightPressed = true;
    zoomWindow(1.0 / 5);
    zoom /= 5.0;
  }
  loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double cr = minRe + (maxRe - minRe) * x / width;
      double ci = minIm + (maxIm - minIm) *y / height;
      double re = 0, im = 0;
      
      int iter;
      for (iter = 0; iter < maxIter; iter++) {
        double tempr = re*re - im*im + cr;
        im = ((float)(2*re*im)) + ci;
        re = tempr;
        if (re*re + im*im > 2*2) break;
      }
      //pixels[x+y * width] = color(255 - (float) iter / maxIter*255);
      int colorCount = colors.length-1;
      if (iter == maxIter) iter = 0;
      double mu = 1.0 * iter / maxIter;
      mu *= colorCount;
      int iMu = (int) mu;
      color c1 = colors[iMu]; // color before the value mu
      color c2 = colors[min(iMu + 1, colorCount)]; // color right after mu
      color res = linearInterpolation(c1, c2, mu - iMu);
      pixels[x + y * width] = res;
    }
  }
  updatePixels();
  
  String iterMsg = "Max iteration: " + maxIter;
  String zoomMsg = "Zoom: " + zoom;
  textSize(20);
  fill(238);
  text(iterMsg, 40, 40, 280, 40);
  text(zoomMsg, 40, 80, 280, 80);
}

// return the color corrosponding to c1 + a*(c2-c1)
//where 'a' is a value between 0 and 1
color linearInterpolation(color c1, color c2, double a) {
  double newR = red(c1) + a *(red(c2) - red(c1));
  double newG = green(c1) + a *(green(c2) - green(c1));
  double newB = blue(c1) + a *(blue(c2) - blue(c1));
  return color((float)newR, (float)newG, (float)newB);
}
