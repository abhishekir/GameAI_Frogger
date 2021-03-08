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
