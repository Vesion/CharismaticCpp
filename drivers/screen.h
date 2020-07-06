#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
#define SCREEN_SIZE (MAX_ROWS * MAX_COLS)
#define VIDEO_MEMORY_SIZE (2 * SCREEN_SIZE)
#define WHITE_ON_BLACK 0x0f
#define RED_ON_WHITE 0xf4

/* Screen i/o ports */
#define REG_SCREEN_CTRL 0x3d4
#define REG_SCREEN_DATA 0x3d5

/* Public kernel API */
void clear_row(int row);
void clear_screen();
void kprint_at(const char* message, int row, int col);
void kprint(const char* message);

