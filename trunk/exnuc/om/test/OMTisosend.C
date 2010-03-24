#include "OMobjectcomm.h"
#include "OMintprims.h"

#define MAXTRANS	3
#define MAXOBJT		5

#define OS1		0
#define OS2		1
#define OS3		2

#define CONSTRUCT(OSNUM,OBJ,TYPE,STRING )				\
sts = om$construct(osname = trans_osname[OSNUM].s_name, 		\
                   classname = TYPE,					\
                   p_objid = &trans_objids[OSNUM][OBJ],			\
                   neighbor = OM_GS_NULL_NEIGHBOR);  			\
if (!(sts&1))								\
   {									\
   printf("Error om$construct for %s\n",STRING); 	\
   om$report_error(sts = sts);						\
   exit();								\
   }									\
printf(" >>>> %s :: %d\n",STRING,trans_objids[OSNUM][OBJ] );

#define CONNECT( OS1, OBJ1, CHAN1, OS2, OBJ2, CHAN2 )			\
printf(">>> Connecting  OBJID %d of OS %d (OSID %d)\n",			\
	trans_objids[OS1][OBJ1] , OS1, trans_osnum[OS1]);		\
printf(">>>         To  OBJID %d of OS %d (OSID %d)\n",			\
	trans_objids[OS2][OBJ2] , OS2, trans_osnum[OS2]);		\
	connect_args.to_sel.type = OM_e_name;				\
	connect_args.to_sel.u_sel.name = CHAN2;				\
	connect_args.to_idx = 0;					\
	connect_args.fr_objid = trans_objids[OS1][OBJ1];		\
	connect_args.fr_os = trans_osnum[OS1];				\
	connect_args.fr_sel.type = OM_e_name;				\
	connect_args.fr_sel.u_sel.name = CHAN1;				\
	connect_args.fr_idx            = 0;				\
	sts = om$send (msg = &connect_msg,				\
		       senderid = trans_objids[OS1][OBJ1],		\
		       targetid = trans_objids[OS2][OBJ2],		\
		       targetos = trans_osnum[OS2]);			\
 if (!(sts&1))								\
 {									\
   printf("Error in om$send msg =connect\n" );				\
   om$report_error(sts = sts);						\
   exit();								\
 }		

main()
{

OM_S_OBJID                  transobj[MAXTRANS],trans_objids[MAXTRANS][MAXOBJT];
OM_S_MESSAGE                connect_msg, show_a, show_b, deltrans;
OM_S_CHANSELECT             chansel;
OMuword                     trans_osnum[MAXTRANS];

struct trans_osname_type
        {
        char s_name[15];
	} trans_osname[MAXTRANS];

struct connect_struct
       {
	 OM_S_CHANSELECT      to_sel;
	 int		      to_idx;
	 OM_S_OBJID	      fr_objid;
	 OMuword              fr_os;
	 OM_S_CHANSELECT      fr_sel;
	 int		      fr_idx;
       } connect_args;


int    sts,i,j,num;

printf ("\nInitializing . . .\n");

sts = om$runtime_init();
if (!(sts&1))
	{
	printf( "Error in om$runtime_init\n");
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
   printf( "Error in om$make_message\n");
   om$report_error(sts = sts);
   exit();
   }

sts = om$make_message(classname = "A",
                      methodname = "show_a",
                      p_msg = &show_a );
if (!(sts&1))
   {
   printf( "Error in om$make_message\n");
   om$report_error(sts = sts);
   exit();
   }

sts = om$make_message(classname = "B",
                      methodname = "show_b",
                      p_msg = &show_b );
if (!(sts&1))
   {
   printf( "Error in om$make_message\n");
   om$report_error(sts = sts);
   exit();
   }

sts = om$make_message(classname = "OMTransOS",
                      methodname = "delete",
                      p_msg = &deltrans );
if (!(sts&1))
   {
   printf( "Error in om$make_message\n");
   om$report_error(sts = sts);
   exit();
   }


printf("\n\n*** Creating TransOSs ***\n\n");

for ( i=0; i<MAXTRANS; i++ )
   {
   sprintf( trans_osname[i].s_name, "TransOS%d", i);
   sts = om$construct_os(classname= "OMTransOS", 		
			 osnum =&trans_osnum[i],		
			 osname =trans_osname[i].s_name,		
			 p_objid =&transobj[i]);
      if (!(sts&1))
	{
	printf("Error in om$construct_os\n");
	om$report_error(sts = sts);
	exit();
	}

   printf("\nOS%d :: %s :: %d", i+1, trans_osname[i].s_name, trans_osnum[i]);
   }

/*
                       A2 ___                ___ B2
 (OBJECT SPACE 1)	     \		    /         A1 _
   			      ISO1======ISO2              \
	      A1  ------------ISO1======ISO2--------------(REL) B1
                 A3 _________/                        __ / /
                    A4 _____/                   A2 __/   _/
                       A5 _/                         ___/
						   _/      (OBJECT SPACE 2)
                                                 _/
 (OBJECT SPACE 3)      A2____		       _/
		             \		    __/
	      A1 (REL)--------ISO4======ISO3
                  \__
                     \
		      (REL) B1
                A3 __/

*/

printf("\n\n*** Creating Objects ***\n\n");

printf("\n                       A2 ___                ___ B2 ");
printf("\n (OBJECT SPACE 1)	     \\		    /         A1 _ ");
printf("\n   			      ISO1======ISO2              \\ ");
printf("\n	      A1  ------------ISO1======ISO2--------------(REL) B1 ");
printf("\n                 A3 _________/                        __ / / ");
printf("\n                    A4 _____/                   A2 __/   _/ ");
printf("\n                       A5 _/                         ___/ ");
printf("\n						   _/       (OBJECT SPACE 2) ");
printf("\n                                                 _/ ");
printf("\n (OBJECT SPACE 3)      A2____		       _/ ");
printf("\n		             \\		    __/ ");
printf("\n	      A1 (REL)--------ISO4======ISO3 ");
printf("\n                  \\__ ");
printf("\n                     \\ ");
printf("\n		      (REL) B1 ");
printf("\n                A3 __/ \n\n");

CONSTRUCT(OS1,0,"A","OS1..A1");		/* Construct A1 in OS1 */
CONSTRUCT(OS1,1,"A","OS1..A2");		/* Construct A2 in OS1 */
CONSTRUCT(OS1,2,"A","OS1..A3");		/* Construct A3 in OS1 */
CONSTRUCT(OS1,3,"A","OS1..A4");		/* Construct A4 in OS1 */
CONSTRUCT(OS1,4,"A","OS1..A5");		/* Construct A5 in OS1 */

CONSTRUCT(OS2,0,"B","OS2..B1");		/* Construct B1 in OS2 */
CONSTRUCT(OS2,1,"A","OS2..A1");		/* Construct A1 in OS2 */
CONSTRUCT(OS2,2,"B","OS2..B2");		/* Construct B2 in OS2 */
CONSTRUCT(OS2,3,"A","OS2..A2");		/* Construct A2 in OS2 */

CONSTRUCT(OS3,0,"A","OS3..A1");		/* Construct A1 in OS3 */
CONSTRUCT(OS3,1,"B","OS3..B1");		/* Construct B1 in OS3 */
CONSTRUCT(OS3,2,"A","OS3..A2");		/* Construct A2 in OS3 */
CONSTRUCT(OS3,3,"A","OS3..A3");		/* Construct A3 in OS3 */

/*
   Note:: In order to test the sorting algorithm used in sibling send
	  the connections are performed unordered with respect to 
	  OS/OBJID pairs
*/

printf("\n\n*** Connecting Objects ***\n\n");

CONNECT(OS2,1,"acb",OS2,0,"bca");	/* connect A1 in OS2 to B1 in OS2 */

printf(">>> connected A1 in OS2 to B1 in OS2 \n\n");

CONNECT(OS1,4,"acb",OS2,0,"bca");	/* connect A5 in OS1 to B1 in OS2 */

printf(">>> connected A5 in OS1 to B1 in OS2 \n\n");

CONNECT(OS1,2,"acb",OS2,0,"bca");	/* connect A3 in OS1 to B1 in OS2 */

printf(">>> connected A3 in OS1 to B1 in OS2 \n\n");

CONNECT(OS1,3,"acb",OS2,0,"bca");	/* connect A4 in OS1 to B1 in OS2 */

printf(">>> connected A4 in OS1 to B1 in OS2 \n\n");

CONNECT(OS1,0,"acb",OS2,0,"bca");	/* connect A1 in OS1 to B1 in OS2*/

printf(">>> connected A1 in OS1 to B1 in OS2 \n\n");

CONNECT(OS3,2,"acb",OS2,0,"bca");	/* connect A2 in OS3 to B1 in OS2*/

printf(">>> connected A2 in OS3 to B1 in OS2 \n\n");

CONNECT(OS3,0,"acb",OS2,0,"bca");	/* connect A1 in OS3 to B1 in OS2*/

printf(">>> connected A1 in OS3 to B1 in OS2 \n\n");

CONNECT(OS3,0,"acb",OS3,1,"bca");	/* connect A1 in OS3 to B1 in OS3*/

printf(">>> connected A1 in OS3 to B1 in OS3 \n\n");

CONNECT(OS1,1,"acb",OS2,2,"bca");	/* connect A2 in OS1 to B2 in OS2*/

printf(">>> connected A2 in OS1 to B2 in OS2 \n\n");

CONNECT(OS2,3,"acb",OS2,0,"bca");	/* connect A2 in OS2 to B1 in OS2*/

printf(">>> connected A2 in OS2 to B1 in OS2 \n");

CONNECT(OS3,3,"acb",OS3,1,"bca");	/* connect A3 in OS3 to B1 in OS3*/

printf(">>> connected A3 in OS3 to B1 in OS3 \n");

/*=================*/
/*  change to OS2  */
/*=================*/

om$make_current_os ( osnum = trans_osnum[OS2] );

printf("\n\n*** Dump Relation of B1 in OS2 ***\n\n");

sts = OMT_dump_relation( trans_osnum[OS2], trans_objids[OS2][0], "bca" );
if(!(sts&1))
  {
   printf("error in OMT_dump_relation for B1 in OS2\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Send by Channel from B1 in OS2 ***\n\n");

chansel.type = OM_e_name;
chansel.u_sel.name = "bca";

sts = om$send ( msg = &show_a,
                senderid = trans_objids[OS2][0],
                p_chanselect = &chansel );
if(!(1&sts))
  {
   printf("error in om$send (show_a) out bca for B1 in OS2\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Sibling Send from A1 in OS2 (inclusive) ***\n\n");

chansel.type = OM_e_name;
chansel.u_sel.name = "acb";

sts = om$sibling_send ( msg = &show_a,
                        senderid = trans_objids[OS2][1],
                        p_chanselect = &chansel,
                        inclusive = OM_e_inclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_a) out acb for A1 in OS2\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Sibling Send from A1 in OS2 (exclusive) ***\n\n");

sts = om$sibling_send ( msg = &show_a,
                        senderid = trans_objids[OS2][1],
                        p_chanselect = &chansel,
                        inclusive = OM_e_exclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_a) out acb for A1 in OS2\n");
   om$report_error(sts = sts);
   exit();
  }

/*=================*/
/*  change to OS1  */
/*=================*/

om$make_current_os ( osnum = trans_osnum[OS1] );

printf("\n\n*** Sibling Send from A1 in OS1 (inclusive) ***\n\n");

chansel.type = OM_e_name;
chansel.u_sel.name = "acb";

sts = om$sibling_send ( msg = &show_a,
                        senderid = trans_objids[OS1][0],
                        p_chanselect = &chansel,
                        inclusive = OM_e_inclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_a) out acb for A1 in OS1\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Sibling Send from A1 in OS1 (exclusive) ***\n\n");

sts = om$sibling_send ( msg = &show_a,
                        senderid = trans_objids[OS1][0],
                        p_chanselect = &chansel,
                        inclusive = OM_e_exclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_a) out acb for A1 in OS2\n");
   om$report_error(sts = sts);
   exit();
  }


printf("\n\n*** Send by Channel from A2 in OS1 ***\n\n");

chansel.type = OM_e_name;
chansel.u_sel.name = "acb";

sts = om$send ( msg = &show_b,
                senderid = trans_objids[OS1][1],
                p_chanselect = &chansel );
if(!(sts&1))
  {
   printf("error in om$send (show_b) out acb from A2 in OS1\n");
   om$report_error(sts = sts);
   exit();
  }

/*=================*/
/*  change to OS3  */
/*=================*/

om$make_current_os ( osnum = trans_osnum[OS3] );

printf("\n\n*** Dump Relation of A1 in OS3 ***\n\n");

sts = OMT_dump_relation( trans_osnum[OS3], trans_objids[OS3][0], "acb" );
if(!(sts&1))
  {
   printf("error in OMT_dump_relation for A1 in OS3\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Sibling Send from A1 in OS3 (inclusive) ***\n\n");

chansel.type = OM_e_name;
chansel.u_sel.name = "acb";

sts = om$sibling_send ( msg = &show_a,
                        senderid = trans_objids[OS3][0],
                        p_chanselect = &chansel,
                        inclusive = OM_e_inclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_a) out acb for A1 in OS3\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Sibling Send from A1 in OS3 (exclusive) ***\n\n");

sts = om$sibling_send ( msg = &show_a,
                        senderid = trans_objids[OS3][0],
                        p_chanselect = &chansel,
                        inclusive = OM_e_exclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_a) out acb for A1 in OS3\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Dump Relation of B1 in OS3 ***\n\n");

sts = OMT_dump_relation( trans_osnum[OS3], trans_objids[OS3][1], "bca" );
if(!(sts&1))
  {
   printf("error in OMT_dump_relation for B1 in OS3\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Sibling Send from B1 in OS3 (inclusive) ***\n\n");

chansel.type = OM_e_name;
chansel.u_sel.name = "bca";

sts = om$sibling_send ( msg = &show_b,
                        senderid = trans_objids[OS3][1],
                        p_chanselect = &chansel,
                        inclusive = OM_e_inclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_b) out bca for B1 in OS3\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Sibling Send from B1 in OS3 (exclusive) ***\n\n");

sts = om$sibling_send ( msg = &show_b,
                        senderid = trans_objids[OS3][1],
                        p_chanselect = &chansel,
                        inclusive = OM_e_exclusive );
if(!(1&sts))
  {
   printf("error in om$sibling_send (show_b) out bca for B1 in OS3\n");
   om$report_error(sts = sts);
   exit();
  }

printf("\n\n*** Send by Channel from B1 in OS3 ***\n\n");

chansel.type = OM_e_name;
chansel.u_sel.name = "bca";

sts = om$send ( msg = &show_a,
                senderid = trans_objids[OS3][1],
                p_chanselect = &chansel );
if(!(1&sts))
  {
   printf("error in om$send (show_a) out bca for B1 in OS3\n");
   om$report_error(sts = sts);
   exit();
  }

/*============================*/
/*  Delete the Object Spaces  */
/*============================*/

printf("\n\n*** Deleting OSs ***\n\n");

for ( i=0; i<MAXTRANS; i++ )
   {
   
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &deltrans,
                 senderid = transobj[i],
                 targetid = transobj[i],
                 targetos = trans_osnum[i] );
   if (!(sts&1))
   	{
   	printf( "Error in OM_send_foreign\n");
   	om$report_error(sts = sts);
   	exit();
   	}

   }
}
