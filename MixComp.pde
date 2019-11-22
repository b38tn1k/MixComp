import processing.sound.*;

IntList colors = new IntList(#ff71ce, #01cdfe, #05ffa1, #b967ff, #fffb96);
int bg;
PFont font;
RectButton b1;
RectButton b2;
RectButton playButton;
RectButton timeLine;
RectButton playHead;
RectButton m1Status;
RectButton m2Status;
boolean m1Active = true;
boolean m2Active = false;
int textColor;
boolean play = false;
int border = 10;
String mix1Path;
String mix2Path;
int activeColor;
int inactiveColor;
SoundFile mix1;
SoundFile mix2;
boolean playLatch = play;
boolean audioSetup = false;
float maxDuration;
float velocity;
int lastTime = 0;
int FFT_lower_border;

public class RectButton {
  public float x;
  public float y;
  public float w;
  public float h;
  public float x2;
  public float y2;
  public int c;
  String label;
  float cenX;
  float cenY;
  RectButton (float _x, float _y, float _w, float _h, int _c) {
    x = _x;
    y = _y;
    h = _h;
    w = _w;
    x2 = x+w;
    y2 = y+h;
    c = _c;
    label = " ";
    cenX = ((x + x2)/2);
    cenY = (y + (y2 - y)/2);
  }
  void attachLabel(String str) {
    label = str;
  }
  void updateXPosition(float _x) {
    x = _x;
    x2 = x+w;
    y2 = y+h;
  }
  void draw() {
    fill(c);
    rect(x, y, w, h);
    fill(textColor);
    textAlign(CENTER, CENTER);
    text(label, cenX, cenY);
  }
  boolean mouseOver()  {
    if (mouseX >= x && mouseX <= x2 && 
        mouseY >= y && mouseY <= y2) {
      return true;
    } else {
      return false;
    }
  }
  
}

void keyPressed() {
  if (key == 'r') {
    reset();
  }
  if (key == ' ') {
    play = !play;
    setPlayButtonIcon();
  }
  if (key == '1') {
    m1Active = true;
    m2Active = false;
    updateStatusLabels();
  }
  if (key == '2') {
    m2Active = true;
    m1Active = false;
    updateStatusLabels();
  }
}

void doPlayStuff() {
  if (mix1 != null && mix2 != null) {
    if (m1Active == true) {
      mix1.amp(1);
    } else {
      mix1.amp(0.01);
    }
    if (m2Active == true) {
      mix2.amp(1);
    } else {
      mix2.amp(0.01);
    }
    if (playLatch != play) {
      playLatch = play;
      if (play == true) {
        println("play");
        mix1.play();
        mix2.play();
      } else {
        println("pause");
        mix1.pause();
        mix2.pause();
      }
    }
  }
}

void reset() {
  colors = new IntList(#ff71ce, #01cdfe, #05ffa1, #b967ff, #fffb96);
  bg = urcol();
  background(bg);
  activeColor = urcol();
  inactiveColor = urcol();
  textColor = urcol();
  
  int _length = 235;
  int _height = 50;
  int ypos = height - (border + _height);
  b1 = new RectButton(border, ypos, _length, _height, rcol());
  b1.attachLabel("load sample 1");
  b2 = new RectButton(width - (_length + border), ypos, _length, _height, rcol());
  b2.attachLabel("load sample 2");
  _length = 50;
  ypos -= (_height + border);
  timeLine = new RectButton(border, ypos, (width - 2*border), _height, inactiveColor);
  playHead = new RectButton(border, ypos, (border), _height, activeColor);
  ypos -= (_height + border);
  playButton = new RectButton((width/2 - _length/2), ypos, _length, _height, inactiveColor);
  playButton.attachLabel(">");
  _length = ((width - 2 * border) / 2) - (_length - border);
  m1Status = new RectButton(border, ypos, _length, _height, rcol());
  m2Status = new RectButton((width - (border + _length)), ypos, _length, _height, rcol());
  updateStatusLabels();
  FFT_lower_border = ypos-border;
}

void setPlayButtonIcon() {
  if (play == true) {
    playButton.attachLabel("||");
    playButton.c = inactiveColor;
  } else {
    playButton.attachLabel(">");
    playButton.c = activeColor;
  }
}

void mouseReleased() {
  if (timeLine.mouseOver() == true) {
    playHead.updateXPosition(mouseX - border/2);
    float cue = (mouseX-border) / (1.0*(width - 2*border));
    if (audioSetup == true){
      cue = maxDuration*cue;
      play = false;
      while(mix1.isPlaying() == true) {mix1.stop();}
      while(mix2.isPlaying() == true) {mix2.stop();}
      mix1.cue(cue);
      mix2.cue(cue);
    }
  }
}

void mouseClicked() {
  if (b1.mouseOver() == true) {
    selectInput("Select Mix 1", "selectMix1");
  }
  if (b2.mouseOver() == true) {
    selectInput("Select Mix 2", "selectMix2");
  }
  if (playButton.mouseOver() == true) {
    play = ! play;
    setPlayButtonIcon();
  }
  if (m1Status.mouseOver() == true || m2Status.mouseOver() == true) {
    m1Active = !m1Active;
    m2Active = !m2Active;
    updateStatusLabels();
  }
  
}
int rcol() {
  return colors.get(int(random(colors.size())));
};

void updateStatusLabels() {
  String label = "Mix 1: ";
  if (m1Active == true) {
    label += "ON";
    m1Status.c = activeColor;
  } else {
    label += "MUTE";
    m1Status.c = inactiveColor;
  }
  m1Status.attachLabel(label);
  
  label = "Mix 2: ";
  if (m2Active == true) {
    label += "ON";
    m2Status.c = activeColor;
  } else {
    label += "MUTE";
    m2Status.c = inactiveColor;
  }
  m2Status.attachLabel(label);
}
int urcol() {
  int my_color = #FFFFFF;
  if (colors.size() >= 1) {
    int val = int(random(colors.size()));
    my_color = colors.get(val);
    colors.remove(val);
  } 
  return my_color;
}

void selectMix1(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    audioSetup = false;
    String name = selection.getName();
    String upper = name.toUpperCase();
    if ((upper.indexOf(".WAV") != -1) || (upper.indexOf(".AIF") != -1)|| (upper.indexOf(".MP3") != -1)) {
      println("User selected " + selection.getAbsolutePath());
      mix1Path = selection.getAbsolutePath();
      mix1 = new SoundFile(this, mix1Path);
      if (name.length() > 15) {
        name = name.substring(1, 7) + "..." + name.substring(name.length()-7, name.length());
      }
      b1.attachLabel(name);
      playHead.updateXPosition(border);
    } else {
      println("User Selected Wrong File");
    }
  }
}

void selectMix2(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    audioSetup = false;
    String name = selection.getName();
    String upper = name.toUpperCase();
    if ((upper.indexOf(".WAV") != -1) || (upper.indexOf(".AIF") != -1)|| (upper.indexOf(".MP3") != -1)) {
      println("User selected " + selection.getAbsolutePath());
      mix2Path = selection.getAbsolutePath();
      mix2 = new SoundFile(this, mix2Path);
      if (name.length() > 15) {
        name = name.substring(1, 7) + "..." + name.substring(name.length()-7, name.length());
      }
      b2.attachLabel(name);
      playHead.updateXPosition(border);
    } else {
      println("User Selected Wrong File");
    }
  }
}
FFT fft1;
FFT fft2;
int bands = 128;
float smoothingFactor = 0.2;
float[] sum1 = new float[bands];
float[] sum2 = new float[bands];
float barWidth;

void setup() {
  font = createFont("OCRAStd.otf", 20);
  textFont(font);
  size(500, 500, P2D); 
  reset();
  mix1 = new SoundFile(this, "05 Airport Arguments.wav");
  mix2 = new SoundFile(this, "04 Prosperity Gospel.wav");
  //FFT setup
  barWidth = (width-2*border)/float(bands);
  fft1 = new FFT(this, bands);
  fft2 = new FFT(this, bands);
  noStroke();
}



void draw(){
  clear();
  background(bg);
  
  float dt = (millis() - lastTime)/1000.0;
  lastTime = millis();
  doPlayStuff();
  if (audioSetup == false && mix1 != null && mix2 != null) {
    audioSetup = true;
    fft1.input(mix1);
    fft2.input(mix2);
    maxDuration = min(mix1.duration(), mix2.duration());
    println(maxDuration);
    velocity = (width - 2*border)/maxDuration;
  }
  if (audioSetup == true) {
    if (play == true) {
          fft1.analyze();
          fft2.analyze();
          for (int i = 0; i< bands; i++) {
            // Smooth the FFT spectrum data by smoothing factor
            sum1[i] += (fft1.spectrum[i] - sum1[i]) * smoothingFactor;
            sum2[i] += (fft2.spectrum[i] - sum2[i]) * smoothingFactor;
            float scale = 80*float(i)/bands;
            // Draw the rectangles, adjust their height using the scale factor
            fill(rcol());
            rect(border+i*barWidth, FFT_lower_border, barWidth, -sum1[i]*FFT_lower_border*scale);
            rect(border+i*barWidth, FFT_lower_border, barWidth, -sum2[i]*FFT_lower_border*scale);
        }
      float pos = playHead.x + velocity*dt;
      if (pos < (width-border)){
        playHead.updateXPosition(pos);
      } else {
        play = false;
      }
    }
    setPlayButtonIcon();
  }
  //cause I am lazy and like pretty stuff
  fill(bg);
  rect(0, 0, width, border);
  fill(rcol());
  
  b1.draw();
  b2.draw();
  playButton.draw();
  m1Status.draw();
  m2Status.draw();
  timeLine.draw();
  playHead.draw();
}
