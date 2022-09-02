import java.util.Arrays;
import java.util.Comparator;
import java.util.Random;

// Vectors for forces and locations
PVector spawnPoint, gravity, airForce;

// Current generation running
Cannon[] cannons;

// Target
Target target;

// Initializing constants
float maxLifespan = 125, mutationRate = 0.1;
float lifespan = maxLifespan;
float maxProjectileSpeed = 30;
float minAngle = 0, maxAngle = PI/2;
int population = 100, generation = 1;

// Setting up Legend
PFont f;

// Setting up Random Generator
Random random = new Random();

void settings(){
  // Setting up canvas size
  size(1500, 1000);
}
 
void setup(){
  // Setting up environmental forces
  this.gravity = new PVector(0, 0.25);
  this.airForce = new PVector(-0.5,0.1);
  
  // Setting up Cannon spawn point
  this.spawnPoint = new PVector(width/16, height*15/16);
  
  // Setting up target spawn point
  this.target = new Target(width*15/16, random(height));
  
  // Create first generation
  this.cannons = new Cannon[this.population];
  for(int i = 0; i < this.population ; i++) {
    this.cannons[i] = new Cannon(-random(this.minAngle, this.maxAngle), this.maxProjectileSpeed, this.spawnPoint, PVector.sub(this.target.location, this.spawnPoint).mag());
  }
    f = createFont("Arial" , 16, true);
}
 
// THIS HAPPENS FOR EVERY FRAME
void draw(){
  // First: Clear everything on the screen
  background(255);
  
  // Second: Display the target
  this.target.display();
  
  // Third: Physics round
  for(int i = 0; i < this.population; i++) this.cannons[i].run(target, gravity, airForce);
  
  // Fourth: Update legend information
  textFont(f,16);
  fill(0);
  text("Lifespan: " + this.lifespan 
      + "\nGeneration: " + this.generation
      + "\nPopulation: " + this.population
      + "\nMutation Rate: " + (this.mutationRate * 100) + "%"
  , width/16,height/16);
  
  // (Optional): Change target location if desired
  if(mousePressed) this.target = new Target(mouseX, mouseY);
  
  if(this.lifespan > 0) {
    // Fifth: Reduce global lifespan timer of current generation if its above 0
    this.lifespan--;
  }
  else {
    // Sisth: Once the global lifespan timer reaches 0, start breeding process
    
    
    // Sorting cannons in a descending fashion according to fitness 
    Arrays.sort(cannons);
    
    println("Best Cannon: " + cannons[0].fitness);
    
    // SELECTING PARENTS: The 50% of the top cannons are selected for mating
    
    // Create new vector for offsprings
    Cannon[] offsprings = new Cannon[this.population];
    int halfPopulation = (population/2) + 1;
    
    for(int i = 0; i < this.population; i++) {
      // For each offspring, select 2 parents from the top 50%
      Cannon parentA = cannons[(int)(random(halfPopulation))];
      Cannon parentB = cannons[(int)(random(halfPopulation))];
      
      // Throw a dice to see how the crossup is going to be done
      boolean diceBoolean = random.nextBoolean();
      if(diceBoolean) {
        // Parent A will pass down the Cannon Angle
        // Parent B will pass down the Initial Projectile Speed
        offsprings[i] = new Cannon(parentA.angle, parentB.projectileSpeed, this.spawnPoint, PVector.sub(this.target.location, this.spawnPoint).mag());
      } else {
        // Parent A will pass down the Initial Projectile Speed
        // Parent B will pass down the Cannon Angle
        offsprings[i] =  new Cannon(parentB.angle, parentA.projectileSpeed, this.spawnPoint, PVector.sub(this.target.location, this.spawnPoint).mag());
      }
       
      // Perform Mutation
      offsprings[i].mutate(this.mutationRate);
    }
    
    // Reset lifespan timer
    this.lifespan = this.maxLifespan;
    
    // Increase generation
    this.generation++;
    
    // The offsprings become the new generation
    this.cannons = offsprings;
  }
}
