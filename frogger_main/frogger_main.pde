/*
Part 1 - Q-Learning Results:
Record after 542 trials was 360 wins - 182 losses
Record after 5161 trials was 4896 wins - 265 losses

Part 2 - Widrow Hoff Results:
Record after 512 trials was 397 wins - 115 losses
*/

import java.util.Random;

static int FROG_WIDTH = 40;
static int GAME_WIDTH_IN_SQUARES = 12;
static int GAME_WIDTH = FROG_WIDTH * GAME_WIDTH_IN_SQUARES;
static int GAME_HEIGHT_IN_SQUARES = 5;
static int GAME_HEIGHT = FROG_WIDTH * GAME_HEIGHT_IN_SQUARES;
static float TRUCK_WIDTH = 1.3*FROG_WIDTH;
static float TRUCK_SPEED = 0.7;

static int START_FROG_X = 5;
static int START_FROG_Y = GAME_HEIGHT_IN_SQUARES-1;

static int frog_x = START_FROG_X;
static int frog_y = START_FROG_Y;
static int best_move = 0;

static int TRUCK_ROWS = GAME_HEIGHT_IN_SQUARES-2;
static int TRUCKS_PER_ROW = 2;

static float[][] truck_x = {{0, 100, 300},
                     {25, 225, 325},
                     {10, 70, 200}};

Random rng = new Random();

// Constants for frog moves, indexing into policy

static int STAY = 0;
static int MOVE_LEFT = 1;
static int MOVE_RIGHT = 2;
static int MOVE_UP = 3;
static int MOVE_DOWN = 4;
static int POSSIBLE_MOVES = 5;

static boolean WIDROW_HOFF = true;

// Slow the frog down a little so it's visible and not superspeedy
static int frame = 0;
static int deaths = 0;
static int wins = 0;
// Only allow action every this many frames
static int FROG_FRAMES = 1;

static float LEARNING_RATE = 0.2;
static float DISCOUNT_FACTOR = 0.3;

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
