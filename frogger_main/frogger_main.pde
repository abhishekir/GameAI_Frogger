/*
Part 1 - Q-Learning Results:
Record after 542 trials was 360 wins - 182 losses
Record after 5161 trials was 4896 wins - 265 losses

Part 2 - Widrow Hoff Results:
Record after 512 trials was 397 wins - 115 losses
*/

import java.util.Random;

int FROG_WIDTH = 40;
int GAME_WIDTH_IN_SQUARES = 12;
int GAME_WIDTH = FROG_WIDTH * GAME_WIDTH_IN_SQUARES;
int GAME_HEIGHT_IN_SQUARES = 5;
int GAME_HEIGHT = FROG_WIDTH * GAME_HEIGHT_IN_SQUARES;
float TRUCK_WIDTH = 1.3*FROG_WIDTH;
float TRUCK_SPEED = 0.7;

int START_FROG_X = 5;
int START_FROG_Y = GAME_HEIGHT_IN_SQUARES-1;

int frog_x = START_FROG_X;
int frog_y = START_FROG_Y;
int best_move = 0;

int TRUCK_ROWS = GAME_HEIGHT_IN_SQUARES-2;
int TRUCKS_PER_ROW = 2;

float[][] truck_x = {{0, 100, 300},
                     {25, 225, 325},
                     {10, 70, 200}};

Random rng = new Random();

// Constants for frog moves, indexing into policy

int STAY = 0;
int MOVE_LEFT = 1;
int MOVE_RIGHT = 2;
int MOVE_UP = 3;
int MOVE_DOWN = 4;
int POSSIBLE_MOVES = 5;

boolean WIDROW_HOFF = true;

// Slow the frog down a little so it's visible and not superspeedy
int frame = 0;
int deaths = 0;
int wins = 0;
// Only allow action every this many frames
int FROG_FRAMES = 3;

float LEARNING_RATE = 0.2;
float DISCOUNT_FACTOR = 0.3;

void settings() {
  size(GAME_WIDTH, GAME_HEIGHT);
  if (WIDROW_HOFF) {
    LEARNING_RATE = 0.01;
    DISCOUNT_FACTOR = 0.1;
  }
}

void setup() {
  textSize(20);
}

void draw() {
  frame++;
  int frame_mod = FROG_FRAMES;
  float truck_speed = TRUCK_SPEED;
  if (keyPressed && key == 'f') {
    frame_mod = FROG_FRAMES/3;
    truck_speed = TRUCK_SPEED * 3;
  }
  background(255);
  update_trucks(truck_speed);
  draw_trucks();
  boolean[][] environment = get_nearby_squares();
  
  if (frame % frame_mod == 0) {
    best_move = decide_move(environment, WIDROW_HOFF);
    move_frog(best_move);
  }
  boolean dead_frog = check_death();
  if (dead_frog) {
    deaths++;
  }
  fill(240,0,0);
  text(deaths, FROG_WIDTH/2, FROG_WIDTH/2);
  draw_frog(dead_frog);
  boolean winner_frog = (!dead_frog && frog_y == 0);
  if (winner_frog) {
    wins++;
  }
  text(wins, FROG_WIDTH*(GAME_WIDTH_IN_SQUARES-1), FROG_WIDTH/2);
  if (dead_frog || winner_frog) {
    frog_x = START_FROG_X;
    frog_y = START_FROG_Y;
  }
  
  // TODO figure rewards here
  float reward = 0;
  if (dead_frog) {
    reward -= 10;
  } else if (winner_frog) {
    reward += 20;
  }
  
  // Update model if we just moved or if we're getting killed because of our last move
  if (frame % frame_mod == 0 || dead_frog) {
    boolean[][] new_environment = get_nearby_squares();
    update_q(best_move, environment, new_environment, reward, WIDROW_HOFF);
  }
}

void draw_frog(boolean dead_frog) {
  if (dead_frog) {
    fill(240, 0, 0);
  } else {
    fill(0,240,0);
  }
  // Legs
  line(frog_x * FROG_WIDTH, frog_y * FROG_WIDTH, (frog_x + 1)*FROG_WIDTH, (frog_y + 1)*FROG_WIDTH);
  line(frog_x * FROG_WIDTH, (frog_y + 1) * FROG_WIDTH, (frog_x + 1)*FROG_WIDTH, frog_y * FROG_WIDTH);
  // body
  float frog_true_x = FROG_WIDTH * ((float)frog_x + 0.5);
  float frog_true_y = FROG_WIDTH * ((float)frog_y + 0.5);
  ellipse(frog_true_x, frog_true_y, FROG_WIDTH, FROG_WIDTH);
}

void update_trucks(float truck_speed) {
  for (int i = 0; i < TRUCK_ROWS; i++) {
    for (int j = 0; j < TRUCKS_PER_ROW; j++) {
      if (i % 2 == 0) {
        truck_x[i][j] += truck_speed;
        if (truck_x[i][j] >= GAME_WIDTH) {
          truck_x[i][j] = 0 - TRUCK_WIDTH;
        }
      } else {
        truck_x[i][j] -= truck_speed;
        if (truck_x[i][j] <= -TRUCK_WIDTH) {
          truck_x[i][j] = GAME_WIDTH;
        }
      }
    }
  }
}

void draw_trucks() {
  fill(120, 0, 0);
  for (int i = 0; i < TRUCK_ROWS; i++) {
    for (int j = 0; j < TRUCKS_PER_ROW; j++) {
      float truck_y = (i+1)*FROG_WIDTH;
      rect(truck_x[i][j], truck_y, TRUCK_WIDTH, FROG_WIDTH);
    }
  }
}

void move_frog(int best_move) {
  if (best_move == MOVE_LEFT) {
    frog_x--;
  } else if (best_move == MOVE_RIGHT) {
    frog_x++;
  } else if (best_move == MOVE_UP) {
    frog_y--;
  } else if (best_move == MOVE_DOWN) {
    frog_y++;
  }
}

boolean check_death() {
  // Die if we wander off the playing field
  if (frog_x < 0 || frog_x >= GAME_WIDTH_IN_SQUARES || frog_y < 0 || frog_y >= GAME_HEIGHT_IN_SQUARES) {
    return true;
  }
  for (int i = 0; i < TRUCK_ROWS; i++) {
    for (int j = 0; j < TRUCKS_PER_ROW; j++) {
      if (truck_in_square(i, j, frog_x, frog_y)) {
        return true;
      }
    }
  }
  return false;
}

// square_x and square_y are in FROG_WIDTH boxes
boolean truck_in_square(int truck_row, int truck, int square_x, int square_y) {
  if ((truck_row + 1) != square_y) {
    return false;
  }
  float truck_min_x = truck_x[truck_row][truck];
  float truck_max_x = truck_min_x + TRUCK_WIDTH;
  float square_min_x = square_x * FROG_WIDTH;
  float square_max_x = (square_x + 1) * FROG_WIDTH;
  if (square_max_x >= truck_min_x && square_min_x <= truck_max_x) {
    return true;
  }
  return false;
}

int decide_move(boolean[][] environment, boolean widrowHoff) {
  return QLearningAction(environment);    
}


//environment -> action = QValue
float[][] QStore = new float[256][5];

int getBestAction(int environmentCode) {
  float[] environmentActions = QStore[environmentCode];
  int bestAction = 0;
  float bestValue = environmentActions[bestAction];
  for (int i = 0; i < environmentActions.length; i++) {
    if (environmentActions[i] > bestValue) {
      bestValue = environmentActions[i];
      bestAction = i;
    }
  }
  return bestAction;
}


int QLearningAction(boolean[][] environment) {
  float pRandomAction = 0.8/(wins+1);
  float random = rng.nextFloat();
  int action;
  
  if (random < pRandomAction) {
    action = rng.nextInt(POSSIBLE_MOVES);
  } else {
    action = getBestAction(get_environment_code(environment));
  }
  
  return action;
}

// returns a 2-d boolean array representing if the squares around the frog are occupied
boolean[][] get_nearby_squares() {
  boolean[][] environment = new boolean[3][3];
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      environment[i][j] = false;
      int square_x = frog_x + j - 1;
      int square_y = frog_y + i - 1;
      if (square_x < 0 || square_y < 0 || square_x >= GAME_WIDTH_IN_SQUARES || square_y >= GAME_HEIGHT_IN_SQUARES) {
        environment[i][j] = true;  // treat off-board spaces as occupied;
      } else {
        if (square_y-1 >= 0 && square_y-1 < TRUCK_ROWS) {
          for (int k = 0; k < TRUCKS_PER_ROW; k++) { // only check in same row
            if (truck_in_square(square_y-1, k, square_x, square_y)) {
              environment[i][j] = true;
            }
          }
        }
      }
    }
  }
  return environment;
}

int toInt(boolean v) {
  return (v? 1 : 0);
}

// A helper to get a unique index for a particular environment, created using
// a binary code for the environment - index into Q(state, action) array with this
int get_environment_code(boolean[][]environment) {
  return toInt(environment[0][0]) * 128 + toInt(environment [0][1])*64
                       + toInt(environment[0][2]) * 32 + toInt(environment[1][0])*16
                       + toInt(environment[1][2]) * 8 + toInt(environment[2][0])*4
                       + toInt(environment[2][1]) * 2 + toInt(environment[2][2])*1;
}

/* Data Structure for storing action-location possiblities
 - 5 actions (up, down, left, right, wait)
 - 3 surrounding rows
 - 3 surrounding columns
 Indexing sequence: arr[action][row][column]
*/
float[][][] widrow_weights = new float[5][3][3];

void update_q(int best_move, boolean[][] environment,
              boolean[][] new_environment, float reward, boolean widrowHoff) {
   // TODO - Q-learning with or without Widrow-Hoff rule
   
   int initialEnvironment = get_environment_code(environment);
   float originalQ = QStore[initialEnvironment][best_move];
   
   int finalEnvironment = get_environment_code(new_environment);
   int bestNextAction = getBestAction(finalEnvironment);
   float maxQ = QStore[finalEnvironment][bestNextAction];
   
   if(!widrowHoff) { //Q-Learning Q Function
     QStore[initialEnvironment][best_move] = ((1 - LEARNING_RATE) * originalQ) 
     + (LEARNING_RATE*(reward + (DISCOUNT_FACTOR * maxQ)));
   } else { //Widrow-Hoff Q Function
     float QSum = 0;
     float w;
     int v;
     for (int i = 0; i < environment.length; i++) {
       for (int j = 0; j < environment[i].length; j++) {
         if(environment[i][j]) v = 1;
         else v = -1;
         w = widrow_weights[best_move][i][j];
         QSum += v*w;
       }
     }
     QStore[initialEnvironment][best_move] = QSum;
     
     float idealQ = reward + (LEARNING_RATE * maxQ);
     float error = idealQ - originalQ;
     
     for (int i = 0; i < environment.length; i++) {
       for (int j = 0; j < environment[i].length; j++) {
         if(environment[i][j]) v = 1;
         else v = -1;
         widrow_weights[best_move][i][j] += LEARNING_RATE * error * v;
       }
     }
     
     /*
     for (int i = 0; i < widrow_weights[best_move].length; i++) {
       for (int j = 0; j < widrow_weights[best_move][i].length; j++) {
         widrow_weights[best_move][i][j] += LEARNING_RATE * error * v;
       }
     }
     */
   }
   return;
}
