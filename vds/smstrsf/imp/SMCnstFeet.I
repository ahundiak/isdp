/* $Id: SMCnstFeet.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        smstrsf/SMCnstFeet.I
 *
 * Description:
 *
 *      This file implements the ACconstruct_feet for the structural
 *	surface.
 *
 * Dependencies:
 *
 *      SMMainSf
 *
 * Revision History:
 *	$Log: SMCnstFeet.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  18:27:34  pinnacle
# Fixed uninit ref
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/02/19  05:49:52  pinnacle
# Replaced: smstrsf/imp/SMCnstFeet.I for:  by rgade for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      02/19/93        P. Lacroix	Creation date.
 *      02/19/96	Ravi	        Set the cog attr.
 *	10/30/97	ah		Fix uninitialized sfprops
 * -------------------------------------------------------------------------
 */


class implementation SMMainSf;


#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsmass.h"


#include "VDSutil_def.h" 
#include "vdsmacros.h"
#include "SMdef.h"
#include "SMStructSf.h"
#include "SMcomp_def.h"

#include "AS_status.h"



/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 /* Root list:
 /*
 /*	- Dynamic collection (description, location, comp_flag, ...).
 /*	- surface
 /*
 /* */

 IGRlong 		status, loc_msg;
 IGRchar		name[81];
 IGRshort		is_consume, is_display, macro_props,sfprops, type, x_offset, y_offset;
 IGRdouble		consume, val, density, weight; 
 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level;
 struct GRobj_env	surf;
 struct	GRvg_construct  cst;
 IGRboolean		CalFlg, CurDspFlg;
 struct GRsymbology	symb;

 IGRdouble 		area, props[NUMB_PROPS],cog[3];

 *fcount = 0;
 *rc     = 0;

 sfprops = 0; // Get rid of uninitialized warning
 sfprops = VD_NO_DISP_PT | VD_NO_DISP_TXT;

 /* Set the construction list (get the active symb) .
 /* */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = md_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;

 feet_list[0].objid = NULL_OBJID;
 feet_list[1].objid = NULL_OBJID;
 feet_list[0].osnum = md_env->md_id.osnum;
 feet_list[1].osnum = md_env->md_id.osnum;

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg     = &loc_msg,
                       sizbuf  = &sizebuf,
                       buffer  = &display,
                       nret    = &nret);

 /*| get the active level */

 sizebuf = sizeof(IGRshort);
 gr$get_active_level(msg     = &loc_msg,
                     sizbuf  = &sizebuf,
                     buffer  = &level,
                     nret    = &nret);
 cst.display    = &display;
 cst.level      = level;

 symb.display_attr = display;
 symb.level      = level;

 if(!GetEnvFrObj(&list[1], &surf.mod_env, &surf.obj_id)) {
   printf("Error GetEnvFrObj\n");
   goto wrapup;
 }
 status = om$send(msg = message GRgraphics.GRcopy(&loc_msg, &surf.mod_env, md_env,
			&feet_list[0].objid),
                  senderid = NULL_OBJID,
		  targetid = surf.obj_id.objid,
		  targetos = surf.obj_id.osnum );
 as$status();
 if(!(status & loc_msg & 1)) {
	feet_list[0].objid = NULL_OBJID;
	goto wrapup;
 }
 status = om$send(msg = message GRvg.GRputsymb(&loc_msg,&symb),
                  senderid = NULL_OBJID,
		  targetid = feet_list[0].objid,
		  targetos = feet_list[0].osnum );
 as$status();
 if(!(status & loc_msg & 1)) {
	printf("Erreur putsymb object = %d, %d\n",feet_list[0].objid,feet_list[0].osnum ); 
	goto wrapup;
 }

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"consume",
			&consume, NULL),
 			targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No consume defined for the surface\n");
    goto wrapup;
  }

 if(consume == 1){

 	/* consume the template and  undisplay it */
	is_display = 0;
  	is_consume = 1;
  
  	status = VDconsume_and_display( list[1], is_consume, is_display, &surf.mod_env );
  	as$status( );
 }
 
 if(!(SMGetCalMnSfFlg(&CalFlg) & 1)) CalFlg = FALSE;
 if(CalFlg != TRUE)
  {
   /* No compute are provided */

   /* Set the surface state to modified */
   status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id);
   as$status();


   /* Set the calculation flag to: SM_NOT_COMP  */
   status = om$send(msg = message SMmgr.SMChgState(SM_NOT_COMP , 
   						   SM_NOT_COMP ),
                  targetid = my_id);
   as$status();
   feet_list[1].objid = NULL_OBJID;
   *fcount = 2;
   *rc = 1;
   return OM_S_SUCCESS;
  }

 
 if(SMCompMassProp(&surf.obj_id, AREA_PROPERTIES, &surf.mod_env.md_env,
		      1., 1., props) != 1){
   printf("Error in the computation of the mass prop for the surface\n");
   goto wrapup;
 }
 cog[0] = props[2];  
 cog[1] = props[3];  
 cog[2] = props[4];  

 area = props[11];

 /* set the cog atttributes -Ravi TR#179528520  */

 type = SM_SYST_ATT | SM_DYNAMIC_ATT;

 status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "cog_x",
			cog[0], type),
                  targetid = my_id );
 as$status();
 if(!(status & loc_msg & 1)) {
	goto wrapup;
 }

 status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "cog_y",
			cog[1], type),
                  targetid = my_id );
 as$status();
 if(!(status & loc_msg & 1)) {
	goto wrapup;
 }

 status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "cog_z",
			cog[2], type),
                  targetid = my_id );
 as$status();
 if(!(status & loc_msg & 1)) {
	goto wrapup;
 }

 /* set the area */
 status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "area",
			area, type),
                  targetid = my_id );
 as$status();
 if(!(status & loc_msg & 1)) {
	goto wrapup;
 }

 /* set the weight */

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"density",
			&density, NULL),
 			targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No density defined for the surface\n");
    goto wrapup;
  }

 weight = density * area;

 status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "weight",
			weight, type),
                  targetid = my_id );
 as$status();
 if(!(status & loc_msg & 1)) {
	goto wrapup;
 }

 cst.env_info = md_env;


 /* Create special VDpoint */

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg,"name",
			name, NULL),
 			targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No name defined for the surface\n");
    goto wrapup;
  }


 SMGetDspMnSfFlg(&CurDspFlg);
 if(CurDspFlg == FALSE) sfprops = VD_NO_DISP_PT | VD_NO_DISP_TXT;
 else
  {
    status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"props",
						     &val, NULL),
		     targetid = my_id);

    if(!(status & loc_msg & 1))
      macro_props = SM_CMP_DSP_CMP_COG_PT | SM_CMP_DSP_CMP_COG_NAME;
    else
     {
       sfprops = 0;
       macro_props = (IGRshort) val;
       if(!(macro_props & SM_CMP_DSP_CMP_COG_PT))
	 sfprops = sfprops | VD_NO_DISP_PT;
       if(!(macro_props & SM_CMP_DSP_CMP_COG_NAME))
	 sfprops = sfprops | VD_NO_DISP_TXT;   
     }
  }

 x_offset = y_offset = 0;

 status = vd$cnst_txt_pt(    msg 		= &loc_msg,
   		  	     pt 		= cog,
			     name 		= name,
			     x_offset		= 0,
			     y_offset		= 0,
			     props		= sfprops,
		  	     cst		= &cst,
		  	     obj		= &feet_list[1]);

 if(!(status & loc_msg & 1)) {
	feet_list[1].objid = NULL_OBJID;
	goto wrapup;
 }

 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
 as$status();

 /* Clear if it was the error state */
 status = om$send(msg = message SMmgr.SMChgState(SM_NOT_COMP | SM_CAL_ERR, (IGRshort) 0),
                  targetid = my_id );
 as$status();


 *fcount = 2;
 *rc = 1;
 return	OM_S_SUCCESS;

 
wrapup:

 /* Change the state to modified & error */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, SM_CAL_ERR),
                  targetid = my_id );
 as$status();

 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
 as$status();

 *rc = 0;
 return OM_W_ABORT;
}

end implementation SMMainSf;
 

