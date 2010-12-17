#define JNL_INFO_EVENT    0x7fffffff

#define JNL_WINDOW_CHANGE          1
#define JNL_CHAR                   2
#define JNL_TIMER_NO               3

/*  Maximum chararacter to be stored on INFO_EVENT  */

#define JNL_MAX_CHAR             256

struct echo_button
  {
    int    window;
    int    x, y;
    int    btype;
    int    state;
    int    timetag;
  };

struct echo_collapse_button
  {
    int    window;
    int    opmask;
  };

struct echo_delete_button
  {
    int    window;
  };

struct echo_refresh_button
  {
    int    window;
    int    vs_no;
    int    x, y;
    int    x2, y2;
    int    ax1, ay1;
    int    ax2, ay2;
    int    opmask;
  };

struct jnl_timers
  {
    int    used;
    int    current;
    int    previous;
  };
