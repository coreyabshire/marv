import numpy as np

def get_turn_radius(w, a, b): 
    return np.abs(w / 2 * (a + b) / (b - a))

def normalize(v):
    return v / np.linalg.norm(v)

def orthogonal_vec(v):
    return np.array([v[1], v[0]])

def get_position(center, cos_angle, sin_angle, radius):
    return np.array([center[0] + cos_angle * radius, center[1] + sin_angle * radius])
    
def rotate_90_cw(v):
    return np.array([v[1], -v[0]])
    
def rotate_90_ccw(v):
    return np.array([-v[1], v[0]])
    
def get_pos_cw(c, v, r, ca, sa):
    return c + v * r * ca + rotate_90_cw(v) * r * sa
    
def get_pos_ccw(c, v, r, ca, sa):
    return c + v * r * ca + rotate_90_ccw(v) * r * sa
    
def apply_distance_left_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance):
    center_radius = get_turn_radius(vehicle_width, left_distance, right_distance)
    half_vehicle_width = vehicle_width / 2.0
    left_radius = center_radius - half_vehicle_width
    right_radius = center_radius + half_vehicle_width
    turn_center = center_position + normalize(left_position - center_position) * center_radius
    turn_vec = center_position - turn_center
    norm_turn_vec = normalize(turn_vec)
    turn_angle_deg = 180.0 * right_distance / (np.pi * right_radius)
    turn_angle = np.deg2rad(turn_angle_deg)
    cos_turn_angle = np.cos(turn_angle)
    sin_turn_angle = np.sin(turn_angle)
    left_position = get_pos_ccw(turn_center, norm_turn_vec, left_radius, cos_turn_angle, sin_turn_angle)
    center_position = get_pos_ccw(turn_center, norm_turn_vec, center_radius, cos_turn_angle, sin_turn_angle)
    right_position = get_pos_ccw(turn_center, norm_turn_vec, right_radius, cos_turn_angle, sin_turn_angle)
    return left_position, center_position, right_position

def apply_distance_right_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance):
    center_radius = get_turn_radius(vehicle_width, left_distance, right_distance)
    half_vehicle_width = vehicle_width / 2.0
    left_radius = center_radius + half_vehicle_width
    right_radius = center_radius - half_vehicle_width
    turn_center = center_position + normalize(right_position - center_position) * center_radius
    turn_vec = center_position - turn_center
    norm_turn_vec = normalize(turn_vec)
    turn_angle_deg = 180.0 * left_distance / (np.pi * left_radius)
    turn_angle = np.deg2rad(turn_angle_deg)
    cos_turn_angle = np.cos(turn_angle)
    sin_turn_angle = np.sin(turn_angle)
    left_position = get_pos_cw(turn_center, norm_turn_vec, left_radius, cos_turn_angle, sin_turn_angle)
    center_position = get_pos_cw(turn_center, norm_turn_vec, center_radius, cos_turn_angle, sin_turn_angle)
    right_position = get_pos_cw(turn_center, norm_turn_vec, right_radius, cos_turn_angle, sin_turn_angle)
    return left_position, center_position, right_position

def apply_distance_turn(vehicle_width, inner_position, center_position, outer_position, inner_distance, outer_distance, direction):
    center_radius = get_turn_radius(vehicle_width, inner_distance, outer_distance)
    half_vehicle_width = vehicle_width / 2.0
    outer_radius = center_radius + half_vehicle_width
    inner_radius = center_radius - half_vehicle_width
    turn_center = center_position + normalize(inner_position - center_position) * center_radius
    turn_vec = center_position - turn_center
    norm_turn_vec = normalize(turn_vec)
    turn_angle_deg = direction * 180.0 * outer_distance / (np.pi * outer_radius)
    turn_angle = np.deg2rad(turn_angle_deg)
    cos_turn_angle = np.cos(turn_angle)
    sin_turn_angle = np.sin(turn_angle)
    inner_position = get_pos_ccw(turn_center, norm_turn_vec, inner_radius, cos_turn_angle, sin_turn_angle)
    center_position = get_pos_ccw(turn_center, norm_turn_vec, center_radius, cos_turn_angle, sin_turn_angle)
    outer_position = get_pos_ccw(turn_center, norm_turn_vec, outer_radius, cos_turn_angle, sin_turn_angle)
    return inner_position, center_position, outer_position

def apply_distance_no_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance):
    left_vec = normalize(left_position - center_position)
    forward_vec = np.array([left_vec[1], -left_vec[0]])
    distance = (left_distance + right_distance) * 0.5
    movement_vec = forward_vec * distance
    left_position += movement_vec
    center_position += movement_vec
    right_position += movement_vec
    return left_position, center_position, right_position

def apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance, epsilon):
    if abs(left_distance - right_distance) < epsilon:
        return apply_distance_no_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
    elif left_distance < right_distance:
        #return apply_distance_left_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
        left_position, center_position, right_position = apply_distance_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance, 1.0)
        return left_position, center_position, right_position
    else:
        #return apply_distance_right_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
        right_position, center_position, left_position = apply_distance_turn(vehicle_width, right_position, center_position, left_position, right_distance, left_distance, -1.0)
        return left_position, center_position, right_position
        
def get_final_position(vehicle_width, n, left_position, center_position, right_position, left_distance, right_distance):
    left_distance = 75.6 / n
    right_distance = 91.9 / n
    #left_distance = 91.9 / n
    #right_distance = 75.6 / n
    print(left_distance, right_distance)
    epsilon = 0.0001
    for i in range(n):
        left_position, center_position, right_position = apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance, epsilon)
        print('  positions', left_position, center_position, right_position)
        print('  norms', np.linalg.norm(left_position - center_position), np.linalg.norm(right_position - center_position), np.linalg.norm(left_position - right_position))
    return left_position, center_position, right_position

def original_test():
    vehicle_width = 62.0
    center_position = np.array([0.0, 0.0])
    left_position = np.array([center_position[0] - vehicle_width / 2, center_position[1]])
    right_position = np.array([center_position[0] + vehicle_width / 2, center_position[1]])

    #left_vec = left_position - center_position
    #norm_left_vec = left_vec / np.linalg.norm(left_vec)
    left_distance = 75.6
    right_distance = 91.9

    values = {}
    n = 1
    while n <= 512:
        values[n] = get_final_position(vehicle_width, n, left_position, center_position, right_position, left_distance, right_distance)
        n *= 2

    for n in sorted(values.keys()):
        print(n, values[n])
        
def rustler_test_01():
    epsilon = 0.00001
    vehicle_width = 0.265
    left_position = np.array([-0.1325, -0.0315])
    center_position = np.array([ 0.,     -0.0315])
    right_position = np.array([ 0.1325, -0.0315])
    left_distance = 0.01575
    right_distance = 0.0 
    left_position, center_position, right_position = apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance, epsilon)        

def rustler_test_02():
    epsilon = 0.00001
    vehicle_width = 0.265
    left_position = np.array([-0.1325, 0.0315])
    center_position = np.array([ 0.,   0.0315])
    right_position = np.array([ 0.1325,0.0315])
    left_distance = 0.0
    right_distance = 0.01575
    print(left_position, center_position, right_position)
    left_position, center_position, right_position = apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance, epsilon)        
    print(left_position, center_position, right_position)
    
if __name__ == '__main__':
    original_test()
    #rustler_test_02()