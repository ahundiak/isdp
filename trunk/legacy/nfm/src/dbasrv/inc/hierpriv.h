/* $Revision: 1.1 $ */
#ifndef _HIERPRIV_H_
#define _HIERPRIV_H_

typedef struct HierRowData {
    char *text;
    char *open_icon;
    char *close_icon;
    int open_index;
    int close_index;
    short indent;
    BOOL expand, state;
  } HierRowData;

typedef struct HierarchyData {
    HierRowData *data;
    char *open_icon;
    char *close_icon;
    char *script;
    int open_index;
    int close_index;
    int num;
    int num_alloc;
    int attr;
    int select;
    int event_row;
    char event_type;
    char separator;
  } HierarchyData;

#endif
