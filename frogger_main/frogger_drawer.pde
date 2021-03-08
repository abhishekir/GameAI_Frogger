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
  
  //if (frame % frame_mod == 0) {
    best_move = decide_move(environment, WIDROW_HOFF);
    move_frog(best_move);
  //}
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
  //if (frame % frame_mod == 0 || dead_frog) {
    boolean[][] new_environment = get_nearby_squares();
    update_q(best_move, environment, new_environment, reward, WIDROW_HOFF);
  //}
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
