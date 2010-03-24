class implementation Ddel ;

from Adel import respond_to_Ddel,delete;
from Bdel import respond_to_Ddel,delete;
from Cdel import respond_to_Ddel,delete;
from Bprdel import respond_to_Ddel,delete;
from Cprdel import respond_to_Ddel,delete;

#include "OMobjectcomm.h"
#include <stdio.h>
#include "cerr.c"

/* ************************ MACROS *************************/
/* macro for constructing an object in default object space */
#define	construct(CLASS_NAME,OBJECT_PTR) sts = OM_construct_object_by_name(\
        /* OS name		*/ "OM_TransOS_0",\
        /* class name        	*/ "CLASS_NAME",\
        /* place for object id  */ &OBJECT_PTR,\
        /* neighbor		*/ OM_GS_NULL_NEIGHBOR,\
        /* argument list 	*/ NULL,\
        /* ptr to VLA descriptor*/ NULL,\
        /* number of VLA's	*/ NULL);\
        if (sts != OM_S_SUCCESS)\
            err_abort(sts,"Error in OM_construct_object_by_name ")

/* end of construct macro*/

/* macro to send a message to an object id...*/
#define OBJ OM_e_wrt_object
#define MSG OM_e_wrt_message
#define sendit(TARGET_ID, MESSAGE_NAME, OBORMESS) sts = OM_send_object(\
       /* use object's method	*/ OBORMESS,\
       /* message structure	*/ message MESSAGE_NAME,\
       /* sender objid 		*/ my_id,\
       /* target objid		*/ TARGET_ID);\
       if (sts != OM_S_SUCCESS)\
           err_report(sts,"Error in OM_send_object ")
/* end of send macro..*/
/************************ END OF MACROS ***********************/

method MAINDEL()
{

/* this method is the main method for this test  series */

	OM_S_OBJID a_objid,b_objid,c_objid,bpr_objid,cpr_objid;
	int sts,defer;
/* construct an A object and  delete it */	

	printf("--- inside D .. constructing an A object ...\n");

	construct(Adel,a_objid);
	printf(" delete an A object using root.delete \n");
	printf(" showing spacemap before delete ...\n");
	sts = OMpms_show_spacemap(OM_Gw_current_OS);

	sendit(a_objid,Root.delete(0),OBJ);
	printf("--- deleted A .. showing spacemap after\n");
	sts = OMpms_show_spacemap(OM_Gw_current_OS);

	for (defer=0; defer <= 1; defer++)
	{
	printf("\n\n*****************************************");
	printf(" DEFER = %d TEST **************************\n",defer);
	   if (!(defer)){
		printf("--- constructing a A,B, and C \n");
 		construct(Adel,a_objid);
		construct(Bdel,b_objid);
		construct(Cdel,c_objid);
	   }
/*
/* delete A,B, and C with a method that should work ..
*/
		printf("\n\n========<<<<<<<<< delete A >>>>>>>>>>======\n");
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		printf(" ---- deleting A with defer = %d\n",defer);
		sendit(a_objid,Adel.delete(defer),OBJ);
		printf("--- deleted A .. showing spacemap after\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);

		printf("\n\n========<<<<<<<<< delete B >>>>>>>>>>======\n");
		printf(" ---- deleting B with defer = %d\n",defer);
		sendit(b_objid,Bdel.delete(defer),OBJ);
		printf("--- deleted B .. showing spacemap after\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
	
		printf("\n\n========<<<<<<<<< delete C >>>>>>>>>>======\n");
		printf(" ---- deleting C with defer = %d\n",defer);
		sendit(c_objid,Cdel.delete(defer),OBJ);
		printf("--- deleted C .. showing spacemap after\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
	
		printf("\n\n ---- constructing another A,B, and C \n");
		construct(Adel,a_objid);
		construct(Bdel,b_objid);
		construct(Cdel,c_objid);

/*
/* delete again with send depth greater than 0	..
*/

		printf("\n\n========<<<<<<<<< delete A >>>>>>>>>>======\n");
		printf(" -telling A to tell us to delete it \n");
		sendit(a_objid,Adel.respond_to_Ddel('A',defer,1),OBJ);
	
		printf("\n\n========<<<<<<<<< delete B >>>>>>>>>>======\n");
		printf(" telling B to tell us to delete it \n");
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(b_objid,Adel.respond_to_Ddel('B',defer,1),OBJ);
	
		printf("\n\n========<<<<<<<<< delete C >>>>>>>>>>======\n");
		printf("telling C to tell us to delete it \n");
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(c_objid,Cdel.respond_to_Ddel('C',defer,1),OBJ);

	}	/* end of do for defer=false, then true */

/*
/* delete A,B, and C with a method that shouldn't work ..
*/
	printf("\n\n\n\n============= bprime and cprime test =======\n");
		printf("\n\n-- constructing a B prime and C prime \n");
		construct(Bprdel,bpr_objid);
		construct(Cprdel,cpr_objid);


	for (defer=0; defer <= 1; defer++)
	{
	printf("\n\n*****************************************");
	printf(" DEFER = %d TEST **************************\n",defer);

/*
/* do with send depth = 0 ...
*/
		printf("\n\n========<<<<<<<<< delete B' >>>>>>>>>>======\n");
		printf("---- deleting B prime with defer = %d\n",defer);
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(bpr_objid,Bprdel.delete(defer),OBJ);
	
		printf("\n\n========<<<<<<<<< delete C' >>>>>>>>>>======\n");
		printf("---- deleting C prime with defer = %d\n",defer);
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(cpr_objid,Cprdel.delete(defer),OBJ);
	
/*
/* delete again with send depth greater than 0	..
*/
		printf("\n\n========<<<<<<<<< delete B' >>>>>>>>>>======\n");
		printf(" telling B prime to tell us to delete it \n");
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(bpr_objid,Bprdel.respond_to_Ddel('b',defer,1),OBJ);
	
		printf("\n\n========<<<<<<<<< delete C' >>>>>>>>>>======\n");
		printf(" telling C prime to tell us to delete it \n");
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(cpr_objid,Cprdel.respond_to_Ddel('c',defer,1),OBJ);


	}	/* end of do for defer=false, then true */

/*
/* now see what happens when you send two deferred deletes in a row 
/* with send depth =0 and send depth > 0
*/

	for (defer=0; defer <= 1; defer++)
	{
		printf("--- constructing an A \n");
 		construct(Adel,a_objid);
/*
/* delete A twice ..
*/
		printf(" ---- deleting A with defer = %d\n",defer);
		printf(" showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(a_objid,Adel.delete(defer),OBJ);
		printf("--- deleted A .. showing spacemap after\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);

		printf(" ---- deleting A again with defer = %d\n",defer);
		sendit(a_objid,Adel.delete(defer),OBJ);
		printf("--- showing spacemap after 2nd attempt ..\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);

		printf("---- constructing another A \n");
		construct(Adel,a_objid);
/*
/* delete again with send depth greater than 0	..
*/
		printf("--- telling A to tell us to delete it \n");
		printf("\n\n showing spacemap before delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
		sendit(a_objid,Adel.respond_to_Ddel('A',defer,2),OBJ);
	
	}	/* end of do for defer=false, then true */

		printf("\n\n showing spacemap after delete ...\n");
		sts = OMpms_show_spacemap(OM_Gw_current_OS);
	printf("--- returned  to D \n");


	return(OM_S_SUCCESS);
}
/* end of MAINDEL method	*/

/*....................method definition ..................*/
/* sample parameter declaration ...*/


method Telld(char classname;int defer; int times)

{

	int sts;
/* send  a delete message to the object that sent me this message */
/* they sent me their class name so i can request that they use their
/* delete method ...*/

        switch(classname){
        /* is it a class A object? */
        case 'A':
	printf("--- sending a class 'A' delete message. defer %d\n",defer);
        	sendit(sender_id,Adel.delete(defer),OBJ);
        	if (times == 2){ sendit(sender_id,Adel.delete(defer),OBJ);}
        break;

	/* is it a class B OBJect? */
        case 'B':
	printf("--- sending a class 'B' delete message. defer %d\n",defer);
        	sendit(sender_id,Bdel.delete(defer),OBJ);
        	if (times == 2){ sendit(sender_id,Bdel.delete(defer),OBJ);}
        break;

	/* is it a class C object? */
        case 'C':
	printf("--- sending a class 'C' delete message. defer %d\n",defer);
        	sendit(sender_id,Cdel.delete(defer),OBJ);
        	if (times == 2){sendit(sender_id,Cdel.delete(defer),OBJ);}
        break;

        /* is it a class B prime object? */
        case 'b':
	printf("--- sending a class 'b' delete message. defer %d\n",defer);
        	sendit(sender_id,Bprdel.delete(defer),OBJ);
        	if (times == 2){sendit(sender_id,Bprdel.delete(defer),OBJ);}
        break;

        /* is it a class C prime object? */
        case 'c':
	printf("--- sending a class 'c' delete message. defer %d\n",defer);
        	sendit(sender_id,Cprdel.delete(defer),OBJ);
        	if (times == 2){sendit(sender_id,Cprdel.delete(defer),OBJ);}
        break;
        default: break;
        }              /* end of case statement */      
	printf("From Ddel: returning from 2nd level tell to delete..\n");
	return(sts);
}			/* end of Telld method	*/


/**.......................................................**/
	main()
	{
/* main routine for the delete test program..*/
	
	OM_S_OBJID d_objid;
	int sts,my_id;

	my_id = 0;
        printf("Initializing the object manager ....");
        sts = OM_runtime_init(NULL,NULL);
        if (sts != OM_S_SUCCESS) 
           err_abort(sts,"Error in OM_runtime_init ");

	construct(Ddel,d_objid);
	sendit(d_objid,Ddel.MAINDEL(),OBJ);

	printf(" goodbye.....");
}


end implementation Ddel;

