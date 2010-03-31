class implementation ASnode;

#include "AS_status.h"
#include "OMerrordef.h"
#include "emseligible.h"
#include "emssfcvs.h"
#define AS_DEBUG

from EMSsurface import EMmake_wire_frame;

ASmake_wireframe(component,osnum,from_env,to_env,
		 drawing_component,nb_drawing_comp)
OM_S_OBJID component;
GRspacenum osnum;
struct GRmd_env *from_env,*to_env;
struct GRid **drawing_component;
int *nb_drawing_comp;
{
int status;
long loc_msg;
long		      buf_size = 0;
struct EMScurveinfo   curve_info;
struct GRsymbology    symbology;
struct GRvg_construct construct_list;
IGRushort option;

/* Copy from the method EMSsurface.GRplotprep */

  	status = om$send(msg = message GRvg.GRgetsymb(&loc_msg, &symbology),
		      senderid = NULL_OBJID,
		      targetos = osnum,
                      targetid = component);
  	if (!(status&loc_msg&1)) return OM_W_ABORT;


	/* 
	 * Set up the construct list.
	 */
	construct_list.msg = &loc_msg;
	construct_list.env_info = to_env;
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
	curve_info.curves = drawing_component;
	curve_info.buf_size = &buf_size;
	curve_info.num_curves = (long *) nb_drawing_comp;


	option = EMSeligible_NonSeamEdge | EMSeligible_NonSubEdge |
	EMSeligible_NonDegenerateEdge | EMSeligible_UseMsc;

	status = om$send(msg = message EMSsurface.EMmake_wire_frame
				(&loc_msg,from_env,&curve_info,option),
			 senderid = NULL_OBJID,
			 targetid = component);
	return status;
 
}
end implementation ASnode;
