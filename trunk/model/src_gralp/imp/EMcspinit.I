/* ###################   APOGEE COMPILED   ################## */
class implementation EMScusp;

/*
History

    AIC  08 Oct 1990 Genesis
    AIC  08 Nov 1990 Added edge based rule lines
    Jack 30 Apr 1991 Modified for 2.0.1 Horizon Loops.
    Jack 28 May 1991 Removed code for pulling out non-cusp
                     rule lines.
    Jack 21 Aug 1991 Added code to delete me(the cusp object)
                     if there are no edges for it.
    Jack 15 Oct 1991 Moved call to get surface partolbasis and sent
                     it as a new parm to EMScusp.EMput_rule_lines.
    Sudha 25-Jun-93  Modified for BSprototype ansification

Notes

    "sender_id" must be surface id to get correct edge types.
*/

#include "emsedgedef.h"
#include "msdef.h"
#include "dperr.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsfndsfcsp.h"

#define BUFSIZE 100



method EMinit_cusp( struct IGRbsp_surface   *surface;
                     OM_S_OBJID               surface_id;
                     IGRshort                *matrix_type;
                     IGRdouble               *matrix)               


{
  IGRint                   usize, 
                           vsize;
  IGRlong                  rc;
  IGRlong                  sts = OM_S_SUCCESS, 
                           EMmsg = EMS_S_Success;
  IGRdouble                darray[BUFSIZE], 
                          *dptr = NULL;
  struct IGResqbs          cusps_buffer, 
                          *cusps, 
                          *rule_lines = NULL;
  struct EMSpartolbasis    partolbasis;
  IGRdouble                parametric_tolerance;

  void                     EFgetRuleLineTable();


  cusps = &cusps_buffer;
  usize = surface->u_num_poles - surface->u_order + 1;
  vsize = surface->v_num_poles - surface->v_order + 1;

  if(usize + vsize <= BUFSIZE) dptr = darray;
  else
  {
    dptr = (double *) om$malloc(size = (usize + vsize) * sizeof(double));
    if(! dptr) { EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
  }

  cusps->u_rule_values = dptr;
  cusps->v_rule_values = dptr + usize;
  BSfndsfcsp(surface, (IGRint *)&cusps->u_rules, cusps->u_rule_values,
             (IGRint *)&cusps->v_rules, cusps->v_rule_values, &rc);

  /* Get the parametric tolerance for this surface.
   */
  sts = EFsspbtol_by_geom(&EMmsg, surface, &parametric_tolerance);
  EMerr_hndlr(!(1 & EMmsg & sts),EMmsg,EMS_E_Fail,wrapup);
  
  partolbasis.tol = parametric_tolerance;
  partolbasis.in_world = TRUE;
  partolbasis.is_valid = TRUE;
  partolbasis.mattyp = matrix_type;
  partolbasis.mat = matrix;


  if(cusps->u_rules || cusps->v_rules)
   {
    sts = om$send(msg = message EMScusp.EMput_rule_lines(
                                        cusps, 
                                        TRUE, 
                                        surface_id,
                                       &partolbasis),
                  targetid = my_id);
    if(! (1 & sts)) goto wrapup;
   }
  else
   {
    /* delete the cusp object */  
    om$send(msg      = message Root.delete(1),
            targetid = my_id,
            targetos = OM_Gw_current_OS);

    if(! (1 & sts)) goto wrapup;

    sts = 0; /* set status to 0 so upon return we know that the cusp
                has been deleted */
    goto wrapup;            
     
   }

       
  /*
   * Initialize the feature loop data.
   */
  sts = om$send(msg = message EMSgraloop.EMglpinit(
                                        &EMmsg, 
                                         EMLP_ACTIVE, 
                                        &partolbasis,
                                         sender_id),
                targetid = my_id);
  if(! (1 & sts)) goto wrapup;

  /*
   * Update the features against the boundaries
   */
  sts = om$send(msg = message EMSgraloop.EMupdate_feature(
                                          &EMmsg, 
                                           matrix_type,
                                           matrix),
                targetid = my_id);


wrapup:
  if(dptr && (dptr != darray)) om$dealloc(ptr = dptr);
  if(rule_lines) om$dealloc(ptr = rule_lines);

  if(sts != 0)
    EMWRAPUP(EMmsg, sts, "EMScusp.EMinit_cusp")

  return sts;
}


end implementation EMScusp;
