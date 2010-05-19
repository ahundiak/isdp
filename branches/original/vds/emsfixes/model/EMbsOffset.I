/* $Id: EMbsOffset.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/model/EMbsOffset.I
 *
 * Description:
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: EMbsOffset.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/06/24  14:55:54  pinnacle
# tr179801103
#
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/24/98  ah      TR179801103 Offset curve, ignore warnings
 ***************************************************************************/

/* ###################   APOGEE COMPILED   ################## */
class implementation GRbspline;

#include "EMS.h"
#include "msdef.h"
#include "grerr.h"

/* # include "grdef.h" */

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

#include "bserr.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "bsparameters.h"
#include "bsfreecv.h"
#include "bscvoffsetd.h"

extern GRclassid OPP_GR3dpoint_class_id;
/*
 * RLW quick fix routine to create proper class during an offset.
 * This should really be done by the proper class but alas we
 * are not responsible for the other classes.
 *
 * 08/27/87 : Quick fix date (kluge)
 * 09/07/88 : Modified to support infinite lines
 *   Sudha  06/16/93     Modified for BSprototype ansification
 * 
 *   SAM    10/7/94 	 EMS310 TR#119423144. Offsets of SKcircle/SKarc should not 
 * 			 produce a SKcircle/SKarc at this level. It now produces a 
 * 			 GR3dcircle and GR3dcirarc. Note this is needed since we don't
 * 			 want SK geometries without their SKmgr. It is needed here since 
 * 			 this method is not overidden at various SK classes.
 */

extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GRcircle_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_SKcircle_class_id;
extern OMuword OPP_GRcirarc_class_id;
extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_SKarc_class_id;
extern OMuword OPP_GRlinear_class_id;
extern OMuword OPP_GRinfline_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dinfline_class_id;

static void Local_off_classid(
 curve_classid,
 curve,
 new_curve_classid)

OMuword		curve_classid;
struct		IGRbsp_curve *curve;
OMuword		*new_curve_classid;

{
 IGRlong sts;
 IGRdouble tol;

 BSEXTRACTPAR (&sts, BSTOLLENVEC, tol);
 if (EFpts_degenerate (curve->num_poles, curve->poles, curve->weights, 3, tol))
   *new_curve_classid = OPP_GR3dpoint_class_id;
 else if (curve->order == 2)
  {
   sts = om$is_ancestry_valid(superclassid = OPP_GRinfline_class_id,
                              subclassid = curve_classid);
    if (sts == OM_S_SUCCESS)
     *new_curve_classid = OPP_GR3dinfline_class_id;
    else if (curve->num_poles == 2)
     *new_curve_classid = OPP_GR3dlineseg_class_id;
    else
     *new_curve_classid = OPP_GR3dlinestr_class_id;
  }
 else if ((curve->order == 3) && (curve->rational))
  {
   sts = om$is_ancestry_valid(superclassid = OPP_GRcircle_class_id,
                              subclassid = curve_classid);
    if (sts == OM_S_SUCCESS)
    {
     /*
      * TR# 119423144, do not produce SK classes at this level
      */
     
     if (curve_classid == OPP_SKcircle_class_id)
      *new_curve_classid = OPP_GR3dcircle_class_id;
     else
      *new_curve_classid = curve_classid;
    }
    else
     {
      sts = om$is_ancestry_valid(superclassid = OPP_GRcirarc_class_id,
                                 subclassid = curve_classid);
       if (sts == OM_S_SUCCESS)
       {
        /*
         * TR# 119423144, do not produce SK classes at this level
         */         
        
        if (curve_classid == OPP_SKarc_class_id)
         *new_curve_classid = OPP_GR3dcirarc_class_id;
        else
         *new_curve_classid = curve_classid;         
       }
       else
        *new_curve_classid = OPP_GRbcsubbc_class_id;
     }
  }
 else
  *new_curve_classid = OPP_GRbcsubbc_class_id;

 return;
}
/*
 * End RLW quick fix routine
 */

method EMcvoffset(IGRlong	*EMmsg;
		IGRshort	*mattype;
		IGRmatrix	matrix;
		struct GRvg_construct *const_list;
		IGRdouble 	*dist;
		IGRvector 	vector;
		IGRboolean	right_side;
		IGRboolean	uniform;
		IGRint		*off_code;
		IGRboolean	fillet;
		IGRboolean	remove_loops;
		struct GRid	*off_crv_id;
		IGRlong		*num_loops;
		struct IGRbsp_curve ***loops;
		IGRlong		**loop_table)



/*
Abstract

  This method offsets a curve. 

History

	SS	10/03/86 : Design date.
	rlw	08/27/87 : Modified to output proper class
	RV	12/31/87 : Revision to incorporate major advances
			   in offset technology.
        rlw     09/07/88 : Modified to support infinite lines.
                           Modified to construct curve in object space
                           dictated by construct list - not current OS.
    dhm 01/20/89 : Took out place where const_list->msg's address was 
                   being changed.  This can cause memory faults.
*/

{
  IGRlong		OM_stat;
  BSrc			rc;
  OMuword		my_classid, new_classid;
  struct IGRbsp_curve	*crv_geom = NULL, *res_crv_geom = NULL;
  char			*gen_ptr = NULL;
  IGRint		i, moron_num_loops = 0;
  IGRboolean		temp_side;
  IGRpoint		moron_point;
  struct IGRbsp_curve   **moron_loops = NULL;


  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  OM_stat = om$send(msg = message GRcurve.GRgenabsg(EMmsg,
                  		mattype,
                  		matrix,
                  		&gen_ptr),
                 	targetid = my_id);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  crv_geom = (struct IGRbsp_curve *) gen_ptr;

  BScvoffsetd(crv_geom, *dist, NULL, TRUE, (fillet ? 1 : 0),
	      (remove_loops ? 2 : 0), &right_side, vector, &res_crv_geom,
	      &moron_num_loops, &moron_loops, &rc);

  // TR179801103
  if (rc == BSWARN) rc = BSSUCC;
  
  
  EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_I_BSerror,wrapup);

  OM_stat = om$get_classid(object = me,
                           p_classid = &my_classid);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 

  Local_off_classid(my_classid, res_crv_geom, &new_classid);
  if (new_classid == OPP_GR3dpoint_class_id)
    *EMmsg = EMS_I_Degenerate;

  const_list->newflag = FALSE;
  const_list->geometry = (IGRchar *) res_crv_geom;
  off_crv_id->osnum = const_list->env_info->md_id.osnum;
  OM_stat = om$construct(classid = new_classid,
                         msg = message GRvg.GRconstruct(const_list),
                         p_objid = &off_crv_id->objid,
                         osnum = off_crv_id->osnum);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 

  if (res_crv_geom) BSfreecv (&rc, res_crv_geom);


wrapup:

  /* deallocate moron loops just in case math returned loops */

  for (i=0; i<moron_num_loops; i++)
  {
    if (moron_loops && moron_loops[i]) BSfreecv(&rc, moron_loops[i]);
  }
  if (moron_loops) om$dealloc(ptr = moron_loops);

  EMWRAPUP(*EMmsg, OM_stat, "In GRbspline.EMoffset")
  return(OM_stat);
}


end implementation GRbspline;
