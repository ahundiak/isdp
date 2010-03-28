command_string  "de n pt loc",0,DEnpt
class           DEnpt
product_name   "$PLATFORM"
spec_path      "$PLATFORM/co/spec"
super_class     CEO_GSLOCATE
super_class     COnpt
start_state     terminate

specification
#include "de.h"

implementation
#include "OMminimum.h"
#include "OMindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "codebug.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include <sys/types.h>
#include "grerr.h"
#include "codef.h"
#include "msdef.h"
#include "dedef.h"
#include "igrmacros.h"
#include "dpcodef.h"
#include "dpcomacros.h"
#include "coniarray.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "comiscmac.h"
#include "lcmacros.h"
#include <tools.h>
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "referr.h"
#include "comnmacros.h"
#include "DEso.h"
#include "DEsomacros.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrdef.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "dpbco.h"

#define ACCEPT     1
#define WINDOW     5
#define CO_TEXT   12
#define WT_TEXT   13
#define ST_TEXT   14
#define HIDDEN    18
#define INVIS     19
#define VIS       20
#define SPECIFIED 21
#define PARTIAL   22
#define SHO_INVIS 23
#define COLOR     24
#define WEIGHT    25
#define STYLE     26

#define CLEAR_IT  0

#define DO_NOT_FLIP   0
#define NEEDS_FLIP    1
#define FLIPPED       2
#define NEEDS_UNFLIP  3
#define UNFLIPPED     4

#define ON_OVERLAP    2

#ifdef SUNOS5
%undef sleep
#endif

from GRgraphics   import    GRdisplay,GRlnproject;
from GRbspline    import    GRlinesegproj;
from DEso         import    DEget;
from GRvg         import    GRgeomprops;

extern     IGRint     DEselect();  
extern     IGRint     DElocact();  
extern     IGRint     COhilite_sym_o();

%safe
static        IGRint     *t_table = 0;
static        IGRdouble  *b_table = 0;
static struct IGRdisplay *a_table = 0;
%endsafe

instance
{

    enum  DEwindow_mode window_mode;    /* how to display */
    struct GRid         window_grid;    /* grid of window of current soo */
    struct GRparms      boundary_parms; /* parms of a point projected    */

    struct IGRdisplay   so_form;
    IGRshort            so_type;
    IGRboolean          so_total;
    IGRboolean          so_flipper;
}

/*----------------------------------------
 *    define actions
 *----------------------------------------
 */

action set_all_windows
{
    me->window_mode = DEall_windows;

} /* set_all_windows */

action set_one_window
{
    me->window_mode = DEone_window;

} /* set_one_window */

action store_boundary_parms
{
    IGRpoint            DummyPoint;

    status = co$project_event( msg     =  sts,
                               event   = &me->event1,
                               module  = &me->ModuleInfo,
                               cob_id  =  my_id,
                               p_chanselect = &me->located_chansel,
		               parms   = &me->boundary_parms,
			       point   =  DummyPoint);

} /* store_boundary_parms */

action display_object
{
    long msg;
    struct GRid          module_grid;

    msg = OM_S_SUCCESS;

    status = ex$get_cur_mod(id = &module_grid.objid,
			    osnum = &module_grid.osnum );
	
    switch ( me->window_mode )
    {
      case DEall_windows:

             status = om$send(msg = message GRgraphics.GRdisplay(&msg,
				    &me->ModuleInfo.md_env.matrix_type,
				     me->ModuleInfo.md_env.matrix,
				    &me->DisplayMode,
				    &module_grid ),
                       p_chanselect = &me->located_chansel);

             break;
	    
      case DEone_window:

	    status = om$send( msg = message GRgraphics.GRdisplay(&msg,
                                            &me->ModuleInfo.md_env.matrix_type,
                                              me->ModuleInfo.md_env.matrix,
                                             &me->DisplayMode,
                                             &me->window_grid ),
                              p_chanselect = &me->located_chansel);

	    break;

      case DEupdate_all_win:
            status = dp$update (
                   msg   =  sts,
                   osnum = module_grid.osnum,
                   objid = module_grid.objid );

 	    break;

      case DEupdate_one_win:
            
            status = dp$update (
                   msg   =  sts,
                   osnum = me->window_grid.osnum,
                   objid = me->window_grid.objid );

	    break;

      default:
	    break;
	    
    } /* end switch ( window_mode ) */

} /* display_object */

action display_objid ( int *sts; int ele )
{
    long            msg;
    IGRboolean      show_it = FALSE;
    struct GRid     dis_grid;
    struct GRid     vw_grid;
    struct GRevent *ele_event = NULL;

    msg = OM_S_SUCCESS;

    switch( ele )
    {
       case 0:   ele_event = &me->first_event  ; break;
       case 1:   ele_event = &me->second_event ; break;
       case 2:   ele_event = &me->third_event  ; break;
       case 3:   ele_event = &me->fourth_event ; break;
       case 4:   ele_event = &me->fifth_event  ; break;
       case 5:   ele_event = &me->sixth_event  ; break;
       case 6:   ele_event = &me->seventh_event; break;
       default:  *sts = MSINARG;
    }

    dis_grid = ele_event->located_object[0].located_obj;

    switch ( me->window_mode )
    {
      case DEall_windows:

	    show_it = TRUE;
            status = ex$get_cur_mod( id = &vw_grid.objid,
                                     osnum = &vw_grid.osnum );

            break;

      case DEone_window:

	    show_it = TRUE;
            vw_grid = me->window_grid;

            break;

      default:
            break;

    } /* end switch ( window_mode ) */

    if ( show_it )
    {
      status = om$send( msg = message GRgraphics.GRdisplay(
                              &msg,
                             &me->ModuleInfo.md_env.matrix_type,
                              me->ModuleInfo.md_env.matrix,
                             &me->DisplayMode,
                             &vw_grid ),
                        targetid = dis_grid.objid,
                        targetos = dis_grid.osnum );
    }

} /* display_objid */


action init
{
   IGRushort          flags;
   struct IGRdisplay  symbology;


   status = om$send( mode     = OM_e_wrt_message,
                     msg      = message CEO_LOCATE.init( type, str_ptr ),
                     targetid = my_id );
   _m_checkq( status );

   /*
    *  as a default, set the window_mode to ALL_WINDOWS
    */
   me->window_mode = DEall_windows;

   /* default - not flipped - shortest distance between u's */
   me->so_flipper = DO_NOT_FLIP;

   dp$codpb_get_so_flags(so_flags = &flags);

   if (SO_HIDDEN & flags)
   {
      me->so_type = DE_SOE | DE_HIDDEN;
      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_on(me->status_display_form_ptr, HIDDEN);
      }

      me->so_form.color   = CLEAR_IT;   /* just added*/
      me->so_form.weight  = CLEAR_IT;
      me->so_form.style   = CLEAR_IT;

      if( me->status_display_form_ptr != NULL)
      {
         status = FIg_erase( me->status_display_form_ptr, COLOR );
         status = FIg_erase( me->status_display_form_ptr, WEIGHT );
         status = FIg_erase( me->status_display_form_ptr, STYLE );
         status = FIg_erase( me->status_display_form_ptr, CO_TEXT );
         status = FIg_erase( me->status_display_form_ptr, WT_TEXT );
         status = FIg_erase( me->status_display_form_ptr, ST_TEXT );
      }
   }
   else if (SO_INVISIBLE & flags)
   {
      me->so_type =  DE_SOE | DE_INVIS;

      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_on(me->status_display_form_ptr, INVIS);
      }

      me->so_form.color  = (IGRushort) DP_INVISIBLE_COLOR;
      me->so_form.style  = (IGRuchar)  DP_INVISIBLE_COLOR;
      me->so_form.weight = (IGRuchar)  DP_INVISIBLE_COLOR;

      if( me->status_display_form_ptr != NULL)
      {
         status = FIg_erase( me->status_display_form_ptr, COLOR );
         status = FIg_erase( me->status_display_form_ptr, WEIGHT );
         status = FIg_erase( me->status_display_form_ptr, STYLE );
         status = FIg_erase( me->status_display_form_ptr, CO_TEXT );
         status = FIg_erase( me->status_display_form_ptr, WT_TEXT );
         status = FIg_erase( me->status_display_form_ptr, ST_TEXT );
      }
   }
   else if (SO_VISIBLE & flags)
   {
      me->so_type =  DE_SOE | DE_VIS;

      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_on(me->status_display_form_ptr, VIS);
      }

      me->so_form.color   = CLEAR_IT;   /* just added*/
      me->so_form.weight  = CLEAR_IT;
      me->so_form.style   = CLEAR_IT;

      if( me->status_display_form_ptr != NULL)
      {
         status = FIg_erase( me->status_display_form_ptr, COLOR );
         status = FIg_erase( me->status_display_form_ptr, WEIGHT );
         status = FIg_erase( me->status_display_form_ptr, STYLE );
         status = FIg_erase( me->status_display_form_ptr, CO_TEXT );
         status = FIg_erase( me->status_display_form_ptr, WT_TEXT );
         status = FIg_erase( me->status_display_form_ptr, ST_TEXT );
      }
   }
   else if (SO_SPECIFIED & flags)
   {
      me->so_type = DE_SOE;

      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_on(me->status_display_form_ptr, SPECIFIED);
      }

      /*get saved symbology*/
      dp$codpb_get_so_flags(so_symbology = &symbology);

      if( me->status_display_form_ptr != NULL)
      {
         status = FIg_set_value( me->status_display_form_ptr, COLOR,  (double) symbology.color);
         status = FIg_set_value( me->status_display_form_ptr, WEIGHT, (double) symbology.weight);
         status = FIg_set_value( me->status_display_form_ptr, STYLE,  (double) symbology.style);
      }

      me->so_form.color  = symbology.color;
      me->so_form.weight = symbology.weight;
      me->so_form.style  = symbology.style;

      if( me->status_display_form_ptr != NULL)
      {
         status = FIg_display( me->status_display_form_ptr, COLOR );
         status = FIg_display( me->status_display_form_ptr, WEIGHT );
         status = FIg_display( me->status_display_form_ptr, STYLE );
         status = FIg_display( me->status_display_form_ptr, CO_TEXT );
         status = FIg_display( me->status_display_form_ptr, WT_TEXT );
         status = FIg_display( me->status_display_form_ptr, ST_TEXT );
      }
   }
   else
   {
      /* no button has been pressed on this form yet, i.e. flags is zero, so
         set defaults */
      me->so_type = DE_SOE | DE_HIDDEN;
      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_on(me->status_display_form_ptr, HIDDEN);
      }

      flags = flags |  SO_HIDDEN;	 /* set button flag to hidden    */
      flags = flags & ~SO_INVISIBLE;     /* turn off all other buttons   */
      flags = flags & ~SO_VISIBLE;
      flags = flags & ~SO_SPECIFIED;
      flags = flags & ~SO_ENABLE_TOTAL;  /* partial is to be the initial */
                                         /* default                      */
      flags = flags |  SO_ENABLE_INVIS;  /* invisibility is to be the    */
                                         /* initial default              */

      status = gr$get_active_display( buffer = &me->so_form );

      dp$codpb_put_so_flags(so_flags = &flags, so_symbology = &me->so_form);

      if( me->status_display_form_ptr != NULL)
      {
         status = FIg_set_value( me->status_display_form_ptr,
                                 COLOR,
                                 (double) me->so_form.color);
         status = FIg_set_value( me->status_display_form_ptr,
                                 WEIGHT,
                                 (double) me->so_form.weight);
         status = FIg_set_value( me->status_display_form_ptr,
                                 STYLE,
                                 (double) me->so_form.style);

         status = FIg_erase( me->status_display_form_ptr, COLOR );
         status = FIg_erase( me->status_display_form_ptr, WEIGHT );
         status = FIg_erase( me->status_display_form_ptr, STYLE );
         status = FIg_erase( me->status_display_form_ptr, CO_TEXT );
         status = FIg_erase( me->status_display_form_ptr, WT_TEXT );
         status = FIg_erase( me->status_display_form_ptr, ST_TEXT );
      }
   }


   if (SO_ENABLE_TOTAL & flags)
   {
      me->so_total = TRUE;

      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_on(me->status_display_form_ptr, PARTIAL);
      }
   }
   else
   {
      me->so_total = FALSE;

      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_off(me->status_display_form_ptr, PARTIAL);
      }
   }


   if (SO_ENABLE_INVIS & flags)
   {
      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_off(me->status_display_form_ptr, SHO_INVIS);
      }
   }
   else
   {
      if( me->status_display_form_ptr != NULL)
      {
         FIg_set_state_on(me->status_display_form_ptr, SHO_INVIS);
      }
   }
} /* init */

action sleep
{
   IGRint sts = MSSUCC; /* need for overridden message */


   status = DEshow_all_soo();
   status = DEshow_all();
   status = dp$erase_hilite( msg = &sts );

   if( me->status_display_form_ptr != NULL)
   {
      status = FIf_erase( me->status_display_form_ptr );
   }

   if (t_table)
   {
      om$dealloc(ptr = t_table);
      t_table = NULL;
   }
   if (b_table)
   {
      om$dealloc(ptr = b_table);
      b_table = NULL;
   }
   if (a_table)
   {
      om$dealloc(ptr = a_table);
      a_table = NULL;
   }
} /* sleep */

action filter
{
    IGRboolean  flag;    /* T - does     call DEshow_only_one_soo in DEselect */
                         /* F - does NOT call DEshow_only_one_soo in DEselect */

    /*
     *  initialize status to be good ( i am an optimist )
     */

    switch ( filter )
    {
        case DE_LOCATE1:
            me->select = (char (*)()) DEselect;
            me->action_handler = (char (*)()) DElocact;
            flag = TRUE;
            me->action_args = (char *)&flag;
            me->select_args = (char *)&flag;

            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(_gr_locate,
                                                               response,
                                                               response_data),
                              targetid = my_id );
            break;

        default:
            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(filter,
                                                                response,
                                                                response_data),
                              targetid = my_id );
            _m_checkq( status );
            break;

    } /* end switch */

} /* filter */

action store_locate_context
{
  IGRint                 count; /* need sts for overriden messages */
  struct GRobj_env      *object_list = 0;

  count = 0;

  status = gr$gsis_graphics_set(msg = sts,
				p_chanselect = &me->located_chansel);
  if((status&1) & (*sts&1))
     {
       gr$gsinqcount(msg = sts,
		     count = &count,
		     p_chanselect = &me->located_chansel);
       
       object_list = (struct GRobj_env *)om$malloc(
			   size = sizeof(struct GRobj_env) * count);
       
       gr$gsget_objects(msg = sts,
			array = object_list,
			size = (sizeof(struct GRobj_env) * count),
			count = &count,
			p_chanselect = &me->located_chansel);
       
       me->ModuleInfo = object_list[0].mod_env;
       om$dealloc(ptr = object_list);
     }
  else
    {
      status = om$send( mode = OM_e_wrt_message,
		       msg = message COnpt.store_locate_context(sts),
		       targetid = my_id );
    }

} /* store_locate_context */

action get_window
{
    me->window_grid.objid = me->event1.event.button.objid;
    me->window_grid.osnum = me->event1.event.button.osnum;

} /* get_window */

action get_locate_window
{
    me->window_grid.objid = me->event2.event.button.objid;
    me->window_grid.osnum = me->event2.event.button.osnum;

} /* get_locate_window */

action get_window_by_name ( int *sts; int event )
{
    IGRlong             NumberOfGrids;
    struct GRid         WindowArray[MAX_WINDOW]; /* array of window id's */
    struct GRevent     *win_event = NULL;

    /*
     *  get the window id's of all the appropriate windows.
     *  i.e. those that match the regular expression in
     *  the input string.
     */
    status = dp$get_gragad_id( msg = sts,
                               name = me->event1.event.keyin,
                               numberofids = &NumberOfGrids,
                               found_GRids = WindowArray );
    _m_check2q( status, *sts );

    /*
     *  if the number of windows that match is 0,
     *  then, prompt for another identifier
     */
    if ( NumberOfGrids == 0 )
    {
        *sts = DE_I_EXP_MATCHED_NO_WINDOW;
        goto quit;
    }
    else if ( NumberOfGrids > 1 )
    {
        *sts = DE_I_TOO_MANY_WINDOWS;
        goto quit;
    }


    /*
     *  store his window number in instance data
     *  should probably put the window on a channel, but
     *  no channel available, and also has to many implications
     */

    switch( event )
    {
       case 0:   win_event = &me->first_event  ; break;
       case 1:   win_event = &me->second_event ; break;
       default:  *sts = MSINARG;
    }

   me->window_grid.objid = win_event->event.button.objid = WindowArray[0].objid;
   me->window_grid.osnum = win_event->event.button.osnum = WindowArray[0].osnum;

} /* get_window_by_name */

action create_soo
{
    status = de$create_soo (
                msg   = sts,
                osnum = me->event1.located_object[0].located_obj.osnum );

} /* create_soo */

action project_locate_point( int *sts;
                             int  pt;
                             int  ele )
{
  extern IGRint       GRvwvolbrln();

  long                msg;
  IGRint              rc;
  IGRdouble           BorePoints[6];
  struct IGRline      BoreLine;
  struct IGRline_seg  lineseg;
  IGRpoint            DummyPoint;
  IGRpoint            Point1;
  IGRdouble           DummyDouble;
  struct GRevent     *pt_event = NULL,
                     *ele_event = NULL;
  char               class_name[80];


    msg = OM_S_SUCCESS;
    class_name[0] = NULL;

    switch( pt )
    {
       case 0:   pt_event = &me->first_event  ; break;
       case 1:   pt_event = &me->second_event ; break;
       case 2:   pt_event = &me->third_event  ; break;
       case 3:   pt_event = &me->fourth_event ; break;
       case 4:   pt_event = &me->fifth_event  ; break;
       case 5:   pt_event = &me->sixth_event  ; break;
       case 6:   pt_event = &me->seventh_event; break;
       default:  *sts = MSINARG;
    }

    switch( ele )
    {
       case 0:   ele_event = &me->first_event  ; break;
       case 1:   ele_event = &me->second_event ; break;
       case 2:   ele_event = &me->third_event  ; break;
       case 3:   ele_event = &me->fourth_event ; break;
       case 4:   ele_event = &me->fifth_event  ; break;
       case 5:   ele_event = &me->sixth_event  ; break;
       case 6:   ele_event = &me->seventh_event; break;
       default:  *sts = MSINARG;
    }

    pt_event->located_object[0].located_obj = me->event2.located_object[0].located_obj;

    BoreLine.point1 = lineseg.beg_point = &( BorePoints[0] );
    BoreLine.point2 = lineseg.end_point = &( BorePoints[3] );

    rc = GRvwvolbrln(sts, pt_event, &BoreLine);

    om$get_classname (osnum = ele_event->located_object[0].located_obj.osnum,
                      objid = ele_event->located_object[0].located_obj.objid,
                      classname = class_name);

    if (!strcmp (class_name, "GR3dtext")) {
     status = om$send(
     msg =  message GRgraphics.GRlnproject(
        &msg,
       &ele_event->located_object[0].module_info.md_env.matrix_type,
        ele_event->located_object[0].module_info.md_env.matrix,
       &BoreLine,
        DummyPoint,
        Point1,
       &DummyDouble,
       &pt_event->located_object[0].geom_parms ),
     targetid = ele_event->located_object[0].located_obj.objid,
     targetos = ele_event->located_object[0].located_obj.osnum );
    }
    else {
    status = om$send(
     msg =  message GRbspline.GRlinesegproj(
        &msg,
       &ele_event->located_object[0].module_info.md_env.matrix_type,
        ele_event->located_object[0].module_info.md_env.matrix,
       &lineseg,
        DummyPoint,
        Point1,
       &DummyDouble,
       &pt_event->located_object[0].geom_parms ),
     targetid = ele_event->located_object[0].located_obj.objid,
     targetos = ele_event->located_object[0].located_obj.osnum );
  }

} /* project_locate_point */

action project_data_point( int *sts; int ele )
{
  extern IGRint       GRvwvolbrln();

  long                msg;
  IGRint              rc;
  IGRdouble           BorePoints[6];
  struct IGRline      BoreLine;
  struct IGRline_seg  lineseg;
  IGRpoint            DummyPoint;
  IGRpoint            Point1;
  IGRdouble           DummyDouble;
  struct GRevent     *ele_event = NULL;


    msg = OM_S_SUCCESS;

    switch( ele )
    {
       case 0:   ele_event = &me->first_event  ; break;
       case 1:   ele_event = &me->second_event ; break;
       case 2:   ele_event = &me->third_event  ; break;
       case 3:   ele_event = &me->fourth_event ; break;
       case 4:   ele_event = &me->fifth_event  ; break;
       case 5:   ele_event = &me->sixth_event  ; break;
       case 6:   ele_event = &me->seventh_event; break;
       default:  *sts = MSINARG;
    }

    BoreLine.point1 = lineseg.beg_point = &( BorePoints[0] );
    BoreLine.point2 = lineseg.end_point = &( BorePoints[3] );

    rc = GRvwvolbrln(sts, ele_event, &BoreLine);

    status = om$send(
     msg =  message GRbspline.GRlinesegproj(
        &msg,
       &ele_event->located_object[0].module_info.md_env.matrix_type,
        ele_event->located_object[0].module_info.md_env.matrix,
       &lineseg,
        DummyPoint,
        Point1,
       &DummyDouble,
       &ele_event->located_object[0].geom_parms ),
     targetid = ele_event->located_object[0].located_obj.objid,
     targetos = ele_event->located_object[0].located_obj.osnum );

} /* project_data_point */

action remove_sym_o
{
  struct IGRdisplay display;
  IGRint            type;
  IGRdouble         u1,
                    u2;

  status = de$retrieve_override (
           msg          =  sts,
           p_type       = &type,
           p_symbology  = &display,
           p_u1         = &u1,
           p_u2         = &u2,
           go_grid      = &me->first_event.located_object[0].geom_parms.leaf_id,
           u            =  me->first_event.located_object[0].geom_parms.u,
           window_grid  = &me->window_grid,
           module       = &me->ModuleInfo );

  if ( *sts == MSSUCC )
  {
    status = de$delete_override(
            msg         =  sts,
            type        =  type,
            symbology   = &display,
            u1          =  u1,
            u2          =  u2,
            go_grid     = &me->first_event.located_object[0].geom_parms.leaf_id,
            window_grid = &me->window_grid,
            module      = &me->ModuleInfo );

    if ( type & DE_OVERLAP )
    {
      status = de$next_override (
                 msg         =  sts,
                 p_type      = &type,
                 p_symbology = &display,
                 p_u1        = &u1,
                 p_u2        = &u2 );

      status = de$delete_override(
            msg         =  sts,
            type        =  type,
            symbology   = &display,
            u1          =  u1,
            u2          =  u2,
            go_grid     = &me->first_event.located_object[0].geom_parms.leaf_id,
            window_grid = &me->window_grid,
            module      = &me->ModuleInfo );
    }
  }

} /* remove_sym_o */

action show_only_one_soo
{
  status = DEshow_only_one_soo(
              sts,
             &me->first_event.located_object[0].located_obj,
              me->first_event.located_object[0].geom_parms.u,
             &me->window_grid,
             &me->ModuleInfo );

} /* show_only_one_soo */

action show_only_soo
{
  status = DEshow_only_soo();

} /* show_only_soo */

action show_all
{
  status = DEshow_all();

} /* show_all */

action show_only_man_soo
{
  status = DEshow_only_man_soo();

} /* show_only_man_soo */

action show_all_soo
{
  status = DEshow_all_soo();

} /* show_all_soo */

action update_all_win
{
    me->window_mode = DEupdate_all_win;

} /* update_all_win */

action update_one_win
{
    me->window_mode = DEupdate_one_win;

} /* update_one_win */

action smart_prompt
{
    if ( queue_empty && vsd_empty )
    {
       ex$message( in_buff       = me->prompt,
                   field         = PROMPT_FIELD,
                   justification = RIGHT_JUS );
    }
}/* smart_prompt */

action place_sym_o_form
{

/* This algorithm is valid for placing partial SOs
   If SO is NOT some version of flip
      Save all SOs
      Place original SO
   If SO is to flip the original SO
      Delete the original SO
      Place the saved SOs
      Place the flipped SO
   If SO is to unflip the SO
      Delete the flipped SO
      Place the saved SOs
      Place the original SO
 */

  IGRint i;

  if ( me->so_total )
  {
    OMuint               count;
    struct GRid          target_grid;
    IGRlong              string_status;
    OM_S_CHANSELECT      to_comp_chandef;
    OM_S_OBJECT_LINKAGE *channel_list = NULL;
    IGRchar              class_name[80];


    count = 0;
    class_name[0] = NULL;

    target_grid.objid = me->event1.located_object[0].located_obj.objid;
    target_grid.osnum = me->event1.located_object[0].located_obj.osnum;

    status = om$get_classname( classname = class_name,
                               objid     = target_grid.objid,
                               osnum     = target_grid.osnum );

    /*
     *  check the classname
     */
    status = om$is_ancestry_valid( subclassname   = class_name,
                                   superclassname = "GRgrgrp" );

    string_status = strcmp( class_name, "GRgrgrp" ) == 0;

    if (! ((status == OM_I_INVANCESTRY) && (!string_status)) )
    { /* gotta graphic set/group */

       status = om$make_chanselect(channame     = "GRcmpowner.to_components",
                                   p_chanselect = &to_comp_chandef );

       status = om$get_channel_count( objid        =  target_grid.objid,
                                      osnum        =  target_grid.osnum,
                                      p_chanselect = &to_comp_chandef,
                                      count        = &count);

       channel_list = (OM_S_OBJECT_LINKAGE *) om$malloc(
                      size = (sizeof(OM_S_OBJECT_LINKAGE)) * count);

      /*
       * Get objid and object space number of GO
       */
       status = om$get_channel_objects( objid        =  target_grid.objid,
                                        osnum        =  target_grid.osnum,
                                        p_chanselect = &to_comp_chandef,
                                        list         =  channel_list,
                                        size         =  count,
                                        count        = &count);

       for ( i = 0; i < count; i++ )
       {
         target_grid.objid = channel_list[i].S_objid;
         target_grid.osnum = channel_list[i].osnum;
         status = de$place_override(
                 msg         =  sts,
                 symbology   = &me->so_form,
                 go_grid     = &target_grid,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );
       }

       om$dealloc(ptr = channel_list);
    }
    else
    { /* gotta GO */

      status = de$place_override(
                 msg         =  sts,
		 type        =  me->so_type,
                 symbology   = &me->so_form,
                 go_grid     = &target_grid,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );
    }
  }
  else
  {
    long          msg;
    IGRboolean    cross = FALSE;
    IGRshort      tmp_type;
    IGRdouble     start1,
                  stop1 = 0.0,
                  start2,
                  stop2 = 0.0;
    struct        GRprops     Properties;

    msg = OM_S_SUCCESS;

    start1 = me->first_event.located_object[0].geom_parms.u;
    start2 = me->second_event.located_object[0].geom_parms.u;

    status = om$send( msg = message GRvg.GRgeomprops(
                         &msg,
                        &me->ModuleInfo.md_env.matrix_type,
                         me->ModuleInfo.md_env.matrix,
                        &Properties ),
             targetid = me->second_event.located_object[0].located_obj.objid,
             targetos = me->second_event.located_object[0].located_obj.osnum);
    if ( !(status & msg & 1) )
       goto quit;

    if ( Properties.phy_closed )
    {
       IGRint     	  *types;
       IGRdouble  	  *boundary_parms;
       struct GRid        soo;
       struct IGRdisplay  *display_attributes;
       static IGRint      count;

      if ((start1 == 0.0) || (start1 == 1.0) || (start2 == 0.0) || (start2 == 1.0))
        cross = ON_OVERLAP;

      if ( me->so_flipper != NEEDS_FLIP && me->so_flipper != NEEDS_UNFLIP )
      {
        struct IGRdisplay orig_ele_attr;

        status = gr$get_active_display( buffer = &orig_ele_attr );

        DEget_soo ( &soo.objid,
                    &soo.osnum,
                     me->second_event.located_object[0].located_obj.osnum );

        status = om$send ( msg = message DEso.DEget (
                    &msg,
                    &types,
                    &boundary_parms,
                    &count,
                    &display_attributes,
                    &orig_ele_attr,
                     me->second_event.located_object[0].located_obj.objid,
                     me->window_grid.objid,
                    &me->ModuleInfo.md_env.matrix_type,
                     me->ModuleInfo.md_env.matrix,
		     0,
                     0 ),
               targetid = soo.objid,
               targetos = soo.osnum);
       
	if (count)
	{
          if (t_table)
            t_table = (int *) realloc ( t_table, sizeof ( int ) * count);
          else
            t_table = (int *) om$malloc ( size = sizeof ( int ) * count);

          if (b_table)
            b_table = (double *) realloc ( b_table, sizeof ( double ) * 2 * count);
          else
            b_table = (double *) om$malloc ( size = sizeof ( double ) * 2 * count);

          if (a_table)
            a_table = (struct IGRdisplay *) realloc ( a_table, sizeof ( struct IGRdisplay ) * count);
          else
            a_table = (struct IGRdisplay *) om$malloc ( size = sizeof ( struct IGRdisplay ) * count);

          for ( i=0; i<count; i++ )
          {
            t_table[i]     = types[i];
            b_table[i*2]   = boundary_parms[i*2];
            b_table[i*2+1] = boundary_parms[i*2+1];
            a_table[i]     = display_attributes[i];
          }
	}
      }

      if ( start1 < start2 )
      {
        if ( (start2 - start1) > ( start1 + ( 1 - start2 ) ) )
        {
	  if ( start1 == 0 )
	  {
            start1 = me->first_event.located_object[0].geom_parms.u = 1.0;
	  }
	  else
	  {
	    cross = TRUE;
            stop1 = 0.0;
            stop2 = 1.0;
	  }
        }
      }
      else
      {
        if ( (start1 - start2) > ( start2 + ( 1 - start1 ) ) )
	{
	  if ( start2 == 0 )
	  {
            start2 = me->second_event.located_object[0].geom_parms.u = 1.0;
	  }
	  else
	  {
	    cross = TRUE;
            stop1 = 1;
            stop2 = 0;
	  }
	}
      }

      if ( me->so_flipper == NEEDS_FLIP )
      {
        if ( cross == TRUE )
        {
	  IGRdouble del_u11,
		    del_u12,
		    del_u21,
		    del_u22;

	  if ( start1 < start2 )
	  {
	    del_u11 = 0;
	    del_u12 = start1;
	    del_u21 = start2;
	    del_u22 = 1;
	  }
	  else
	  {
	    del_u11 = start1;
	    del_u12 = 1;
	    del_u21 = 0;
	    del_u22 = start2;
	  }

	  tmp_type = me->so_type | DE_OVERLAP;

          status = de$delete_override(
                 msg         =  sts,
                 type        =  tmp_type,
                 symbology   = &me->so_form,
                 u1          =  del_u11,
                 u2          =  del_u12,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

          status = de$delete_override(
                 msg         =  sts,
                 type        =  tmp_type,
                 symbology   = &me->so_form,
                 u1          =  del_u21,
                 u2          =  del_u22,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

	  cross = FALSE;
        }
        else
        {
          status = de$delete_override(
                 msg         =  sts,
	         type        =  me->so_type,
                 symbology   = &me->so_form,
                 u1          =  start1,
                 u2          =  start2,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

	  if ( cross != ON_OVERLAP )
	  {
	    if ( start1 < start2 )
	    {
	      stop1 = 0;
	      stop2 = 1;
	    }
	    else
	    {
	      stop1 = 1;
	      stop2 = 0;
	    }

	    cross = TRUE;
	  }
	  else
	  {
	    if (start1 == 0.0)
	      start1 = 1.0;
	    else if (start1 == 1.0)
		   start1 = 0.0;
	    else if (start2 == 0.0)
		   start2 = 1.0;
	    else if (start2 == 1.0)
		   start2 = 0.0;
	  }
        }

	for ( i=0; i<count; i++ )
	{
          status = de$place_override(
                 msg         =  sts,
                 type        =  t_table[i],
                 symbology   = &a_table[i],
                 u1          =  b_table[i*2],
                 u2          =  b_table[i*2+1],
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );
	}

        me->so_flipper = FLIPPED;
      }

      if ( me->so_flipper == NEEDS_UNFLIP )
      {
        if ( cross == FALSE )
        {
	  IGRdouble del_u11,
		    del_u12,
		    del_u21,
		    del_u22;

	  if ( start1 < start2 )
	  {
	    del_u11 = 0;
	    del_u12 = start1;
	    del_u21 = start2;
	    del_u22 = 1;
	  }
	  else
	  {
	    del_u11 = start1;
	    del_u12 = 1;
	    del_u21 = 0;
	    del_u22 = start2;
	  }

	  tmp_type = me->so_type | DE_OVERLAP;

          status = de$delete_override(
                 msg         =  sts,
                 type        =  tmp_type,
                 symbology   = &me->so_form,
                 u1          =  del_u11,
                 u2          =  del_u12,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

          status = de$delete_override(
                 msg         =  sts,
                 type        =  tmp_type,
                 symbology   = &me->so_form,
                 u1          =  del_u21,
                 u2          =  del_u22,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

	  cross = FALSE;
        }
        else
        {
	  if ( cross == TRUE )
	  {
            status = de$delete_override(
                 msg         =  sts,
	         type        =  me->so_type,
                 symbology   = &me->so_form,
                 u1          =  start1,
                 u2          =  start2,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

	    if ( start1 < start2 )
	    {
	      stop1 = 0;
	      stop2 = 1;
	    }
	    else
	    {
	      stop1 = 1;
	      stop2 = 0;
	    }

	    cross = TRUE;
	  }
	  else
	  {
	    if (start1 == 0.0)
	      start1 = 1.0;
	    else if (start1 == 1.0)
		   start1 = 0.0;
	    else if (start2 == 0.0)
		   start2 = 1.0;
	    else if (start2 == 1.0)
		   start2 = 0.0;

            status = de$delete_override(
                 msg         =  sts,
	         type        =  me->so_type,
                 symbology   = &me->so_form,
                 u1          =  start1,
                 u2          =  start2,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

	    if (start1 == 0.0)
	      start1 = 1.0;
	    else if (start1 == 1.0)
		   start1 = 0.0;
	    else if (start2 == 0.0)
		   start2 = 1.0;
	    else if (start2 == 1.0)
		   start2 = 0.0;
	  }
        }

        me->so_flipper = DO_NOT_FLIP;

	for ( i=0; i<count; i++ )
	{
          status = de$place_override(
                 msg         =  sts,
                 type        =  t_table[i],
                 symbology   = &a_table[i],
                 u1          =  b_table[i*2],
                 u2          =  b_table[i*2+1],
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );
	}
      }
    }

    if ( cross == TRUE )
    {
      tmp_type = me->so_type | DE_OVERLAP;

      status = de$place_override(
                 msg         =  sts,
                 type        =  tmp_type,
                 symbology   = &me->so_form,
                 u1          =  start1,
                 u2          =  stop1,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );

      status = de$place_override(
                 msg         =  sts,
                 type        =  tmp_type,
                 symbology   = &me->so_form,
                 u1          =  start2,
                 u2          =  stop2,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );
    }
    else
    {
      tmp_type = me->so_type & (~ DE_OVERLAP);

      status = de$place_override(
                 msg         =  sts,
		 type        =  tmp_type,
                 symbology   = &me->so_form,
                 u1          =  start1,
                 u2          =  start2,
                 go_grid     = &me->second_event.located_object[0].located_obj,
                 window_grid = &me->window_grid,
                 module      = &me->ModuleInfo );
    }
  }

} /* place_sym_o_form */


action form_notification
{
  IGRlong    msg;
  IGRint     mystate, response;
  IGRdouble  myvalue;
  int        num_char = 9;
  int        dum1;
  int        dum2;
  IGRchar    mynewvalue[9];
  static IGRushort  flags;
  static struct IGRdisplay symbology;
  static int	    first_call=TRUE;

  extern int FIg_get_state();
  extern int FIg_set_state_off();
  extern int FIg_set_value();
  extern int FIg_get_value();
 
  msg = OM_S_SUCCESS;

  if (first_call == TRUE)
    {
      dp$codpb_get_so_flags(so_flags = &flags, so_symbology = &symbology);
      first_call = FALSE;
    }

  switch( gadget_label )
  {
    case ACCEPT:
    {
      status= om$send(msg = message CEO.erase_form_by_label( form_label,
                                                             0,
                                                            (int *)&msg),
                      targetid = my_id);

      status = FIg_set_state_off( form_ptr, ACCEPT );
      response = EX_FORM_FINISHED;
      ex$putque( msg      = &msg,
                  response = &response );

      break;
    }
    case WINDOW:
    {
      status = FIg_disable( form_ptr, WINDOW );

      break;
    }
    case HIDDEN:
    {
      me->so_type = DE_SOE | DE_HIDDEN;

      flags = flags |  SO_HIDDEN;	/*set button flag to hidden*/
      flags = flags & ~SO_INVISIBLE;	/*turn off all other buttons*/
      flags = flags & ~SO_VISIBLE;
      flags = flags & ~SO_SPECIFIED;

      me->so_form.color   = CLEAR_IT;   /* just added*/
      me->so_form.weight  = CLEAR_IT;
      me->so_form.style   = CLEAR_IT;

      dp$codpb_put_so_flags(so_flags = &flags);

      status = FIg_erase( form_ptr, COLOR );
      status = FIg_erase( form_ptr, WEIGHT );
      status = FIg_erase( form_ptr, STYLE );
      status = FIg_erase( form_ptr, CO_TEXT );
      status = FIg_erase( form_ptr, WT_TEXT );
      status = FIg_erase( form_ptr, ST_TEXT );

      break;
    }
    case INVIS:
    {
      me->so_type = DE_SOE | DE_INVIS;

      flags = flags & ~SO_HIDDEN;	
      flags = flags |  SO_INVISIBLE;	/*set button flag to invisible*/
      flags = flags & ~SO_VISIBLE;	/*turn off all other buttons*/
      flags = flags & ~SO_SPECIFIED;

      dp$codpb_put_so_flags(so_flags = &flags);

      me->so_form.color  = (IGRushort) DP_INVISIBLE_COLOR;
      me->so_form.style  = (IGRuchar)  DP_INVISIBLE_COLOR;
      me->so_form.weight = (IGRuchar)  DP_INVISIBLE_COLOR;

      status = FIg_erase( form_ptr, COLOR );
      status = FIg_erase( form_ptr, WEIGHT );
      status = FIg_erase( form_ptr, STYLE );
      status = FIg_erase( form_ptr, CO_TEXT );
      status = FIg_erase( form_ptr, WT_TEXT );
      status = FIg_erase( form_ptr, ST_TEXT );

      break;
    }
    case VIS:
    {
      me->so_type = DE_SOE | DE_VIS;

      flags = flags & ~SO_HIDDEN;	/*turn off all other buttons*/
      flags = flags & ~SO_INVISIBLE;	
      flags = flags |  SO_VISIBLE;	/*set button flag to visible*/
      flags = flags & ~SO_SPECIFIED;

      dp$codpb_put_so_flags(so_flags = &flags);

      me->so_form.color   = CLEAR_IT;   /* just added*/
      me->so_form.weight  = CLEAR_IT;
      me->so_form.style   = CLEAR_IT;

      status = FIg_erase( form_ptr, COLOR );
      status = FIg_erase( form_ptr, WEIGHT );
      status = FIg_erase( form_ptr, STYLE );
      status = FIg_erase( form_ptr, CO_TEXT );
      status = FIg_erase( form_ptr, WT_TEXT );
      status = FIg_erase( form_ptr, ST_TEXT );

      break;
    }
    case SPECIFIED:
    {
      me->so_type = DE_SOE;

      flags = flags & ~SO_HIDDEN;	/*turn off all other buttons*/
      flags = flags & ~SO_INVISIBLE;	
      flags = flags & ~SO_VISIBLE;	
      flags = flags |  SO_SPECIFIED;	/*set button flag to specified*/

      dp$codpb_put_so_flags(so_flags = &flags);

      status = FIg_set_value( form_ptr, COLOR,  (double) symbology.color );
      status = FIg_set_value( form_ptr, WEIGHT, (double) symbology.weight );
      status = FIg_set_value( form_ptr, STYLE,  (double) symbology.style );

      me->so_form.color   = symbology.color;   /* just added*/
      me->so_form.weight  = symbology.weight;
      me->so_form.style   = symbology.style;

      status = FIg_display( form_ptr, COLOR );
      status = FIg_display( form_ptr, WEIGHT );
      status = FIg_display( form_ptr, STYLE );
      status = FIg_display( form_ptr, CO_TEXT );
      status = FIg_display( form_ptr, WT_TEXT );
      status = FIg_display( form_ptr, ST_TEXT );

      break;
    }
    case PARTIAL:
    {
      status = FIg_get_state( form_ptr, PARTIAL, &mystate );

      if ( mystate )
	{
          flags = flags | SO_ENABLE_TOTAL;	/*total is on*/
          me->so_total = TRUE;		/*I'm not sure this var is needed anymore?*/
	}
      else
	{
          flags = flags & ~SO_ENABLE_TOTAL;
          me->so_total = FALSE;		/*I'm not sure this var is needed anymore?*/
	}

      dp$codpb_put_so_flags(so_flags = &flags);

      response = EX_FORM_FINISHED;
      ex$putque( msg      = &msg,
                  response = &response );
      break;
    }
    case SHO_INVIS:
    {
      struct GRid module_grid;
      IGRboolean tmpstate;

      status = FIg_get_state( form_ptr, SHO_INVIS, &mystate );

      if ( mystate )
        flags = flags & ~SO_ENABLE_INVIS;   /*if true, invisibility is off*/
      else
        flags = flags |  SO_ENABLE_INVIS;   /*if false, invisibility is on*/

      dp$codpb_put_so_flags(so_flags = &flags);

      mystate = !mystate;
      tmpstate = (IGRboolean)mystate; /* Sun requires a short here */
      status = gr$put_invis_so_on( buffer = &tmpstate );

      status = ex$get_cur_mod( id = &module_grid.objid,
			       osnum = &module_grid.osnum );

      status = dp$update( msg   = &msg,
                          osnum =  module_grid.osnum,
                          objid =  module_grid.objid );

      break;
    }
    case COLOR:
    {
      int num;

      status = FIfld_get_text( form_ptr, COLOR, 0, 0,
                               num_char, mynewvalue, &dum1, &dum2 );

      num = atoi(mynewvalue);

      if ( ! num )
      {
        IGRushort color;
        struct GRid module_grid;

        status = ex$get_cur_mod( id    = &module_grid.objid,
                                 osnum = &module_grid.osnum );

        status = ige$get_color_from_name( name      =  mynewvalue,
                                          color     =  ( IGRshort *)&color,
                                          mod_id    =  module_grid.objid,
                                          mod_osnum =  module_grid.osnum );

        if ( status & 1 )
        {
          me->so_form.color = color;
	  symbology.color = color;
        }
      }
      else
	{
          me->so_form.color = (IGRushort)num;
	  symbology.color = (IGRushort)num;
	}

      dp$codpb_put_so_flags(so_symbology = &symbology);

      status = FIg_set_value( form_ptr, COLOR, (double)me->so_form.color );

      break;
    }
    case WEIGHT:
    {
      status = FIg_get_value( form_ptr, WEIGHT, &myvalue );
      me->so_form.weight = myvalue;

      symbology.weight = myvalue;
      dp$codpb_put_so_flags(so_symbology = &symbology);

      break;
    }
    case STYLE:
    {
      status = FIg_get_value( form_ptr, STYLE, &myvalue );
      me->so_form.style = myvalue;

      symbology.style = myvalue;
      dp$codpb_put_so_flags(so_symbology = &symbology);

      break;
    }
  }
} /* form_notification */


action some_or_all
{
  if ( me->so_total ){
    if (me->so_type & DE_HIDDEN) {
       *sts = 99;
    }
    else if ((me->so_type == DE_SOE) && (me->so_form.style != 0)) {
       *sts = 99;
    }
    else {
      *sts = 77;
    }
  }
  else
    *sts = 55;
} /* some_or_all */

action status_disp
{
  IGRboolean          mystate;
  char               *form_ptr;
  int index, msg;

  extern int          FIg_set_state_on();
  extern int          FIg_set_state_off();

  status = om$send( msg = message CEO.get_form_ptr( STATUS_FORM, &form_ptr,
                                                    &index, &msg ),
                    targetid = my_id );
  _m_checkq( status );

  if ( form_ptr  ) {
/*
 *  Command has a status display form & we are controling when the form
 *  will be displayed.  This means the status form will be displayed
 *  after we initialize the gadgets.
 */
    status = gr$get_invis_so_on( buffer = &mystate );
    
    if ( mystate )
      status = FIg_set_state_off( form_ptr, SHO_INVIS );
    else
      status = FIg_set_state_on( form_ptr, SHO_INVIS );

    status = om$send( msg = message CEO.status_disp(),
                      mode = OM_e_wrt_message, targetid = my_id );
    _m_checkq( status );
  }
  else {
/*
 *  Command does not have a status display form
 */
    status = om$send( msg = message CEO.status_disp(),
                      mode = OM_e_wrt_message, targetid = my_id );
    _m_checkq( status );
  }

} /* status_disp */

action so_flip_flop
{
  if ( me->so_flipper == DO_NOT_FLIP )
    me->so_flipper = NEEDS_FLIP;

       else if ( me->so_flipper == FLIPPED )
              me->so_flipper = NEEDS_UNFLIP;

            else if ( me->so_flipper == UNFLIPPED )
                   me->so_flipper = DO_NOT_FLIP;
} /* so_flip_flop */

action so_flip_off
{
  me->so_flipper = DO_NOT_FLIP;
} /* so_flip_off */

action show_sym_o
{
  long    msg;
  IGRlong size;
  IGRint  response;
  IGRchar command_key[30];

  msg = OM_S_SUCCESS;

  if ( me->first_event.response == EX_STRING )
  {
    size = strlen( me->first_event.event.keyin ) + 1;
    response = EX_STRING;

    status = ex$putque( msg      =  &msg,
                        response = &response,
                        byte     = &size,
                        buffer   =  me->first_event.event.keyin );
  }
  else
  {
    response = EX_DATA;
    size = sizeof(struct GRevent)-(2*sizeof(IGRlong));

    status = ex$putque( msg      =  &msg,
                        response = &response,
                        byte     = &size,
                        buffer   = (char *)&me->first_event.event );
  }
 
  strcpy( command_key, "GRSlEInV" );
  size = strlen( command_key ) + 1;
  response = EX_CMD_KEY;

  status = ex$putque( msg      =  &msg,
                      response = &response,
                      byte     = &size,
                      buffer   =  command_key );

} /* show_sym_o */

action is_keypoint
{
  if (me->event2.subtype == GRst_KEYPOINT)
    *sts = 1;
  else
    *sts = 0;

} /* is_keypoint */ 

action process_group
{
  struct GRid vw_grid;

  vw_grid.objid = me->second_event.event.button.objid;
  vw_grid.osnum = me->second_event.event.button.osnum;

  status = COshowsymo( sts,
                      &my_id,
                      &vw_grid,
                      &me->second_event );

} /* process_group */


action store_event( int f, t )
{
   struct GRevent e;

   if (f > 0 && f < 4 && t >= 0 && t <= 6)
   {
      me->ret = MSSUCC;
      if (f == 1)
      {
         e = me->event1;
      }
      else if (f == 2)
      {
         e = me->event2;
      }
      else
      {
         e = me->event3;
      }

      switch( t )
      {
         case 0:   me->first_event   = e;
                   break;
         case 1:   me->second_event  = e;
                   break;
         case 2:   me->third_event   = e;
                   break;
         case 3:   me->fourth_event  = e;
                   break;
         case 4:   me->fifth_event   = e;
                   break;
         case 5:   me->sixth_event   = e;
                   break;
         case 6:   me->seventh_event = e;
                   break;
      }
   }
   else
   {
      me->ret = MSFAIL;
   }
}  /* store_event */


action erase_hilite_plane ()
{
    status = dp$erase_hilite (msg = &me->ret,
                              objid = me->ModuleInfo.md_id.objid,
                              osnum = me->ModuleInfo.md_id.osnum);
}

 
