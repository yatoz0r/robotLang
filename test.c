#include "robot.h"

int main(int argc, char const *argv[])
{
	robot_t *R5 = initialize_robot(5);
	move_forward(R5, 2.50);
	turn_left(R5, 90.00);
	start_cleaning(R5);
	move_forward(R5, 3.00);
	check_battery(R5);
	report_status(R5);
	return_to_base(R5);
	return 0;
}
