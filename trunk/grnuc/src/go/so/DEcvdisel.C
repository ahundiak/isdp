#include "msdef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMlimits.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "maerr.h"
#include "codef.h"
#include <sys/types.h>
#include <tools.h>
#include "DEso.h"
#include "DEglob.h"
#include "DEsomacros.h"
#include <alloca.h>

/* These variables are used to highlight one soo of a particular object */
int             DEdisplay_soo = FALSE;
static double          DEu = -1, DEu2 = -1;
static struct GRid     DEwindow;
static IGRmatrix       DEmatrix_buffer;
static double          *DEmatrix;
static int	       DElocalplot = FALSE;

#argsused
DEcvdiselem ( msg, buffer, mode, dp_info, soo_info, type, matrix )
              int                   *msg     /* return  code           OUT */;
              struct DPele_header   *buffer  /* element header for bs  IN  */;
              int                   *mode    /* how to display curve   IN  */;
              struct DP_information *dp_info /* display information    IN  */;
              struct DEcv_soo_info  *soo_info/* soo stuff              IN  */;
              short                 *type    /* matrix type            IN  */;
              IGRmatrix             matrix   /* matrix                 IN  */;
/*
   DEcvdiselem:  Given a bspline curve display the curve with the 
                 appropiate symbology override applied.
*/ 
{
  double            *save_ptr;/* holding spot for the graphic object's ptr */
  struct IGRdisplay save_dis; /* holding spot for it's display attributes  */
  short             save_num; /* holding spot for it's num of bounds       */
  double            *bounds;  /* malloc area for g.o.'s + soo's boundaries */
  int               i, j;
  int               status,dealloc=TRUE;   
  double            one_bound [4]; 
                              /* array holds one boundary with a 0.0 and
                                 a 1.0 sandwiching it...for display    */

  /* save the graphic objects data which I must temporarily change */
  save_ptr = buffer->geometry.bspcurve->bdrys;
  save_num = buffer->geometry.bspcurve->num_boundaries;
  save_dis = *buffer->dis_att;
  
  if(DElocalplot)
  {
     /* impose boundary on entire curve */
  one_bound[0] = 0.0;
  one_bound[3] = 1.0;
/*
 * allocate and initialize an array to hold the g. objects original boundaries
 * and its soo boundaries to display the g. o. with all of these bounds
 */

  bounds = (IGRdouble *) om$malloc(size = (sizeof(IGRdouble) * 2 *
        (soo_info->num_bounds + buffer->geometry.bspcurve->num_boundaries)));
  if (!bounds)
  {
   *msg = MANOMEMORY;
    dealloc = FALSE;
    goto wrapup;
  }

  /* copy g.o boundaries into malloc area */
  for (i=0;i<save_num*2;i++)
    bounds[i] = buffer->geometry.bspcurve->bdrys[i];

  /* add soo boundaries to malloc area */
  for (j=0;j < soo_info->num_bounds*2; j++,i++)
    bounds[i] = soo_info->bounds[j];

 /*
    display curve with pre existing boundaries and soo boundaries imposed
  */

  if(buffer->geometry.bspcurve->num_boundaries == 0)
   {
    buffer->geometry.bspcurve->bdrys = bounds;
    buffer->geometry.bspcurve->num_boundaries += soo_info->num_bounds;
    status = dp$dispelem(msg = msg,
                         buffer = buffer,
                         mode = *mode,
                         dp_info = dp_info);
    if (!status)
    goto wrapup;
   }

/*
 * now I have to display one soo boundary at a time
 */

  buffer->geometry.bspcurve->num_boundaries = 2;
  buffer->geometry.bspcurve->bdrys = one_bound;
  for (i=save_num*2, j=0; j < soo_info->num_bounds; j++,i+=2)
  {
    one_bound[1] = bounds[i];
    one_bound[2] = bounds[i + 1];
   *buffer->dis_att = soo_info->attr[j];

    status = dp$dispelem(msg = msg,
                         buffer = buffer,
                         mode = *mode,
                         dp_info = dp_info);

    if (!status)
      break;
  }

wrapup:

/*
 * I must restore all the original graphic object variables
 */

  if (dealloc)
    om$dealloc(ptr = bounds);

  buffer->geometry.bspcurve->bdrys = save_ptr;
  buffer->geometry.bspcurve->num_boundaries = save_num;
 *buffer->dis_att = save_dis;

  return(OM_S_SUCCESS);

  }

  if (DEdisplay_soo)
  {
    /* we can call dp several times (we are in a command) */
    /* impose boundary on entire curve (remember: the boundaries are what we don't display) */
    one_bound[0] = 0.0;
    one_bound[3] = 1.0;
  
    /* allocate and initialize an array to hold the g. objects original 
       boundaries and its soo boundaries to display the g. o. with all 
       of these bounds */
    bounds = (double *) alloca ( sizeof ( double ) * 2 *  
          (soo_info->num_bounds + buffer->geometry.bspcurve->num_boundaries) );
    if (!bounds)
    {
      *msg = MANOMEMORY;
      return OM_E_NODYNMEM;
    }
  
    /* copy g.o boundaries into malloc area */
    for (i = 0; i < save_num * 2; i++)
      bounds [i] = buffer->geometry.bspcurve->bdrys[i];
  
    /* add soo boundaries to malloc area */
    for (j = 0; j < soo_info->num_bounds * 2; j++,i++)
      bounds [i] = soo_info->bounds [j];
  
    /* now I have to display one soo boundary at a time */
    buffer->geometry.bspcurve->num_boundaries = 2;
    buffer->geometry.bspcurve->bdrys = one_bound;
    for (i = save_num * 2, j = 0; j < soo_info->num_bounds; j++,i += 2)
    {
      if (DEu != -1)
      {
        /* make sure it's in the corrent window for the correct context */
        if (DEwindow.objid != dp_info->view_objid || DEwindow.osnum != dp_info->view_osnum)
          continue;
        if (DEmatrix)
          if (memcmp ( DEmatrix, matrix, 16 * sizeof ( double ) ))
            continue;
        
        /* make sure the u falls into the boundaries */
        if ((DEu <= bounds [i] && DEu >= bounds [i + 1]) ||
            (DEu >= bounds [i] && DEu <= bounds [i + 1]))
          buffer->dis_att->color = save_dis.color;
        else
          if (DEu2 != -1)
            /* we have a 1/0 overlap ==> second chance */
            if ((DEu2 <= bounds [i] && DEu2 >= bounds [i + 1]) || 
                (DEu2 >= bounds [i] && DEu2 <= bounds [i + 1]))
              buffer->dis_att->color = save_dis.color;
            else
              continue;
          else
            continue;
      }
      else
        buffer->dis_att->color = save_dis.color;
  
      one_bound [1] = bounds [i];
      one_bound [2] = bounds [i + 1];
  
      status = dp$dispelem ( msg = msg, 
                             buffer = buffer, 
                             mode = *mode, 
                             dp_info = dp_info ); 
  
      buffer->dis_att->color = soo_info->attr [j].color;
   
      if (!status)
        break;
    }
  }
  else
  
  /*
   *  Kludge for a gpipe bug.  If there is only one override and
   *  its endpoints are [0,1] and the override is invisible the
   *  dont display anything.  |[>Mike Lanier: x7818: 03/18/92<]|
   */
   
  if( !(soo_info->num_bounds == 1 &&
        soo_info->bounds[0] == 0.0 && 
        soo_info->bounds[1] == 1.0 && 
        soo_info->attr[0].color == 0xffff) )
  {
    struct IGRdisplay **u_bound_att /*to contain the display of each boundary*/,
                      *attributes   /*to contain the display of each boundary*/;
    int               i, j,
                      *indices      /*indices into u_bound_att               */;

    /* display curve with pre existing boundaries and soo boundaries imposed */
    if (buffer->geometry.bspcurve->num_boundaries != 0)
      printf ( "FATAL BUGCHECK in file %s at line %d: number of boundaries is not 0\n", __FILE__, __LINE__ );
  
    /* allocate and initialize an array to hold the g. objects original boundaries and its 
       soo boundaries to display the g. o. with all of these bounds */
    bounds = (double *) alloca ( sizeof ( double ) * 2 * soo_info->num_bounds );
    u_bound_att = (struct IGRdisplay **) alloca ( sizeof ( struct IGRdisplay * ) * (soo_info->num_bounds * 2 + 1) );
    attributes = (struct IGRdisplay *)alloca ( sizeof ( struct IGRdisplay ) * (soo_info->num_bounds * 2) + 1 );
    indices = (int *) alloca ( sizeof ( int ) * soo_info->num_bounds * 2 + 1 );
    if (!bounds || !u_bound_att || !attributes || !indices)
    {
      *msg = MANOMEMORY;
      return OM_E_NODYNMEM;
    }
  
    /* copy g.o. boundaries into malloc area */
    for (i = 0; i < soo_info->num_bounds * 2 + 1; i += 2)
    {
      attributes [i] = save_dis;
      u_bound_att [i] = &(attributes [i]);
      indices [i] = i;
    }
  
    /* copy soo boundaries into malloc area */
    for (i = 1, j = 0; i < soo_info->num_bounds * 2 + 1; i += 2, j++)
    {
      attributes [i] = soo_info->attr [j];
      u_bound_att [i] = &(attributes [i]);
      indices [i] = i;
    }
    
    buffer->u_bound_att = u_bound_att;
    buffer->u_bound_att_indices = &indices;
    buffer->u_num_bound_att = soo_info->num_bounds * 2 + 1;
    buffer->geometry.bspcurve->bdrys = soo_info->bounds;
    buffer->geometry.bspcurve->num_boundaries = soo_info->num_bounds;
  
    status = dp$dispelem ( msg = msg, 
                           buffer = buffer, 
                           mode = *mode, 
                           dp_info = dp_info); 
    buffer->u_bound_att = NULL;
    buffer->u_bound_att_indices = NULL;
    buffer->u_num_bound_att = NULL;
  }
  
  /* I must restore all the original graphic object variables */
  buffer->geometry.bspcurve->bdrys = save_ptr;
  buffer->geometry.bspcurve->num_boundaries = save_num;
  *buffer->dis_att = save_dis;

  return OM_S_SUCCESS;
}


DEshow_only_one_soo ( msg, grid, u, window, md_env )
                      long        *msg        /* return status          OUT */;
                      struct GRid *grid       /* object with override   IN  */; 
                      IGRdouble    u          /* the u of the acpt pnt  IN  */;
                      struct GRid *window     /* the window of override IN  */;
                      struct GRmd_env *md_env /* the module env         IN  */;
/*
   This function is used when a soo needs to be highlighted.  The command
   will set the u parm in order to display one soo only.
*/
{
  int               status = OM_S_SUCCESS, type;
  struct IGRdisplay symb;
  double            u1, u2;

  *msg = MSSUCC;
  
  /* can we find an override for that guy ? */
  status = de$retrieve_override ( msg = msg,
                                  p_type = &type,
                                  p_symbology = &symb,
                                  p_u1 = &u1,
                                  p_u2 = &u2,
                                  u = u,
                                  go_grid = grid,
                                  window_grid = window,
                                  module = md_env );
  if (*msg == MSSUCC)
  {
    DEdisplay_soo = 1;
    DEwindow = *window;

    if (md_env)
    {
      DEmatrix = DEmatrix_buffer;
      memcpy ( DEmatrix, md_env->md_env.matrix, 16 * sizeof ( double ) );
    }
    else
      DEmatrix = NULL;

    DEu = u1 + (u2 - u1) * 0.5;
    
    if (type & DE_OVERLAP)
    {
      status = de$next_override ( msg = msg, 
                                  p_symbology = &symb,
                                  p_u1 = &u1,
                                  p_u2 = &u2 );
      if (*msg == MSSUCC)
        DEu2 = u1 + (u2 - u1) * 0.5;
      else
        DEu2 = -1;
    }
    else
      DEu2 = -1;
  }

  return status;
}


DEshow_only_soo ()
/*
   This function is used when the soo's need to be highlighted.  
*/
{
  DEdisplay_soo = TRUE;
  DEu = DEu2 = -1;

  return OM_S_SUCCESS;
}

DEget_localplot()
{
   return DElocalplot;
}

DEset_localplot()
{
   DElocalplot = TRUE;

   return OM_S_SUCCESS;
}

DEreset_localplot()
{
   DElocalplot = FALSE;

   return OM_S_SUCCESS;
}

DEshow_all ()
{
  DEdisplay_soo = FALSE;

  return OM_S_SUCCESS;
}
