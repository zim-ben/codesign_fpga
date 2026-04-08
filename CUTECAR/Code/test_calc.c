#include <stdint.h>
#include <stdio.h>

#define POS_DATA2R (*(volatile uint32_t *)0x00000050u)
#define POS_DATA6R (*(volatile uint32_t *)0x00000090u)

int main(void)
{
    printf("read pos_data2r...\n");
    fflush(stdout);
    printf("pos_data2r = 0x%08X\n", (unsigned)POS_DATA2R);
    fflush(stdout);

    printf("read pos_data6r...\n");
    fflush(stdout);
    printf("pos_data6r = 0x%08X\n", (unsigned)POS_DATA6R);
    fflush(stdout);

    while (1) { }
}