#include "OMobjectcomm.h"
#define	MAXA	20	/* minimum of 2 !!!!!!!!!!!! */
#define MAXB	20	/* minimum of 2 !!!!!!!!!!!! */

extern int OMT_dump_relation();

main ()
{
/*	One extra set of data structures are allocated for A's and B's.
	The last A and B will be connected as a dipole.
*/
int		sts, i, half_A, half_B;
OM_S_OBJID	a_objid[MAXA+1], b_objid[MAXB+1];
OM_S_OBJID	resa_objid[MAXA+1], resb_objid[MAXB+1];
int		relindex=0;
uword		minorchan=0;
OM_S_MESSAGE	disconnect_msg,connect_msg,showa, showb;
OM_S_MESSAGE    range_disconnect_msg;
OM_S_CHANSELECT chansel;
char            *chan_acb,*chan_bca, *chan_resacb, *chan_resbca;

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

struct range_disconnect_struct
       {
         OM_S_CHANSELECT      to_sel;
         int                  low_index;
         int                  hi_index;
       } range_disconnect_args;


half_A=MAXA/2; half_B=MAXB/2;

sts = om$runtime_init();
if (!(sts&1))
 {
  printf ("error in om$runtime_init: %x \n", sts );
  om$report_error(sts=sts);
  exit();
 }

chan_acb = "A.acb";
chan_bca = "B.bca";

/*
	Construct A's
*/
printf("\n>>> Table of A's object IDs::\n");
for (i=0; i<MAXA+1; i++)
 {
   sts = om$construct (osname="OM_TransOS_0",classname="A",	
					p_objid=&a_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$construct object A[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    exit();
   }
  printf("\n>>> A[%d]: %d",i,a_objid[i]);
 }
/*
	Construct B's
*/
printf("\n\n>>> Table of B's object IDs::\n");
for (i=0; i<MAXB+1; i++)
 {
   sts = om$construct (osname="OM_TransOS_0",classname="B",	
					p_objid=&b_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$construct object B[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    exit();
   }
  printf("\n>>> B[%d]: %d ",i,b_objid[i]);
 }
/*
	Connect last A to last B
*/
printf("\n\n>>> Connect Last A to Last B\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[MAXA];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );
	if(!(sts&1))
 	{
  	   printf("error in om$make_message for connect: %x\n",  sts);
  	   om$report_error(sts=sts);
  	   exit();
 	}
	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[MAXA],			
		       targetid = b_objid[MAXB] );

if (!(sts&1))
 {
  printf ("error in om$send msg=connect LAST A to LAST B: %x\n", i, sts );
  om$report_error(sts=sts);
  exit();
 }
/*
	Connect last half of B's to A[0]

*/
printf("\n\n>>> Connect last half of B's to A[0]");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

for (i=half_B; i<MAXB; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[0],			
		       targetid = b_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$send msg=connect B[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }
/*
	Connect last half of A's to B[0]

*/

printf("\n\n>>> Connect last half of A's to B[0]");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

for (i=half_A; i<MAXA; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[0],			
		       targetid = a_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$send msg=connect A[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }
/*
	Connect first half of B's to A[1]

  note: a many-to-many object existed for B[0] thus a connection between
	two many-to-many objects occurs

*/

printf("\n\n>>> Connect first half of B's to A[1]");
printf("\n>>>>>> note: an entry was inserted into B[0]'s bca channel");
printf("\n>>>>>>       linking itself to A[1]'s acb channel");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_bca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = a_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_acb;
	connect_args.fr_idx            = 0;

for (i=0; i<half_B; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = a_objid[1],			
		       targetid = b_objid[i] );
 
  if (!(sts&1))
   {
    printf ("error in om$send msg=connect B[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }
/*
	Connect first half of A's to B[1]

  note: a many-to-many connection existed for A[0] thus a connection between
	two many-to-many connections occurs

*/

printf("\n\n>>> Connect first half of A's to B[1]");
printf("\n>>>>>> note: an entry was inserted into A[0]'s acb channel");
printf("\n>>>>>>       linking itself to B[1]'s bca channel");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_acb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = b_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_bca;
	connect_args.fr_idx            = 0;

for (i=0; i<half_A; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = b_objid[1],			
		       targetid = a_objid[i] );
 
  if (!(sts&1))
   {
    printf ("error in om$send msg=connect A[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }
/*
	For each B dump relations
*/
printf("\n\n>>> For each B dump relations::\n");
for(i=0; i<MAXB+1; i++)
 {
  printf("\n>>> B[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], chan_bca);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for B[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }
/*
	Make message to send to B objects
*/
sts = om$make_message(classname="B",methodname="show_b",p_msg=&showb);

if(!(sts&1))
 {
  printf("error in om$make_message for show_b: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Send message to all B objects connected on A[0]'s "acb" channel
*/
printf("\n>>> Send message to all B's connected on A[0]'s \"acb\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "acb";
sts = om$send (msg=&showb,mode=OM_e_wrt_object,senderid=a_objid[0],
					p_chanselect=&chansel );
if(!(sts&1))
 {
  printf("error in om$send msg=show_b A[0]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Send message to all B objects connected on A[1]'s "acb" channel
*/
printf("\n>>> Send message to all B's connected on A[1]'s \"acb\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "acb";
sts = om$send (msg=&showb,mode=OM_e_wrt_object,senderid=a_objid[1],
					p_chanselect=&chansel );

if(!(sts&1))
 {
  printf("error in om$send msg= show_b A[1]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	For each A dump relations
*/
printf("\n>>> For each A dump relations\n");
for(i=0; i<MAXA+1; i++)
 {
  printf("\n>>> A[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[i], chan_acb);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for A[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }
/*
	Make message to send to A objects
*/
sts = om$make_message(classname="A",methodname="show_a",p_msg=&showa);

if(!(sts&1))
 {
  printf("error in om$make_message for show_a: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Send message to all A objects connected on B[0]'s "bca" channel
*/
printf("\n>>> Send message to all A's connected on B[0]'s \"bca\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "bca";
sts = om$send (msg=&showa,mode=OM_e_wrt_object,senderid=b_objid[0],
					p_chanselect=&chansel );

if(!(sts&1))
 {
  printf("error in om$send msg= show_a B[0]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Send message to all A objects connected on B[1]'s "bca" channel
*/
printf("\n>>> Send message to all A's connected on B[1]'s \"bca\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "bca";
sts = om$send (msg=&showa,mode=OM_e_wrt_object,senderid=b_objid[1],
					p_chanselect=&chansel );

if(!(sts&1))
 {
  printf("error in om$send msg= show_a B[1]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Disconnect the first A contained wihtin the last half of A's
	from it's associated B.

  note:	Remember that the last half of the A's were connected to B[0] (see above).
*/
printf("\n>>> Disconnect the 1st in the 2nd half of A from corresponding B\n");

     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_acb;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = 0;

     sts = om$make_message(classname = "Root",		
		           methodname = "range_disconnect",		
			   size = sizeof( struct range_disconnect_struct),
			   p_arglist = &range_disconnect_args,	
			   p_msg = &range_disconnect_msg );
     
     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = a_objid[half_A],			
	            targetid = a_objid[half_A]);

if (!(sts&1))
 {
  printf ("error in om$send msg=disconnect A[half_A] case: %x \n", sts );
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "acb" of A[half_A]
*/
printf("\n>>> Dump relations of the channel \"acb\" of A[half_A]\n");
printf("\n>>> A[%d]:",half_A);
sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[half_A], chan_acb);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for A[half_A]: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "bca" for B[0]
*/
printf("\n>>> Dump relations of the channel \"bca\" of B[0] (A[MAXA/2])\n");
printf("\n>>>>>> note: \"A[half_A]\" was connected to B[0]");
printf("\n>>> B[0]:");
sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[0], chan_bca);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for B[0] ( A[MAXA/2] case ): %x\n",i,sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Disconnect 1st half of objects connected to B[1]
*/
printf("\n>>> Disconnect 1st half of objects connected to B[1]\n");

     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_bca;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = half_A/2;

     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = b_objid[1],			
	            targetid = b_objid[1] );

if (!(sts&1))
 {
  printf ("error in om$disconnect range B[1] case: %x \n", sts );
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "bca" of B[1]
*/
printf("\n>>> Dump relations on the channel \"bca\" of B[1]\n");
sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[1], chan_bca);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for B[1]: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations on channel "acb" of all A's
*/
printf("\n>>> Dump relations on channel \"acb\" of all A's\n");
for(i=0; i<MAXA+1; i++)
 {
  printf("\n>>> A[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[i], chan_acb);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for A[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }
/*
	Disconnect All objects connected to A[0] on channel "acb"

  note: the last index of the relation is used if it is exceeded by the
	given "end" index

*/
printf("\n>>> Disconnect All objects connected to A[0] on channel \"acb\"\n");

     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_acb;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = MAXB+99;

     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = a_objid[0],			
	            targetid = a_objid[0] );

if (!(sts&1))
 {
  printf ("error in om$disconnect range A[0] case: %x \n", sts );
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "acb" of A[0]
*/
printf("\n>>> Dump relations of the channel \"acb\" of A[0]\n");
sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[0], chan_acb);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for A[0]: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "bca" for all B's
*/
printf("\n>>> Dump relations of the channel \"bca\" for all B's\n");
for(i=0; i<MAXB+1; i++)
 {
  printf("\n>>> B[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[i], chan_bca);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for B[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }
/*
	Disconnect LAST A from LAST B
*/
printf("\n>>> Disconnect LAST A from LAST B \"acb\"\n");
     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_acb;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = MAXA;
     
     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = a_objid[MAXA],			
	            targetid = a_objid[MAXA] );

if (!(sts&1))
 {
  printf ("error in om$disconnect range LAST A & B case: %x \n", sts );
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "acb" of A[MAXA]
*/
printf("\n>>> Dump relations of the channel \"acb\" of LAST A\n");
printf("\n>>> A[%d]:",MAXA);
sts = OMT_dump_relation( OM_Gw_current_OS, a_objid[MAXA], chan_acb);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for LAST A: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "bca" for B[MAXB]
*/
printf("\n>>> Dump relations of the channel \"bca\" of LAST B\n");
printf("\n>>> B[%d]:",MAXB);
sts = OMT_dump_relation( OM_Gw_current_OS, b_objid[MAXB], chan_bca);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for LAST B: %x\n", i, sts);
  om$report_error(sts=sts);
  exit();
 }

/*************************************************************/
/*		Restricted Section			     */
/*************************************************************/

printf("\n\n******************************************************\n");
printf("	     Restricted Tests\n");
printf("******************************************************\n\n");

chan_resacb = "ResA.acb";
chan_resbca = "ResB.bca";

/*
	Construct ResA's
*/

printf("\n>>> Table of ResA's object IDs::\n");
for (i=0; i<MAXA+1; i++)
 {
   sts = om$construct (osname="OM_TransOS_0",classname="ResA",	
					p_objid=&resa_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$construct object ResA[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    exit();
   }
  printf("\n>>> ResA[%d]: %d",i,resa_objid[i]);
 }

/*
	Construct ResB's
*/

printf("\n\n>>> Table of ResB's object IDs::\n");
for (i=0; i<MAXB+1; i++)
 {
   sts = om$construct (osname="OM_TransOS_0",classname="ResB",	
					p_objid=&resb_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$construct object ResB[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    exit();
   }
  printf("\n>>> ResB[%d]: %d ",i,resb_objid[i]);
 }

/*
	Connect last ResA to last ResB
*/

printf("\n\n>>> Connect Last ResA to Last ResB\n");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[MAXA];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

	sts = om$make_message(classname = "Root",		
			      methodname = "connect",		
			      size = sizeof( struct connect_struct),
			      p_arglist = &connect_args,	
			      p_msg = &connect_msg );
	if(!(sts&1))
 	{
  	   printf("error in om$make_message for connect: %x\n",  sts);
  	   om$report_error(sts=sts);
  	   exit();
 	}
	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[MAXA],			
		       targetid = resb_objid[MAXB] );

if (!(sts&1))
 {
  printf ("error in om$send msg=connect LAST ResA to LAST ResB: %x\n", i,
sts );
  om$report_error(sts=sts);
  exit();
 }

/*
	Connect last half of ResB's to ResA[0]

*/

printf("\n\n>>> Connect last half of ResB's to ResA[0]");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

for (i=half_B; i<MAXB; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[0],			
		       targetid = resb_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$send msg=connect ResB[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }

/*
	Connect last half of ResA's to ResB[0]

*/

printf("\n\n>>> Connect last half of ResA's to ResB[0]");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[0];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

for (i=half_A; i<MAXA; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[0],			
		       targetid = resa_objid[i] );

  if (!(sts&1))
   {
    printf ("error in om$send msg=connect ResA[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }

/*
	Connect first half of ResB's to ResA[1]

  note: a many-to-many object existed for ResB[0] thus a connection between
	two many-to-many objects occurs

*/

printf("\n\n>>> Connect first half of ResB's to ResA[1]");
printf("\n>>>>>> note: an entry was inserted into ResB[0]'s bca channel");
printf("\n>>>>>>       linking itself to ResA[1]'s acb channel");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resbca;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resa_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resacb;
	connect_args.fr_idx            = 0;

for (i=0; i<half_B; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = resa_objid[1],			
		       targetid = resb_objid[i] );
 
  if (!(sts&1))
   {
    printf ("error in om$send msg=connect ResB[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }

/*
	Connect first half of ResA's to ResB[1]

  note: a many-to-many connection existed for ResA[0] thus a connection
between
	two many-to-many connections occurs

*/

printf("\n\n>>> Connect first half of ResA's to ResB[1]");
printf("\n>>>>>> note: an entry was inserted into ResA[0]'s acb channel");
printf("\n>>>>>>       linking itself to ResB[1]'s bca channel");

	connect_args.to_sel.type = OM_e_name;
	connect_args.to_sel.u_sel.name = chan_resacb;
	connect_args.to_idx = 0;
	connect_args.fr_objid = resb_objid[1];
	connect_args.fr_os = OM_Gw_current_OS;
	connect_args.fr_sel.type = OM_e_name;
	connect_args.fr_sel.u_sel.name = chan_resbca;
	connect_args.fr_idx            = 0;

for (i=0; i<half_A; i++)
 {
	sts = om$send (msg = &connect_msg,			
		       senderid = resb_objid[1],			
		       targetid = resa_objid[i] );
 
  if (!(sts&1))
   {
    printf ("error in om$send msg=connect ResA[%d]: %x \n", i, sts );
    om$report_error(sts=sts);
    printf("iteration: %d\n", i);
    exit();
   }
 }

/*
	For each ResB dump relations
*/

printf("\n\n>>> For each ResB dump relations::\n");
for(i=0; i<MAXB+1; i++)
 {
  printf("\n>>> ResB[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, resb_objid[i], chan_resbca);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for ResB[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }

/*
	Make message to send to ResB objects
*/

sts = om$make_message(classname="ResB",methodname="show_b",p_msg=&showb);

if(!(sts&1))
 {
  printf("error in om$make_message for show_b: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Send message to all ResB objects connected on ResA[0]'s "acb" channel
*/

printf("\n>>> Send message to all ResB's connected on ResA[0]'s \"acb\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "ResA.acb";
sts = om$send (msg=&showb,mode=OM_e_wrt_object,senderid=resa_objid[0],
					p_chanselect=&chansel );
if(!(sts&1))
 {
  printf("error in om$send msg=show_b ResA[0]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Send message to all ResB objects connected on ResA[1]'s "acb" channel
*/

printf("\n>>> Send message to all ResB's connected on ResA[1]'s \"acb\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "ResA.acb";
sts = om$send (msg=&showb,mode=OM_e_wrt_object,senderid=resa_objid[1],
					p_chanselect=&chansel );

if(!(sts&1))
 {
  printf("error in om$send msg= show_b ResA[1]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	For each ResA dump relations
*/

printf("\n>>> For each ResA dump relations\n");
for(i=0; i<MAXA+1; i++)
 {
  printf("\n>>> ResA[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, resa_objid[i], chan_resacb);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for ResA[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }

/*
	Make message to send to ResA objects
*/

sts = om$make_message(classname="ResA",methodname="show_a",p_msg=&showa);

if(!(sts&1))
 {
  printf("error in om$make_message for show_a: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Send message to all ResA objects connected on ResB[0]'s "bca" channel
*/

printf("\n>>> Send message to all ResA's connected on ResB[0]'s \"bca\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "ResB.bca";
sts = om$send (msg=&showa,mode=OM_e_wrt_object,senderid=resb_objid[0],
					p_chanselect=&chansel );

if(!(sts&1))
 {
  printf("error in om$send msg= show_a ResB[0]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Send message to all ResA objects connected on ResB[1]'s "bca" channel
*/

printf("\n>>> Send message to all ResA's connected on ResB[1]'s \"bca\" chan\n");
chansel.type = OM_e_name;
chansel.u_sel.name = "ResB.bca";
sts = om$send (msg=&showa,mode=OM_e_wrt_object,senderid=resb_objid[1],
					p_chanselect=&chansel );

if(!(sts&1))
 {
  printf("error in om$send msg= show_a ResB[1]: %x\n",  sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Disconnect the first ResA contained wihtin the last half of ResA's
	from it's associated ResB.

  note:	Remember that the last half of the ResA's were connected to
ResB[0] (see above).
*/

printf("\n>>> Disconnect the 1st in the 2nd half of ResA from corresponding ResB\n");

     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_resacb;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = 0;

     sts = om$make_message(classname = "Root",		
		           methodname = "range_disconnect",		
			   size = sizeof( struct range_disconnect_struct),
			   p_arglist = &range_disconnect_args,	
			   p_msg = &range_disconnect_msg );
     
     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = resa_objid[half_A],			
	            targetid = resa_objid[half_A]);

if (!(sts&1))
 {
  printf ("error in om$send msg=disconnect ResA[half_A] case: %x \n",
sts );
  om$report_error(sts=sts);
  exit();
 }

/*
	Dump relations of the channel "acb" of ResA[half_A]
*/

printf("\n>>> Dump relations of the channel \"acb\" of ResA[half_A]\n");
printf("\n>>> ResA[%d]:",half_A);
sts = OMT_dump_relation( OM_Gw_current_OS, resa_objid[half_A], chan_resacb);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for ResA[half_A]: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Dump relations of the channel "bca" for ResB[0]
*/

printf("\n>>> Dump relations of the channel \"bca\" of ResB[0] (ResA[MAXA/2])\n");
printf("\n>>>>>> note: \"ResA[half_A]\" was connected to ResB[0]");
printf("\n>>> ResB[0]:");
sts = OMT_dump_relation( OM_Gw_current_OS, resb_objid[0], chan_resbca);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for ResB[0] ( ResA[MAXA/2] case ): %x\n",i,sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Disconnect 1st half of objects connected to ResB[1]
*/

printf("\n>>> Disconnect 1st half of objects connected to ResB[1]\n");

     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_resbca;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = half_A/2;

     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = resb_objid[1],			
	            targetid = resb_objid[1] );

if (!(sts&1))
 {
  printf ("error in om$disconnect range ResB[1] case: %x \n", sts );
  om$report_error(sts=sts);
  exit();
 }

/*
	Dump relations of the channel "bca" of ResB[1]
*/

printf("\n>>> Dump relations on the channel \"bca\" of ResB[1]\n");
sts = OMT_dump_relation( OM_Gw_current_OS, resb_objid[1], chan_resbca);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for ResB[1]: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations on channel "acb" of all ResA's
*/
printf("\n>>> Dump relations on channel \"acb\" of all A's\n");
for(i=0; i<MAXA+1; i++)
 {
  printf("\n>>> ResA[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, resa_objid[i], chan_resacb);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for ResA[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }

/*
	Disconnect All objects connected to ResA[0] on channel "acb"

  note: the last index of the relation is used if it is exceeded by the
	given "end" index

*/
printf("\n>>> Disconnect All objects connected to ResA[0] on channel \"acb\"\n");

     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_resacb;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = MAXB+99;

     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = resa_objid[0],			
	            targetid = resa_objid[0] );

if (!(sts&1))
 {
  printf ("error in om$disconnect range ResA[0] case: %x \n", sts );
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "acb" of A[0]
*/
printf("\n>>> Dump relations of the channel \"acb\" of ResA[0]\n");
sts = OMT_dump_relation( OM_Gw_current_OS, resa_objid[0], chan_resacb);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for ResA[0]: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "bca" for all ResB's
*/
printf("\n>>> Dump relations of the channel \"bca\" for all ResB's\n");
for(i=0; i<MAXB+1; i++)
 {
  printf("\n>>> ResB[%d]:",i);
  sts = OMT_dump_relation( OM_Gw_current_OS, resb_objid[i], chan_resbca);
  if(!(sts&1))
   {
    printf("error in OMT_dump_relation for ResB[%d]: %x\n", i, sts);
    om$report_error(sts=sts);
    exit();
   }
 }

/*
	Disconnect LAST A from LAST ResB
*/
printf("\n>>> Disconnect LAST ResA from LAST ResB \"acb\"\n");
     range_disconnect_args.to_sel.type = OM_e_name;
     range_disconnect_args.to_sel.u_sel.name = chan_resacb;
     range_disconnect_args.low_index = 0;
     range_disconnect_args.hi_index = MAXA;
     
     sts = om$send (msg = &range_disconnect_msg,			
		    senderid = resa_objid[MAXA],			
	            targetid = resa_objid[MAXA] );

if (!(sts&1))
 {
  printf ("error in om$disconnect range LAST ResA & ResB case: %x \n", sts
);
  om$report_error(sts=sts);
  exit();
 }
/*
	Dump relations of the channel "acb" of ResA[MAXA]
*/
printf("\n>>> Dump relations of the channel \"acb\" of LAST ResA\n");
printf("\n>>> ResA[%d]:",MAXA);
sts = OMT_dump_relation( OM_Gw_current_OS, resa_objid[MAXA], chan_resacb);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for LAST ResA: %x\n", sts);
  om$report_error(sts=sts);
  exit();
 }

/*
	Dump relations of the channel "bca" for ResB[MAXB]
*/

printf("\n>>> Dump relations of the channel \"bca\" of LAST ResB\n");
printf("\n>>> ResB[%d]:",MAXB);
sts = OMT_dump_relation( OM_Gw_current_OS, resb_objid[MAXB], chan_resbca);
if(!(sts&1))
 {
  printf("error in OMT_dump_relation for LAST ResB: %x\n", i, sts);
  om$report_error(sts=sts);
  exit();
 }

}
