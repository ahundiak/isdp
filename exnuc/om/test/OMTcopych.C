#include "OMobjectcomm.h"
#include "OMintprims.h"

#define MAXB 5
#define MAXA 11

main()
{
   int             sts, i, zro=0;
   OM_S_OBJID      a_objid[MAXA], b_objid[MAXB];
   OM_S_OBJID      resa_objid[MAXA], resb_objid[MAXB];
   uword           count, siz;
   char           *chan_acb,*chan_bca,*chan_resbca,*chan_resacb;
   int		   relindex=0;
   uword	   OSnum;
   uword	   minorchan=0;
   OM_p_CHANNUM    chan_a,chan_b,chan_resa,chan_resb;
   OM_S_MESSAGE    copy_chan_msg,connect_msg,adel, bdel, resadel, resbdel;

struct connect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 uword                fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
       } connect_args;

struct copy_chan_struct
       {
          OM_S_CHANSELECT     to_sel;
          OM_S_OBJID          fr_objid;
          OMuword             fr_os;
          OM_S_CHANSELECT     fr_sel;
       } copy_chan_args;

   sts = om$runtime_init();
   if (!(sts&1))
   {
      printf (" error in om$runtime_init : %x \n", sts );
      om$report_error(sts=sts);
      exit();
   }

   chan_acb = "A.acb";
   chan_bca = "B.bca";

   OSnum = OM_Gw_TransOSnum_0;
   
printf("\n\n*** Constructing A objects ***\n\n");

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct (osname="OM_TransOS_0",classname="A",									p_objid=&a_objid[i]);

    if (!(sts&1))
      {
         printf (" error in om$construct for A : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }


   sts = om$get_channel_number (channame= "A.acb",p_channum= &chan_a );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for acb : %x \n", sts );
      om$report_error(sts=sts);
      exit();
   }

   sts = om$get_channel_number (channame= "B.bca",p_channum= &chan_b );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for bca : %x \n", sts );
      om$report_error(sts=sts);
      exit();
   }


printf("\n\n*** Constructing B objects ***\n\n");

   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct (osname="OM_TransOS_0",classname="B",								p_objid=&b_objid[i]);
 
    if (!(sts&1))
      {
         printf (" error in om$construct for B : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */

printf("\n\n*** Build the following constructs for the test:\n");
printf("	a1 - b0    	Dipole \n");
printf("	a2,a3 - b1  	TO:FROM\n");
printf("	a4 - b2,b3	FROM:TO\n");
printf("        a4 - b1                \n");
printf("	a5 - b4         Dipole \n");


printf("\n\n*** Connect A1 to B0 ***\n\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
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
      printf (" error in om$connect for B\n");
      om$report_error(sts=sts);
      exit();
      }
printf ("----- Dumping A[1]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );

printf ("----- Dumping B[0]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, b_objid[0], "bca" );


printf("\n\n*** Connect A2 to B1 ***\n\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[2];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[2],			
		       targetid = b_objid[1] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A2 connected to B1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("B1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for A2 to B1 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping A[2]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[2], "acb" );

printf ("----- Dumping B[1]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );

printf("\n\n*** Connect A3 to B1 ***\n\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[3],			
		       targetid = b_objid[1] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A3 connected to B1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("B1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for A3 to B1 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping A[3]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[3], "acb" );

printf ("----- Dumping B[1]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );
     

printf("\n\n*** Connect A4 to B2 ***\n\n");

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
		       targetid = b_objid[2] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A4 connected to B2\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for A4 to B2 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping A[4]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );

printf ("----- Dumping B[2]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, b_objid[2], "bca" );

printf("\n\n*** Connect A4 to B3 ***\n\n");

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
		       targetid = b_objid[3] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A4 connected to B3\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for A4 to B3 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping A[4]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );

printf ("----- Dumping B[3]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, b_objid[3], "bca" );

printf("\n\n*** Connect A4 to B1 ***\n\n");

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
		       targetid = b_objid[1] );
 
  switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A4 connected to B1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for A4 to B1 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping A[4]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );

printf ("----- Dumping B[1]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, b_objid[1], "bca" );

printf("\n\n*** Connect A5 to B4 ***\n\n");

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
      printf (" error in om$send msg=connect\n" );
      om$report_error(sts=sts);
      exit();
      }
printf ("----- Dumping A[5]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[5], "acb" );

printf ("----- Dumping B[4]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, b_objid[4], "bca" );

printf("\n\n*****************************************************\n");
printf("*** Test channel name version ***\n");
printf("*********************************************************\n\n");

/******************************************************************
Test # 1 - Source is a singleton.
*******************************************************************/
printf("\n\n*** Test 1 - A[0] to A[6] Source is an empty channel ***\n\n");

printf ("----- Dumping A[0]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = a_objid[0];

	sts = om$make_message(classname = "Root",		
			      methodname = "copy_chan",		
			      size = sizeof( struct copy_chan_struct),
			      p_arglist = &copy_chan_args,	
			      p_msg = &copy_chan_msg );

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = a_objid[0],			
		       targetid = a_objid[6] );
   
   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("A0.acb copied to A6.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for A0 to A6 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping A[0]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[0], "acb" );

   printf ("----- Dumping A[6]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[6], "acb" );

/******************************************************************
Test # 2 - Source is a dipole.
*******************************************************************/
printf("\n\n*** Test 2 - A[1] to A[7] Source is a dipole ***\n\n");

printf ("----- Dumping A[1]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );


         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = a_objid[1];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = a_objid[1],			
		       targetid = a_objid[7] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A1.acb copied to A7.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for A1 to A7 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping A[1]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[1], "acb" );

   printf ("----- Dumping A[7]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[7], "acb" );

/******************************************************************
Test # 3 - Source is on the TO side of a relation.
*******************************************************************/
printf("\n\n*** Test 3 - A[2] to A[8] Source on TO side ***\n\n");

printf ("----- Dumping A[2]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[2], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = a_objid[2];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = a_objid[2],			
		       targetid = a_objid[8] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A2.acb copied to A8.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for A2 to A8 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping A[2]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[2], "acb" );

   printf ("----- Dumping A[8]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[8], "acb" );

/******************************************************************
Test # 4 - Source is on the FROM side of a relation.
*******************************************************************/
printf("\n\n*** Test 4 - A[4] to A[9] Source on FROM side ***\n\n");

printf ("----- Dumping A[4]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = a_objid[4];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = a_objid[4],			
		       targetid = a_objid[9] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A4.acb copied to A9.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for A4 to A9 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping A[4]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[4], "acb" );

   printf ("----- Dumping A[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[9], "acb" );

/******************************************************************
Test # 5 - Source is a dipole and target is a dipole.  

*******************************************************************/
printf("\n\n*** Test 5 - A[5] to A[10] Source and target are dipole ***\n\n");

printf ("----- Dumping A[5]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, a_objid[5], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.u_sel.name = chan_acb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = a_objid[5];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = a_objid[5],			
		       targetid = a_objid[10] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("A5.acb copied to A10\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for A5 to A10 %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping A[5]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[5], "acb" );

   printf ("----- Dumping A[10]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, a_objid[10], "acb" );

   printf("\n\n*********** Delete objects before exiting **************\n\n");

	sts = om$make_message(classname = "A",		
			      methodname = "delete",	
			      p_msg = &adel );

        if (!(sts&1))
	{
	printf("error in om$make_message for delete of A: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

	sts = om$make_message(classname = "B",		
			      methodname = "delete",	
			      p_msg = &bdel );

        if (!(sts&1))
	{
	printf("error in om$make_message for delete of B: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

        for ( i=1; i<MAXA; i++ )
	{
	 sts = om$send (msg = &adel,									mode = OM_e_wrt_object,								senderid = a_objid[i],								targetid = a_objid[i] );

               if (!(sts&1))
		{
		printf("error in om$send msg=adel : %d\n", sts);
		om$report_error(sts=sts);
		exit();
		}
	}

        for ( i=1; i<MAXB; i++ )
	{
	 sts = om$send (msg = &bdel,									mode = OM_e_wrt_object,								senderid = b_objid[i],								targetid = b_objid[i] );

               if (!(sts&1))
		{
		printf("error in OM_send_object : %d\n", sts);
		om$report_error(sts=sts);
		exit();
		}
	}


   /*=======================================================*/
   /*=======================================================*/
   /*    R E S T R I C T E D   C H A N N E L    T E S T S   */
   /*=======================================================*/
   /*=======================================================*/


   printf ("\nStart of Restricted Channel testing\n\n");

   chan_resacb = "ResA.acb";
   chan_resbca = "ResB.bca";

   OSnum = OM_Gw_TransOSnum_0;
   
   printf("\n\n*** Constructing ResA objects ***\n\n");

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct (osname="OM_TransOS_0",classname="ResA",
                          p_objid=&resa_objid[i]);

    if (!(sts&1))
      {
         printf (" error in om$construct for ResA : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }


   sts = om$get_channel_number (channame= "ResA.acb",p_channum= &chan_resa );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for ResA.acb : %x \n", sts );
      om$report_error(sts=sts);
      exit();
   }

   sts = om$get_channel_number (channame= "ResB.bca",p_channum= &chan_resb );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for ResB.bca : %x \n", sts );
      om$report_error(sts=sts);
      exit();
   }


   printf("\n\n*** Constructing ResB objects ***\n\n");

   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct (osname="OM_TransOS_0",classname="ResB",
                          p_objid=&resb_objid[i]);
 
    if (!(sts&1))
      {
         printf (" error in om$construct for ResB : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */

printf("\n\n*** Build the following constructs for the test:\n");
printf("	resa1 - resb0    	Dipole \n");
printf("	resa2,resa3 - resb1  	TO:FROM\n");
printf("	resa4 - resb2,resb3	FROM:TO\n");
printf("        resa4 - resb1                \n");
printf("	resa5 - resb4           Dipole \n");


printf("\n\n*** Connect ResA1 to ResB0 ***\n\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
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
      printf (" error in om$connect for ResB\n");
      om$report_error(sts=sts);
      exit();
      }
printf ("----- Dumping ResA[1]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[1], "acb" );

printf ("----- Dumping ResB[0]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, resb_objid[0], "bca" );


printf("\n\n*** Connect ResA2 to ResB1 ***\n\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[2];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[2],			
		       targetid = resb_objid[1] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA2 connected to ResB1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("ResB1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for ResA2 to ResB1 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping ResA[2]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[2], "acb" );

printf ("----- Dumping ResB[1]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, resb_objid[1], "bca" );

printf("\n\n*** Connect ResA3 to ResB1 ***\n\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[3],			
		       targetid = resb_objid[1] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA3 connected to ResB1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("ResB1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for ResA3 to ResB1 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping ResA[3]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[3], "acb" );

printf ("----- Dumping ResB[1]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, resb_objid[1], "bca" );
     

printf("\n\n*** Connect ResA4 to ResB2 ***\n\n");

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
		       targetid = resb_objid[2] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA4 connected to ResB2\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for ResA4 to ResB2 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping ResA[4]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acb" );

printf ("----- Dumping ResB[2]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, resb_objid[2], "bca" );

printf("\n\n*** Connect ResA4 to ResB3 ***\n\n");

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
		       targetid = resb_objid[3] );
 
   switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA4 connected to ResB3\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for ResA4 to ResB3 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping ResA[4]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acb" );

printf ("----- Dumping ResB[3]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, resb_objid[3], "bca" );

printf("\n\n*** Connect ResA4 to ResB1 ***\n\n");

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
		       targetid = resb_objid[1] );
 
  switch(sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA4 connected to ResB1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=connect for ResA4 to ResB1 : %x\n", sts);
         om$report_error(sts=sts);
   }
printf ("----- Dumping ResA[4]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acb" );

printf ("----- Dumping ResB[1]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, resb_objid[1], "bca" );

printf("\n\n*** Connect ResA5 to ResB4 ***\n\n");

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
      printf (" error in om$send msg=connect\n" );
      om$report_error(sts=sts);
      exit();
      }
printf ("----- Dumping ResA[5]'s acb channel\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[5], "acb" );

printf ("----- Dumping ResB[4]'s bca channel\n");
OMT_dump_relation( OM_Gw_current_OS, resb_objid[4], "bca" );

printf("\n\n*****************************************************\n");
printf("*** Test channel name version ***\n");
printf("*********************************************************\n\n");

/******************************************************************
Test # 1 - Source is a singleton.
*******************************************************************/
printf("\n\n*** Test 1 - ResA[0] to ResA[6] Source is an empty channel ***\n\n");

printf ("----- Dumping ResA[0]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[0], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = resa_objid[0];

	sts = om$make_message(classname = "Root",		
			      methodname = "copy_chan",		
			      size = sizeof( struct copy_chan_struct),
			      p_arglist = &copy_chan_args,	
			      p_msg = &copy_chan_msg );

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = resa_objid[0],			
		       targetid = resa_objid[6] );
   
   switch(sts)
   {
      case OM_I_CHAN_EMPTY:
      case OM_S_SUCCESS:  printf("ResA0.acb copied to ResA6.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for ResA0 to ResA6 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping ResA[0]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[0], "acb" );

   printf ("----- Dumping ResA[6]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[6], "acb" );

/******************************************************************
Test # 2 - Source is a dipole.
*******************************************************************/
printf("\n\n*** Test 2 - ResA[1] to ResA[7] Source is a dipole ***\n\n");

printf ("----- Dumping ResA[1]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[1], "acb" );


         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = resa_objid[1];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = resa_objid[1],			
		       targetid = resa_objid[7] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("ResA1.acb copied to ResA7.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for ResA1 to ResA7 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping ResA[1]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[1], "acb" );

   printf ("----- Dumping ResA[7]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[7], "acb" );

/******************************************************************
Test # 3 - Source is on the TO side of a relation.
*******************************************************************/
printf("\n\n*** Test 3 - ResA[2] to ResA[8] Source on TO side ***\n\n");

printf ("----- Dumping ResA[2]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[2], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = resa_objid[2];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = resa_objid[2],			
		       targetid = resa_objid[8] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("ResA2.acb copied to ResA8.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for ResA2 to ResA8 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping ResA[2]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[2], "acb" );

   printf ("----- Dumping ResA[8]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[8], "acb" );

/******************************************************************
Test # 4 - Source is on the FROM side of a relation.
*******************************************************************/
printf("\n\n*** Test 4 - ResA[4] to ResA[9] Source on FROM side ***\n\n");

printf ("----- Dumping ResA[4]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = resa_objid[4];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = resa_objid[4],			
		       targetid = resa_objid[9] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("ResA4.acb copied to ResA9.acb\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for ResA4 to ResA9 : %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping ResA[4]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[4], "acb" );

   printf ("----- Dumping ResA[9]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[9], "acb" );

/******************************************************************
Test # 5 - Source is a dipole and target is a dipole.  

*******************************************************************/
printf("\n\n*** Test 5 - ResA[5] to ResA[10] Source and target are dipole ***\n\n");

printf ("----- Dumping ResA[5]'s acb channel before copy\n");
OMT_dump_relation( OM_Gw_current_OS, resa_objid[5], "acb" );

         copy_chan_args.to_sel.type = OM_e_name;
         copy_chan_args.to_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.u_sel.name = chan_resacb;
         copy_chan_args.fr_sel.type = OM_e_name;
         copy_chan_args.fr_os = OM_Gw_current_OS;
         copy_chan_args.fr_objid = resa_objid[5];

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = resa_objid[5],			
		       targetid = resa_objid[10] );

   switch(sts)
   {
      case OM_S_SUCCESS:  printf("ResA5.acb copied to ResA10\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send msg=copy_chan for ResA5 to ResA10 %x\n", sts);
         om$report_error(sts=sts);
   }


   printf ("----- Dumping ResA[5]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[5], "acb" );

   printf ("----- Dumping ResA[10]'s acb channel\n");
   OMT_dump_relation( OM_Gw_current_OS, resa_objid[10], "acb" );

printf("\n\n*********** Delete objects before exiting **************\n\n");

	sts = om$make_message(classname = "ResA",		
			      methodname = "delete",	
			      p_msg = &resadel );

     if (!(sts&1))
	{
	printf("error in om$make_message for delete of ResA: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

	sts = om$make_message(classname = "ResB",		
			      methodname = "delete",	
			      p_msg = &resbdel );

       if (!(sts&1))
	{
	printf("error in om$make_message for delete of ResB: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

       for ( i=1; i<MAXA; i++ )
	{
	 sts = om$send (msg = &resadel,
                        mode = OM_e_wrt_object,
                        senderid = resa_objid[i],
                        targetid = resa_objid[i] );

               if (!(sts&1))
		{
		printf("error in om$send msg=resadel : %d\n", sts);
		om$report_error(sts=sts);
		exit();
		}
	}

      for ( i=1; i<MAXB; i++ )
	{
	 sts = om$send (msg = &resbdel,
                        mode = OM_e_wrt_object,
                        senderid = resb_objid[i],
                        targetid = resb_objid[i] );
               if (!(sts&1))
		{
		printf("error in OM_send_object : %d\n", sts);
		om$report_error(sts=sts);
		exit();
		}
	}

}  /* main */
