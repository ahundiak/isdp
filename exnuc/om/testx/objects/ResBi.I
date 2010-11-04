class implementation ResB;

#include "OMobjectcomm.h"


method assign_b ( int num )
{
  ME.ResB -> bnum = num;
  printf (" >>> assign_b::  bnum set to %d\t <<<\n", ME.ResB -> bnum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}

method inc_b ()
{
  printf (" >>> inc_b::  bnum incremented to %d\t <<<\n", ++ME.ResB->bnum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}


method show_b ()
{
  printf (" >>> show_b::  bnum is %d\t <<<\n", ME.ResB->bnum );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return(OM_S_SUCCESS);
}

method add_one ( int *i; OM_S_OBJID *b_objid; )
{
  OM_S_MESSAGE connect_msg,ass_b;
  int          sts;
  struct connect_struct
        {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 uword                fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
        } connect_args;


  *i = (*i) + 1;

   sts = om$construct (osnum = OM_Gw_current_OS,		
		       object = (OM_p_OBJECTHDR) me,  p_objid = &b_objid[*i]);

/* sts = OM_construct_object_using_me ( OM_Gw_current_OS, me, &b_objid[*i],
			OM_GS_NULL_NEIGHBOR, 0, 0, 0 );
*/  
  if (!(1&sts))
  {
    printf(" error from om$construct in add_one : %x\n", sts);
    om$report_error(sts=sts);
    printf (" iteration %d \n", *i );
    exit();
  }

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = "bca";
	connect_args.to_idx = 0;
	connect_args.fr_objid = sender_id;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = "acb";
	connect_args.fr_idx            = 0;

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );


	sts = om$send (msg = &connect_msg,			
		       senderid = sender_id,			
		       targetid = b_objid[*i] );
 

/*sts = OM_connect_by_name ( "OM_TransOS_0", sender_id, "acb", 0, 0,
                             "OM_TransOS_0", b_objid[*i], "bca", 0, 0 );
*/  
  if (!(1&sts))
  {
    printf (" error from om$send connect in add_one : %x\n", sts);
    om$report_error(sts=sts);
    printf (" iteration %d \n", *i );
    exit();
  }

  printf("\nDumping relation after add_one connect number %d \n\n", *i+1 );

  sts = OMT_dump_relation ( OM_Gw_current_OS, sender_id, "acb" );
  if (!(sts&1))
  {
    printf (" error from OMT_dump_relation in add_one for ResB : %x \n", sts );
    om$report_error(sts=sts);
    exit();
  }

    sts = om$make_message (classname = "ResB", methodname = "assign_b",
			   size = 4, p_arglist = i, p_msg = &ass_b );

/*  sts = OM_make_message ( "ResB", "assign_b", 4, i, &ass_b );*/
  if (!(sts&1))
  {
    printf(" error from om$make_message in add_one (ass_b) : %x \n", sts );
    om$report_error(sts=sts);
    exit();
  }

  sts = om$send (mode = OM_e_wrt_object, msg = &ass_b,		
		 senderid = sender_id, targetid = b_objid[*i] );

/*sts = OM_send_object ( OM_e_wrt_object, ass_b, sender_id, b_objid[*i]);*/
  if (!(1&sts))
  {
    printf (" error from om$send msg=ass_b in add_one : %x\n", sts);
    om$report_error(sts=sts);
    printf (" iteration %d \n", *i );
    exit();
  }

  return (OM_S_SUCCESS);
}


method unknown (OM_S_MESSAGE *msg)
{
    printf( " --- in unkmsg ---\n");
    printf( "unknown message method index within class ResB is: ?\n");
    return(OM_S_SUCCESS);
}

end implementation ResB;
