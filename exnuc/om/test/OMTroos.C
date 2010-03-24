#include "OMobjectcomm.h"
#include "OMintprims.h"

#define MAXFILED	2
#define MAXOBJ		10
#define MAXTEST         3

OM_S_OBJID   fil_objids_a[MAXFILED][MAXOBJ],
             fil_objids_b[MAXFILED][MAXOBJ];
OMuword      fil_osnum[MAXFILED];
OM_S_OBJID   osobjid[MAXFILED], extra_b;
OM_S_MESSAGE assign_a, show_a, assign_b, show_b, delfil;
OM_S_MESSAGE connect_msg, disconnect_msg, rootdel;
OMuword      osndx;
int          assignment;
int          sts, i, j, k, test;
OMuint       count, num_obj_a, num_obj_b;

OM_S_OBJECT_LINKAGE         list[MAXOBJ+1];
OM_S_CHANSELECT             chansel;
   

int perform_test_scenario(n)
int  n;
{
   
   int     b, rtn;
   OMuword sav_osnum;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";

   /*=======================================*/
   /*  test om$is_objid_on_channel for B's  */
   /*=======================================*/

   for ( b=0; b<num_obj_b; b++ )
   {
      printf ("\nCalling om$is_objid_on_channel for B[1][%d] - ",b);

      rtn = om$is_objid_on_channel ( osnum_c = fil_osnum[0],
                                     objid_c = fil_objids_a[0][n],
                                     p_chanselect = &chansel,
                                     objid = fil_objids_b[1][b],
                                     osnum2 = fil_osnum[1] );
      if ( rtn == OM_W_NOTONCHAN )
      {
         printf ("not found\n");
      }
      else if ( rtn == OM_S_SUCCESS )
      {
         printf ("found\n");
      }
      else 
      {
         printf (" error from om$is_objid_on_channel\n");
         om$report_error(sts=rtn);
         exit();
      }
   }

   /*=============================*/
   /*  test om$get_channel_count  */
   /*=============================*/

   printf ("\n\nCalling om$get_channel_count for A[0][%d] - count is ",n);

   rtn = om$get_channel_count ( osnum = fil_osnum[0],
                                objid = fil_objids_a[0][n],
                                p_chanselect = &chansel,
                                count = &count );
   if (!(1&rtn))
   {
      printf (" error in om$get_channel_count\n");
      om$report_error(sts=rtn);
      exit();
   }

   printf ("%d\n",count);

   /*===============================*/
   /*  test om$get_channel_objects  */
   /*===============================*/

   printf ("\n\nCalling om$get_channel_objects for A[0][%d]\n",n);

   rtn = om$get_channel_objects ( osnum = fil_osnum[0],
                                  objid = fil_objids_a[0][n],
                                  p_chanselect = &chansel,
                                  list = list,
                                  size = num_obj_b+1,
                                  count = &count );
   if (!(1&rtn))
   {
      printf (" error in om$get_channel_objects\n");
      om$report_error(sts=rtn);
      exit();
   }

   printf ("Count of objects : %d\n",count);

   for ( b=0; b<count; b++ )
   {
      for ( k=0; k<MAXFILED; k++ )
      {
         if ( fil_osnum[k] == list[b].osnum )
         {
            osndx = k;
            break;
         }
      }

      if (IF_EQ_OBJID(extra_b,list[b].S_objid))
      {
         printf ("List[%d] is extra B - actual objid %d in OS %d\n",
                       b,extra_b,fil_osnum[osndx]);
      }
      else
      {
         for ( k=0; k<MAXOBJ; k++ )
         {
            if ( IF_EQ_OBJID(fil_objids_b[osndx][k],list[b].S_objid))
            {
               printf ("List[%d] is B[%d][%d] - actual objid %d in OS %d\n",
                       b,osndx,k,fil_objids_b[osndx][k],fil_osnum[osndx]);
               break;
            }
         }
      }
   }

   /*=======================*/
   /*  test a channel send  */
   /*=======================*/

   printf ("\n\nIssuing a channel send out A[0][%d]\n",n);

   rtn = om$send ( msg = &show_b,
                   senderid = fil_objids_a[0][n],
                   p_chanselect = &chansel,
                   targetos = fil_osnum[0] );
   if (!(1&rtn))
   {
      printf (" error in om$send (show_b) out A[0][%d]\n",n);
      om$report_error(sts=rtn);
      exit();
   }

   /*================================================*/
   /*  test a sibling send from B[1][1] and B[1][2]  */
   /*================================================*/

   chansel.u_sel.name = "bca";

   printf ("\n\nIssuing a sibling send from B[1][0]\n");

   sav_osnum = OM_Gw_current_OS;
   om$make_current_os ( osnum = fil_osnum[1] );

   rtn = om$sibling_send ( msg = &show_b,
                           senderid = fil_objids_b[1][0],
                           p_chanselect = &chansel );
   om$make_current_os ( osnum = sav_osnum );
   if (!(1&rtn))
   {
      printf (" error in om$sibling_send for B[1][0]\n");
      om$report_error(sts=rtn);
      exit();
   }
}


main()
{
   struct fil_osname_type
   {
      char s_name[15];
   } fil_osname[MAXFILED];

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

   /*==============*/
   /*  initialize  */
   /*==============*/

   system ("rm OMTroos.os0 OMTroos.os1 2>/dev/null");

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

   sts = om$make_message(classname = "OMFiledOS",
                         methodname = "delete",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &delfil );
   if (!(sts&1))
   {
      printf( "Error in om$make_message (delfil) \n");
      om$report_error(sts = sts);
      exit();
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

   sts = om$make_message ( classname = "Root",
                           methodname = "delete",
                           p_msg = &rootdel );
   if (!(1&sts))
   {
      printf (" error in om$make_message for Root.delete\n");
      om$report_error(sts=sts);
      exit();
   }

   printf("\n\n*** Creating FiledOSs ***\n\n");

   for ( i=MAXFILED-1;i>=0; i-- )
   {
      sprintf( fil_osname[i].s_name, "OMTroos.os%d", i);

      /*==========================*/
      /*  construct Filed OS      */
      /*==========================*/

      printf ("\n--------------------------------------");
      printf ("\n\nConstructing my FiledOS number %d \n", i );

      sts = om$construct_os ( classname = "OMFiledOS",		
			      osnum = &fil_osnum[i],		
			      osname = fil_osname[i].s_name,	
			      p_objid = &osobjid[i] );

      if (!(sts&1))
      {	
         printf(" error in om$construct_os \n");
         om$report_error(sts = sts);
         exit();
      }

      printf ("Actual object space number is %d \n\n", fil_osnum[i] );

      for ( j=0; j<MAXOBJ; j++ )
      {
         printf ("  constructing object A[%d] in FiledOS %d\n", j, 
                 fil_osnum[i] );

         sts = om$construct(osname = fil_osname[i].s_name,
                            classname = "A",
                            p_objid = &fil_objids_a[i][j],
                            neighbor = OM_GS_NULL_NEIGHBOR);
         if (!(sts&1))
         {
	    printf(" error in om$construct for A \n");
	    om$report_error(sts = sts);
	    exit();
	 }
         printf ("  constructing object B[%d] in FiledOS %d\n", j, 
                 fil_osnum[i] );

         sts = om$construct(osname = fil_osname[i].s_name,
                            classname = "B",
                            p_objid = &fil_objids_b[i][j],
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
                       senderid = fil_objids_a[i][j],
                       targetid = fil_objids_a[i][j],
                       targetos = fil_osnum[i] );
         if (!(sts&1))	
         {
            printf( " error in om$send (assign_a) \n");
	    om$report_error(sts = sts);
	    exit();
	 }

         sts = om$send(mode = OM_e_wrt_object,
                       msg = &show_a,
                       senderid = fil_objids_a[i][j],
                       targetid = fil_objids_a[i][j],
                       targetos = fil_osnum[i] );
         if (!(sts&1))	
	 {
	    printf( " error in om$send (show_a) \n");
            om$report_error(sts = sts);
	    exit();
         }

	 sts = om$send(mode = OM_e_wrt_object,
                       msg = &assign_b,
                       senderid = fil_objids_b[i][j],
                       targetid = fil_objids_b[i][j],
                       targetos = fil_osnum[i] );
         if (!(sts&1))	
         {
            printf( " error in om$send (assign_b) \n");
	    om$report_error(sts = sts);
	    exit();
	 }

         sts = om$send(mode = OM_e_wrt_object,
                       msg = &show_b,
                       senderid = fil_objids_b[i][j],
                       targetid = fil_objids_b[i][j],
                       targetos = fil_osnum[i] );
         if (!(sts&1))	
	 {
	    printf( " error in om$send (show_b) \n");
            om$report_error(sts = sts);
	    exit();
         }
      }
   }

   /*===================================*/
   /*  constructing the extra B object  */
   /*===================================*/

   sts = om$construct( osnum = fil_osnum[1],
                       classname = "B",
                       p_objid = &extra_b );
   if (!(sts&1))
   {
      printf(" error in om$construct for extra B \n");
      om$report_error(sts = sts);
      exit();
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
            num_obj_b = MAXOBJ;
            break;

         case 2:
            printf (">>>>>>>>>>>>>>  MANY-MANY CASE  <<<<<<<<<<<<<<\n\n");
            num_obj_a = MAXOBJ;
            num_obj_b = MAXOBJ;
            break;

         default:
            printf (" error - default test case reached\n");
            exit();
            break;
      }

      /*============================*/
      /*  connect up the test case  */
      /*============================*/

      printf ("\n\n**** Connecting the test case\n");

      for ( i=0; i<num_obj_a; i++ )
      {
         for ( j=0; j<num_obj_b; j++ )
         {
            connect_args.to_sel.type = OM_e_name;
            connect_args.to_sel.u_sel.name = "bca";
            connect_args.to_idx = 0;
            connect_args.fr_objid = fil_objids_a[0][i];
            connect_args.fr_os = fil_osnum[0];
            connect_args.fr_sel.type = OM_e_name;
            connect_args.fr_sel.u_sel.name = "acb";
            connect_args.fr_idx            = 0;

            sts = om$send (msg = &connect_msg,			
                           senderid = fil_objids_a[0][i],
                           targetid = fil_objids_b[1][j],		
		           targetos = fil_osnum[1] ); 
            if (!(sts&1))
            {
               printf(" error in om$connect for A[0][%d] to B[1][%d]\n",i,j);
               om$report_error(sts = sts);
               exit();
            }
         }
      }

      /*=========================*/
      /*  dump relation for A[0] */
      /*=========================*/

      printf ("\n\n-----------------------------------\n");
      printf ("Dumping channel info for A[0][0]\n");
    
      sts = OMT_dump_relation ( fil_osnum[0], fil_objids_a[0][0], "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }

      /*==============================================*/
      /*  delete OS[1] and read back in as Read Only  */
      /*==============================================*/

      sts = om$send ( msg = &delfil,
                      senderid = osobjid[1],
                      targetid = osobjid[1],
                      targetos = fil_osnum[1] );
      if (!(1&sts))
      {
         printf (" error in om$send OMFiledOS.delete");
         om$report_error(sts=sts);
         exit();
      }

      printf ("\n--------------------------------------");
      printf ("\nConstructing OS[1] as Read Only\n");

      sts = om$construct_os ( classname = "OMFiledOS",		
			      osnum = &fil_osnum[1],		
			      osname = fil_osname[1].s_name,	
			      p_objid = &osobjid[1],
                              loadmode = OM_e_loados_ro );
      if (!(sts&1))
      {	
         printf(" error in om$construct_os as read only \n");
         om$report_error(sts = sts);
         exit();
      }

      /*========================*/
      /*   KLUDGE for testing   */
      /*========================*/

      OM_Gw_RO_OS_count++;

      printf ("Actual object space number is %d\n",fil_osnum[1]);

      /*=================================*/
      /*  perform the tests for A[0][0]  */
      /*=================================*/
       
      printf ("\n*** Performing test scenario for A[0][0]\n");
      perform_test_scenario (0);


      for ( i=0; i<num_obj_a; i++ )
      {
         /*===================================*/
         /*  disconnect B[1][2] from A[0][0]  */
         /*===================================*/

         disconnect_args.to_sel.type = OM_e_name;
         disconnect_args.to_sel.u_sel.name = "bca";
         disconnect_args.fr_sel.type = OM_e_name;
         disconnect_args.fr_sel.u_sel.name = "acb";
         disconnect_args.fr_os = fil_osnum[0];
         disconnect_args.fr_objid = fil_objids_a[0][i];

         printf ("\n\n**** Logically disconnecting B[1][0] from A[0][%d]\n",i);

         sts = om$send (msg = &disconnect_msg,			
                        senderid = fil_objids_a[0][i],	
		        targetid = fil_objids_b[1][0],		
		        targetos = fil_osnum[1] );
         if (!(1&sts))
         {
            printf (" error in om$send (Root.disconnect) \n" );
            om$report_error(sts = sts);
            exit();
         }
      }  

      /*=========================*/
      /*  dump relation for A[0] */
      /*=========================*/

      printf ("\n\n-----------------------------------\n");
      printf ("Dumping channel info for A[0][0]\n");
    
      sts = OMT_dump_relation ( fil_osnum[0], fil_objids_a[0][0], "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }

      /*=================================*/
      /*  perform the tests for A[0][0]  */
      /*=================================*/
       
      printf ("\n*** Performing test scenario for A[0][0]\n");
      perform_test_scenario (0);

      /*===============================*/
      /*  reconnect A[0]'s to B[1][0]  */
      /*===============================*/

      for ( i=0; i<num_obj_a; i++ )
      {
         printf ("\n\n**** Reconnecting B[1][0] to A[0][%d]\n",i);

         connect_args.to_sel.type = OM_e_name;
         connect_args.to_sel.u_sel.name = "bca";
         connect_args.to_idx = 0;
         connect_args.fr_objid = fil_objids_a[0][i];
         connect_args.fr_os = fil_osnum[0];
         connect_args.fr_sel.type = OM_e_name;
         connect_args.fr_sel.u_sel.name = "acb";
         connect_args.fr_idx            = 0;

         sts = om$send (msg = &connect_msg,			
                        senderid = fil_objids_a[0][i],	
		        targetid = fil_objids_b[1][0],		
		        targetos = fil_osnum[1] );
         if (!(1&sts))
         {
            printf (" error in om$send (Root.connect) \n" );
            om$report_error(sts = sts);
            exit();
         }
      }

      /*=========================*/
      /*  dump relation for A[0] */
      /*=========================*/

      printf ("\n\n-----------------------------------\n");
      printf ("Dumping channel info for A[0][0]\n");
    
      sts = OMT_dump_relation ( fil_osnum[0], fil_objids_a[0][0], "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }

      /*=================================*/
      /*  perform the tests for A[0][0]  */
      /*=================================*/
       
      printf ("\n*** Performing test scenario for A[0][0]\n");
      perform_test_scenario (0);

      /*=========================================*/
      /*  logically connect another B to each A  */
      /*=========================================*/

      for ( i=0; i<num_obj_a; i++ )
      {
         printf ("\n\n**** Logically connecting extra B to A[0][%d]\n",i);

         connect_args.to_sel.type = OM_e_name;
         connect_args.to_sel.u_sel.name = "bca";
         connect_args.to_idx = 0;
         connect_args.fr_objid = fil_objids_a[0][i];
         connect_args.fr_os = fil_osnum[0];
         connect_args.fr_sel.type = OM_e_name;
         connect_args.fr_sel.u_sel.name = "acb";
         connect_args.fr_idx            = 0;

         sts = om$send (msg = &connect_msg,			
                        senderid = fil_objids_a[0][i],	
		        targetid = extra_b,
		        targetos = fil_osnum[1] );
         if (!(1&sts))
         {
            printf (" error in om$send (Root.connect) for extra B\n" );
            om$report_error(sts = sts);
            exit();
         }
      }

      /*=========================*/
      /*  dump relation for A[0] */
      /*=========================*/

      printf ("\n\n-----------------------------------\n");
      printf ("Dumping channel info for A[0][0]\n");
    
      sts = OMT_dump_relation ( fil_osnum[0], fil_objids_a[0][0], "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }

      /*=================================*/
      /*  perform the tests for A[0][0]  */
      /*=================================*/
       
      printf ("\n*** Performing test scenario for A[0][0]\n");
      perform_test_scenario (0);

      /*===============================================*/
      /*  delete OS[1] and read back in as Read Write  */
      /*===============================================*/

      sts = om$send ( msg = &delfil,
                      senderid = osobjid[1],
                      targetid = osobjid[1],
                      targetos = fil_osnum[1] );
      if (!(1&sts))
      {
         printf (" error in om$send OMFiledOS.delete");
         om$report_error(sts=sts);
         exit();
      }

      printf ("\n--------------------------------------");
      printf ("\nConstructing OS[1] as Read Write\n");

      sts = om$construct_os ( classname = "OMFiledOS",		
			      osnum = &fil_osnum[1],		
			      osname = fil_osname[1].s_name,	
			      p_objid = &osobjid[1] );
      if (!(sts&1))
      {	
         printf(" error in om$construct_os as read write \n");
         om$report_error(sts = sts);
         exit();
      }

      /*========================*/
      /*   KLUDGE for testing   */
      /*========================*/

      OM_Gw_RO_OS_count--;

      printf ("Actual object space number is %d\n",fil_osnum[1]);

      /*=========================*/
      /*  dump relation for A[0] */
      /*=========================*/

      printf ("\n\n-----------------------------------\n");
      printf ("Dumping channel info for A[0][0]\n");
    
      sts = OMT_dump_relation ( fil_osnum[0], fil_objids_a[0][0], "acb" );
      if (!(1&sts))
      {
         printf (" error in OMT_dump_relation\n");
         om$report_error(sts=sts);
         exit();
      }

      /*=================================*/
      /*  perform the tests for A[0][0]  */
      /*=================================*/
       
      printf ("\n*** Performing test scenario for A[0][0]\n");
      perform_test_scenario (0);

      /*==========================*/
      /*  disconnect the objects  */
      /*==========================*/

      printf ( "\n\n**** Disconnecting the objects in the test case\n\n");

      for ( i=0; i<num_obj_a; i++ )
      {
         for ( j=0; j<num_obj_b; j++ )
         {
            disconnect_args.to_sel.type = OM_e_name;
            disconnect_args.to_sel.u_sel.name = "bca";
            disconnect_args.fr_sel.type = OM_e_name;
            disconnect_args.fr_sel.u_sel.name = "acb";
            disconnect_args.fr_os = fil_osnum[0];
            disconnect_args.fr_objid = fil_objids_a[0][i];

            sts = om$send (msg = &disconnect_msg,			
	 	           senderid = fil_objids_a[0][i],	
		           targetid = fil_objids_b[1][j],		
		           targetos = fil_osnum[1] );

            if (!(1&sts))
            {
               printf (" error in om$send (Root.disconnect) \n" );
               om$report_error(sts = sts);
               exit();
            }
         }
      }
   }

   /*==================*/
   /*  delete objects  */
   /*==================*/

   printf ("\n*** Deleting all objects ***\n");
   for ( i=0; i<MAXFILED; i++ )
   {
      for ( j=0; j<MAXOBJ; j++ )
      {
         sts = om$send ( msg = &rootdel,
                         senderid = fil_objids_a[i][j],
                         targetid = fil_objids_a[i][j], 
                         targetos = fil_osnum[i] );
         if (!(1&sts))
         {
            printf (" error deleting A[%d][%d]\n",i,j);
            om$report_error(sts=sts);
            exit();
         }

         sts = om$send ( msg = &rootdel,
                         senderid = fil_objids_b[i][j],
                         targetid = fil_objids_b[i][j], 
                         targetos = fil_osnum[i] );
         if (!(1&sts))
         {
            printf (" error deleting B[%d][%d]\n",i,j);
            om$report_error(sts=sts);
            exit();
         }
      }
   }

   sts = om$send ( msg = &rootdel,
                   senderid = extra_b,
                   targetid = extra_b, 
                   targetos = fil_osnum[1] );
   if (!(1&sts))
   {
      printf (" error deleting extra B\n");
      om$report_error(sts=sts);
      exit();
   }

   /*==============================*/
   /*  delete Filed Object Spaces  */
   /*==============================*/

   printf ("\n\n*** Deleting OSs ***\n\n");

   for ( i=0; i<MAXFILED; i++ )
   {
      sts = om$send(mode = OM_e_wrt_object,
                    msg = &delfil,
                    senderid = osobjid[i],
                    targetid = osobjid[i],
                    targetos = fil_osnum[i] );
      if (!(sts&1))
      {
   	 printf( "Error in om$send (delete OS)\n");
   	 om$report_error(sts = sts);
   	 exit();
      }
   }
}
