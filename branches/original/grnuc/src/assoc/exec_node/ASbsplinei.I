class implementation ASbspline;

#include "AS_status.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "grownerdef.h"
#include "lcmsg.h"
#include "grerr.h"
#include "DEsomacros.h"

#define AS_DEBUG 1


method GRptseqspace(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		     IGRpoint point1,point2,point3; 
		     struct GRparms *p1,*p2,*p3; IGRlong *num;
		     IGRdouble *out_points)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRptalong(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		  IGRpoint point1,point2; struct GRparms *p1,*p2;
		  IGRdouble *dist; IGRpoint out_point)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRendpts(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRpoint startpt,endpt)
{
IGRint status;
struct GRid my_grid,null_grid,modifier;

if(me->state & ND_DIS_BY_CH)
  { 
   my_grid.objid=my_id;
   my_grid.osnum=OM_Gw_current_OS;
   null_grid.objid = NULL_OBJID;
   ASfind_modifier(my_grid,null_grid,&modifier);
   if(!IF_NULL_OBJID(modifier.objid))
     {status = om$send(msg = OPPmargs,
	      	       targetid = modifier.objid);
      return(status);
     }
  }
   status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
   return(status);
}

method GRmidpoint(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		   struct GRparms *ref_parms; IGRpoint midpoint)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRcenter(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRpoint center)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRperbis(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 struct GRparms *ref_parms; IGRvector norm_vc; IGRpoint
		 proj_pt; struct IGRbsp_curve *bisector)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRinsvertex(IGRlong *msg; struct GRmd_env *md_env;
		    struct GRparms *ref_parms; struct IGRline *boreline;
		    GRobjid *new_objid)
{
  *msg = MSFAIL;
  *new_objid = my_id;

  /*| Don't allow to insert a vertex to  an associtive object */

  return(OM_S_SUCCESS);

}

method GRdelvertex(IGRlong *msg; struct GRmd_env *md_env;
		    struct GRparms *ref_parms; GRobjid *new_objid)
{
  *msg = MSFAIL;
  *new_objid = my_id;

  /*| Don't allow to delete a vertex to  an associtive object */

  return(OM_S_SUCCESS);
}

    
method GR2ptpartdel(IGRlong *msg; struct GRmd_env *env; IGRpoint point1,
		      point2; struct GRparms *p1, *p2; GRobjid *c1,*c2; 
		      IGRshort *num)
{
 *msg = MSFAIL;
 *num = 1;
 *c1  = my_id;
 *c2  = NULL_OBJID;

 /*| Don't allow to partial delete by 2 points for this associtive object */

return(OM_S_SUCCESS);
}



method GR3ptpartdel(IGRlong *msg; struct GRmd_env *env; IGRpoint point1,
		      point2,point3; struct GRparms *p1, *p2, *p3;
		      GRobjid *c1, *c2; IGRshort *num)
{
 *msg = MSFAIL;
 *num = 1;
 *c1  = my_id;
 *c2  = NULL_OBJID;

 /*| Don't allow to partial delete by 3 points for this associtive object */

return(OM_S_SUCCESS);
}

method GRarea(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
	       IGRdouble *area)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRarclength(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		    IGRpoint point1,point2,point3; struct GRparms *p1,
		    *p2,*p3; IGRdouble *arclength)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRptextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint,
		   ext_pt, new_end)
{
  *msg = MSFAIL;

 /*| No extend for this associative object */

 return(OM_S_SUCCESS);
}

method GRdisextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint; 
	  	    IGRdouble *dist; IGRpoint new_end)
{
 /*| No extend for this associative object */
 return(OM_S_SUCCESS);
}


method GRsplit(IGRlong *msg; struct GRmd_env *env; IGRpoint point;
		struct GRparms *parm; GRobjid *c1, *c2; IGRshort *num)
{
 *msg = MSFAIL;
 *num = 1;
 *c1  = my_id;
 *c2  = NULL_OBJID;

 /*| Don't allow to split an associtive object */

 /* chaque type d'object pourrait overrider cette methode pour en faire 
 /* un split assoc (par example le ASby2ptsg pourrait creer 2 segments assoc)
 /**/
return(OM_S_SUCCESS);
}


method GRcpparallel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                    struct GRmd_env *offset_env; 
                    struct IGRline *direction_boreline; 
 	            struct IGRline *distance_boreline; 
	            IGRdouble *distance; IGRboolean *apparent_flag;
     	            IGRmatrix projection_matrix; GRobjid *objid)
{
  *msg   = MSFAIL;
  *objid = NULL_OBJID;
  return(OM_S_SUCCESS);
}


method GRrevparm(IGRlong *msg; struct GRmd_env *md_env)
{
  *msg = MSFAIL;

  return(OM_S_SUCCESS);
}


method EMcvradcrv (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                    struct GRvg_construct *const_args; IGRlong numpars;
		    struct GRparms *start_parm,*mid_parm,*end_parm;
                    IGRdouble maxrad; 
                    IGRdouble *crvtr_val; IGRdouble *radii_val; 
                    IGRdouble *radii_poly; GRobjid *radii_obj;
                    IGRdouble *crv_poly; GRobjid *crv_obj)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);

}


method EMcvtanorm (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct GRvg_construct *const_args; IGRlong numpars;
	           struct GRparms *start_parm,*mid_parm,*end_parm;
                   IGRdouble displen; IGRdouble *dirpt;
                   IGRboolean comp_tangent; IGRboolean comp_normal;
                   IGRdouble *outpoly; GRobjid *outobj)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMcvoffset (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
        struct GRvg_construct *const_args; IGRdouble *offdist;
	IGRvector vector; IGRboolean right_side; IGRboolean uniform;
	IGRint *off_code; IGRboolean fillet, remove_loops;
        struct GRid *offcvid; IGRlong *num_loops; 
	struct IGRbsp_curve ***loops; IGRlong **loop_table)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}



method EMpartofcv (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct GRvg_construct *const_args; 
		   struct GRparms *start_parms,*mid_parms,*end_parms;
                   GRobjid *partcvid)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMcrvcrvint(  IGRlong *msg; 
		     struct GRvg_construct *crv_cnst;
		     struct GRmdenv_info   *my_objenv;
		     struct IGRbsp_curve   *other_curve_in;
		     struct GRid	   *other_obj;
		     struct GRmdenv_info   *other_objenv;
		     IGRboolean		    end_inter_valid;
		     IGRlong		   *pnt_slots;
		     IGRlong		   *grand_num_pnt;
		     struct GRid	  **pnt_ids;
		     struct GRparms	  **my_pnt_inters;
		     struct GRparms	  **other_pnt_inters;
		     IGRdouble		  **inter_pnts_xyz;
 		     IGRlong		   *crv_slots;
		     IGRlong		   *grand_num_crv;
		     struct GRid	  **crv_ids;
		     struct GRparms	  **my_crv_inters;
		     struct GRparms	  **other_crv_inters)
{
IGRlong status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMcrvslfint( IGRlong *msg;
		    struct GRvg_construct *crv_cnst;
		    struct GRmdenv_info *my_objenv;
		    IGRlong		*pnt_slots;  
		    IGRlong 		*grand_num_pnt;
		    struct GRid 	**pnt_ids;
		    struct GRparms 	**my_pnt_inters;
		    IGRdouble      	**inter_pnts_xyz;
		    IGRlong		*crv_slots;
		    IGRlong 		*grand_num_crv;
		    struct GRid 	**crv_ids;
		    struct GRparms 	**my_crv_inters)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method EMbctobz ( struct GRvg_construct *construct_list;
		  GRobjid **bz_objid; IGRint *nbezier; IGRlong *msg )
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method EMgetbcdef (IGRlong *msg; struct IGRbsp_curve *crv)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
 *msg = MSSUCC;
 *properties = GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
               GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
               GR_LC_CMP_READ     | GR_LC_RIGID;

 return(OM_S_SUCCESS);
}

method GRchgprops(IGRlong *msg; IGRshort *flag; IGRshort *props)
{
struct GRid my_grid, comp_grid;
IGRint status;
IGRuint count;
IGRshort loc_props;

/* if the symbology override bit is being set or cleared, send this message
 * to the component; also, if the symbology override bit is being set,
 * change the symbology override table to reference the component object since
 * it will be getting the display message; only do the above if there is one
 * component since it doesn't make since to put a symbology override on
 * multiple components; this is the fix for TR#119301281
 */

if (loc_props = *props & DEHAS_OVERRIDE)
  {
    status = om$get_channel_count(objid = my_id,
                                  p_chanselect = &AS_to_comp,
                                  count = &count);
    if ((1 & status) && (count == 1))
      {
        status = om$send(msg = message GRgraphics.GRchgprops(msg, flag,
                                                             &loc_props),
                         p_chanselect = &AS_to_comp);

        if (1 & status & *msg)
          {
            if (*flag)
              {
                status = om$get_objid_at_index(objid = my_id,
                                               p_chanselect = &AS_to_comp,
                                               index = 0,
                                               objidaddr = &comp_grid.objid,
                                               osnumaddr = &comp_grid.osnum);

                if (1 & status)
                  {
                    my_grid.objid = my_id;
                    my_grid.osnum = OM_Gw_current_OS;

                    de$objid_changed(msg = msg,
                                     old = &my_grid,
                                     new = &comp_grid);
                  }
                }
            }
        }

      as$status();
  }

status = om$send(msg = message ASnode.GRchgprops(msg,flag,props),
		 targetid = my_id,
		 mode = OM_e_wrt_message);
return(status);
}
    
end implementation ASbspline;
