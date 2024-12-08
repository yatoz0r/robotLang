#ifndef ROBOT_H
#define ROBOT_H

#include <stdio.h>
#include <stdlib.h>

typedef enum _robot_status
{
    ROBOT_STATUS_IDLE,
    ROBOT_STATUS_CLEANING,
    ROBOT_STATUS_PAUSED,
    ROBOT_STATUS_RETURNING,
} robot_status_t;

typedef enum _cleaning_mode
{
    CLEANING_MODE_NORMAL,
    CLEANING_MODE_DEEP,
    CLEANING_MODE_QUICK,
} cleaning_mode_t;

typedef struct _robot
{
    int id;
    robot_status_t status;
    cleaning_mode_t mode;
    float battery_level;
    float speed;
    float x_coord;
    float y_coord;
    float angle;
} robot_t;

robot_t *initialize_robot(int id);
int move_forward(robot_t *robot, float distance);
int move_backward(robot_t *robot, float distance);
int turn_left(robot_t *robot, float angle);
int turn_right(robot_t *robot, float angle);
int start_cleaning(robot_t *robot);
int stop_cleaning(robot_t *robot);
int return_to_base(robot_t *robot);
int check_battery(robot_t *robot);
int report_status(robot_t *robot);
int pause(robot_t *robot);
int resume(robot_t *robot);
int set_speed(robot_t *robot, float speed);
int set_cleaning_mode(robot_t *robot, cleaning_mode_t mode);
void set_speed_based_on_mode(robot_t *robot);
int detect_obstacle(robot_t *robot);

#endif // ROBOT_H
