class implementation Root;

from EMSassoc import EMget_parent_info, EMget_info, EMput_info;
from GRgraphics import GRconstruct, GRdelete;
from EMSsurface import EMmk_nat_bdry;
from EMSgencompsf import EMmake_comp;
from GRvg import GRchgprops;
from EMSsfstitch import EMmake_comp;
from EMSsfstitch import EMmake_primitive1;
from GRconnector import GRrigidconn;
%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"
#include "EMSmsgdef.h"            /* EMS_I_NotFound */
#include "EC_M.h"            /* Command strings */
#include "EC_P.h"      /* Prompt strings */
#include "EC_I.h"      /* Informational strings */
#include "EC_F.h"      /* Fatal strings */
#include "FI.h"
#include "EMSdpb.h"
#include "emsdef.h"
#include "emserr.h"
#include "REsfsolid.h"
#include "REassoc.h"
#include "REgenbs.h"
#include "emsmass.h"
#include "bsgeom_cvsf.h"
#include "EMSsfparms.h"
#include "bsconic.h"
#include "bssrmktsncg.h"
#include "bssftgeomsf.h"
#include "bssf_rev.h"
#include "bssf_copy.h"
#include "bsmergsfnna.h"
#include "bsfreesf.h"
#include "bsarclnpars.h"
#include "bsallocsf.h"
#include "godef.h"

/*
Name
  compare_doubles

Abstract
 This function compares 2 doubles and returns 0 if equal, -1 if the
 first is smaller than the second, 1 if second is smaller than first. 
Synopsis
 
Description
 IN:	double *a; a pointer to the first double
 IN:	double *b; a pointer to the second double
Return Value
 
Notes
 It is a rather stupid function, but qsort requires a function to do
 the sort.
Index

Keywords

History
  06/22/93 : Carlos M. Diaz :  created
 */

int compare_doubles(a, b) 
double *a, *b;
{
  return((*a == *b) ? 0 : (*a < *b) ? -1 : 1);
}


/*

Name
  elim_adj_reps

Abstract
 This function eliminates repetitions on a sorted list
 (need to change it to use base tolerance for comparison)

Synopsis
 IN:		double *list; a pointer to a double
 IN/OUT:	double *length; a pointer to the length of the array
Description
 
Return Value

Notes

Index

Keywords

History
  06/22/93 : Carlos M. Diaz : created

*/
int elim_adj_reps (list, length)
double *list;
int *length;
{
  int i;
#ifdef DEBUG
  printf ("list is:\n");
  for (i = 0; i < *length; i++)
    printf ("%lf",list[i]);
#endif
  if (*length <= 1) 
   return 0;
  else
  {
    BSrc bs_rc;
    double base_tol;
    BSxtractpar( &bs_rc, BSTOLBASIS, &base_tol);
    if (bs_rc != BSSUCC) 
     base_tol = 0.001;
    for (i = 0; i < (*length - 2); i++)
    {
      if ( fabs (list[i] - list[i+1]) < base_tol)
      {
        OM_BLOCK_MOVE (&list[i+2], &list[i+1], (*length - i - 1) * sizeof (double));
        (*length)--;
        i--;
      }
    }
    if ( fabs (list[i] - list[i+1]) < base_tol) 
     (*length)--; 
   return 1;
  }
}


/*
 * Name 
 *      EMS_conv_int()
 * Abstract 
 *      This function converts the given data (int) from LITTLE_ENDIAN format 
 *      to BIG_ENDIAN format.
 * Synopsis
 *      data    void *    IN   pointer to data
 *      n       int       IN   number of ints needs to be converted.
 * History 
 *      Sanjay    10/12/94     Creation
 */ 
int EMS_conv_int( data, n )
void *data;
int n;
{
   unsigned int *i = data;
   int   buf;
   char *x, *y;

      x = (char *) &buf;
      y = (char *) i;

      while (n)
      {
         x[0] = ((char*)i)[0]; 
         x[1] = ((char*)i)[1];
         x[2] = ((char*)i)[2];
         x[3] = ((char*)i)[3];

         y[0] = x[3];
         y[1] = x[2];
         y[2] = x[1];
         y[3] = x[0];

         y += sizeof(int);
         i++;
         n--;
      }

   return(1);
}

/*

Name
  EFSkinSurface

Abstract
 This function is an argument to ems$associative_element_by_function. 
 It is responsible for the creation and recomputation of the skinning 
 surface. It is also used for the skinning solid, as part of an equivalent 
 function.
Synopsis
 OUT:	IGRlong *EMmsg; if (1&*EMmsg) then successful else failed. 
 IN:	IGRuint options; not used.
 IN:	GRobjid old_objid; not used.
 IN:	GRobjid new_objid; objid of the newly created object.
 IN:	IGRint num_parents; number of parents.
 IN:	IGRchar *parent_info; information about parents. 
 IN:	IGRchar *recomp_info; information used to perform the recomputation
 IN:	struct GRvg_construct *construct_list; environment information
 OUT:	GRobjid *mod_new_id; same as new_objid if a change class did not occur, 
 			     else is whatever the id of the new class object is.
Description

Return Value
 IGRlong
Notes
 
Index

Keywords
 skinning,surface,solid,placement,recomputation,composite

History
  06/18/93 : Carlos M. Diaz : created
  08/01/94 : Sanjay         :  Fix for TR# 11940621 :
                               After the skinning surface is created, it will
                               be split at the cusps points and the profile
                               components i.e.
                               m - number of components of the X sec. curve.
                               n - number of components of the Trace curve.
                               k - number of cusps in U
                               l - number of cusps in V
                               Then the total number of surfaces after split :
                                  = ( m + k ) * ( n + l ).
                               The preliminary design was to split the surface
                               at the above knot points and then make surfaces
                               out of these split surface geometrices. In doing
                               so, as the no. of splits increases there will be
                               a huge memory lock and will result in malloc fu-
                               nction to fail. Changed the design,so that after
                               each split a surface object will be created and
                               the memory for that surface will be immediately
                               freed. In case split fails, all the intermediate
                               surfaces created will be deleted from the object
                               space.
  10/12/94 : Sanjay         :  Fix for TR# 119422901. See Notes below for desc.
 */
IGRlong EFSkinSurface (EMmsg, options, old_objid, new_objid,num_parents,
parent_info, recomp_info, construct_list, mod_new_id)

IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
{
  extern OMuword OPP_EMAgenbs_class_id;
  extern OMuword OPP_EMSgenbs_class_id;
  extern OMuword OPP_EMSsfstitch_class_id;  
  IGRlong status = OM_S_SUCCESS, msg_loc = OM_S_SUCCESS;
  IGRuint *root_type = NULL, number_of_sections, number_of_trace_curves;
  union EMSparent_info *roots = NULL;
  union EMSparent_info *start_roots = NULL;
  struct EMSskinning_surface *info = NULL;
  GRobjid  tempid = NULL_OBJID;
  int i;

  struct IGRbsp_surface *p_surface = NULL;

  int split_traces = 0;
  int split_cross = 0;

  IGRdouble *U_list = NULL;     /* final lists of split points */
  IGRdouble *V_list = NULL;

  int U_length = NULL;		/* length of final lists */
  int V_length = NULL;

  IGRdouble *U_split_at = NULL; /* splits corresponding to parent geom */
  IGRdouble *V_split_at = NULL;

  IGRdouble *U_cusp_at = NULL;  /* splits corresponding to cusps */
  IGRdouble *V_cusp_at = NULL;

  int num_cusps_U;
  int num_cusps_V;
  IGRlong curve_index;
  struct GRlc_info *cross_sections = NULL;
  struct GRlc_info *traces = NULL;
  struct GRlc_info *tangent_surfaces = NULL;
  struct IGRbsp_curve *shape_law = NULL, *orient_law = NULL;
  IGRint cnt = 0;
  IGRboolean surface_is_open = FALSE, 
  	     absolute_orientation = FALSE, 
      	     no_height_scaling = FALSE,
      	     smooth = FALSE, made_composite = FALSE;
  extern void EMget_lawcurve();

  int can_create_composite = FALSE;
 
  *EMmsg = OM_S_SUCCESS;

  options = options; /* make the compiler happy */
  old_objid = old_objid; 
  /*
   * get recompute information.
   */
  info = (struct EMSskinning_surface *)recomp_info;
  /*
  info contains the following:
  info->number_of_sections;
  info->number_of_trace_curves;
  info->tangent_surf_props;
  info->skinning_surf_props;
  info->chardata;
  */

  /*
   * KLUDGE OF KLUDGES : (TR# 119422901)
   * -----------------------------------
   *    Surfaces resulting from skinning, can be of any surface class i.e.
   *    EMArevol, EMAplane etc. But the transos function is available for
   *    only EMAgenbs, so the assoc data i.e. recomputation info., will not
   *    get converted for the other classes. Similarly, while storing also
   *    the data will be stored in the native format of the machine on which
   *    design file is created. It is also clear that it is not possible to 
   *    provide the fix at the TRANSOS level because the already created 
   *    skin objects will fail to recompute. So, here is a KLUDGE for the 
   *    problem mentioned. Convert the data and  check for the acceptability
   *    of the converted and original data, whichever found acceptable take
   *    that as the correct info.
   */
  number_of_sections = info->number_of_sections;
  number_of_trace_curves = info->number_of_trace_curves;

  /* Convert the data in the recompute info structure */

  EMS_conv_int( recomp_info, 2 ); 

  /* Compare this with original data , and choose the best */

  if( number_of_sections < info->number_of_sections )
  {
     /* Stored info is correct, hence put it back */

    info->number_of_sections = number_of_sections;
    info->number_of_trace_curves = number_of_trace_curves;
  }
  else
  {
    IGRchar    *loc_info=NULL, func_name[14];
    IGRuint    info_size=0, recomp_size, func_name_size, type;

#ifdef DEBUG
    printf("stored info is bad\n");
    printf("number_of_sections = %d\n", number_of_sections);
    printf("number_of_trace_curves = %d\n", number_of_trace_curves);
    printf("Msg : Converting skinning recompute information.\n");
#endif 

    status = om$send( msg = message EMSassoc.EMget_info( &msg_loc, NULL, &type,
                                    &info_size, &loc_info ),
                      senderid = old_objid,
                      targetid = old_objid );
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 
    func_name[0] = '\0';
    if( info_size > 14 )
        OM_BLOCK_MOVE( loc_info, func_name, 14 );

    if( !(strcmp(func_name, "EFSkinSurface")) )
    {
       func_name_size  = strlen(loc_info) + 1;
       func_name_size += ( func_name_size % 8 ? (8 - func_name_size % 8) : 0 );
       recomp_size     = info_size - func_name_size;
       OM_BLOCK_MOVE( info, &loc_info[func_name_size], recomp_size );
    }
    else
    {
       OM_BLOCK_MOVE( info, loc_info, info_size );
    }

    status = om$send( msg = message EMSassoc.EMput_info( &msg_loc, NULL, type,
                                    info_size, loc_info),
                      senderid = old_objid,
                      targetid = old_objid );
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    om$dealloc( ptr = loc_info ); loc_info = NULL;
  }

  cross_sections = (struct GRlc_info *) stackalloc ( 
      sizeof (struct GRlc_info) * info->number_of_sections);
  EMerr_hndlr(!cross_sections, *EMmsg, EMS_E_DynamicMemoryAllocated, 
      wrapup);

  traces = (struct GRlc_info *) stackalloc ( 
      sizeof (struct GRlc_info) * info->number_of_trace_curves);
  EMerr_hndlr(!traces, *EMmsg, EMS_E_DynamicMemoryAllocated, 
      wrapup);

  if (info->tangent_surf_props)
  {
    tangent_surfaces = (struct GRlc_info *) stackalloc ( 
        sizeof (struct GRlc_info) * 4);
    EMerr_hndlr(!tangent_surfaces, *EMmsg, EMS_E_DynamicMemoryAllocated, 
        wrapup);
  }

 /*
  * Get the parents
  */
  root_type = (IGRuint *)stackalloc(num_parents * sizeof(IGRuint));
  roots = (union EMSparent_info *)stackalloc(num_parents*sizeof(union EMSparent_info));
  EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  for (i=0; i<num_parents; i++)
   root_type[i] = EMSgrid;
   
  roots = (union EMSparent_info *)stackalloc(num_parents * sizeof(union EMSparent_info));
  EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$send (msg = message EMSassoc.EMget_parent_info(&msg_loc, NULL,
                         num_parents,
                         parent_info,
                         root_type, 
                         roots),
                   targetid = new_objid,
		   senderid = new_objid);

  start_roots = roots; /* save it for later */

  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  for (i=0;i<info->number_of_sections;i++,cnt++)
  {
    cross_sections[i].located_obj = roots->grobj.grid;
    cross_sections[i].module_info = roots->grobj.env;
    cross_sections[i].geom_parms.polygon_inx = info->chardata[cnt];
    ++(roots);
  }

  for (i=0;i<info->number_of_trace_curves;i++,cnt++)
  {
    traces[i].located_obj = roots->grobj.grid;
    traces[i].module_info = roots->grobj.env;
    traces[i].geom_parms.polygon_inx = info->chardata[cnt];
    ++(roots);
  }
  if ((info->number_of_trace_curves <= 2) &&
      (info->number_of_sections == 2) &&
      (info->skinning_surf_props & EMS_IS_SURFACE_OPEN))
  {
    if (info->skinning_surf_props & EMS_IS_ORIENTATION_LAW)
    {
      EMget_lawcurve(
          &msg_loc,
          &info->chardata[cnt],
          &curve_index,
          &orient_law);
      cnt += strlen(&info->chardata[cnt]) + 1;
    }
    if (info->skinning_surf_props & EMS_IS_SHAPE_LAW)
    {
      EMget_lawcurve(
          &msg_loc,
          &info->chardata[cnt],
          &curve_index,
          &shape_law);
    }
  }
  if (info->tangent_surf_props)
  {
    if (info->tangent_surf_props & EMS_FIRST_SURF)
    {
      tangent_surfaces[0].located_obj = roots->grobj.grid;
      tangent_surfaces[0].module_info = roots->grobj.env;
      ++(roots);
    }
    else
      tangent_surfaces[0].located_obj.objid = NULL_OBJID;
    if (info->tangent_surf_props & EMS_SECOND_SURF)
    {
      tangent_surfaces[1].located_obj = roots->grobj.grid;
      tangent_surfaces[1].module_info = roots->grobj.env;
      ++(roots);
    }
    else
      tangent_surfaces[1].located_obj.objid = NULL_OBJID;
    if (info->tangent_surf_props & EMS_THIRD_SURF)
    {
      tangent_surfaces[2].located_obj = roots->grobj.grid;
      tangent_surfaces[2].module_info = roots->grobj.env;
      ++(roots);
    }
    else
      tangent_surfaces[2].located_obj.objid = NULL_OBJID;
    if (info->tangent_surf_props & EMS_FOURTH_SURF)
    {
      tangent_surfaces[3].located_obj = roots->grobj.grid;
      tangent_surfaces[3].module_info = roots->grobj.env;
      ++(roots);
    }
    else
      tangent_surfaces[3].located_obj.objid = NULL_OBJID;
  }
  else
    tangent_surfaces = NULL;

  if (!(info->skinning_surf_props & EMS_IS_HEIGHT_SCALING))
    no_height_scaling = TRUE;

  if (info->skinning_surf_props & EMS_IS_SURFACE_OPEN)
    surface_is_open = TRUE;

  if (info->skinning_surf_props & EMS_IS_ABSOLUTE_ORIENTATION)
    absolute_orientation = TRUE;
    
  if (info->skinning_surf_props & EMS_IS_ARC_LENGTH_PARAM)
    smooth = TRUE;

  status = EFMakeSkinSurface(
      &msg_loc, 
      info->number_of_trace_curves,
      traces,
      info->number_of_sections,
      cross_sections,
      surface_is_open,
      tangent_surfaces,
      absolute_orientation,
      no_height_scaling,
      shape_law,
      orient_law,
      smooth,
      &p_surface);

  if (shape_law) free(shape_law);
  if (orient_law) free(orient_law);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  /*
   * if user wants a composite
   *    then 
   *     determine if I can create a composite
   *     if I can create a composite
   *        then
   *         create a multi-component composite
   *        else
   *         create a single surface
   *    else
   *     create a single surface
   */
  if (info->skinning_surf_props & EMS_COMPOSITE_WANTED) {
    BSrc rc;
    IGRlong loc_msg;
    struct GRid *traces_obj;
    struct GRid *xsections_obj;
    GRobjid *part_surfs_objids;
    IGRint i, j, k, num_t, num_x, index, num_comps[2];

    k = 0;
    loc_msg = EMS_S_Success;
    traces_obj = NULL;
    xsections_obj = NULL;
    part_surfs_objids = NULL;

    /*
     * let's find the cusps
     */
    U_cusp_at = (double *)stackalloc((p_surface->u_num_poles - p_surface->u_order + 3) * sizeof (double));
    V_cusp_at = (double *)stackalloc((p_surface->v_num_poles - p_surface->v_order + 3) * sizeof (double));
    BSfndsfcsp (p_surface, &num_cusps_U, &U_cusp_at[0], &num_cusps_V, &V_cusp_at[0], &rc);

#ifdef DEBUG
    printf ("Cusps in U (after BSfndsfcsp) at:\n");    
    for (i=0; i<num_cusps_U; i++)
      printf ("%lf\t",U_cusp_at[i]);
    printf ("\n");
    printf ("Cusps in V (after BSfndsfcsp) at:\n");
    for (i=0; i<num_cusps_V; i++)
      printf ("%lf\t",V_cusp_at[i]);
    printf ("\n");      
#endif
    if (num_cusps_U || num_cusps_V) can_create_composite = TRUE;

  /*
   * Now check to see if the number of elements in the
   * cross-sections and traces match.
   */

    num_t = info->number_of_trace_curves;
    num_x = info->number_of_sections;

    traces_obj    = (struct GRid *)stackalloc(num_t * sizeof (struct GRid));
    EMerr_hndlr( !traces_obj, *EMmsg, EMS_E_NoDynamicMemory, wrapup );

    xsections_obj = (struct GRid *)stackalloc(num_x * sizeof (struct GRid));
    EMerr_hndlr( !xsections_obj, *EMmsg, EMS_E_NoDynamicMemory, wrapup );
    
    for (index = 0; index < num_x; index++)
    {
     xsections_obj[index].objid = start_roots[index].grobj.grid.objid;
     xsections_obj[index].osnum = start_roots[index].grobj.grid.osnum;       
    }

    for (index = 0; index < num_t; index++)
    {
     traces_obj[index].objid = start_roots[index + num_x].grobj.grid.objid;
     traces_obj[index].osnum = start_roots[index + num_x].grobj.grid.osnum;
    }
    
    EFMatch (
       &status, 
        num_t, 
        num_x,
        traces_obj, 	/* traces   */
        xsections_obj,  /* cross-sections */
    	num_comps);
  
    if (smooth) {
      num_comps[0] = 0;
      num_comps[1] = 0;
      }

    if (num_comps[0] <= 1)
      split_traces = FALSE;
    else {
      split_traces = num_comps[0]; /* TRUE */
      V_split_at = (double *) stackalloc( split_traces * sizeof (double));
      EMerr_hndlr( !V_split_at, *EMmsg, EMS_E_NoDynamicMemory, wrapup );
      for (i = 0; i < split_traces ; i++)
        V_split_at[i] =  (double)i/(double)num_comps[0];
    }

    if (num_comps[1] <= 1)
      split_cross = FALSE;
    else {
      split_cross = num_comps[1]; /* TRUE */
      U_split_at = (double *) stackalloc(split_cross * sizeof (double));
      EMerr_hndlr( !U_split_at, *EMmsg, EMS_E_NoDynamicMemory, wrapup );
      for (i = 0; i < split_cross; i++)
        U_split_at[i] =  (double)i/(double)num_comps[1];
    } 

#ifdef DEBUG
 printf ("Split points after checking comps\n");
 if (split_traces)
  for(i=0;i<split_traces;i++)
   printf("%f\n",V_split_at[i]);  
 printf ("\n");
 if (split_cross)
  for(i=0;i<split_cross;i++)
   printf("%f\n",U_split_at[i]);
#endif  

    if (split_cross || split_traces) 
      can_create_composite = TRUE;
  
    
   if (can_create_composite) {

    IGRdouble  Upars[2], Vpars[2];
    struct EMpatch_list patch_list; /* defined in emsmass.h */

    k = 0;
    memset( &patch_list, 0, sizeof(struct EMpatch_list) );

    /* This block will create a multi-component composite.
     * 
     * Now let's make up 2 lists of ordered split points using U_split_at, 
     * V_split_at, U_cusp_at and V_cusp_at. 
     */
    V_length = split_traces + num_cusps_V + 2; 
    U_length = split_cross + num_cusps_U + 2; 
    
    V_list = (double *) stackalloc ((V_length) * sizeof (double));
    EMerr_hndlr( !V_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup );
    V_list[0] = 0;
    V_list[V_length - 1] = 1; 
    
    U_list = (double *) stackalloc ((U_length) * sizeof (double));
    EMerr_hndlr( !U_list, *EMmsg, EMS_E_NoDynamicMemory, wrapup );
    U_list[0] = 0;
    U_list[U_length - 1] = 1; 
    
    if (split_cross)    
     OM_BLOCK_MOVE (&U_split_at[0], &U_list[1], split_cross * sizeof (double));
    if (num_cusps_U)
     OM_BLOCK_MOVE (&U_cusp_at[0], &U_list[split_cross + 1], num_cusps_U * sizeof (double));

    if (split_traces)
     OM_BLOCK_MOVE (&V_split_at[0], &V_list[1], split_traces * sizeof (double));
    if (num_cusps_V)
     OM_BLOCK_MOVE (&V_cusp_at[0], &V_list[split_traces + 1], num_cusps_V * sizeof (double));

#ifdef DEBUG
 printf ("Split points after merging, before sorting and elim\n");
 if (V_length)
  for(i=0;i<V_length;i++)
   printf("%f\n",V_list[i]);  
 printf ("\n");
 if (U_length)
  for(i=0;i<U_length;i++)
   printf("%f\n",U_list[i]);
#endif 
    
    if (U_length > 2) {
      qsort (U_list,U_length,sizeof(double),compare_doubles);
      elim_adj_reps (U_list, &U_length);
      } 

    if (V_length > 2) {
      qsort (V_list,V_length,sizeof(double),compare_doubles);
      elim_adj_reps (V_list, &V_length);
      }
#ifdef DEBUG
    for (i=0; i < U_length; i++)
    	printf ("Split at U: %lf\n", U_list[i]);

    printf ("\n");

    for (i=0; i < V_length; i++)
    	printf ("Split at V: %lf\n", V_list[i]);
#endif
  /*
   * Now split the skinning surface geometry into
   * partial surfaces corresponding to each U,V
   * rectangle
   */

     part_surfs_objids = (GRobjid *)stackalloc(U_length * V_length * sizeof (GRobjid));
     EMerr_hndlr( !part_surfs_objids, *EMmsg, EMS_E_NoDynamicMemory, wrapup );

     part_surfs_objids[0] = NULL_OBJID;
     
#ifdef DEBUG
     printf ("Splitting surface using the following: \n");
     printf ("along U:\n");
     for (i=0; i< U_length; i++)
      printf ("%f\n", U_list[i]);
     printf ("along V:\n");
     for (i=0; i< V_length; i++)
      printf ("%f\n", V_list[i]); 
#endif

     patch_list.params.numu = 2;
     patch_list.params.numv = 2;
     patch_list.params.u_pars = Upars;
     patch_list.params.v_pars = Vpars;
     patch_list.geometries = (struct IGRbsp_surface **)
     			     stackalloc( sizeof (struct IGRbsp_surface *)); 
     EMerr_hndlr( !patch_list.geometries, *EMmsg, EMS_E_NoDynamicMemory, 
                  wrapup );
     patch_list.geometries[0] = NULL;
         
     for( i = 0, k = 0; i < U_length - 1 ; i++ )
     {
        patch_list.params.u_pars[0] = U_list[i];
        patch_list.params.u_pars[1] = U_list[i+1];
        for( j = 0; j < V_length - 1 ; j++ )
        {
           part_surfs_objids[k] = NULL_OBJID;
           patch_list.params.v_pars[0] = V_list[j];
           patch_list.params.v_pars[1] = V_list[j+1];

           /* split the surface */
           EFSplitSurface (&msg_loc, p_surface, patch_list);
           EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, loc_wrapup);

           /* 
            * Create surface object from the split surface geometry.
            * The following function converts geometry into optimized 
            * surface.
            */
           status = EFspecial_case_from_geom (&msg_loc,
                  patch_list.geometries[0],
                  construct_list,
                  &part_surfs_objids[k]);
           if( !(1&status&msg_loc) )
               part_surfs_objids[k] = NULL_OBJID; 
           EMerr_hndlr( !(1&status&msg_loc), *EMmsg, EMS_E_SurfaceError, 
                        loc_wrapup);

           /* free the split surface's geometry */
           BSfreesf( &loc_msg, patch_list.geometries[0] );
           patch_list.geometries[0] = NULL;

           k++;
        }
     }

    /*
     * then make a composite
     * 
     */
     {
     struct GRid grid;
     GRobjid someid;
     
     status = om$construct(classid = OPP_EMSsfstitch_class_id,
                       p_objid = &someid,
                       osnum = construct_list->env_info->md_id.osnum);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, loc_wrapup);

     status = om$send (msg = message EMSsfstitch.EMmake_comp ( 
     				 &msg_loc,
     				 (U_length - 1) * (V_length - 1),
     				 part_surfs_objids,
     				 construct_list->env_info,
     				 NULL,
     				 NULL,
     				 NULL,
     				 NULL,
     				 NULL),
                       targetid = someid,
                       senderid = NULL);
     EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, loc_wrapup);

     made_composite = TRUE;
     tempid = someid;

     status = om$send (msg = message EMSsfstitch.EMmake_primitive1 (
     				&msg_loc,
     				construct_list->env_info,
     				&grid),
     		       targetid = someid,
                       senderid = NULL);
     EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, loc_wrapup);

     new_objid = *mod_new_id = grid.objid;
#ifdef DEBUG
     printf ("EMSsfstitch created\n");
#endif
     }
     }
     else /* user wanted a composite but I can not do it */   
     {
        /*
         * This block constructs a single surface
         * (should I create a composite with a single element ? */
     
         GRobjid surf_objid;
         status = EFspecial_case_from_geom (&msg_loc,
	  	 p_surface,
	  	 construct_list,
	  	 &surf_objid);
    EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, loc_wrapup);
    *mod_new_id = new_objid = surf_objid;
#ifdef DEBUG
   printf ("Created single surface\n");
#endif
     }

  loc_wrapup:

    if( can_create_composite )
    {
       IGRlong loc_status;
       
       loc_status = OM_S_SUCCESS;

       /* in case of failure, do the following */
       if( !(1&status&msg_loc) )
       {
          if( made_composite )
          {
             loc_status = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
                                             construct_list->env_info ),
                               senderid = NULL_OBJID,
                               targetid = tempid,
                               targetos = construct_list->env_info->md_id.osnum
                             ); 
             EMerr_hndlr( !(1&loc_status&loc_msg), *EMmsg, EMS_E_Fail, wrapup );
          }
          else
          {
             k = 0;

             /* delete all the split surfaces created */
             while( part_surfs_objids[k] != NULL_OBJID )
             {
                loc_status = om$send( msg = message GRgraphics.GRdelete( 
                                                &loc_msg, 
                                                construct_list->env_info ),
                                senderid = NULL_OBJID,
                                targetid = part_surfs_objids[k],
                                targetos = construct_list->env_info->md_id.osnum
                                );
                EMerr_hndlr( !(1&loc_status&loc_msg), *EMmsg, EMS_E_Fail,    
                             wrapup );
                k++;
             }
          }
       }
    }

    EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }
  else /* user did not want a composite */   
  { 
  /*
  * This block constructs a single surface
  */
   GRobjid surf_objid;
   status = EFspecial_case_from_geom (&msg_loc,
	  	 p_surface,
	  	 construct_list,
	  	 &surf_objid);
   EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_OMerror, wrapup);
   *mod_new_id = new_objid = surf_objid;
#ifdef DEBUG
   printf ("Created single surface\n");
#endif
  }
#ifdef DEBUG
  if (1&status&msg_loc) {
   printf ("CDCrtSkinSrf successful\n");
   }
#endif

  wrapup:
  if (p_surface)
   {
    IGRboolean  status;
    IGRlong  loc_msg;

    status = BSfreesf(
        &loc_msg, 
        p_surface);
   }
   if (!(1&status&msg_loc))
    return EMS_E_Fail;
   else 
    return EMS_S_Success;
}


end implementation Root;
