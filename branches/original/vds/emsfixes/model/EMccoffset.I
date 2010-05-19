/* $Id: EMccoffset.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */
/***************************************************************************
* I/VDS
*
* File: emsfixes/model/EMccoffset.I        
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: EMccoffset.I,v $
*      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
*      Initial import to CVS
*
# Revision 1.1  2000/01/04  08:33:16  pinnacle
# New emsfile with fix for TR179900860
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      12/07/99  Jayadev TR179900860 Offset curve, check parameterization
***************************************************************************/
class implementation GRcompcurve;

/*

  HISTORY

        Sudha   06/21/93        modified for BSprototype ansification
*/

#include "EMScc.h"
#include "msdef.h"
#include "grerr.h"
#include "emsdef.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsicmpcvoff.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "OMmacros.h"
#include "bststcvfarc.h"
#include "bststcvdegn.h"
#include "bsreparmcv.h"
#include "bsmerge_cv.h"
#include "bsfreecv.h"
#include "bscv_copy.h"
#include "bscmpcvoff.h"
#include "bsalloccv.h"
#include "bsparameters.h"

#define INVALID -999

#define FIRST  0
#define SECOND 1

extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GRcircle_class_id;
extern OMuword OPP_GRcirarc_class_id;
extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GRlinear_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dlineseg_class_id;

/*
 * RLW quick fix routine to create proper class during an offset.
 * This should really be done by the proper class but alas we
 * are not responsible for the other classes.
 *
 * 8/27/87 : Quick fix date (kluge)
 */

extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GRcircle_class_id;
extern OMuword OPP_GRcirarc_class_id;
extern OMuword OPP_GRlinear_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dcirarc_class_id;

static void Local_off_classid(
 curve_classid,
 curve,
 new_curve_classid)

OMuword		curve_classid;
struct		IGRbsp_curve *curve;
OMuword		*new_curve_classid;

{
 IGRlong sts;

 *new_curve_classid = OPP_GRbcsubbc_class_id;
 if (curve->order == 2)
  {
/*
   sts = om$is_ancestry_valid(superclassid = OPP_GRlinear_class_id,
                              subclassid = curve_classid);
    if (sts == OM_S_SUCCESS)
     *new_curve_classid = curve_classid;
*/
    if (curve->num_poles == 2)
     *new_curve_classid = OPP_GR3dlineseg_class_id;
    else
     *new_curve_classid = OPP_GR3dlinestr_class_id;
  }
 else if ((curve->order == 3) && (curve->rational))
  {
   sts = om$is_ancestry_valid(superclassid = OPP_GRcircle_class_id,
                              subclassid = curve_classid);
    if (sts == OM_S_SUCCESS)
     *new_curve_classid = curve_classid;
    else   /* Check whether the curve is a circular arc */
     {
      IGRboolean  is_arc;
      IGRpoint    center;
      IGRdouble   radius;
      IGRdouble   buffer[38]; /* Space required for poles, knots and weights
                                 of arc */
      struct IGRbsp_curve arc;
      BSrc         rc;

      arc.poles = &buffer[0];
      arc.knots = &buffer[21];
      arc.weights = &buffer[31];

      BStstcvfarc(curve,&is_arc,center,&radius,&arc,&rc);
      if(rc != 0) return;
      
      if(is_arc) {			/* if it is an arc, copy the */
        BScv_copy (&rc, &arc, curve);   /* arc geometry to the curve */
        if (rc != 0) return;		/* and change its class	     */
        *new_curve_classid = OPP_GR3dcirarc_class_id;
        }
      else 
        *new_curve_classid = OPP_GRbcsubbc_class_id;
  /*******************************************************************
      sts = om$is_ancestry_valid(superclassid = OPP_GRcirarc_class_id,
                                 subclassid = curve_classid);
       if (sts == OM_S_SUCCESS) 
        *new_curve_classid = curve_classid;
       else
        *new_curve_classid = OPP_GRbcsubbc_class_id;
   *******************************************************************/
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

  This method offsets a composite curve. Each component may be offset
  with a different distance.

History

    12/31/87	RV	Creation
    09/07/88	rlw	Modified to construct result in object
				    space dictated by the construct list and
				    not the current OS.
    01/20/89    dhm	Took out all places where const_list->msg's 
				    address was being changed.  This can cause
				    memory faults.
    01/27/89	rlw	Modified to delete result on failure.
    01/30/89    rlw Modified not to create the members of the
                    offset which become degenerate.  These are
                    returned by the math for commands which
                    need this info, e.g. drafted surface.
    03/26/90    RC  Initialized crvs and res_crvs. Non-intialized pointers
                    were causing memory fault.
    05/14/90 Inasu  Modified to determine the class of offsetted B_spline curves
                    (Fix for TR 90N1019).
    02/06/92 Carlos After calling BStstcvfarc, if the b-spline was an arc, its
    		    class was changed but not its geometry. This fixed TR#92N0375.
    08/17/93 NP     Uninitialized array "pts2" was causing sqrt DOMAIN errors.
    12/06/93 Carlos Loop pointers were being bspcv freed and never really should
     		    have. See header for bscmpcvoff.
    04/19/95 Jagan  Set the phy_closed property to FALSE in the line_crv. 
                    Fix for TR#119421628 
    06/21/95 Aditya  Insufficient memory was being passed to BScmpcvoffset.
                     Fix for TR#119526456.
    06/21/95 Hari   Fix for ABW's : TR#119526441
 */

{
 IGRint i, j, k, l, prev_i, next_i;
 IGRlong msg_loc;
 IGRdouble knots[4];
 IGRpoint poles2[2], pts2[2];
 struct IGRpolyline py;
 struct IGRbsp_curve *cv, *newcv, line_crv;

  IGRlong		OM_stat, total_curves_produced;
  OM_S_CHANSELECT	to_comps, to_cpx;
  struct IGRbsp_curve   **crvs = NULL, **res_crvs = NULL, **dum_loops = NULL;
  BSrc			rc;
  OMuint                num_comps;
  IGRint		num_poles, res_num_comps, 
			*table = NULL, dum_num_loops = 0, *dum_loop_table = NULL;
  IGRlong		stupid_index;
  GRobjid		*compid = NULL, new_compid, last_curve_offset;
  OMuword		compos, comp_classid, new_classid;
  IGRboolean		closed,ret_code = FALSE;
  IGRlong		crv_size;



  
  OM_stat = OM_S_SUCCESS;
 
 newcv = NULL;

  off_crv_id->objid = NULL_OBJID;		/* rlw 01/27/89 */
  new_compid = NULL_OBJID;			/* rlw 01/27/89 */
  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.GRcmpowner->to_components;
  
  OM_stat = EMmake_chanselect(GRconnector_to_owners, &to_cpx);

  OM_stat = om$get_channel_count(object = me,
				p_chanselect = &to_comps,
				count = &num_comps);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  if (num_comps < 1) {*EMmsg = EMS_I_InvalidArg; goto wrapup;}

  crvs = (struct IGRbsp_curve **) om$malloc(size = (OMuint)
				 num_comps * sizeof(struct IGRbsp_curve *));
  EMerr_hndlr(!crvs,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   

  for (i = 0; i < num_comps; i++)
    crvs[i] = NULL;

  res_crvs = (struct IGRbsp_curve **) om$malloc(size = (OMuint)
                                 (2*num_comps+1)*sizeof(struct IGRbsp_curve *));
  EMerr_hndlr(!res_crvs,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   

  for (i = 0; i < (2*num_comps+1); i++)
    res_crvs[i] = NULL;

  table = (IGRint *) om$malloc(size = (OMuint) (2*num_comps+1)*sizeof(IGRint));
  EMerr_hndlr(!table,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   

  compid = (GRobjid *) om$malloc(size = (OMuint)
				 num_comps * sizeof(GRobjid));
  EMerr_hndlr(!compid,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);   

  for (i = 0; i < num_comps; i++)
  {
   OM_stat = om$get_objid_at_index(object = me,
					p_chanselect = &to_comps,
					index = i,
					objidaddr = &compid[i],
					osnumaddr = &compos);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 

   OM_stat = om$send (msg = message GRvg.GRgetsize(EMmsg,
                  		mattype, matrix, &crv_size),
                 	targetid = compid[i]);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   crvs[i] = (struct IGRbsp_curve *) om$malloc (size = (OMuint) crv_size);
   if (!crvs[i]) {*EMmsg = EMS_E_DynamicMemoryAllocated;  goto wrapup;}

   OM_stat = om$send(msg = message GRvg.GRgetgeom (EMmsg,
                  		mattype, matrix, (char *) crvs[i]),
                     targetid = compid[i]);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  }
  closed = ME.GRcompcurve->comp_props & GRIS_PHY_CLOSED;

  BScmpcvoff(num_comps, crvs, right_side, vector, dist, uniform,
  	     off_code, fillet, TRUE,
	     closed, &res_num_comps, res_crvs, table, 
	     &dum_num_loops, &dum_loops, &dum_loop_table, &rc);

  /* The following changes have been made for TR179900860 - begin */ 
  //EMerr_hndlr(rc == BSINARG,*EMmsg,EMS_I_InvalidArg,wrapup);
  //EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_I_BSerror,wrapup);
  if((rc == BSINARG) || (rc != BSSUCC))
  {
    ret_code = check_parameterization(num_comps,crvs);
    if(!ret_code) goto wrapup;
    
    BScmpcvoff(num_comps, crvs, right_side, vector, dist, uniform,
	       off_code, fillet, TRUE,closed, &res_num_comps, res_crvs, table,
	       &dum_num_loops, &dum_loops, &dum_loop_table, &rc);
    
    EMerr_hndlr(rc == BSINARG,*EMmsg,EMS_I_InvalidArg,wrapup);
    EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_I_BSerror,wrapup);
  }
  /* The above changes have been made for TR179900860 - end */ 
  if (!res_num_comps) {*EMmsg = EMS_I_Fail; goto wrapup;}

 /*
  * If the discontinuity after simple curve offset of the components was
  * filled up using a line-string with 3 points, break up the line-string into
  * two parts and merge these parts back into the adjoining offset results.
  */

 /* Uninitialized variables were causing sqrt DOMAIN error in EMcnvtpybsn fn. */
 for(i=0; i<2; i++)
   for(j=0; j<3; j++)
     pts2[i][j]=0.0;
 
 py.num_points = 2;
 py.points = (IGRdouble *) pts2;
 line_crv.poles = (IGRdouble *) poles2;
 line_crv.knots = knots;
 EMcnvtpybsn (&msg_loc, 3, &py, &line_crv); 
 /*
  * set the phy_closed property to FALSE as this is being a line segment. The
  * above routine would have set this to TRUE because the poles passed in to 
  * create this abstract buffer are same. So, we should set it externally.
  */
 line_crv.phy_closed = FALSE;
 for (i=0, prev_i=-1, next_i=1 ; i<res_num_comps; i++, prev_i++, next_i++)
   {
   if (table[i] == BSCVLINESTR && prev_i >= 0 && next_i <= res_num_comps-1 &&
       table[prev_i] >= 0 && table[next_i] >= 0 &&
       res_crvs[i]->num_poles == 3)
     {
     for (j=prev_i, k=0, l=FIRST; l<=SECOND; j=next_i, k+=3, l++)
       {
       if (off_code[table[j]] == BSPRESERVCVSHP ||
           off_code[table[j]] == BSLINVAROFF)
         continue;

       cv = res_crvs[j];
       num_poles = cv->num_poles + 2 + 2 * (cv->order-2);
       BSalloccv (cv->order, num_poles, cv->rational, 0, &newcv, &msg_loc);
       EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 
       /*
        * Move the poles and set the phy_closed property as this property is 
        * being set initially by some JUNK stuff.
        */
       OM_BLOCK_MOVE (&res_crvs[i]->poles[k], poles2, 2 * sizeof (IGRpoint));
       EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       
       BSmerge_cv (&msg_loc, cv, &line_crv, newcv);
       EMerr_hndlr (msg_loc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       BSreparmcv (newcv, 0.0, 1.0, newcv, &msg_loc);

       BSfreecv (&msg_loc, cv);
       res_crvs[j] = newcv;
       newcv = NULL;
       }
     table[i] = INVALID;
     }
   }


  const_list->geometry = NULL;
  off_crv_id->osnum = const_list->env_info->md_id.osnum;
  OM_stat = om$construct(osnum = off_crv_id->osnum,
			  classid = OPP_GRcompcurve_class_id,
			  p_objid = &off_crv_id->objid,
                          msg = message GRgraphics.GRconstruct(const_list));
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
/*
 * Reworked the below logic to trap degenerate curves created during
 * the offset process.  In such cases we should not create the curve.
 * In addition we need to keep up with the number of curves created
 * because if the total is 0 or 1 then we need to blow away the composite.
 * Also, if the table code shows INVALID, then do not create the curve.
 */
  total_curves_produced = 0;
  for (i = 0; i < res_num_comps; i++)
  {
   IGRboolean	is_degenerate;
   IGRlong	loc_msg;

   BStstcvdegn(
     res_crvs[i],
     &is_degenerate,
     &loc_msg);
    EMerr_hndlr(loc_msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
   if (! is_degenerate && table[i] != INVALID)
    {
     total_curves_produced++;
     if (table[i] < 0)
      {
       if (table[i] == BSCVLINE)
        new_classid = OPP_GR3dlineseg_class_id;
       else if (table[i] == BSCVLINESTR)
        new_classid = OPP_GR3dlinestr_class_id;
       else if (table[i] == BSCVCIRCARC) 
        new_classid = OPP_GR3dcirarc_class_id;
       else
         new_classid = OPP_GRbcsubbc_class_id;
      }
     else
      {
       OM_stat = om$get_classid(
         objid = compid[table[i]], 
         osnum = compos,
         p_classid = &comp_classid);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 
       if (off_code[table[i]] == BSPRESERVCVSHP)
        new_classid = comp_classid;
       else if (off_code[table[i]] == BSLINVAROFF) 
        new_classid = OPP_GRbcsubbc_class_id;
       else
        Local_off_classid(comp_classid, res_crvs[i], &new_classid);
      }
     OM_stat = om$construct(
       osnum = off_crv_id->osnum,
       classid = new_classid,
       p_objid = &new_compid);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 
     const_list->geometry = (IGRchar *) res_crvs[i];
     OM_stat = om$send(
       msg = message GRvg.GRconstruct(const_list),
       targetid = new_compid,
       targetos = off_crv_id->osnum);
      EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_OMerror,wrapup);
     stupid_index = i;
     OM_stat = om$send(
       msg = message GRconnector.GRrigidconn(
        EMmsg,
        off_crv_id,
        &stupid_index),
       targetid = new_compid,
       targetos = off_crv_id->osnum);
      EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 
     last_curve_offset = new_compid;
     new_compid = NULL_OBJID;		/* rlw 01/27/89 */
    } /* if (! is_degenerate) */
  } /* for (i = 0; i < res_num_comps; i++) */
/*
 * Post the abstract data
 */
 if (total_curves_produced > 1)
 {
  IGRchar	*geometry;
  GRobjid	new_id;
  struct	GRpost_info info;

  geometry = NULL;
  info.construct_flag = FALSE;
  OM_stat = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRpostabsg(
                    EMmsg,
                    const_list->env_info,
                    &info, 
                    geometry, 
                    &new_id),
                  senderid = my_id,
                  targetid = off_crv_id->objid,
                  targetos = off_crv_id->osnum);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 
 } /* if (total_curves_produced > 1) */
/*
 * Blow away the composite as it is no longer necessary
 */
 else
 {
  OM_stat = om$send(
    mode = OM_e_wrt_message,
    msg = message Root.delete(0),
    targetid = off_crv_id->objid,
    targetos = off_crv_id->osnum);
   EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup); 
  if (total_curves_produced)
   off_crv_id->objid = last_curve_offset;
  else
   {
    off_crv_id->objid = NULL_OBJID;
    *EMmsg = EMS_I_BSerror;
   }
 } /* ELSE FOR if (total_curves_produced > 1) */
/*
 * Free memory
 */
  for(i=0; i<res_num_comps; i++)
  {
    if (res_crvs[i]) BSfreecv (&rc, res_crvs[i]);
  }


wrapup:

   if (newcv)
     BSfreecv (&msg_loc, newcv);
/*
 * Make sure that any temporary curves are deleted if this
 * routine fails.  rlw 01/27/89
 */
 if (! (1 & *EMmsg))
  {
   IGRlong	sts, loc_msg;

   if (off_crv_id->objid != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       const_list->env_info),
      targetid = off_crv_id->objid,
      targetos = off_crv_id->osnum);
     off_crv_id->objid = NULL_OBJID;
    }
   if (new_compid != NULL_OBJID)
    {
     sts = om$send(
      msg = message GRgraphics.GRdelete(
       &loc_msg,
       const_list->env_info),
      targetid = new_compid,
      targetos = off_crv_id->osnum);
    }
  } /* if (! (1 & *EMmsg) */

  /* dealloc dumb loops just in case math returned loops */
  /* NO!!! read header for BScmpcvoff... TR119313209. Carlos.
  for(i=0; i<dum_num_loops; i++)
  {
    if (dum_loops && dum_loops[i]) 
    	BSfreecv(&rc, dum_loops[i]);
  }
  */ 
  if (dum_loops) om$dealloc(ptr = dum_loops);
  if (dum_loop_table) om$dealloc(ptr = dum_loop_table);

  for(i=0; i<num_comps; i++)
  {
    if (crvs[i]) om$dealloc(ptr = crvs[i]);
  }
  if (table) om$dealloc(ptr = table);
  if (compid) om$dealloc(ptr = compid);
  if (crvs) om$dealloc (ptr = crvs);
  if (res_crvs) om$dealloc (ptr = res_crvs);

  EMWRAPUP(*EMmsg, OM_stat, "In GRcompcurve.EMoffset")
  return(OM_stat);
}

/*
 * This function checks the direction of paramterization of the components
 * of a composite curve, and changes it as that of the first component in 
 * erratic cases
 */
int check_parameterization(int n_comps,struct IGRbsp_curve **curves)
{
  int i,num_pars=1;
  BSrc rc;
  IGRint retFlag = FALSE;
  double   bastol= 0.0, chtol= 0.0;
  double   dist = 0.0,par=0.0;
  IGRpoint pt1,pt2;
  IGRboolean ret_type = FALSE;
  
  BSxtractpar( &rc, BSTOLBASIS, &bastol );
  BSxtractpar( &rc, BSTOLCHRDHT, &chtol );
  
  for(i=0;i<n_comps;i++)
  {
    if(i==0) continue; // avoid the first component for reference
    
    par = 1.0; // end point of the previous component
    BScvarrev0(&rc,curves[i-1],&par,num_pars,pt1);
    if ( BSSUCC != rc ) goto wrapup;
    par = 0.0; // start point of this component
    BScvarrev0(&rc,curves[i],&par,num_pars,pt2);
    if ( BSSUCC != rc ) goto wrapup;
    
    // Find the distance between the two points - to be within tolerance
    // for continuity in parameterization
    
    dist = BSdistptpt( &rc, pt1, pt2 );
    if ( BSSUCC != rc ) goto wrapup;
    
    if(dist>(2*chtol)) ret_type = BSrev_cv(&rc,curves[i]); 
    if ( BSSUCC != rc ) goto wrapup;
    
  }
  retFlag = TRUE;
 wrapup:
  return retFlag;
}
end implementation GRcompcurve;

