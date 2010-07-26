#include "OMobjectcomm.h"
#include "stdio.h"

#define MAXB 5
#define MAXA 5

main()
{
   int                sts, i, zro=0;
   OM_S_OBJID         a_objid[MAXA], b_objid[MAXB];
   OM_S_OBJID         resa_objid[MAXA], resb_objid[MAXB];
   uword              chan_a, chan_b, count, siz, chan_resa, chan_resb;
   char               *chan_acb, *chan_bca, *chan_resacb, *chan_resbca,
                      *chan_resacbc, *chan_resacany;
   int		      relindex=0, to=0, from=0;
   uword	      minorchan=0;
   OM_S_MESSAGE       disconnect_msg,connect_msg,showb,showresb;
   OM_S_CHANSELECT    chansel;

   struct connect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 OMuword              fr_os;
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
      printf (" error in om$runtine_init : %x \n", sts );
      om$report_error(sts=sts);
      exit();
   }

   chan_acb = "A.acb";
   chan_bca = "B.bca";

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct ( osname="OM_TransOS_0",classname= "A",    
                 p_objid= &a_objid[i],neighbor=OM_GS_NULL_NEIGHBOR);

      if (!(sts&1))
      {
         printf (" error in om$construct for A : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }
   printf("created %d A objids \n", MAXA);

   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct ( osname="OM_TransOS_0",classname= "B",     
               p_objid= &b_objid[i],neighbor=OM_GS_NULL_NEIGHBOR);

      if (!(sts&1))
      {
         printf (" error in om$construct for B : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */
   printf("created %d B objids \n", MAXB);


/* Singleton:Singleton Connect */


	connect_args.to_sel.type       = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx            = 0;
	connect_args.fr_objid          = a_objid[0];
	connect_args.fr_os             = OM_Gw_current_OS;
	connect_args.fr_sel.type       = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );

        if (!(sts&1))
        {
            printf("\nerror in om$make_message for connect: %x \n",sts);
            om$report_error(sts=sts);
            exit();
        }
	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[0] );
      
      if (!(sts&1))
      {
         printf (" error in om$send connect for B : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected s:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = om$make_message(classname="B",methodname="show_b",       
                            p_msg=&showb);
      if(!(sts&1))
      {
         printf (" error in om$make_message for showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send for showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


     
/* Connect A[0] to B[1]:  Dipole:Singleton */


	connect_args.to_sel.type       = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx            = 0;
	connect_args.fr_objid          = a_objid[0];
	connect_args.fr_os             = OM_Gw_current_OS;
	connect_args.fr_sel.type       = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[1] );

   switch(sts=sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A0 connected to B1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("B1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send_message connect A0 to B1 : %x\n", sts);
         om$report_error(sts=sts);
   }
      printf("\nconnected d:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg= showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
 

/* Disconnect B1 from A[0]:  case 2 f:t */


     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_bca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_acb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = a_objid[0];

     sts = om$make_message(classname = "Root",			
			   methodname = "disconnect",		
			   size = sizeof (struct disconnect_struct),
			   p_arglist = &disconnect_args,	
			   p_msg = &disconnect_msg );
   
        if (!(sts&1))
        {
            printf("\nerror in om$make_message for disconnect: %x \n",sts);
            om$report_error(sts=sts);
            exit();
        }   
        sts = om$send ( msg = &disconnect_msg,			
		        senderid = a_objid[0],			
		        targetid = b_objid[1]  );
   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("B[1] disconnected from A[0] \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("No connection existed \n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B[1] was not connected to A[0]\n");
      			    break;
      default:  printf("Error in om$send msg = disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected case 2 [f:t] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

       if(!(sts&1))
      {
         printf (" error in om$send msg= showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
 
   
/* Connect A[1] to B[0]:  Singleton:Dipole */

	connect_args.to_sel.type       = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx            = 0;
	connect_args.fr_objid          = a_objid[1];
	connect_args.fr_os             = OM_Gw_current_OS;
	connect_args.fr_sel.type       = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[0] );

   switch(sts=sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("A1 connected to B0\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send connect for A1 to B0 : %x\n", sts);
         om$report_error(sts=sts);
   }
      printf("\nconnected s:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }

   
/* Disconnect A1 from B0:  case 3 t:f */


     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_acb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_bca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = b_objid[0];

   sts = om$send ( msg = &disconnect_msg,			
		   senderid = b_objid[0],			
		   targetid = a_objid[1]);

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("A1 disconnected from B0 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A1 was not connected to B0\n");
      			    break;
      default:  printf("Error in om$send msg=disconnect A: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected case 3 [t:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
       chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
   

/* AGAIN   Singleton:Singleton Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[1] );

      if (!(sts&1))
      {
         printf (" error in om$send connect  : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("another connected s:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Dipole:Dipole Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[1] );

    if (!(sts&1))
      {
         printf (" error in om$send connect  : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected d:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
       chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   FROM:Singleton Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[2] );
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected FROM:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Singleton:TO Connect */

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
		       targetid = b_objid[2] );
 

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected s:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[2], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Singleton:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[3],			
		       targetid = a_objid[0] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected s:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:Singleton Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[3],			
		       targetid = a_objid[3] );

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[3], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[2] );
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   FROM:TO Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[3],			
		       targetid = a_objid[2] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("connecd FROM:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[2], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   FROM:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[3] );
 

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected FROM:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*  Create dipole A4 - B4  */

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
		       targetid = b_objid[4] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("another connected s:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[4], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Dipole:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[4],			
		       targetid = a_objid[1] );
 

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected d:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect A1 from B1:  case 4 f:f (t:f)*/
  
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_acb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_bca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = b_objid[1];

   sts = om$send ( msg = &disconnect_msg,			
		   senderid = b_objid[1],			
		   targetid = a_objid[1]  );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("A1 disconnected from B1 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A1 was not connected to B1\n");
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
}
      printf("\ndisconnected case 4 [t:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:TO Connect */

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
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[4], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
   


/* Disconnect B1-B3 from A0:  case4 f:f (f:t) */

for( i=1; i<4; i++)
{
   
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_bca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_acb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = a_objid[0];

    sts = om$send ( msg = &disconnect_msg,			
		    senderid = a_objid[0],			
		    targetid = b_objid[i] );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("B[%d] disconnected from A0\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B[%d] was not on channel A[0]\n", i);
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
                printf (" iteration : %d \n", i );
   }
      printf("\ndisconnected case 4 [f:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[i], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
}
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*  Above disconnect made A0 - B0 a dipole */

/*   FROM:Dipole Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[0] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected FROM:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect B4 from A4:  case 4 f:f (f:t) ; creates 2 dipoles */

     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_bca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_acb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = a_objid[4];
  
 sts = om$send ( msg = &disconnect_msg,				
		senderid = a_objid[4],			
		targetid = b_objid[4]  );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("B4 disconnected from A4 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B4 was not connected to A4\n");
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected case 4 [f:f] (f:t)\n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[4], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*  A4 - B1 is now a dipole  */

/*   Dipole:TO Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[1],			
		       targetid = a_objid[3] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected d:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[3], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect B2-B4 from A1:  case4 f:f  */

for( i=2; i<5; i++)
{

     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_bca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_acb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = a_objid[1];
  
   sts = om$send ( msg = &disconnect_msg,	
                   senderid = a_objid[1],							   targetid = b_objid[i]);

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("B[%d] disconnected from A1\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("B[%d] was not on channel A[1]\n", i);
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
                printf (" iteration : %d \n", i );
   }
      printf("\ndisconnected case 4 [f:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[i], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
}
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect A0 from B0:  creates dipole A1 - B0 */

     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_acb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_bca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = b_objid[0];
  
   sts = om$send ( msg = &disconnect_msg,
                   senderid = b_objid[0],							   targetid = a_objid[0]);

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("A0 disconnected from B0 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A0 was not connected to B0\n");
      			    break;
      default:  printf("Error in om$send msg = disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected to create dipole \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:Dipole Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[2];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[2],			
		       targetid = a_objid[1] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }

/* Disconnect A2-A3 from B3:  last delete is case d:d  */

for( i=2; i<4; i++)
{
 
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_acb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_bca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = b_objid[3];

     sts = om$send ( msg = &disconnect_msg,	
                     senderid = b_objid[3],			
		     targetid = a_objid[i]  );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("A[%d] disconnected from B[3]\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("A[%d] was not on channel B[3]\n", i);
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
                printf (" iteration : %d \n", i );
   }
}
      printf("\ndisconnected last iteration is d:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for A[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for B[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[2], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showb,	
		senderid = a_objid[3], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }

   /*=========================================================*/
   /*=========================================================*/
   /*   R E S T R I C T E D     C H A N N E L     T E S T S   */
   /*=========================================================*/
   /*=========================================================*/

   printf ("\n\nStart of restricted channel tests\n\n");

   chan_resacb = "ResA.acb";
   chan_resbca = "ResB.bca";
   chan_resacbc = "ResA.acbc";
   chan_resacany = "ResA.acany";

   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct ( osname="OM_TransOS_0",classname= "ResA",    
                 p_objid= &resa_objid[i],neighbor=OM_GS_NULL_NEIGHBOR);

      if (!(sts&1))
      {
         printf (" error in om$construct for ResA : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }
   printf("created %d ResA objids \n", MAXA);

   for ( i=0; i<MAXB; i++ )
   {
      sts = om$construct ( osname="OM_TransOS_0",classname= "ResB",     
               p_objid= &resb_objid[i],neighbor=OM_GS_NULL_NEIGHBOR);

      if (!(sts&1))
      {
         printf (" error in om$construct for ResB : %x \n", sts );
         om$report_error(sts=sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   } /* for */
   printf("created %d ResB objids \n", MAXB);


/* Singleton:Singleton Connect */


	connect_args.to_sel.type       = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx            = 0;
	connect_args.fr_objid          = resa_objid[0];
	connect_args.fr_os             = OM_Gw_current_OS;
	connect_args.fr_sel.type       = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );

        if (!(sts&1))
        {
            printf("\nerror in om$make_message for connect: %x \n",sts);
            om$report_error(sts=sts);
            exit();
        }
	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[0],			
		       targetid = resb_objid[0] );
      
      if (!(sts&1))
      {
         printf (" error in om$send connect for ResB : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected s:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = om$make_message(classname="ResB",methodname="show_b",       
                            p_msg=&showresb);
      if(!(sts&1))
      {
         printf (" error in om$make_message for showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send for showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


     
/* Connect ResA[0] to ResB[1]:  Dipole:Singleton */


	connect_args.to_sel.type       = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx            = 0;
	connect_args.fr_objid          = resa_objid[0];
	connect_args.fr_os             = OM_Gw_current_OS;
	connect_args.fr_sel.type       = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[0],			
		       targetid = resb_objid[1] );

   switch(sts=sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA0 connected to ResB1\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("ResB1 is already connected\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send_message connect ResA0 to ResB1 : %x\n", sts);
         om$report_error(sts=sts);
   }
      printf("\nconnected d:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg= showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
 

/* Disconnect ResB1 from ResA[0]:  case 2 f:t */


     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resa_objid[0];

     sts = om$make_message(classname = "Root",			
			   methodname = "disconnect",		
			   size = sizeof (struct disconnect_struct),
			   p_arglist = &disconnect_args,	
			   p_msg = &disconnect_msg );
   
        if (!(sts&1))
        {
            printf("\nerror in om$make_message for disconnect: %x \n",sts);
            om$report_error(sts=sts);
            exit();
        }   
        sts = om$send ( msg = &disconnect_msg,			
		        senderid = resa_objid[0],			
		        targetid = resb_objid[1]  );
   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResB[1] disconnected from ResA[0] \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("No connection existed \n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResB[1] was not connected to ResA[0]\n");
      			    break;
      default:  printf("Error in om$send msg = disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected case 2 [f:t] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

       if(!(sts&1))
      {
         printf (" error in om$send msg= showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
 
   
/* Connect ResA[1] to ResB[0]:  Singleton:Dipole */

	connect_args.to_sel.type       = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx            = 0;
	connect_args.fr_objid          = resa_objid[1];
	connect_args.fr_os             = OM_Gw_current_OS;
	connect_args.fr_sel.type       = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[1],			
		       targetid = resb_objid[0] );

   switch(sts=sts)
   {
      case OM_I_ADDEDATEND:
      case OM_S_SUCCESS:  printf("ResA1 connected to ResB0\n");
      			  break;
      case OM_E_CHAN_NOTEMPTY: printf("Channel is not empty\n");
      			       break;
      case OM_E_INVCHAN:  printf("an invalid channel name was used\n");
      		          break;
      case OM_E_REL_MISMATCH:  printf("relations don't match\n");
      				break;
      default:				
         printf("error in om$send connect for ResA1 to ResB0 : %x\n", sts);
         om$report_error(sts=sts);
   }
      printf("\nconnected s:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }

   
/* Disconnect ResA1 from ResB0:  case 3 t:f */


     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resb_objid[0];

   sts = om$send ( msg = &disconnect_msg,			
		   senderid = resb_objid[0],			
		   targetid = resa_objid[1]);

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResA1 disconnected from ResB0 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResA1 was not connected to ResB0\n");
      			    break;
      default:  printf("Error in om$send msg=disconnect ResA: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected case 3 [t:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
       chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
   

/* AGAIN   Singleton:Singleton Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[1],			
		       targetid = resb_objid[1] );

      if (!(sts&1))
      {
         printf (" error in om$send connect  : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("another connected s:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Dipole:Dipole Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[0],			
		       targetid = resb_objid[1] );

    if (!(sts&1))
      {
         printf (" error in om$send connect  : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected d:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
       chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   FROM:Singleton Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[0],			
		       targetid = resb_objid[2] );
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected FROM:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Singleton:TO Connect */

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
		       targetid = resb_objid[2] );
 

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected s:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[2], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Singleton:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[3],			
		       targetid = resa_objid[0] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected s:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:Singleton Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[3],			
		       targetid = resa_objid[3] );

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[3], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[1],			
		       targetid = resb_objid[2] );
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   FROM:TO Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[3];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[3],			
		       targetid = resa_objid[2] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("connecd FROM:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[2], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   FROM:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[1],			
		       targetid = resb_objid[3] );
 

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected FROM:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*  Create dipole ResA4 - ResB4  */

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
		       targetid = resb_objid[4] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("another connected s:s \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[4], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   Dipole:FROM Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[4];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[4],			
		       targetid = resa_objid[1] );
 

    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected d:FROM \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect ResA1 from ResB1:  case 4 f:f (t:f)*/
  
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resb_objid[1];

   sts = om$send ( msg = &disconnect_msg,			
		   senderid = resb_objid[1],			
		   targetid = resa_objid[1]  );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResA1 disconnected from ResB1 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResA1 was not connected to ResB1\n");
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
}
      printf("\ndisconnected case 4 [t:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:TO Connect */

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
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[4], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
   


/* Disconnect ResB1-ResB3 from ResA0:  case4 f:f (f:t) */

for( i=1; i<4; i++)
{
   
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resa_objid[0];

    sts = om$send ( msg = &disconnect_msg,			
		    senderid = resa_objid[0],			
		    targetid = resb_objid[i] );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResB[%d] disconnected from ResA0\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResB[%d] was not on channel ResA[0]\n", i);
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
                printf (" iteration : %d \n", i );
   }
      printf("\ndisconnected case 4 [f:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[i], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
}
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[0], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*  Above disconnect made ResA0 - ResB0 a dipole */

/*   FROM:Dipole Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[1],			
		       targetid = resb_objid[0] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected FROM:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect ResB4 from ResA4:  case 4 f:f (f:t) ; creates 2 dipoles */

     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resa_objid[4];
  
 sts = om$send ( msg = &disconnect_msg,				
		senderid = resa_objid[4],			
		targetid = resb_objid[4]  );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResB4 disconnected from ResA4 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResB4 was not connected to ResA4\n");
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected case 4 [f:f] (f:t)\n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[4], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[4], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[4] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[4], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*  ResA4 - ResB1 is now a dipole  */

/*   Dipole:TO Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[1],			
		       targetid = resa_objid[3] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected d:TO \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[1], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[3], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect ResB2-ResB4 from ResA1:  case4 f:f  */

for( i=2; i<5; i++)
{

     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resa_objid[1];
  
   sts = om$send ( msg = &disconnect_msg,	
                   senderid = resa_objid[1],							   targetid = resb_objid[i]);

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResB[%d] disconnected from ResA1\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResB[%d] was not on channel ResA[1]\n", i);
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
                printf (" iteration : %d \n", i );
   }
      printf("\ndisconnected case 4 [f:f] \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[i], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
}
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/* Disconnect ResA0 from ResB0:  creates dipole ResA1 - ResB0 */

     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resb_objid[0];
  
   sts = om$send ( msg = &disconnect_msg,
                   senderid = resb_objid[0],							   targetid = resa_objid[0]);

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResA0 disconnected from ResB0 \n");
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResA0 was not connected to ResB0\n");
      			    break;
      default:  printf("Error in om$send msg = disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
   }
      printf("\ndisconnected to create dipole \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[0], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[0], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[0] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }


/*   TO:Dipole Connect */

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[2];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[2],			
		       targetid = resa_objid[1] );
 
    if (!(sts&1))
      {
         printf (" error in om$send connect : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      printf("\nconnected TO:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[2], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[2] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[1], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[1] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[1], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }

/* Disconnect ResA2-ResA3 from ResB3:  last delete is case d:d  */

for( i=2; i<4; i++)
{
 
     disconnect_args.to_sel.type = OM_e_name;
     disconnect_args.to_sel.u_sel.name = chan_resacb;
     disconnect_args.fr_sel.type = OM_e_name;
     disconnect_args.fr_sel.u_sel.name = chan_resbca;
     disconnect_args.fr_os = OM_Gw_current_OS;
     disconnect_args.fr_objid = resb_objid[3];

     sts = om$send ( msg = &disconnect_msg,	
                     senderid = resb_objid[3],			
		     targetid = resa_objid[i]  );

   switch(sts=sts)
   {
      case OM_S_SUCCESS:  printf("ResA[%d] disconnected from ResB[3]\n", i);
      			  break;
      case OM_I_CHAN_EMPTY:  printf("Channel was empty\n");
      			     break;
      case OM_W_NOTONCHAN:  printf("ResA[%d] was not on channel ResB[3]\n", i);
      			    break;
      default:  printf("Error in om$send msg=disconnect: %x\n", sts);
      	        om$report_error(sts=sts);
                printf (" iteration : %d \n", i );
   }
}
      printf("\ndisconnected last iteration is d:d \n");
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[2], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid[3], "acb" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResA[%d] : %x \n", i, sts );
         om$report_error(sts=sts);
         exit();
      }
      sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[3], "bca" );
      if(!(sts&1))
      {
         printf (" error in OMT_dump_relation for ResB[3] : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[2], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$send (mode = OM_e_wrt_object, msg = &showresb,	
		senderid = resa_objid[3], p_chanselect = &chansel);

      if(!(sts&1))
      {
         printf (" error in om$send msg = showresb : %x \n", sts );
         om$report_error(sts=sts);
         exit();
      }

      printf ("\n\nNow try some illegal connections to restricted channels\n\n");

      printf ("Attempt to connect ResA1.acbc to ResB1.bca - should fail\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacbc;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[1],			
		       targetid = resa_objid[1] );
 
        if (sts != OM_E_CLASS_CONFLICT)
        {
          printf ("Expected OM_E_CLASS_CONFLICT - instead got \n");
          om$report_error(sts=sts);
          exit();
        }
        printf ("\n Status = OM_E_CLASS_CONFLICT - expected status\n");

        printf ("Attempt to connect ResA1.acany to ResB1.bca - should fail\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacany;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[1],
		       targetid = resa_objid[1] );
 
        if (sts != OM_E_CLASS_CONFLICT)
        {
          printf ("Expected OM_E_CLASS_CONFLICT - instead got \n");
          om$report_error(sts=sts);
          exit();
        }
        printf ("\n Status = OM_E_CLASS_CONFLICT - expected status\n");

       
}  /* main */
