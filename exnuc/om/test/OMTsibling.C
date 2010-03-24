#include "OMobjectcomm.h"
#define MAXO 10

main()
{
   int                 sts, i, zro=0;
   OM_S_OBJID          a_objid, a2_objid, b_objid[MAXO], c_objid[MAXO],
		       resa_objid, resa2_objid, resb_objid[MAXO];
   OM_S_MESSAGE        wild_disconnect_msg;
   OM_S_MESSAGE        connect_msg,ass_a, ass_b, sho_a, sho_b,
			ass_resa, ass_resb, sho_resa, sho_resb,
			ass_c, sho_c, debug_msg;
   char                *chan_acb,*chan_bca, *reschan_acb, *reschan_bca,
		       *chan_A_acs,*chan_sca,*chan_ResA_acs;
   OM_S_CHANNUM        chan_a, chan_b, chan_resa, chan_resb, chan_c,
		       chan_R_acs, chan_NR_acs;
   OM_S_CHANSELECT     chansel;

struct connect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 uword                fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
       } connect_args;
struct wild_disconnect_struct
       {
	 OM_S_CHANSELECT      to_sel;
       } wild_disconnect_args;

   /*==============*/
   /*  initialize  */
   /*==============*/

   printf ("\n----- Initializing \n");

   sts = om$runtime_init();
   if (!(sts&1))
   {
      printf (" error in om$runtine_init\n" );
      om$report_error(sts=sts);
      exit();
   }

/*===================================================*/
/* Test sibling send for nonrestricted only channels */
/*===================================================*/

   chan_acb = "A.acb";
   chan_bca = "B.bca";

   /*================================*/
   /*  construct the instances of A  */
   /*================================*/

   printf ("\n----- Constructing A \n");

   sts = om$construct( osname="OM_TransOS_0",
                       classname="A",
                       p_objid=&a_objid);

   if (!(sts&1))
   {
      printf (" error in om$construct for A\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Constructing A2 \n");

   sts = om$construct( osname="OM_TransOS_0",
                       classname="A",
                       p_objid=&a2_objid);

   if (!(sts&1))
   {
      printf (" error in om$construct for A2\n");
      om$report_error(sts=sts);
      exit();
   }

   /*===================================================*/
   /*  convert the channel names in A and B to numbers  */
   /*===================================================*/

   printf ("\n----- Converting the channel names to numbers \n");
   sts = om$get_channel_number ( channame = chan_acb, p_channum = &chan_a);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_number for acb\n");
      om$report_error(sts=sts);
      exit();
   }
   sts = om$get_channel_number ( channame = chan_bca, p_channum = &chan_b);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_number for bca\n");
      om$report_error(sts=sts);
      exit();
   }

   /*=======================================*/
   /*  fill the relation with MAXO objects  */
   /*=======================================*/

   printf ("\n----- Constructing the B's \n");

   for ( i=0; i<MAXO; i++ )
   {
      sts = om$construct ( osname="OM_TransOS_0",
                           classname="B",
                           p_objid=&b_objid[i]);

    if (!(sts&1))
      {
         printf(" error in om$construct for B\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

   } /* for */


   /*=======================================*/
   /*  assign an identifer to each b_objid  */
   /*=======================================*/

	sts = om$make_message(classname = "B",		
			      methodname = "assign_b",		
			      size = 4,
			      p_arglist = &i,	
			      p_msg = &ass_b     );

   if (!(1&sts))
   {
      printf (" error in om$make_message (ass_b)\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Assigning an identifier for each instance of B \n");

   for ( i=0; i<MAXO; i++ )
   {
	sts = om$send (msg = &ass_b,
		       senderid = a_objid,			
		       targetid = b_objid[i] );
    
      if (!(1&sts))
      {
         printf (" error in om$send (ass_b)\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );

   /*================================*/
   /*  connect half of the B's to A  */
   /*================================*/

   for ( i=0; i<MAXO/2; i++ )
   {
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid,			
		       targetid = b_objid[i] );

      if (!(sts&1))
      {
         printf (" error in om$send msg=connect for B\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping A's channel after connect number %d\n\n", i+1);
 
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

   /*=================================*/
   /*  connect half of the B's to A2  */
   /*=================================*/

   for ( i=MAXO/2; i<MAXO; i++ )
   {
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a2_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a2_objid,			
		       targetid = b_objid[i] );

      if (!(sts&1))
      {
         printf (" error in om$send msg=connect for B\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping A2's channel after connect number %d\n\n", i+1);
 
      sts = OMT_dump_relation ( OM_Gw_current_OS, a2_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

   /*=========================================================*/
   /*  Now connect A2 with B[2] to connect the two relations  */
   /*=========================================================*/

   printf ("\n----- Connecting A2 with B[2]\n");

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = chan_bca;
   connect_args.to_idx = OM_K_MAXINT;
   connect_args.fr_objid = a2_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = chan_acb;
   connect_args.fr_idx            = 0;

   sts = om$send (msg = &connect_msg,			
                  senderid = a2_objid,			
		  targetid = b_objid[2] );

   if (!(sts&1))
   {
      printf (" error in om$send msg=connect for B\n");
      om$report_error(sts=sts);
      printf (" iteration : %d \n", i );
      exit();
   }

   printf("\n----- Dumping A2's channel after connecting B[2]\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, a2_objid, "acb" );
   if (!(1&sts))
   {
      printf (" error in OMT_dump_relation\n");
      om$report_error(sts=sts);
      exit();
   }

   /*==================================*/
   /*  prepare to issue sibling sends  */
   /*==================================*/
	sts = om$make_message(classname = "B",		
			      methodname = "show_b",
			      p_msg = &sho_b );

   if (!(1&sts))
   {
      printf (" error in om$make_message (show_b)\n");
      om$report_error(sts=sts);
      exit();
   }

   /*===================================================*/
   /*  issue a sibling send via b_objid[2] - exclusive  */
   /*===================================================*/

   printf("\n----- Issuing a sibling send for B's from B[2] (excl) \n");

   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_bca;
   sts = om$sibling_send ( msg = &sho_b,
                           senderid = b_objid[2],
                           p_chanselect = &chansel,
                           inclusive = OM_e_exclusive );
   if (!(1&sts))
   {
      printf (" error in om$sibling_send (excl)\n");
      om$report_error(sts=sts);
      exit();
   }

   /*===================================================*/
   /*  issue a sibling send via b_objid[4] - inclusive  */
   /*===================================================*/

   printf ("\n----- Issuing a sibling send for B's from B[4] (inc) \n");
   
   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_bca;
   sts = om$sibling_send ( msg = &sho_b,
                           senderid = b_objid[4],
                           p_chanselect = &chansel,
                           inclusive = OM_e_inclusive );
   if (!(1&sts))
   {
      printf (" error in om$sibling_send (inc)\n");
      om$report_error(sts=sts);
      exit();
   }

   /*==================================================================*/
   /*  now disconnect them and the relation should dynamically shrink  */
   /*==================================================================*/
      sts = om$make_message(classname = "Root",		
			    methodname = "wild_disconnect",		
			    size = sizeof( struct wild_disconnect_struct),
			    p_arglist = &wild_disconnect_args,	
		            p_msg = &wild_disconnect_msg );

   for ( i=0; i<MAXO; i++)
   {
       wild_disconnect_args.to_sel.type = OM_e_num;
       wild_disconnect_args.to_sel.u_sel.number = chan_b;

       sts = om$send (msg=&wild_disconnect_msg,
                      senderid=b_objid[i],
		      targetid=b_objid[i]);
      if (!(1&sts))
      {
         printf("error in om$send msg=wild_disconnect for B\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping A's channel after disconnect number %d\n\n",i+1);
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }

      printf("\n----- Dumping A2's channel after disconnect number %d\n\n",i+1);
      sts = OMT_dump_relation ( OM_Gw_current_OS, a2_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

/*================================================*/
/* Test sibling send for restricted only channels */
/*================================================*/

   reschan_acb = "ResA.acb";
   reschan_bca = "ResB.bca";

   /*===================================*/
   /*  construct the instances of ResA  */
   /*===================================*/

   printf ("\n----- Constructing ResA \n");

   sts = om$construct( osname="OM_TransOS_0",
                       classname="ResA",
                       p_objid=&resa_objid);

   if (!(sts&1))
   {
      printf (" error in om$construct for ResA\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Constructing ResA2 \n");

   sts = om$construct( osname="OM_TransOS_0",
                       classname="ResA",
                       p_objid=&resa2_objid);

   if (!(sts&1))
   {
      printf (" error in om$construct for ResA2\n");
      om$report_error(sts=sts);
      exit();
   }

   /*=========================================================*/
   /*  convert the channel names in ResA and ResB to numbers  */
   /*=========================================================*/

   printf ("\n----- Converting the channel names to numbers \n");
   sts = om$get_channel_number ( channame=reschan_acb, p_channum=&chan_resa);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_number for restricted acb\n");
      om$report_error(sts=sts);
      exit();
   }
   sts = om$get_channel_number ( channame=reschan_bca, p_channum=&chan_resb);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_number for restricted bca\n");
      om$report_error(sts=sts);
      exit();
   }

   /*=======================================*/
   /*  fill the relation with MAXO objects  */
   /*=======================================*/

   printf ("\n----- Constructing the restricted B's \n");

   for ( i=0; i<MAXO; i++ )
   {
      sts = om$construct ( osname="OM_TransOS_0",
                           classname="ResB",
                           p_objid=&resb_objid[i]);

    if (!(sts&1))
      {
         printf(" error in om$construct for restricted B\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

   } /* for */


   /*=======================================*/
   /*  assign an identifer to each b_objid  */
   /*=======================================*/

	sts = om$make_message(classname = "ResB",
			      methodname = "assign_b",
			      size = 4,
			      p_arglist = &i,	
			      p_msg = &ass_resb     );

   if (!(1&sts))
   {
      printf (" error in om$make_message (ass_resb)\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Assigning an identifier for each instance of ResB \n");

   for ( i=0; i<MAXO; i++ )
   {
	sts = om$send (msg = &ass_resb,
		       senderid = resa_objid,		
		       targetid = resb_objid[i] );
    
      if (!(1&sts))
      {
         printf (" error in om$send (ass_resb)\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }


   /*======================================*/
   /*  connect half of the ResB's to ResA  */
   /*======================================*/

   for ( i=0; i<MAXO/2; i++ )
   {
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = reschan_bca;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = resa_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = reschan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid,
		       targetid = resb_objid[i] );

      if (!(sts&1))
      {
         printf (" error in om$send msg=connect for ResB\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping ResA's channel after connect number %d\n\n", i+1);
 
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

   /*=======================================*/
   /*  connect half of the ResB's to ResA2  */
   /*=======================================*/

   for ( i=MAXO/2; i<MAXO; i++ )
   {
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = reschan_bca;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = resa2_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = reschan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa2_objid,
		       targetid = resb_objid[i] );

      if (!(sts&1))
      {
         printf (" error in om$send msg=connect for ResB\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping ResA2's channel after connect number %d\n\n", i+1);
 
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa2_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

   /*=========================================================*/
   /*  Now connect ResA2 with ResB[2] to connect the two relations  */
   /*=========================================================*/

   printf ("\n----- Connecting ResA2 with ResB[2]\n");

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = reschan_bca;
   connect_args.to_idx = OM_K_MAXINT;
   connect_args.fr_objid = resa2_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = reschan_acb;
   connect_args.fr_idx            = 0;

   sts = om$send (msg = &connect_msg,			
                  senderid = resa2_objid,
		  targetid = resb_objid[2] );

   if (!(sts&1))
   {
      printf (" error in om$send msg=connect for ResB\n");
      om$report_error(sts=sts);
      printf (" iteration : %d \n", i );
      exit();
   }

   printf("\n----- Dumping ResA2's channel after connecting ResB[2]\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resa2_objid, "acb" );
   if (!(1&sts))
   {
      printf (" error in OMT_dump_relation\n");
      om$report_error(sts=sts);
      exit();
   }

   /*==================================*/
   /*  prepare to issue sibling sends  */
   /*==================================*/
	sts = om$make_message(classname = "ResB",
			      methodname = "show_b",
			      p_msg = &sho_resb );

   if (!(1&sts))
   {
      printf (" error in om$make_message (show_resb)\n");
      om$report_error(sts=sts);
      exit();
   }

   /*===================================================*/
   /*  issue a sibling send via resb_objid[2] - exclusive  */
   /*===================================================*/

   printf("\n----- Issuing a sibling send for ResB's from ResB[2] (excl) \n");

   chansel.type = OM_e_name;
   chansel.u_sel.name = reschan_bca;
   sts = om$sibling_send ( msg = &sho_resb,
                           senderid = resb_objid[2],
                           p_chanselect = &chansel,
                           inclusive = OM_e_exclusive );
   if (!(1&sts))
   {
      printf (" error in om$sibling_send (excl)\n");
      om$report_error(sts=sts);
      exit();
   }

   /*======================================================*/
   /*  issue a sibling send via resb_objid[4] - inclusive  */
   /*======================================================*/

   printf ("\n----- Issuing a sibling send for ResB's from ResB[4] (inc) \n");
   
   chansel.type = OM_e_name;
   chansel.u_sel.name = reschan_bca;
   sts = om$sibling_send ( msg = &sho_resb,
                           senderid = resb_objid[4],
                           p_chanselect = &chansel,
                           inclusive = OM_e_inclusive );
   if (!(1&sts))
   {
      printf (" error in om$sibling_send (inc)\n");
      om$report_error(sts=sts);
      exit();
   }

   /*==================================================================*/
   /*  now disconnect them and the relation should dynamically shrink  */
   /*==================================================================*/

   for ( i=0; i<MAXO; i++)
   {
       wild_disconnect_args.to_sel.type = OM_e_num;
       wild_disconnect_args.to_sel.u_sel.number = chan_resb;

       sts = om$send (msg=&wild_disconnect_msg,
                      senderid=resb_objid[i],
		      targetid=resb_objid[i]);
      if (!(1&sts))
      {
         printf("error in om$send msg=wild_disconnect for ResB\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping ResA's channel after disconnect number %d\n\n",i+1);
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }

      printf("\n----- Dumping ResA2's channel after disconnect number %d\n\n",i+1);
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa2_objid, "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

/*===============================================*/
/* Test sibling send with mixture of restricted  */
/* and nonrestricted channels                    */
/*===============================================*/

   chan_A_acs = "A.acs";
   chan_sca = "C.sca";
   chan_ResA_acs = "ResA.acs";

   /*=========================================================*/
   /*  convert the channel names in A, ResA and C to numbers  */
   /*=========================================================*/

   printf ("\n----- Converting the channel names to numbers \n");
   sts = om$get_channel_number ( channame=chan_A_acs, p_channum=&chan_NR_acs);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_number for class A's acs\n");
      om$report_error(sts=sts);
      exit();
   }
   sts = om$get_channel_number ( channame=chan_sca, p_channum=&chan_c);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_number for restricted sca\n");
      om$report_error(sts=sts);
      exit();
   }
   sts = om$get_channel_number ( channame=chan_ResA_acs,
				 p_channum=&chan_R_acs);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_number for restricted sca\n");
      om$report_error(sts=sts);
      exit();
   }

   /*=======================================*/
   /*  fill the relation with MAXO objects  */
   /*=======================================*/

   printf ("\n----- Constructing the C's \n");

   for ( i=0; i<MAXO; i++ )
   {
      sts = om$construct ( osname="OM_TransOS_0",
                           classname="C",
                           p_objid=&c_objid[i]);

    if (!(sts&1))
      {
         printf(" error in om$construct for C\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

   } /* for */
   /*=======================================*/
   /*  assign an identifer to each b_objid  */
   /*=======================================*/

	sts = om$make_message(classname = "C",
			      methodname = "assign_c",
			      size = 4,
			      p_arglist = &i,	
			      p_msg = &ass_c );

   if (!(1&sts))
   {
      printf (" error in om$make_message (ass_c)\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Assigning an identifier for each instance of C \n");

   for ( i=0; i<MAXO; i++ )
   {
	sts = om$send (msg = &ass_c,
		       senderid = a_objid,			
		       targetid = c_objid[i] );
    
      if (!(1&sts))
      {
         printf (" error in om$send (ass_c)\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }

   /*================================*/
   /*  connect half of the B's to A  */
   /*================================*/

   for ( i=0; i<MAXO/2; i++ )
   {
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_sca;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = a_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_A_acs;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid,			
		       targetid = c_objid[i] );

      if (!(sts&1))
      {
         printf (" error in om$send msg=connect for C\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping A's channel after connect number %d\n\n", i+1);
 
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid, "acs" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

   /*===================================*/
   /*  connect half of the C's to ResA  */
   /*===================================*/

   for ( i=MAXO/2; i<MAXO; i++ )
   {
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_sca;
	connect_args.to_idx = OM_K_MAXINT;
	connect_args.fr_objid = resa_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_ResA_acs;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid,			
		       targetid = c_objid[i] );

      if (!(sts&1))
      {
         printf (" error in om$send msg=connect for C\n");
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }

      printf("\n----- Dumping ResA's channel after connect number %d\n\n", i+1);
 
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid, "acs" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }
   }

   /*===========================================================*/
   /*  Now connect ResA with C[2] to connect the two relations  */
   /*===========================================================*/

   printf ("\n----- Connecting ResA with C[2]\n");

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = chan_sca;
   connect_args.to_idx = OM_K_MAXINT;
   connect_args.fr_objid = resa_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = chan_ResA_acs;
   connect_args.fr_idx            = 0;

   sts = om$send (msg = &connect_msg,			
                  senderid = resa_objid,
		  targetid = c_objid[2] );

   if (!(sts&1))
   {
      printf (" error in om$send msg=connect for C\n");
      om$report_error(sts=sts);
      printf (" iteration : %d \n", i );
      exit();
   }

   printf("\n----- Dumping ResA's channel after connecting C[2]\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid, "acs" );
   if (!(1&sts))
   {
      printf (" error in OMT_dump_relation\n");
      om$report_error(sts=sts);
      exit();
   }

   /*==================================*/
   /*  prepare to issue sibling sends  */
   /*==================================*/
	sts = om$make_message(classname = "C",
			      methodname = "show",
			      p_msg = &sho_c );

   if (!(1&sts))
   {
      printf (" error in om$make_message (show_c)\n");
      om$report_error(sts=sts);
      exit();
   }

	sts = om$make_message(classname = "Root",
			      methodname = "debug",
			      p_msg = &debug_msg );

   if (!(1&sts))
   {
      printf (" error in om$make_message (debug)\n");
      om$report_error(sts=sts);
      exit();
   }

   /*===================================================*/
   /*  issue a sibling send via c_objid[2] - exclusive  */
   /*===================================================*/

   printf("\n----- Issuing a sibling send for C's from C[2] (excl) \n");

   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_sca;
   sts = om$sibling_send ( msg = &sho_c,
                           senderid = c_objid[2],
                           p_chanselect = &chansel,
                           inclusive = OM_e_exclusive );
   if (!(1&sts))
   {
      printf (" error in om$sibling_send (excl)\n");
      om$report_error(sts=sts);
      exit();
   }
   /*===================================================*/
   /*  issue a sibling send via resa_objid - inclusive  */
   /*===================================================*/

   printf("\n----- Issuing a sibling send for A & ResA's from ResA (incl) \n");

   chansel.type = OM_e_name;
   chansel.u_sel.name = chan_ResA_acs;
   sts = om$sibling_send ( msg = &debug_msg,
                           senderid = resa_objid,
                           p_chanselect = &chansel,
                           inclusive = OM_e_inclusive );
   if (!(1&sts))
   {
      printf (" error in om$sibling_send (incl)\n");
      om$report_error(sts=sts);
      exit();
   }
}

