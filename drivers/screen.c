#include "common/memory.h"
#include "drivers/screen.h"
#include "drivers/port.h"

// private utils declaration
int get_cursor_offset();
void set_cursor_offset(int offset);
int print_char(char c, int row, int col, int attr);
int get_offset(int row, int col);
int get_offset_row(int offset);
int get_offset_col(int offset);

// public APIS definition
void clear_row(int row) {
  int offset = 0;
  if (row < 0 || row >= MAX_ROWS) {
    offset = get_cursor_offset();
  } else {
    offset = get_offset(row, 0);
  }

  char* vidmem = (char*)VIDEO_ADDRESS;
  for (int i = 0; i < MAX_COLS; ++i) {
    vidmem[offset+i*2] = 0;
    vidmem[offset+i*2+1] = WHITE_ON_BLACK;
  }
  set_cursor_offset(offset);
}

void clear_screen() {
  int i = 0;
  char* vidmem = (char*)VIDEO_ADDRESS;

  for (i = 0; i < SCREEN_SIZE; ++i) {
    vidmem[i*2] = 0;
    vidmem[i*2+1] = WHITE_ON_BLACK;
  }
  set_cursor_offset(0);
}

void kprint_at(const char* message, int row, int col) {
  for (int offset = 0; *message != 0; ++message) {
    offset = print_char(*message, row, col, WHITE_ON_BLACK);
    row = get_offset_row(offset);
    col = get_offset_col(offset);
  }
}

void kprint(const char* message) {
  kprint_at(message, -1, -1);
}

// private utils definition
int get_cursor_offset() {
  port_byte_out(REG_SCREEN_CTRL, 14);
  int offset = port_byte_in(REG_SCREEN_DATA) << 8;
  port_byte_out(REG_SCREEN_CTRL, 15);
  offset += port_byte_in(REG_SCREEN_DATA);
  return offset * 2;
}

void set_cursor_offset(int offset) {
  offset /= 2;
  port_byte_out(REG_SCREEN_CTRL, 14);
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
  port_byte_out(REG_SCREEN_CTRL, 15);
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

// print a 'char' at offset row:col
// if either 'row' or 'col' is out of range, will print at current cursor
// if 'attr' is zero, will use WHITE_ON_BLACK as default
// returns the offset of the next character
// sets the cursor to the returned offset
int print_char(char c, int row, int col, int attr) {
  char* vidmem = (char*)VIDEO_ADDRESS;
  if (!attr) {
    attr = WHITE_ON_BLACK;
  }

  int offset = 0;
  if (row < 0 || row >= MAX_ROWS ||
      col < 0 || col >= MAX_COLS) {
    offset = get_cursor_offset();
  } else {
    offset = get_offset(row, col);
  }

  if (c == '\n') {
    row = get_offset_row(offset);
    offset = get_offset(row+1, 0);
  } else {
    vidmem[offset] = c;
    vidmem[offset+1] = attr;
    offset += 2;
  }

  if (offset < VIDEO_MEMORY_SIZE) {
    set_cursor_offset(offset);
    return offset;
  }

  for (int i = 1; i < MAX_ROWS; ++i) {
    memory_copy_n((const char*)VIDEO_ADDRESS + get_offset(i, 0),
                  (char*)VIDEO_ADDRESS + get_offset(i-1, 0),
                  MAX_COLS * 2);
  }
  clear_row(MAX_ROWS-1);
  return get_cursor_offset();
}

int get_offset(int row, int col) {
  return 2 * (row * MAX_COLS + col);
}

int get_offset_row(int offset) {
  return offset / (2 * MAX_COLS);
}

int get_offset_col(int offset) {
  return (offset - (get_offset_row(offset) * 2 * MAX_COLS)) / 2;
}

