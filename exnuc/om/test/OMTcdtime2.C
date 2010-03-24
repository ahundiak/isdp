#include <sys/types.h>
#include <sys/times.h>
#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"


#define	MAXA	1
#define MAXB    2

main ()

{						/* main */

int		sts, i;
OM_S_OBJID	a_objid[MAXA], b_objid[MAXB];
OM_S_MESSAGE    connect_msg, disconnect_msg;
char            chan_acb[10], chan_bca[10];

int num;

struct connect_struct
	{
	OM_S_CHANSELECT	to_sel;
	int		to_idx;
	OM_S_OBJID	fr_objid;
	uword		fr_os;
	OM_S_CHANSELECT fr_sel;
	int		fr_idx;
	} connect_args;

struct disconnect_struct
	{
	OM_S_CHANSELECT	to_sel;
	OM_S_OBJID	fr_objid;
	uword		fr_os;
	OM_S_CHANSELECT fr_sel;
	} disconnect_args;	
	
#ifdef TIME
struct tms buffer1, buffer2;

printf("\nEnter the number of times to execute tests: ");
scanf("%d", &num);

printf("\n********************* Timing Tests ***************************\n");
printf("This test will time %d connects and disconnects.\n", num );
printf("The user time and system time will be given before and after\n");
printf("each test in 60ths of a second. The channel used is many_to_many,\n");
printf("unordered, with default initial size and increment values.\n");
printf("**************************************************************\n\n\n\n");
#else
num=10000;
#endif

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

#ifdef DEBUG
printf("\n*** Construct A objects ***\n");
#endif

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
printf("\n*** Constructed %d class A object(s) ***\n", MAXA);
#endif

#ifdef DEBUG
printf("\n*** Construct B objects ***\n");
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
printf("\n*** Constructed %d class B object(s) ***\n", num);
#endif


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


    disconnect_args.to_sel.type = OM_e_name;
    disconnect_args.to_sel.u_sel.name = chan_bca;
    disconnect_args.fr_objid = a_objid[0];
    disconnect_args.fr_os = OM_Gw_current_OS;
    disconnect_args.fr_sel.type = OM_e_name;
    disconnect_args.fr_sel.u_sel.name = chan_acb;

    sts=om$make_message(classname="Root", 
			methodname="disconnect", 
			size=sizeof(struct disconnect_struct), 
			p_arglist=&disconnect_args, 
			p_msg=&disconnect_msg
			);
    if (!(sts&1))
    {
	   printf ("\nerror in om$make_message for disconnect: %x\n", sts);
	   om$report_error(sts=sts);
	   exit();
    }

/* Connect a0 to b0 */

    sts=om$send(msg=&connect_msg, 
		senderid=a_objid[0], 
		targetid=b_objid[0]
		);
		
    if (!(sts&1))
    {
        printf ("\nerror in send to connect: %x \n", sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }


#ifdef TIME
printf("\n*** Time before connects / disconnects ***\n");
times( &buffer1 );
printf("user time: %d\n", buffer1.tms_utime);
printf("syst time: %d\n", buffer1.tms_stime);
#endif

for(i=0; i<num; i++)

{
			
    sts=om$send(msg=&connect_msg, 
		senderid=a_objid[0], 
		targetid=b_objid[1]
		);
		
    if (!(sts&1))
    {
        printf ("\nerror in send to connect: %x \n", sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }

			
    sts=om$send(msg=&disconnect_msg, 
		senderid=a_objid[0], 
		targetid=b_objid[1]
		);
		
    if (!(sts&1))
    {
        printf ("\nerror in send to disconnect: %x \n", sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }

}

#ifdef TIME
printf("\n*** Time after connects / disconnects ***\n");
times( &buffer2 );
printf("user time: %d\n", buffer2.tms_utime);
printf("syst time: %d\n", buffer2.tms_stime);

printf("\n*** Total time required for %d connects /disconnects ***\n", num);
printf("user time: %d\n", buffer2.tms_utime - buffer1.tms_utime );
printf("syst time: %d\n", buffer2.tms_stime - buffer1.tms_stime );
#endif

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

