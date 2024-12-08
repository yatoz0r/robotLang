#include "robot.h"
#include <math.h>

int validate_non_negative(float value)
{
    if (value < 0)
    {
        printf("Error: Negative value %.2f is not allowed.\n", value);
        return 0;
    }
    return 1;
}

robot_t *initialize_robot(int id)
{
    robot_t *robot = (robot_t *)malloc(sizeof(robot_t));
    if (robot == NULL)
    {
        printf("Error: Failed to allocate memory for robot.\n");
        return NULL;
    }

    robot->id = id;
    robot->status = ROBOT_STATUS_IDLE;
    robot->mode = CLEANING_MODE_NORMAL;
    robot->battery_level = 100.0;
    robot->speed = 0.0;
    robot->x_coord = 0.0;
    robot->y_coord = 0.0;
    robot->angle = 0.0;

    printf("Robot %d initialized.\n", id);
    return robot;
}

int move_forward(robot_t *robot, float distance)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    if (!validate_non_negative(distance))
        return 5;

    if (robot->speed == 0.0 && robot->status == ROBOT_STATUS_CLEANING)
    {
        set_speed_based_on_mode(robot);
    }

    float radians = robot->angle * (M_PI / 180.0);
    robot->x_coord += distance * cos(radians);
    robot->y_coord += distance * sin(radians);
    robot->battery_level -= distance * 0.1; 
    printf("Robot %d moving forward by %.2f meters.\n", robot->id, distance);
    return 0;
}

int move_backward(robot_t *robot, float distance)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    if (!validate_non_negative(distance))
        return 5;

    if (robot->speed == 0.0 && robot->status == ROBOT_STATUS_CLEANING)
    {
        set_speed_based_on_mode(robot);
    }

    float radians = robot->angle * (M_PI / 180.0);
    robot->x_coord -= distance * cos(radians);
    robot->y_coord -= distance * sin(radians);
    robot->battery_level -= distance * 0.1;
    printf("Robot %d moving backward by %.2f meters.\n", robot->id, distance);
    return 0;
}

int turn_left(robot_t *robot, float angle)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    if (!validate_non_negative(angle))
        return 5;

    robot->angle += angle;
    printf("Robot %d turning left by %.2f degrees. New angle: %.2f degrees.\n", robot->id, angle, robot->angle);
    return 0;
}

int turn_right(robot_t *robot, float angle)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    if (!validate_non_negative(angle))
        return 5;

    robot->angle -= angle;
    printf("Robot %d turning right by %.2f degrees. New angle: %.2f degrees.\n", robot->id, angle, robot->angle);
    return 0;
}

int start_cleaning(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    robot->status = ROBOT_STATUS_CLEANING;
    set_speed_based_on_mode(robot);
    printf("Robot %d started cleaning.\n", robot->id);
    return 0;
}

int stop_cleaning(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    robot->status = ROBOT_STATUS_IDLE;
    robot->speed = 0.0;
    printf("Robot %d stopped cleaning.\n", robot->id);
    return 0;
}

int return_to_base(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    robot->status = ROBOT_STATUS_RETURNING;
    robot->x_coord = 0.0;
    robot->y_coord = 0.0;
    printf("Robot %d returning to base.\n", robot->id);
    return 0;
}

int check_battery(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    printf("Robot %d battery level: %.2f%%\n", robot->id, robot->battery_level);
    return 0;
}

int report_status(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    printf("Robot %d status report:\n", robot->id);
    printf("1. Status: %s\n", robot->status == ROBOT_STATUS_IDLE ? "Idle" : (robot->status == ROBOT_STATUS_CLEANING ? "Cleaning" : (robot->status == ROBOT_STATUS_PAUSED ? "Paused" : "Returning")));
    printf("2. Cleaning Mode: %s\n", robot->mode == CLEANING_MODE_NORMAL ? "Normal" : (robot->mode == CLEANING_MODE_DEEP ? "Deep" : "Quick"));
    printf("3. Battery Level: %.2f%%\n", robot->battery_level);
    printf("4. Speed: %.2f m/s\n", robot->speed);
    printf("5. Coordinates: (%.2f, %.2f)\n", robot->x_coord, robot->y_coord);
    printf("6. Angle: %.2f degrees\n", robot->angle);
    return 0;
}

int pause(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    robot->status = ROBOT_STATUS_PAUSED;
    robot->speed = 0.0;
    printf("Robot %d paused.\n", robot->id);
    return 0;
}

int resume(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    robot->status = ROBOT_STATUS_CLEANING;
    set_speed_based_on_mode(robot);
    printf("Robot %d resumed.\n", robot->id);
    return 0;
}

int set_speed(robot_t *robot, float speed)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    if (!validate_non_negative(speed))
        return 5;

    robot->speed = speed;
    printf("Robot %d speed set to %.2f m/s.\n", robot->id, speed);
    return 0;
}

int set_cleaning_mode(robot_t *robot, cleaning_mode_t mode)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    robot->mode = mode;
    set_speed_based_on_mode(robot);
    printf("Robot %d cleaning mode set to %s.\n", robot->id, mode == CLEANING_MODE_NORMAL ? "Normal" : (mode == CLEANING_MODE_DEEP ? "Deep" : "Quick"));
    return 0;
}

void set_speed_based_on_mode(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return;
    }

    switch (robot->mode)
    {
        case CLEANING_MODE_NORMAL:
            robot->speed = 0.5;
            break;
        case CLEANING_MODE_DEEP:
            robot->speed = 0.3;
            break;
        case CLEANING_MODE_QUICK:
            robot->speed = 0.7; 
            break;
        default:
            robot->speed = 0.0;
            break;
    }
}

int detect_obstacle(robot_t *robot)
{
    if (robot == NULL)
    {
        printf("ERROR: Robot is NULL.\n");
        return 1;
    }

    printf("Robot %d detected an obstacle.\n", robot->id);
    return 0;
}
