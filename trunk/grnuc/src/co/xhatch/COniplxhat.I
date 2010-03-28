/* #######################    APOGEE COMPILED   ######################## */
/*
   CO_ni_place_crosshatch()

*/

class implementation Root;
#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "codef.h"
#include "igrmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "csdef.h"
#include "csmacros.h"
#include "grxhdef.h"
#include "grxhatch.h"

from IGEgragad  import DPinrot;
from GRcoxhatch import GRxhinit;
from GRcoxhatch import GRxhadd_bdry;
from GRcoxhatch import GRxhcompute;
from GRcoords   import GRcvt_to_wld_coords;

/* */
#argsused
IGRlong  CO_ni_place_crosshatch( msg,
                                 events,
                                 active_level,
                                 attributes,
                                 xhatch_gg,
                                 cobid,
                                 cobos,
                                 p_co_chanselect,
                                 module_info,
                                 objects_grid,
                                 xhatch_color,
                                 xhatch_spacing,
                                 xhatch_angle,
                                 xhatch_pattern)

    IGRlong              *msg;
    struct GRevent       *events[];
    IGRshort             *active_level;
    IGRchar              *attributes;
    struct GRid          *xhatch_gg;
    OM_S_OBJID            cobid;
    GRspacenum            cobos;
    OM_S_CHANSELECT      *p_co_chanselect;
    struct GRmd_env      *module_info[];
    struct GRid          *objects_grid[];
    IGRshort              xhatch_color;
    IGRdouble             xhatch_spacing;
    IGRdouble             xhatch_angle;
    struct GRxhatchpat   *xhatch_pattern;

{
/* */
  struct GRid           xhatch_id;
  IGRlong               status;               
  struct GRid           my_grid;
  struct GRid           window_grid;
  IGRint                num_bytes, num_bytes_ret;
  IGRdouble             origin[3];
  IGRdouble             world_origin[3];
  IGRint                name_size = 80;
  IGRint                desc_size = 80;
  IGRint                ret_name_size;
  IGRint                ret_desc_size;
  IGRchar               act_cs_name[80];
  IGRchar               act_cs_desc[80];
  struct  GRid          active_cs;
  IGRboolean            xhatch_assoc_flag;

  _m_debug(EX_start_timing();)
  _m_debug(EX_start_timing();)

  my_grid.objid = cobid;
  my_grid.osnum = cobos;
  
  num_bytes = sizeof(IGRboolean);
  gr$get_associative_flag(msg = msg,
			  sizbuf = &num_bytes,
			  buffer = &xhatch_assoc_flag,
			  nret = &num_bytes_ret);
  xhatch_id.osnum = module_info[0]->md_id.osnum;

  /* construct raw object */
  status = om$construct(osnum = xhatch_id.osnum,
 			classname = "GRcoxhatch",
			p_objid = &xhatch_id.objid);
  _m_debug(EX_end_timing("xhatch ni func: const. xhatch");)

  _m_debug(EX_start_timing();)
  window_grid.osnum = events[0]->event.button.osnum;
  window_grid.objid = events[0]->event.button.objid;

  active_cs.osnum = objects_grid[0]->osnum;
  status = cs$get_active_info(msg = msg,
			      osnum = objects_grid[0]->osnum,
			      namebuf_size = name_size,
                              name = act_cs_name,
                              namebytes_ret = &ret_name_size,
                              descbuf_size = desc_size,
                              desc = act_cs_desc,
                              descbytes_ret = &ret_desc_size,
			      objid = &active_cs.objid);
  _m_check2p(status,*msg,"CO_ni_place_crosshatch cs$get_active_info failed");
  _m_check2q(status,*msg);

  world_origin[0] = 0.0;
  world_origin[1] = 0.0;
  world_origin[2] = 0.0;
  status = om$send ( msg = message GRcoords.GRcvt_to_wld_coords(msg,
								Rectangular,
								1,
								world_origin,
								origin),
		    senderid = NULL_OBJID,
		    targetos = active_cs.osnum,
                    targetid = active_cs.objid);
  _m_check2p(status,*msg,"CO_ni_place_crosshatch GRcoords.GRcvt_to_lcl_coords");
  _m_check2q(status,*msg);
  _m_debug(EX_end_timing("xhatch ni func: get cs info");)

  status = om$send (msg = message GRcoxhatch.GRxhinit(msg,
                                                    objects_grid[0],
                                                    &window_grid,
                                                     xhatch_assoc_flag,
                                                     xhatch_color,
                                                     xhatch_spacing,
                                                     xhatch_angle,
                                                     origin,
                                                     xhatch_pattern),
                    senderid = NULL_OBJID,
 		    targetid = xhatch_id.objid,
                    targetos = xhatch_id.osnum);
  _m_check2p(status,*msg,"CO_ni_place_crosshatch GRcoxhatch.GRxhinit failed");
  _m_check2q(status,*msg);

  /* add boundaries */
  status = om$send (msg = message GRcoxhatch.GRxhadd_bdry(msg,
                                                        &my_grid,
                                                        p_co_chanselect),

                    senderid = NULL_OBJID,
 		    targetid = xhatch_id.objid,
                    targetos = xhatch_id.osnum);
  _m_check2p(status,*msg,"CO_ni_place_crosshatch GRcoxhatch.GRxhadd_bdry failed");
  _m_check2q(status,*msg);

  /* compute cross hatching */
  status = om$send (msg = message GRcoxhatch.GRxhcompute(msg,
                                                       module_info[0],
                                                       xhatch_gg),
                    senderid = NULL_OBJID,
 		    targetid = xhatch_id.objid,
                    targetos = xhatch_id.osnum);
  _m_check2p(status,*msg,"CO_ni_place_crosshatch GRcoxhatch.GRxhcompute failed");

quit:
  _m_debug(EX_end_timing("CO_ni_place_crossx");)
  _m_debug(EX_print_timing();)
   return( status );
} /*  end  of CO_ni_place_crosshatch    */

/*  */
#argsused
IGRint  GRxh_load_pattern(pattern_type, 
                          xhatch_spacing, 
                          pattern_def )
     
     IGRlong                   pattern_type;
     IGRdouble                 xhatch_spacing;
     struct GRxhatchpat       *pattern_def;
{   
  IGRint                size, size_returned;
  struct IGRdisplay     line_symbology;
  IGRlong               status = OM_S_SUCCESS;
  IGRlong               msg;
  
  size = sizeof(line_symbology);
  gr$get_active_display(msg = &msg,
			sizbuf = &size,
			buffer = &line_symbology,
			nret = &size_returned );
  
  size = sizeof(pattern_def->level);
  gr$get_active_level(msg = &msg,
		      sizbuf = &size,
		      buffer = &pattern_def->level,
		      nret = &size_returned);
  
  line_symbology.style = 0;
  
  switch(pattern_type)
    {
    case GRXH_ANSI_IRON:
    case GRXH_DIN_IRON:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 1;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	break;
      }
      
    case GRXH_ANSI_BRONZE:
    case GRXH_DIN_COPPER:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 2;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	line_symbology.style = 3;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .5;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	break;
      }
      
    case GRXH_ANSI_TITANIUM:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 3;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	line_symbology.style = 3;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .25;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	line_symbology.style = 0;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	pattern_def->pass[0].lines[2].perp_dist_next_line =  .50;
	break;
      }
      
    case GRXH_ANSI_PLASTIC:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 4;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	pattern_def->pass[0].lines[1].perp_dist_next_line =  .1429;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	pattern_def->pass[0].lines[2].perp_dist_next_line = .2857;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	pattern_def->pass[0].lines[3].line_symbology = line_symbology;
	pattern_def->pass[0].lines[3].perp_dist_next_line = .4286;
	break;
      }
      
    case GRXH_ANSI_STEEL:
    case GRXH_DIN_STEEL:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 2;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .33;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	break;
      }

    case GRXH_ANSI_WHITE_METAL: 
    case GRXH_DIN_SEAL_INSULAT:
      {
	pattern_def->num_angles = 2;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 1;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	pattern_def->pass[1].angle = 1.5707;  
	pattern_def->pass[1].num_lines = 1;
	pattern_def->pass[1].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[1].lines[0].line_symbology = line_symbology;
	break;
      }
      
    case GRXH_DIN_CAST_STEEL:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 3;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .25;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	pattern_def->pass[0].lines[2].perp_dist_next_line = .50;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	break;
      }

    case GRXH_DIN_BRASS:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 4;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .16;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	pattern_def->pass[0].lines[2].perp_dist_next_line = .32;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	line_symbology.style = 3;
	pattern_def->pass[0].lines[3].perp_dist_next_line = .66;
	pattern_def->pass[0].lines[3].line_symbology = line_symbology;
	break;
      }

    case GRXH_DIN_BRONZE:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 3;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .26;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	line_symbology.style = 3;
	pattern_def->pass[0].lines[2].perp_dist_next_line = .635;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	break;
      }
      
    case GRXH_DIN_ZINC_LEAD:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 3;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	line_symbology.style = 3;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .33;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	pattern_def->pass[0].lines[2].perp_dist_next_line = .66;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	break;
      }
      
    case GRXH_DIN_LIGHT_METAL:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 4;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	line_symbology.style = 3;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .25;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	pattern_def->pass[0].lines[2].perp_dist_next_line = .50;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	pattern_def->pass[0].lines[3].perp_dist_next_line = .75;
	pattern_def->pass[0].lines[3].line_symbology = line_symbology;
	break;
      }	
    case GRXH_DIN_HARD_RUBBER:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 4;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
	pattern_def->pass[0].lines[1].perp_dist_next_line = .25;
	pattern_def->pass[0].lines[1].line_symbology = line_symbology;
	line_symbology.style = 3;
	pattern_def->pass[0].lines[2].perp_dist_next_line = .50;
	pattern_def->pass[0].lines[2].line_symbology = line_symbology;
	pattern_def->pass[0].lines[3].perp_dist_next_line = .75;
	pattern_def->pass[0].lines[3].line_symbology = line_symbology;
	break;
      }

    case GRXH_EMPTY:
      {
	pattern_def->num_angles = 1;
	pattern_def->pass[0].angle = 0.0;
	pattern_def->pass[0].num_lines = 0;
	pattern_def->pass[0].lines[0].perp_dist_next_line = 0.0;
	pattern_def->pass[0].lines[0].line_symbology = line_symbology;
        break;
      }
      
    default:
      {
	status = OM_E_ABORT; 
	break;     
      }
      
    }
  
  return(status);
}

end implementation Root;























