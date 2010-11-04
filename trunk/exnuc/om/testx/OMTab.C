#include "OMobjectcomm.h"

#define MAXB 5
#define MAXC 3

main(argc,argv)
int     argc;
char    *argv[];

{
   int           sts, i, zro=0, j;
   int		 relindex=0;
   int	         from=0, to=0;
   OMuint        count;

   OM_S_OBJID    a_objid, b_objid[MAXB], a1_objid, a2_objid, c_objid[MAXC];
   OM_S_OBJID	 resa_objid, resb_objid[MAXB], resa1_objid;
   OM_S_OBJID    d_objid, b1_objid, resb1_objid, bad_objid;
   OMuword       siz, classid, a_classid, b_classid, c_classid,d_classid;
   OMuword       parentlist[2], resa_classid, resb_classid;
   OM_S_CHANNUM  chan_a, chan_resa, chan_resacs, chan_b, chan_resb;
   OM_S_MESSAGE  ass_a, ass_b, inca, incb, showa, showb, ass_d, showd_d;
   OM_S_MESSAGE  move_chan_msg,connect_msg,disconnect_msg;
   OM_S_MESSAGE  wild_disconnect_msg,showd_c, root_del, del, new_c_to_b;

   OM_S_OBJECT_LINKAGE 	list[MAXB];
   OM_S_CHANSELECT chansel;

   uword	minorchan=0;



   char         sub_classname[OM_K_MAXCLASS_LEN], 
                par_classname[OM_K_MAXCLASS_LEN];

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
struct move_chan_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 OM_S_OBJID	      fr_objid;
	 OMuword              fr_os;
	 OM_S_CHANSELECT      fr_sel;
       }move_chan_args;
struct wild_disconnect_struct
       {
	 OM_S_CHANSELECT      to_sel;
       } wild_disconnect_args;

typedef struct { int flag; } TRootDelete;
TRootDelete   arg_delete;
arg_delete.flag = 0;

if ( argc == 1 )
{
   printf ("Initializing\n");
}
   sts = om$runtime_init();
   if (!(sts&1))
   {
      printf (" error in om$runtine_init : %x \n", sts );
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("Make all messages\n");
}
   sts = om$make_message(classname = "Root",		
			 methodname = "connect",		
			 size = sizeof( struct connect_struct),
			 p_arglist = &connect_args,	
			 p_msg = &connect_msg );
   if (!(1&sts))
   {
      printf (" error in om$make_message for Root.connect\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$make_message(classname = "Root",
                         methodname = "delete",
                         size = sizeof(TRootDelete),
                         p_arglist = &arg_delete,
                         p_msg = &root_del );
   if (!(sts&1))
   {
      printf (" error in om$make_message for Root.delete\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "Root",		
			 methodname = "disconnect",		
			 size = sizeof( struct disconnect_struct),
			 p_arglist = &disconnect_args,	
			 p_msg = &disconnect_msg );
   if (!(1&sts))
   {
      printf (" error in om$make_message for Root.disconnect\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$make_message(classname = "Root",		
		         methodname = "wild_disconnect",		
		         size = sizeof( struct wild_disconnect_struct),
		         p_arglist = &wild_disconnect_args,	
			 p_msg = &wild_disconnect_msg );
   if (!(1&sts))
   {
      printf (" error in om$make_message for Root.wild_disconnect\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$make_message(classname = "Root",		
			 methodname = "move_chan",		
			 size = sizeof( struct move_chan_struct),
			 p_arglist = &move_chan_args,	
			 p_msg = &move_chan_msg );
   if (!(1&sts))
   {
      printf (" error in om$make_message for Root.move_chan\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$make_message(classname = "A",
                         methodname = "assign_a",
                         size = 4,
                         p_arglist = &zro,
                         p_msg = &ass_a );
   if (!(1&sts))
   {
      printf (" error in om$make_message for A.assign_a\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$make_message(classname = "A",
                         methodname = "show",
                         p_msg = &showd_d );
   if (sts&1)
   {
      printf (" expected an error in om$make_message for A.show\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "A",
                         methodname = "delete",
                         size = sizeof(TRootDelete),
                         p_arglist = &arg_delete,
                         p_msg = &del );
   if (!(sts&1))
   {
      printf (" error in om$make_message for A.delete\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "B",
                         methodname = "assign_b",
                         size = 4,
                         p_arglist = &i,
                         p_msg = &ass_b );
   if (!(sts&1))
   {
      printf (" error in om$make_message for B.assign_b\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "B",
                         methodname = "show_b",
                         p_msg = &showb );
   if (!(1&sts))
   {
      printf (" error in om$make_message for B.show_b\n");
      om$report_error(sts=sts);
      exit();
   }
  
   sts = om$make_message(classname = "C",
                         methodname = "show",
                         p_msg = &showd_c );
   if (!(sts&1))
   {
      printf (" error in om$make_message for C.show\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "C",
                         methodname = "make_connect",
                         p_msg = &new_c_to_b );
   if (!(sts&1))
   {
      printf (" error in om$make_message for C.make_connect\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "D",
                         methodname = "assign_c",
                         size = 4,
                         p_arglist = &zro,
                         p_msg = &ass_d );
   if (!(sts&1))
   {
      printf (" error in om$make_message for D.assign_c\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "D",
                         methodname = "show",
                         p_msg = &showd_d );
   if (!(sts&1))
   {
      printf (" error in om$make_message for D.show\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("Testing if C is an ancestor of D -- this should be OK\n");
}
   sts = om$is_ancestry_valid(subclassname = "D",
                              superclassname = "C" );
   if (!(1&sts))
   {
      printf (" error in om$is_ancestry_valid");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("Testing if Root is an ancestor of D -- this should be OK\n");
}
   sts = om$is_ancestry_valid(subclassname = "D",
                              superclassname = "Root" );
   if (!(1&sts))
   {
      printf (" error in om$is_ancestry_valid\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("Testing if B is an ancestor of D -- this should error\n");
}
   sts = om$is_ancestry_valid(subclassname = "D",
                              superclassname = "B" );
   if ( sts != OM_I_INVANCESTRY )
   {
      printf(" Unexpected return from om$is_ancestry_valid\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("\n");
   printf("Tracing the ancestry of D using om$get_parent_classname\n");
}

   sprintf ( sub_classname, "%s", "D" );

   sts = OM_S_SUCCESS;
   while (strcmp(sub_classname,"Root"))
   {
      sts = om$get_parent_classname(classname = sub_classname,
                                    parent_classname = par_classname );
      if (!(1&sts))
      {
         printf (" error in om$get_parent_classname\n");
         om$report_error(sts = sts);
         exit();
      }
if ( argc == 1 )
{
      if ( sts == OM_S_SUCCESS )
      printf (" Class: %s   Parent class: %s \n", sub_classname,par_classname);
}
      strncpy ( sub_classname, par_classname, OM_K_MAXCLASS_LEN );
   }

if ( argc == 1 )
{
   printf("\n");
   printf("Tracing the ancestry of OMFiledOS using om$get_all_parents\n");
}
   sprintf ( sub_classname, "%s", "OMFiledOS" );

   sts = OM_S_SUCCESS;
   while (strcmp(sub_classname,"Root"))
   {
      sts = om$get_parent_count ( classname = sub_classname,
                                  count = &count );
      if (!(1&sts))
      {
         printf (" error in om$get_parent_count %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

      if ( count == 1 )
      {
         sts = om$get_parent_classname(classname = sub_classname,
                                       parent_classname = par_classname );
         if (!(1&sts))
         {
            printf (" error in om$get_parent_classname %x \n", sts );
            om$report_error(sts = sts);
            exit();
         }
if ( argc == 1 )
{
         if (1&sts)
         printf (" Class: %s   Parent class: %s \n", sub_classname,
                 par_classname);
}
         strncpy ( sub_classname, par_classname, OM_K_MAXCLASS_LEN );
      }
      else
      {
         sts = om$get_all_parents ( classname = sub_classname,
                                    parentlist = parentlist,
                                    size = count,
                                    count = &count );
         if (!(1&sts))
         {
            printf (" error in om$get_all_parents %x \n", sts );
            om$report_error(sts = sts);
            exit();
         }

         for ( i=0; i<count; i++ )
         {
            sts = om$get_classname(classid = parentlist[i],
                                   classname = par_classname );
            if (!(1&sts))
            {
               printf (" error in om$get_classname %x \n", sts );
               om$report_error(sts = sts);
               exit();
            }
if ( argc == 1 )
{
            if (1&sts)
               printf (" Class: %s   Parent class: %s \n", sub_classname,
                       par_classname);
}
         }
         strncpy ( sub_classname, par_classname, OM_K_MAXCLASS_LEN );
      }
   }

if ( argc == 1 )
{
   printf("\n--- The NULL_OBJID should be an invalid objid ---\n");
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = NULL_OBJID);
   if (sts&1)
   {
	printf( " expected an error from om$is_objid_valid (NULL_OBJID)\n");
	om$report_error(sts = sts);
        exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Constructing A\n");
}
   
   sts = om$construct(osname = "OM_TransOS_0",
                      classname = "A",
                      p_objid = &a_objid,
                      neighbor = OM_GS_NULL_NEIGHBOR,
                      msg = &ass_a );
   if (!(sts&1))
   {
      printf (" error in om$construct for A \n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if A's objid of %d is valid ---\n", a_objid);
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = a_objid);
   if (!(sts&1))
	{
	printf("Object id is invalid : %x \n", sts);
	om$report_error(sts = sts);
	exit();
	}

   bad_objid  = -1;
if ( argc == 1 )
{
   printf("--- %d should be an invalid objid in this test---\n",bad_objid);
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = bad_objid);
   if (sts&1)
   {
	printf(" expected an error in om$is_objid_valid (-1)\n");
	om$report_error(sts = sts);
        exit();
   }

   bad_objid  = 1000000;
if ( argc == 1 )
{
   printf("--- %d should be an invalid objid in this test---\n",bad_objid);
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = bad_objid);
   if (sts&1)
   {
	printf(" expected an error in om$is_objid_valid (1000000)\n");
	om$report_error(sts = sts);
        exit();
   }


   sts = om$get_channel_number(channame = "A.acb",
                               p_channum = &chan_a );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for acb : %x \n", sts );
      om$report_error(sts = sts);
      exit();
   }

   sts = om$get_channel_number(channame = "B.bca",
                               p_channum = &chan_b );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for bca : %x \n", sts );
      om$report_error(sts = sts);
      exit();
   }

   /* Get Nonexistant Class's classid & ptr to ACLD */

if ( argc == 1 )
{
   printf ("Attempt to get classid of unknown class Q - should error\n");
}
   sts = om$get_classid(classname = "Q",
                        p_classid = &a_classid);

   if ( sts != OM_E_NOSUCHCLASS )
   {
      printf (" expected an error in om$get_classid for class Q\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Get Class A's classid */

   sts = om$get_classid(classname = "A",
                        p_classid = &a_classid);
   if (!(sts&1))
   {
      printf (" error in om$get_classid for class A\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf ("Classid for A is %d\n", a_classid);
}
   for ( i=0; i<MAXB; i++ )
   {
if ( argc == 1 )
{
      printf ("\n----- Constructing B[%d]\n",i);
}
      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "B",
                         p_objid = &b_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR,
                         msg = &ass_b);
      if (!(sts&1))
      {
         printf (" error in om$construct for B : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

      sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                              objid = b_objid[i]);
      if (!(sts&1))
      {
	printf("Object of B[%d] id is invalid\n",i);
	om$report_error(sts = sts);
	exit();
      }

      connect_args.to_sel.type = OM_e_num;
      connect_args.to_sel.u_sel.number = chan_b;
      connect_args.to_idx = 0;
      connect_args.fr_objid = a_objid;
      connect_args.fr_os = OM_Gw_current_OS;
      connect_args.fr_sel.type = OM_e_num;
      connect_args.fr_sel.u_sel.number = chan_a;
      connect_args.fr_idx            = 0;

if ( argc == 1 )
{
      printf ("----- Connecting B[%d] to A\n",i);
}

      sts = om$send (msg = &connect_msg,			
		       senderid = a_objid,			
		       targetid = b_objid[i] );
 
      if (!(sts&1))
      {
         printf (" error in connect for B[%d] to A\n",i);
         om$report_error(sts = sts);
         exit();
      }
   } /* for */

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for A on channel acb\n");

   sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, "acb" );
   if(!(sts&1))
   {
	printf("error in OMT_dump_relation for A: %x\n",  sts);
	exit();
   }

   for(i=0; i<MAXB; i++)   
   {
      printf ("\n----- Dumping channel info for B[%d] on channel bca\n",i);

      sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], "bca" );
      if(!(sts&1))
      {
         printf("error in OMT_dump_relation for B[%d]: %x\n", i,  sts);
         exit();
      }
   }
}

if ( argc == 1 )
{
   printf ("\n----- Issue a channel send to show all B's connected to A\n");
}
   from = 0;
   to = OM_K_MAXINT;
   chansel.type =OM_e_name;
   chansel.u_sel.name = "acb";

   sts = om$send(mode = OM_e_wrt_object,
                    msg = &showb,
                    senderid = a_objid,
                    p_chanselect =&chansel,
                    from = from,
                    to = to );
   if (!(sts&1))
   {
      printf (" error in om$send (showb) out A's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Get Class B's classid */

   sts = om$get_classid(osnum = OM_Gw_TransOSnum_0,
                        objid = b_objid[0],
                        p_classid = &b_classid);
   if (!(1&sts))
   {
      printf (" error in om$get_classid for B\n");
      om$report_error(sts=sts);
      exit();
   }

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = a_objid,
                              p_chanselect = &chansel,
                              count = &count );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_count for A's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf ( " Channel count for A's channel acb is %d \n", count );
}
   if ( count != MAXB )
   {
      printf (" count for A's acb is incorrect - expected %d\n",MAXB);
      exit();
   }

   chansel.type = OM_e_name;
   chansel.u_sel.name = "bca";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = b_objid[0],
                              p_chanselect = &chansel,
                              count = &count );
   if (!(sts&1))
   {
      printf (" error in om$get_channum_count for B[0]'s bca channel\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf ( " Channel count for B[0]'s channel bca is %d \n", count );
}
   if ( count != 1 )
   {
      printf (" count for B[0]'s bca is incorrect - expected 1\n");
      exit();
   }

   for ( i=0; i<MAXB; i++ )
   {
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$is_objid_on_channel(osnum_c = OM_Gw_TransOSnum_0,
                                   objid_c = a_objid,
                                   p_chanselect = &chansel,
                                   objid = b_objid[i],
                                   osnum2 = OM_Gw_TransOSnum_0);
      if (!(1&sts))
      {
         printf (" error in om$is_objid_on_channel for B[%d] on A's acb\n",i);
         om$report_error(sts=sts);
         exit();
      }
   }

if ( argc == 1 )
{
   printf ("\n----- Calling om$get_channel_objects to gather B's \n" );
}
   siz = MAXB * sizeof(OM_S_OBJECT_LINKAGE);

   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_a;
   sts = om$get_channel_objects(osnum = OM_Gw_TransOSnum_0,
                                objid = a_objid,
                                p_chanselect = &chansel,
                                list = list,
                                size = siz,
                                count = &count );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_objects for A's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }

   if ( count != MAXB )
   {
      printf (" count from om$get_channel_objects != MAXB\n");
      exit();
   }

if ( argc == 1 )
{
   printf (" Count : %d \n", count );

   for ( i=0; i<MAXB; i++ )
   {
      for ( j=0; j<MAXB; j++ )
      {
         if (IF_EQ_OBJID ( b_objid[i], list[j].S_objid ))
            printf (" b_objid[%d] was in list \n", i );
      }
   }
}

   /* Construct A2: another instance of class A */

if ( argc == 1 )
{
   printf ("\n----- Constructing A2\n");
}
   sts = om$construct (obj_osnum = OM_Gw_TransOSnum_0,
                     objid = a_objid,
                     osnum = OM_Gw_TransOSnum_0,
                     p_objid = &a2_objid,
                     neighbor = OM_GS_NULL_NEIGHBOR);
   if(!(sts&1))
   {
	printf("error in om$construct for A2 by objid\n");
	om$report_error(sts = sts);
	exit();
   }

if ( argc == 1 )
{
   printf("--- test if A2's objid of %d is valid ---\n", a2_objid );
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = a2_objid);
   if (!(sts&1))
   {
	printf(" error in om$is_objid_valid for A2\n");
	om$report_error(sts = sts);
	exit();
   }

   chansel.type = OM_e_name;
   chansel.u_sel.name = "bca";
   sts = om$is_objid_on_channel(osnum_c = OM_Gw_current_OS,
                                objid_c = b_objid[2],
                                p_chanselect = &chansel,
                                objid = a2_objid,
                                osnum2 = OM_Gw_current_OS);
   if (1&sts)
   {
      printf ("Unexpected result from om$is_objid_on_channel\n");
      printf ("this should have errored - nothing is connected to A2\n");
      exit();
   }

   chansel.type = OM_e_name;
   chansel.u_sel.name = "cc";   
   sts = om$is_objid_on_channel(osnum_c = OM_Gw_current_OS,
                                objid_c = b_objid[2],
                                p_chanselect = &chansel,
                                objid = a2_objid,
                                osnum2 = OM_Gw_current_OS);
   if ( sts != OM_E_INVCHAN )
   {
      printf (" error condition in om$is_objid_on_channel\n");
      printf (" cc is not a valid channel on B\n");
      exit();
   }
     
   /* Connect A2 to B[4] */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "bca";
   connect_args.to_idx = 0;
   connect_args.fr_objid = a2_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "acb";
   connect_args.fr_idx            = 0;

if ( argc == 1 )
{
   printf ("\n----- Connecting A2 to B[4]\n");
}
   sts = om$send (msg = &connect_msg,			
		       senderid = a2_objid,			
		       targetid = b_objid[4] );
    if(!(sts&1))
    {
	printf("error in connect of A2 to B[4]: %x\n",  sts);
        om$report_error(sts=sts);
	exit();
    }

if ( argc == 1 )
{
    printf ("\n----- Dumping channel info for A2's acb channel\n");

    sts = OMT_dump_relation ( OM_Gw_current_OS, a2_objid, "acb" );
    if(!(sts&1))
    {
	printf("error in OMT_dump_relation for A2: %x\n",  sts);
	exit();
    }

    printf ("\n----- Dumping channel info for B[4]'s bca channel\n");

    sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[4], "bca" );
    if(!(sts&1))
    {
	printf("error in OMT_dump_relation for B[4]: %x\n",  sts);
	exit();
    }
}

if ( argc == 1 )
{
   printf ("\n-----Issuing a channel send to show all B's connected to A2\n");
}
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
   from = 0;
   to = OM_K_MAXINT;

   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = a2_objid,
                 p_chanselect = &chansel,
                 from = from,
                 to = to );
   if (!(sts&1))
   {
      printf (" error in om$send (showb) out A2's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Connect A2 to B[4]: use invalid channel name */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "bbb";
   connect_args.to_idx = 0;
   connect_args.fr_objid = a2_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "aaa";
   connect_args.fr_idx            = 0;

   sts = om$send (msg = &connect_msg,			
		       senderid = a2_objid,			
		       targetid = b_objid[4] );
 
 
   if (1&sts)
   {
      printf (" an error of invalid channel was expected here\n");
      printf (" aaa and bbb are invalid channel names\n");
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Constructing B1\n");
}
   sts = om$construct(obj_osnum = OM_Gw_TransOSnum_0,
                     objid = b_objid[0],
                     osnum = OM_Gw_TransOSnum_0,
                     p_objid = &b1_objid,
                     neighbor = OM_GS_NULL_NEIGHBOR);
   if(!(sts))
   {
      printf("error in om$construct (by objid) for B1\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if %d is valid objid ---\n", b1_objid );
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = b1_objid);
   if (!(sts&1))
   {
	printf("Object id of B1 is invalid\n");
	om$report_error(sts = sts);
	exit();
   }

   disconnect_args.to_sel.type = OM_e_num;
   disconnect_args.to_sel.u_sel.number = chan_a;
   disconnect_args.fr_sel.type = OM_e_num;
   disconnect_args.fr_sel.u_sel.number = chan_b;
   disconnect_args.fr_os = OM_Gw_current_OS;
   disconnect_args.fr_objid = b1_objid;

   sts = om$send (msg = &disconnect_msg,			
		       senderid = b1_objid,			
		       targetid = a_objid );
 
   if (sts != OM_W_NOTONCHAN)
   {
      printf (" unexpected result from disconnect of B1 from A\n");
      printf (" expected OM_W_NOTONCHAN\n");
      exit();
   }
   
   /* Disconnect B[0]'s channel from object on other side */

   disconnect_args.to_sel.type = OM_e_num;
   disconnect_args.to_sel.u_sel.number = chan_a;
   disconnect_args.fr_sel.type = OM_e_num;
   disconnect_args.fr_sel.u_sel.number = chan_b;
   disconnect_args.fr_os = OM_Gw_current_OS;
   disconnect_args.fr_objid = b_objid[0];

if ( argc == 1 )
{
   printf ("\n----- Disconnecting A and B[0]\n");
}
   sts = om$send (msg = &disconnect_msg,			
		       senderid = b_objid[0],			
		       targetid = a_objid );

   if (!(1&sts))
   {
      printf (" error from disconnect of B[0] from A\n");
      om$report_error(sts=sts);
      exit();
   }

if ( argc == 1 )
{
    printf ("\n----- Dumping channel info for A's acb channel\n");

    sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid, "acb" );
    if(!(sts&1))
    {
	printf("error in OMT_dump_relation for A: %x\n",  sts);
	exit();
    }

    printf ("\n----- Dumping channel info for B[0]'s bca channel\n");

    sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[0], "bca" );
    if(!(sts&1))
    {
	printf("error in OMT_dump_relation for B0: %x\n",  sts);
	exit();
    }
}

if ( argc == 1 )
{
   printf ("\n----- Issuing a channel send to show all B's connected to A\n" );
}
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = a_objid,
                 p_chanselect = &chansel,
                 from = from,
                 to = to );
   if (!(sts&1))
   {
      printf (" error in om$send (showb) out A's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Disconnect all objects connected to A via acb */

   wild_disconnect_args.to_sel.type = OM_e_num;
   wild_disconnect_args.to_sel.u_sel.number = chan_a;  
   
   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_a;

if ( argc == 1 )
{
   printf ("\n----- Issue a Root.wild_disconnect on A's acb channel\n");
}

   sts = om$send (mode = OM_e_wrt_message,
                  msg = &wild_disconnect_msg,			
                  senderid = a_objid,			
		  targetid=a_objid );
 
   if (!(1&sts))
   {
      printf (" error in om$send of Root.wild_disconnect out A's acb\n");
      om$report_error(sts=sts);
      exit();
   }   

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for A's acb channel\n");
    
   sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid, "acb" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for A\n");
      om$report_error(sts=sts);
      exit();
    }
}

   /* Get Channel Count after Disconnect : other side */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = a_objid,
                              p_chanselect = &chansel,
                              count = &count);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_count for A's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf (" Channel count for A's acb channel is %d\n", count);
}

   if ( count != 0 )
   {
      printf (" count for A's acb is incorrect - expected 0\n");
      exit();
   }

   /* Using Bad Channel Name, Get Channel Count after Disconnect */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "aaa";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = a_objid,
                              p_chanselect = &chansel,
                              count = &count);
   if (sts&1)
   {
      printf (" expected an error in om$get_channel_count\n");
      printf (" aaa is not a valid channel of A\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Construct Another Instance of Class A: A1 */

if ( argc == 1 )
{
   printf ("\n----- Constructing A1 by classid\n");
}
   sts = om$construct(osnum = OM_Gw_TransOSnum_0,
                      classid = a_classid,
                      p_objid = &a1_objid,
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if (!(sts&1))
   {
      printf ("error in om$construct (by classid) for A1\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if A1's objid of %d is valid ---\n", a1_objid );
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = a1_objid);
   if (!(sts&1))
   {
	printf("Object id of A1 is invalid\n");
	om$report_error(sts = sts);
	exit();
   }

   /* Construct a C object, after getting its classid */
   
   sts = om$get_classid(classname = "C",
                        p_classid = &c_classid);
   if(!(sts&1))
   {
      printf("error on om$get_classid for C\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Constructing C[0] by classid\n");
}
   sts = om$construct(osnum = OM_Gw_TransOSnum_0,
                      classid = c_classid,
                      p_objid = &c_objid[0],
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if (!(sts&1))   
   {
      printf (" error on om$construct (by classid) for C\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if %d is valid objid ---\n", c_objid[0] );
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = c_objid[0]);
   if (!(sts&1))
   {
	printf("Object id of C[0] is invalid\n");
	om$report_error(sts = sts);
	exit();
   }

   /* Connect C0 to B2 */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "scb";
   connect_args.to_idx = 0;
   connect_args.fr_objid = b_objid[2];
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "bcs";
   connect_args.fr_idx            = 0;

if ( argc == 1 )
{
   printf ("\n----- Connecting C[0] to B[2]\n");
}
   sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[2],			
		       targetid = c_objid[0] );
   if(!(sts&1))
   {
      printf("error on om$connect for C0 to B[2]\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for B[2]'s bcs channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[2], "bcs" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for B2\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for C[0]'s scb channel\n");
    
   sts = OMT_dump_relation ( OM_Gw_current_OS, c_objid[0], "scb" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for A: %x\n",  sts);
      om$report_error(sts=sts);
      exit();
   }
}

if ( argc == 1 )
{
   printf ("\n----- Sending show_b message to B[2]\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = c_objid[0],
                 targetid = b_objid[2]);
   if (!(sts&1))
   {
      printf("error in om$send (showb) to B[2]\n", sts);
      om$report_error(sts = sts);
      exit();
   }

   /* Construct an object of Class D */

   sts = om$get_classid(classname = "D",
                        p_classid = &d_classid );
   if(!(sts&1))
   {
      printf("error in om$get_classid for D\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Constructing D\n");
}
   sts = om$construct(osname = "OM_TransOS_0",
                      classname = "D",
                      p_objid = &d_objid,
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if(!(sts&1))
   {
      printf("error in om$construct for D\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if D's objid of %d is valid ---\n", d_objid );
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = d_objid);
   if (!(sts&1))
   {
	printf("Object id of D is invalid : %x \n", sts);
	om$report_error(sts = sts);
	exit();
   }

   /* Assign 0 to D */
if ( argc == 1 )
{
   printf ("\n----- Sending assign_d to D\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &ass_d,
                 senderid = d_objid,
                 targetid = d_objid);
   if (!(sts&1))
   {
      printf(" error in om$send (assign_d)\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Perform send wrt message */

if ( argc == 1 )
{
   printf ("\n----- Send a show message to D\n");
}
   sts = om$send(mode = OM_e_wrt_message,
                 msg = &showd_c,
                 senderid = d_objid,
                 targetid = d_objid);
   if (!(sts&1))
   {
      printf(" error in om$send (showd_c)\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Active Class A does not match a superclass of D so OM_W_UNKNOWN_MSG */

   sts = om$send(msg = &showd_d,
                 senderid = a_objid,
                 targetid = a_objid);
   if (sts != OM_W_UNKNOWN_MSG)
   {
      printf(" error in om$send (showd_d) - expected OM_W_UNKNOWN_MSG\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Send a show message to D\n");
}
   sts = om$send(mode = OM_e_wrt_message,
                 msg = &showd_d,
                 senderid = d_objid,
                 targetid = d_objid);
   if (!(sts&1))
   {
      printf(" error in om$send (showd_d)\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Disconnect A1 from B1: after first connecting them */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "bca";
   connect_args.to_idx = 0;
   connect_args.fr_objid = a1_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "acb";
   connect_args.fr_idx            = 0;

if ( argc == 1 )
{
   printf ("\n----- Connecting A1 to B1\n");
}
   sts = om$send (msg = &connect_msg,			
		       senderid = a1_objid,			
		       targetid = b1_objid );
 
   if(!(sts&1))
   {
      printf(" error in om$send (connect) for A1 to B1\n");
      om$report_error(sts = sts);
      exit();
   }
   
if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for A1's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, a1_objid, "acb" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for A1\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for B1's bca channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, b1_objid, "bca" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for B1: %x\n",  sts);
      om$report_error(sts=sts);
      exit();
   }
}

if ( argc == 1 )
{
   printf ("\n----- Sending a show_b message to B1\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = a1_objid,
                 targetid = b1_objid);
   if (!(sts&1))
   {
      printf(" error in om$send (showb) to B1\n");
      om$report_error(sts = sts);
      exit();
   }

   disconnect_args.to_sel.type = OM_e_name;
   disconnect_args.to_sel.u_sel.name = "bca";
   disconnect_args.fr_sel.type = OM_e_name;
   disconnect_args.fr_sel.u_sel.name = "acb";
   disconnect_args.fr_os = OM_Gw_current_OS;
   disconnect_args.fr_objid = a1_objid;

if ( argc == 1 )
{
   printf ("\n----- Disconnecting A1 and B1\n");
}
   sts = om$send (msg = &disconnect_msg,			
		       senderid = a1_objid,			
		       targetid = b1_objid );
 
   if (!(1&sts))
   {
      printf (" error in disconnect of A1 from B1\n");
      om$report_error(sts=sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for A1's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, a1_objid, "acb" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for A1\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for B1's bca channel\n");
   
   sts = OMT_dump_relation ( OM_Gw_current_OS, b1_objid, "bca" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for B1\n");
      om$report_error(sts=sts);
      exit();
   }
}

   /* Move Channel "bcs" from B2 to B0 */

   move_chan_args.to_sel.type = OM_e_name;
   move_chan_args.to_sel.u_sel.name = "bcs";
   move_chan_args.fr_objid = b_objid[2];
   move_chan_args.fr_os = OM_Gw_current_OS;
   move_chan_args.fr_sel.type = OM_e_name;
   move_chan_args.fr_sel.u_sel.name = "bcs";

if ( argc == 1 )
{
   printf ("\n----- Issue a move channel from B[2]'s bcs to B[0]'s bcs\n");
}
   sts = om$send (msg = &move_chan_msg,			
		       senderid = b_objid[2],			
		       targetid = b_objid[0] );
 
   if(!(sts&1))
   {
      printf("error in om$send (move_channel)\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for B[2]'s bcs channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[2], "bcs" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for B2\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for B[2]'s bcs channel\n");
   
   sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[0], "bcs" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for B0\n");
      om$report_error(sts=sts);
      exit();
   }
}

   /* Get List of Channel Objects on B0 */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "bcs";
   sts = om$get_channel_objects(osnum = OM_Gw_TransOSnum_0,
                                objid = b_objid[0],
                                p_chanselect = &chansel,
                                list = list,
                                size = siz,
                                count = &count);
   if(!(sts&1))
   {
      printf("error in om$get_channel_objects on B[0]'s bcs channel\n");  
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf(" Count : %d\n",  count);
   if (IF_EQ_OBJID (c_objid[0], list[0].S_objid))
      printf(" c_objid[0] is in list \n");
   else
      printf(" c_objid[0] is not in list \n");
}

   /* Connect B[]'s to A; then move all channels from A to A2 */

   for ( i=0; i<MAXB; i++)
   {
	connect_args.to_sel.type = OM_e_num;
	connect_args.to_sel.u_sel.number = chan_b;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_num;
	connect_args.fr_sel.u_sel.number = chan_a;
	connect_args.fr_idx            = 0;

if ( argc == 1 )
{
        printf ("----- Connecting B[%d] to A\n",i);
}
	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid,			
		       targetid = b_objid[i] );
 
      if (!(sts&1))
      {
         printf (" error in om$connect for B[%d] to A\n",i);
         om$report_error(sts = sts);
         exit();
      }
   }

   wild_disconnect_args.to_sel.type = OM_e_num;
   wild_disconnect_args.to_sel.u_sel.number = chan_a;  
   
   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_a;

if ( argc == 1 )
{
   printf ("\n----- Issue a Root.wild_disconnect on A2's acb channel\n");
}

   sts = om$send (mode = OM_e_wrt_message,
                  msg = &wild_disconnect_msg,			
                  senderid = a2_objid,			
		  targetid=a2_objid );
 
   if (!(1&sts))
   {
      printf (" error in om$send of Root.wild_disconnect out A2's acb\n");
      om$report_error(sts=sts);
      exit();
   }   

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for A's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid, "acb" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for A\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for A2's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, a2_objid, "acb" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for A2\n");
      om$report_error(sts=sts);
      exit();
   }
}

   move_chan_args.to_sel.type = OM_e_name;
   move_chan_args.to_sel.u_sel.name = "acb";
   move_chan_args.fr_objid = a_objid;
   move_chan_args.fr_os = OM_Gw_current_OS;
   move_chan_args.fr_sel.type = OM_e_name;
   move_chan_args.fr_sel.u_sel.name = "acb";

if ( argc == 1 )
{
   printf ("\n----- Issue a move channel from A's acb to A2's acb\n");
}

   sts = om$send (msg = &move_chan_msg,			
		       senderid = a_objid,			
		       targetid = a2_objid );
   if(!(sts&1))
   {
      printf(" error in om$send (move channel)\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for A2's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, a2_objid, "acb" );
   if(!(sts&1))
   {
      printf (" error in OMT_dump_relation for A2\n");
 
     exit();
   }

   printf ("\n----- Dumping channel info for A's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, a_objid, "acb" );
   if(!(sts&1))
   {
      printf (" error in OMT_dump_relation for A\n");
      om$report_error(sts=sts);
      exit();
   }
}

   /* Delete A1: an unconnected object */

if ( argc == 1 )
{
   printf ("\n----- Deleting A1\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &del,
                 senderid = a1_objid,
                 targetid = a1_objid );
   if (!(1&sts))
   {
      printf (" error in om$send (Root.delete) for A1\n");
      om$report_error(sts=sts);
      exit();
   }

   /* Connect B1 to D;Send from D via "scb" channel wrt msg to delete B1 */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "scb";
   connect_args.to_idx = 0;
   connect_args.fr_objid = b1_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "bcs";
   connect_args.fr_idx            = 0;

if ( argc == 1 )
{
   printf ("\n----- Connecting B1 to D\n");
}
   sts = om$send (msg = &connect_msg,			
		       senderid = b1_objid,			
		       targetid = d_objid );
   if (!(1&sts))
   {
      printf (" error in om$send (Root.connect) for B1 and D\n");
      om$report_error(sts=sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for B1's bcs channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, b1_objid, "bcs" );
   if(!(sts&1))
   {
      printf (" error in OMT_dump_relation for B1\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for D's scb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, d_objid, "scb" );
   if(!(sts&1))
   {
      printf (" error in OMT_dump_relation for D\n");
      om$report_error(sts=sts);
      exit();
   }
}

if ( argc == 1 )
{
   printf ("\n----- Sending a show_b message to B1\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = d_objid,
                 targetid = b1_objid);
   if(!(sts&1))
   {
      printf (" error in om$send (showb) to B1\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Is B1 on D */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "scb";
   sts = om$is_objid_on_channel(osnum_c = OM_Gw_TransOSnum_0,
                                objid_c = d_objid,
                                p_chanselect = &chansel,
                                objid = b1_objid,
                                osnum2 = "OM_TransOS_0");
   if (!(1&sts))
   {
      printf (" error in om$is_objid_on_channel b1 on D's scb channel\n");
      om$report_error(sts=sts);
      exit();
   }

   chansel.type = OM_e_name;
   chansel.u_sel.name = "scb";

if ( argc == 1 )
{
   printf ("\n----- Deleting everyone on D's scb channel\n");
}
   sts = om$send(mode = OM_e_wrt_message,
                 msg = &root_del,
                 senderid = d_objid,
                 p_chanselect = &chansel,
                 from = from,
                 to = to);
   if(!(sts&1))
   {
	printf("error in om$send (Root.delete) out D's scb channel\n");
	om$report_error(sts = sts);
        exit();
   }
   
   /* Create a new C object and connect it to B[1] by send obj wrt obj */

if ( argc == 1 )
{
   printf("\n----- Sending a new_c_to_b message to C[0]\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &new_c_to_b,
                 senderid = b_objid[1],
                 targetid = c_objid[0]);
   if(!(sts&1))
   {
      printf (" error in om$send (new_c_to_b) to C[0]\n");
      om$report_error(sts = sts);
      exit();
   }
 
if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for B[1]'s bcs channel\n");
  
   sts = OMT_dump_relation ( OM_Gw_current_OS, b_objid[1], "bcs" );
   if(!(sts&1))
   {
      printf (" error in OMT_dump_relation for B1\n");
      om$report_error(sts=sts);
      exit();
   }
 
   printf ("\n----- Dumping channel info for C[0]'s scb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, c_objid[0], "scb" );
   if(!(sts&1))
   {
      printf (" error in OMT_dump_relation for C0\n");
      om$report_error(sts=sts);
      exit();
   }
}

if ( argc == 1 )
{
   printf ("\n----- Sending a show_b message to B[1]\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = c_objid[0],
                 targetid = b_objid[1]);
   if(!(sts&1))
   {
      printf (" error in om$send (showb) to B[1]\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Is B1 connected to anyone on other side of "bcs" */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "bcs";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = b_objid[1],
                              p_chanselect = &chansel,
                              count = &count);
   if(!(sts&1))
   {
      printf (" error in om$get_channel_count for B[1]'s bcs channel\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf (" Channel Count for B[1]'s bcs channel is %d\n", count);
}
   if ( count != 1 )
   {
      printf (" count for B[1]'s bcs is incorrect - expected 1\n");
      exit();
   }


/********************************************************************/
/*		Test Restricted Channels	                    */
/********************************************************************/

   sts = om$make_message(classname = "ResA",
                         methodname = "assign_a",
                         size = 4,
                         p_arglist = &zro,
                         p_msg = &ass_a );
   if (!(1&sts))
   {
      printf (" error in om$make_message for ResA.assign_a\n");
      om$report_error(sts=sts);
      exit();
   }

   sts = om$make_message(classname = "ResA",
                         methodname = "show",
                         p_msg = &showd_d );
   if (sts&1)
   {
      printf (" expected an error in om$make_message for ResA.show\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "ResA",
                         methodname = "delete",
                         p_msg = &del );
   if (!(sts&1))
   {
      printf (" error in om$make_message for ResA.delete\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "ResB",
                         methodname = "assign_b",
                         size = 4,
                         p_arglist = &i,
                         p_msg = &ass_b );
   if (!(sts&1))
   {
      printf (" error in om$make_message for ResB.assign_b\n");
      om$report_error(sts = sts);
      exit();
   }

   sts = om$make_message(classname = "ResB",
                         methodname = "show_b",
                         p_msg = &showb );
   if (!(1&sts))
   {
      printf (" error in om$make_message for ResB.show_b\n");
      om$report_error(sts=sts);
      exit();
   }
  
if ( argc == 1 )
{
   printf ("\n----- Constructing ResA\n");
}
   
   sts = om$construct(osname = "OM_TransOS_0",
                      classname = "ResA",
                      p_objid = &resa_objid,
                      neighbor = OM_GS_NULL_NEIGHBOR,
                      msg = &ass_a );
   if (!(sts&1))
   {
      printf (" error in om$construct for ResA \n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if ResA's objid of %d is valid ---\n", resa_objid);
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = resa_objid);
   if (!(sts&1))
	{
	printf("Object id is invalid : %x \n", sts);
	om$report_error(sts = sts);
	exit();
	}


   sts = om$get_channel_number(channame = "ResA.acb",
                               p_channum = &chan_resa );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for acb : %x \n", sts
);
      om$report_error(sts = sts);
      exit();
   }

   sts = om$get_channel_number(channame = "ResA.acs",
                               p_channum = &chan_resacs );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for acs : %x \n", sts
);
      om$report_error(sts = sts);
      exit();
   }

   sts = om$get_channel_number(channame = "ResB.bca",
                               p_channum = &chan_resb );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_number for bca : %x \n", sts
);
      om$report_error(sts = sts);
      exit();
   }


   /* Get Class ResA's classid */

   sts = om$get_classid(classname = "ResA",
                        p_classid = &resa_classid);
   if (!(sts&1))
   {
      printf (" error in om$get_classid for class ResA\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf ("Classid for ResA is %d\n", resa_classid);
}
   for ( i=0; i<MAXB; i++ )
   {
if ( argc == 1 )
{
      printf ("\n----- Constructing ResB[%d]\n",i);
}
      sts = om$construct(osname = "OM_TransOS_0",
                         classname = "ResB",
                         p_objid = &resb_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR,
                         msg = &ass_b);
      if (!(sts&1))
      {
         printf (" error in om$construct for ResB : %x \n", sts );
         om$report_error(sts = sts);
         exit();
      }

      sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                              objid = resb_objid[i]);
      if (!(sts&1))
      {
	printf("Object of ResB[%d] id is invalid\n",i);
	om$report_error(sts = sts);
	exit();
      }

      connect_args.to_sel.type = OM_e_num;
      connect_args.to_sel.u_sel.number = chan_resb;
      connect_args.to_idx = 0;
      connect_args.fr_objid = resa_objid;
      connect_args.fr_os = OM_Gw_current_OS;
      connect_args.fr_sel.type = OM_e_num;
      connect_args.fr_sel.u_sel.number = chan_resa;
      connect_args.fr_idx            = 0;

if ( argc == 1 )
{
      printf ("----- Connecting ResB[%d] to ResA\n",i);
}

      sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid,			
		       targetid = resb_objid[i] );
 
      if (!(sts&1))
      {
         printf (" error in connect for ResB[%d] to ResA\n",i);
         om$report_error(sts = sts);
         exit();
      }
   } /* for */

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResA on channel acb\n");

   sts = OMT_dump_relation( OM_Gw_current_OS, resa_objid, "acb" );
   if(!(sts&1))
   {
	printf("error in OMT_dump_relation for ResA: %x\n",  sts);
	exit();
   }

   for(i=0; i<MAXB; i++)   
   {
      printf ("\n----- Dumping channel info for ResB[%d] on channel bca\n",i);

      sts = OMT_dump_relation( OM_Gw_current_OS, resb_objid[i], "bca" );
      if(!(sts&1))
      {
         printf("error in OMT_dump_relation for ResB[%d]: %x\n", i,  sts);
         exit();
      }
   }
}

if ( argc == 1 )
{
   printf ("\n----- Issue a channel send to show all ResB's connected to ResA\n");
}
   from = 0;
   to = OM_K_MAXINT;
   chansel.type =OM_e_name;
   chansel.u_sel.name = "acb";

   sts = om$send(mode = OM_e_wrt_object,
                    msg = &showb,
                    senderid = resa_objid,
                    p_chanselect =&chansel,
                    from = from,
                    to = to );
   if (!(sts&1))
   {
      printf (" error in om$send (showb) out ResA's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Get Class ResB's classid */

   sts = om$get_classid(osnum = OM_Gw_TransOSnum_0,
                        objid = resb_objid[0],
                        p_classid = &resb_classid);
   if (!(1&sts))
   {
      printf (" error in om$get_classid for ResB\n");
      om$report_error(sts=sts);
      exit();
   }

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = resa_objid,
                              p_chanselect = &chansel,
                              count = &count );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_count for ResA's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf ( " Channel count for ResA's channel acb is %d \n", count );
}
   if ( count != MAXB )
   {
      printf (" count for ResA's acb is incorrect - expected %d\n",MAXB);
      exit();
   }

   chansel.type = OM_e_name;
   chansel.u_sel.name = "bca";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = resb_objid[0],
                              p_chanselect = &chansel,
                              count = &count );
   if (!(sts&1))
   {
      printf (" error in om$get_channum_count for ResB[0]'s bca channel\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ( " Channel count for ResB[0]'s channel bca is %d \n", count );
}
   if ( count != 1 )
   {
      printf (" count for ResB[0]'s bca is incorrect - expected 1\n");
      exit();
   }

   for ( i=0; i<MAXB; i++ )
   {
      chansel.type = OM_e_name;
      chansel.u_sel.name = "acb";
      sts = om$is_objid_on_channel(osnum_c = OM_Gw_TransOSnum_0,
                                   objid_c = resa_objid,
                                   p_chanselect = &chansel,
                                   objid = resb_objid[i],
                                   osnum2 = OM_Gw_TransOSnum_0);
      if (!(1&sts))
      {
         printf (" error in om$is_objid_on_channel for ResB[%d] on ResA's acb\n",i);
         om$report_error(sts=sts);
         exit();
      }
   }

if ( argc == 1 )
{
   printf ("\n----- Calling om$get_channel_objects to gather ResB's \n");
}
   siz = MAXB * sizeof(OM_S_OBJECT_LINKAGE);

   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_resa;
   sts = om$get_channel_objects(osnum = OM_Gw_TransOSnum_0,
                                objid = resa_objid,
                                p_chanselect = &chansel,
                                list = list,
                                size = siz,
                                count = &count );
   if (!(sts&1))
   {
      printf (" error in om$get_channel_objects for ResA's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }

   if ( count != MAXB )
   {
      printf (" count from om$get_channel_objects != MAXB\n");
      exit();
   }

if ( argc == 1 )
{
   printf (" Count : %d \n", count );

   for ( i=0; i<MAXB; i++ )
   {
      for ( j=0; j<MAXB; j++ )
      {
         if (IF_EQ_OBJID ( resb_objid[i], list[j].S_objid ))
            printf (" resb_objid[%d] was in list \n", i );
      }
   }
}

if ( argc == 1 )
{
   printf ("\n----- Constructing ResB1\n");
}
   sts = om$construct(obj_osnum = OM_Gw_TransOSnum_0,
                     objid = resb_objid[0],
                     osnum = OM_Gw_TransOSnum_0,
                     p_objid = &resb1_objid,
                     neighbor = OM_GS_NULL_NEIGHBOR);
   if(!(sts))
   {
      printf("error in om$construct (by objid) for ResB1\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if %d is valid objid ---\n", resb1_objid );
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = resb1_objid);
   if (!(sts&1))
   {
	printf("Object id of ResB1 is invalid\n");
	om$report_error(sts = sts);
	exit();
   }

   disconnect_args.to_sel.type = OM_e_num;
   disconnect_args.to_sel.u_sel.number = chan_resa;
   disconnect_args.fr_sel.type = OM_e_num;
   disconnect_args.fr_sel.u_sel.number = chan_resb;
   disconnect_args.fr_os = OM_Gw_current_OS;
   disconnect_args.fr_objid = resb1_objid;

   sts = om$send (msg = &disconnect_msg,			
		       senderid = resb1_objid,			
		       targetid = resa_objid );
 
   if (sts != OM_W_NOTONCHAN)
   {
      printf (" unexpected result from disconnect of ResB1 from ResA\n");
      printf (" expected OM_W_NOTONCHAN\n");
      exit();
   }
   
   /* Disconnect ResB[0]'s channel from object on other side */

   disconnect_args.to_sel.type = OM_e_num;
   disconnect_args.to_sel.u_sel.number = chan_resa;
   disconnect_args.fr_sel.type = OM_e_num;
   disconnect_args.fr_sel.u_sel.number = chan_resb;
   disconnect_args.fr_os = OM_Gw_current_OS;
   disconnect_args.fr_objid = resb_objid[0];

if ( argc == 1 )
{
   printf ("\n----- Disconnecting ResA and ResB[0]\n");
}
   sts = om$send (msg = &disconnect_msg,			
		       senderid = resb_objid[0],			
		       targetid = resa_objid );

   if (!(1&sts))
   {
      printf (" error from disconnect of ResB[0] from ResA\n");
      om$report_error(sts=sts);
      exit();
   }

if ( argc == 1 )
{
    printf ("\n----- Dumping channel info for ResA's acb channel\n");

    sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid, "acb" );
    if(!(sts&1))
    {
	printf("error in OMT_dump_relation for ResA: %x\n",  sts);
	exit();
    }

    printf ("\n----- Dumping channel info for ResB[0]'s bca channel\n");

    sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[0], "bca" );
    if(!(sts&1))
    {
	printf("error in OMT_dump_relation for ResB0: %x\n",  sts);
	exit();
    }
}

if ( argc == 1 )
{
   printf ("\n----- Issuing a channel send to show all ResB's connected to ResA\n" );

}
   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = resa_objid,
                 p_chanselect = &chansel,
                 from = from,
                 to = to );
   if (!(sts&1))
   {
      printf (" error in om$send (showb) out ResA's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }


   /* Using Bad Channel Name, Get Channel Count after Disconnect */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "aaa";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = resa_objid,
                              p_chanselect = &chansel,
                              count = &count);
   if (sts&1)
   {
      printf (" expected an error in om$get_channel_count\n");
      printf (" aaa is not a valid channel of ResA\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Construct Another Instance of Class ResA: ResA1 */

if ( argc == 1 )
{
   printf ("\n----- Constructing ResA1 by classid\n");
}
   sts = om$construct(osnum = OM_Gw_TransOSnum_0,
                      classid = resa_classid,
                      p_objid = &resa1_objid,
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if (!(sts&1))
   {
      printf ("error in om$construct (by classid) for ResA1\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf("--- test if ResA1's objid of %d is valid ---\n", resa1_objid );
}
   sts = om$is_objid_valid(osnum = OM_Gw_TransOSnum_0,
                           objid = resa1_objid);
   if (!(sts&1))
   {
	printf("Object id of ResA1 is invalid\n");
	om$report_error(sts = sts);
	exit();
   }

   /* Construct  C objects, after getting its classid */
   
   sts = om$get_classid(classname = "C",
                        p_classid = &c_classid);
   if(!(sts&1))
   {
      printf("error on om$get_classid for C\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Constructing C[0-%d] by classid\n", MAXC-1);
}

for (i=0; i<MAXC; i++ )
   {
   sts = om$construct(osnum = OM_Gw_TransOSnum_0,
                      classid = c_classid,
                      p_objid = &c_objid[i],
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if (!(sts&1))   
   {
      printf (" error on om$construct (by classid) for C\n");
      om$report_error(sts = sts);
      exit();
   }
}

   /* Connect C0-3 to ResA1 */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "sca";
   connect_args.to_idx = 0;
   connect_args.fr_objid = resa1_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "acs";
   connect_args.fr_idx            = 0;

for ( i=0; i<(MAXC-1); i++)
{
if ( argc == 1 )
{
   printf ("\n----- Connecting C[%d] to ResA1\n",i);
}
   sts = om$send (msg = &connect_msg,			
		       senderid = resa1_objid,			
		       targetid = c_objid[i] );
   if(!(sts&1))
   {
      printf("error on om$connect for C%d to ResA1\n",i);
      om$report_error(sts = sts);
      exit();
   }

   printf ("\n----- Dumping channel info for C[%d]'s sca channel\n",i);
    
   sts = OMT_dump_relation ( OM_Gw_current_OS, c_objid[i], "sca" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for C: %x\n",  sts);
      om$report_error(sts=sts);
      exit();
   }
}

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResA1's acs channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resa1_objid, "acs" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for ResA1\n");
      om$report_error(sts=sts);
      exit();
   }

}

   /* Connect C4 to ResA1 */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "acs";
   connect_args.to_idx = 0;
   connect_args.fr_objid = c_objid[MAXC-1];
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "sca";
   connect_args.fr_idx            = 0;


if ( argc == 1 )
{
   printf ("\n----- Connecting C[%d] to ResA1\n",MAXC-1);
}
   sts = om$send (msg = &connect_msg,			
		       senderid = c_objid[MAXC-1],			
		       targetid = resa1_objid);
   if(!(sts&1))
   {
      printf("error on om$connect for C%d to ResA1\n",MAXC-1);
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResA1's acs channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resa1_objid, "acs" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for ResA1\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for C[%d]'s sca channel\n",MAXC-1);
    
   sts = OMT_dump_relation ( OM_Gw_current_OS, c_objid[MAXC-1], "sca" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for C: %x\n",  sts);
      om$report_error(sts=sts);
      exit();
   }
}

   /* Construct an object of Class D */

   sts = om$get_classid(classname = "D",
                        p_classid = &d_classid );
   if(!(sts&1))
   {
      printf("error in om$get_classid for D\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Constructing D\n");
}
   sts = om$construct(osname = "OM_TransOS_0",
                      classname = "D",
                      p_objid = &d_objid,
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if(!(sts&1))
   {
      printf("error in om$construct for D\n");
      om$report_error(sts = sts);
      exit();
   }


   /* Assign 0 to D */

if ( argc == 1 )
{
   printf ("\n----- Sending assign_d to D\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &ass_d,
                 senderid = d_objid,
                 targetid = d_objid);
   if (!(sts&1))
   {
      printf(" error in om$send (assign_d)\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Perform send wrt message */

if ( argc == 1 )
{
   printf ("\n----- Send a show message to D\n");
}
   sts = om$send(mode = OM_e_wrt_message,
                 msg = &showd_c,
                 senderid = d_objid,
                 targetid = d_objid);
   if (!(sts&1))
   {
      printf(" error in om$send (showd_c)\n");
      om$report_error(sts = sts);
      exit();
   }

   /* Active Class ResA does not match a superclass of D so OM_W_UNKNOWN_MSG */

   sts = om$send(msg = &showd_d,
                 senderid = resa_objid,
                 targetid = resa_objid);
   if (sts != OM_W_UNKNOWN_MSG)
   {
      printf(" error in om$send (showd_d) - expected OM_W_UNKNOWN_MSG\n");
      om$report_error(sts = sts);
      exit();
   }


   /* Disconnect ResA1 from ResB1: after first connecting them */

   connect_args.to_sel.type = OM_e_name;
   connect_args.to_sel.u_sel.name = "bca";
   connect_args.to_idx = 0;
   connect_args.fr_objid = resa1_objid;
   connect_args.fr_os = OM_Gw_current_OS;
   connect_args.fr_sel.type = OM_e_name;
   connect_args.fr_sel.u_sel.name = "acb";
   connect_args.fr_idx            = 0;

if ( argc == 1 )
{
   printf ("\n----- Connecting ResA1 to ResB1\n");
}
   sts = om$send (msg = &connect_msg,			
		       senderid = resa1_objid,			
		       targetid = resb1_objid );
 
   if(!(sts&1))
   {
      printf(" error in om$send (connect) for ResA1 to ResB1\n");
      om$report_error(sts = sts);
      exit();
   }
   
if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResA1's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resa1_objid, "acb" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for ResA1\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for ResB1's bca channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resb1_objid, "bca" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for ResB1: %x\n",  sts);
      om$report_error(sts=sts);
      exit();
   }
}

if ( argc == 1 )
{
   printf ("\n----- Sending a show_b message to ResB1\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showb,
                 senderid = resa1_objid,
                 targetid = resb1_objid);
   if (!(sts&1))
   {
      printf(" error in om$send (showb) to ResB1\n");
      om$report_error(sts = sts);
      exit();
   }

   disconnect_args.to_sel.type = OM_e_name;
   disconnect_args.to_sel.u_sel.name = "bca";
   disconnect_args.fr_sel.type = OM_e_name;
   disconnect_args.fr_sel.u_sel.name = "acb";
   disconnect_args.fr_os = OM_Gw_current_OS;
   disconnect_args.fr_objid = resa1_objid;

if ( argc == 1 )
{
   printf ("\n----- Disconnecting ResA1 and ResB1\n");
}
   sts = om$send (msg = &disconnect_msg,			
		       senderid = resa1_objid,			
		       targetid = resb1_objid );
 
   if (!(1&sts))
   {
      printf (" error in disconnect of ResA1 from ResB1\n");
      om$report_error(sts=sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResA1's acb channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resa1_objid, "acb" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for ResA1\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for ResB1's bca channel\n");
   
   sts = OMT_dump_relation ( OM_Gw_current_OS, resb1_objid, "bca" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for ResB1\n");
      om$report_error(sts=sts);
      exit();
   }
}

   /* Move Channel "bca" from ResB2 to ResB0 */

   move_chan_args.to_sel.type = OM_e_name;
   move_chan_args.to_sel.u_sel.name = "bca";
   move_chan_args.fr_objid = resb_objid[2];
   move_chan_args.fr_os = OM_Gw_current_OS;
   move_chan_args.fr_sel.type = OM_e_name;
   move_chan_args.fr_sel.u_sel.name = "bca";

if ( argc == 1 )
{
   printf ("\n----- Issue a move channel from ResB[2]'s bcs to ResB[0]'s bca\n");
}
   sts = om$send (msg = &move_chan_msg,			
		       senderid = resb_objid[2],			
		       targetid = resb_objid[0] );
 
   if(!(sts&1))
   {
      printf("error in om$send (move_channel)\n");
      om$report_error(sts = sts);
      exit();
   }

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResB[2]'s bcs channel\n");

   sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[2], "bca" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for ResB2\n");
      om$report_error(sts=sts);
      exit();
   }

   printf ("\n----- Dumping channel info for ResB[0]'s bca channel\n");
   
   sts = OMT_dump_relation ( OM_Gw_current_OS, resb_objid[0], "bca" );
   if(!(sts&1))
   {
      printf(" error in OMT_dump_relation for ResB0\n");
      om$report_error(sts=sts);
      exit();
   }
}

   /* Get List of Channel Objects on ResB0 */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "bca";
   sts = om$get_channel_objects(osnum = OM_Gw_TransOSnum_0,
                                objid = resb_objid[0],
                                p_chanselect = &chansel,
                                list = list,
                                size = siz,
                                count = &count);
   if(!(sts&1))
   {
      printf("error in om$get_channel_objects on ResB[0]'s bca channel\n");  
      om$report_error(sts = sts);
      exit();
   }

printf("Number of objects on ResB[0] bca: %d\n", count);

   /* Disconnect all objects connected to ResA via acb */

   wild_disconnect_args.to_sel.type = OM_e_num;
   wild_disconnect_args.to_sel.u_sel.number = chan_resa;  
   
   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_resa;

if ( argc == 1 )
{
   printf ("\n----- Issue a Root.wild_disconnect on ResA's acb channel\n");
}

   sts = om$send (mode = OM_e_wrt_message,
                  msg = &wild_disconnect_msg,			
                  senderid = resa_objid,			
		  targetid=resa_objid );
 
   if (!(1&sts))
   {
      printf (" error in om$send of Root.wild_disconnect out ResA's acb\n");
      om$report_error(sts=sts);
      exit();
   }   

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResA's acb channel\n");
    
   sts = OMT_dump_relation ( OM_Gw_current_OS, resa_objid, "acb" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for ResA\n");
      om$report_error(sts=sts);
      exit();
    }
}

   /* Get Channel Count after Disconnect : other side */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acb";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = resa_objid,
                              p_chanselect = &chansel,
                              count = &count);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_count for ResA's acb channel\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf (" Channel count for ResA's acb channel is %d\n", count);
}

   if ( count != 0 )
   {
      printf (" count for ResA's acb is incorrect - expected 0\n");
      exit();
   }

   /* Disconnect all objects connected to ResA1 via acs */

   wild_disconnect_args.to_sel.type = OM_e_num;
   wild_disconnect_args.to_sel.u_sel.number = chan_resacs;  
   
   chansel.type = OM_e_num;
   chansel.u_sel.number = chan_resacs;

if ( argc == 1 )
{
   printf ("\n----- Issue a Root.wild_disconnect on ResA1's acs channel\n");
}

   sts = om$send (mode = OM_e_wrt_message,
                  msg = &wild_disconnect_msg,			
                  senderid = resa1_objid,			
		  targetid=resa1_objid );
 
   if (!(1&sts))
   {
      printf (" error in om$send of Root.wild_disconnect out ResAa's acs\n");
      om$report_error(sts=sts);
      exit();
   }   

if ( argc == 1 )
{
   printf ("\n----- Dumping channel info for ResA1's acs channel\n");
    
   sts = OMT_dump_relation ( OM_Gw_current_OS, resa1_objid, "acs" );
   if(!(sts&1))
   {
      printf("error in OMT_dump_relation for ResA1\n");
      om$report_error(sts=sts);
      exit();
    }
}

   /* Get Channel Count after Disconnect : other side */

   chansel.type = OM_e_name;
   chansel.u_sel.name = "acs";
   sts = om$get_channel_count(osnum = OM_Gw_TransOSnum_0,
                              objid = resa1_objid,
                              p_chanselect = &chansel,
                              count = &count);
   if (!(sts&1))
   {
      printf(" error in om$get_channel_count for ResA1's acs channel\n");
      om$report_error(sts = sts);
      exit();
   }
if ( argc == 1 )
{
   printf (" Channel count for ResA1's acs channel is %d\n", count);
}

   if ( count != 0 )
   {
      printf (" count for ResA1's acs is incorrect - expected 0\n");
      exit();
   }

   /* Delete ResA1: an unconnected object */

if ( argc == 1 )
{
   printf ("\n----- Deleting ResA1\n");
}
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &del,
                 senderid = resa1_objid,
                 targetid = resa1_objid );
   if (!(1&sts))
   {
      printf (" error in om$send (Root.delete) for ResA1\n");
      om$report_error(sts=sts);
      exit();
   }


}

