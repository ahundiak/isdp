#include "machine.h"
#include "MEMstruct.h"

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMquery_make_transition (user_id, attr_list, data_list)
  long     user_id;
  MEMptr   *attr_list;
  MEMptr   *data_list;
  {
    return (WFquery_make_transition (user_id, attr_list, data_list));
  }

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMmake_transition (user_id, attr_list, data_list)
  long     user_id;
  MEMptr   attr_list;
  MEMptr   data_list; 
  {
    return (WFmake_transition (user_id, attr_list, data_list));
  }
