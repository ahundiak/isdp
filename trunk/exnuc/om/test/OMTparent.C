#include "OMeveryone.h"
#define DEBUG

main ()

{						/* main */

int		sts, i;
OM_S_OBJID	d_objid;
OM_S_MESSAGE    display_msg;
	

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
printf("\n*** Construct D object ***\n");
#endif


sts=om$construct(classname="classd", osnum=OM_Gw_current_OS,
			p_objid=&d_objid
			);
			
    if (!(sts&1))
    {
        printf ("error in om$construct: %x \n", sts );
        om$report_error(sts=sts);
        exit();
    }


#ifdef DEBUG
printf("\n*** Constructed class D object ***\n");
#endif

#ifdef DEBUG
printf("\n Prepare to send to parent's display.\n");
#endif

sts = om$make_message(	classname="classd", 
			methodname="display", 
			p_msg=&display_msg);
			
if ( ! (sts & 1 ) )
	{
	printf(" error in make_message for display : %x\n",  sts );
	om$report_error(sts=sts);
	exit();
	}
	
sts = om$send(	mode=OM_e_wrt_parent,
		msg=&display_msg, 
		senderid=NULL_OBJID, 
		targetid=d_objid);
		
if ( ! (sts & 1 ) )
     {
      printf(" error in send to display: %x\n", sts );
      om$report_error(sts=sts);
      exit();
     }


}
