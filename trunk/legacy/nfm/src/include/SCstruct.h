#ifndef SC_STRUCT
#define SC_STRUCT
#if (defined OS_SUNOS) /* MSSP */
#include "/usr/5include/curses.h"  /* Added by SSRS - 19/10/93 */
#else
#include <curses.h>
#endif
#include "NFMdef.h"
#include "SCdef.h"
#include "SCdata.h"

struct SCatofn_st
  {
    char *name;
    NFMfunction (*fn_ptr)();
  };

struct SCfunc_st
  {
    char *func_string;
    char *func_symb;
    char *func_name;
    struct SCfunc_st *left_scroll;
    struct SCfunc_st *parent,*parent_first_func;
    struct SCfunc_st *prev,*next;
    struct SCfunc_st *child;
  };

struct SCcolumn_st
  {
    WINDOW *win;			/* window id */
    struct SCcolumn_data_st *data;	/* data passed to forms controller */
    int data_count;			/* number of elements in data array */
    int row_offset;			/* row offset for scrolling */
    int max_row_offset;			/* maximum row offset for scrolling */
    int first_pos;
    int last_pos;
    int cur_pos;
  };

struct SCconfig_st
  {
    char *config_msg;
    char *config_sym;
    struct SCconfig_st *next;
  };

#endif
