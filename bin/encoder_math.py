import numpy as np

def get_turn_radius(w, a, b): 
    return np.abs(w * (a + b) / (b - a))

def normalize(v):
    return v / np.linalg.norm(v)

def get_position(turn_center, norm_turn_vec, radius, cos_turn_angle, sin_turn_angle):
    perp_turn_vec = np.array([-norm_turn_vec[1], norm_turn_vec[0]])
    return turn_center + norm_turn_vec * radius * cos_turn_angle + perp_turn_vec * radius * sin_turn_angle

def apply_distance_turn(half_vehicle_width, inner_position, center_position, outer_position, inner_distance, outer_distance, direction):
    center_radius = get_turn_radius(half_vehicle_width, inner_distance, outer_distance)
    outer_radius = center_radius + half_vehicle_width
    inner_radius = center_radius - half_vehicle_width
    turn_center = center_position + normalize(inner_position - center_position) * center_radius
    turn_vec = center_position - turn_center
    norm_turn_vec = normalize(turn_vec)
    turn_angle = direction * outer_distance / outer_radius
    cos_turn_angle = np.cos(turn_angle)
    sin_turn_angle = np.sin(turn_angle)
    inner_position = get_position(turn_center, norm_turn_vec, inner_radius, cos_turn_angle, sin_turn_angle)
    center_position = get_position(turn_center, norm_turn_vec, center_radius, cos_turn_angle, sin_turn_angle)
    outer_position = get_position(turn_center, norm_turn_vec, outer_radius, cos_turn_angle, sin_turn_angle)
    return inner_position, center_position, outer_position

def apply_distance_no_turn(left_position, center_position, right_position, left_distance, right_distance):
    left_vec = normalize(left_position - center_position)
    forward_vec = np.array([left_vec[1], -left_vec[0]])
    distance = (left_distance + right_distance) * 0.5
    movement_vec = forward_vec * distance
    left_position += movement_vec
    center_position += movement_vec
    right_position += movement_vec
    return left_position, center_position, right_position

def apply_distance(half_vehicle_width, left_position, center_position, right_position, left_distance, right_distance):
    if left_distance == right_distance:
        return apply_distance_no_turn(left_position, center_position, right_position, left_distance, right_distance)
    elif left_distance < right_distance:
        left_position, center_position, right_position = apply_distance_turn(half_vehicle_width, left_position, center_position, right_position, left_distance, right_distance, 1.0)
        return left_position, center_position, right_position
    else:
        right_position, center_position, left_position = apply_distance_turn(half_vehicle_width, right_position, center_position, left_position, right_distance, left_distance, -1.0)
        return left_position, center_position, right_position

def get_final_position(half_vehicle_width, n, left_position, center_position, right_position, left_distance, right_distance):
    left_distance = 75.6 / n
    right_distance = 91.9 / n
    print(left_distance, right_distance)
    for i in range(n):
        left_position, center_position, right_position = apply_distance(half_vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
    return left_position, center_position, right_position

def original_test():
    vehicle_width = 62.0
    half_vehicle_width = vehicle_width / 2.0
    center_position = np.array([0.0, 0.0])
    left_position = np.array([center_position[0] - vehicle_width / 2, center_position[1]])
    right_position = np.array([center_position[0] + vehicle_width / 2, center_position[1]])
    left_distance = 75.6
    right_distance = 91.9
    values = {}
    n = 1
    while n <= 512:
        values[n] = get_final_position(half_vehicle_width, n, left_position, center_position, right_position, left_distance, right_distance)
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
    left_position, center_position, right_position = apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)

def rustler_test_02():
    epsilon = 0.00001
    vehicle_width = 0.265
    left_position = np.array([-0.1325, 0.0315])
    center_position = np.array([ 0.,   0.0315])
    right_position = np.array([ 0.1325,0.0315])
    left_distance = 0.0
    right_distance = 0.01575
    print(left_position, center_position, right_position)
    left_position, center_position, right_position = apply_distance(vehicle_width, left_position, center_position, right_position, left_distance, right_distance)
    print(left_position, center_position, right_position)

if __name__ == '__main__':
    original_test()
