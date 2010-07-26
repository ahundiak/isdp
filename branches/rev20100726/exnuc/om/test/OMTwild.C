#include "OMobjectcomm.h"
#define MAXB	25

main ()
{
int		sts, i;
OM_S_OBJID	a_objid, b_objid[MAXB];
char            *chan_acb,*chan_bca;
OM_S_CHANSELECT chansel;
OM_S_MESSAGE	connect_msg,showa, showb,wild_disconnect_msg;

struct wild_disconnect_struct
       {
         OM_S_CHANSELECT   to_sel;
       } wild_disconnect_args;
struct connect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 uword                fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
       } connect_args;

chan_acb = "A.acb";
chan_bca = "B.bca";

sts = om$runtime_init();
if (!(sts&1))
{
    printf ("error in om$runtime_init: %x \n", sts );
    om$report_error(sts = sts);
    exit();
}

sts = om$construct(osname = "OM_TransOS_0",
                   classname = "A",
                   p_objid = &a_objid,
                   neighbor = OM_GS_NULL_NEIGHBOR);
if (!(sts&1))
{
    printf ("error in om$construct : %x \n", sts );
    om$report_error(sts = sts);
    exit();
}

sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, chan_acb);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for A: %x\n", sts);
    exit();
}
    
sts = om$make_message(classname = "A",
                      methodname = "show_a",
                      p_msg = &showa );
if(!(sts&1))
{
    printf("error in om$make_message for show_a: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

sts = om$send(mode = OM_e_wrt_object,
              msg = &showa,
              senderid = a_objid,
              targetid = a_objid);
if(!(sts&1))
{
    printf("error in om$send for show_a: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

/* Wild Disconnect: singleton case */
wild_disconnect_args.to_sel.type = OM_e_name;
wild_disconnect_args.to_sel.u_sel.name = chan_acb;

sts = om$make_message(classname = "Root",		
		      methodname = "wild_disconnect",		
		      size = sizeof( struct wild_disconnect_struct),
		      p_arglist = &wild_disconnect_args,	
		      p_msg = &wild_disconnect_msg );
if(!(sts&1))
{
    printf("error in om$make_message for wild_disconnect: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

chansel.type = OM_e_name;
chansel.u_sel.name = chan_acb;
sts = om$send (msg = &wild_disconnect_msg,			
	       senderid = a_objid,			
	       targetid = a_objid);
 
if (!(sts&1))
{
    printf ("error in om$send msg=wild_disconnect singleton case: %x \n", sts );
    om$report_error(sts = sts);
    exit();
}
printf("\n\n\n********Wild Disconnect: singleton case********\n\n\n");

sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, chan_acb);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for A: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}
    
   sts = om$construct(osname = "OM_TransOS_0",
                      classname = "B",
                      p_objid = &b_objid[0],
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if (!(sts&1))
   {
       printf ("error in construction of B[0]: %x \n", sts );
       om$report_error(sts = sts);
       exit();
   }

/* Connect A to B0 to create dipole connection */

        connect_args.to_idx = 0;
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
        connect_args.fr_idx = 0;
	connect_args.fr_objid = a_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;

sts = om$make_message(classname = "Root",		
		      methodname = "connect",		
		      size = sizeof( struct connect_struct),
		      p_arglist = &connect_args,	
		      p_msg = &connect_msg );
if(!(sts&1))
{
    printf("error in om$make_message for connect: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

   sts = om$send (msg = &connect_msg,			
	          senderid = a_objid,			
	          targetid = b_objid[0] );

   if (!(sts&1))
   {
       printf ("error connecting A to B0: %x \n", sts );
       om$report_error(sts = sts);
       exit();
   }

sts = om$make_message(classname = "B",
                      methodname = "show_b",
                      p_msg = &showb );
if(!(sts&1))
{
    printf("error in om$make_message for show_b: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

sts = om$send(mode = OM_e_wrt_object,
              msg = &showb,
              senderid = a_objid,
              targetid = b_objid[0]);
if(!(sts&1))
{
    printf("error in om$send_object for show_b: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

/* Wild Disconnect: dipole case */

sts = om$send (msg = &wild_disconnect_msg,			
	       senderid = a_objid,			
	       targetid = a_objid );

if (!(sts&1))
{
    printf ("error in wild_disconnect dipole case: %x \n", sts );
    om$report_error(sts = sts);
    exit();
}
printf("\n\n\n********Wild Disconnect: dipole case********\n\n\n");

sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, chan_acb);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for A: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}
sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[0], chan_bca);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for B[0]: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}

for (i=1; i<MAXB; i++)
{
   sts = om$construct(osname = "OM_TransOS_0",
                      classname = "B",
                      p_objid = &b_objid[i],
                      neighbor = OM_GS_NULL_NEIGHBOR);
   if (!(sts&1))
   {
       printf ("error in om$construct for B[%d]: %x \n", i, sts );
       om$report_error(sts = sts);
       exit();
   }

/* cvrt40 #7: Old-fashioned OM: OM_connect_by_name */
/* cvrt40 #7:	-- connect is now a message of Root */
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.fr_objid = a_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;

   sts = om$send (msg = &connect_msg,			
	          senderid = a_objid,			
	          targetid = b_objid[i] );

   if (!(sts&1))
   {
       printf ("error in connect of A to B%d: %x \n", i, sts );
       om$report_error(sts = sts);
       printf("iteration: %d\n", i);
       exit();
   }
}
printf("created a relation object\n");

sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, chan_acb);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for A: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}


for(i=1; i<MAXB; i++)
{
  sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], chan_bca);
  if(!(sts&1))
  {
    printf("error in OMT_dump_relation for B[%d]: %x\n", i, sts);
    om$report_error(sts = sts);
    exit();
  }
}


chansel.type = OM_e_name;
chansel.u_sel.name = chan_acb;
sts = om$send(mode = OM_e_wrt_object,
              msg = &showb,
              senderid = a_objid,
              p_chanselect = &chansel,
              from = 0,
              to = MAXB);
if(!(sts&1))
{
    printf("error in om$send_by_channame for show_b: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

/* Wild Disconnect: FROM case */

sts = om$send (msg = &wild_disconnect_msg,			
	       senderid = a_objid,			
	       targetid = a_objid );

if (!(sts&1))
{
    printf ("error in wild_disconnect FROM case: %x \n", sts );
    om$report_error(sts = sts);
    exit();
}
printf("\n\n\n********Wild Disconnect: FROM case********\n\n\n");
sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, chan_acb);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for A: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}

for(i=1; i<MAXB; i++)
{
  sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], chan_bca);
  if(!(sts&1))
  {
    printf("error in OMT_dump_relation for B[%d]: %x\n", i, sts);
    om$report_error(sts = sts);
    exit();
  }
}

for (i=0; i<MAXB; i++)
{
	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.fr_objid = a_objid;
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;

   sts = om$send (msg = &connect_msg,			
	          senderid = a_objid,			
	          targetid = b_objid[i] );

   if (!(sts&1))
   {
       printf ("error in connect A to B%d: %x \n", i, sts );
       om$report_error(sts = sts);
       printf("iteration: %d\n", i);
       exit();
   }

}
printf("reconnected all B objects to A\n");


/* Wild Disconnect: TO case */

sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, chan_acb);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for A: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}

for(i=0; i<MAXB; i++)
{
  sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], chan_bca);
  if(!(sts&1))
  {
    printf("error in OMT_dump_relation for B[%d]: %x\n", i, sts);
    om$report_error(sts = sts);
    exit();
  }
}

chansel.type = OM_e_name;
chansel.u_sel.name = chan_acb;
sts = om$send(mode = OM_e_wrt_object,
              msg = &showb,
              senderid = a_objid,
              p_chanselect = &chansel,
              from = 0,
              to = MAXB);
if(!(sts&1))
{
    printf("error in om$send thru A's acb channel for show_b: %x\n",  sts);
    om$report_error(sts = sts);
    exit();
}

wild_disconnect_args.to_sel.type = OM_e_name;
wild_disconnect_args.to_sel.u_sel.name = chan_bca;
sts = om$send (msg = &wild_disconnect_msg,			
	       senderid = b_objid[24],			
	       targetid = b_objid[24] );

if (!(sts&1))
{
    printf ("error in wild_disconnect TO case: %x \n", sts );
    om$report_error(sts = sts);
    exit();
}
printf("\n\n\n********Wild Disconnect: TO case********\n\n\n");

sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[24], chan_bca);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for B[24]: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}
sts = OMT_dump_relation( OM_Gw_current_OS, a_objid, chan_acb);
if(!(sts&1))
{
    printf("error in OMT_dump_relation for A: %x\n", sts);
    om$report_error(sts = sts);
    exit();
}
   
}
