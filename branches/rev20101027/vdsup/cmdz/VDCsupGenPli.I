class implementation VDCzupGenPl;

#define  AS_DEBUG 1

from	ACrg_collect    import AClist_attribute;
from	ACncpx		import ACget_rep, ACget_NV_rep, ACset_NV_rep;

extern  DB_debug();           /* Function to print debug		      */
extern	ASstart_fence(), ASend_fence();
extern  NDexec_batch();       /* Function to execute the batch queue          */
extern  ACcreate_possible_rep_col(); /* Fn to find/create representation      */

extern VDsupDispObj();

method hello ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  printf("Hello\n");
  status = OM_S_SUCCESS;
  goto quit;
quit:
  return OM_S_SUCCESS;
}

/*
method get_initFlag ( long * sts )
{
  *sts = me->initFlag;
  return OM_S_SUCCESS;
}
*/

method init ( int type ; char * str_ptr )
{
  int status;

  status = om$send( 
    msg  = message VDCzupGen.init(type,str_ptr),
    mode = OM_e_wrt_message,
    targetid = my_id
  );
  as$status( action = RET_STATUS );

/*  me->initFlag = 1;

  if (me->ClearFlag) {
    printf("### Clear Me!!!\n");
  }
  me->ClearFlag = 0;
*/

  return OM_S_SUCCESS;
}

method sleep (int pos)
{
  int status;

  status = om$send( 
    msg  = message CEO_LOCATE.sleep(pos),
    mode = OM_e_wrt_message,
    targetid = my_id
  );
  as$status( action = RET_STATUS );

  me->sleepFlag = 1;

  return OM_S_SUCCESS;
}
method wakeup (int pos)
{
  int status;

  status = om$send( 
    msg  = message CEO_LOCATE.wakeup(pos),
    mode = OM_e_wrt_message,
    targetid = my_id
  );
  as$status( action = RET_STATUS );

  me->sleepFlag = 0;

  return OM_S_SUCCESS;
}

end implementation VDCzupGenPl;
