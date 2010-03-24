#include "OMobjectcomm.h"
#define MAXB 5
#define MAXA 5


main()
{
   int              osnumr,sts, i, relndx;
   OM_S_OBJID       a_objid[MAXA], b_objid[MAXB], my_objid,
		    resa_objid[MAXA], resb_objid[MAXB];
   OM_S_MESSAGE	    disconnect_msg,connect_msg,shob, shoa, shoresb, shoresa;
   OMuword          a_classid, b_classid;
   OM_S_CHANNUM     chan_a, chan_b, chan_resa, chan_resb;
   OM_S_CHANSELECT  chansel;

struct connect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 uword                fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
       } connect_args;
struct disconnect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 OM_S_OBJID	      fr_objid;
	 OMuword              fr_os;
	 OM_S_CHANSELECT      fr_sel;
       } disconnect_args;


   sts = om$runtime_init();
   if (!(sts&1))
   {
      printf (" error in om$runtine_init\n");
      om$report_error(sts = sts);
      exit();
   }

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct(osnum = OM_Gw_current_OS,
                         classname = "A",
                         p_objid = &a_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for A : %x \n", sts );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }
   printf("created %d A objids \n", MAXA);
   
   sts = om$get_channel_number(channame = "A.acb",
                               p_channum = &chan_a );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for A.acb : %x \n", sts );
      om$report_error(sts = sts);
      exit();
   }

   sts = om$get_channel_number(channame = "B.bca",
                               p_channum = &chan_b );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for B.bca : %x \n", sts );
      om$report_error(sts = sts);
      exit();
   }


   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct(osnum = OM_Gw_current_OS,
                         classname = "B",
                         p_objid = &b_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for B : %x \n", sts );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */
   printf("created %d B objids \n", MAXB);

/* Singleton:Singleton Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[0] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) for B \n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected s:s \n");

      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

      printf ("\n----- Dumping channel info for B[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
	sts = om$make_message(classname = "B",
                              methodname = "show_b",
                              p_msg = &shob);
	if(!(sts&1))
	{
	    printf("error in om$make_message for show_b\n");
	    om$report_error(sts = sts);
	    exit();
	}
        chansel.type = OM_e_name;
        chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}

     
/* Connect A[0] to B[1]:  Dipole:Singleton */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = "bca";
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = "acb";
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[1] );
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A0 connected to B1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("B1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (connect) for A0 to B1\n");
         om$report_error(sts = sts);
   }
      printf("connected d:s \n");
      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

      printf ("\n----- Dumping channel info for B[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}
 

/* Disconnect B1 from A[0]:  case 2 f:t */

     disconnect_args.to_sel.type = OM_e_num;
     disconnect_args.to_sel.u_sel.number = chan_a;
     disconnect_args.fr_sel.type = OM_e_num;
     disconnect_args.fr_sel.u_sel.number = chan_b;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = b_objid[1];

	sts = om$make_message(classname = "Root",		
			      methodname = "disconnect",		
			      size = sizeof( struct disconnect_struct),
			      p_arglist = &disconnect_args,	
			      p_msg = &disconnect_msg );

	sts = om$send (msg = &disconnect_msg,			
		       senderid = b_objid[1],			
		       targetid = a_objid[0] );
   switch(sts)
   {
      case OM_S_SUCCESS:  printf("B[1] disconnected from A[0] \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("No connection existed \n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B[1] was not connected to A[0]\n");
      			    break;
      default:  printf("Error in om$send (disconnect) of A0,B1\n");
      	        om$report_error(sts = sts);
   }
      printf("disconnected case 2 [f:t] \n");
      printf ("\n----- Dumping channel info for B[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel );
       
	if(!(sts&1))
	{
	    printf("error in om$send ot A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}
 
   
/* Connect A[1] to B[0]:  Singleton:Dipole */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = "bca";
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = "acb";
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[0] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A1 connected to B0\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (connect) for A1 to B0\n");
         om$report_error(sts = sts);
   }
      printf("connected s:d \n");
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}

   
/* Disconnect A1 from B0:  case 3 t:f */

     disconnect_args.to_sel.type = OM_e_num;
     disconnect_args.to_sel.u_sel.number = chan_b;
     disconnect_args.fr_sel.type = OM_e_num;
     disconnect_args.fr_sel.u_sel.number = chan_a;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = a_objid[1];

	sts = om$send (msg = &disconnect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[0] );
 
   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A1 disconnected from B0 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A1 was not connected to B0\n");
      			    break;
      default:  printf("Error in om$send (disconnect) A1,B0\n");
      	        om$report_error(sts = sts);
   }
      printf("disconnected case 3 [t:f] \n");
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
	sts = om$make_message(classname = "A",
                              methodname = "show_a",
                              size = 0,
                              p_arglist = 0,
                              p_msg = &shoa);
	if(!(sts&1))
	{
	    printf("error in om$make_message for show_a\n");
	    om$report_error(sts = sts);
	    exit();
	}
        chansel.type = OM_e_name;
        chansel.u_sel.name = "bca";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shoa,
                      senderid = b_objid[0],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out B[0]'s bca (show_a)\n");
	    om$report_error(sts = sts);
	}
   

/* AGAIN   Singleton:Singleton Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[1] );
 
      if (!(sts&1))
      {
         printf (" error in om$send (connect) A1,B1\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("another connected s:s \n");
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 1);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*   Dipole:Dipole Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[1] );
 
      if (!(sts&1))
      {
         printf (" error in om$send (connect) A0,B1\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected d:d \n");
      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*   FROM:Singleton Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[2] );
 
      if (!(sts&1))
      {
         printf (" error in om$send (connect) A0,B2\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected FROM:s \n");
      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[2]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

/* Channel Send: have B's show themselves if they are attached to A0 from 0:2 */

        chansel.type = OM_e_name;
        chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 2);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}
	

/*   Singleton:TO Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[2];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[2],			
		       targetid = b_objid[2] );
 
      if (!(sts&1))
      {
         printf (" error in om$send (connect) A2,B2\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected s:TO \n");
      printf ("\n----- Dumping channel info for A[2]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[2] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[2]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[2],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[2]'a acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*   Singleton:FROM Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_a;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_b;
	connect_args.fr_idx            = OM_K_MAXINT;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[3],			
		       targetid = a_objid[0] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) B3,A0\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected s:FROM \n");
      printf ("\n----- Dumping channel info for B[3]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }


/* Channel Send: have B's show themselves if they are attached to A0 from 3:1 */

        chansel.type = OM_e_name;
        chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel,
                      from = 3,
                      to = 1);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}
	


/*   TO:Singleton Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_a;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_b;
	connect_args.fr_idx            = OM_K_MAXINT;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[3],			
		       targetid = a_objid[3] );
 
      if (!(sts&1))
      {
         printf (" error in om$send (connect) B3,A3\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected TO:s \n");
      printf ("\n----- Dumping channel info for B[3]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[3]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[3] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[3],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[3]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*   TO:FROM Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[2] );
 
      if (!(sts&1))
      {
         printf (" error in om$send (connect) A1,B2\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected TO:FROM \n");
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[2]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 4);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*   FROM:TO Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_a;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_b;
	connect_args.fr_idx            = OM_K_MAXINT;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[3],			
		       targetid = a_objid[2] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) B3,A2\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connecd FROM:TO \n");
      printf ("\n----- Dumping channel info for B[3]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[2]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[2] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[2],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[2]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*   FROM:FROM Connect */
	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[3] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) A1,B3\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected FROM:FROM \n");
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[3]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*  Create dipole A4 - B4  */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[4],			
		       targetid = b_objid[4] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) A4,B4\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("another connected s:s \n");
      printf ("\n----- Dumping channel info for A[4]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[4] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[4]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[4] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[4],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[4]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}

/*   Test om$get_index  and om$get_objid_at_index    */

     printf ("\nTesting om$get_index and om$get_objid_at_index routines\n\n");
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
     sts = om$get_index(osnum_c = OM_Gw_current_OS,
                        objid_c = a_objid[4],
                        p_chanselect = &chansel,
                        objid = b_objid[4],
                        osnum2 = OM_Gw_current_OS,
                        indexaddr = &relndx );
     if (!(1&sts))
     {
        printf(" error in om$get_index\n");
        om$report_error(sts = sts);
        exit();
     }

     printf ("Relindex of B[4] : %d \n\n", relndx );
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
     sts = om$get_objid_at_index (osnum=OM_Gw_current_OS, objid=a_objid[4],
                                   p_chanselect=&chansel,	
				   index = relndx,objidaddr = &my_objid, 					 osnumaddr =& osnumr);
     if (!(1&sts) || !(IF_EQ_OBJID(b_objid[4], my_objid)))
     {
        printf(" error in om$get_objid_at_index\n");
        om$report_error(sts = sts);
        exit();
     }

/*   Dipole:FROM Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_a;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_b;
	connect_args.fr_idx            = OM_K_MAXINT;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[4],			
		       targetid = a_objid[1] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) B4,A1\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected d:FROM \n");
      printf ("\n----- Dumping channel info for B[4]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[4] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

/*   Test om$get_index  and om$get_objid_at_index    */

     printf ("\nTesting om$get_index and om$get_objid_at_index routines\n\n");

     for ( i=0; i<MAXB-1; i++ )
     {
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
        sts = om$get_index(osnum_c = OM_Gw_current_OS,
                           objid_c = a_objid[0],
                           p_chanselect = &chansel,
                           objid = b_objid[i],
                           osnum2 = OM_Gw_current_OS,
                           indexaddr = &relndx );
        if (!(1&sts))
        {
           printf(" error in om$get_index\n");
           om$report_error(sts = sts);
           printf (" Iteration : %d \n", i );
        }

        printf ("Relindex of B[%d] : %d \n\n", i, relndx );
     }

/* Channel Send: have B's show themselves if they are attached to A1 from 3:3 */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 3,
                      to = 3);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}

/* Channel Send: have B's show themselves if they are attached to A0 from 1:10 */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel,
                      from = 1,
                      to = 10);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}

/* Channel Send: have B's show themselves if they are attached to A0 from -1:4 */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel,
                      from = -1,
                      to = 4);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/* Disconnect A1 from B1:  case 4 f:f (t:f)*/

     disconnect_args.to_sel.type = OM_e_num;
     disconnect_args.to_sel.u_sel.number = chan_b;
     disconnect_args.fr_sel.type = OM_e_num;
     disconnect_args.fr_sel.u_sel.number = chan_a;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = a_objid[1];

	sts = om$send (msg = &disconnect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[1] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A1 disconnected from B1 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A1 was not connected to B1\n");
      			    break;
      default:  printf("Error in om$send (disconnect) A1,B1\n");
      	        om$report_error(sts = sts);
}
      printf("disconnected case 4 [t:f] \n");
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 5);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*   TO:TO Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[4],			
		       targetid = b_objid[1] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) A4,B1\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected TO:TO \n");
      printf ("\n----- Dumping channel info for A[4]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[4] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[4],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 5);
	if(!(sts&1))
	{
	    printf("error in om$send out A[4]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}
   


/* Disconnect B1-B3 from A0:  case4 f:f (f:t) */

for( i=1; i<4; i++)
{
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = "acb";
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = "bca";
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = b_objid[i];

	sts = om$send (msg = &disconnect_msg,			
		       senderid = b_objid[i],			
		       targetid = a_objid[0] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("B[%d] disconnected from A0\n",i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B[i] was not on channel A[0]\n");
      			    break;
      default:  printf("Error in om$send (disconnect) A0,B%d\n",i);
      	        om$report_error(sts = sts);
                printf (" iteration : %d \n", i );
   }
      printf("disconnected case 4 [f:f] \n");
      printf ("\n----- Dumping channel info for B[%d]\n",i);
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[%d] : %x \n", i, sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
}
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[0],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 5);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*  Above disconnect made A0 - B0 a dipole */

/*   FROM:Dipole Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[0] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) A1,B0\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected FROM:d \n");
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 5);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/* Disconnect B4 from A4:  case 4 f:f (f:t) ; creates 2 dipoles */

	disconnect_args.to_sel.type = OM_e_num;
	disconnect_args.to_sel.u_sel.number = chan_a;
	disconnect_args.fr_objid = b_objid[4];
	disconnect_args.fr_os = OM_Gw_current_OS;
	disconnect_args.fr_sel.type = OM_e_num;
	disconnect_args.fr_sel.u_sel.number = chan_b;

	sts = om$send (msg = &disconnect_msg,			
		       senderid = b_objid[4],			
		       targetid = a_objid[4] );
   switch(sts)
   {
      case OM_S_SUCCESS:  printf("B4 disconnected from A4 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B4 was not connected to A4\n");
      			    break;
      default:  printf("Error in om$send (disconnect) A4,B4\n");
      	        om$report_error(sts = sts);
   }
      printf("disconnected case 4 [f:f] (f:t)\n");
      printf ("\n----- Dumping channel info for B[4]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[4] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[4]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[4] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[4],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 5);
	if(!(sts&1))
	{
	    printf("error in om$send out A[4]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/*  A4 - B1 is now a dipole  */

/*   Dipole:TO Connect */

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_a;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_b;
	connect_args.fr_idx            = OM_K_MAXINT;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[1],			
		       targetid = a_objid[3] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) A3,B1\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected d:TO \n");
      printf ("\n----- Dumping channel info for B[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[3]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[3] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[3],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 2);
	if(!(sts&1))
	{
	    printf("error in om$send out A[3]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/* Disconnect B2-B4 from A1:  case4 f:f  */

for( i=2; i<5; i++)
{
	disconnect_args.to_sel.type = OM_e_name;
	disconnect_args.to_sel.u_sel.name = "acb";
	disconnect_args.fr_objid = b_objid[i];
	disconnect_args.fr_os = OM_Gw_current_OS;
	disconnect_args.fr_sel.type = OM_e_name;
	disconnect_args.fr_sel.u_sel.name = "bca";
	sts = om$send (msg = &disconnect_msg,			
		       senderid = b_objid[i],			
		       targetid = a_objid[1] );
 
    switch(sts)
   {
      case OM_S_SUCCESS:  printf("B[%d] disconnected from A1\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B[%d] was not on channel A[1]\n", i);
      			    break;
      default:  printf("Error in om$send (disconnect) A1,B%d\n",i);
      	        om$report_error(sts = sts);
                printf (" iteration : %d \n", i );
   }
      printf("disconnected case 4 [f:f] \n");
      printf ("\n----- Dumping channel info for B[%d]\n",i);
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[%d] : %x \n", i, sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
}
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 5);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}


/* Disconnect A0 from B0:  creates dipole A1 - B0 */
	disconnect_args.to_sel.type = OM_e_num;
	disconnect_args.to_sel.u_sel.number = chan_b;
	disconnect_args.fr_objid = a_objid[0];
	disconnect_args.fr_os = OM_Gw_current_OS;
	disconnect_args.fr_sel.type = OM_e_num;
	disconnect_args.fr_sel.u_sel.number = chan_a;

	sts = om$send (msg = &disconnect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[0] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A0 disconnected from B0 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A0 was not connected to B0\n");
      			    break;
      default:  printf("Error in om$send (disconnect) A0,B0\n");
      	        om$report_error(sts = sts);
   }
      printf("disconnected to create dipole \n");
      printf ("\n----- Dumping channel info for A[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "bca";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shoa,
                      senderid = b_objid[0],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 5);
	if(!(sts&1))
	{
	    printf("error in om$send out B[0]'s bca (show_a)\n");
	    om$report_error(sts = sts);
	}

/*   TO:Dipole Connect */
	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_a;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[2];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_b;
	connect_args.fr_idx            = OM_K_MAXINT;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[2],			
		       targetid = a_objid[1] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) A1,B2\n");
         om$report_error(sts = sts);
         exit();
      }
      printf("connected TO:d \n");
      printf ("\n----- Dumping channel info for B[2]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for A[1]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shob,
                      senderid = a_objid[1],
                      p_chanselect = &chansel,
                      from = 0,
                      to = 2);
	if(!(sts&1))
	{
	    printf("error in om$send out A[1]'s acb (show_b)\n");
	    om$report_error(sts = sts);
	}

/* Disconnect A2-A3 from B3:  last delete is case d:d  */

for( i=2; i<4; i++)
{
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = "bca";
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = "acb";
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = a_objid[i];

	sts = om$send (msg = &disconnect_msg,			
		       senderid = a_objid[i],			
		       targetid = b_objid[3] );
   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A[%d] disconnected from B3\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A[i] was not on channel B[3]\n");
      			    break;
      default:  printf("Error in om$send (disconnect) A%d,B3\n",i);
      	        om$report_error(sts = sts);
                printf (" iteration : %d \n", i );
   }
}
      printf("disconnected last iteration is d:d \n");
      printf ("\n----- Dumping channel info for A[%d]\n",i);
      sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[i], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[%d] : %x \n", i, sts );
         om$report_error(sts = sts);
         exit();
      }
      printf ("\n----- Dumping channel info for B[3]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

/*=====================================*/
/* add some restricted channel testing */
/*=====================================*/

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct(osnum = OM_Gw_current_OS,
                         classname = "ResA",
                         p_objid = &resa_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for ResA : %x \n", sts );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }
   printf("created %d ResA objids \n", MAXA);
   
   sts = om$get_channel_number(channame = "ResA.acb",
                               p_channum = &chan_resa );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for ResA.acb : %x \n", sts );
      om$report_error(sts = sts);
      exit();
   }

   sts = om$get_channel_number(channame = "ResB.bca",
                               p_channum = &chan_resb );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for ResB.bca : %x \n", sts );
      om$report_error(sts = sts);
      exit();
   }


   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct(osnum = OM_Gw_current_OS,
                         classname = "ResB",
                         p_objid = &resb_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for ResB : %x \n", sts );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */
   printf("created %d ResB objids \n", MAXB);

/* connect all ResB objects to ResA[0] */

for(i=0; i<MAXB; i++)
{
	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_resa;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[i];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_resb;
	connect_args.fr_idx            = OM_K_MAXINT;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[i],
		       targetid = resa_objid[0] );

      if (!(sts&1))
      {
         printf (" error in om$send (connect) ResA0,ResB%d\n");
         om$report_error(sts = sts);
         exit();
      }
}
      printf("connected ResA0:ResB[MAXB] \n");
      printf ("\n----- Dumping channel info for ResA[0]\n");
      sts = OMT_dump_relation( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }
/*   Test om$get_index  and om$get_objid_at_index    */

     printf ("\nTesting om$get_index and om$get_objid_at_index routines\n\n");

     for ( i=0; i<MAXB; i++ )
     {
   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_resa;
        sts = om$get_index(osnum_c = OM_Gw_current_OS,
                           objid_c = resa_objid[0],
                           p_chanselect = &chansel,
                           objid = resb_objid[i],
                           osnum2 = OM_Gw_current_OS,
                           indexaddr = &relndx );
        if (!(1&sts))
        {
           printf(" error in om$get_index\n");
           om$report_error(sts = sts);
           printf (" Iteration : %d \n", i );
        }

        printf ("Relindex of ResB[%d] : %d \n\n", i, relndx );
     }

  for ( i=0; i<MAXB; i++ )
  {
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
     sts = om$get_objid_at_index (osnum=OM_Gw_current_OS, objid=resa_objid[0],
                                  p_chanselect=&chansel,
				  index = i, objidaddr = &my_objid,
				  osnumaddr =& osnumr);
     if (!(1&sts) || !(IF_EQ_OBJID(resb_objid[i], my_objid)))
     {
        printf(" error in om$get_objid_at_index, iteration %d\n", i);
        om$report_error(sts = sts);
        exit();
     }
  }
/* Channel Send: have ResB's show themselves if they are attached to ResA0 from 4:4 */

	sts = om$make_message(classname = "ResB",
                              methodname = "show_b",
                              p_msg = &shoresb);
	if(!(sts&1))
	{
	    printf("error in om$make_message for show_resb\n");
	    om$report_error(sts = sts);
	    exit();
	}
   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_resa;
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shoresb,
                      senderid = resa_objid[0],
                      p_chanselect = &chansel,
                      from = 4,
                      to = 4);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_resb)\n");
	    om$report_error(sts = sts);
	}

/* Channel Send: have ResB's show themselves if they are attached to ResA0 from 3:1 */

	sts = om$make_message(classname = "ResB",
                              methodname = "show_b",
                              p_msg = &shoresb);
	if(!(sts&1))
	{
	    printf("error in om$make_message for show_resb\n");
	    om$report_error(sts = sts);
	    exit();
	}
   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_resa;
	sts = om$send(mode = OM_e_wrt_object,
                      msg = &shoresb,
                      senderid = resa_objid[0],
                      p_chanselect = &chansel,
                      from = 3,
                      to = 1);
	if(!(sts&1))
	{
	    printf("error in om$send out A[0]'s acb (show_resb)\n");
	    om$report_error(sts = sts);
	}

}  /* main */
