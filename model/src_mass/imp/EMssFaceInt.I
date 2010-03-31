/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include <stdio.h>
#include "emsmass.h"
#include "wanginc.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "EMSlogic.h"
#include "EMScmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#include "PWminimum.h"
#include "PWapi/partol.h"

#define MASS_PROPS 0
#define SURF_PROPS 1
#define AREA_ONLY  2

%safe
static void CorrectBdryPts(struct IGRbsp_surface *, IGRdouble);
%endsafe

method EMfaceintgrl(IGRlong               *msg;
                    IGRboolean            want_status;
                    IGRboolean            new_tiler;
                    IGRint                *surf_inx;
                    IGRint                num_surfaces;
                    struct GRmd_env       *my_env;
                    struct IGRbsp_surface *surf_in;
                    IGRdouble             scaling_factor;
                    IGRvector             trans_vector;
                    IGRdouble             *tran_mat;
                    IGRlong               option;
                    IGRdouble             *density;
                    IGRdouble             *out_int)
/*
Description
	This method returns surface integral contributions of faces
	towards mass properties or area properties based on the option.

Return values
	EMS_S_Success if all's well
Notes

History
        Nilesh 1/30/97          Corrected boundary points when the points 
                                were less than sftol, to avoid inconsistency
                                in Mass Property evaluation when the points
                                varied in this order.

        PP  01/10/89            Corrected Allen's change to pass in
                                mattyp and mat instead of passing in
                                NULL.
        AIC	12 Oct 1988	        Added matrix and type arguments
                                to EMget_boundaries message.
	    gk	3/8/88              reduce the number of points in a boundary
                                if they are collinear
        gk  1/12/88	            total redesign
        gk  11/11/87            Design date

*/

{
  IGRlong                stat_OM, mysize, i, j, numb_poles, bsmsg,rc;
  IGRdouble              scaling_less_1, tol, scratch, scratch1, vect[3],
                         sfuvtol,sftol_basis,prop[NUMB_PROPS];
  struct IGRbsp_surface  *surf=NULL;
 
  extern  IGRboolean     BNsb_fsd();
  extern  IGRboolean     BNsb_fct();
  extern  IGRboolean     BNsb_fsd();
  IGRboolean             flat_check,
                         log_status;
  IGRchar                display_string[40];
  struct BNsf_data       *surf_data;
  struct IGRbsp_bdry_pts *bdry_ptr;
  struct GRid            my_GRid;
  void                   MSfacetint(), MSreduce();

  /* Initialize */

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (! num_surfaces) num_surfaces = 1;

  if (want_status)
   {
    int junk;

    junk = ++(*surf_inx);
    ex$message(msgnumb = EMS_I_ProcessingSfOfSf, type = "%d%d", 
               var = `junk, num_surfaces`, 
               buff = display_string);
    /******************
    sprintf(display_string, "Processing Surface #%d / %d",
            ++(*surf_inx), num_surfaces );
    ******************/
   }
  else
   {
    ex$message(msgnumb = EMS_I_PreProcessing, buff = display_string);
    /*sprintf(display_string, "PreProcessing....");*/
   }
  ex$message(in_buff = display_string, field = ERROR_FIELD);

  /* Get my geometry, if need be */

  if(surf_in)
   {
    surf = (struct IGRbsp_surface *)surf_in;
   }
  else
   {
    stat_OM = om$send(msg = message GRvg.GRgetsize(msg,
                           &my_env->md_env.matrix_type,
                           my_env->md_env.matrix,
                           &mysize),
                     targetid = my_id);
    if (EMSmsgReport (stat_OM, "EMssfaceint: getsiz error", FALSE))
                      goto wrapup;

    surf = (struct IGRbsp_surface *)om$malloc(size = mysize);
    if(!surf)
     {
      *msg = EMS_E_NoDynamicMemory;
      stat_OM = OM_E_ABORT;
      goto wrapup;
     }
    stat_OM = om$send(msg = message GRvg.GRgetgeom(msg,
                           &my_env->md_env.matrix_type,
                           my_env->md_env.matrix,
                           ( IGRchar * )surf),
                     targetid = my_id);
    if (EMSmsgReport (stat_OM,"EMssfaceint: get geom error", FALSE))
                      goto wrapup;
   }

  numb_poles = surf->u_num_poles * surf->v_num_poles;

  /* Translate and scale if need be */

  if (trans_vector)
   {
    j = 0;
    for(i=0; i<numb_poles; i++)
     {
	  scratch1 = (surf->rational) ? (surf->weights[i]) : (1.0);

      surf->poles[j] -= (trans_vector[0] * scratch1);
	  j++;

      surf->poles[j] -= (trans_vector[1] * scratch1);
      j++;

      surf->poles[j] -= (trans_vector[2] * scratch1);
      j++;
     }
   }

  BSEXTRACTPAR (&bsmsg, BSTOLCLOSETOZERO, tol);
  scratch = 1.0 - scaling_factor;
  scaling_less_1 = (scratch >= 0.0) ? (scratch) : (-scratch);
  if (scaling_less_1 > tol)	/* not 1 */
   {
    for(i=0; i<3*numb_poles; i++) surf->poles[i] /= scaling_factor;
   }

  if(tran_mat)	/* one more transformation needed */
   {
    j = 0;
    for(i=0; i<numb_poles; i++)
     {
	  vect[0] = surf->poles[j];
	  vect[1] = surf->poles[j+1];
	  vect[2] = surf->poles[j+2];

      surf->poles[j]   = tran_mat[0]*vect[0] +
                         tran_mat[1]*vect[1] +
                         tran_mat[2]*vect[2];

      surf->poles[j+1] = tran_mat[3]*vect[0] +
                         tran_mat[4]*vect[1] +
                         tran_mat[5]*vect[2];

      surf->poles[j+2] = tran_mat[6]*vect[0] +	/* should be 0 */
                         tran_mat[7]*vect[1] +
                         tran_mat[8]*vect[2];

      j += 3;
     }
   }  /* if tran_mat */

  /* Load all the boundaries of the surface */

  stat_OM = om$send(msg = message EMSsubbs.EMget_boundaries(msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix,
                         &surf->on_off, &surf->num_boundaries, 
                         &surf->bdrys),
                   targetid = my_id);
  if (EMSmsgReport (stat_OM, "EMssfaceint: load bnd", FALSE)) goto wrapup;

  for (i=0; i<NUMB_PROPS; i++) prop[i] = 0.0;

  if (surf->num_boundaries)
   {
    ex$message(msgnumb = EMS_I_Processing, field = PROMPT_FIELD)

    /*   Reduce the number of points in the boundary, if possible */
    /*

    BSEXTRACTPAR(&bsmsg, BSTOLPARAM, tol);
    for (i=0; i<surf->num_boundaries; i++)
     {
      bdry_ptr = (struct IGRbsp_bdry_pts *)&surf->bdrys[i];

      MSreduce (&bdry_ptr->num_points, bdry_ptr->points, bdry_ptr->points,
                tol);
     }
    */

    BSEXTRACTPAR(&bsmsg, BSTOLCHRDHT, tol);
    flat_check = FALSE;
    
    BSEXTRACTPAR(&rc,BSTOLBASIS,sftol_basis);
    sfuvtol=pwGetParTolSf(surf,sftol_basis);
    
    CorrectBdryPts(surf,sfuvtol);
    
    log_status = BNsb_fct(&bsmsg, surf, &tol, &flat_check, &surf_data);
    if(NOT log_status)	/* screwed up */
     {
      stat_OM = OM_E_ABORT;
      *msg = EMS_F_Fail;
     }

    /* Invoke integration scheme */
    ex$message(msgnumb = EMS_I_Integrating, field = PROMPT_FIELD)

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    if ((option == MASS_PROPS) && (new_tiler))
        EMfacetint(&bsmsg, my_env, trans_vector, surf, &my_GRid,
                   surf_data, option, density, prop);
    else
        MSfacetint(&bsmsg, surf_data, option, density, prop);

    ex$message(msgnumb = EMS_P_ClearPromptField)

    log_status = BNsb_fsd(&bsmsg, surf_data);
    if (NOT log_status)
     {
      stat_OM = OM_E_ABORT;
      *msg = EMS_F_Fail;
     }
   }
  else
   {
    stat_OM = om$send(msg = message EMSsurface.EMsurfintgrl(msg, my_env,
                           new_tiler, trans_vector, surf, NULL, option,
                           density, prop),
                           targetid = my_id);
    if (EMSmsgReport (stat_OM,"EMssFaceInt: surf integral", FALSE))
                      goto wrapup;
   }


  /* If surf->pos_orient negate the properties */

  if (surf->pos_orient) for(i=0; i<11; i++) prop[i] *= -1.0;

  for (i=0; i<NUMB_PROPS; i++) out_int[i] += prop[i];

  /* Free the memory */

  for (i=0; i<surf->num_boundaries; i++)
   {
    bdry_ptr = (struct IGRbsp_bdry_pts *)&surf->bdrys[i];
    om$dealloc( ptr = bdry_ptr->points );
   }
  if(surf->bdrys) om$dealloc( ptr = surf->bdrys );

wrapup:

  if(surf AND (NOT surf_in)) om$dealloc (ptr = surf);
  return(stat_OM);
}


static void CorrectBdryPts(surf,sftol)
struct IGRbsp_surface *surf;
IGRdouble             sftol;
{
  IGRshort num_bdrys;
  IGRlong  num_pts;
  IGRint  inx, uu;
  IGRdouble *ptr;

  sftol=sftol*0.0001;

  num_bdrys=surf->num_boundaries;

  for(inx=0;inx<num_bdrys;inx++)
  {
    num_pts  = (surf->bdrys[inx]).num_points;
    ptr = (IGRdouble *)surf->bdrys[inx].points; 

    for(uu=0;uu<num_pts;uu=uu+2)
    {
      if( fabs(ptr[uu]) < sftol)
      {
        ptr[uu] = 0.0;
      }
      else if( (1-ptr[uu]) < sftol)
      {
        ptr[uu] = 1.0;
      }

      if( fabs(ptr[uu+1]) < sftol)
      {
        ptr[uu+1]=0.0;
      }
      else if( (1-ptr[uu+1]) < sftol)
      {
        ptr[uu+1]=1.0;
      }
    }
  }

  return;
}

end implementation EMSsubbs;

