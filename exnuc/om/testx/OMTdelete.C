#include "OMobjectcomm.h"

/* ===================================================
 *
 *   sts = som_make_message ( ( "A" ) , ( ( ( OMuword ) - 1 ) ) , ( "delete" ) , ( 0 ) , ( ( void * ) 0 ) , ( & a_msg_delete ) )

 *   sts = som_send_object ( ( OM_e_wrt_object ) , ( & a_msg_delete ) , ( a_objid ) , ( a_objid ) , ( NULL_CHANNUM ) )

       sts = f ( msg , saved_senderOS , senderid , targetid , rip . p_mapentry ,
                channum , p_ACLD ) ;
 *
int Root_Root_delete_method(OPPmargs,sender_os,sender_id,my_id,p_spacemap,in_channel,p_ACLD)
 OM_p_CLASSDEF p_ACLD;
 OM_S_CHANNUM in_channel;
 unsigned sender_os;
 OM_S_OBJID sender_id, my_id;
 OM_p_SPAMAPENT p_spacemap;
 OM_S_MESSAGE *OPPmargs;
 {
 char *opp_pargs = OPPmargs->p_arglist; Which is NULL
 flag = *(opp_the_type *)opp_pargs;

 */
/*
 * for (ii=OM_Gw_next_class_index-1; ii >= 0 ; ii--)
   {
     if (NULL != (p_testcld = OM_GA_active_classes[ii]))
*/

static void die(char *msg)
{
  printf("*** DIE %s\n",msg);
  exit(1);
}
int main(int argc, char *argv[])
{
  int sts;
  typedef struct { int flag; } TRootDelete;

  OM_S_OBJID    a_objid;
  OM_S_MESSAGE  a_msg_delete;
  TRootDelete   a_arg_delete;
  

  sts = om$runtime_init();
  if (!(sts&1)) die("runtime_init failed");

  sts = om$make_message(classname  = "A",
                        methodname = "delete",
                        size = sizeof(TRootDelete),
                        p_arglist = &a_arg_delete,
                        p_msg     = &a_msg_delete);
  if (!(sts&1)) die("Create A.delete message failed");

  sts = om$construct(osname    = "OM_TransOS_0",
                     classname = "A",
                     p_objid   = &a_objid,
                     neighbor  = OM_GS_NULL_NEIGHBOR);
                     // msg = &ass_a );
  if (!(sts&1)) die("Constructing A failed");

  a_arg_delete.flag = 0;
  sts = om$send(mode = OM_e_wrt_object,
                msg  = &a_msg_delete,
                senderid = a_objid,
                targetid = a_objid );
  if (!(sts&1)) die("Deleting A");
  
  return 0;
}