#include <stdio.h>
#include "OMobjectcomm.h"
#include "OMindex.h"

extern OM_p_RTREE_OP OM_GA_rtree_ops;
extern int  OM_Gi_ops_head, OM_Gi_ops_tail;
extern int  OM_Gi_ops_count, OM_Gi_record_ops;


som_rtree_ops_init(count)

int count;

{
if (count <= 0)	
  {
  printf("count has to be >= 1 \n");
  }
if ( !(OM_GA_rtree_ops = (OM_p_RTREE_OP)
      om$malloc(size = count * sizeof(OM_S_RTREE_OP))) )
  {
  return(OM_E_NODYNMEM);
  }

OM_Gi_ops_count = count;
OM_Gi_record_ops = TRUE;
OM_Gi_ops_head = -1;
OM_Gi_ops_tail = -1;

return(OM_S_SUCCESS);
}



som_rtree_ops_flag(doit_or_not)

int doit_or_not;

{
OM_Gi_record_ops = doit_or_not;	
return(OM_S_SUCCESS);
}


som_rtree_get_op(rtree_op_pp)

OM_S_RTREE_OP **rtree_op_pp;

{
if (OM_Gi_ops_head == -1)
  {
  *rtree_op_pp = NULL;
  return(OM_S_SUCCESS);
  }

*rtree_op_pp = &OM_GA_rtree_ops[OM_Gi_ops_head];

if (OM_Gi_ops_tail == OM_Gi_ops_head)
  {
  OM_Gi_ops_head = -1;
  OM_Gi_ops_tail = -1;
  }
else if (OM_Gi_ops_head == OM_Gi_ops_count - 1)
       {
       OM_Gi_ops_head = 0;
       }
     else
       {
       ++OM_Gi_ops_head;
       }

return(OM_S_SUCCESS);
}


DB_rtree_put_op(objid, op_code, osnum)

OM_S_OBJID  objid;
unsigned char op_code;
OMuword     osnum;

{
if (OM_Gi_ops_head == -1)
  {
  OM_Gi_ops_head = OM_Gi_ops_tail = 0;
  OM_GA_rtree_ops[OM_Gi_ops_tail].objid = objid;
  OM_GA_rtree_ops[OM_Gi_ops_tail].op_code = op_code;
  OM_GA_rtree_ops[OM_Gi_ops_tail].osnum = osnum;
  }
else
  {
  if (OM_Gi_ops_tail == OM_Gi_ops_count - 1)
    {
    OM_Gi_ops_tail = 0;
    }
  else
    {
    ++OM_Gi_ops_tail;
    }
  OM_GA_rtree_ops[OM_Gi_ops_tail].objid = objid;
  OM_GA_rtree_ops[OM_Gi_ops_tail].op_code = op_code;
  OM_GA_rtree_ops[OM_Gi_ops_tail].osnum = osnum;
  if (OM_Gi_ops_head == OM_Gi_ops_tail)
    {
    if (OM_Gi_ops_head == OM_Gi_ops_count - 1)
      OM_Gi_ops_head = 0;
    else
      ++OM_Gi_ops_head;
    }
  }

return(OM_S_SUCCESS);
}
