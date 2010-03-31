/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
# include "emsdef.h"
# include "emserr.h"
# include "emseligible.h"
# include "EMSssprops.h"       /* Inactive bit definition */
# include "igrtypedef.h"
# include "igr.h"
# include "igrdef.h"
# include "dpdef.h"
# include "dpmacros.h"

extern struct GRid GUwindow_being_plotted;

method GRplotprep(IGRlong *EMmsg; struct GRmd_env *cur_env, *target_env;
                  IGRshort *num_prisms; struct IGRcv_prism *prism_array;
                  struct GRid *set_id; IGRlong *begin_index, *end_index)
/*
Abstract

    This method prepares for plotting a surface by generating the
    curves needed to perform the plot.

Notes

    It is assumed that if either surface of a common edge gets
    this message, they both will.

History

   ??/??/?? : aic : This probably written by allen
   01/17/89 : rlw : Modified not to plot if surface is inactive
   03/31/89 : PP  : Fixed a problem during plotting wherein degenerate
                    edges were getting magnified during the course of
                    conversion to IGDS and thus appearing as zingers. 
   DLB    04/17/89  Added EMset_inactive send to handle pre 1.2.0 OS which
                    doesn't have the inactive bit set.
   09/14/89 : SM  : Upon error, output successfully created curves.
		    Instead of aborting set the return code to
		    EMS_I_Fail.
   10/13/89 : PP  : Modified the code to support an alternative 
                    symbology and user specified level mapping should
                    they exist.
   03/22/90 : SM  : Use option EMSeligible_UseMsc for EMmake_wire_frame, to
		    copy MSC of an edge is noe exists, instead of creating
		    new curve. This is to pick up any symbology override.
   12/09/91: Jack : Added a reference to a KLUDGE that gives me 
                    struct GRid GUwindow_being_plotted so I can get the
                    view_vector of the window being plotted.
   08/25/92: NP   : Modified for ANSI compliance. Changed declaration of "ret_size"
		    to "IGRlong".
*/
{
  IGRlong               sts = OM_S_SUCCESS,
                        loc_msg = MSSUCC,
                        buf_size = 0,
                        num_curves = 0,
                        rc = 0;
  struct GRid           *curve_GRid_ptr = NULL;
  struct EMScurveinfo   curve_info;
  struct GRsymbology    symbology;
  struct GRvg_construct construct_list;
  unsigned short option;
  extern IGRlong GUget_symb_level();
  extern IGRboolean BSmkvec(), BSnorvec();
  IGRvector             view_vector;
  IGRpoint              point1, 
                        point2,
                        cv_point;
  struct IGRline        bore_line;
  IGRlong               ret_size;
  IGRlong               which_err;
  struct var_list       var_list[2];
  IGRmatrix             vwmat;


  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  { /*Intentional block. -DLB*/
    IGRlong dlb_loc_msg, OM_stat;
    IGRboolean did_set_inactive;
    OM_stat = om$send(msg = message EMSsubbs.EMset_inactive(
                            &dlb_loc_msg, &did_set_inactive),
                      targetid = my_id);
  }

  if (me->ss_props & EMSIS_INACTIVE) goto wrapup; /* rlw 01/17/89 */
  sts = om$send(msg = message GRvg.GRgetsymb(EMmsg, &symbology),
                targetid = my_id);
  if (! (1 & sts)) goto wrapup;


  /* determine the view_vector of the view for plotting.  Needed
     for horizon edges.  Jack 12/09/91 
   */  

  var_list[0].var            =  VW_ROT_NO_CON;
  var_list[0].var_ptr        =  (IGRchar *)vwmat;
  var_list[0].num_bytes      =  sizeof ( IGRmatrix );
  var_list[0].bytes_returned = &ret_size;

  var_list[1].var = END_PARAM;

  sts = dp$inq_set_gragad(
                msg          =  EMmsg,
                osnum        =  GUwindow_being_plotted.osnum,
                gragad_objid =  GUwindow_being_plotted.objid,
                which_error  = &which_err,
                var_list     =  var_list );
  if(!(1 & sts & *EMmsg))
    goto wrapup;

  cv_point[0] = vwmat[8];
  cv_point[1] = vwmat[9];
  cv_point[2] = vwmat[10];

  bore_line.point1 = point1;
  bore_line.point2 = point2;

  /* construct the bore_line */
  sts = GRbrlnconstr(EMmsg,
                     cv_point,
                     vwmat,
                    &bore_line);

  sts = BSmkvec(&rc,
                 view_vector,
                 point1,
                 point2);
  if (! sts)
   {
    *EMmsg = MSFAIL;
     goto wrapup;
   }

  sts = BSnorvec(&rc,
                  view_vector);
  if (! sts)
   {
    *EMmsg = MSFAIL;
     goto wrapup;
   }

  /* pass the view_vector in the curve_info struct */
  curve_info.view_vector = view_vector;

/*
 * Call to support alternative symbology/level mapping.
 * pp (10/12/89).
 */
   sts = GUget_symb_level(EMmsg,&symbology);
   if (! (1 & sts)) goto wrapup;

  /*
   * Set up the construct list.
   */
  construct_list.msg = &loc_msg;
  construct_list.env_info = target_env;
  construct_list.newflag = FALSE;
  construct_list.level = symbology.level;
  construct_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  construct_list.geometry = NULL;
  construct_list.display = &symbology.display_attr;
  construct_list.class_attr = NULL;
  construct_list.name = NULL;

  /*
   * Set up the curve info structure.
   */
  curve_info.messg_linestr = NULL;
  curve_info.messg_gencrv = NULL;
  curve_info.construct_list = &construct_list;
  curve_info.linestr.objid = NULL_OBJID;
  curve_info.gencrv.objid = NULL_OBJID;
  curve_info.linestr_counter = 0;
  curve_info.gencrv_counter = 0;
  curve_info.curves = &curve_GRid_ptr;
  curve_info.buf_size = &buf_size;
  curve_info.num_curves = &num_curves;

  /*
   * Get the curves
   */
  option = EMSeligible_NonSeamEdge | EMSeligible_NonSubEdge |
           EMSeligible_NonDegenerateEdge | EMSeligible_UseMsc;

  sts = om$send(msg = message EMSsubbs.EMmake_wire_frame(EMmsg, cur_env,
                &curve_info, option),
                targetid = my_id);
  if(! (1 & sts)) goto wrapup;

  /*
   * Connect the curves to the set object.
   */
  {
    IGRlong     flag = 1.0;
    IGRlong     maxint = MAXINT;
    IGRlong     index;
    IGRint      i;
    struct GRid *GRids;

    for(i = 0, index = *end_index, GRids = curve_GRid_ptr;
        i < num_curves;
        i ++, index ++, GRids ++)
    {
      sts = om$send(msg = message GRconnector.GRflexconn(EMmsg, &flag,
                    set_id, end_index, &maxint),
                    targetid = GRids->objid, targetos = GRids->osnum);
      if(! (1 & sts)) goto wrapup;
    }
    *end_index = index;
  }

wrapup:
  /*
   * If an error occured, then delete all the generated curves.
   */

/************************* SM 09/14/89 ******************
  if(! (1 & sts))
  {
    IGRint  i;

    for(i = 0; i < num_curves; i ++)
    {
      om$send(msg = message GRgraphics.GRdelete(EMmsg, target_env),
              targetid = curve_GRid_ptr[i].objid,
              targetos = curve_GRid_ptr[i].osnum);
    }
  }
********************************************************/

  if(curve_GRid_ptr) om$dealloc (ptr = curve_GRid_ptr);

  EMWRAPUP(*EMmsg, sts, "EMSsubbs.GRplotprep")
  if(!(1&*EMmsg)) *EMmsg = EMS_I_Fail;
  return(OM_S_SUCCESS);
}

end implementation EMSsubbs;
