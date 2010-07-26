#include <sys/types.h>
#include <sys/times.h>
#include "OMeveryone.h"

#define MAXTST	75

main ()

{						/* main */

int		sts, i;
OM_S_OBJID	tst_objid[MAXTST];
OM_S_MESSAGE    connect_msg, display_msg;
OM_S_CHANSELECT chan_0_sel;
char 		class_name[10];
char            chan_0[15], chan_n[15];
OMuword		classid;
struct tms buffer1, buffer2;

struct connect_struct
	{
	OM_S_CHANSELECT	to_sel;
	int		to_idx;
	OM_S_OBJID	fr_objid;
	uword		fr_os;
	OM_S_CHANSELECT fr_sel;
	int		fr_idx;
	} connect_args;

	
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

strcpy(chan_0, "tst0.chan0");

#ifdef DEBUG
printf("\n*** Construct tst objects ***\n");
#endif

for(i=0; i<MAXTST; i++)
{

    sprintf(class_name,"tst%d",i);

    sts=om$construct(classname=class_name, osnum=OM_Gw_current_OS,
			p_objid=&tst_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }

#ifdef DEBUG
om$get_classid(classname=class_name,p_classid=&classid);
printf("\nconstructed class: %s  classid: %d\n", class_name,classid);
#endif

}

    connect_args.to_sel.type = OM_e_name;
    connect_args.to_idx = 0;
    connect_args.fr_objid = tst_objid[0];
    connect_args.fr_os = OM_Gw_current_OS;
    connect_args.fr_sel.type = OM_e_name;
    connect_args.fr_sel.u_sel.name = chan_0;
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


for(i=1; i<MAXTST; i++)

{
			
    sprintf(chan_n,"tst%d.chan%d",i,i);

#ifdef DEBUG
printf("\nchan_n: %s\n", chan_n);
#endif

    connect_args.to_sel.u_sel.name = chan_n;

    sts=om$send(msg=connect_msg, 
		senderid=tst_objid[0], 
		targetid=tst_objid[i]
		);
		
    if ( ! (sts&1) )
	{
	om$report_error(sts=sts);
	exit();
	}			
}

sts=om$make_message(classname="tst", 
		methodname="display", 
		p_msg=&display_msg);
if (!(sts&1))
    {
    printf ("\nerror in om$make_message for display: %x\n", sts);
    om$report_error(sts=sts);
    exit();
    }


chan_0_sel.type = OM_e_name;
chan_0_sel.u_sel.name = chan_0;

#ifdef TIME
printf("\n*** Time before send ***\n");
times( &buffer1 );
printf("user time: %d\n", buffer1.tms_utime);
printf("syst time: %d\n", buffer1.tms_stime);
#endif


for (i=0;i<100;i++)
{

sts = om$send(	msg=display_msg,
		senderid=tst_objid[0],
		p_chanselect=&chan_0_sel );

if ( ! (sts&1) )
	{
	om$report_error(sts=sts);
	exit();
	}			
}

#ifdef TIME
printf("\n*** Time after send ***\n");
times( &buffer2 );
printf("user time: %d\n", buffer2.tms_utime);
printf("syst time: %d\n", buffer2.tms_stime);

printf("\n*** Total time required send ***\n");
printf("user time: %d\n", buffer2.tms_utime - buffer1.tms_utime );
printf("syst time: %d\n", buffer2.tms_stime - buffer1.tms_stime );
#endif

}
