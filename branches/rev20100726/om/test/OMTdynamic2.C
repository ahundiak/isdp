#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#define MAXA	1
#define MAXB	1
#define MAXC	3
#define MAXD	3
#define MAXSUBD 1
#define MAXE    3

main ()

{						/* main */

int		sts, i, num;
OM_S_OBJID	a_objid[MAXA], b_objid[MAXB], c_objid[MAXC], e_objid[MAXE];
OM_S_OBJID	d_objid[MAXD], subd0_objid[MAXSUBD], subd1_objid[MAXSUBD], ssubd_objid[MAXSUBD], old_d;
OM_S_MESSAGE    connect_msg, disconnect_msg, ass_write, printa_msg,
printb_msg, printe1_msg;
OM_S_CHANSELECT chansel;
OMuword		classid;
char            chan_acb[15], chan_cchan[15];
extern	int	OM_Gd_construct;


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

char osname[30];

struct write_args_struct
	{
	char *new_osname;
	} write_args;

OM_S_OBJID filedobj;
uword filed_osnum;
static char *OMparams[]={"DEFTRANS_GROUP_NUMOBJS=12000",NULL};

sts=om$runtime_init( paramc=1, param_list=OMparams );
if (!(sts&1))
   {
   printf ("error in OM_runtime_init: %x \n", sts );
   om$report_error(sts=sts);
   exit();
   }

/******** Construct Filed Object Space *****************/

sts = om$make_message(	classname="OMFiledOS", 
			methodname="write", 
			size=sizeof(struct write_args_struct), 
			p_arglist=&write_args, 
			p_msg=&ass_write);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for write : %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}
	
sts = om$construct_os(	classname="OMFiledOS",
			osnum=&filed_osnum,
			osname="OSdyn",
			di_logical=":dynamic",
			p_objid=&filedobj);

if (!(sts&1))
	{
	printf("*** ERROR in CONSTRUCT OS ***\n");
	om$report_error(sts=sts);
	exit();
	}

#ifdef DEBUG
printf("\n*** Filed OS successfully constructed ***\n");
printf("filed_osnum: %d\n", filed_osnum);
printf("filedobj: %d\n", filedobj);
#endif

om$make_current_os( osnum=filed_osnum );

strcpy(chan_acb, "clsa.acb");

strcpy(chan_cchan, "clsc.cchan");

for(i=0; i<MAXA; i++)

{

    sts=om$construct(classname="clsa", osnum=filed_osnum,
			p_objid=&a_objid[i]
			);
			
    if (!(sts&1))
    {
        printf ("error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

for(i=0; i<MAXB; i++)
{

    sts=om$construct(classname="clsb", osnum=filed_osnum,
			p_objid=&b_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}


for(i=0; i<MAXC; i++)
{

    sts=om$construct(classname="clsc", osnum=filed_osnum,
			p_objid=&c_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}


for(i=0; i<MAXE; i++)
{

    sts=om$construct(classname="clse", osnum=filed_osnum,
			p_objid=&e_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

printf("\n\n*** Get classid for clsd ***\n\n");
sts = om$get_classid(classname="clsd",p_classid=&classid);
if (!(sts&1))
	{
	printf("\n***error in getting classid for clsd ***\n\n");
	om$report_error(sts=sts);
	}
printf("\n*** clsd classid: %d ***\n", classid);

printf("\n\n*** Construct clsd objects ***\n\n");

for ( i=0; i<MAXD; i++ )
{
sts=om$construct(classname="clsd", osnum=filed_osnum,
			p_objid=&d_objid[i]
			);
			
if (!(sts&1))
    {
        printf ("error in om$construct for clsd objid: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }

printf("\n**** Show d_objid[%d] ****\n",i);
som_show_object(filed_osnum, d_objid[i]);

}

sts = om$make_message(	classname="clsd", 
			methodname="printe1", 
			p_msg=&printe1_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printe1: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}


printf("\n*** Send to message printe1 from d_objid[0] ***\n");

sts = om$send(	msg=&printe1_msg, 
		senderid=NULL_OBJID, 
		targetid=d_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clse's display from clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

sts = om$make_message(	classname="clsd", 
			methodname="printb", 
			p_msg=&printb_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printb: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}


printf("\n*** Send to message printb from d_objid[0] ***\n");


sts = om$send(	msg=&printb_msg, 
		senderid=NULL_OBJID, 
		targetid=d_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb's display from clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }


printf("\n\n*** Get classid for sub0_clsd ***\n\n");
sts = om$get_classid(classname="sub0_clsd",p_classid=&classid);
if (!(sts&1))
	{
	printf("\n***error in getting classid for sub0_clsd ***\n\n");
	om$report_error(sts=sts);
	}
printf("\n*** sub0_clsd classid: %d ***\n", classid);

printf("\n\n*** Construct sub0_clsd objects ***\n\n");

for ( i=0; i<MAXSUBD; i++ )
{
sts=om$construct(classname="sub0_clsd", osnum=filed_osnum,
			p_objid=&subd0_objid[i]
			);
			
if (!(sts&1))
    {
        printf ("error in om$construct for sub0_clsd objid: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }

printf("\n**** Show subd0_objid[%d] ****\n",i);
som_show_object(filed_osnum, subd0_objid[i]);

}

sts = om$make_message(	classname="sub0_clsd", 
			methodname="printe1", 
			p_msg=&printe1_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printe1: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printe1 from subd0_objid[0] ***\n");

sts = om$send(	msg=&printe1_msg, 
		senderid=NULL_OBJID, 
		targetid=subd0_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clse's display from sub0_clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

sts = om$make_message(	classname="sub0_clsd", 
			methodname="printb", 
			p_msg=&printb_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printb: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printb from subd0_objid[0] ***\n");

sts = om$send(	msg=&printb_msg, 
		senderid=NULL_OBJID, 
		targetid=subd0_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb's display from sub0_clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }


printf("\n\n*** Get classid for sub1_clsd ***\n\n");
sts = om$get_classid(classname="sub1_clsd",p_classid=&classid);
if (!(sts&1))
	{
	printf("\n***error in getting classid for sub1_clsd ***\n\n");
	om$report_error(sts=sts);
	}
printf("\n*** sub1_clsd classid: %d ***\n", classid);

printf("\n\n*** Construct sub1_clsd objects ***\n\n");

for ( i=0; i<MAXSUBD; i++ )
{
sts=om$construct(classname="sub1_clsd", osnum=filed_osnum,
			p_objid=&subd1_objid[i]
			);
			
if (!(sts&1))
    {
        printf ("error in om$construct for sub1_clsd objid: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }

printf("\n**** Show subd1_objid[%d] ****\n",i);
som_show_object(filed_osnum, subd1_objid[i]);

}

sts = om$make_message(	classname="sub1_clsd", 
			methodname="printe1", 
			p_msg=&printe1_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printe1: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printe1 from subd1_objid[0] ***\n");

sts = om$send(	msg=&printe1_msg, 
		senderid=NULL_OBJID, 
		targetid=subd1_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clse's display from sub1_clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

sts = om$make_message(	classname="sub1_clsd", 
			methodname="printb", 
			p_msg=&printb_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printb: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printb from subd1_objid[0] ***\n");

sts = om$send(	msg=&printb_msg, 
		senderid=NULL_OBJID, 
		targetid=subd1_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb's display from sub1_clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }


printf("\n\n*** Get classid for ssub_clsd ***\n\n");
sts = om$get_classid(classname="ssub_clsd",p_classid=&classid);
if (!(sts&1))
	{
	printf("\n***error in getting classid for ssub_clsd ***\n\n");
	om$report_error(sts=sts);
	}
printf("\n*** ssub_clsd classid: %d ***\n", classid);

printf("\n\n*** Construct ssub_clsd objects ***\n\n");

for ( i=0; i<MAXSUBD; i++ )
{
sts=om$construct(classname="ssub_clsd", osnum=filed_osnum,
			p_objid=&ssubd_objid[i]
			);
			
if (!(sts&1))
    {
        printf ("error in om$construct for ssub_clsd objid: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }

printf("\n**** Show ssubd_objid[%d] ****\n",i);
som_show_object(filed_osnum, ssubd_objid[i]);

}

sts = om$make_message(	classname="ssub_clsd", 
			methodname="printe1", 
			p_msg=&printe1_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printe1: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printe1 from ssubd_objid[0] ***\n");

sts = om$send(	msg=&printe1_msg, 
		senderid=NULL_OBJID, 
		targetid=ssubd_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clse's display from ssub_clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

sts = om$make_message(	classname="ssub_clsd", 
			methodname="printb", 
			p_msg=&printb_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printb: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printb from ssubd_objid[0] ***\n");

sts = om$send(	msg=&printb_msg, 
		senderid=NULL_OBJID, 
		targetid=ssubd_objid[0],
		targetos=filed_osnum);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb's display from ssub_clsd objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

    connect_args.to_sel.type = OM_e_name;
    connect_args.to_sel.u_sel.name = chan_cchan;
    connect_args.to_idx = 0;
    connect_args.fr_os = filed_osnum;
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

printf("\n\n*** Connect d_objid[i] to c objid 0 ***\n\n");

for(i=0; i<MAXD; i++)

{
    connect_args.fr_objid = d_objid[i];

    sts=om$send(msg=&connect_msg, 
		senderid=d_objid[i], 
		targetid=c_objid[0],
		targetos=filed_osnum
		);
		
    if (!(sts&1))
    {
        printf ("\nerror in send to connect for clsd objid: %x \n",
sts );
        om$report_error(sts=sts);
	printf ("\niteration: %d\n", i);
        exit();
    }
}

/*======================================================*/
/*  issue send to translate name 'clsd_objid'           */
/*======================================================*/

sts = di$translate(objname = ":dynamic:clsd_objid",
		   p_objid = &old_d);

if (!(1&sts))
   {
      printf (" error from di$translate : %x \n", sts );
      di$report_error(sts=sts);
      exit();
   }

printf("\n*** old_d oid: %d\n", old_d);

printf("\n\n*** Connect old_d objid to c objid 0 ***\n\n");

connect_args.fr_objid = old_d;

sts=om$send(msg=&connect_msg, 
	senderid=old_d, 
	targetid=c_objid[0],
	targetos=filed_osnum
	);
		
if (!(sts&1))
    {
    printf ("\nerror in send to connect for clsd objid: %x \n", sts );
    om$report_error(sts=sts);
    exit();
    }

printf("\n*** Channel send from c_objid[0] to class a's display ***\n\n");

sts=om$make_message(classname="clsd", 
		methodname="printa", 
		size=sizeof(num), 
		p_arglist=&num, 
		p_msg=&printa_msg
		);

if (!(sts&1))
   {
   printf ("\nerror in om$make_message for printa: %x\n", sts);
   om$report_error(sts=sts);
   exit();
   }


num=101;
chansel.type = OM_e_name;
chansel.u_sel.name = chan_cchan;

sts = om$send(	msg=&printa_msg,
		senderid=c_objid[0],
		p_chanselect=&chansel,
		targetos=filed_osnum);

if ( ! ( sts & 1 ) )
	{
	printf("\n Error in channel send from c[0] \n");
	om$report_error(sts=sts);
	exit();
	}

  
printf("\n*** Disconnect the d_objids from the c_objids ***\n");

disconnect_args.to_sel.type = OM_e_name;
disconnect_args.to_sel.u_sel.name = chan_cchan;
disconnect_args.fr_os = filed_osnum;
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


for(i=0; i<MAXD; i++)

{
			
    disconnect_args.fr_objid = d_objid[i];

    sts=om$send(msg=&disconnect_msg, 
		senderid=d_objid[i], 
		targetid=c_objid[0],
		targetos=filed_osnum
		);
		
    if (!(sts&1))
    {
        printf ("\nerror in send to disconnect : %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

disconnect_args.fr_objid = old_d;

sts=om$send(msg=&disconnect_msg, 
	senderid=old_d, 
	targetid=c_objid[0],
	targetos=filed_osnum
	);
		
if (!(sts&1))
   {
   printf ("\nerror in send to disconnect for old_d : %x \n", sts );
   om$report_error(sts=sts);
   exit();
   }

/* Write out OS */

strcpy(osname,"OSdyn");

write_args.new_osname = osname;
   
sts = om$send(	msg=&ass_write, 
		senderid=filedobj, 
		targetid=filedobj,
		targetos=filed_osnum);
		
if ( ! (sts & 1 ) )
    {
     printf(" error in send to write os: %x\n", sts );
     om$report_error(sts=sts);
     exit();
    }


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


