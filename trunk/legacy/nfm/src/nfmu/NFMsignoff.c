#include "machine.h"
#include "MEMstruct.h"

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMpurge_signoff (user_id, catalog, item, revision)
  long      user_id;
  char      *catalog;
  char      *item;
  char      *revision;
  {
    return (WFpurge_signoff (user_id, catalog, item, revision));
  }

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMquery_signoff_attributes (user_id, attr_list, data_list, value_list)
  long      user_id;
  MEMptr    *attr_list;
  MEMptr    *data_list;
  MEMptr    *value_list;
  {
    return (WFquery_signoff_attributes
        (user_id, attr_list, data_list, value_list));
  }

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMsignoff (user_id, attr_list, data_list)
  long      user_id;
  MEMptr    attr_list;
  MEMptr    data_list;
  {
    return (WFsignoff (user_id, attr_list, data_list));
  }
