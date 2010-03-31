class implementation HSsupsym;



#define CHECK_RETURN_CODES 0

#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "msmacros.h"
#include "dpmacros.h"
#include "refdef.h"
#include "detaildef.h"
#include "hscmd.h"
#include "hsmessage.h"

from GRdrawview import GRget_component_id;
from GRreffile  import GRchgrfprops;

/*---default transitions for all states---------------------------*/


#define _start 0

method load_prompt ( long * sts )
{
  int		  status = OM_S_SUCCESS;


	if ( me->display_hidden )
	   {
	   /* mode is display hidden lines */
	   ex$message( msgnumb = HS_I_DisplaySymbMode, buff = me->status );
	   }
	else
	   {
	   /* mode is suppress hidden lines */
	   ex$message( msgnumb = HS_I_SuppressSymbMode, buff = me->status );
	   }
	
	ex$message( msgnumb = HS_P_SelDrawingView, buff = me->prompt );
	ex$message( in_buff = me->status, field = ERROR_FIELD );
	quit:
  return OM_S_SUCCESS;
}

method process_drawing_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong     msg;
	IGRint      id_type;
	IGRshort    flag;
	IGRulong    props;
	struct GRid ref_id;

	/* get the reference file header associated with the drawing view */
	status = om$send( msg      = message GRdrawview.GRget_component_id( &msg, GR_DV_REFFILE,
	                                                                    1, &ref_id, &id_type ),
	                  targetid = me->event1.located_object[0].located_obj.objid,
	                  targetos = me->event1.located_object[0].located_obj.osnum );
	if ( (1 & status & msg) )
	   {
	   /* change the HIDDEN display bit in the reference file headers properties word */
	   flag = me->display_hidden ? 0 : 1;
	   props = GRHIDDEN_OFF;
	   status = om$send( msg      = message GRreffile.GRchgrfprops( &msg, &flag, &props ),
	                     targetid = ref_id.objid,
	                     targetos = ref_id.osnum );

	   }

        if (! (1 & status & msg))
           {
           extern IGRint EFsv_suppress_symb();
           struct GRid   window_grid;

           /* the drawing view may be the parent of a Section View and
            * would not have a reference file; the following function will
            * determine if this is the case and, if so, will either change
            * the automatic hidden symbology overrides of the solids owned
            * by the Section View into automatic invisible symbology
            * overrides or change the automatic invisible symbology
            * overrides into automatic hidden symbology overrides,
            * depending on how me->display_hidden is set
            */

           window_grid.objid = me->event1.event.button.objid;
           window_grid.osnum = me->event1.event.button.osnum;

           EFsv_suppress_symb(&msg, &me->event1.located_object[0].located_obj,
                              &me->event1.located_object[0].module_info,
                              &window_grid, me->display_hidden);
           }

	   ex$message( msgnumb = HS_I_UpdWin );
	   sleep( 3 );
	   ex$message( in_buff = "", field = ERROR_FIELD );

	/* clear the hilite plane */
	dp$erase_hilite( msg = &msg );

	quit:
  return OM_S_SUCCESS;
}

method toggle_display ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	me->display_hidden = !me->display_hidden;
	quit:
  return OM_S_SUCCESS;
}

end implementation HSsupsym;
