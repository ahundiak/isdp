#include "OMobjectcomm.h"

#define MAXTRANS	2
#define MAXOBJT		10
#define MAXTEST         3

main()
{
   OM_S_OBJID   transobj[MAXTRANS], trans_objids_b[MAXTRANS][MAXOBJT];
   OM_S_OBJID   trans_objids_a[MAXTRANS][MAXOBJT],osobjid[MAXTRANS];
   OM_S_MESSAGE assign_a, show_a, assign_b, show_b, deltrans,copy_chan_msg;
   OM_S_MESSAGE connect_msg,disconnect_msg,set_operation_msg,move_chan_msg;
   OMuword      trans_osnum[MAXTRANS];
   int          assignment;
   OMuword      osndx;
   int          relindex=0;
   int          sts, i, j, k, test;
   OMuint       count, size, num_obj_a, num_obj_b;

   OM_S_OBJECT_LINKAGE         list[MAXOBJT];
   OM_S_CHANSELECT             chansel;
   
   struct trans_osname_type
   {
      char s_name[15];
   } trans_osname[MAXTRANS];

struct move_chan_struct
       {
         OM_S_CHANSELECT      to_sel;
	 OM_S_OBJID	      fr_objid;
	 OMuword              fr_os;
	 OM_S_CHANSELECT      fr_sel;
       } move_chan_args;
struct copy_chan_struct
       {
         OM_S_CHANSELECT      to_sel;
	 OM_S_OBJID	      fr_objid;
	 OMuword              fr_os;
	 OM_S_CHANSELECT      fr_sel;
       } copy_chan_args;
        
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

struct set_operation_struct
       {
	OM_S_CHANSELECT       to_sel;
	OM_S_OBJID            op2_objid;
	OMuword               op2_os;
	OM_S_CHANSELECT       op2_sel;
	OM_S_OBJID            op3_objid;
	OMuword               op3_os;
	OM_S_CHANSELECT       op3_sel;
 	char       	      operation;
	OMuword		      preserve;
       } set_operation_args;

   /*==============*/
   /*  initialize  */
   /*==============*/

   printf ("\nInitializing \n\n");

   sts = om$runtime_init(paramc = 0,
                         param_list = 0);
   if (!(sts&1))
   {
      printf( "Error in om$runtime_init \n");
      om$report_error(sts = sts);
      exit();
   }

   /*=================*/
   /*  make messages  */
   /*=================*/

   sts = om$make_message(classname = "A",
                         methodname = "assign_a",
                         size = 4,
                         p_arglist = &assignment,
                         p_msg = &assign_a );
   if (!(sts&1))
   {
      printf( "Error in om$make_message (assign_a) \n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "A",
                         methodname = "show_a",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &show_a );
   if (!(sts&1))
   {
      printf( "Error in om$make_message (show_a) \n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "B",
                         methodname = "assign_b",
                         size = 4,
                         p_arglist = &assignment,
                         p_msg = &assign_b );
   if (!(sts&1))
   {
      printf( "Error in om$make_message (assign_b) \n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "B",
                         methodname = "show_b",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &show_b );
   if (!(sts&1))
   {
      printf( "Error in om$make_message (show_b) \n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "OMTransOS",
                         methodname = "delete",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &deltrans );
   if (!(sts&1))
   {
      printf( "Error in om$make_message (deltrans) \n");
      om$report_error(sts = sts);
      exit();
   }

   printf("\n\n*** Creating TransOSs ***\n\n");

   for ( i=MAXTRANS-1;i>=0; i-- )
   {
      sprintf( trans_osname[i].s_name, "TransOS%d", i);

      /*==========================*/
      /*  construct Transient OS  */
      /*==========================*/

      printf ("\n--------------------------------------");
      printf ("\n\nConstructing my TransOS number %d \n", i );

      sts = om$construct_os ( classname = "OMTransOS",		
			      osnum = &trans_osnum[i],		
			      osname = trans_osname[i].s_name,	
			      p_objid = &osobjid[i] );

      if (!(sts&1))
      {	
         printf(" error in om$construct_os \n");
         om$report_error(sts = sts);
         exit();
      }

      printf ("Actual object space number is %d \n\n", trans_osnum[i] );

      for ( j=0; j<MAXOBJT; j++ )
      {
         printf ("  constructing object A[%d] in TransOS %d\n", j, 
                 trans_osnum[i] );

         sts = om$construct(osname = trans_osname[i].s_name,
                            classname = "A",
                            p_objid = &trans_objids_a[i][j],
                            neighbor = OM_GS_NULL_NEIGHBOR);
         if (!(sts&1))
         {
	    printf(" error in om$construct for A \n");
	    om$report_error(sts = sts);
	    exit();
	 }
         printf ("  constructing object B[%d] in TransOS %d\n", j, 
                 trans_osnum[i] );

         sts = om$construct(osname = trans_osname[i].s_name,
                            classname = "B",
                            p_objid = &trans_objids_b[i][j],
                            neighbor = OM_GS_NULL_NEIGHBOR);
         if (!(sts&1))
         {
	    printf(" error in om$construct for B \n");
	    om$report_error(sts = sts);
	    exit();
	 }
		 
	 assignment = (i)*100 + j;
 
	 sts = om$send(mode = OM_e_wrt_object,
                       msg = &assign_a,
                       senderid = trans_objids_a[i][j],
                       targetid = trans_objids_a[i][j],
                       targetos = trans_osnum[i] );
         if (!(sts&1))	
         {
            printf( " error in om$send (assign_a) \n");
	    om$report_error(sts = sts);
	    exit();
	 }

         sts = om$send(mode = OM_e_wrt_object,
                       msg = &show_a,
                       senderid = trans_objids_a[i][j],
                       targetid = trans_objids_a[i][j],
                       targetos = trans_osnum[i] );
         if (!(sts&1))	
	 {
	    printf( " error in om$send (show_a) \n");
            om$report_error(sts = sts);
	    exit();
         }

	 sts = om$send(mode = OM_e_wrt_object,
                       msg = &assign_b,
                       senderid = trans_objids_b[i][j],
                       targetid = trans_objids_b[i][j],
                       targetos = trans_osnum[i] );
         if (!(sts&1))	
         {
            printf( " error in om$send (assign_b) \n");
	    om$report_error(sts = sts);
	    exit();
	 }

         sts = om$send(mode = OM_e_wrt_object,
                       msg = &show_b,
                       senderid = trans_objids_b[i][j],
                       targetid = trans_objids_b[i][j],
                       targetos = trans_osnum[i] );
         if (!(sts&1))	
	 {
	    printf( " error in om$send (show_b) \n");
            om$report_error(sts = sts);
	    exit();
         }
      }
   }

   /*==============================*/
   /*  run actual test procedures  */
   /*==============================*/

   for ( test=0; test<MAXTEST; test++)
   {
      printf ("\n\n\n");
      printf (">>>>>>>>>>>>>>  TEST CASE %d  <<<<<<<<<<<<<<\n\n", test);
    
      /*===========================*/
      /*  determine the test case  */
      /*===========================*/

      switch (test)
      {
         case 0:
            printf (">>>>>>>>>>>>>>  DIPOLE CASE  <<<<<<<<<<<<<<\n\n");
            num_obj_a = 1;
            num_obj_b = 1;
            break;

         case 1:
            printf (">>>>>>>>>>>>>>  1-MANY CASE  <<<<<<<<<<<<<<\n\n");
            num_obj_a = 1;
            num_obj_b = MAXOBJT;
            break;

         case 2:
            printf (">>>>>>>>>>>>>>  MANY-MANY CASE  <<<<<<<<<<<<<<\n\n");
            num_obj_a = MAXOBJT;
            num_obj_b = MAXOBJT;
            break;

         default:
            printf (" error - default test case reached\n");
            exit();
            break;
      }

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );
            if (!(sts&1))
            {
               printf(" error in om$make_message connect \n" );
               om$report_error(sts = sts);
               exit();
            }
	sts = om$make_message(classname = "Root",		
			      methodname = "move_chan",		
			      size = sizeof( struct move_chan_struct),
			      p_arglist = &move_chan_args,	
			      p_msg = &move_chan_msg );
            if (!(sts&1))
            {
               printf(" error in om$make_message move_chan \n" );
               om$report_error(sts = sts);
               exit();
            }
	sts = om$make_message(classname = "Root",		
			      methodname = "copy_chan",		
			      size = sizeof( struct copy_chan_struct),
			      p_arglist = &copy_chan_args,	
			      p_msg = &copy_chan_msg );
            if (!(sts&1))
            {
               printf(" error in om$make_message copy_chan \n" );
               om$report_error(sts = sts);
               exit();
            }
	sts = om$make_message(classname = "Root",		
			      methodname = "disconnect",		
			      size = sizeof( struct disconnect_struct),
			      p_arglist = &disconnect_args,	
			      p_msg = &disconnect_msg );
            if (!(sts&1))
            {
               printf(" error in om$make_message disconnect \n" );
               om$report_error(sts = sts);
               exit();
            }
	sts = om$make_message(classname = "Root",		
			      methodname = "set_operation",		
			      size = sizeof( struct set_operation_struct),
			      p_arglist = &set_operation_args,	
			      p_msg = &set_operation_msg );
            if (!(sts&1))
            {
               printf(" error in om$make_message set_operation \n" );
               om$report_error(sts = sts);
               exit();
            }
      /*============================*/
      /*  connect up the test case  */
      /*============================*/

      for ( i=0; i<num_obj_a; i++ )
      {
         for ( j=0; j<num_obj_b; j++ )
         {
            printf ("---------------------------------\n");
            printf ("Connecting A[0][%d] with B[1][%d] \n\n", i, j );

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = "bca";
	connect_args.to_idx = 0;
	connect_args.fr_objid = trans_objids_a[0][i];
	connect_args.fr_os = trans_osnum[0];
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = "acb";
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = trans_objids_a[0][i],			
		       targetid = trans_objids_b[1][j],		
		       targetos = trans_osnum[1] ); 
        if (!(sts&1))
        {
               printf(" error in om$connect  \n" );
               om$report_error(sts = sts);
               exit();
         }
       }
     }

      /*=======================================*/
      /*  perform the channel support testing  */
      /*=======================================*/

      for ( k=0; k<num_obj_a; k++ )
      {
         /*=====================*/
         /*  dump the relation  */
         /*=====================*/

         printf ("\n\n------------------------------- \n");       
         printf ("Dumping relation given A[0][%d] \n", k);

         sts =OMT_dump_relation(trans_osnum[0],trans_objids_a[0][k],"acb");
         if (!(1&sts))
         {
            printf (" error in OMT_dump_relation \n" );
            om$report_error(sts = sts);
            exit();
         }

         /*=====================================*/
         /*  perform is objid on channel tests  */
         /*=====================================*/

         printf ("\n\n-----------------------------------------------\n");
         printf ("Performing is objid on channel tests for A[0][%d]\n",k);

         for ( i=0; i<num_obj_b; i++)
         {
            printf ("\nCalling om$is_objid_on_channel for B[1][%d] - ",i);
         
            chansel.type = OM_e_name;
            chansel.u_sel.name = "acb";
            sts = om$is_objid_on_channel(osnum_c = trans_osnum[0],
                                         objid_c = trans_objids_a[0][k],
				         p_chanselect = &chansel,
                                         objid = trans_objids_b[1][i],
                                         osnum2 = trans_osnum[1]);
            if ( sts == OM_W_NOTONCHAN )
            {
               printf ("not found \n");
            }
            else if ( sts == OM_S_SUCCESS )
            {
               printf ("found \n");
            }
            else
            {
               printf (" error in om$is_objid_on_channel : iter %d\n", i);
               om$report_error(sts = sts);
               exit();
            }
         }

         /*===================================*/
         /*  perform get channel count tests  */
         /*===================================*/

         printf("\n\n-------------------------------------------------\n");
         printf("Calling om$get_channel_count A[0][%d]\n",k);
         chansel.type = OM_e_name;
         chansel.u_sel.name = "acb";
         sts = om$get_channel_count(osnum = trans_osnum[0],
                                    objid = trans_objids_a[0][k],
                                    p_chanselect = &chansel,
                                    count = &count );
         if (!(1&sts))
         {
            printf (" error in om$get_channel_count (this side) \n");
            om$report_error(sts = sts);
            exit();
         }
         printf ("Channel count : %d\n", count );

         /*====================================*/
         /*  perform get channel object tests  */
         /*====================================*/

         printf ( "\n\n-------------------------------------------- \n");
         printf ( "Calling om$get_channel_objects for A[0][%d]\n",k);
         chansel.type = OM_e_name;
         chansel.u_sel.name = "acb";
         sts = om$get_channel_objects(osnum = trans_osnum[0],
                                      objid = trans_objids_a[0][k],
                                      p_chanselect = &chansel,
                                      list = list,
                                      size = num_obj_b,
                                      count = &count );
         if (!(1&sts))
         {
            printf (" error in om$get_channel_objects \n");
            om$report_error(sts = sts);
            exit();
         }

         printf ("Count of objects : %d\n", count );

         for ( i=0; i<count; i++ )
         {
            for ( j=0; j<MAXTRANS; j++ )
            {
               if ( trans_osnum[j] == list[i].osnum ) 
               {
                  osndx = j;
                  break;
               }
            }

            for ( j=0; j<MAXOBJT; j++ )
            {
               if (IF_EQ_OBJID(trans_objids_b[osndx][j],list[i].S_objid))
               {
               printf("List[%d] is B[%d][%d] - actual objid %d from OSnum %d\n"
                     ,i,osndx,j, trans_objids_b[osndx][j] ,
                      trans_osnum[osndx]);
                  break;
               }
            }
         }

         /*=============================*/
         /*  perform move channel test  */
         /*=============================*/

         if ( test < 2 )
         {
            printf ("\n\n---------------------------------------------\n");
            printf ("Sending Root.copy_chan for A[0][0] to A[0][2]\n");

	copy_chan_args.to_sel.type = OM_e_name;
	copy_chan_args.to_sel.u_sel.name = "acb";
	copy_chan_args.fr_objid = trans_objids_a[0][0];
	copy_chan_args.fr_os = trans_osnum[0];
	copy_chan_args.fr_sel.type = OM_e_name;
	copy_chan_args.fr_sel.u_sel.name = "acb";

	sts = om$send (msg = &copy_chan_msg,			
		       senderid = trans_objids_a[0][0],			
		       targetid = trans_objids_a[0][2],
                       targetos = trans_osnum[0] );

            if (!(1&sts))
            {
               printf (" error in Root.copy_chan \n");
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][0]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][0],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][2]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][2],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\n\n---------------------------------------------\n");
            printf ("Sending Root.set_operations for Difference \n");
            printf ("  for A[0][0] and A[0][2] result in A[0][3]\n\n");

	set_operation_args.to_sel.type = OM_e_name;
	set_operation_args.to_sel.u_sel.name = "acb";
	set_operation_args.op2_objid = trans_objids_a[0][0];
	set_operation_args.op2_os = trans_osnum[0];
	set_operation_args.op2_sel.type = OM_e_name;
	set_operation_args.op2_sel.u_sel.name = "acb";
	set_operation_args.op3_objid = trans_objids_a[0][2];
	set_operation_args.op3_os = trans_osnum[0];
	set_operation_args.op3_sel.type = OM_e_name;
	set_operation_args.op3_sel.u_sel.name = "acb";
	set_operation_args.operation            = 'd';
	set_operation_args.preserve             = 1;

	sts = om$send (msg = &set_operation_msg,			
		       senderid = trans_objids_a[0][3],			
		       targetid = trans_objids_a[0][3],		
		       targetos = trans_osnum[0] ); 

            if (!(1&sts))
            {
               printf (" error in Root.set_operations (D) \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][0]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][0],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][2]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][2],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][3]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][3],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }
            

            printf ("\n\n---------------------------------------------\n");
            printf ("Sending Root.set_operations for Union \n");
            printf ("  for A[0][0] and A[0][2] result in A[0][4]\n\n");

	set_operation_args.to_sel.u_sel.name = "acb";
	set_operation_args.op2_objid = trans_objids_a[0][0];
	set_operation_args.op2_os = trans_osnum[0];
	set_operation_args.op2_sel.type = OM_e_name;
	set_operation_args.op2_sel.u_sel.name = "acb";
	set_operation_args.op3_objid = trans_objids_a[0][2];
	set_operation_args.op3_os = trans_osnum[0];
	set_operation_args.op3_sel.type = OM_e_name;
	set_operation_args.op3_sel.u_sel.name = "acb";
	set_operation_args.operation            = 'u';
	set_operation_args.preserve             = 1;

	sts = om$send (msg = &set_operation_msg,			
		       senderid = trans_objids_a[0][4],			
		       targetid = trans_objids_a[0][4],		
		       targetos = trans_osnum[0] ); 

            if (!(1&sts))
            {
               printf (" error in Root.set_operations (D) \n" );
               om$report_error(sts = sts);
               exit();
            }
            printf ("\nDumping the relation giving A[0][0]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][0],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][2]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][2],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][4]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][4],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }
            
            printf ("\n\n---------------------------------------------\n");
            printf ("Sending Root.set_operation for Intersection\n");
            printf ("  for A[0][0] and A[0][2] result in A[0][5]\n\n");

	set_operation_args.to_sel.u_sel.name = "acb";
	set_operation_args.op2_objid = trans_objids_a[0][0];
	set_operation_args.op2_os = trans_osnum[0];
	set_operation_args.op2_sel.type = OM_e_name;
	set_operation_args.op2_sel.u_sel.name = "acb";
	set_operation_args.op3_objid = trans_objids_a[0][2];
	set_operation_args.op3_os = trans_osnum[0];
	set_operation_args.op3_sel.type = OM_e_name;
	set_operation_args.op3_sel.u_sel.name = "acb";
	set_operation_args.operation            = 'i';
	set_operation_args.preserve             = 1;

	sts = om$send (msg = &set_operation_msg,			
		       senderid = trans_objids_a[0][5],			
		       targetid = trans_objids_a[0][5],		
		       targetos = trans_osnum[0] ); 

            if (!(1&sts))
            {
               printf (" error in Root.set_operations (I) \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][0]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][0],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][2]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][2],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][5]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][5],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

           printf ("\n\n--------------------------------------------\n");
           printf ("Sending Root.move_chan for A[0][0] to A[0][1]\n\n");

	move_chan_args.to_sel.type = OM_e_name;
	move_chan_args.to_sel.u_sel.name = "acb";
	move_chan_args.fr_objid = trans_objids_a[0][0];
	move_chan_args.fr_os = trans_osnum[0];
	move_chan_args.fr_sel.type = OM_e_name;
	move_chan_args.fr_sel.u_sel.name = "acb";

	sts = om$send (msg = &move_chan_msg,			
		       senderid = trans_objids_a[0][0],			
		       targetid = trans_objids_a[0][1],
                       targetos = trans_osnum[0] );

            if (!(1&sts))
            {
               printf (" error in Root.move_chan \n");
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][0]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][0],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }

            printf ("\nDumping the relation giving A[0][1]\n\n");

            sts = OMT_dump_relation(trans_osnum[0],trans_objids_a[0][1],"acb");
            if (!(1&sts))
            {
               printf (" error in OMT_dump_relation \n" );
               om$report_error(sts = sts);
               exit();
            }
         }
      }

      /*==========================*/
      /*  disconnect the objects  */
      /*==========================*/

      printf ( "\nDisconnecting the objects\n\n");

      for ( i=0; i<num_obj_a; i++ )
      {
         for ( j=0; j<num_obj_b; j++ )
         {
           printf ("------------------------------------\n");
           printf ("Disconnecting A[0][%d] from B[1][%d]\n\n",	
				                     (test<2)?i+1:i,j  );
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = "bca";
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = "acb";
     disconnect_args.fr_os = trans_osnum[0];
     disconnect_args.fr_objid = trans_objids_a[0][(test<2)?i+1:i];

	sts = om$send (msg = &disconnect_msg,			
		       senderid = trans_objids_a[0][(test<2)?i+1:i],	
		       targetid = trans_objids_b[1][j],		
		       targetos = trans_osnum[1] );

            if (!(1&sts))
            {
               printf (" error in om$send (Root.disconnect) \n" );
               om$report_error(sts = sts);
               exit();
            }
         }
      }
      
      if ( test < 2 )
      {
         for ( i=2; i<6; i++)
         {
            if ( i == 3 ) continue;
            for ( j=0; j<num_obj_b; j++ )
            {
               printf ("------------------------------------\n");
               printf ("Disconnecting A[0][%d] from B[1][%d]\n\n",i,j);

     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = "bca";
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = "acb";
     disconnect_args.fr_os = trans_osnum[0];
     disconnect_args.fr_objid = trans_objids_a[0][i];

	sts = om$send (msg = &disconnect_msg,			
		       senderid = trans_objids_a[0][i],	
		       targetid = trans_objids_b[1][j],		
		       targetos = trans_osnum[1] );

               if (!(1&sts))
               {
                  printf (" error in om$send (Root.disconnect) \n" );
                  om$report_error(sts = sts);
                  exit();
               }
            }
         }
      }
   }

   /*==========================*/
   /*  end of test procedures  */
   /*==========================*/

   printf ("\n\n*** Deleting OSs ***\n\n");

   for ( i=0; i<MAXTRANS; i++ )
   {
      sts = om$send(mode = OM_e_wrt_object,
                    msg = &deltrans,
                    senderid = osobjid[i],
                    targetid = osobjid[i],
                    targetos = trans_osnum[i] );
      if (!(sts&1))
      {
   	 printf( "Error in om$send (delete OS)\n");
   	 om$report_error(sts = sts);
   	 exit();
      }
   }
}
