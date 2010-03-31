class implementation EMSsubbs;

#include "memory.h"
#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsconic.h"
#include "ECmsg.h"
#include "EMSmsgdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "emssfintdef.h"
#include "emserr.h"
#include "ECmfdef.h"
#include "ECmf.h"
#include "ECmfopt.h"
#include "ECmferr.h"
#include "emsmapdef.h"

#define EQUAL_TOL 0.000001
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define MEM_FREE( addr ) if ( addr ) { om$dealloc ( ptr = addr ) ; addr = 0 ; }

#define STRT 0
#define STOP 2

#define LEFT   1
#define RIGHT -1

from GRcurve import GRendpts;

%safe
static IGRlong qq_common_segs();
%endsafe

extern double fabs();

/*

 * DESCRIPTION

   Given a fillet and 2 surfaces for the fillet is created, return common
   segments of fillets lying on both the surfaces. i.e. effectively trim
   the fillet against imposed boundaries of both the surfaces.  the trimming
   is not done here.  only num of overlapping segments and arrays for V start 
   & V end for each seg are returned.  the memory for arrays is alocated here, 
   and should be freed by the caller.

   note:  the caller is expected to impose const V isocurves on the original
          fillet, so this whole thing makes sense!
          the 2 arrays returned could have been bundled into a linked list
          (just got lazy!!)


 * INPUT

   opts            not used
   const_list      usual construction list.  it is needed by EMget_mapped_data
   active_md_env   usual env info
   fill_id         GRid of the fillet
   sf0_id          GRid of sf0 on which the fillet is placed
   sf1_id          GRid of sf1 on which the fillet is placed
   fill_sf         IGRbsp_surface of the fillet (optional)
   sf0_sf          IGRbsp_surface of sf0 for sf0_id (optional)
   sf1_sf          IGRbsp_surface of sf1 for sf1_id (optional)


 * OUTPUT

   msg             EMS errors
   num_segs        num of overlapping segments
   str_segs        array of V values for start of segments
   end_segs        array of V values for end of segments


 * ALGORITHM

   find intersections of u0 & u1 isocurves with respctive surfaces 
   (EMget_mapped_data).
   process the intersections to find out common segments.  this algorithm is
   copied from EMintpybdrys:

   endpoints from all the segments from EMparttrim (for both u0 & u1) are 
   mergred and arranged in ascending order.  when merged, each endpoint is 
   assigned '+1' if it is a left end of a segment and '-1' if it is a right
   end of a segment.  As we go down the arrangement, add these values. When the    sum is 2, we have a overlap starting at that node. This is immediately 
   followed by a 'right end' node, meaning the overlap terminates there.

    examples:

    list a              -----     ------   --    -----    -----
    list b            -----     ---------------    --             ----
    overlap             ...       ......   ..      ..

    arrangement:  L L R R L L R L R R L L R R L R L R
    overlap:        ***     *** ***     ***


 * HISTORY

   pac             3/30
   pac             ????      change parttrim to EMget_mapped_data 

 */


IGRlong ECmf_flsfint( msg, opts, const_list, active_md_env, 
                      fill_id, sf0_id, sf1_id, 
                      fill_sf, sf0_sf, sf1_sf, 
                      num_segs, str_segs, end_segs )

IGRlong               *msg;
IGRushort             opts;
struct GRvg_construct *const_list;
struct GRmd_env       *active_md_env;
struct GRid           *fill_id, *sf0_id, *sf1_id;
struct IGRbsp_surface *fill_sf, *sf0_sf, *sf1_sf;
IGRint                *num_segs;
IGRdouble             **str_segs, **end_segs;
{

IGRlong               stat, rc;
IGRint                free0=0, free1=0, ii, jj, ndx;
IGRint                num_u0int=0, num_u1int=0; 
IGRdouble             cht, knot_tol, upar, *arr_ptr=0, *temp_arr=0;
IGRdouble             *u0int=0, *u1int=0, fillu, fillv, mdist;
IGRpoint              fillbase;
IGRshort              option;
IGRboolean            tst_planar;
/*
IGRint                num_bdrys=0;
IGRpoint              fillpt;
IGRboolean            is_sf_planar=EMS_O_Unknown, onsurf;
struct EMSdataselect  xyzdata, uvdata;
struct EMSpypoint     *ptr=0;
*/
struct EMSsfintedpar  *bdry_parms=0;
struct EMSpypoint     *bdrys=0;

struct IGRbsp_curve   *isocv=0;
struct GRid           *l_sfid=0;
struct IGRbsp_surface *l_fill_sf=0, *l_sf=0;

struct EMSgetlp_output out_curves;
struct GRid            clip_ls;
OM_S_CHANSELECT        to_loopset;
OM_S_OBJECT_LINKAGE    obj;
IGRushort              options;
IGRint                 count = 0;
IGRpoint               startpt, endpt;

  /*
   * Initialize
   */

  opts = opts;

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  /* data check */
  EMerr_hndlr( !( fill_id && (sf0_id || sf0_sf) && (sf1_id || sf1_sf) &&
                  active_md_env && num_segs && str_segs && end_segs),
               *msg, EMS_E_InvalidData, ret_end );


  /* get surface if not available */

  if( !fill_sf)
    {
    free0 =1;
    stat = EMgetvggeom( msg,
                        &active_md_env->md_env.matrix_type,
                        active_md_env->md_env.matrix,
                        fill_id, &l_fill_sf, NULL );
    EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, ret_end );
    }
  else
    l_fill_sf = fill_sf;


  for(ii=STRT; ii<STOP; ii++)
    {

    /* get surface if not available */

    l_sf = (ii == STRT) ? sf0_sf : sf1_sf;
    l_sfid = (ii == STRT) ? sf0_id : sf1_id;

    if( !l_sf)
      {
      free1 =1;
      stat = EMgetvggeom( msg,
                          &active_md_env->md_env.matrix_type,
                          active_md_env->md_env.matrix,
                          l_sfid, &l_sf, NULL );
      EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, ret_end );
      }

    /*
     * get isocurve
     */

    BSalloccv( l_fill_sf->v_order, l_fill_sf->v_num_poles, l_fill_sf->rational,
               NULL, &isocv, &rc);
    EMerr_hndlr( (rc != BSSUCC), *msg, BSNOMEMORY, ret_end );

    upar = (ii == STRT) ? 0.0 : 1.0;
    option = 1; /* in_u_dir */
    tst_planar = 0;

    BSconstprcv( &rc, l_fill_sf, &option, &upar, &tst_planar, isocv);
    EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

    /* Linestring post does not handle weights */
    if((isocv->order == 2) && isocv->rational)
      {
      BSunwght_p( &rc, isocv->poles, isocv->weights,
                  &isocv->num_poles, isocv->poles);
      EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
      }

    BSEXTRACTPAR ( &rc, BSTOLCHRDHT, cht );

    BSsfkttol2 ( l_sf->u_order, l_sf->v_order, l_sf->u_knots,
                 l_sf->v_knots, l_sf->u_num_poles, l_sf->v_num_poles,
                 l_sf->poles, l_sf->weights, &knot_tol, &rc );
    EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

/*
 * this part is replaced by EMget_mapped_data

    xyzdata.datatype = EMSdata_curve3d;
    xyzdata.data.curve = isocv;
    is_sf_planar=EMS_O_Unknown;

    EMmapcvxyz_to_uv( &stat, NULL, l_sf, &xyzdata, cht, knot_tol,
                      &is_sf_planar, &uvdata, &onsurf );
    EMerr_hndlr( EMSerror( stat ), *msg, EMS_E_Fail, ret_end );

#ifdef DEBUG
 fprintf(stderr, "onsurf %d\n", onsurf);
#endif

    num_bdrys = 0;
    EMpypoint_free(bdrys, 0);
    EMsfintedpar_free(bdry_parms, NULL);
    stat = om$send( msg = message EMSsubbs.EMparttrim( msg,
                          &active_md_env->md_env.matrix_type,
                          &active_md_env->md_env.matrix[0],
                          &uvdata,
                          NULL, &num_bdrys, &bdrys,
                          &bdry_parms ),
                          senderid = NULL_OBJID,
                          targetid = l_sfid->objid,
                          targetos = l_sfid->osnum );

#if 0
 fprintf(stderr, "num_bdrys %d\n", num_bdrys);
#endif

    EMerr_hndlr(!num_bdrys || !(*msg & stat & 1), stat, OM_E_ABORT, ret_end);

    if(ii == STRT)
      {
      u0int = (double *) om$malloc(size = (2*num_bdrys) * sizeof(double));
      EMerr_hndlr(!(u0int), stat, EMS_E_NoDynamicMemory, ret_end);
      }
    else
      {
      u1int = (double *) om$malloc(size = (2*num_bdrys) * sizeof(double));
      EMerr_hndlr(!(u1int), stat, EMS_E_NoDynamicMemory, ret_end);
      }
 
    arr_ptr = (ii == STRT) ? u0int : u1int;

    if(ii == STRT)
      num_u0int = 2*num_bdrys;
    else
      num_u1int = 2*num_bdrys;

    ndx = 0;

    for(ptr=bdrys; ptr!=NULL; ptr=ptr->next)
      {
      if( fabs(ptr->point[0]-0.0) < EQUAL_TOL)
        ptr->point[0] = 0.0;
      if( fabs(ptr->point[1]-0.0) < EQUAL_TOL)
        ptr->point[1] = 0.0;
      BSsfeval( l_sf, ptr->point[0], ptr->point[1], 0, fillpt, &rc );
      EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

      BSmdistptsf( &rc, l_fill_sf, fillpt, &fillu, &fillv, fillbase, &mdist );
      EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

      arr_ptr[ndx++] = fillv;
      }
*/


    stat = om$make_chanselect( channame = "EMSsubbs.to_loopset",
                               p_chanselect = &to_loopset );
    EMerr_hndlr(!(stat & 1), stat, OM_E_ABORT, ret_end);

    stat = om$get_channel_objects(osnum = l_sfid->osnum, objid = l_sfid->objid,
                                  p_chanselect = &to_loopset, list = &obj, 
                                  size = 1, count = (OMuint *) &count);
    EMerr_hndlr(!(stat & 1), stat, OM_E_ABORT, ret_end);

    if(count)
      clip_ls.objid = obj.S_objid;
    else
      clip_ls.objid = NULL_OBJID;

    clip_ls.osnum = l_sfid->osnum;

    out_curves.objs = 0;
    options = 0;
    options |= EMMapBnd_WantBadCurves | EMMapBnd_WantStatMsg;
    options |= EMMapBnd_StrokeIfNeeded;
    options |= EMMapBnd_NoValidate;
    stat = EMget_mapped_data(1, &isocv, 0, const_list, l_sf, 0, 
                             active_md_env, 0, 0, 0, &out_curves, clip_ls, 
                             options, 0, msg);
    EMerr_hndlr(!(*msg & stat & 1), stat, OM_E_ABORT, ret_end);

    if(! out_curves.objs)
      EMerr_hndlr(1, *msg, EMS_E_Fail, ret_end);

    if(ii == STRT)
      {
      u0int = (double *) om$malloc(size = (2*out_curves.num_objs) * sizeof(double));
      EMerr_hndlr(!(u0int), stat, EMS_E_NoDynamicMemory, ret_end);
      }
    else
      {
      u1int = (double *) om$malloc(size = (2*out_curves.num_objs) * sizeof(double));
      EMerr_hndlr(!(u1int), stat, EMS_E_NoDynamicMemory, ret_end);
      }
 
    arr_ptr = (ii == STRT) ? u0int : u1int;

    if(ii == STRT)
      num_u0int = 2*out_curves.num_objs;
    else
      num_u1int = 2*out_curves.num_objs;

    ndx = 0;

    for(jj=0; jj<out_curves.num_objs; jj++)
      {
      stat = om$send( msg = message GRcurve.GRendpts(msg, 
                            &active_md_env->md_env.matrix_type,
                            &active_md_env->md_env.matrix[0],
                            startpt, endpt),
                      senderid = NULL_OBJID,
                      targetid = out_curves.objs[jj],
                      targetos = l_sfid->osnum );
      EMerr_hndlr(!(*msg & stat & 1), stat, OM_E_ABORT, ret_end);

      BSmdistptsf( &rc, l_fill_sf, startpt, &fillu, &fillv, fillbase, &mdist );
      EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

      arr_ptr[ndx++] = fillv;

      BSmdistptsf( &rc, l_fill_sf, endpt, &fillu, &fillv, fillbase, &mdist );
      EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

      arr_ptr[ndx++] = fillv;

      stat = om$send( msg = message GRgraphics.GRdelete( msg, active_md_env),
                      senderid = NULL_OBJID,
                      targetos = l_sfid->osnum,
                      targetid = out_curves.objs[jj] );
      EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);
      }


    /* make sure the array is sorted in ascending order */

    ndx--;

    if( arr_ptr[0] > arr_ptr[ndx] )
        {
        temp_arr = (double *) 
                    om$malloc(size = (2*out_curves.num_objs) * sizeof(double));
        EMerr_hndlr(!(temp_arr), stat, EMS_E_NoDynamicMemory, ret_end);
        for(jj=0; jj<(2*out_curves.num_objs); jj++)
          temp_arr[ndx--] = arr_ptr[jj];
        memcpy( arr_ptr, temp_arr, (2*out_curves.num_objs) * sizeof(double) );
        MEM_FREE(temp_arr);
        }

    if(free1)
      MEM_FREE(l_sf);

    if(isocv)
        BSfreecv(&rc, isocv);
    isocv = 0;

    }
  /* for ii=STRT; ii<STOP */


  /*
   * fix self intersection if any
   */

  if( (num_u0int == 2) && (fabs(u0int[0] - u0int[1]) < EQUAL_TOL) )
    u0int[1] = 1 - u0int[1];
  if( (num_u1int == 2) && (fabs(u1int[0] - u1int[1]) < EQUAL_TOL) )
    u1int[1] = 1 - u1int[1];

  stat = qq_common_segs( msg, num_u0int, num_u1int, num_segs, 
                         u0int, u1int, str_segs, end_segs);
  EMerr_hndlr( !(*msg & stat & 1), stat, OM_E_ABORT, ret_end);
          
  /*
   * for num_segs == 1, str_segs[0] may be GT end_segs[0], so swap
   */

  if( (*num_segs == 1) && ((*str_segs)[0] > (*end_segs)[0]) )
    {
    IGRdouble temp_val;
    temp_val = (*str_segs)[0];
    (*str_segs)[0] = (*end_segs)[0];
    (*end_segs)[0] = temp_val;
    }

ret_end:

  if(free0)
    MEM_FREE(l_fill_sf);

  if(free1)
    MEM_FREE(l_sf);

  if(isocv)
    BSfreecv(&rc, isocv);

  MEM_FREE(u0int);
  MEM_FREE(u1int);
  EMsfintedpar_free(bdry_parms, NULL);
  EMpypoint_free(bdrys, 0);

#ifdef DEBUG
  if( !EMSerror (stat & *msg) )
    for(jj=0; jj<*num_segs; jj++)
      {
      fprintf(stderr, "(*str_segs)[jj] %lf ", (*str_segs)[jj]);
      fprintf(stderr, "\n");
      fprintf(stderr, "(*end_segs)[jj] %lf ", (*end_segs)[jj]);
      fprintf(stderr, "\n");
      }
#endif

  EMWRAPUP (*msg, stat, "ECmf_flsfint");
  return stat;

}

static IGRlong qq_common_segs( msg, num_u0int, num_u1int, num_segs,
                               u0int, u1int, str_segs, end_segs)
IGRlong                *msg;
IGRint                 num_u0int, num_u1int, *num_segs;
IGRdouble              *u0int, *u1int, **str_segs, **end_segs;
{

  IGRlong              stat=OM_S_SUCCESS;
  IGRdouble            *tmp_arr=0, *loc_1=0, *loc_2=0;
  IGRint               *ndx_arr=0, ndx=0, ndx0, ndx1, u0_end, u1_end, sum, ii;
  IGRboolean           u0_goes_in;

  
  tmp_arr = (double *) om$malloc(size = (num_u0int+num_u1int) * sizeof(double));
  EMerr_hndlr(!(tmp_arr), *msg, EMS_E_NoDynamicMemory, ret_end);

  ndx_arr = (IGRint *) om$malloc(size = (num_u0int+num_u1int) * sizeof(IGRint));
  EMerr_hndlr(!(ndx_arr), *msg, EMS_E_NoDynamicMemory, ret_end);

  ndx  = 0;
  ndx0 = 0;
  ndx1 = 0;
  u0_end = LEFT;
  u1_end = LEFT;

  while( (ndx0 < num_u0int) || (ndx1 < num_u1int) )
    {
    if(ndx1 ==  num_u1int)
      u0_goes_in = 1;
    else if(ndx0 == num_u0int)
      u0_goes_in = 0;
    else if(u0int[ndx0] < u1int[ndx1])
      u0_goes_in = 1;
    else
      u0_goes_in = 0;

    if(u0_goes_in)
      {
      ndx_arr[ndx] = u0_end;
      tmp_arr[ndx++] = u0int[ndx0];
      if(ndx0 < num_u0int)
        ndx0++;
      u0_end = (u0_end == LEFT) ? RIGHT : LEFT;
      }
    else
      {
      ndx_arr[ndx] = u1_end;
      tmp_arr[ndx++] = u1int[ndx1];
      if(ndx1 < num_u1int)
        ndx1++;
      u1_end = (u1_end == LEFT) ? RIGHT : LEFT;
      }
    }

  loc_1 = (double *) om$malloc(size = (ndx * sizeof(double)));
  EMerr_hndlr(!(loc_1), *msg, EMS_E_NoDynamicMemory, ret_end);

  loc_2 = (double *) om$malloc(size = (ndx * sizeof(double)));
  EMerr_hndlr(!(loc_2), *msg, EMS_E_NoDynamicMemory, ret_end);

  sum = 0;
  ii=0;
  (*num_segs) = 0;
  while(ii<ndx)
    {
    sum += ndx_arr[ii];
    if(sum == 2)
      {
      loc_1[(*num_segs)] = tmp_arr[ii];
      ii++;
      loc_2[(*num_segs)] = tmp_arr[ii];
      (*num_segs) = (*num_segs) + 1;
      sum += ndx_arr[ii];
      }
    ii++;
    }

ret_end:
 
  *str_segs = loc_1;
  *end_segs = loc_2;

  MEM_FREE(tmp_arr);
  MEM_FREE(ndx_arr);

  return stat;

}
/* qq_common_segs */

end implementation EMSsubbs;
