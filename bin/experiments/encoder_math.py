import numpy as np

def get_turn_radius(w, a, b): 
    return np.abs(w / 2 * (a + b) / (b - a))

def normalize(v):
    return v / np.linalg.norm(v)

def orthogonal_vec(v):
    return np.array([v[1], v[0]])

def get_position(center, cos_angle, sin_angle, radius):
    return np.array([center[0] + cos_angle * radius, center[1] + sin_angle * radius])

def apply_distance_left_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance):
    print('left turn')
    center_radius = get_turn_radius(vehicle_width, left_distance, right_distance)
    left_radius = center_radius - (vehicle_width / 2.0)
    right_radius = center_radius + (vehicle_width / 2.0)
    print('radius', left_radius, center_radius, right_radius)
    turn_center = center_position + normalize(left_position - center_position) * center_radius
    turn_vec = center_position - turn_center
    norm_turn_vec = normalize(turn_vec)
    turn_center_right_vec = np.array([turn_center[0] + center_radius, turn_center[1]]) - turn_center
    norm_turn_center_right_vec = normalize(turn_center_right_vec)
    print(turn_center, turn_vec, turn_center_right_vec)
    turn_angle_deg = 180.0 * right_distance / (np.pi * right_radius)
    turn_angle = np.deg2rad(turn_angle_deg)
    base_angle = np.arccos(np.dot(norm_turn_vec, norm_turn_center_right_vec))
    full_angle = turn_angle + base_angle
    print(turn_angle_deg, turn_angle, base_angle, full_angle)
    cos_full_angle = np.cos(full_angle)
    sin_full_angle = np.sin(full_angle)
    left_position = get_position(turn_center, cos_full_angle, sin_full_angle, left_radius)
    center_position = get_position(turn_center, cos_full_angle, sin_full_angle, center_radius)
    right_position = get_position(turn_center, cos_full_angle, sin_full_angle, right_radius)
    return left_position, center_position, right_position

def apply_distance_right_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance):
    print('right turn')
    print(left_distance, right_distance)
    center_radius = get_turn_radius(vehicle_width, left_distance, right_distance)
    left_radius = center_radius + (vehicle_width / 2.0)
    right_radius = center_radius - (vehicle_width / 2.0)
    print('radius', left_radius, center_radius, right_radius)
    turn_center = center_position + normalize(right_position - center_position) * center_radius
    turn_vec = center_position - turn_center
    norm_turn_vec = normalize(turn_vec)
    turn_center_left_vec = np.array([turn_center[0] - center_radius, turn_center[1]]) - turn_center
    norm_turn_center_left_vec = normalize(turn_center_left_vec)
    print(turn_center, turn_vec, turn_center_left_vec)
    turn_angle_deg = 180.0 * left_distance / (np.pi * left_radius)
    turn_angle = np.deg2rad(turn_angle_deg)
    base_angle = np.arccos(np.dot(norm_turn_vec, norm_turn_center_left_vec))
    full_angle = turn_angle + base_angle
    print(np.degrees(turn_angle), np.degrees(base_angle), np.degrees(full_angle))
    cos_full_angle = np.cos(full_angle)
    sin_full_angle = np.sin(full_angle)
    left_position = get_position(turn_center, cos_full_angle, sin_full_angle, left_radius)
    center_position = get_position(turn_center, cos_full_angle, sin_full_angle, center_radius)
    right_position = get_position(turn_center, cos_full_angle, sin_full_angle, right_radius)
    return left_position, center_position, right_position

def apply_distance_no_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance):
    print('no turn')
    left_vec = normalize(left_position - center_position)
    forward_vec = np.array([left_vec[1], -left_vec[0]])
    distance = (left_distance + right_distance) * 0.5
    movement_vec = forward_vec * distance
    left_position += movement_vec
    center_position += movement_vec
    right_position += movement_vec
    print(distance, movement_vec, left_position, center_position, right_position)
    return left_position, center_position, right_position

def apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance, epsilon):
    if abs(left_distance - right_distance) < epsilon:
        return apply_distance_no_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
    elif left_distance < right_distance:
        return apply_distance_left_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
    else:
        return apply_distance_right_turn(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
        
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
    left_distance = 0.01575
    right_distance = 0.0
    print(left_position, center_position, right_position)
    left_position, center_position, right_position = apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance, epsilon)        
    print(left_position, center_position, right_position)
    
if __name__ == '__main__':
    #original_test()
    rustler_test_02()