#define JNL_INFO_EVENT    0x7fffffff


#define JNL_WINDOW_CHANGE   1
#define JNL_CHAR            2
#define JNL_TIMER_NO        3
#define JNL_BUTTON_COUNT    4
#define JNL_PENDING_EVENTS  5
#define JNL_BINARY          6
#define JNL_STOPSIGN        7
#define JNL_MAX_CHAR      256  /*max char to be stored on INFO_EVENT*/

 struct echo_button
 {
    int window;
    int x;
    int y;
    int btype;
    int state;
    int timetag;
 };


 struct echo_collapse_button
 {
    int window;
    int opmask;
 };

 struct echo_delete_button
 {
    int window;
 };

 struct echo_refresh_button
 {
    int window;
    int vs_no;
    int x;
    int y;
    int x2;
    int y2;
    int ax1;
    int ay1;
    int ax2;
    int ay2;
    int opmask;
 };

struct jnl_timers
{
    int used;
    int current;
    int previous;
};
