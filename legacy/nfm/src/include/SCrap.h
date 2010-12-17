extern void init_rap();
extern char *start_record();
extern char *start_playback();
extern char *stop_record();
extern chtype getch_rap();

#define IMMEDIATE		1
#define REAL_TIME		2
#define SINGLE_STEP		3
