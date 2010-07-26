#define CHAR_STACK_LEN 20


struct char_data
 {
  int ch;
  char *filename;
  int line_no;
  int pol;
 };


struct char_stack
 {
  struct char_data chars[CHAR_STACK_LEN];
  struct char_stack *next;
  int stack_posit;
 };


extern void push_char ();
extern void push_string ();
extern struct char_data pop_char ();
extern void char_stack_end ();
extern void close_char_stack ();
extern void dump_stack ();
