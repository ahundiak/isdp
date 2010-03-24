#include "OMprimitives.h"

#define	MAXA	10
#define MAXB	10

	
/*---------------------------------------------------------------------*/

#define DEBUG_PRINT_LIST(list, count)			\
	{						\
	int i;						\
							\
	printf("\n****** CONTENTS OF LIST ***********\n");	\
	for (i=0;i<count;i++)				\
	   {						\
	   printf("list[%d].S_objid = %d\n",i,list[i].S_objid);	\
	   }						\
	printf("*************************************\n");	\
	}						\

#define RAND_INT( L, U )				\
	(int)( L + (U-L)*drand48() )


#define SWAP( A, B, OPTYPE )				\
	{						\
	OPTYPE temp;					\
	temp = A;					\
	A = B;						\
	B = temp;					\
	}

static void OMT_qsort_objlnks( lower, upper, list)

	int			lower;	/* Lower bound of partition */
	int			upper;	/* Upper bound of partition */
	OM_p_OBJECT_LINKAGE	list;   /* List to be sorted	    */

{
register int i, lastlow;
double 	drand48();
OM_S_OBJECT_LINKAGE t;


if ( upper > lower )
    {
    i=RAND_INT( lower,  upper );
    SWAP( list[lower], list[i], OM_S_OBJECT_LINKAGE );
    t = list[lower];
    lastlow = lower;
    for ( i=lower+1; i<=upper; i++)
	{
	if ( list[i].S_objid <  t.S_objid ) 
	    { 
	    lastlow++;
	    SWAP( list[lastlow], list[i], OM_S_OBJECT_LINKAGE );
	    }
	}
    SWAP( list[lower], list[lastlow], OM_S_OBJECT_LINKAGE );
    OMT_qsort_objlnks( lower,  lastlow-1, list );
    OMT_qsort_objlnks( lastlow+1, upper, list );
    }
}

/*---------------------------------------------------------------------------*/


main ()

{						/* main */

int		sts, i;
OM_S_OBJID	a_objid[MAXA], b_objid[MAXB];
OM_S_OBJECT_LINKAGE	list[MAXA];
OM_S_MESSAGE    connect_msg, set_operation_msg;
char            chan_acb[10], chan_bca[10];
OM_S_CHANSELECT chansel;
int		size=10;
OMuint          count;

struct connect_struct
	{
	OM_S_CHANSELECT	to_sel;
	int		to_idx;
	OM_S_OBJID	fr_objid;
	uword		fr_os;
	OM_S_CHANSELECT fr_sel;
	int		fr_idx;
	} connect_args;
	
struct set_operation_struct
	{
	OM_S_CHANSELECT	to_sel;
	OM_S_OBJID	op2_objid;
	OMuword		op2_os;
	OM_S_CHANSELECT	op2_sel;
	OM_S_OBJID	op3_objid;
	OMuword		op3_os;
	OM_S_CHANSELECT	op3_sel;
	char 		operation;
	OMuword		preserve;
	} set_operation_args;
	

sts=om$runtime_init();
if (!(sts&1))
{
    printf ("error in OM_runtime_init: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

#ifdef DEBUG
printf("\n*** RUNTIME_INIT COMPLETE ***\n");
#endif

strcpy(chan_acb, "testa.acb");

strcpy(chan_bca, "testb.bca");

for(i=0; i<MAXA; i++)

{

    sts=om$construct(classname="testa", osnum=OM_Gw_current_OS,
			p_objid=&a_objid[i]
			);
			
    if (!(sts&1))
    {
        printf ("error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

#ifdef DEBUG
printf("\n*** Constructed %d class A objects ***\n", MAXA);
#endif

for(i=0; i<MAXB; i++)
{

    sts=om$construct(classname="testb", osnum=OM_Gw_current_OS,
			p_objid=&b_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

#ifdef DEBUG
printf("\n*** Constructed %d class B objects ***\n", MAXB);
#endif


/*	Connect A0 to B0-B2	*/

    connect_args.to_sel.type = OM_e_name;
    connect_args.to_sel.u_sel.name = chan_bca;
    connect_args.to_idx = 0;
    connect_args.fr_objid = a_objid[0];
    connect_args.fr_os = OM_Gw_current_OS;
    connect_args.fr_sel.type = OM_e_name;
    connect_args.fr_sel.u_sel.name = chan_acb;
    connect_args.fr_idx = 0;

    sts=om$make_message(classname="Root", 
			methodname="connect", 
			size=sizeof(struct connect_struct), 
			p_arglist=&connect_args, 
			p_msg=&connect_msg
			);
    if (!(sts&1))
    {
	   printf ("\nerror in om$make_message for connect: %x\n", sts);
	   om$report_error(sts=sts);
	   exit();
    }

for(i=0; i<3; i++)
{
			
    sts=om$send(msg=&connect_msg, 
		senderid=a_objid[0], 
		targetid=b_objid[i]
		);
		
/*    sts = OM_connect_by_name ( "OM_TransOS_0", a_objid[0], "acb", minorchan, 
		relindex, "OM_TransOS_0", b_objid[i], "bca", minorchan, 
		relindex);
*/
    if (!(sts&1))
    {
        printf ("\nerror in send to connect: %x \n", sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }
}

chansel.type = OM_e_name;
chansel.u_sel.name = chan_acb;

#ifdef DEBUG
printf("\n*** Connected A0 to B0-B2 ***\n");
printf("*** Dump A0 after connect *****\n");
#endif

sts=om$get_channel_objects(osnum=OM_Gw_current_OS,
				objid=a_objid[0],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif


/*	Connect A1 to B3-B4	*/

connect_args.to_sel.type = OM_e_name;
connect_args.to_sel.u_sel.name = chan_bca;
connect_args.to_idx = 0;
connect_args.fr_objid = a_objid[1];
connect_args.fr_os = OM_Gw_current_OS;
connect_args.fr_sel.type = OM_e_name;
connect_args.fr_sel.u_sel.name = chan_acb;
connect_args.fr_idx = 0;

for(i=3; i<5; i++)
{

    sts=om$send(msg=&connect_msg, 
		senderid=a_objid[1], 
		targetid=b_objid[i]
		);
		
/*  sts = OM_connect_by_name ( "OM_TransOS_0", a_objid[1], "acb", minorchan, 
		relindex, "OM_TransOS_0", b_objid[i], "bca", minorchan, 
		relindex);
*/

    if (!(sts&1))
    {
        printf ("\nerror in send to connect: %x \n", sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }
}

#ifdef DEBUG
printf("\n*** Connected A1 to B3-B4 ***\n");
printf("*** Dump A1 after connect *****\n");
#endif

sts=om$get_channel_objects(objid=a_objid[1],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

/*****************************************************************************/
/* No-op Union: A0 = A0 + A0  :  Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** No-op Union: A0 = A0 + A0  :  Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[0];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[0];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'u';
set_operation_args.preserve = 0;

sts=om$make_message(classname="Root", 
			methodname="set_operation", 
			size=sizeof(struct set_operation_struct), 
			p_arglist=&set_operation_args, 
			p_msg=&set_operation_msg
			);
			
if (!(sts&1))
{
   printf ("\nerror in om$make_message for set_operation: %x\n", sts);
   om$report_error(sts=sts);
   exit();
}

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[0], 
		targetid=a_objid[0]
		);
		
/*sts = OM_set_operations_by_name('u', 0, a_objid[0], "acb", a_objid[0], "acb", 
				a_objid[0], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Union no-op case: %x\n",sts);
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[0],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	count != 3			 )
	{
	printf("*** error in A0=A0+A0, p=0 ***\n");
	exit();
	}


/*****************************************************************************/

/* Subtractor = Subtrahend Union: A6 = A1 + A1  :  Preserve Set */

#ifdef DEBUG
printf("\n*** Subtractor = Subtrahend Union: A6 = A1 + A1  :  Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[1];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[1];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'u';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[1], 
		targetid=a_objid[6]
		);

/*sts = OM_set_operations_by_name('u', 1, a_objid[1], "acb", a_objid[1], "acb", 
				a_objid[6], "acb");
*/
if (!(sts&1))
{
    printf ("\nerror in send to set_operations Union case 2: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[6],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif


if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2		 	 )
	{
	printf("*** error in A6=A1+A1, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Subtractor = Subtrahend Union: A2 = A1 + A1  :  Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Subtractor = Subtrahend Union: A2 = A1 + A1  :  Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[1];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[1];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'u';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[1], 
		targetid=a_objid[2]
		);

/*sts = OM_set_operations_by_name('u', 0, a_objid[1], "acb", a_objid[1], "acb", 
				a_objid[2], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Union case 2: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[2],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A2=A1+A1, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[1],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A2=A1+A1, p=0, cnta1!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 3 Union: A0 = A2 + A0  -  Preserve Sets */

#ifdef DEBUG
printf("\n*** Case 3 Union: A0 = A2 + A0  -  Preserve Sets ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[2];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[0];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'u';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[2], 
		targetid=a_objid[0]
		);

/*sts = OM_set_operations_by_name('u', 1, a_objid[2], "acb", a_objid[0], "acb", 
				a_objid[0], "acb");
*/
if (!(sts&1))
{
    printf ("\nerror in send to set_operation Union 3rd case: %x \n", sts);
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[0],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	list[3].S_objid != b_objid[3]	||
	list[4].S_objid != b_objid[4]	||
	count != 5			 )
	{
	printf("*** error in A0=A2+A0, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 3 Union: A0 = A2 + A0  -  Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Case 3 Union: A0 = A2 + A0  -  Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[2];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[0];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'u';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[2], 
		targetid=a_objid[0]
		);

/*sts = OM_set_operations_by_name('u', 0, a_objid[2], "acb", a_objid[0], "acb", 
				a_objid[0], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Union 3rd case: %x \n", sts);
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[0],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	list[3].S_objid != b_objid[3]	||
	list[4].S_objid != b_objid[4]	||
	count != 5			 )
	{
	printf("*** error in A0=A2+A0, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[2],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A0=A2+A0, p=0, cnta2!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/*	Connect A3 to B3 	*/

#ifdef DEBUG
printf("\n*** Connecting A3 to B3 ***\n");
#endif

connect_args.to_sel.type = OM_e_name;
connect_args.to_sel.u_sel.name = chan_bca;
connect_args.to_idx = 0;
connect_args.fr_objid = a_objid[3];
connect_args.fr_os = OM_Gw_current_OS;
connect_args.fr_sel.type = OM_e_name;
connect_args.fr_sel.u_sel.name = chan_acb;
connect_args.fr_idx = 0;

sts=om$send(msg=&connect_msg, 
		senderid=a_objid[3], 
		targetid=b_objid[3]
		);
		
/*sts = OM_connect_by_name ( "OM_TransOS_0", a_objid[3], "acb", minorchan, 
   		relindex, "OM_TransOS_0", b_objid[3], "bca", minorchan, 
		relindex);
*/

if (!(sts&1))
{
    printf ("error in send to connect : %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

/*****************************************************************************/

/* Case 3 Difference: A2 = A0 - A3  :  Preserve Sets */

#ifdef DEBUG
printf("\n*** Case 3 Difference: A2 = A0 - A3  :  Preserve Sets ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[0];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[3];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'd';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[0], 
		targetid=a_objid[2]
		);

/*sts = OM_set_operations_by_name('d', 1, a_objid[0], "acb", a_objid[3], "acb", 
				a_objid[2], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Difference 3rd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[2],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	list[3].S_objid != b_objid[4]	||
	count != 4			 )
	{
	printf("*** error in A2=A0-A3, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 3 Difference: A2 = A0 - A3  :  Do Not Preserve Sets */

#ifdef DEBUG
printf("\n*** Case 3 Difference: A2 = A0 - A3  :  Do Not Preserve Sets ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[0];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[3];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'd';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[0], 
		targetid=a_objid[2]
		);

/*sts = OM_set_operations_by_name('d', 0, a_objid[0], "acb", a_objid[3], "acb", 
				a_objid[2], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Difference 3rd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[2],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	list[3].S_objid != b_objid[4]	||
	count != 4			 )
	{
	printf("*** error in A2=A0-A3, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[0],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A2=A0+A3, p=0, cnta0!=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[3],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A2=A0+A3, p=0, cnta3!=0 ***\n");
	exit();
	}


/*****************************************************************************/

/* Case 4 Union: A4 = A6 + A2   :   Preserve Sets */

#ifdef DEBUG
printf("\n*** Case 4 Union: A4 = A6 + A2   :   Preserve Sets ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[6];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[2];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'U';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[6], 
		targetid=a_objid[4]
		);

/*sts = OM_set_operations_by_name('U', 1, a_objid[6], "acb", a_objid[2], "acb", 
				a_objid[4], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Union 4th case: %x \n", sts);
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[4],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	list[3].S_objid != b_objid[3]	||
	list[4].S_objid != b_objid[4]	||
	count != 5			 )
	{
	printf("*** error in A4=A6+A2, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 4 Union: A4 = A6 + A2   :   Do Not Preserve Sets */

#ifdef DEBUG
printf("\n*** Case 4 Union: A4 = A6 + A2   :   Do Not Preserve Sets ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[6];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[2];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'U';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[6], 
		targetid=a_objid[4]
		);

/*sts = OM_set_operations_by_number('U', 0, a_objid[6], chan_a, a_objid[2], 
                                  chan_a, a_objid[4], chan_a);
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Union 4th case: %x \n",sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[4],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	list[3].S_objid != b_objid[3]	||
	list[4].S_objid != b_objid[4]	||
	count != 5			 )
	{
	printf("*** error in A4=A6+A2, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[6],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A4=A6+A2, p=0, cnta6!=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[2],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A4=A6+A2, p=0, cnta2!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 2 Difference: A0 = A4 - A0  :  Preserve Set */

#ifdef DEBUG
printf("\n*** Case 2 Difference: A0 = A4 - A0  :  Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[4];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[0];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'D';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[4], 
		targetid=a_objid[0]
		);

/*sts = OM_set_operations_by_name('D', 1, a_objid[4], "acb", a_objid[0], "acb", 
				a_objid[0], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Difference 2nd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[0],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[0]	||
	list[1].S_objid != b_objid[1]	||
	list[2].S_objid != b_objid[2]	||
	list[3].S_objid != b_objid[3]	||
	list[4].S_objid != b_objid[4]  	||
	count != 5			 )
	{
	printf("*** error in A0=A4-A0, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/*	Connect A5 to B0-B2	*/

#ifdef DEBUG
printf("\n*** Connecting A5 to B0-B2 ***\n");
#endif

connect_args.to_sel.type = OM_e_name;
connect_args.to_sel.u_sel.name = chan_bca;
connect_args.to_idx = 0;
connect_args.fr_objid = a_objid[5];
connect_args.fr_os = OM_Gw_current_OS;
connect_args.fr_sel.type = OM_e_name;
connect_args.fr_sel.u_sel.name = chan_acb;
connect_args.fr_idx = 0;

for(i=0; i<3; i++)
{

    sts=om$send(msg=&connect_msg, 
		senderid=a_objid[5], 
		targetid=b_objid[i]
		);
		
/*  sts = OM_connect_by_name ( "OM_TransOS_0", a_objid[5], "acb", minorchan, 
		relindex, "OM_TransOS_0", b_objid[i], "bca", minorchan, 
		relindex);
*/

    if (!(sts&1))
    {
        printf ("\nerror in send to connect: %x \n", sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }
}

/*****************************************************************************/

/* Case 2 Difference: A4 = A4 - A5  :  Preserve Set */

#ifdef DEBUG
printf("\n*** Case 2 Difference: A4 = A4 - A5  :  Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[4];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[5];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'D';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[4], 
		targetid=a_objid[4]
		);

/*sts = OM_set_operations_by_name('D', 1, a_objid[4], "acb", a_objid[5], "acb", 
				a_objid[4], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Difference 2nd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[4],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A4=A4-A5, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 2 Difference: A4 = A4 - A5  :  Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Case 2 Difference: A4 = A4 - A5  :  Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[4];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[5];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'D';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[4], 
		targetid=a_objid[4]
		);

/*sts = OM_set_operations_by_name('D', 0, a_objid[4], "acb", a_objid[5], "acb", 
				a_objid[4], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Difference 2nd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[4],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A4=A4-A5, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[5],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A4=A4-A5, p=0, cnta5!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 1 Difference: A1 = A0 - A0   :   Preserve Set */

#ifdef DEBUG
printf("\n*** Case 1 Difference: A1 = A0 - A0   :   Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[0];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[0];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'D';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[0], 
		targetid=a_objid[1]
		);

/*sts = OM_set_operations_by_name('d', 1, a_objid[0], "acb", a_objid[0], "acb", 
				a_objid[1], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Difference 1st case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_count(	objid=a_objid[1],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A1=A0-A0, p=1, cnta1!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 1 Difference: A0 = A0 - A0   :   Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Case 1 Difference: A0 = A0 - A0   :   Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[0];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[0];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'd';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[0], 
		targetid=a_objid[0]
		);

/*sts = OM_set_operations_by_name('d', 0, a_objid[0], "acb", a_objid[0], "acb", 
				a_objid[0], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Difference 1st case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_count(	objid=a_objid[0],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A0=A0-A0, p=0, cnta0!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/*	Connect A5 to B0-B3	*/

#ifdef DEBUG
printf("\n***	Connecting A5 to B0-B3	***\n");
#endif

connect_args.to_sel.type = OM_e_name;
connect_args.to_sel.u_sel.name = chan_bca;
connect_args.to_idx = 0;
connect_args.fr_objid = a_objid[5];
connect_args.fr_os = OM_Gw_current_OS;
connect_args.fr_sel.type = OM_e_name;
connect_args.fr_sel.u_sel.name = chan_acb;
connect_args.fr_idx = 0;


for(i=0; i<4; i++)
{
    sts=om$send(msg=&connect_msg, 
		senderid=a_objid[5], 
		targetid=b_objid[i]
		);
		
/*  sts = OM_connect_by_name ( "OM_TransOS_0", a_objid[5], "acb", minorchan, 
		relindex, "OM_TransOS_0", b_objid[i], "bca", minorchan, 
		relindex);
*/

    if (!(sts&1))
    {
        printf ("\nerror in send to connect: %x \n", sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }
}

#ifdef DEBUG
printf("\nconnected A5 to B0-B3\n");
#endif


/*****************************************************************************/

/* Case 1 Intersection: A4 = A4 ^ A4   :   Do Preserve Set */

#ifdef DEBUG
printf("\n*** Case 1 Intersection: A4 = A4 ^ A4   :   Do Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[4];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[4];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'i';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[4], 
		targetid=a_objid[4]
		);

/*sts = OM_set_operations_by_name('i', 1, a_objid[4], "acb", a_objid[4], "acb", 
				a_objid[4], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Intersection 1st case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[4],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A4=A4^A4, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 2 Intersection: A0 = A4 ^ A1   :   Do Preserve Set */

#ifdef DEBUG
printf("\n*** Case 2 Intersection: A0 = A4 ^ A1   :   Do Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[4];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[1];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'i';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[4], 
		targetid=a_objid[0]
		);

/*sts = OM_set_operations_by_name('i', 1, a_objid[4], "acb", a_objid[1], "acb", 
				a_objid[0], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Intersection 2nd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_count(	objid=a_objid[0],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A0=A4^A1, p=1, cnta0!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 3 Intersection: A1 = A4 ^ A4   :   Do Preserve Set */

#ifdef DEBUG
printf("\n*** Case 3 Intersection: A1 = A4 ^ A4   :   Do Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[4];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[4];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'I';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[4], 
		targetid=a_objid[1]
		);

/*sts = OM_set_operations_by_name('I', 1, a_objid[4], "acb", a_objid[4], "acb", 
				a_objid[1], "acb");
*/

if (!(sts&1))
{
    printf ("\nerror in send to set_operation Intersection 3rd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[1],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A1=A4^A4, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 4 Intersection: A2 = A4 ^ A1   :   Do Preserve Set */

#ifdef DEBUG
printf("\n*** Case 4 Intersection: A2 = A4 ^ A1   :   Do Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[4];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[1];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'I';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[4], 
		targetid=a_objid[2]
		);

/*sts = OM_set_operations_by_name('I', 1, a_objid[4], "acb", a_objid[1], "acb", 
				a_objid[2], "acb");
*/

if (!(sts&1))
{
    printf("\nerror in send to set_operation Intersection 4th case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[2],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A2=A4^A1, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 5 Intersection: A5 = A2 ^ A5   :   Do Preserve Set */

#ifdef DEBUG
printf("\n*** Case 5 Intersection: A5 = A2 ^ A5   :   Do Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[2];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[5];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'I';
set_operation_args.preserve = 1;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[2], 
		targetid=a_objid[5]
		);

/*sts = OM_set_operations_by_name('I', 1, a_objid[2], "acb", a_objid[5], "acb", 
				a_objid[5], "acb");
*/

if (!(sts&1))
{
    printf("\nerror in send to set_operation Intersection 5th case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[5],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	count != 1			 )
	{
	printf("*** error in A5=A2^A5, p=1 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 2 Intersection: A0 = A0 ^ A5   :   Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Case 2 Intersection: A0 = A0 ^ A5   :   Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[0];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[5];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'i';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[0], 
		targetid=a_objid[0]
		);

/*sts = OM_set_operations_by_name('i', 0, a_objid[0], "acb", a_objid[5], "acb", 
				a_objid[0], "acb");
*/

if (!(sts&1))
{
    printf("\nerror in send to set_operation Intersection 2nd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_count(	objid=a_objid[0],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A0=A0^A5, p=0, cnta0!=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[5],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A0=A0^A5, p=0, cnta5!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 3 Intersection: A5 = A2 ^ A2   :   Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Case 3 Intersection: A5 = A2 ^ A2   :   Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[2];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[2];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'i';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[2], 
		targetid=a_objid[5]
		);

/*sts = OM_set_operations_by_name('i', 0, a_objid[2], "acb", a_objid[2], "acb", 
				a_objid[5], "acb");
*/

if (!(sts&1))
{
    printf("\nerror in send to set_operation Intersection 3rd case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[5],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A5=A2^A2, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[2],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A5=A2^A2, p=0, cnta2!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 4 Intersection: A1 = A1 ^ A5   :   Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Case 4 Intersection: A1 = A1 ^ A5   :   Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[1];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[5];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'I';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[1], 
		targetid=a_objid[1]
		);

/*sts = OM_set_operations_by_name('I', 0, a_objid[1], "acb", a_objid[5], "acb", 
				a_objid[1], "acb");
*/

if (!(sts&1))
{
    printf("\nerror in send to set_operation Intersection 4th case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[1],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A1=A1^A5, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[5],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A1=A1^A5, p=0, cnta5!=0 ***\n");
	exit();
	}

/*****************************************************************************/

/* Case 5 Intersection: A5 = A1 ^ A4   :   Do Not Preserve Set */

#ifdef DEBUG
printf("\n*** Case 5 Intersection: A5 = A1 ^ A4   :   Do Not Preserve Set ***\n");
#endif

set_operation_args.to_sel.type = OM_e_name;
set_operation_args.to_sel.u_sel.name = chan_acb;
set_operation_args.op2_objid = a_objid[1];
set_operation_args.op2_os = OM_Gw_current_OS;
set_operation_args.op2_sel.type = OM_e_name;
set_operation_args.op2_sel.u_sel.name = chan_acb;
set_operation_args.op3_objid = a_objid[4];
set_operation_args.op3_os = OM_Gw_current_OS;
set_operation_args.op3_sel.type = OM_e_name;
set_operation_args.op3_sel.u_sel.name = chan_acb;
set_operation_args.operation = 'I';
set_operation_args.preserve = 0;

sts=om$send(msg=&set_operation_msg, 
		senderid=a_objid[1], 
		targetid=a_objid[5]
		);

/*sts = OM_set_operations_by_name('I', 0, a_objid[1], "acb", a_objid[4], "acb", 
				a_objid[5], "acb");
*/

if (!(sts&1))
{
    printf("\nerror in send to set_operation Intersection 5th case: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

sts=om$get_channel_objects(	objid=a_objid[5],
				p_chanselect=&chansel,
				list=list,
				size=size,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_objects: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

OMT_qsort_objlnks(0, count-1, list);

#ifdef DEBUG
DEBUG_PRINT_LIST(list, count);
#endif

if (	list[0].S_objid != b_objid[3]	||
	list[1].S_objid != b_objid[4]	||
	count != 2			 )
	{
	printf("*** error in A5=A1^A4, p=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[1],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A5=A1^A4, p=0, cnta1!=0 ***\n");
	exit();
	}

sts=om$get_channel_count(	objid=a_objid[4],
				p_chanselect=&chansel,
				count=&count);
if (!(sts&1))
	{
	printf("error in get_channel_count: %d\n", sts);
	om$report_error(sts=sts);
	exit();
	}

if ( count != 0 )
	{
	printf("*** error in A5=A1^A4, p=0, cnta4!=0 ***\n");
	exit();
	}

/*****************************************************************************/

}

EX_error_box(vs, msg, title)
int   vs;
char  *msg, *title;
{
   if (!vs || !msg || !title)
   {
      printf("\n\nPoor Man's EX_error_box:\n");
      printf("\n+-------------------+\n");
      printf("|                   |\n");
      printf("|       x  x        |\n");
      printf("|         >         |\n");
      printf("|       ____        |\n");
      printf("|        U          |\n");
      printf("|                   |\n");
      printf("+-------------------+\n\n");
   }
   else if (msg)
      printf("--->%s\n", msg);
   return(1);
}


