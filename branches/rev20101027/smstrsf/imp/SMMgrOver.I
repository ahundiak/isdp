/* $Id: SMMgrOver.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        smstrsf/SMMgrOver.I
 *
 * Description:
 *
 *      This file override the SMmgr methods for the management of the 
 *	main (or structural) surfaces.
 *
 * Dependencies:
 *
 *      SMMainSf
 *
 * Revision History:
 *	$Log: SMMgrOver.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
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
 *      02/01/93        P. Lacroix      Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation SMMainSf;

#include "SMStructSf.h"


#include "AS_status.h"

#define AS_DEBUG


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMWhoAreYou from SMmgr

  Abstract

	Returns the type and subtype of the object (See SMdef.h)

  Arguments

   IGRlong           *msg            O : Completion code

   IGRshort          *type           O : Type of the object
                                          (see SMdef.h).

   IGRshort          *sub_type       O : Sub-type of the object
                                          (see SMdef.h).

  Status/Return Code
     OM_S_SUCCESS	if successfull
     OM_E_ABORT 	if not



 -------------------------------------------------------------------------
-mo*/

method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{

 if(sub_type != NULL) *sub_type = 0xffff;

 if(type != NULL) *type = SM_SRF;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMFillSfFile from SMmgr

  Abstract

	Adds the object information to the given file.
	Each object knows how to write its own info.

  Notes/Remarks

	That was implemented for Seasafe data extraction.

  Arguments

   IGRlong           	*mask            O : Completion code

   File              	*p_file          I : File pointer.

   IGRshort           	options          I : Possible options (not yet used).

   IGRboolean         	tag              I : TRUE => only taged objects
                                             are concerned.

   IGRshort           	out_units        I : Output units (SMdef.h)

   struct GRmdenv_info 	*obj_env         I : Object environnement.

   struct GRmdenv_info 	*trans_env       I : Transformation matrix.

  Status/Return Code
    OM_S_SUCCESS	if successfull
    OM_E_ABORT 		if not



 -------------------------------------------------------------------------
-mo*/

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
 IGRlong 		status, loc_msg;
 IGRshort		state;



 /*
  * The Calculation section is maybe in deffer mode, if true, it has to be
  * recomputed.
  */
 
 status = om$send(msg = message SMmgr.SMGetState(&state),
 			targetid = my_id);
 if(!(status & 1)) return OM_W_ABORT;

 if(state & SM_NOT_COMP)
  {
   IGRboolean CurCalFlg;

   /* Get the calculation section state to turn it on and restore it */

   SMGetCalMnSfFlg(&CurCalFlg);
   if(CurCalFlg != TRUE) SMSetCalMnSfFlg(1);
   status = om$send(msg = message NDnode.NDs_compute_node(&loc_msg, 0, NULL),
   			targetid = my_id);
   if(CurCalFlg != TRUE) SMSetCalMnSfFlg(0);
   if(!(status & 1)) return OM_W_ABORT;

   status = om$send(msg = message SMmgr.SMGetState(&state),
 			targetid = my_id);
   if(!(status & 1)) return OM_W_ABORT;
  }

 if(state & SM_CAL_ERR) return OM_W_ABORT;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}



/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMFillRpFile from SMmgr

  Abstract

	Adds the object information to the given file.
	Each object knows how to write its own info.

  Notes/Remarks

	That was implemented to generate on line reports

  Arguments

   IGRlong           	*mask            O : Completion code

   IGRchar		*DescFile	 O : File describing the output format
					     (can be NULL).

   File              	*p_file          I : File pointer.

   IGRshort           	options          I : Report type (see SMdef.h)

   IGRboolean         	tag              I : TRUE => only taged objects
                                             are concerned.

   IGRshort           	out_units        I : Output units (SMdef.h)

   struct GRmdenv_info 	*obj_env         I : Object environnement.

   struct GRmdenv_info 	*trans_env       I : Transformation matrix.

  Status/Return Code
      OM_S_SUCCESS	if successfull
      OM_E_ABORT 	if not



 -------------------------------------------------------------------------
-mo*/

method SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file;
                     IGRshort options; IGRboolean tag; IGRshort out_units;
                     struct GRmdenv_info *obj_env, *trans_env)
{

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDdelete from NDnode

  Abstract

     This message is used to delete an element of the graph.
     It has been overriden to unconsume the surface.


  Arguments

      struct GRmd_env	*md_env           I	module env info


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method NDdelete(struct GRmd_env *md_env)

{
 IGRlong 	status, loc_msg;
 IGRint		stat;
 IGRdouble	consume;
 IGRshort	is_consume, is_display;
 struct GRid	as_pl;


 status = om$send( msg = message  ACcpx.ACfind_exp_temp_obj
					(&stat,1,&as_pl),
                    targetid = my_id );
 as$status( action = RET_STATUS );
 if(!stat) goto wrapup;

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"consume",
			&consume, NULL),
 			targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No consume defined for the surface\n");
    goto wrapup;
  }
 if(consume == 1){
 	is_consume = 0; /* unconsume the template */
 	is_display = 1;
 	status = VDconsume_and_display( as_pl, is_consume, is_display, md_env );
 	as$status( action = RET_STATUS );
 }
 
wrapup:
        status = om$send( msg      = message ACncpx.NDdelete(md_env),
	         targetid = my_id,
                 mode     = OM_e_wrt_message );
 	as$status( action = RET_STATUS );
 return(1);
}

end implementation SMMainSf;
 

