/* $Id: EMcsMassProp.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */
/***************************************************************************
* I/VDS
*
* File: emsfixes/model/EMcsMassProp.I
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: EMcsMassProp.I,v $
*      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
*      Initial import to CVS
*
# Revision 1.2  2000/02/10  17:13:32  pinnacle
# Replaced: emsfixes/model/EMcsMassProp.I for:  by impd252 for vds
#
# Revision 1.1  2000/02/08  17:33:14  pinnacle
# initial revision
#
# Revision 1.1  2000/01/04  08:33:16  pinnacle
*
* History:
*      	MM/DD/YY  AUTHOR  	DESCRIPTION
*	02/08/00  Rama Rao	TR#179901004 - Changed the active bastol 0.001
*				and later restored to the original value.
***************************************************************************/

/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

//  %safe
//  #include <math.h>
//  %endsafe

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmass.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "EMSopt.h"
#include <stdio.h>
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "maidmx.h"
#include "bseig3x3.h"
#include "bsdistptpt.h"

#define TILE_FAC 100

extern OMuword OPP_EMSsolid_class_id;
/* Start VDS correction - Rama Rao 02/02/2000 */
#include "vdprdmacros.h"
extern char EX_runname[];
/* End VDS correction - Rama Rao 02/02/2000 */

from EMSmassprop import EMretn_mass_prop,
			EMstore_geometry,
                        EMupdate_orient,
                        EMrefxform,
                        EMget_objectid,
                        EMload_mass_prop;

method EMmassprop(IGRlong           *msg;
                  IGRint            num_surfaces;
                  IGRdouble         sld_range;
                  struct GRmd_env   *my_env;
        		  IGRdouble	        scaling_factor;
		          IGRvector	        trans_vector;
		          IGRdouble	        *density;
		          IGRdouble	        *mass_int)
/*
Descrpition
	If the composite is closed this method returns the mass
	properties

History:
	gk	11/12/87	the begining
	gk	3/17/88		compute mass props of cs that are
                    not closed too!
    pp  11/01/88    Moving the solid to the area centroid before
                    computing mass properties to minimise the
                    errors due to gaps and non-triangular facets
                    generated due to boundaries on non-planar
                    surfaces
    gupta 07/19/89  Changed for associativity .. etc
    Sudha 06/28/93  Modified for BSprototype ansification

*/

{
  BSrc              rc;
  IGRlong	    stat_OM, option, i;
  IGRint            surf_index;
  IGRdouble	    loc_sf[NUMB_PROPS], loc_mass[NUMB_PROPS];
  IGRdouble         eig_matrix[3][3];
  IGRdouble         dest_glo_loc[9];
  IGRdouble         tol, negtol, savedtol;
  extern IGRboolean IGEstop();
  void              MSsftoms(), MSaccprop();
  OMuword           myclass_id;
  OM_S_CHANSELECT   notify_chan;
  struct GRmd_env   loc_md_env;
  struct GRid       mass_prop_obj;
  IGRboolean        new_tile, validity, not_closed;
  IGRboolean        interrupt= FALSE, mod_tol=FALSE;
  char              *prod = NULL;
  static IGRdouble  identity_matrix[9] = { 1.0,  0.0,  0.0, 
                                           0.0,  1.0,  0.0, 
                                           0.0,  0.0,  1.0 };
  static IGRdouble  zero_origin[3] = {0.0, 0.0, 0.0};

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  option = 0;		/* mass properties */
  new_tile = FALSE;

  /*
   * Do I have a massprop object associated with me?
   * If so, then retrieve the properties and quit
   */

  stat_OM = om$make_chanselect(channame = "GRnotify.notification",
                               p_chanselect = &notify_chan);
  if (! (1 & stat_OM)) goto wrapup;

  validity = FALSE;
  stat_OM = om$send(msg = message EMSmassprop.EMretn_mass_prop(msg, 
                          &validity, loc_mass),
                    p_chanselect = &notify_chan,
                    from = 0,
                    to = 100000);

  if(stat_OM && validity) /* object found */
   {
     MSaccprop(loc_mass, mass_int);
     return(OM_S_SUCCESS);
   }

  /* No mass prop object; Crunch dutifully */

  /*
   * Is my ancestor a solid. Then continue.
   * Else make sure that I have no 'connectable' edges
   */

/* Start VDS correction - Rama Rao 02/02/2000 */
  prod = EX_runname;
  if (  (    !strcmp ( prod, VD_PROD_NAME_VDS )
         ||  !strcmp ( prod, VD_PROD_NAME_ROUTE )
         ||  !strcmp ( prod, VD_PROD_NAME_STRUCT )
         ||  !strcmp ( prod, VD_PROD_NAME_LOFT )   ) )
  {
     IGRdouble   bastol;
     BSxtractpar ( &rc, BSTOLBASIS, &bastol);
     if(  bastol < 0.001 )
     {
        savedtol = bastol;
        BSchgdeppar(0.001, &rc);
        mod_tol = TRUE ;
     }
  }
/* End VDS correction - Rama Rao 02/02/2000 */

  BSEXTRACTPAR(msg, BSTOLBASIS, tol);
  tol *= 5.0;
  negtol = -tol;

  stat_OM = om$get_classid(object = me,
                           p_classid = &myclass_id);
  if(EMSmsgReport(stat_OM, "EMcsmassprop: myclass id", FALSE))goto wrapup;

  stat_OM = om$is_ancestry_valid(subclassid = myclass_id,
				superclassid = OPP_EMSsolid_class_id);

  not_closed = FALSE;

  if(stat_OM IS OM_S_SUCCESS)	/* I am a solid child */
   {
    /* Do nothing here */
   }
  else if(stat_OM IS OM_I_INVANCESTRY) /* just composite surface child */
   {
    struct GRid     *edges = NULL;
    GRobjid	        *surf_list = NULL;
    IGRint          buf_size  = 0, num_edges   = 0,
                    list_size = 0, num_in_list = 0,
		    *numed_list = NULL;
    IGRlong         stat_OM1;

    stat_OM1 = om$send(msg = message EMSsurface.EMgetedges(msg,
                             EMS_OPT_CONNECTABLE, &edges, &buf_size,
                             &num_edges, &surf_list, &numed_list,
                             &list_size, &num_in_list), 
                       targetid = my_id);

    if( edges )	om$dealloc( ptr = edges );
    if( surf_list )	om$dealloc( ptr = surf_list );
    if( numed_list )	om$dealloc( ptr = numed_list );

    if (EMSmsgReport(stat_OM1, "EMcsmassprop: get edges", FALSE))
                     goto wrapup;

    if(num_edges)	/* non zero connectable edges */
     {
      ex$message(field = ERROR_FIELD, msgnumb = EMS_E_CompSNotClosed)
      ex$message(field = PROMPT_FIELD, msgnumb = EMS_I_WarnSfNotClosedCont)
      not_closed = TRUE;
     }
   }
  if (EMSmsgReport (stat_OM, "EMcsmassprop: valid ancestry", FALSE))
      goto wrapup;

  /*
      At this point we have one of the following;
      i. solid  ii. solid modification  iii. closed composite surface
      3/17/88   GK;
      composite surface may not be closed but compute the mass props
      anyway. CS may not be closed due to minute tolerancing problems.
      So do not penalize the user/benchmarker for that. But a smart
      alec intentionally using this Achilles heel will be rewarded with
      screwed up numbers. "Garbage in garbage out"
  */

/* begin pp */

/* First calculate the properties based on an identity matrix, and load
 * the same. Thereafter transform the properties based on incoming matrix.
 */


  loc_md_env = *my_env;
  
  loc_md_env.md_env.matrix_type = MAIDMX;
  MAidmx(msg,loc_md_env.md_env.matrix);

/* end pp (02/17/90) */

  for(i = 0; i < NUMB_PROPS; i++) loc_sf[i] = 0.0;

  stat_OM = om$send(msg = message EMSsurface.EMareaprop(msg, FALSE,
                          num_surfaces, &loc_md_env, scaling_factor,
                          trans_vector, loc_sf),
                    targetid = my_id);
  if ((*msg == EMS_I_Interrupt) || ((interrupt = IGEstop())))
   {
    *msg = EMS_I_Interrupt; return (OM_S_SUCCESS);
   }
  if (EMSmsgReport (stat_OM, "EMcsfaceint: EMfaceintgrl", FALSE))
                    goto wrapup;

  trans_vector[0] = loc_sf[2];
  trans_vector[1] = loc_sf[3];
  trans_vector[2] = loc_sf[4];

  /* using the new tiler only if centroid is at a distance greater
     than TILE_FAC times the max range of the solid. This is being
     done for the new tiler is relatively slower */

  if (BSdistptpt(msg, zero_origin, &loc_sf[2]) >= TILE_FAC * sld_range)
      new_tile = TRUE;

  surf_index = 0;
  for(i = 0; i < NUMB_PROPS; i++) loc_sf[i] = 0.0;

  stat_OM = om$send(msg = message EMSsurface.EMfaceintgrl(msg,
                          TRUE, new_tile, &surf_index, num_surfaces,
                          &loc_md_env, NULL, scaling_factor, trans_vector,
                          NULL, option, density, loc_sf),
                    targetid = my_id);
  if ((*msg == EMS_I_Interrupt) || ((interrupt = IGEstop())))
   {
    *msg = EMS_I_Interrupt; return (OM_S_SUCCESS);
   }

  if (EMSmsgReport (stat_OM, "EMcsfaceint: EMfaceintgrl", FALSE))
                    goto wrapup;

  if (loc_sf[0] < 0.0) 	/* normals screwed up */
   {
    fprintf(stderr, "Total volume is negative \n");
    for(i=0; i<11; i++) loc_sf[i] *= -1.0;
   }

  if (loc_sf[11] < 0.0) 
   {
    loc_sf[11] *= -1.0;
    fprintf (stderr,"Total surface area is negative \n");
   }

  MSsftoms(trans_vector, scaling_factor, loc_sf, loc_mass);
  MSaccprop(loc_mass, mass_int);

  stat_OM = om$send(msg = message EMSmassprop.EMget_objectid(msg,
                          &mass_prop_obj),
                    p_chanselect = &notify_chan,
                    from = 0,
                    to = 100000);

  /* send it load message */

  for (i=0; i<9; i++) dest_glo_loc[i] = identity_matrix[i];

  eig_matrix[0][0] =  mass_int[5];
  eig_matrix[0][1] = -mass_int[8];
  eig_matrix[0][2] = -mass_int[10];

  eig_matrix[1][0] = -mass_int[8];
  eig_matrix[1][1] =  mass_int[6];
  eig_matrix[1][2] = -mass_int[9];

  eig_matrix[2][0] = -mass_int[10];
  eig_matrix[2][1] = -mass_int[9];
  eig_matrix[2][2] =  mass_int[7];

  BSeig3x3 (eig_matrix, (IGRint *)&stat_OM, &mass_int[5], (IGRvector *)dest_glo_loc, msg);

  mass_int[8] = 0.0;
  mass_int[9] = 0.0;
  mass_int[10] = 0.0;

  stat_OM = om$send(msg = message EMSmassprop.EMload_mass_prop(msg, 
                          TRUE, mass_int),
                    targetid = mass_prop_obj.objid);
  if (EMSmsgReport (stat_OM, "EMcsfaceint: mass prop load", FALSE))
                    goto wrapup;

  for (i=0; i<9; i++)
   {
    if ((dest_glo_loc[i] <= tol) && (dest_glo_loc[i] >= negtol))
         dest_glo_loc[i] = 0.0;
   }
/*
 * begin pp 
 * transform the orientation matrix into one suitable for reference files.
 */

  stat_OM = om$send(msg = message EMSmassprop.EMupdate_orient(msg,
                          dest_glo_loc),
                    targetid = mass_prop_obj.objid,
                    targetos = mass_prop_obj.osnum);
  if (EMSmsgReport (stat_OM, "EMcsfaceint: update orient", FALSE))
                    goto wrapup;

/* begin pp */

   if (my_env->md_env.matrix_type != MAIDMX)
   {
    IGRdouble ref_point[3];
    IGRboolean validity;
    IGRdouble  in_glo_loc[9];
    
    for (i=0; i<NUMB_PROPS; i++) mass_int[i] = 0.0;

/*
 * Fudge.
 */

    stat_OM = om$send(msg = message EMSmassprop.EMstore_geometry(msg,
                           dest_glo_loc),
                     targetos = mass_prop_obj.osnum,
                     targetid = mass_prop_obj.objid);
    if (! (1 & stat_OM & *msg)) goto wrapup;

    stat_OM = om$send(msg = message EMSmassprop.EMrefxform(msg,
                          my_env,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix,
                          ref_point, mass_int,
                          in_glo_loc,
                          &validity),
                       targetid = mass_prop_obj.objid,
                       targetos = mass_prop_obj.osnum);
    if (EMSmsgReport (stat_OM,"EMssfaceint: massprop refxform",FALSE))
       goto wrapup;
    if (!validity)
    {
      *msg = EMS_E_Fail;
      stat_OM = OM_E_ABORT;
      goto wrapup;
    }
   }
/* end pp (02/17/90) */
  if(not_closed) mass_int[13] = -5.0;	/* signal to command object */

wrapup:
/* Start VDS correction - Rama Rao 02/02/2000 */
  if (mod_tol) BSchgdeppar(savedtol, &rc);
/* End VDS correction - Rama Rao 02/02/2000 */

 if (! (1 & stat_OM & *msg))
  *msg = EMS_E_Fail;
 else
  *msg = EMS_S_Success; 
  return(stat_OM);
}

end implementation EMScompsurf;

