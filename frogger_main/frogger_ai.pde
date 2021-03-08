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
