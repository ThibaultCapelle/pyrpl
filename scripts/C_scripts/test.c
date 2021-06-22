// build with:
// gcc -Wall -g -O2 -c test.c -o test.o
// gcc -Wall -g -O2 -o test test.o

#include <stdint.h>
#include <stdio.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>

#define XPS_SCU_PERIPH_BASE		0xF8F00000U
#define XPAR_GLOBAL_TMR_BASEADDR	(XPS_SCU_PERIPH_BASE + 0x00000200U)

#define GLOBAL_TMR_BASEADDR               (XPAR_GLOBAL_TMR_BASEADDR-0x200U)
#define GTIMER_COUNTER_LOWER_OFFSET       (0x00U+0x200U)
#define GTIMER_COUNTER_UPPER_OFFSET       (0x04U+0x200U)
#define GTIMER_CONTROL_OFFSET             (0x08U+0x200U)

#define PAGE_SIZE ((size_t)getpagesize())
#define PAGE_MASK ((uint64_t)(long)~(PAGE_SIZE - 1))

int
main(int argc, char *argv[])
{
  int TIMER_FD = open("/dev/mem", O_RDWR|O_SYNC);
  if (TIMER_FD < 0) {
      fprintf(stderr, "open(/dev/mem) failed (%d)\n", errno);
      return 1;
  }

  volatile uint8_t* TIMER_MMAP;
  TIMER_MMAP = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
                    TIMER_FD, GLOBAL_TMR_BASEADDR);
  if (TIMER_MMAP == MAP_FAILED) {
      fprintf(stderr, "mmap64(0x%x@0x%x) failed (%d)\n",
              PAGE_SIZE, (uint32_t)(XPAR_GLOBAL_TMR_BASEADDR), errno);
      return 1;
  }

  // Disable Global Timer
  *(volatile uint32_t *)(TIMER_MMAP+GTIMER_CONTROL_OFFSET) = 0x00;

  // Set Global Timer Counter Register to zero
  // Comment out this lines and the system no longer hangs.
  //*(volatile uint32_t *)(TIMER_MMAP+GTIMER_COUNTER_LOWER_OFFSET) = (uint32_t)0;
  //*(volatile uint32_t *)(TIMER_MMAP+GTIMER_COUNTER_UPPER_OFFSET) = (uint32_t)0;

  // Re-enable Global Timer
  *(volatile uint32_t *)(TIMER_MMAP+GTIMER_CONTROL_OFFSET) = (uint32_t)0x1;
  return 0;
}