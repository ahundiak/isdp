#include "OMobjectcomm.h"

#define MAXB 6
#define MAXA 11

main()
{
   int                  sts, i, zro=0;
   OM_S_OBJID           a_objid[MAXA], b_objid[MAXB], c_objid;
   OM_S_OBJID           resa_objid[MAXA], resb_objid[MAXB], c2_objid;
   OM_S_CHANNUM         chan_a, chan_b;
   OM_S_CHANNUM         chan_resa, chan_resb;
   uword                count, siz;
   char                 *chan_acany,*chan_acbc,*chan_acb,*chan_bca;
   char                 *chan_sbca;
   char                 *chan_resacany,*chan_resacbc,*chan_resacb,*chan_resbca;
   char                 *chan_sca;
   OM_S_CHANSELECT      chansel;
   int		        relindex=0, to=0, from=0;
   OM_S_MESSAGE 	showb,showresb,connect_msg,move_chan_msg;
   uword        	OSnum;
   uword	        minorchan=0;
   
struct connect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 uword                fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
       } connect_args;
struct move_chan_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 OM_S_OBJID	      fr_objid;
	 OMuword              fr_os;
	 OM_S_CHANSELECT      fr_sel;
       } move_chan_args;
   sts = om$runtime_init();
   if (!(sts&1))
   {
      printf (" error in om%runtine_init\n" );
      om$report_error(sts = sts);
      exit();
   }

   OSnum = OM_Gw_TransOSnum_0;
   

   chan_acb  = "A.acb";
   chan_acany  = "A.acany";
   chan_acbc = "A.acbc";
   chan_bca  = "B.bca";
   chan_sbca  = "C.sbca";

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "A",
                         p_objid = &a_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for A\n" );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }


   sts = om$get_channel_number(channame = "A.acb",
                               p_channum = &chan_a );
   if (!(sts&1))
   {
      printf (" error in om$get channel_number for acb\n" );
      om$report_error(sts = sts);
      exit();
   }

   sts = om$get_channel_number(channame = "B.bca",
                               p_channum = &chan_b );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for bca\n" );
      om$report_error(sts = sts);
      exit();
   }


   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "B",
                         p_objid = &b_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for B\n" );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */

/* Now I need to build the following relations for the test:
	a1 - b0    	Dipole
	a2,a3 - b1  	TO:FROM
	a4 - b2,b3	FROM:TO
	a5 - b4         Dipole
	a10 - b5	Dipole
*/

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[1];
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
		       senderid = a_objid[1],			
		       targetid = b_objid[0] );

   if (!(sts&1))
      {
      printf (" error in om$send (connect) for B\n" );
      om$report_error(sts = sts);
      exit();
      }
   printf ("A1 connected to B0\n");

   printf ("----- Dumping A[1]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );

   printf ("----- Dumping B[0]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, b_objid[0], "bca" );
   
     
for(i=2; i<4; i++)
{
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[i];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[i],			
		       targetid = b_objid[1] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A%d connected to B1\n", i);
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("B1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (connect) for A%d to B1\n", i);
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[%d]'s acb channel\n",i);
   OMT_dump_relation( OM_Gw_current_OS, a_objid[i], "acb" );

   printf ("----- Dumping B[1]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
}
      

for(i=2; i<4; i++)
{
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[4],			
		       targetid = b_objid[i] );

   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A4 connected to B%d\n", i);
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (connect) for A4 to B%d\n", i);
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[4]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );

   printf ("----- Dumping B[%d]'s bca channel\n",i);
   OMT_dump_relation( OM_Gw_current_OS, b_objid[i], "bca" );
}

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[5];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[5],			
		       targetid = b_objid[4] );
 
   if (!(sts&1))
      {
      printf (" error in om$send (connect)\n");
      om$report_error(sts = sts);
      exit();
      }
   printf ("A5 connected to B4\n");

   printf ("----- Dumping A[5]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[5], "acb" );

   printf ("----- Dumping B[4]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, b_objid[4], "bca" );

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[10];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[10],			
		       targetid = b_objid[5] );
   if (!(sts&1))
      {
      printf (" error in om$send (connect)\n");
      om$report_error(sts = sts);
      exit();
      }

   printf ("A10 connected to B5\n");

   printf ("----- Dumping A[10]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[10], "acb" );

   printf ("----- Dumping B[5]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, b_objid[5], "bca" );

/******************************************************************
Test # 1 - Source is a singleton.
*******************************************************************/

   printf ("\n\n******* Test 1 - A0.acb to A6.acb but A0 is empty\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acb;
	move_chan_args.fr_objid = a_objid[0];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acb;

	sts = om$make_message(classname = "Root",		
			      methodname = "move_chan",		
			      size = sizeof( struct move_chan_struct),
			      p_arglist = &move_chan_args,	
			      p_msg = &move_chan_msg );

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[0],			
		       targetid = a_objid[6] );

   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("\n\nA0.acb moved to A6.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A0 to A6\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[0]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );

   printf ("----- Dumping A[6]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[6], "acb" );


/******************************************************************
Test # 2 - Source is a dipole.
*******************************************************************/

   printf ("\n\n******* Test 2 - A1.acb to A7.acb\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acb;
	move_chan_args.fr_objid = a_objid[1];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[1],			
		       targetid = a_objid[7] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nA1.acb moved to A7.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A1 to A7\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[1]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );

   printf ("----- Dumping A[7]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[7], "acb" );

   sts = om$make_message(classname = "B",
                         methodname = "show_b",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &showb);
   if(!(sts&1))
   {
	printf("error in om%make_message for show_b\n");
	om$report_error(sts = sts);
	exit();
   }
   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_acb;
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = a_objid[7],
                 p_chanselect = &chansel);
   if(!(sts&1))
   {
	printf("error in om$send (show_b)\n");
	om$report_error(sts = sts);
	exit();
   }

/******************************************************************
Test # 3 - Source is on the TO side of a relation.
*******************************************************************/

   printf ("\n\n******* Test 3 - A2.acb to A8.acb\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acb;
	move_chan_args.fr_objid = a_objid[2];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[2],			
		       targetid = a_objid[8] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nA2.acb moved to A8.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A2 to A8\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[2]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[2], "acb" );

   printf ("----- Dumping A[8]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[8], "acb" );

   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_acb;
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = a_objid[8],
                 p_chanselect = &chansel);
   if(!(sts&1))
   {
	printf("error in om$send (show_b)\n");
	om$report_error(sts = sts);
	exit();
   }

/******************************************************************
Test # 4 - Source is on the FROM side of a relation.
*******************************************************************/

   printf ("\n\n******* Test 4 - A4.acb to A9.acb\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acb;
	move_chan_args.fr_objid = a_objid[4];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[4],			
		       targetid = a_objid[9] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nA4.acb moved to A9.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A4 to A9\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[4]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );

   printf ("----- Dumping A[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[9], "acb" );

   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_acb;
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = a_objid[9],
                 p_chanselect = &chansel);
   if(!(sts&1))
   {
	printf("error in om$send (show_b)\n");
	om$report_error(sts = sts);
	exit();
   }

/******************************************************************
Test # 5 - Source is a dipole and target is a dipole.  This should 
           generate a error because the target should be empty.
*******************************************************************/

   printf ("\n\n******* Test 5 - A5.acb to A10.acb but A10.acb is not empty\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acb;
	move_chan_args.fr_objid = a_objid[5];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[5],			
		       targetid = a_objid[10] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nA5.acb moved to A10\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("\nOM_E_INVCHAN - expected error\n\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A5 to A10\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[5]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[5], "acb" );

   printf ("----- Dumping A[10]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[10], "acb" );

/******************************************************************
Test # 6 - Source is a dipole and its channel has only Bs on rhs.  
           Target is empty and its channel accepts Bs & Cs on rhs.
	   Target channel is a superset of Source's channel.
*******************************************************************/

   printf ("\n\n******* Test 6 - A7.acb to A1.acbc\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acbc;
	move_chan_args.fr_objid = a_objid[7];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[7],			
		       targetid = a_objid[1] );

   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("\n\nA7.acb moved to A1.acbc\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A7.acb to A1.acbc\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[7]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[7], "acb" );

   printf ("----- Dumping A[1]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acbc" );

/******************************************************************
Test # 7 - Source is FROM side of relation and its channel has
		 only Bs on rhs.  
           Target is empty and its channel accepts any class on rhs.
	   Target channel is a wildcard channel.
*******************************************************************/

   printf ("\n\n******* Test 7 - A9.acb to A10.acany\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acany;
	move_chan_args.fr_objid = a_objid[9];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[9],			
		       targetid = a_objid[10] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nA9.acb moved to A10.acany\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A9.acb to A10.acany\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[9], "acb" );

   printf ("----- Dumping A[10]'s acany channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[10], "acany" );

/******************************************************************
Test # 8 - Source is FROM side of relation and its channel has
	    only any class on rhs.  
           Target is empty and its channel accepts Bs & Cs on rhs.
	   Target channel is a subset of source channel but all
	    objects currently hooked to channel are allowed on source.
*******************************************************************/

   printf ("\n\n******* Test 8 - A10.acany to A4.acbc\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acbc;
	move_chan_args.fr_objid = a_objid[10];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acany;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[10],			
		       targetid = a_objid[4] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nA10.acany moved to A4.acbc\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A10.acany to A4.acbc\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[10]'s acany channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[10], "acany" );

   printf ("----- Dumping A[4]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acbc" );

/* Construct a C object and connect it to A[4].acbc */

      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "C",
                         p_objid = &c_objid,
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for C\n" );
         om$report_error(sts = sts);
         exit();
      }

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_sbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acbc;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[4],			
		       targetid = c_objid );
 
   if (!(sts&1))
      {
      printf (" error in om$send (connect) for C\n");
      om$report_error(sts = sts);
      exit();
      }

   printf ("A4 connected to C\n");

   printf ("----- Dumping A[4]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acbc" );

   printf ("----- Dumping C's sbca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, c_objid, "sbca" );
   

/******************************************************************
Test # 9 - Source is FROM side of relation and its channel has
	    Bs and Cs on rhs.  
           Target is empty and its channel accepts only Bs on rhs.
	   Target channel is a subset of source channel but all
	    objects currently hooked to channel are not allowed
	    on source.  This test should fail.
*******************************************************************/

   printf ("\n\n******* Test 9 - A4.acbc to A9.acb but C is not allowed on acb\n");
	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_acb;
	move_chan_args.fr_objid = a_objid[4];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_acbc;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid[4],			
		       targetid = a_objid[9] );

   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("\n\nA4.acbc moved to A9.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_CLASS_CONFLICT: 
                         printf ("\nOM_E_CLASS_CONFLICT - expected error\n\n");
                         break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for A4.acbc to A9.acb\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping A[4]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acbc" );

   printf ("----- Dumping A[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[9], "acb" );


   /*=========================================================*/
   /*=========================================================*/
   /*   R E S T R I C T E D     C H A N N E L    T E S T S    */
   /*=========================================================*/
   /*=========================================================*/

   printf ("\nStart of restrcited channel tests\n\n\n");

   chan_resacb    = "ResA.acb";
   chan_resacany  = "ResA.acany";
   chan_resacbc   = "ResA.acbc";
   chan_resbca    = "ResB.bca";
   chan_sca       = "C.sca";

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "ResA",
                         p_objid = &resa_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for ResA\n" );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }


   sts = om$get_channel_number(channame = "ResA.acb",
                               p_channum = &chan_a );
   if (!(sts&1))
   {
      printf (" error in om$get channel_number for acb\n" );
      om$report_error(sts = sts);
      exit();
   }

   sts = om$get_channel_number(channame = "ResB.bca",
                               p_channum = &chan_b );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for bca\n" );
      om$report_error(sts = sts);
      exit();
   }


   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "ResB",
                         p_objid = &resb_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for ResB\n" );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */

/* Now I need to build the following relations for the test:
	a1 - b0    	Dipole
	a2,a3 - b1  	TO:FROM
	a4 - b2,b3	FROM:TO
	a5 - b4         Dipole
	a10 - b5	Dipole
*/

	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[1];
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
		       senderid = resa_objid[1],			
		       targetid = resb_objid[0] );

   if (!(sts&1))
      {
      printf (" error in om$send (connect) for ResB\n" );
      om$report_error(sts = sts);
      exit();
      }
   printf ("ResA1 connected to ResB0\n");

   printf ("----- Dumping ResA[1]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[1], "acb" );

   printf ("----- Dumping ResB[0]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resb_objid[0], "bca" );
   
     
for(i=2; i<4; i++)
{
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[i];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[i],			
		       targetid = resb_objid[1] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA%d connected to ResB1\n", i);
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("ResB1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (connect) for ResA%d to ResB1\n", i);
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[%d]'s acb channel\n",i);
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[i], "acb" );

   printf ("----- Dumping ResB[1]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resb_objid[1], "bca" );
}
      

for(i=2; i<4; i++)
{
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[4],			
		       targetid = resb_objid[i] );

   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA4 connected to ResB%d\n", i);
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (connect) for ResA4 to ResB%d\n", i);
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[4]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acb" );

   printf ("----- Dumping ResB[%d]'s bca channel\n",i);
   OMT_dump_relation( OM_Gw_current_OS, resb_objid[i], "bca" );
}

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[5];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[5],			
		       targetid = resb_objid[4] );
 
   if (!(sts&1))
      {
      printf (" error in om$send (connect)\n");
      om$report_error(sts = sts);
      exit();
      }
   printf ("ResA5 connected to ResB4\n");

   printf ("----- Dumping ResA[5]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[5], "acb" );

   printf ("----- Dumping ResB[4]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resb_objid[4], "bca" );

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[10];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[10],			
		       targetid = resb_objid[5] );
   if (!(sts&1))
      {
      printf (" error in om$send (connect)\n");
      om$report_error(sts = sts);
      exit();
      }

   printf ("ResA10 connected to ResB5\n");

   printf ("----- Dumping ResA[10]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[10], "acb" );

   printf ("----- Dumping ResB[5]'s bca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resb_objid[5], "bca" );

/******************************************************************
Test # 1 - Source is a singleton.
*******************************************************************/

   printf ("\n\n******* Test 1 - ResA0.acb to ResA6.acb but ResA0 is empty\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacb;
	move_chan_args.fr_objid = resa_objid[0];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacb;

	sts = om$make_message(classname = "Root",		
			      methodname = "move_chan",		
			      size = sizeof( struct move_chan_struct),
			      p_arglist = &move_chan_args,	
			      p_msg = &move_chan_msg );

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[0],			
		       targetid = resa_objid[6] );

   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("\n\nResA0.acb moved to ResA6.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for ResA0 to ResA6\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[0]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[0], "acb" );

   printf ("----- Dumping ResA[6]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[6], "acb" );


/******************************************************************
Test # 2 - Source is a dipole.
*******************************************************************/

   printf ("\n\n******* Test 2 - ResA1.acb to ResA7.acb\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacb;
	move_chan_args.fr_objid = resa_objid[1];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[1],			
		       targetid = resa_objid[7] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nResA1.acb moved to ResA7.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for ResA1 to ResA7\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[1]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[1], "acb" );

   printf ("----- Dumping ResA[7]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[7], "acb" );

   sts = om$make_message(classname = "ResB",
                         methodname = "show_b",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &showresb);
   if(!(sts&1))
   {
	printf("error in om%make_message for show_b\n");
	om$report_error(sts = sts);
	exit();
   }
   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_resacb;
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showresb,
                 senderid = resa_objid[7],
                 p_chanselect = &chansel);
   if(!(sts&1))
   {
	printf("error in om$send (show_b)\n");
	om$report_error(sts = sts);
	exit();
   }

/******************************************************************
Test # 3 - Source is on the TO side of a relation.
*******************************************************************/

   printf ("\n\n******* Test 3 - ResA2.acb to ResA8.acb\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacb;
	move_chan_args.fr_objid = resa_objid[2];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[2],			
		       targetid = resa_objid[8] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nResA2.acb moved to ResA8.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for ResA2 to ResA8\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[2]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[2], "acb" );

   printf ("----- Dumping ResA[8]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[8], "acb" );

   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_resacb;
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showresb,
                 senderid = resa_objid[8],
                 p_chanselect = &chansel);
   if(!(sts&1))
   {
	printf("error in om$send (show_b)\n");
	om$report_error(sts = sts);
	exit();
   }

/******************************************************************
Test # 4 - Source is on the FROM side of a relation.
*******************************************************************/

   printf ("\n\n******* Test 4 - ResA4.acb to ResA9.acb\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacb;
	move_chan_args.fr_objid = resa_objid[4];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[4],			
		       targetid = resa_objid[9] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nResA4.acb moved to ResA9.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for ResA4 to ResA9\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[4]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acb" );

   printf ("----- Dumping ResA[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[9], "acb" );

   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_resacb;
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showresb,
                 senderid = resa_objid[9],
                 p_chanselect = &chansel);
   if(!(sts&1))
   {
	printf("error in om$send (show_b)\n");
	om$report_error(sts = sts);
	exit();
   }

/******************************************************************
Test # 5 - Source is a dipole and target is a dipole.  This should 
           generate a error because the target should be empty.
*******************************************************************/

   printf ("\n\n******* Test 5 - ResA5.acb to ResA10.acb but ResA10.acb is not empty\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacb;
	move_chan_args.fr_objid = resa_objid[5];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[5],			
		       targetid = resa_objid[10] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nResA5.acb moved to ResA10\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("\nOM_E_INVCHAN - expected error\n\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for ResA5 to ResA10\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[5]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[5], "acb" );

   printf ("----- Dumping ResA[10]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[10], "acb" );

/******************************************************************
Test # 6 - Source is a dipole and its channel has only ResBs on rhs.  
           Target is empty and its channel accepts ResBs & Cs on rhs.
	   Target channel is a superset of Source's channel.
*******************************************************************/

   printf ("\n\n******* Test 6 - ResA7.acb to ResA1.acbc - should error\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacbc;
	move_chan_args.fr_objid = resa_objid[7];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[7],			
		       targetid = resa_objid[1] );

   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("\n\nResA7.acb moved to ResA1.acbc\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      case OM_E_CLASS_CONFLICT:
                           printf("\nOM_E_CLASS_CONFLICT - expected error\n");
                           break;
      default:				
         printf("error in om$send (move_chan) for ResA7.acb to ResA1.acbc\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[7]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[7], "acb" );

   printf ("----- Dumping ResA[1]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[1], "acbc" );

/******************************************************************
Test # 7 - Source is FROM side of relation and its channel has
		 only ResBs on rhs.  
           Target is empty and its channel accepts any class on rhs.
	   Target channel is a wildcard channel.
*******************************************************************/

   printf ("\n\n******* Test 7 - ResA9.acb to ResA10.acany - should error\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacany;
	move_chan_args.fr_objid = resa_objid[9];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacb;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[9],			
		       targetid = resa_objid[10] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nResA9.acb moved to ResA10.acany\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      case OM_E_CLASS_CONFLICT:
                           printf("\nOM_E_CLASS_CONFLICT - expected error\n");
                           break;
      default:				
         printf("error in om$send (move_chan) for ResA9.acb to ResA10.acany\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[9], "acb" );

   printf ("----- Dumping ResA[10]'s acany channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[10], "acany" );

/******************************************************************
Test # 8 - Source is FROM side of relation and its channel has
	    only any class on rhs.  
           Target is empty and its channel accepts ResBs & Cs on rhs.
	   Target channel is a subset of source channel but all
	    objects currently hooked to channel are allowed on source.
*******************************************************************/

   printf ("\n\n******* Test 8 - ResA10.acany to ResA4.acbc but Res10.acany is empty\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacbc;
	move_chan_args.fr_objid = resa_objid[10];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacany;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[10],			
		       targetid = resa_objid[4] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("\n\nResA10.acany moved to ResA4.acbc\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      case OM_I_CHAN_EMPTY:
                           printf("\nOM_I_CHAN_EMPTY - expected status\n");
                           break;
      default:				
         printf("error in om$send (move_chan) for ResA10.acany to ResA4.acbc\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[10]'s acany channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[10], "acany" );

   printf ("----- Dumping ResA[4]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acbc" );

/* Construct a C object and connect it to ResA[4].acbc */

      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "C",
                         p_objid = &c2_objid,
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for C2\n" );
         om$report_error(sts = sts);
         exit();
      }

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_sca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacbc;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[4],			
		       targetid = c2_objid );
 
   if (!(sts&1))
      {
      printf (" error in om$send (connect) for C2\n");
      om$report_error(sts = sts);
      exit();
      }

   printf ("ResA4 connected to C2\n");

   printf ("----- Dumping ResA[4]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acbc" );

   printf ("----- Dumping C2's sca channel\n");
   OMT_dump_relation( OM_Gw_current_OS, c2_objid, "sca" );
   

/******************************************************************
Test # 9 - Source is FROM side of relation and its channel has
	    ResBs and C2s on rhs.  
           Target is empty and its channel accepts only ResBs on rhs.
	   Target channel is a subset of source channel but all
	    objects currently hooked to channel are not allowed
	    on source.  This test should fail.
*******************************************************************/

   printf ("\n\n******* Test 9 - ResA4.acbc to ResA9.acb but C2 is not allowed on acb\n");
	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = chan_resacb;
	move_chan_args.fr_objid = resa_objid[4];
	move_chan_args.fr_os = OM_Gw_current_OS;
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = chan_resacbc;

	sts = om$send (msg = &move_chan_msg,			
		       senderid = resa_objid[4],			
		       targetid = resa_objid[9] );

   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("\n\nResA4.acbc moved to ResA9.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("\nOM_E_INVCHAN - expected error\n");
      		          break;
      case OM_E_CLASS_CONFLICT: 
                         printf ("\nOM_E_CLASS_CONFLICT - expected error\n\n");
                         break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send (move_chan) for ResA4.acbc to ResA9.acb\n");
         om$report_error(sts = sts);
   }
   printf ("----- Dumping ResA[4]'s acbc channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acbc" );

   printf ("----- Dumping ResA[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[9], "acb" );

return(1);
}  /* main */
