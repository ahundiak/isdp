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

#define EQUAL_TOL 0.0001
#define ENDP_TOL  0.005
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define MEM_FREE( addr ) if ( addr ) { om$dealloc ( ptr = addr ) ; addr = 0 ; }

extern double fabs();
#define GE(a, b) ( (a>b) || (fabs(a-b) < ENDP_TOL) )
#define LE(a, b) ( (a<b) || (fabs(a-b) < ENDP_TOL) )

/*

 * DESCRIPTION

   appenddge to EMcrfilletsurf.  After the fillet is created, impose
   const V isocurves on the fillet where fillet interesects imposed boundaries
   of the surface on which the fillet is placed.


 * INPUT

   opts            FIRST_ELE : TBD
                   !FIRST_ELE: TBD

   active_md_env   usual env info
   fill_hot_v;                                                   I/O
   fill_id         GRid of the fillet
   sf0_id          GRid of sf0 on which the fillet is placed
   sf1_id          GRid of sf1 on which the fillet is placed
   fill_sf         IGRbsp_surface of the fillet (optional)
   sf0_sf          IGRbsp_surface of sf0 for sf0_id (optional)
   sf1_sf          IGRbsp_surface of sf1 for sf1_id (optional)


 * OUTPUT

   msg             EMS errors
   fill_id         the fillet is modified


 * ALGORITHM

   generate sorted arrays of V prams of u0 & u1 intersections with the
   imposed boundaries.  impose const V isocurve/s as explained in opts


* HISTORY

   pac             3/30

 */


IGRlong ECmf_newfl( msg, opts, active_md_env, num_segs, str_segs, end_segs,
                    ref_pt, ele)
                      
IGRlong               *msg;
IGRushort             opts;
struct GRmd_env       *active_md_env;
IGRint                num_segs;
IGRdouble             *str_segs, *end_segs;
IGRpoint              ref_pt;
struct ele_stack      *ele;
{

IGRlong               stat, rc;
IGRint                ii, ll, free0=0;
IGRdouble             vpar, fil_one_v=0, fil_other_v=0;
IGRshort              option;
IGRboolean            tst_planar;
IGRdouble             *fill_hot_v;                  
struct GRid           *fill_id=0;

struct IGRbsp_curve   *isocv=0;
struct IGRbsp_surface *l_fill_sf=0;

IGRint                loopst=0;
IGRdouble             ref_v=-1, fillu, fillv, mdist;
IGRpoint              fillpt;
struct EMSinters      *inters=0;
IGRboolean            is_u_increasing, uincr=0;
struct EMSintobj      *temp_ptr=0;
IGRushort             trace_opts, bool_opts;

  IGRdouble                  p_range[4];
  IGRdouble                  min_bnd_hot_v, max_bnd_hot_v;
  IGRint                     num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;

extern void EMsfintedpar_free();

  /*
   * Initialize
   */

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  /* data check */

  MF_EMerr_hndlr( !( ele && active_md_env ),
                     *msg, EMS_E_InvalidData, ret_end );


  fill_id = &ele->ele_grid;
  fill_hot_v = &ele->hot_edge;

  /*
   * get fillet sf if necessary
   */

  l_fill_sf = ele->objs_surf;

  if(! l_fill_sf)
    {
    free0 = 1;
    stat = EMgetvggeom( msg,
                        &active_md_env->md_env.matrix_type,
                        active_md_env->md_env.matrix,
                        fill_id, &l_fill_sf, NULL );
    MF_EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, ret_end );
    }

  if( (opts & CLOSE_ELE) || (opts & FIRST_ELE) ) 
    {
    if(num_segs > 1)
      {
      for(ii=0; ii<num_segs; ii++)
        {
        BSmdistptsf(&rc, l_fill_sf, ref_pt, &fillu, &fillv, fillpt, &mdist);
        MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
        if( (GE(fillv, str_segs[ii])) && (LE(fillv, end_segs[ii])) )
          {
          fil_one_v = str_segs[ii];
          fil_other_v = end_segs[ii];
          break;
          }
        }/*for*/
      }
    else /* num_segs == 1 */
      {
      fil_one_v = str_segs[0];
      fil_other_v = end_segs[0];
      }
    } /* CLOSE_ELE || FIRST_ELE */


  /*
   * if it's a closed fillet, get a new surf to replace the old one
   */

  if(opts & CLOSE_ELE)
    {
    IGRdouble extent_points_UV[2][2];
    struct GRpost_info  post_info;
    struct IGRbsp_surface *new_fil_surface=0;
    GRobjid new_objid, dumobjs[4];

    OM_S_CHANSELECT  to_loopset;

    if(fil_one_v < fil_one_v)
      {
      extent_points_UV[0][0] = 0.0;
      extent_points_UV[1][0] = 1.0;
      }
    else
      {
      extent_points_UV[0][0] = 1.0;
      extent_points_UV[1][0] = 0.0;
      }
    extent_points_UV[0][1] = fil_one_v;
    extent_points_UV[1][1] = fil_other_v;

    JANAKAextract_partial_fillet( msg, 0, l_fill_sf,
                                       extent_points_UV, ref_pt, 0,
                                       &new_fil_surface );
    MF_EMerr_hndlr( !(*msg & 1), stat, OM_E_ABORT, ret_end );

    dp$display( msg = &stat, oids = fill_id, mode = GRbe );

    post_info.construct_flag = FALSE;
    stat = om$send( msg = message GRvg.GRpostabsg(
                                  msg, active_md_env, &post_info,
                                  ( IGRchar* ) new_fil_surface,
                                  &new_objid ),
                                  senderid = NULL_OBJID,
                                  targetid = fill_id->objid,
                                  targetos = fill_id->osnum );
    MF_EMerr_hndlr( !( *msg & stat & 1 ) || ( new_objid != fill_id->objid ),
                    *msg, EMS_E_SurfaceError, ret_end );

    GRabsg_del_by_objid( &fill_id->objid, &fill_id->osnum );
    
    /* update ele */
    ele->objs_surf = new_fil_surface;

    /* del old loopset and impose new */
    stat = om$make_chanselect( channame = "EMSsubbs.to_loopset",
                               p_chanselect = &to_loopset );
    MF_EMerr_hndlr(!(stat & 1), stat, stat, ret_end);

    stat = om$send( msg = message Root.delete(0), senderid = fill_id->objid,
                    p_chanselect = &to_loopset, targetos = fill_id->osnum );
    MF_EMerr_hndlr(!(stat & 1), stat, stat, ret_end);

    stat = om$send( msg = message EMSsurface.EMmk_nat_bdry( msg, 
                                  &active_md_env->md_env, dumobjs ),
                          senderid = NULL_OBJID,
                          targetid = fill_id->objid,
                          targetos = fill_id->osnum );
    MF_EMerr_hndlr( !(*msg & stat & 1), stat, OM_E_ABORT, ret_end );

    goto ret_end;
    }/* opts & CLOSE_ELE */


  if(opts & FIRST_ELE)
    loopst = 0;
  else
    loopst = 1;

  for(ii=loopst; ii<2; ii++)
    {
  
    /*
     *  determine which isocurve
     */

    if(opts & FIRST_ELE)
      {
      if(!ii)
        vpar = fil_one_v;
      else
        vpar = fil_other_v;
      }
    else
      {
      p_range[0] = 0;
      p_range[1] = 1;
      p_range[2] = 0;
      p_range[3] = 1;
      stat = EMis_natsf(msg, fill_id, p_range, &num_mineds, &mineds,
                        &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
      MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

      MEM_FREE(mineds);
      MEM_FREE(maxeds);

      /* only for FIRST_ELE fill_hot_v=0, but just in case */
      if(fill_hot_v)
        {
        if( fabs(*fill_hot_v - min_bnd_hot_v) < EQUAL_TOL )
          {
          ref_v = max_bnd_hot_v;
          uincr = 0;
          }
        else
          {
          ref_v = min_bnd_hot_v;
          uincr = 1;
          }
        }

      vpar = -1;

      for(ll=0; ll<num_segs; ll++)
        {
        if( (GE(ref_v, str_segs[ll])) && (LE(ref_v, end_segs[ll])) )
          {
          if(uincr)
            vpar = end_segs[ll];
          else
            vpar = str_segs[ll];
          break;
          }
/* 
 * I think str_segs & end_segs are always sorted in increasing v, so don't 
 * need this!
        if( (LE(ref_v, str_segs[ll])) && (GE(ref_v, end_segs[ll])) )
          {
          vpar = str_segs[ll];
          break;
          }
 */
        }
      /* for */
      }
    /* if (! (opts & FIRST_ELE) ) */

    if(vpar == -1)
    {
#ifdef DEBUG
 fprintf(stderr, "Error determining isocv to impose\n");
 fflush(stderr);
#endif
    stat = OM_E_ABORT;
    goto ret_end;
    }

    option = 2; /* in_v_dir */
    tst_planar = 0;

    /*
     * get isocurve
     */

    BSalloccv(l_fill_sf->u_order, l_fill_sf->u_num_poles, l_fill_sf->rational,
              NULL, &isocv, &rc);
    MF_EMerr_hndlr( (rc != BSSUCC), *msg, BSNOMEMORY, ret_end );

    BSconstprcv( &rc, l_fill_sf, &option, &vpar, &tst_planar, isocv);
    MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

    /* Linestring post does not handle weights */
    if((isocv->order == 2) && isocv->rational)
      {
      BSunwght_p( &rc, isocv->poles, isocv->weights, 
                  &isocv->num_poles, isocv->poles);
      MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
      }

    /*
     * build inters list
     */

    inters = 0;
    stat = EMcvsfinters( msg, 0, active_md_env, isocv, fill_id, l_fill_sf,
                         &inters, &is_u_increasing );
    MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

    if(opts & FIRST_ELE)
      {
      if(!ii)
        uincr = 0;
      else 
        uincr = 1;
      }
    
    /*
     * check orientation of curve to be imposed
     */

    if( ( uincr && (! is_u_increasing)) ||
        (!uincr && is_u_increasing) )
      {
      temp_ptr = inters->cvs;
      do{
        temp_ptr->reversed = temp_ptr->reversed ^ 1;
        temp_ptr = temp_ptr->next;
        } while(temp_ptr != 0);
      }

    /*
     * do boolean
     */

    trace_opts = EMS_SFINT_MUSTORIENT |
                 EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_SKIPSFINT |
                 EMS_SFINT_CHTTRACETOL;


    bool_opts = EMSsfbool_opt_SingleTopology | EMSsfbool_opt_noredraw;

    dp$display( msg = &stat, oids = fill_id, mode = GRbe );

    stat = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                            active_md_env,
                                            fill_id->objid, inters, NULL_OBJID,
                                            NULL, NULL);
    MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

    dp$display( msg = &stat, oids = fill_id, mode = GRbd );

    if(inters)
      {
      IGRlong msg_loc;
/* fix for mlk */
      EMinters_data_free (&msg_loc,inters,MAXINT,NULL,EMsfintedpar_free);
      EMinters_free (inters, 0);
      inters = 0;
      }

/*
    if(isocv)
      {
      BSfreecv(&rc, isocv);
      }
*/
      isocv = 0;

    }
  /* for(ii=loopst; ii<2; ii++) */

/* if(! (opts & FIRST_ELE) ) */

 *fill_hot_v = vpar; 

ret_end:

  if(fill_id)
    dp$display( msg = &stat, oids = fill_id, mode = GRbd );

  if(free0)
    MEM_FREE(l_fill_sf);

  if(inters)
    EMinters_free (inters, 0);
  if(isocv)
    BSfreecv(&rc, isocv);

#ifdef DEBUG
  if( EMSerror (stat & *msg) )
    fprintf(stderr, "ECmf_newfl: stat %d *msg %d\n", stat, *msg);
#endif

  EMWRAPUP (*msg, stat, "ECmf_newfl");
  return stat;

}
/* ECmf_newfl */

ECmf_show_segs(msg, fill_sf, num, str_segs, end_segs)
IGRlong *msg;
struct IGRbsp_surface *fill_sf;
int num;
double *str_segs, *end_segs;
{
  IGRlong               rc=BSSUCC, stat=1, mloc=1;
  IGRint                ii;
  IGRshort              option;
  IGRboolean            tst_planar;
  IGRdouble             upar;
  struct IGRbsp_curve   *u0cv=0, *u1cv=0, *u0segs[100], *u1segs[100],
                        *isocvs[100], *isocve[100];

  option = 1; /* in_u_dir */
  tst_planar = 0;

  upar = 0.0;
  BSalloccv(fill_sf->v_order, fill_sf->v_num_poles, fill_sf->rational,
            NULL, &u0cv, &rc);
  MF_EMerr_hndlr( (rc != BSSUCC), mloc, BSNOMEMORY, ret_end );

  BSconstprcv(&rc, fill_sf, &option, &upar, &tst_planar, u0cv);
  MF_EMerr_hndlr ( rc != BSSUCC, mloc, EMS_E_BSerror, ret_end );

  upar = 1.0;
  BSalloccv(fill_sf->v_order, fill_sf->v_num_poles, fill_sf->rational,
            NULL, &u1cv, &rc);
  MF_EMerr_hndlr( (rc != BSSUCC), mloc, BSNOMEMORY, ret_end );

  BSconstprcv(&rc, fill_sf, &option, &upar, &tst_planar, u1cv);
  MF_EMerr_hndlr ( rc != BSSUCC, mloc, EMS_E_BSerror, ret_end );


  option = 2; /* in_v_dir */
  for(ii=0; ii<num; ii++)
    {

    /*
     * get & disp isocurve
     */

    BSalloccv(fill_sf->u_order, fill_sf->u_num_poles, fill_sf->rational,
              NULL, &isocvs[ii], &rc);
    MF_EMerr_hndlr( (rc != BSSUCC), mloc, BSNOMEMORY, ret_end );

    BSconstprcv(&rc, fill_sf, &option, &str_segs[ii], &tst_planar, isocvs[ii]);
    MF_EMerr_hndlr ( rc != BSSUCC, mloc, EMS_E_BSerror, ret_end );

    stat = ECmf_dispele(&mloc, 0, 0, 1, isocvs[ii]);
    MF_EMerr_hndlr (EMSerror (stat & mloc), stat, OM_E_ABORT, ret_end);

    BSalloccv(fill_sf->u_order, fill_sf->u_num_poles, fill_sf->rational,
              NULL, &isocve[ii], &rc);
    MF_EMerr_hndlr( (rc != BSSUCC), mloc, BSNOMEMORY, ret_end );

    BSconstprcv(&rc, fill_sf, &option, &end_segs[ii], &tst_planar, isocve[ii]);
    MF_EMerr_hndlr ( rc != BSSUCC, mloc, EMS_E_BSerror, ret_end );

    stat = ECmf_dispele(&mloc, 0, 0, 1, isocve[ii]);
    MF_EMerr_hndlr (EMSerror (stat & mloc), stat, OM_E_ABORT, ret_end);

    BSalloccv(fill_sf->v_order, fill_sf->v_num_poles, fill_sf->rational,
              NULL, &u0segs[ii], &rc);
    MF_EMerr_hndlr( (rc != BSSUCC), mloc, BSNOMEMORY, ret_end );

    BSpartofcv(&rc, u0cv, str_segs[ii], (str_segs[ii]+end_segs[ii])/2.0,
               end_segs[ii], u0segs[ii]);

    stat = ECmf_dispele(&mloc, 0, 0, 1, u0segs[ii]);
    MF_EMerr_hndlr (EMSerror (stat & mloc), stat, OM_E_ABORT, ret_end);

    BSalloccv(fill_sf->v_order, fill_sf->v_num_poles, fill_sf->rational,
              NULL, &u1segs[ii], &rc);
    MF_EMerr_hndlr( (rc != BSSUCC), mloc, BSNOMEMORY, ret_end );

    BSpartofcv(&rc, u1cv, str_segs[ii], (str_segs[ii]+end_segs[ii])/2.0,
               end_segs[ii], u1segs[ii]);

    stat = ECmf_dispele(&mloc, 0, 0, 1, u1segs[ii]);
    MF_EMerr_hndlr (EMSerror (stat & mloc), stat, OM_E_ABORT, ret_end);

    }

  for(ii=0; ii<num; ii++)
    {
    BSfreecv(&rc, isocvs[ii]);
    BSfreecv(&rc, isocve[ii]);
    BSfreecv(&rc, u0segs[ii]);
    BSfreecv(&rc, u1segs[ii]);
    }
  BSfreecv(&rc, u0cv);
  BSfreecv(&rc, u1cv);

ret_end:

  *msg = mloc;

  EMWRAPUP (*msg, stat, "ECmf_show_segs");

#ifdef DEBUG
    if(EMSerror(stat & mloc))
      fprintf(stderr, "err disp isocvs\n");
#endif

  return stat;
}
/* ECmf_show_segs */

end implementation EMSsubbs;
