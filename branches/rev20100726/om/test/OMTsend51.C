#include <sys/types.h>
#include <sys/times.h>
#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"

#define	MAXA	1

main ()

{						/* main */

int		sts, i;
OM_S_OBJID	a_objid[MAXA];
OM_S_MESSAGE    display_msg;

int num;

#ifdef TIME
printf("\nEnter the number of times to execute tests: ");
scanf("%d", &num);

printf("\n********************* Timing Tests ***************************\n");
printf("This test will time %d sends.\n", num );
printf("The user time and system time will be given before and after\n");
printf("the test in 60ths of a second.\n");
printf("**************************************************************\n\n\n\n");
#else
num=1000000;
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

#ifdef DEBUG
printf("\n*** Construct A objects ***\n");
#endif

for(i=0; i<MAXA; i++)

{

    sts=om$construct(classname="class5", osnum=OM_Gw_current_OS,
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
printf("\n Prepare to send to display %d times \n", num);
#endif

sts = om$make_message(	classname="class1", 
			methodname="display", 
			p_msg=&display_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for display : %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}
	
#ifdef TIME
printf("\n*** Time before sends ***\n");
times( &buffer1 );
printf("user time: %d\n", buffer1.tms_utime);
printf("syst time: %d\n", buffer1.tms_stime);
#endif

for ( i=0; i<num; i++ )

   {   

   sts = om$send(	msg=&display_msg, 
			senderid=NULL_OBJID, 
			targetid=a_objid[0]);
			
   if ( ! (sts & 1 ) )
     {
      printf(" error in send to display: %x\n", sts );
      om$report_error(sts=sts);
      exit();
     }

   }

#ifdef TIME
printf("\n*** Time after sends ***\n");
times( &buffer2 );
printf("user time: %d\n", buffer2.tms_utime);
printf("syst time: %d\n", buffer2.tms_stime);

printf("\n*** Total time required for %d sends ***\n", num);
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

