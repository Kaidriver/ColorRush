//Imports all necessary libraries for sound and save files 
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.content.res.AssetFileDescriptor;
import android.content.Context;
import android.app.Activity;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.media.AudioManager;



import ketai.camera.*;

//Camera
KetaiCamera cam; 

//Sound
SoundPool soundPool;
HashMap<Object, Object> soundPoolMap;
Activity act;
Context cont;
AssetFileDescriptor afd1;
int checkSound;
int streamId;
 
//Detecting colors
color trackColor;
float threshold;

//Tracking Values
PImage check;
PImage back;
PFont font;
int next;
int random;
boolean nextColor = false;
boolean won = false;


//Colors that are tracked
color [] colors = {color(223, 0, 0), color(255,131,0), color(245,245,0), color(0, 176, 0), color(0, 0, 110), };
String [] cName = {"Red", "Orange", "Yellow", "Green", "Blue"};

//Controls which screen to go to
int scene = 1; 


//Tracks all scores
int score = 0;
int highScore = 0;
int highScore2 = 0; 

//Controls timer
float begin; 
boolean start = true;
int t;
String time = "010";
int interval = 60;

void setup() {
  
  //Screen orientation
  fullScreen();
  orientation(LANDSCAPE);
  
  //Load/Format images, fonts
  check = loadImage("check.png");
  back = loadImage("background.jpg");
  back.resize(displayWidth, displayHeight);
  font = createFont("font.ttf", 48);
  textFont(font, 32);
  imageMode(CENTER);
  rectMode(CENTER);
  textMode(CENTER);
  textAlign(CENTER, CENTER);
  
  //Camera setup
  next = 0;
  threshold = 30;
  cam = new KetaiCamera(this, displayWidth/2, 500, 60);
  cam.enableFlash();
 
  //Sets up sound effect
  act = this.getActivity();
  cont = act.getApplicationContext();
  try {
    afd1 = cont.getAssets().openFd("Ding.mp3");
  } 
  catch(IOException e) {
    println("error loading files:" + e);
  }
  soundPool = new SoundPool(12, AudioManager.STREAM_MUSIC, 0);
  soundPoolMap = new HashMap<Object, Object>(2);
  soundPoolMap.put(checkSound, soundPool.load(afd1, 1));
  
  //Load saved data
  loadData();
}

void draw() {
  
  background(back); 
  
  //Saves data
  saveData();
  
  //Main menu
  if (scene == 1) {
 
    //Resets values
    start = true; 
    next = 0;
    won = false; 
    score = 0;
    
    //Displays UI
    printColorText("Color Rush", 200, displayWidth/5, 300);
    Button rush = new Button(displayWidth/2, displayHeight/2, displayWidth/2, displayHeight/8, "Rush Mode", 0, 60);
    Button endless = new Button(displayWidth/2, displayHeight/5*4, displayWidth/2, displayHeight/8, "Endless Mode", 0, 60);
    rush.show();
    endless.show();
    
    //Checks button press
    if (rush.pressed()) {
      scene = 2;
    } else if (endless.pressed()) {
      scene = 3;
    }
    fill(0);
    
    //Color Rush 
  } else if (scene == 2) {
    
    //Displays camera
    displayCamera();
   
    //Shows color that is seeked
    Button currentColor = new Button(displayWidth*3/4, displayHeight/3*2, displayWidth/3, displayHeight/3, cName[next], colors[next], 150);
    currentColor.show();
    
    //Detects if color is detected
    if (detect(colors[next])) {
      playSound(1);
      
      
      //Detects win 
      if (next == 4) {
        nextColor = true;
        mouseX = 0;
        mouseY = 0;
        won = true;
        scene = -2;
      } 
      else {
        next++; 
      }
      
    }
    
    //Sets timer
    interval = 60;
    if (timer(colors[next])) {
      mouseX = 0;
      mouseY = 0;
      scene = -1; 
    }
    
    //Endless Mode
  } else if (scene == 3) {
    
    //Displays camera
    displayCamera();
     
    //Generates random color to seek
    color target = colors[random];
    if (nextColor) {
      do {
         random = int(random(5));
      } while (target == colors[random]); 
      target = colors[random];
      nextColor = false;
    }
    
    //Display color to seek
    Button currentColor = new Button(displayWidth*3/4, displayHeight/3*2, displayWidth/3, displayHeight/3, cName[random], target, 150);
    currentColor.show();
    
    //Checks if color is detected
    if (detect(target)) {
      playSound(1);
      image(check, displayWidth/4, displayHeight/2);
      score+=10; 
      nextColor = true;
      start = true;
    }
    
    //Sets up timer
    interval = 10;
    if (timer(target)) {
      mouseX = 0;
      mouseY = 0;
      scene = -3;
    }
    
  } 
  //Game Over Menu for Rush Mode
  else if (scene == -1) {
    
    //Display UI
    printColorText("Game Over!", 200, displayWidth/5*1.2, displayWidth/8);
    Button scoreBox = new Button(displayWidth/2, displayHeight/3*1.5, displayWidth/2, displayHeight/8, "Score: " + score + "  Best: " + highScore2, 0, 60);
    Button endless = new Button(displayWidth/2, displayHeight/3*2.2, displayWidth/2, displayHeight/8, "Play Again", 0, 60);
    endless.show();
    scoreBox.show();
    
    //Go back to main menu
    if (endless.pressed()) {
      scene = 1;
    }
    
  }
  //Win Menu for Rush Mode
  else if (scene == -2) {
    
    //Update high score if achieved
    if (score > highScore) {
      highScore = score;
    }
    
    //Displays UI
    printColorText("You Win!", 200, displayWidth/5*1.4, displayWidth/8);
    Button scoreBox = new Button(displayWidth/2, displayHeight/3*1.5, displayWidth/2, displayHeight/8, "Score: " + score + "  Best: " + highScore, 0, 60);
    Button endless = new Button(displayWidth/2, displayHeight/3*2.2, displayWidth/2, displayHeight/8, "Play Again", 0, 60);
    endless.show();
    scoreBox.show();
    
    //Go back to main menu
    if (endless.pressed()) {
      scene = 1;
    }
    
  }
  //Game Over Menu for Endless Mode
  else if (scene == -3) {
    
    //Displays UI
    printColorText("Game Over!", 200, displayWidth/5*1.2, displayWidth/8);
    Button scoreBox = new Button(displayWidth/2, displayHeight/3*1.5, displayWidth/2, displayHeight/8, "Score: " + score + "  Best: " + highScore2, 0, 60);
    Button endless = new Button(displayWidth/2, displayHeight/3*2.2, displayWidth/2, displayHeight/8, "Play Again", 0, 60);
    endless.show();
    scoreBox.show();
    
    //Updates high score if achieved
    if (score > highScore2) {
      highScore2 = score;
     
    }

    //Go back to main menu
    if (endless.pressed()) {
      scene = 1;
    }
    
  } 
  
}

//Displays camera
void displayCamera() {
  if (!cam.isStarted()) {
     cam.start();
  }
   cam.read();
   if (cam != null && cam.isStarted()) {
     image(cam, displayWidth/4, displayHeight/2);
   }
}

//Sees if color is detected
boolean detect (color trackColor) {
  
  float avgX = 0;
  float avgY = 0;
  
  int count = 0;
  
  //Loops through every single pixel
  for (int x = 0; x < cam.width; x++) {
    
    for (int y = 0; y < cam.height; y++) {
      
      int loc = x + y * cam.width;
      
      //Checks color distance between pixel read and color seek
      color colorRead = cam.pixels[loc];
      
      float r1 = red(colorRead);
      float g1 = green(colorRead);
      float b1 = blue(colorRead);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);
      
      float d = distSq(r1, g1, b1, r2, g2, b2);
      
      //Adds to count if inside threshold
      if (d < threshold*threshold) {
         
        avgX += x + displayWidth/4-displayWidth/2/2;
        avgY += y + displayHeight/2-250;
        count++;
        
      }
      
    }
    
  }
 
  //Return true if count if bigger than certain threshold, else return false
  if (count > 700) {
    
    
    
    avgX = avgX/count;
    avgY = avgY/count;
    /*
    fill(255);
    strokeWeight(4);
    stroke(0);
    ellipse(avgX, avgY, 24, 24);
    */
    image(check, avgX, avgY);
    return true;
  } else {
    /*
    System.out.println("NOT FOUND");
    */
    return false;
  }
    
  
}

//Sets up timer 
boolean timer (color colorr) {
  

  if (start) {
    begin = millis();
    start = false; 
  }  
  
  int time = interval-int((millis()-begin)/1000);
 
  //Displays timer
  if (score != 0) {
    Button timer = new Button(displayWidth/4*3, displayHeight/3, displayWidth/3, displayHeight/3, str(time) + "  " + str(score), colorr, 150);
    timer.show(); 
  } else {
     Button timer = new Button(displayWidth/4*3, displayHeight/3, displayWidth/3, displayHeight/3, str(time), colorr, 150);
    timer.show(); 
  }
 
  //Timer returns true/false to signal game over
  if (time <= 0) {
    return true;
  } else if (won) {
    score = time;
    
    return false; 
  }
  else {
    return false; 
  }
  
}

//Print text in different color lettering (for main menu and game over)
void printColorText(String text, int size, float x, float y) {
  int colorss = 0;
  for (int i = 0; i < text.length()*135; i+=135) {
    textSize(size);
    fill(colors[colorss]);
    text(text.charAt(i/135), x+i, y);
    colorss++;
    if (colorss == 4) {
      colorss = 0;
    }
  }
}

//Saves Data
void saveData() {
  SharedPreferences sharedPreferences;
  SharedPreferences.Editor editor;
  Activity act;
  act = this.getActivity();
  sharedPreferences = PreferenceManager.getDefaultSharedPreferences(act.getApplicationContext()); 
  editor = sharedPreferences.edit();
  editor.putInt("Highscore", highScore);
  editor.putInt("Highscore2", highScore2);
  editor.commit();
}

//Loads Data
void loadData() {
  SharedPreferences sharedPreferences;
  Activity act;
  act = this.getActivity();
  sharedPreferences = PreferenceManager.getDefaultSharedPreferences(act.getApplicationContext()); 
  highScore = sharedPreferences.getInt("Highscore", highScore);
  highScore2 = sharedPreferences.getInt("Highscore2", highScore2);
}

//Finds color distance
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

//Plays sound
void playSound(int soundID) {
  soundPool.stop(streamId);
  streamId = soundPool.play(soundID, 1.0, 1.0, 1, 0, 1f);
}
