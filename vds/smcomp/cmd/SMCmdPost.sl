/* $Id: SMCmdPost.sl,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        smcomp/cmd/SMCmdPost.sl
 *
 * Description:
 *
 *      This command adds attributes of each solid to the compartment
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMCmdPost.sl,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/13  19:39:14  pinnacle
# Replaced: smcomp/cmd/SMCmdPost.sl for:  by v250_int for vds
#
# Revision 1.3  1998/04/13  17:10:14  pinnacle
# Replaced by A.Gupta
#
# Revision 1.2  1998/03/05  14:17:10  pinnacle
# Replaced: smcomp/cmd/SMCmdPost.sl for:  by rchennup for vds
#
# Revision 1.1  1998/02/13  17:22:36  pinnacle
# Created: smcomp/cmd/SMCmdPost.sl by rchennup for vds
#
*
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/13/97	Sundar		Creation
 * -------------------------------------------------------------------*/

command_string       SMC_M_Post,0,SMPost
class                SMCmdPost
command_table        "sman.cmd"
super_class          VDS_LOCATE
product_name        "$VDS"

form "SMAvReport",0,0,"-1","-1"

/*---------------------
 * specification area
 */

specification

/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class SMCmdPost

  Superclass
	VDS_LOCATE

  Abstract
 	This command adds the info of each solid to compartment.


  Methods

     hilite_half	Public		Semi hilite all stored volumes.


  Overridden Methods

     init_all			initialise the instances.

 -------------------------------------------------------------------------

-cmd*/

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "go.h"
#include "igrdp.h"
#include "OMmacros.h"

#include "UOMdef.h"
#include "growner.h"
#include "coparamac.h"
#include "asmacros.h"

#include "dp.h"
#include "dpmacros.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDScheckdef.h"
#include "ACdb_info.h"
#include "VDSutil.h"
#include "PDUerror.h"

#include "FI.h"

#include "vdsmacros.h"
#include "SMdef.h"
#include "SMcomp_def.h"
#include "SMPost.h"
#include "SMmacros.h"
#include "SMmsg.h"
#include "VDmsg.h"

#include "SMCompForm.h"

#include "VDmem.h"
#include "VDPdef.h"
#include "VDPzone.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

/*+v
 -------------------------------------------------------------------------
*/
instance
{

  struct GRid 		comp_id; /* Id of the working compartment */
  struct SMsol_attr     solinfo[SM_MAX_ALLOW_VOL]; /* Info of all volumes */
  IGRchar CompFrame[POST_NAME];
  IGRchar CompSide[POST_NAME];
  IGRchar CompUsage[POST_NAME]; 
}
/*
 -------------------------------------------------------------------------
-v*/

/*---------------------
 * implementation area
 */

implementation

#include "UOMmacros.h"
#include "AS_status.h"
#include "emsmass.h"
#include "vdbmacros.h"
#include "SMCompForm.h"


#define AS_DEBUG	1

from SMcomp import SMGetVolInfo;
from NDnode     import NDget_objects ;

/*---------------------
 * state table area
 */

state_table

#define TRUE  1
#define FALSE 0

#include "SMCompForm.h"
#include "SMmsg.h"
#include "VDSFilter.h"

state start

	execute		PmeWakeup ( &me->ret )
			  on ERROR
				do status "No PME database connection"
								state terminate
	message_key	SM_M_Post
	prompt_key	SM_P_LocComp
	accept_key	SM_P_PlAccRej
	locate_mask	"GRm_DATA | GRm_TEXT_VALUE"
	locate_eligible "SMcomp"
	locate_owner     "LC_RIGID_COMP | LC_RIGID_OWNER |
			 LC_FLEX_COMP | LC_FLEX_OWNER"
	filter		vds_locate

	on EX_DATA or EX_OBJID
		do process_comp
			on ERROR				state .
		do erase_hilite
								state .
at init		do init_all
at sleep	do erase_hilite

/*********************************************************************/
action form_notification (int form_label; int gadget_label ; double value ;
                          char * form_ptr )
{
	IGRint row, pos, col, sel_flag, r_pos;
	IGRlong msg;

   switch( gadget_label )
   {
   case FI_CANCEL:
		FIf_erase(form_ptr );
	break;

   case FI_ACCEPT:
		status = om$send(  msg      = message SMCmdPost.SMSetcomp_attr(
                                                &msg),
                                targetid = my_id);
		FIf_erase(form_ptr );
#ifdef TEST
		{
			IGRint i, nb_vol;
			struct ACrg_coll *Coll=NULL;

			/* testing of the functions */
			i = SMPmeGetNbVol( me->comp_id, &nb_vol);
			i = SMPmeGetVolAtt(me->comp_id, 1, &Coll);

			#ifdef vdsDEBUG
			for (i=0; i<7; i++)
                		printf ("%s\n",Coll[i].desc.value.att_txt);
			#endif

			_FREE(Coll);
				
		}
#endif
	break;
   case POST_FRAME_FLD:
        FIg_get_text(form_ptr,POST_FRAME_FLD,me->CompFrame);
        break;  
   case POST_SIDE_FLD:
        FIg_get_text(form_ptr,POST_SIDE_FLD,me->CompSide);
        break;
   case POST_USAGE_FLD:
        FIg_get_text(form_ptr,POST_USAGE_FLD,me->CompUsage);
        break; 

   case POST_ALL_FLD:

	FIfld_get_active_row(form_ptr,POST_ALL_FLD, &row,&pos);
        FImcf_get_active_col(form_ptr,POST_ALL_FLD,&col,&pos);

        switch(col)
        {
            case DECK :
		FIfld_get_text(form_ptr,POST_ALL_FLD,row,DECK,5,
                        (unsigned char*)me->solinfo[row].deck, 
			&sel_flag, &r_pos);
		break;

        }
	break;
   }

	return OM_S_SUCCESS;
}

action process_comp 
{

	IGRshort	*obj_type = NULL;
	int 		count,i, nb_vol, tt_vol;
	long 		msg;
	char 		name_comp[100];
	struct GRid 	root,vol_id[SM_MAX_ALLOW_VOL], 
			col_id[SM_MAX_ALLOW_VOL];

	me->comp_id = me->event1.located_object[0].located_obj ;

	vd$get_name(name = name_comp, obj = &me->comp_id);

	FIg_set_text(me->forms[0].form_ptr,POST_NAME_FLD,name_comp);
  
        /*  */
        status = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT,&root,OM_K_MAXINT,NULL,0,0,&count),
                   senderid = NULL_OBJID,
                   targetid = me->comp_id.objid,
                   targetos = me->comp_id.osnum );  
       if(status != OM_S_SUCCESS) {
                printf ("Could not get roots\n");
        } 
       printf ("root=[%d,%d]\n", root.objid, root.osnum);

        if (!VDSGetAttTxt(&root, "frame", me->CompFrame))
                        me->CompFrame[0] = '\0';
        if (!VDSGetAttTxt(&root, "side", me->CompSide))
                        me->CompSide[0] = '\0';
        if (!VDSGetAttTxt(&root, "usage", me->CompUsage))
                        me->CompUsage[0] = '\0';

        /*  */                                           

	nb_vol=0;
        status = om$send( msg = message SMcomp.SMGetVolInfo(&msg,
				SM_MAX_ALLOW_VOL, &nb_vol, &tt_vol, 
				vol_id, col_id, obj_type, NULL),
                        targetid = me->comp_id.objid,
			targetos = me->comp_id.osnum);
	

	FIfld_set_num_rows(me->forms[0].form_ptr,POST_ALL_FLD,nb_vol);
	for (i=0; i<nb_vol; i++){

		double              props[NUMB_PROPS];

		/*
		 * Check if Collector has attributes and
		 * get them.
		 */

		if (!VDSGetAttTxt(&col_id[i], "solid", me->solinfo[i].solid))
			me->solinfo[i].solid[0] = '\0';

		if (!VDSGetAttTxt(&col_id[i], "deck", me->solinfo[i].deck))
			me->solinfo[i].deck[0] = '\0';

		me->solinfo[i].farea[0] = '\0';
		me->solinfo[i].volume[0] = '\0';

		sprintf(me->solinfo[i].solid, "defined%d", i);

		if(SMCompFloorProp(&vol_id[i],
                                &me->event1.located_object[0].module_info,
                                1., 1., props) != 1) {
                }
                sprintf(me->solinfo[i].farea, "%.2f",  props[11]);

		if(SMCompMassProp(&vol_id[i],
			MASS_PROPERTIES,
			&me->event1.located_object[0].module_info.md_env,	
			1., 1., props) != 1) {
		}
		sprintf(me->solinfo[i].volume, "%.2f",  props[0]);

	}

#ifdef	vdsDEBUG
	for (i=0; i<nb_vol; i++){
		printf (" Solid [%d].solid : %s\n", i,me->solinfo[i].solid );
		printf (" Solid [%d].deck : %s\n", i,me->solinfo[i].deck );
		printf (" Solid [%d].frame : %s\n", i,me->solinfo[i].frame );
		printf (" Solid [%d].side : %s\n", i,me->solinfo[i].side );
		printf (" Solid [%d].usage : %s\n", i,me->solinfo[i].usage );
		printf (" Solid [%d].farea : %s\n", i,me->solinfo[i].farea );
		printf (" Solid [%d].volume : %s\n", i,me->solinfo[i].volume );
	}
#endif

        FIg_set_text(me->forms[0].form_ptr,POST_FRAME_FLD,me->CompFrame);
        FIg_set_text(me->forms[0].form_ptr,POST_SIDE_FLD,me->CompSide);
        FIg_set_text(me->forms[0].form_ptr,POST_USAGE_FLD,me->CompUsage);
	
	for (i=0; i<nb_vol; i++){
		FIfld_set_text( me->forms[0].form_ptr,POST_ALL_FLD,
                                i, SOLID, me->solinfo[i].solid );
                FIfld_set_text( me->forms[0].form_ptr,POST_ALL_FLD,
                                i, DECK,  me->solinfo[i].deck );
                FIfld_set_text(me->forms[0].form_ptr,POST_ALL_FLD,
                                i, FAREA,  me->solinfo[i].farea );
                FIfld_set_text(me->forms[0].form_ptr,POST_ALL_FLD,
                                i, 3,  me->solinfo[i].volume );
/*
                FIfld_set_text(me->forms[0].form_ptr,POST_ALL_FLD,
                                i, VOLUME, me->solinfo[i].volume );
 */
	}


	FIf_display(me->forms[0].form_ptr);

  return OM_S_SUCCESS;
}

action SMSetcomp_attr( IGRlong *sts )
{
	IGRshort        *obj_type = NULL;
        int             count,num_vol, i, tt_vol;
        long            msg;
	struct GRid 	root,vol_id[SM_MAX_ALLOW_VOL], 
			col_id[SM_MAX_ALLOW_VOL];

        /* */
        status = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT,&root,OM_K_MAXINT,NULL,0,0,&count),
                   senderid = NULL_OBJID,
                   targetid = me->comp_id.objid,
                   targetos = me->comp_id.osnum );
        if(status != OM_S_SUCCESS) {
                printf ("Could not get roots\n");
        }                                             
        printf ("root=[%d,%d]\n", root.objid, root.osnum);
        if (!VDSSetAttTxt(&root, "frame", me->CompFrame, 0)){
                        VDSSetAttTxt(&root, "frame",
                                me->CompFrame, 1);
           }  
        if (!VDSSetAttTxt(&root, "side", me->CompSide, 0)){
                        VDSSetAttTxt(&root, "side",
                                me->CompSide, 1);
           }
        if (!VDSSetAttTxt(&root, "usage", me->CompUsage, 0)){
                        VDSSetAttTxt(&root, "usage",
                                me->CompUsage, 1);
           } 
        /* */        


	status = om$send( msg = message SMcomp.SMGetVolInfo(&msg,
                                SM_MAX_ALLOW_VOL, &num_vol, &tt_vol,
                                vol_id, col_id, obj_type, NULL),
                        targetid = me->comp_id.objid,
                        targetos = me->comp_id.osnum);

	for (i=0; i<num_vol; i++){
	   if (!VDSSetAttTxt(&col_id[i], "solid", me->solinfo[i].solid, 0)){
			VDSSetAttTxt(&col_id[i], "solid", 
				me->solinfo[i].solid, 1);
	   }
	   if (!VDSSetAttTxt(&col_id[i], "deck", me->solinfo[i].deck, 0)){
			VDSSetAttTxt(&col_id[i], "deck", 
				me->solinfo[i].deck, 1);
	   }
	   if (!VDSSetAttTxt(&col_id[i], "farea", me->solinfo[i].farea, 0)){
			VDSSetAttTxt(&col_id[i], "farea", 
				me->solinfo[i].farea, 1);
	   }
	   if (!VDSSetAttTxt(&col_id[i], "volume", me->solinfo[i].volume, 0)){
			VDSSetAttTxt(&col_id[i], "volume", 
				me->solinfo[i].volume, 1);
	   }
	}

	*sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

action PmeWakeup ( IGRlong *msg)
{
	if ( IsPmeEnabled() )
		*msg = MSSUCC ;
	else
		*msg = MSFAIL ;
	
	return OM_S_SUCCESS;
}
