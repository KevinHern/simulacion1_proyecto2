/*
  THIS IS THE DEFINITION OF THE TARGET OBJECT
  
  This class contains 4 radiuses that determine the size of the 4 rings that the target has
*/
class Target {
  PVector location;
  float r1, r2, r3, r4;
  
  Target(float x, float y){
    this.location = new PVector(x, y);
    this.r4 = 100;
    this.r3 = 50;
    this.r2 = 25;
    this.r1 = 10;
  }
  
  void display() {
    pushMatrix();
    stroke(0);
    fill(200);
    ellipse(this.location.x, this.location.y, this.r4, this.r4);
    
    stroke(0);
    fill(150);
    ellipse(this.location.x, this.location.y, this.r3, this.r3);
    
    stroke(0);
    fill(100);
    ellipse(this.location.x, this.location.y, this.r2, this.r2);
    
    stroke(0);
    fill(100);
    ellipse(this.location.x, this.location.y, this.r1, this.r1);
    
    popMatrix();
  }
}

/*
  THIS IS THE DEFINITION OF THE PROJECTILE OBJECT
  
  This class contains basic physic properties of the projectile
*/
class Projectile {
  PVector location, velocity, acceleration;
  float maxSpeed;
  
  Projectile(PVector spawnPoint, float angle, float speed){
    this.location = new PVector(spawnPoint.x, spawnPoint.y);
    this.velocity = new PVector(speed*cos(angle), speed*sin(angle));
    this.maxSpeed = speed;
    this.acceleration = new PVector(0, 0);
  }

  void applyForce(PVector force) {
    // Calculates the current acceleration
    this.acceleration = PVector.add(this.acceleration, force);
  }
  
  // This is done for every frame
  void update () {
    // First: Modify velocity
    this.velocity = PVector.add(this.velocity, this.acceleration);
    this.velocity.limit(this.maxSpeed);
    
    // Second: Modify the location 
    this.location = PVector.add(this.velocity, this.location);
    
    // Multiply by 0 the current acceleration
    this.acceleration = PVector.mult(this.acceleration, 0);
  }
  
  // Repaint projectile!
  void display() {
    // Prevent projectile from going out of bounds
    if(this.location.y > height) {
      this.location.y = height;
      this.velocity = PVector.mult(this.velocity, 0);
    }
    pushMatrix();
    translate(this.location.x, this.location.y);
    ellipse(0, 0, 15, 15);
    popMatrix();
  }
}

/*
  THIS IS THE DEFINITION OF THE CANNON OBJECT
  
  This class contains basic physic properties of the cannon and projectiles
*/
class Cannon implements Comparable<Cannon> {
  float angle, projectileSpeed, fitness;
  PVector location;
  Projectile projectile;
  
  Cannon(float angle, float speed, PVector location, float fitness){
    this.angle = angle;
    this.projectileSpeed = speed;
    this.location = location;
    this.fitness = fitness;
    this.projectile = new Projectile(location, this.angle, this.projectileSpeed);
  }
  
  // Repaint cannon!
  void display() {
    pushMatrix();
    translate(this.location.x, this.location.y);
    pushMatrix();
    rotate(this.angle);
    fill(150);
    rect(-20, -10, 40, 20);
    popMatrix();
    fill(220);
    rect(-10, -10, 15, 30);
    popMatrix();
  }
  
  /*
    CALCULATING FITNESS
    
    The fitness is basically the distance from the projectile to the center of the target.
    The fitness gets calculated every frame to check if the new distance is less than the previous one
    If it is, then it is the new fitness, otherwise, the previous remains.
    
    Basically, the fitness is the metric of how 'closer' the cannon managed to get its projectile respect to the target
  */
  void getFitness (Target target) {
    float distance = PVector.sub(target.location, this.projectile.location).mag();
    this.fitness = (this.fitness > distance)? distance : this.fitness;
  }
  
  // This is done for every frame
  void run(Target target, PVector gravity, PVector airForce) {
    // First: Apply all the forces to the projectile
    PVector netForces = PVector.add(gravity, airForce);
    this.projectile.applyForce(netForces);
    
    // Second: Calculate new physics properties for the projectile
    this.projectile.update();
    
    // Third: Repaint projectile
    this.projectile.display();
    
    // Repaint Cannon
    this.display();
    
    // Calculate fitness
    this.getFitness(target);
  }
  
  // The only mutation performed is the variation of the angle
  void mutate(float mutationRate) {
    this.angle *= random(0.95, 1.05);
    this.projectileSpeed *= random(0.85, 1.15);
  }
  
  // Used to sort the cannons by fitness in a descending order
  @Override
  public int compareTo(Cannon cannon) {
    return (int)this.fitness - (int)cannon.fitness;
  }
}
