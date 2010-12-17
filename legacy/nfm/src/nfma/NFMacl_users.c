#include "machine.h"
#include "MEMstruct.h"

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMquery_acl_class_users
(user_id, acl_name, attr_list, data_list, value_list)
  long      user_id;
  char      *acl_name;
  MEMptr    *attr_list;
  MEMptr    *data_list;
  MEMptr    *value_list;
  {
    return (WFquery_acl_class_users
        (user_id, acl_name, attr_list, data_list, value_list));
  }

/*  Function is simply a wrapper so as to eliminate
    prototype include file dependencies - Glenn Scott 2/26/92  */

long NFMupdate_acl_class_users (user_id, attr_list, data_list)
  long      user_id;
  MEMptr    attr_list;
  MEMptr    data_list;
  {
    return (WFupdate_acl_class_users (user_id, attr_list, data_list));
  }
