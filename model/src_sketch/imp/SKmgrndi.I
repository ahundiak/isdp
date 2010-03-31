/*

 HISTORY
 Sudha : 7/02/93  :  Modified for BSprototypes ansification

*/

class implementation SKmgr;

#include <math.h>
#include <alloca.h>

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "asbox.h"    /* For NULL_GRID */
#include "nddef.h"    /* For ND_NC_NEW */
#include "asmacros.h" /* For as$make_source */
#include "msmacros.h"
#include "ECmsg.h"
#include "gocmacros.h"
#include "maidmx.h"
      
#include "bserr.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsmult_mats.h"
#include "bsparameters.h"

#define FIRST 0
#define MACRO_KLUDGE 1

#define X 0
#define Y 1
#define Z 2
from SKconstraint import SKpass_by_class_type, SKrecompute_yourself;
from EMSdatpln import EMget_pln_info;

%safe
static struct GRid *my_buffer_addr = NULL;
static int         my_buffer_size = 0;
%endsafe

method NDget_objects ( int type; struct GRid *ndobjs;
                       int size; struct GRid **ndobjs_buff;
                       int ifrom, ito;
                       int *num_ndobjs )
{
  int                 i, j, start_inx, stop_inx, new_size, list_count;
  OMuint              loc_count, chan_count, child_count;
  long                msg_loc, stat_OM;
  struct SKsolvevars  *p_varlist, *varlist;
  struct SKconstrinfo *constrs;
  struct GRid         *grid_ptr;
  OM_S_OBJECT_LINKAGE *list;
  OM_S_CHANSELECT     chan_to_comps, chan_to_parents, chan_to_children;

  stat_OM = OM_S_SUCCESS;
  msg_loc = EMS_S_Success;

  varlist = NULL;
  constrs = NULL;

  if (! (type & ND_ROOT))
  {
    /*
     * Obtain my dependents. Dependents consist of this managers components
     * and the variables that are designated as dependents of this sketch.
     */

    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    EMmake_chanselect (NDchildren_children, &chan_to_children);
    chan_count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
        count = &chan_count);
    om$get_channel_count (object = me, p_chanselect = &chan_to_children,
        count = &child_count);

    om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
        SK_GETVR_NDCHILDREN, &varlist, NULL, NULL), targetid = my_id);
    list_count = 0;
    p_varlist = varlist;
    while (p_varlist)
    {
      list_count++;
      p_varlist = p_varlist->next;
    }

    loc_count = chan_count + list_count + child_count;
    list = (OM_p_OBJECT_LINKAGE) alloca (loc_count *  
        sizeof(OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!list, msg_loc, EMS_E_NoStackMemory, ret_end);

    if (chan_count)
      om$get_channel_objects (object = me, p_chanselect = &chan_to_comps, 
          list = list, size = chan_count, count = &chan_count);

    if (child_count)
      om$get_channel_objects (object = me, p_chanselect = &chan_to_children, 
          list = &list[chan_count], size = child_count, count = &child_count);

    if (list_count)
    {
      p_varlist = varlist;
      for (i=0, j=chan_count+child_count; i<list_count; i++, j++)
      {
        list[j].S_objid = p_varlist->varobj;
        list[j].osnum = OM_Gw_current_OS;
      }
    }
  }
  else
  {
    /*
     * Obtain my parents. Dependents consist of this managers parents
     * on the "father" channel and the node-constraints.
     */

    EMmake_chanselect (NDfather_father, &chan_to_parents);
    chan_count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_parents,
        count = &chan_count);

    list_count = 0;
    om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
        SK_GETCN_HNDL | SK_GETCN_NDPARENTS, NULL, &list_count, &constrs),
        targetid = my_id);

    loc_count = chan_count + list_count;
    list = (OM_p_OBJECT_LINKAGE) alloca (loc_count *  
        sizeof(OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!list, msg_loc, EMS_E_NoStackMemory, ret_end);

    if (chan_count)
      om$get_channel_objects (object = me, p_chanselect = &chan_to_parents, 
          list = list, size = chan_count, count = &chan_count);

    if (list_count)
      for (i=0, j=chan_count; i<list_count; i++, j++)
      {
        list[j].S_objid = constrs[i].constrid;
        list[j].osnum = OM_Gw_current_OS;
      }
  }


  /*
   * Format the output for return
   */

  start_inx = ifrom > 0 ? ifrom : 0;
  stop_inx = ito < loc_count ? ito : loc_count-1;
  new_size = stop_inx-start_inx+1;
  *num_ndobjs = new_size;

  if (type & ND_IN_BUF)
  {
    if (new_size > my_buffer_size)
    {
      if (my_buffer_addr)
        om$dealloc (ptr = my_buffer_addr);

      my_buffer_addr = (struct GRid *) om$malloc (size = new_size *
          sizeof (struct GRid));
      EMerr_hndlr (!my_buffer_addr, msg_loc, EMS_E_NoDynamicMemory, ret_end);
      my_buffer_size = new_size;
    }
    grid_ptr = *ndobjs_buff = my_buffer_addr;
  }
  else
  {
    if (new_size > size)
      goto ret_end;
    grid_ptr = ndobjs;
  }

  for (i=start_inx; i<=stop_inx; i++)
  {
    grid_ptr->objid = list[i].S_objid;
    grid_ptr->osnum = list[i].osnum;
    grid_ptr++;
  }

ret_end :
  if (varlist)
    SKfreevarlist (varlist, MAXINT);
  if (constrs)
    om$dealloc(ptr = constrs);

  EMWRAPUP (msg_loc, stat_OM, "SKmgr.NDget_objects");
  return stat_OM;
}

/*

History
  09/15/93 : Rajiv Agrawal : Added a call to SKcalculate_profile to compute and removed lot
                             of duplicate code.
  12/15/93 : Rajiv Agrawal : Check the ND_COMP_NO_DISPLAY before setting the options for
                             SKcalculate_profile. (TR119312222)
  01/03/94 : Rajiv Agrawal : Added code to handle b-spline poles and started checking the
                             ref-plane matrix to determine if the SKmgr is out of date
                             w.r.t the plane.
  02/01/94 : Rajiv Agrawal : Changed my_id to comp_list[i].objid when finding sub_components
                             to transform bspline.  (TR119416544).
  07/13/94 : Sudha         : Delete the dim objects from rtree for a recompute
			     to avoid the problem being entered to rtree twice
			     when a dimension is modified to a very high value.
			     - fix for TR#11921307
*/


method NDupdate ( int *msg; int cn_type;
                  int count; struct GRid *list;
                  int *parent_state;
                  struct GRid *context, *new_objid;
                  struct GRmd_env *md_env )
{
  IGRboolean        update_error, flag, reset_env=FALSE, aflag=0;
  IGRushort	    options;
  long              msg_loc, stat_OM;
  double            *mat;
  struct GRid       refpln_grid, my_grid;
  struct GRmd_env   recomp_env, orig_env;
  struct ret_struct ret_struct;
  enum GRdpmode     display_mode;
  OM_S_CHANSELECT   chan_to_parent, chan_to_comps;
  IGRboolean        save_br;
  GRspacenum        osn;
  extern int	    SKcalcuate_profile();
  extern void       SKgetgeomtype(), SKgetmatrix();

  aflag = pwIsActivationOn();
  osn = pwGetActiveOs();

/*
 * Remove the macro kludge if France sets ASbroadcast_in_progress to TRUE
 * during placement of a construction macro.
 */

#if MACRO_KLUDGE
  {
    extern IGRboolean ASbroadcast_in_progress;

    save_br = ASbroadcast_in_progress;

    ASbroadcast_in_progress = 1;
  }
#endif

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  update_error = FALSE;
  new_objid->objid = my_id;
  new_objid->osnum = OM_Gw_current_OS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS; 

  /*
   * If this manager is not out of date with it's drivers, then do nothing
   */

  if (! (ME.SKmgr->props & SK_MGR_OUTOFDATE || 
         ME.SKmgr->props & SK_MGR_PLN_OUTOFDATE))
     goto ret_end;

  /*
   * Unless inhibited, erase this geometry
   */

  if (!(cn_type & ND_COMP_NO_ERASE))
  {
    display_mode = GRbe;
    om$send (msg = message SKmgr.NDdisplay (NULL, display_mode, md_env),
             targetid = my_id);
  }

  /*
   * Recomputation is being done outside the rtree to simplify the
   * the conflicting demands from macro copy/recomputation and 
   * recomputation when a parent is changed. Further, it ensures that we do not
   * mess up the rtree should the recomputation fail. So first, unless
   * inhibited, remove the object from the R-tree.
   */

  if (!(cn_type & ND_COMP_NO_REM_RT) && (md_env->md_id.objid != NULL_OBJID)) 
  {
    om$send (msg = message GRgraphics.GRremwrng (&msg_loc, md_env),
             targetid = my_id);

    /* when the dimension is edited to a very high value from its original
       value the old dim object is not removed from rtree. Since we send
       a md_env.md_id.objid = NULL_OBJID for recompute NDs_compute_node()
       receives a NULL_OBJID and hence it is still part of rtree. This was
       causing abort when the modified profile is located later. To fix the
       problem, when the sketch objects are removed from rtree the dimension
       objects are also removed from rtree and added at the end */
    flag = TRUE;
    SKremove_dimobjs_from_rtree( &my_grid, md_env, flag);
   }

  if(aflag && osn==OM_Gw_current_OS)
  {
    orig_env = *md_env;
    pwGetActiveModuleEnv(md_env);
    reset_env = TRUE;
  }

  /*
   * This sketch manager is now updated. 
   * 
   * First:
   * If this object is out of sync with it's plane (PLN_OUTOFDATE) then
   * update the origin, xaxis, normal in the instance data of this manager 
   * from the definition of the datum plane. The internal points are invariant
   * with the change in ref-plane orientation, since they are recorded
   * in the local 2D-coordinates. The dimensions and other expressions
   * are also invariant in this transform.
   */

  recomp_env = *md_env;
  recomp_env.md_id.objid = NULL_OBJID;

  EMmake_chanselect (NDfather_father, &chan_to_parent);
  refpln_grid.objid = NULL_OBJID;
  stat_OM = om$get_objid_at_index (object = me, p_chanselect = &chan_to_parent,
                                   index = FIRST, objidaddr = &refpln_grid.objid, 
                                   osnumaddr = &refpln_grid.osnum);
  if (!IF_NULL_OBJID (refpln_grid.objid))
  {
    ret_struct.type = NULL;
    om$send (msg = message NDnode.NDgive_structure 
                   (&msg_loc, &ret_struct, md_env), 
             targetid = refpln_grid.objid, targetos = refpln_grid.osnum);

    if (ret_struct.type == ref_generic)
    {
      IGRushort			gmtype;
      OMuint 			num_comps, num_sub_comps;
      int       		i,j;
      double 			tol, distsq, dotpx, dotpz;
      IGRpoint  		origpt;
      IGRpoint  		loc_origpt;
      IGRvector 		xaxis, zaxis;
      IGRvector 		loc_xaxis, loc_zaxis;
      IGRmatrix 		trans_mat, hmat1, hmat_t1, hmat2, hmat_t2;
      OM_S_OBJECT_LINKAGE 	*comp_list, *sub_comp_list;

      /*
      * Use the transpose of the matrix returned by NDgive_structure to
      * get consistent results with coordinate systems, and other entities
      * that respond to NDgive_structure etc. 
      * pp 12/9/91
      */
      mat = ret_struct.var.ref_st.t;
      for (i=0;i<4;i++)
       for (j=0;j<4;j++)
         trans_mat[4*i+j] = mat[4*j+i];

      /*
       * Check if the orientation stored in the instance data is the same
       * as the the one given by the ref-plane/coord-system.
       */
      om$send ( msg = message SKmgr.SKgetornt (&msg_loc, origpt, xaxis, zaxis),
                targetid = my_id );
 
      memcpy(loc_xaxis, xaxis, sizeof(IGRvector));
      memcpy(loc_zaxis, zaxis, sizeof(IGRvector));
      memcpy(loc_origpt, origpt, sizeof(IGRpoint));

      if(aflag)
      {
        stat_OM = RFtransform( md_env->md_env.matrix,
                               md_env->md_env.matrix_type,
                               FALSE, loc_xaxis, NULL, loc_zaxis, loc_origpt);
      }

      ME.SKmgr->props |= SK_MGR_PLN_OUTOFDATE;
      BSEXTRACTPAR ( &msg_loc, BSTOLSQLENVEC, tol );

      distsq = BSdistptpts(&msg_loc, loc_origpt, &trans_mat[12]);

      if (distsq < tol) 
      {
        dotpx = fabs(1.0 - BSdotp (&msg_loc, loc_xaxis, &trans_mat[XAXIS_PLANEMAT_INX]));
        BSEXTRACTPAR ( &msg_loc, BSTOLCOLLINVEC, tol );
        if (dotpx < tol) 
        {
          dotpz = fabs(1.0 - BSdotp (&msg_loc, loc_zaxis, &trans_mat[ZAXIS_PLANEMAT_INX]));
          if (dotpz < tol)
            ME.SKmgr->props &= ~SK_MGR_PLN_OUTOFDATE;
        }
      }
        
      /*
       * The ref-plane orientation has changed.  Update the instance data
       * and transform the poles of any bspline profile elements.
       */
      if (ME.SKmgr->props & SK_MGR_PLN_OUTOFDATE) 
      {
        SKgetmatrix(&msg_loc, loc_origpt, loc_zaxis, loc_xaxis, hmat1, hmat_t1);

        if(aflag)
        {
          /*
           * The info in trans_mat is in world space and cannot be directly
           * posted to the instance. It has to be transformed to ref-space
           * by the inverse of the module matrix.
           */
          IGRpoint ref_orig;
          IGRvector ref_xvec, ref_zvec;

          memcpy(ref_orig, &trans_mat[12], sizeof(IGRpoint));
          memcpy(ref_xvec, &trans_mat[XAXIS_PLANEMAT_INX], sizeof(IGRvector));
          memcpy(ref_zvec, &trans_mat[ZAXIS_PLANEMAT_INX], sizeof(IGRvector));

          stat_OM = RFtransform( md_env->md_env.matrix,
                                 md_env->md_env.matrix_type,
                                 TRUE, ref_xvec, NULL, ref_zvec, ref_orig);

          om$send (msg = message SKmgr.SKputornt (&msg_loc, ref_orig, 
                                                  ref_xvec, ref_zvec),
                   targetid = my_id);

          SKgetmatrix (&msg_loc, &trans_mat[12], &trans_mat[ZAXIS_PLANEMAT_INX],
                       &trans_mat[XAXIS_PLANEMAT_INX], hmat2, hmat_t2);
        }
        else
        {
          om$send (msg = message SKmgr.SKputornt (&msg_loc, &trans_mat[12], 
                       &trans_mat[XAXIS_PLANEMAT_INX], &trans_mat[ZAXIS_PLANEMAT_INX]),
                 targetid = my_id);
          SKgetmatrix (&msg_loc, &trans_mat[12], &trans_mat[ZAXIS_PLANEMAT_INX],
                     &trans_mat[XAXIS_PLANEMAT_INX], hmat2, hmat_t2);
        }
  
        BSmult_mats(4, 4, hmat_t2, FALSE, 4, 4, hmat1, FALSE, trans_mat, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);

        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
        stat_OM = om$get_channel_count (objid = my_id,
                                        p_chanselect = &chan_to_comps,
                                        count = &num_comps);
        EMerr_hndlr (!(stat_OM & 1) || !num_comps, *msg, EMS_E_Fail, ret_end);

        comp_list = (OM_S_OBJECT_LINKAGE *) alloca (num_comps * sizeof (OM_S_OBJECT_LINKAGE));
        stat_OM = om$get_channel_objects ( list = comp_list, size = num_comps, 
                                           count = &num_comps, 
                                           objid = my_id, 
                                           p_chanselect = &chan_to_comps);
        if (!(stat_OM & 1)) goto ret_end;
        for (i=0; i<num_comps; i++)
        {
          SKgetgeomtype(comp_list[i].S_objid, comp_list[i].osnum, &gmtype);
          if (gmtype & SK_BSPLINE)
          {
            SKxform_bspline (&msg_loc, &recomp_env, comp_list[i].S_objid, comp_list[i].osnum,
                             trans_mat);
          }
          else if (gmtype & SK_COMPCURVE)
          {
            stat_OM = om$get_channel_count (objid = comp_list[i].S_objid,
                                            osnum = comp_list[i].osnum,
                                            p_chanselect = &chan_to_comps,
                                            count = &num_sub_comps);
            EMerr_hndlr (!(stat_OM & 1) || !num_sub_comps, *msg, EMS_E_Fail, ret_end);
            
            sub_comp_list = (OM_S_OBJECT_LINKAGE *) alloca (num_sub_comps * sizeof (OM_S_OBJECT_LINKAGE));
            stat_OM = om$get_channel_objects ( list = sub_comp_list, size = num_sub_comps, 
                                               count = &num_sub_comps, 
                                               objid = comp_list[i].S_objid, 
                                               osnum = comp_list[i].osnum,
                                               p_chanselect = &chan_to_comps);
            if (!(stat_OM & 1)) goto ret_end;
            for (j=0; j<num_sub_comps; j++)
            {
              SKgetgeomtype (sub_comp_list[j].S_objid, sub_comp_list[j].osnum, &gmtype);
              if (gmtype & SK_BSPLINE)
              {
                SKxform_bspline (&msg_loc, &recomp_env, sub_comp_list[j].S_objid, 
                                 sub_comp_list[j].osnum, trans_mat);
              }
            }
          }
        }
        ME.SKmgr->props |= SK_MGR_OUTOFDATE;
        ME.SKmgr->props &= ~SK_MGR_PLN_OUTOFDATE;
      }
    }
  }

  /*
   * Second:
   * If the sketch variables need to be recomputed, do so.
   */

  if (ME.SKmgr->props & SK_MGR_OUTOFDATE && !update_error)
  {
    options = SK_UPDATE_IMPCONSTRS | SK_UPDATE_EXPCONSTRS;
    if (!(cn_type & ND_COMP_NO_DISPLAY))
      options |= SK_UPDATE_DRAW; 
    stat_OM = SKcalculate_profile (&msg_loc, options, &recomp_env, &my_grid);
  }
  
  /*
   * The profile has been recomputed. Set the module env back to original
   * before we go for display and rtree update.
   */
  if(reset_env)
  {
    *md_env = orig_env;
    reset_env = FALSE;
  }

  /*
   * Unless inhibited, draw this geometry
   */

  if (!(cn_type & ND_COMP_NO_DISPLAY))
  {
    display_mode = GRbd;
    om$send (msg = message SKmgr.NDdisplay (NULL, display_mode, md_env),
             targetid = my_id);
  }

  /*
   * Unless inhibited, add the object back into the R-tree.
   */
  
  if (!(cn_type & ND_COMP_NO_ADD_RT) && (md_env->md_id.objid != NULL_OBJID))
    om$send (msg = message GRgraphics.GRaddwrng (&msg_loc, md_env),
             targetid = my_id);
      
/*  
    
 * If context is coming in then transfer symbology based on the context.
 * This usually happens during recomputation of an entity in a const
 * macro.
 * pp 07/28/92
 */
   
   if (context->objid != NULL_OBJID)
     SKtrans_symb(*context, my_grid);


 /* add dimension objects back to rtree */
  if (!(cn_type & ND_COMP_NO_ADD_RT) && (md_env->md_id.objid != NULL_OBJID))
  {   flag = FALSE;
     SKremove_dimobjs_from_rtree( &my_grid, md_env, flag);
  };

ret_end:
/*
 * Call this macro so that version tag gets updated.
 */

  GR_NOTIFY_LISTENERS(&msg_loc, &stat_OM, GR_GEOM_MODIFIED);
#if MACRO_KLUDGE
  {
    extern IGRboolean ASbroadcast_in_progress;

    ASbroadcast_in_progress = save_br;
  }
#endif
  if (update_error)
    *msg = ND_COMP_FAIL;
  else
    *msg = ND_COMP_SUCC;

  if(reset_env)
  {
    *md_env = orig_env;
  }

  EMWRAPUP (*msg, stat_OM, "SKmgr.NDudpate");
  return stat_OM;
}


method NDdisplay ( int dp_type; enum GRdpmode dpmode; struct GRmd_env *env )
{
  short           mattyp;
  long            msg_loc;
  double          *mat;
  IGRmatrix       idmat;
  struct GRid     mod_grid;
  OM_S_CHANSELECT chan_to_cnstrs;

  if (!env)
  {
    mattyp = MAIDMX;
    MAidmx (&msg_loc, idmat);
    mat = idmat;
  }
  else
  {
    mattyp = env->md_env.matrix_type;
    mat = env->md_env.matrix;
  }

  GRfindmod (&mod_grid);
  om$send (msg = message GRowner.GRdisplay (&msg_loc, &mattyp, mat, &dpmode,
      &mod_grid), mode = OM_e_wrt_message, targetid = my_id);

  EMmake_chanselect (SKmgr_to_constrs, &chan_to_cnstrs);
  om$send (msg = message SKconstraint.SKpass_by_class_type (&msg_loc,
      message GRgraphics.GRdisplay (&msg_loc, &mattyp, mat, &dpmode, &mod_grid),
      SK_PASS_IMPLICIT_CLASS), p_chanselect = &chan_to_cnstrs);

  return OM_S_SUCCESS;
}


method NDmake_source ( long *msg;
                       struct GRid *located_obj,*context;char *path;
                       GRspacenum as_osnum; struct GRid *as)
{
 IGRlong sts, loc_msg;

 *msg = EMS_S_Success;

 as->objid = NULL_OBJID;

 if (context->objid != NULL_OBJID)
 {
  sts = ASmake_source_from_go(&loc_msg, located_obj,context,
                                 as_osnum, as);
  if (!(1&sts&loc_msg)) *msg = MSFAIL;
 }
 else
  *as = *located_obj;

 return (OM_S_SUCCESS);
}


method GRaddwrng ( long *EMmsg; struct GRmd_env *md_info )
{
  OM_S_CHANSELECT to_constrs;

  *EMmsg = EMS_S_Success;

  EMmake_chanselect (SKmgr_to_constrs, &to_constrs);
  om$send (msg = OPPmargs, p_chanselect = &to_constrs);

  om$send (msg = message GRowner.GRaddwrng (EMmsg, md_info),
      mode = OM_e_wrt_message, targetid = my_id);

  return OM_S_SUCCESS;
}


method GRremwrng ( long *EMmsg; struct GRmd_env *md_info )
{
  OM_S_CHANSELECT to_constrs;

  *EMmsg = EMS_S_Success;

  EMmake_chanselect (SKmgr_to_constrs, &to_constrs);
  om$send (msg = OPPmargs, p_chanselect = &to_constrs);

  om$send (msg = message GRowner.GRremwrng (EMmsg, md_info),
      mode = OM_e_wrt_message, targetid = my_id);

  return OM_S_SUCCESS;
}

method ASreturn_go ( struct GRid * go; short *mat_type; double *matrix )
{
  long            msg;
  struct GRmd_env mod_env;
  int             sizbuf, nret;

  go->objid = my_id;
  go->osnum = OM_Gw_current_OS;


  if (matrix && mat_type)
  {
    sizbuf = sizeof(struct GRmd_env);

    gr$get_module_env ( msg = &msg,
        sizbuf = &sizbuf,
        buffer = &mod_env,
        nret = &nret );

    *mat_type = mod_env.md_env.matrix_type;

    memcpy (matrix, mod_env.md_env.matrix, sizeof(IGRmatrix));
  }

  return OM_S_SUCCESS;
}


/*

Name
 NDmove_to_root 
 
Abstract
 
Synopsis
 long *EMmsg; 
 struct GRid *src_grid; 
 struct GRmd_env *md_env;
Description

Return Value

Notes

Index

Keywords
  profile, move, root
History
  Unknown  : Unknown        : creation
  07/19/93 : Carlos M. Diaz : fixed TR#119304406 and put header

 */
method NDmove_to_root ( long *EMmsg; struct GRid *src_grid; struct GRmd_env *md_env )
{
  long            status, msg_loc;
  int             Ok;
  OM_S_CHANSELECT chan_to_parent;
  struct GRid     refpln_grid;
  OM_S_OBJID      new_objid;
  struct GRid     new_GRid, my_GRid;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  EMmake_chanselect (NDfather_father, &chan_to_parent);
  refpln_grid.objid = NULL_OBJID;
  src_grid->objid = NULL_OBJID;

  om$get_objid_at_index (object = me, p_chanselect = &chan_to_parent,
      index = FIRST, objidaddr = &refpln_grid.objid, 
      osnumaddr = &refpln_grid.osnum);
  /*
   * If the move_to_root message was sent by the reference plane or by
   * myself or by the drop associativity command then return my copy which 
   * is going to be non-associative.
   */

  if ((sender_id == refpln_grid.objid) || (sender_id == my_id))
    Ok = 1;
  else
  {
    GRclassid        ClassId = 0;
    extern GRclassid OPP_COadd_opt_class_id;
    
    om$get_classid ( osnum = sender_os, objid = sender_id, p_classid = &ClassId );
    Ok = om$is_ancestry_valid ( subclassid = ClassId,
      superclassid = OPP_COadd_opt_class_id ) == OM_S_SUCCESS;
  }
  
  if (Ok)
  {
    OM_S_CHANSELECT chan_to_comps;
    OMuint my_comp_count;

    OM_S_CHANSELECT chan_to_owners;
    OMuint my_owners_count;

    status = om$send (msg = message GRgraphics.GRcopy ( EMmsg, md_env, md_env,
        &new_objid ), targetid = my_id );
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_owners);

    my_comp_count = 0;
    my_owners_count = 0;
    
    /*
     * If I only have one component, then the copy returns the component
     * itself instead of a graphic group. 
     * Hence we need to transfer connections on my component to the
     * new guy.
     */
    om$get_channel_count ( objid = my_id, p_chanselect = &chan_to_comps,
        count = &my_comp_count);
    src_grid->objid = new_objid;
    if (my_comp_count == 1)
    {
      status = om$get_objid_at_index(objid = my_id,
          p_chanselect = &chan_to_comps,
          index = 0,
          objidaddr = &my_GRid.objid,
          osnumaddr = &my_GRid.osnum);
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
    }
    else
    {
      my_GRid.objid = my_id;
      my_GRid.osnum = OM_Gw_current_OS;
    }

    new_GRid.objid = new_objid;
    new_GRid.osnum = md_env->md_id.osnum;

    ppmove_chan(my_GRid,new_GRid,&msg_loc);
    
   /* CMD 07/19/93 */
    /*
     * now take care of owners
     */
    
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    new_GRid.objid = new_objid;
    new_GRid.osnum = md_env->md_id.osnum;

    ppmove_chan_owners(my_GRid,new_GRid,&msg_loc);
   /* CMD 07/19/93 */
  }


wrapup:
  om$send (msg = message GRgraphics.GRdelete ( &msg_loc, md_env ),
      targetid = my_id);

  return status;
}

/*

Name
 ppmove_chan

Abstract
 moves children from one object to another
Synopsis
 struct GRid fr_GRid;
 struct GRid to_GRid;
 long *EMmsg;
Description
 
Return Value
 
Notes

Index

Keywords
 profile, move, channel
History
  Unknown : Unknown : created

*/
ppmove_chan(fr_GRid, to_GRid, EMmsg)
struct GRid fr_GRid, to_GRid;
long *EMmsg;
{
  OM_S_CHANSELECT chan_to_comps, to_children;
  int 		  i;
  OMuint 	  to_chan_count = 0, fr_chan_count=0, child_count=0;
  long 		  status;
  struct GRid 	  src_to_GRid;

  *EMmsg = MSSUCC;
  status = OM_S_SUCCESS;
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  EMmake_chanselect (NDchildren_children, &to_children);

  child_count = 0;
  om$get_channel_count (objid = fr_GRid.objid, 
      osnum = fr_GRid.osnum,
      p_chanselect = &to_children,
      count = &child_count);

  if (child_count)
  {
    status = as$make_source(go_grid = to_GRid,
        as_grid = &src_to_GRid);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

    status = om$send (msg = message Root.move_chan(to_children, 
        fr_GRid.objid, fr_GRid.osnum, to_children),
        senderid = fr_GRid.objid,
        targetid = src_to_GRid.objid,
        targetos = src_to_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  }

  fr_chan_count = 0;
  om$get_channel_count (objid = fr_GRid.objid, 
      osnum = fr_GRid.osnum,
      p_chanselect = &chan_to_comps,
      count = &fr_chan_count);

  to_chan_count = 0;
  om$get_channel_count (objid = to_GRid.objid, 
      osnum = to_GRid.osnum,
      p_chanselect = &chan_to_comps,
      count = &to_chan_count);

  if (fr_chan_count != to_chan_count) goto wrapup;

  for (i=0;i<fr_chan_count;i++)
  {
    struct GRid comp_fr_GRid, comp_to_GRid;

    status = om$get_objid_at_index(objid = fr_GRid.objid,
        osnum = fr_GRid.osnum,
        p_chanselect = &chan_to_comps,
        index = i,
        objidaddr = &comp_fr_GRid.objid,
        osnumaddr = &comp_fr_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

    status = om$get_objid_at_index(objid = to_GRid.objid,
        osnum = to_GRid.osnum,
        p_chanselect = &chan_to_comps,
        index = i,
        objidaddr = &comp_to_GRid.objid,
        osnumaddr = &comp_to_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
    ppmove_chan(comp_fr_GRid, comp_to_GRid, EMmsg);
  }

wrapup:
  return status;
}


/*

Name
 ppmove_chan_owners

Abstract
 moves owners from one object to another
Synopsis
 struct GRid fr_GRid;
 struct GRid to_GRid;
 long *EMmsg;
Description
 
Return Value
 
Notes
 cloned from ppmove_chan
Index

Keywords
  profile, move, channel
History
  07/19/93 : Carlos M. Diaz : created

*/
ppmove_chan_owners(fr_GRid, to_GRid, EMmsg)
struct GRid fr_GRid, to_GRid;
long *EMmsg;
{
  OM_S_CHANSELECT chan_to_owners;
  int 		  i;
  OMuint 	  to_chan_count = 0, fr_chan_count=0, owners_count=0;
  long 		  status;

  *EMmsg = MSSUCC;
  status = OM_S_SUCCESS;
  EMmake_chanselect (GRconnector_to_owners, &chan_to_owners);

  owners_count = 0;
  om$get_channel_count (objid = fr_GRid.objid, 
      osnum = fr_GRid.osnum,
      p_chanselect = &chan_to_owners,
      count = &owners_count);

  if (owners_count)
  {
    status = om$send (msg = message Root.move_chan(chan_to_owners, 
        fr_GRid.objid, fr_GRid.osnum, chan_to_owners),
        senderid = fr_GRid.objid,
        targetid = to_GRid.objid,
        targetos = to_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
  }

  fr_chan_count = 0;
  om$get_channel_count (objid = fr_GRid.objid, 
      osnum = fr_GRid.osnum,
      p_chanselect = &chan_to_owners,
      count = &fr_chan_count);

  to_chan_count = 0;
  om$get_channel_count (objid = to_GRid.objid, 
      osnum = to_GRid.osnum,
      p_chanselect = &chan_to_owners,
      count = &to_chan_count);

  if (fr_chan_count != to_chan_count) goto wrapup;

  for (i=0;i<fr_chan_count;i++)
  {
    struct GRid comp_fr_GRid, comp_to_GRid;

    status = om$get_objid_at_index(objid = fr_GRid.objid,
        osnum = fr_GRid.osnum,
        p_chanselect = &chan_to_owners,
        index = i,
        objidaddr = &comp_fr_GRid.objid,
        osnumaddr = &comp_fr_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

    status = om$get_objid_at_index(objid = to_GRid.objid,
        osnum = to_GRid.osnum,
        p_chanselect = &chan_to_owners,
        index = i,
        objidaddr = &comp_to_GRid.objid,
        osnumaddr = &comp_to_GRid.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
    ppmove_chan_owners(comp_fr_GRid, comp_to_GRid, EMmsg);
  }

wrapup:
  return status;
}

SKtrans_symb(context, my_GRid)
struct GRid context;
struct GRid my_GRid;
{
 IGRlong msg_loc, status;
 IGRshort  props, action;

 status = OM_S_SUCCESS;
 msg_loc = EMS_S_Success;

 ACtrans_symb(context, my_GRid);
 action = 0;
 props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

 status = om$send(msg = message GRvg.GRchgprops(&msg_loc,
                           &action, &props),
          senderid = NULL_OBJID,
     	  targetid = my_GRid.objid,
          targetos = my_GRid.osnum);
 EMerr_hndlr(!(1&status&msg_loc), msg_loc, EMS_E_Fail, wrapup);

 action = 1;
 props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;

 status = om$send(msg = message GRvg.GRchgprops(&msg_loc,
                           &action, &props),
                 senderid = NULL_OBJID,
                 mode = OM_e_wrt_message,
     	  targetid = my_GRid.objid,
          targetos = my_GRid.osnum);
 EMerr_hndlr(!(1&status&msg_loc), msg_loc, EMS_E_Fail, wrapup);

wrapup:
 return (status);
}

SKremove_dimobjs_from_rtree(mgr_id, md_env, is_remove)
struct GRid	*mgr_id;
struct GRmd_env *md_env;
IGRboolean	is_remove;
{
  long              msg_loc, stat_OM, j, k;
  OMuint	    num_constr = 0;
  OM_S_CHANSELECT   to_constraints;
    
  extern GRclassid 	OPP_SKexplicit_class_id;
  extern GRclassid      OPP_DMroot_class_id;  

    msg_loc = stat_OM = OM_S_SUCCESS;

    EMmake_chanselect (SKmgr_to_constrs, &to_constraints);
    
    stat_OM = om$get_channel_count (objid = mgr_id->objid,
                                    p_chanselect = &to_constraints,
                                    count = &num_constr);
    if (!(stat_OM & 1)) goto ret_end;

    if ( num_constr ) 
    {

      GRclassid 	       classid = 0;
      OM_S_OBJECT_LINKAGE      *constr_list;

	/* check its class for SKexplicit */
        constr_list = (OM_S_OBJECT_LINKAGE *) alloca ( num_constr * 
					sizeof (OM_S_OBJECT_LINKAGE));

        stat_OM = om$get_channel_objects ( list = constr_list, 
					   size = num_constr, 
                                           count = &num_constr, 
                                           objid = mgr_id->objid, 
                                           p_chanselect = &to_constraints);
        if (!(stat_OM & 1)) goto ret_end;

	for ( k = 0; k < num_constr; k ++ ) 
	{
          om$get_classid ( osnum = constr_list[k].osnum,
			   objid = constr_list[k].S_objid, 
			   p_classid = &classid );

	  if ( om$is_ancestry_valid ( subclassid = classid,
                                    superclassid = OPP_SKexplicit_class_id ) == OM_S_SUCCESS )
	  {
	      OMuint	 		dim_comp_count = 0;
	      OM_S_CHANSELECT		to_comps;
	      OM_S_OBJECT_LINKAGE       *dim_comp_list;

              EMmake_chanselect (GRcmpowner_to_components, &to_comps);

              stat_OM = om$get_channel_count (objid = constr_list[k].S_objid,
                                              osnum = constr_list[k].osnum,
                                              p_chanselect = &to_comps,
                                              count = &dim_comp_count);
              if (!(stat_OM & 1)) goto ret_end;            

	      if ( dim_comp_count ) 
	      {	
                 dim_comp_list = (OM_S_OBJECT_LINKAGE *) alloca (dim_comp_count * 
					     sizeof (OM_S_OBJECT_LINKAGE));

                 stat_OM = om$get_channel_objects (list = dim_comp_list, 
						   size = dim_comp_count, 
                                                   count = &dim_comp_count, 
                                                   objid = constr_list[k].S_objid, 
                                                   osnum = constr_list[k].osnum,
                                                   p_chanselect = &to_comps);
                 if (!(stat_OM & 1)) goto ret_end;

  	         for ( j = 0; j < dim_comp_count; j ++ )
	         {
      	           GRclassid 	      dim_classid = 0;

	   	   om$get_classid ( osnum = dim_comp_list[j].osnum,
		   	            objid = dim_comp_list[j].S_objid, 
			            p_classid = &dim_classid );

     	           if ( om$is_ancestry_valid ( subclassid = dim_classid,
                                              superclassid = OPP_DMroot_class_id ) == OM_S_SUCCESS )
	           {
		     if ( is_remove )
                         om$send (msg = message GRgraphics.GRremwrng (&msg_loc,
								      md_env),
				  senderid = NULL_OBJID,
                                  targetid = dim_comp_list[j].S_objid,
				  targetos = dim_comp_list[j].osnum);
		     else
                         om$send (msg = message GRgraphics.GRaddwrng (&msg_loc,
								      md_env),
				  senderid = NULL_OBJID,
                                  targetid = dim_comp_list[j].S_objid,
				  targetos = dim_comp_list[j].osnum);

                   } /* if DMroot */
	
	         } /* for j */

	      } /* if dim_comp_count */

	  } /* if SKexplicit */

       } /* for k */
   
     } /* if num_constr */     

ret_end:
     return(stat_OM);

}

end implementation SKmgr;
