class Button {
  
  float w;
  float h;
  float x;
  float y;
  String text;
  color colorr; 
  int size;
  
  Button(float x, float y, float w, float h, String text, color colorr, int size) {
    this.w = w;
    this.h = h;
    this.x = x;
    this.y = y;
    this.text = text;
    this.colorr = colorr;
    this.size = size; 
  }
  
  void show() {
    strokeWeight(10);
    fill(255);
    stroke(colorr); 
    rect(x, y, w, h); 
    textSize(size);  
    fill(colorr);
    text(text, x, y);  
  }
  
  boolean pressed() {
    if (mouseX < x + (w/2) && mouseX > x - (w/2) && mouseY < y + (h/2) && mouseY > y - (h/2)) {
      return true;
    } else {
      return false;
    }
  }
  
  
}
