class implementation C;

#include "OMminimum.h"
#include "OMerrordef.h"

method assign_c (int num)
{
  ME.C->num = num;
  printf (" >>> assign_c::  cnum set to %d\t <<<\n", ME.C->num );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return( OM_S_SUCCESS );
}

method show ()
{
  printf (" >>> show_c::  cnum is %d\t <<<\n", ME.C->num );
  printf ("\tMy_OS is %d\r\t\t\t\t Senders_OS is %d\n",
				 OM_Gw_current_OS, sender_os);
  printf ("\tMy_ID is %d\r\t\t\t\t Senders_ID is %d\n",
				 my_id, sender_id);
  return( OM_S_SUCCESS );
}

method make_connect ()
{
int	        status;
OM_S_OBJID      obj_id;
OM_S_MESSAGE    connect_msg;
struct connect_struct
      {
         OM_S_CHANSELECT      to_sel;
         int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 uword                fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
       } connect_args;
      
        printf (" >>> make_connect::  Class C <<<\n");
        printf ("\tSender_OS is %9d   Sender_ID is %d\n",
				 sender_os, sender_id);
        status = om$construct ( osnum = OM_Gw_current_OS,	
				classname = "C",		
				p_objid = &obj_id );

 	if( ! (status & 1) ) om$report_error(sts=status);
        else
         {
	  printf ("\t*** I've been constructed\n");
          printf ("\tMy_OS     is %9d   My_ID     is %d\n",
				 OM_Gw_current_OS, obj_id);

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = "scb";
	connect_args.to_idx = 0;
	connect_args.fr_objid = sender_id;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = "bcs";
	connect_args.fr_idx            = 0;

	status = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );


	status = om$send (msg = &connect_msg,
		       senderid = sender_id,
		       targetid = obj_id );

          if( ! (status & 1) ) om$report_error(sts=status);
          else
           {  
            printf ("\t*** I've been connected to sender\n");
	    status=OM_S_SUCCESS;
           }
         }
	return( status );
}

end implementation C;
