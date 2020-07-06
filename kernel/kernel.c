#include "common/utils.h"
#include "drivers/screen.h"

void main() {
  clear_screen();

  char buf[255];
  for (int i = 0; i < 1000; ++i) {
    int_to_ascii(i, buf);
    kprint(buf);
    kprint("\n");
  }
}
