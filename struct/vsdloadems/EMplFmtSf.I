/* ###################   APOGEE COMPILED   ################## */
/*
Description
  This method converts a EMSplane object into an IGDS element.
  If the plane has a cross hatch gradata attatched to it then the entire
  surface is output as a wireframe model in IGDS. If the plane does
  not have a cross hatch gradata attatched to it then it simply invokes the
  implementation at the EMSsubbs level.

History
  pp    13-Oct-89       Modified the code to support an alternative 
                        symbology and user specified level mapping should
                        they exist.
  SM	22-Aug-88	Creation.
*/
class implementation EMSplane;

#include "EMS.h"
#include "bs.h"                 /* Has igr stuff plus bs codes and types */
#include "msdef.h"              /* Has MSFAIL */
#include "emseligible.h"

extern IGRboolean  VS_STRUDL_process;
/*
  External variable;  Set to TRUE during drawing extraction. Defaults to
FALSE. If it is TRUE, the downloaded EMS methods understand that they
are being called for drawing extraction and behave accordingly. When FALSE
their behavior is that of EMS' behavior.
*/

extern OMuword  OPP_EMSchatch_class_id, OPP_EMSplane_class_id;

from EMSgradata import EMget_class_info;

method GRformatele(
IGRlong         *msg;                   /* Error return code */
struct          GRmd_env *md_env;       /* context information */
IGRchar         *dgn_buf;               /* buffer for output to IGDS dgn file*/
IGRchar         *bs_buf;                /* buffer to hold abstract geom */
IGRchar         *ele_buf;               /* buffer to hold an IGDS element */
IGRint          *ele_size;              /* number of bytes in IGDS element */
IGRint          *file_des;              /* pointer to IGDS design file */
IGRdouble       *max_overflow;          /* max. abs. value for int. overflow*/
IGRdouble	*scale_factor)		/* Scale of EMS to IGDS working units*/

{
  IGRlong		sts, loc_msg;
  OMuword               gradata_classid;
/*
  OM_S_MESSAGE          messg;
*/
  OM_S_CHANSELECT       to_helpers;
  IGRlong                buf_size = 0,
                        num_curves = 0;
  struct GRid           *curve_GRid_ptr = NULL;
  struct EMScurveinfo   curve_info;
  struct GRvg_construct construct_list;
  struct GRsymbology    symbology;
  IGRint		i;
  extern IGRlong        GUget_symb_level();

 *msg = MSSUCC;
 sts = OM_S_SUCCESS;

 /* Initialize gradata_classid to any classid other than that of
    EMSchatch. This is done so that no gradata is treated same as non cross
    hatch gradata.
 */
 gradata_classid = OPP_EMSplane_class_id;

 to_helpers.type = OM_e_addr;
 to_helpers.u_sel.addr = &ME.EMSrequester->to_helpers;


 if(! (1 & sts)) goto wrapup;

/*
 sts = om$send(msg = message EMSgradata.EMget_class_info(msg,
                &gradata_classid, &messg), p_chanselect = &to_helpers);
*/
 sts = om$send(msg = message EMSgradata.EMget_class_info(msg,
                &gradata_classid, NULL), p_chanselect = &to_helpers);
 if (sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
 if(! (1 & *msg & sts)) goto wrapup;

 if (gradata_classid != OPP_EMSchatch_class_id)
   sts = om$send(mode = OM_e_wrt_message, 
		 msg = message EMSsubbs.GRformatele
         		(msg, md_env, dgn_buf, bs_buf, ele_buf, ele_size, 
			 file_des, max_overflow, scale_factor), 
		 targetid = my_id);
 else
  {
   sts = om$send(msg = message GRvg.GRgetsymb(msg, &symbology),
                targetid = my_id);
   if (! (1 & sts)) goto wrapup;

/*
 * Call to support alternative symbology/level mapping.
 * pp (10/12/89).
 */
   sts = GUget_symb_level(msg,&symbology);
   if (! (1 & sts)) goto wrapup;

   /*
    * Set up the construct list.
    */
   construct_list.msg = &loc_msg;
   construct_list.env_info = md_env;
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
 if ( VS_STRUDL_process )
 {
   sts = om$send(msg = message EMSsubbs.EMmake_wire_frame(msg, md_env,
                &curve_info, (IGRushort) EMSeligible_NonSubEdge
/* ALAIN FALASSE 13 April 94 : must do it since I removed it from
   method EMSsurface.EMmake_wire_frame ...
 */
					 | EMSeligible_NonSubEdge ),
/* END ALAIN FALASSE */
                targetid = my_id);
 }
 else
 {
   sts = om$send(msg = message EMSsubbs.EMmake_wire_frame(msg, md_env,
                &curve_info, (IGRushort) EMSeligible_NonSubEdge ),
                targetid = my_id);
 }

   if(! (1 & sts)) goto wrapup;

   /* Send the GRformatele message to all the curves. Ignoring the error
    * code so that whatever possible is converted.
   */
   for(i=0; i<num_curves; i++)
     sts = om$send(msg = message GRgraphics.GRformatele
         		(msg, md_env, dgn_buf, bs_buf, ele_buf, ele_size, 
			 file_des, max_overflow, scale_factor), 
		 targetid = curve_GRid_ptr[i].objid, 
		 targetos = curve_GRid_ptr[i].osnum);
		
  } /* else for if(gradata_classid != OPP_EMSchatch_class_id) */

wrapup:

/* Delete all the curves representing the wireframe model.
*/
for(i=0; i<num_curves; i++)
  om$send(msg = message GRgraphics.GRdelete(msg, md_env),
              targetid = curve_GRid_ptr[i].objid,
              targetos = curve_GRid_ptr[i].osnum);

if(curve_GRid_ptr) om$dealloc (ptr = curve_GRid_ptr);

/*
 * Always return success whether or not it is honest
 */
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}

end implementation EMSplane;
