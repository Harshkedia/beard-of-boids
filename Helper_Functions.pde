float[] findIntersection(float[][] line1, float[][] line2) {
  // line intercept math by Paul Bourke http://paulbourke.net/geometry/pointlineplane/
  // Determine the intersection point of two line segments
  float[] intersection = new float[2];
  
  float x1 = line1[0][0];
  float y1 = line1[0][1];
  float x2 = line1[1][0];
  float y2 = line1[1][1];

  float x3 = line2[0][0];
  float y3 = line2[0][1];
  float x4 = line2[1][0];
  float y4 = line2[1][1];

  float denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1));

  if (denominator == 0) {
    return intersection;
  } 
  
    float ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator;
    float ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator;

    if (ua < 0 || ua > 1 || ub < 0 || ub > 1) {
      return intersection;
    } 
    
      float x = x1 + ua * (x2 - x1);
      float y = y1 + ua * (y2 - y1);
      
      intersection[0] = x;
      intersection[1] = y;      
      return intersection;
}

float[][] copy_beard_array(float[][] oldFloat){
  float[][] new_float = new float[22][2];
  
  for(int i=0; i<22; i++){
    new_float[i][0] = oldFloat[i][0];
    new_float[i][1] = oldFloat[i][1];
  }
 
  return new_float;
}


int[] getPointDifference(float[][] currentPoints, float[][] oldPoints){ 
  int total_displaced_points_x = 0;
  int total_displaced_points_y = 0;
  for(int i=0; i<22; i++){ 
    float cur_point_x = currentPoints[i][0];
    float cur_point_y = currentPoints[i][1];  
    float old_point_x = oldPoints[i][0];
    float old_point_y = oldPoints[i][1];
    
    total_displaced_points_x += cur_point_x-old_point_x;
    total_displaced_points_y += cur_point_y-old_point_y; 
  }
  
  int avg_displaced_x = total_displaced_points_x/22;
  int avg_displaced_y = total_displaced_points_y/22;
  
  int[] total_displaced = new int[2];
  total_displaced[0] = avg_displaced_x;
  total_displaced[1] = avg_displaced_y;
 
  return total_displaced;  
}
void moveBeardPoints(int[] displacement){
  for(int i=0; i<22; i++){
    beardPoints[i][0] = beardPoints[i][0]+displacement[0];
    beardPoints[i][1] = beardPoints[i][1]+displacement[1];
  }
}
