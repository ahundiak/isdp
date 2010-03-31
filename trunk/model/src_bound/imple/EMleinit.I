/* ###################   APOGEE COMPILED   ################## */
/*
 * Note: Options used by this method ('EMSleinit_**') are defined in
 * EMSopt.h
 * If NULL is passed for input polyline, the edge is assumed to be
 * existing and iso check is performed in addition to initializing props
 * curve type and closure test (unless some functions are supressed using
 * the relevant options).
 *
 * History :
 *   SM  : Long Ago             Creation.
 *   SM  : 31-Oct-87            Put the curve type on the argument list so
 *                              that the caller has control over it.
 *   PP  : 05/29/87             Changed the method so that a curve type is
 *                              stored too.
 *   SM  : 06/22/87             Modified to set the EMED_XYZ_CLOSED bit
 *                              ON if the edge is closed in UV.
 *   RV  : 15-Aug-88            Modified to set the property EMED_ISO and
 *                              store only two points if applicable.
 *   SM  : 23-Sep-88            If creating iso edge and curve type is 
 *                              EMlinestring, make it EMfreeform_curve.
 *   SM  : 28-Sep-88            If converting an existing linear edge ino
 *                              iso edge, update its partedges if any.
 *                              Added options to supress initialization of
 *                              props, curve type and closure test. Also
 *                              modified such that NULL can be passed for
 *                              input geometry, in which case the edge is
 *                              assumed to be existing and is given a chance
 *                              to become iso.
 *  SM  : 04-Oct-88             Support option EMSleinit_SnapToUvLimits.
 *  SS  : 10-Apr-89             Check/maintain integrity of curve-type.
 *  SM  : 13-Sep-89             Added argument sfid. This is used to get
 *                              proper curve_type when linedge is iso.
 *  SM  : 26-Sep-89             Call function EFisEdgeTypeLinear for making
                                a decision about iso edge's curve type. As
                                a general rule iso edges will not have linear
                                curve type. 
 */

class implementation EMSlinedge;

#include "EMS.h"
#include "OMmacros.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "emsdef.h"
%safe
#include <math.h>
%endsafe

#define UPPER_BOUND     4
#define LOWER_BOUND     4
#define LOCAL_BUF       300

#ifndef DEBUG
#define DEBUG   0
#endif

from EMSpartedge import EMchange_bounds;

method EMleinit (IGRlong *EMmsg; IGRushort ed_props;
                 IGRuchar curve_type;
                 struct IGRpolyline *poly;struct EMSpartolbasis *partolbasis;
                 IGRushort option; GRobjid sfid)
{
  IGRint                sts, vla_size;
  IGRlong               rc;
  IGRboolean            EMis_iso_edge(), EFextract_par(), is_iso, 
                        existing_edge = FALSE, input_geom = TRUE, 
                        came_in_as_iso = FALSE;
  IGRdouble             partollen, *iso_points = NULL, iso_buf[4], 
                        local_buf[LOCAL_BUF];
  struct IGRpolyline    loc_poly;
  IGRint                EMsend_partedges();
  IGRboolean            EFget_new_linear_edge_type();
  extern IGRboolean     EFisEdgeTypeLinear();
  extern OM_S_OBJID     current_creator;


  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  is_iso = FALSE;
  existing_edge = ME.EMSlinedge->num_points ? TRUE : FALSE;
  loc_poly.points = NULL;

  ME.EMSboundary->creator_id = current_creator;

  if(!poly)
   {
    EMerr_hndlr(!ME.EMSlinedge->num_points, *EMmsg, EMS_E_InvalidArg, wrapup);
    if(ME.EMSlinedge->num_points < LinearToIsoWaterMark)
     {
      *EMmsg = EMS_I_Useless;
      goto wrapup;
     }
    loc_poly.num_points = ME.EMSlinedge->num_points;
    
    if(loc_poly.num_points * 2 > LOCAL_BUF)
     loc_poly.points = (IGRdouble *) om$malloc(size = 2 * sizeof(IGRdouble) *
                                        loc_poly.num_points);
    else loc_poly.points = local_buf;
    EMerr_hndlr(!loc_poly.points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    OM_BLOCK_MOVE(ME.EMSlinedge->points, loc_poly.points, 2 * sizeof(IGRdouble)
                                                * loc_poly.num_points);
    poly = (struct IGRpolyline *) &loc_poly;
    input_geom = FALSE;
   }


  /*
   * Initialize the edge properties.
   */
    if(!(option & EMSleinit_IgnoreProps))
     ME.EMSedge->ed_props = ed_props;
    if(!(option & EMSleinit_IgnoreCurveType))
     {
     if (input_geom)
       EFget_new_linear_edge_type (curve_type, poly->num_points, &curve_type);
     ME.EMSedge->curve_type = curve_type;
     }

  /* If the parametric tolerance passed in is not valid go get it.*/

  if(!partolbasis->is_valid || IF_NULL_OBJID(sfid))
   {
     sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg,
                        IF_NULL_OBJID(sfid) ? &sfid : NULL,
                        partolbasis->is_valid ? NULL : partolbasis),
                targetid=my_id);
     EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }
  sts = EFextract_par(BSTOLLENVEC,partolbasis->tol,&partollen,&rc);

  
  if(option & EMSleinit_SnapToUvLimits)
   {
    IGRint      i;

    for(i=0; i< 2 * poly->num_points; i+=2)
     {
      if(fabs(poly->points[i] -Ulow) < partollen) poly->points[i] = Ulow;
      if(fabs(poly->points[i] -Uhigh) < partollen) poly->points[i] = Uhigh;
      if(fabs(poly->points[i+1] -Vlow) < partollen) poly->points[i+1] = Vlow;
      if(fabs(poly->points[i+1] -Vhigh) < partollen) poly->points[i+1] = Vhigh;
     }
   }


  if (! (option & EMSleinit_NoIsoCheck))
   {
    if (ed_props & EMED_ISO)
     {
      came_in_as_iso = TRUE;
      if (is_iso = EMis_iso_edge(poly->num_points, poly->points, 
                                partollen, iso_buf))
       iso_points = iso_buf;
      else
       {
          /* Caller THINKS his data is ISO (because EMED_ISO is passed in). Yet,
           * he is not 100% sure and wants the method to check it. If it is not
           * ISO then error out.
           */
          *EMmsg = EMS_E_InvalidArg; goto wrapup;
       }
     }
    else if (poly->num_points > LinearToIsoWaterMark)
     {
      if (is_iso = EMis_iso_edge(poly->num_points, poly->points, 
                                partollen, iso_buf))
       iso_points = iso_buf;
     }   
   }    /* if make checks */
  else
   {
    if (ed_props & EMED_ISO)
     {
      came_in_as_iso = TRUE;
      if (poly->num_points > 2) 
      {  is_iso =EMis_iso_edge(poly->num_points,poly->points,partollen,iso_buf);
         if (is_iso)
           iso_points = iso_buf;
      }
      else if (poly->num_points == 2)
      {  /* BELIEVE the caller when he/she says edge is ISO, especially since 
          * the "EMSleinit_NoIsoCheck" option is passed in.
          */
         is_iso = TRUE; 
         iso_points = iso_buf;
         OM_BLOCK_MOVE(poly->points, iso_buf, 4 * sizeof (IGRdouble));
      }
      else
        {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
     }     
   }

  /*
   * Store the edge geometry as instance data.
   */

   if (is_iso)
   {
    ME.EMSlinedge->num_points = 2;
    ME.EMSedge->ed_props |= EMED_ISO;
    if ((vla_size = om$dimension_of (varray = ME.EMSlinedge->points)) >
                                        UPPER_BOUND)
      om$vla_set_dimension (varray = ME.EMSlinedge->points,size = LOWER_BOUND);

    else if ((vla_size = om$dimension_of (varray = ME.EMSlinedge->points)) <
                                        LOWER_BOUND)
      om$vla_set_dimension (varray = ME.EMSlinedge->points,size = LOWER_BOUND);

    OM_BLOCK_MOVE (iso_points, ME.EMSlinedge->points, 4 * sizeof (IGRdouble));

    /* Try to set a meaningful edge type for the iso edge, if possible.
     * If the isoness was predetermined, by the caller, leave the edge type
     * alone.
    */
        
    if(!came_in_as_iso && EFisEdgeTypeLinear(ME.EMSedge->curve_type))
     {
      IGRuchar  cvtype;
        
      cvtype = EMfreeform_curve;

      /* In case of any problem cvtype will remain EMfreeform_curve.
      */
      sts = om$send(msg = message EMSlinedge.EMsetIsoType(EMmsg, sfid, 
                                &cvtype, NULL, NULL, FALSE), 
                                targetid = my_id);

      ME.EMSedge->curve_type = cvtype;
      *EMmsg = EMS_S_Success;
      sts = OM_S_SUCCESS;

     }

   }
   else if(input_geom)
   {
      ME.EMSlinedge->num_points = poly->num_points;
      ME.EMSedge->ed_props &= ~EMED_ISO;

      if ((vla_size = om$dimension_of (varray = ME.EMSlinedge->points)) < 
                                2*poly->num_points)
         om$vla_set_dimension (varray = ME.EMSlinedge->points, 
                                size = vla_size+2*poly->num_points);
      OM_BLOCK_MOVE (poly->points, ME.EMSlinedge->points, 
                                poly->num_points * 2 * sizeof (IGRdouble));
   }

   /* See if the edge is closed */

   if(!(option & EMSleinit_NoClosureCheck))
   {
     IGRdouble          *junk;
     IGRint             num;

     junk = (IGRdouble *) ME.EMSlinedge->points;
     num = ME.EMSlinedge->num_points;

     if(EM2ddistptpt(junk, &junk[ 2 * num - 2 ] ) < partollen)
      {
       ME.EMSedge->ed_props &= ~EMED_OPEN;
       ME.EMSedge->ed_props |= EMED_XYZ_CLOSED;
      }
     else 
       ME.EMSedge->ed_props |= EMED_OPEN;
   }

  if(existing_edge && is_iso)
   {
    struct IGRpolyline remove_poly, new_geom;
    IGRint before_ptinx = poly->num_points - 1;
    IGRuchar new_pe_curve_type;

    sts = EFget_clipped_edge_type(EMmsg, ME.EMSedge->curve_type, 
                                        &new_pe_curve_type);
    remove_poly.num_points = poly->num_points - 2;
    remove_poly.points = &poly->points[2];
    new_geom.num_points = ME.EMSlinedge->num_points;
    new_geom.points = ME.EMSlinedge->points;

    sts = EMsend_partedges(&rc, message EMSpartedge.EMchange_bounds
                (EMmsg, before_ptinx, NULL, &remove_poly, 
                 &new_geom, &new_pe_curve_type, NULL, 
                 &ME.EMSedge->ed_props, TRUE, NULL, partolbasis), 
                my_id, 0, MAXINT, NULL, NULL, NULL);
   }

wrapup:

  if(loc_poly.points && (loc_poly.points != local_buf))
   om$dealloc(ptr = loc_poly.points);
  EMWRAPUP(*EMmsg,sts,"In EMSlinedge.EMleinit");
  return (sts);
}

end implementation EMSlinedge;
