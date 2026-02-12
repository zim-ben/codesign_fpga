#include <stdint.h>
#include <stdbool.h>

#define SWITCHES     ((volatile uint8_t  *)0x0003000u)
#define LEDS         ((volatile uint8_t  *)0x0003010u)
#define WRITEDATA_L  ((volatile uint32_t *)0x00000030u)
#define WRITEDATA_R  ((volatile uint32_t *)0x00000020u)

bool go_r = true, dir_r = true;
uint16_t duty_cycle_r = 2150;

bool go_l = false, dir_l = true;
uint16_t duty_cycle_l = 2190;

int main(void)
{
	while (1)
	{
		uint32_t cmd = 0;

		cmd  = ((uint32_t)(go_l ? 1u : 0u) << 13);
		cmd |= ((uint32_t)(dir_l ? 1u : 0u) << 12);
		cmd |= ((uint32_t)(duty_cycle_l & 0x0FFFu));   /* 12-bit duty */
		*WRITEDATA_L = cmd;

		/* RIGHT : [13]=GO, [12]=DIR, [11:0]=DUTY */
		cmd  = ((uint32_t)(go_r ? 1u : 0u) << 13);
		cmd |= ((uint32_t)(dir_r ? 1u : 0u) << 12);
		cmd |= ((uint32_t)(duty_cycle_r & 0x0FFFu));   /* 12-bit duty */
		*WRITEDATA_R = cmd;
	}
}
