/* $Id: VLunwLabel.I,v 1.1.1.1 2001/01/04 21:11:43 cvs Exp $  */
/***************************************************************************
* I/LOFT
*
* File: src/unwext/VLunwLabel.I
*
* Description: The function VLgetGraphics_from__text() converts the supplied 
*              text string into a graphic group. If it fails at any point in the*              process, it wraps up with a retFlag of 0 
*
* Dependencies:
*
* Revision History:
*      $Log: VLunwLabel.I,v $
*      Revision 1.1.1.1  2001/01/04 21:11:43  cvs
*      Initial import to CVS
*
# Revision 1.2  2000/01/04  08:27:40  pinnacle
# Replaced VLunwLabel.I for changing the filename by jpulapar for loft
#
# Revision 1.1  2000/01/04  08:19:22  pinnacle
# New file for mapping the text of label_loft macro
#
*
* History:
*      MM/DD/YY  AUTHOR  DESCRIPTION
*      08/30/99  Jayadev Creation - This was done for conversion of the text
*                                   feet of label_loft macro to graphic elements
* 
***************************************************************************/


class implementation IDpjtext;

#include <math.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grownerdef.h"
#include "growner.h"
#include "grmacros.h"
#include "exmacros.h"
#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"
#include "bsvalues.h"
#include <memory.h>    /* prototypes */
#include <string.h>    /* prototypes */

#define NUM_STRK_DBLS 9000
#define NUM_STRK_PTS 3000
#define INC_STRK_PTS 1500

from GRgraphics import GRconstruct, GRaltconstruct;
from GRvg	import GRgetgeom;
from GRtext 	import GRgettxattr;

extern ASget_active_symb();

IGRint  VLgetGraphics_from__text (struct GRobj_env *text,struct GRid *graphic_grp )
{
  int		  status = OM_S_SUCCESS;
  
  struct GRmd_env act_mod, txt_mod;
  struct IGRdisplay active_display;
  short  active_level;
  
  IGRshort act_os, txt_os;
  GRobjid txt_id;
  struct GRvg_construct cnst_list;
  OM_S_OBJID ggid;
  struct GRid gg_grid;
  IGRlong msg, siz_buf, ret_bytes;
  IGRint retFlag = 0;
  
  graphic_grp->objid = NULL_OBJID;
  graphic_grp->osnum = 0;
  
  /* get active module info */
  siz_buf = sizeof( struct GRmd_env );
  gr$get_module_env( msg = &msg,
		     sizbuf = &siz_buf,
		     buffer = &act_mod,
		     nret = &ret_bytes );
  act_os = act_mod.md_id.osnum;
  
  ASget_active_symb(&active_level,&active_display);
  active_display.style = 0;
  
  /* initialize standard construction list */
  cnst_list.msg = &msg;
  cnst_list.newflag = 0;
  cnst_list.level = active_level; 
  cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cnst_list.display = &active_display;
  cnst_list.name = NULL;
  cnst_list.class_attr = NULL;
  cnst_list.env_info = &act_mod;
  
  /* create a graphic group to put zero thickness or stick font projection */
  status = om$construct( osnum = act_os,
			 classname = "GRgrgrp",
			 p_objid = &ggid,
			 msg = message GRgraphics.GRconstruct( &cnst_list ));
  if ( !( status & 1 )) goto wrapup;
  
  gg_grid.objid = ggid;
  gg_grid.osnum = act_os;
  
  /* get text string id & os */
  txt_mod = text->mod_env;
  txt_id  = text->obj_id.objid;
  txt_os  = text->obj_id.osnum;
  
  /* get text related information */
  {
    struct var_list var_list[5];
    IGRint win_no, gpipe_id, gragad_flags;
    IGRint loop_index;
    struct DPfnt_os_tbl *fnt_os_ptr;
    struct IGRlbsys lbs;
    struct IGResintx txt_ele_info;
    struct IGRestx text_attr;
    IGRshort text_lng, nostrokes, malc_buf;
    IGRuchar *text_string;
    IGRdouble strk_buf[NUM_STRK_DBLS], *ptr_strk_buf, *start_pt;
    IGRint num_points, malloc_size, num_pts, tot_num_pts, count;
    IGRlong which_error;
    IGRboolean ststf;
    OMuword       cur_osnum;
    IGRint        stat1;
    struct        GRid windows[EX_MAX_WINDOW];
    IGRint        num_wins;
    
    var_list[0].var = WIN_NO;
    var_list[0].var_ptr = ( IGRchar * ) &win_no;
    var_list[0].num_bytes = sizeof( IGRint );
    var_list[0].bytes_returned = &ret_bytes;
    
    var_list[1].var = GPIPE_ID;
    var_list[1].var_ptr = ( IGRchar * ) &gpipe_id;
    var_list[1].num_bytes = sizeof( IGRint );
    var_list[1].bytes_returned = &ret_bytes;
    
    var_list[2].var = FONT_OS_PTR;
    var_list[2].var_ptr = ( IGRchar * ) &fnt_os_ptr;
    var_list[2].num_bytes = 4;
    var_list[2].bytes_returned = &ret_bytes;
    
    var_list[3].var = GRAGAD_FLAGS;
    var_list[3].var_ptr = ( IGRchar * ) &gragad_flags;
    var_list[3].num_bytes = sizeof( IGRint );
    var_list[3].bytes_returned = &ret_bytes;
    
    var_list[4].var = END_PARAM;
    
    // get all the window ids and try to fill the var_list
    stat1 = dp$get_gragad_id( msg = &msg,
                              name = "*",
			      type_gragad = ALL_GG_CLASSES | GG_WIN_ON | ACTIVE_GG | NO_DELAY_GG ,
			      array_size = EX_MAX_WINDOW,
			      numberofids = &num_wins,
			      found_GRids = windows);
    
    for(loop_index=0;loop_index<num_wins;loop_index++)
    {
      status = dp$inq_set_gragad( msg = &msg,
				  osnum = windows[loop_index].osnum,
				  gragad_objid = windows[loop_index].objid,
				  which_error = &which_error,
				  var_list = var_list );
      
      if (( status & 1 & msg )) break;
    }
    if(loop_index == num_wins) goto wrapup; //inq_set_gragad failed 
    
    status = om$send( msg = message GRtext.GRgetgeom( &msg, 
						      &txt_mod.md_env.matrix_type,
						      txt_mod.md_env.matrix,
						      (IGRchar *) &lbs ),
                      senderid = NULL_OBJID,
		      targetid = txt_id,
		      targetos = txt_os );
    
    status = om$send( msg = message GRtext.GRgettxattr( &msg, 
						        &text_attr,
						        &text_lng,
						        &text_string ),
                      senderid = NULL_OBJID,
		      targetid = txt_id,
		      targetos = txt_os );
    
    txt_ele_info.font_id = txt_os;
    txt_ele_info.flags = 0;
    txt_ele_info.prev_font = text_attr.font;
    txt_ele_info.estx = &text_attr;
    txt_ele_info.text_string = ( IGRchar * ) text_string;
    
    ptr_strk_buf = strk_buf;
    nostrokes = TRUE;
    num_points = NUM_STRK_PTS;
    malc_buf = FALSE;
    
    /* get text stroke points */
    while ( nostrokes )
    {
      ststf = DPtxstrk( &msg, &lbs, &txt_ele_info, &active_display,
		        win_no, gpipe_id, fnt_os_ptr, gragad_flags,
		        0, 1.0, 0, ptr_strk_buf, &num_points);
      if ( ststf == FALSE )
      {
	num_points = num_points + INC_STRK_PTS;
	if ( malc_buf )
	  om$dealloc( ptr = ptr_strk_buf );
	malc_buf = TRUE;
	malloc_size = sizeof( IGRdouble ) * num_points * 3.0;
	ptr_strk_buf = ( IGRdouble * ) om$malloc( size = malloc_size );
	if ( ptr_strk_buf == NULL )
	{
	  if ( malc_buf )
	    om$dealloc( ptr = ptr_strk_buf );
	  goto wrapup;
	}
      }
      else
	nostrokes = FALSE;
    } /* close for while */
    om$dealloc( ptr = text_string );
    
    tot_num_pts = 0;
    
    while( tot_num_pts < num_points )
    {
      start_pt = ptr_strk_buf;
      count = 0;
      while ( !( fabs( fabs( *ptr_strk_buf/MAXDOUBLE ) - 1 ) < 1e-6 ))
      {
	ptr_strk_buf = ptr_strk_buf + 3;
	count = count + 3;
      }
      num_pts = count / 3;
      tot_num_pts = tot_num_pts + num_pts + 1;
      
      {
	struct IGRpolyline ply_ln;
        struct GRid ply_txt;
	ply_ln.num_points = num_pts;
	ply_ln.points = start_pt;
	
	cnst_list.geometry = ( IGRchar * ) &ply_ln;
	
	ply_txt.objid = NULL_OBJID;
	
	status = om$construct( classname = "GR3dlinestr",
			       osnum = act_os,
			       p_objid = &ply_txt.objid,
			       msg = message GRgraphics.GRaltconstruct( &cnst_list ));
	ply_txt.osnum = act_os;
	
	
	/* put object into the graphic group */
	GRconnect_object( &msg, act_os, ply_txt.objid, &gg_grid, GR_FLEXIBLE,
			  GR_OVERRIDE, OM_K_MAXINT, OM_K_MAXINT );
      } 
      ptr_strk_buf = ptr_strk_buf + 3;
    } /* close for while */
    
    if ( malc_buf )
      om$dealloc( ptr = ptr_strk_buf );
    
  }
  
  graphic_grp->objid = gg_grid.objid;
  graphic_grp->osnum = gg_grid.osnum;
  retFlag = 1;
wrapup:
  return retFlag;
}

end implementation IDpjtext;










