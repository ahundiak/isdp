#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"

#define MAXA	1
#define MAXB	1
#define MAXC	1

main ()

{						/* main */

int		sts, i, num=999;
OM_S_OBJID	a_objid[MAXA], b_objid[MAXB], c_objid[MAXC];
OM_S_MESSAGE    printb_msg, b1_msg, b2_msg, b3_msg, printj_msg,
printh1_msg, printh2_msg;
char		*cur_class, *sub_class, *rec_class, *mth_name, *mth_class;

sts=om$runtime_init( );
if (!(sts&1))
{
    printf ("error in OM_runtime_init: %x \n", sts );
    om$report_error(sts=sts);
    exit();
}

for(i=0; i<MAXA; i++)

{
    sts=om$construct(classname="clsa", p_objid=&a_objid[i]
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

    sts=om$construct(classname="clsb", p_objid=&b_objid[i]
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

    sts=om$construct(classname="clsc", p_objid=&c_objid[i]
			);

    if (!(sts&1))
    {
        printf ("\n error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }
}

cur_class = "clsc";
rec_class = "clsb";
sub_class = "sub_clsb";
mth_class = "clse";
mth_name = "printe1";

printf("\n****************************************************\n");
printf("om$recognize_class: cur_class=%s\n", cur_class);		
printf("                    rec_class=%s\n", rec_class);		
printf("                    sub_class=%s\n", sub_class);		
printf("                    mth_class=%s\n", mth_class);		
printf("                    mth_name= %s\n", mth_name);		
printf("****************************************************\n\n");

sts = om$recognize_class(cur_class=cur_class,
			rec_class=rec_class,
			sub_class=sub_class,
			mth_class=mth_class,
			mth_name=mth_name);

if ( ! ( sts & 1 ) )
	{
	printf("error from om$recognize_class\n");
	om$report_error(sts=sts);
	exit();
	}

/* Make clsb messages */

sts = om$make_message(	classname="clsb", 
			methodname="printb", 
			p_msg=&printb_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printb: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

sts = om$make_message(	classname="clsb", 
			methodname="b1", 
			p_msg=&b1_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for b1: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

sts = om$make_message(	classname="clsb", 
			methodname="b2", 
			p_msg=&b2_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for b2: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

sts = om$make_message(	classname="clsb", 
			methodname="b3", 
			p_msg=&b3_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for b3: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}


printf("\n*** Send to message printb from c_objid[0] ***\n");

sts = om$send(	msg=&printb_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb printb from clsc objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

printf("\n*** Send to message printb from c_objid[0]; should be printe1 method ***\n");

sts = om$send(	msg=&b1_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb b1 from clsc objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }


printf("\n*** Send to message b2 from c_objid[0] ***\n");

sts = om$send(	msg=&b2_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb b2 from clsc objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

printf("\n*** Send to message b3 from c_objid[0]; should be printe1 method ***\n");

sts = om$send(	msg=&b3_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsb b3 from clsc objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

cur_class = "clsc";
rec_class = "clsh";
sub_class = "sub_clsh";
mth_class = "clse";
mth_name = "printe1";

printf("\n****************************************************\n");
printf("om$recognize_class: cur_class=%s\n", cur_class);		
printf("                    rec_class=%s\n", rec_class);		
printf("                    sub_class=%s\n", sub_class);		
printf("                    mth_class=%s\n", mth_class);		
printf("                    mth_name= %s\n", mth_name);		
printf("****************************************************\n\n");

sts = om$recognize_class(cur_class=cur_class,
			rec_class=rec_class,
			sub_class=sub_class,
			mth_class=mth_class,
			mth_name=mth_name);

if ( ! ( sts & 1 ) )
	{
	printf("error from om$recognize_class\n");
	om$report_error(sts=sts);
	exit();
	}

sts = om$make_message(	classname="clsh", 
			methodname="printh1", 
			p_msg=&printh1_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printh1: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

sts = om$make_message(	classname="clsh", 
			methodname="printh2", 
			size=sizeof(int),
			p_arglist=&num,
			p_msg=&printh2_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printh2: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printh1 from c_objid[0]; should be printe1 ***\n");

sts = om$send(	msg=&printh1_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsh printh1 from clsc objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

printf("\n*** Send to message printh2 from c_objid[0] ***\n");

sts = om$send(	msg=&printh2_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsh printh2 from clsc objid[0]: %x\n", sts );
   om$report_error(sts=sts);
   exit();
  }

cur_class = "clsc";
rec_class = "clsj";
sub_class = "sub_clsj";
mth_class = "clse";
mth_name = "printe1";

printf("\n****************************************************\n");
printf("om$recognize_class: cur_class=%s\n", cur_class);		
printf("                    rec_class=%s\n", rec_class);		
printf("                    sub_class=%s\n", sub_class);		
printf("                    mth_class=%s\n", mth_class);		
printf("                    mth_name= %s\n", mth_name);		
printf("****************************************************\n\n");

sts = om$recognize_class(cur_class=cur_class,
			rec_class=rec_class,
			sub_class=sub_class,
			mth_class=mth_class,
			mth_name=mth_name);

if ( ! ( sts & 1 ) )
	{
	printf("error from om$recognize_class\n");
	om$report_error(sts=sts);
	exit();
	}

sts = om$make_message(	classname="clsj", 
			size=sizeof(int),
			methodname="printj", 
			p_arglist=&num,
			p_msg=&printj_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for printj: %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}

printf("\n*** Send to message printj from c_objid[0] ***\n");

sts = om$send(	msg=&printj_msg, 
		senderid=NULL_OBJID, 
		targetid=c_objid[0]);
			
if ( ! (sts & 1 ) )
  {
   printf("ERROR in send to clsj printj from clsc objid[0]: %x\n", sts );
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


