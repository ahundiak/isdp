 
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

/*
DESCRIPTION
   command object to create NC toolpath objects.
   preliminary for testing


HISTORY
   07/20/88   KMJ   Created
   09/06/88   KMJ   Added toolholder
*/


class           NCcretp
spec_path       "$DRAFT/display/spec"
spec_path       "$DRAFT/go/spec"
super_class     CEO_LOCATE
command_string  NC_M_CreToolPath,0,HScretp
product_name    "$MODEL"
start_state     construct_tp_obj


specification

#include "hnmill.h"
#include "hsncdef.h"

#define LOCAL_DISP_LIST_SIZE   5120
#define LOCAL_MAX_5AX_STEPS    150

instance
{
   OM_S_OBJID           tp_id;                         /* the toolpath object */
                                                       /* id                  */

   int                  command_id;                    /* the command id      */
   IGRint               num_quadwords;                 /* the command size    */
   IGRdouble            command[LOCAL_DISP_LIST_SIZE]; /* the command itself  */
   struct GRid          curve_id;                      /* the curve osnum and */
                                                       /* objid               */

   struct IGRbsp_curve  *curve;                        /* the curve definition*/
   IGRint               num_orients;                   /* the 5-axis          */
                                                       /* orientation count   */

   IGRdouble            orient[LOCAL_MAX_5AX_STEPS];   /* the 5-axis step     */
                                                       /* orientations        */

   IGRint               tp_color_option;               /* the sub-toolpath    */
                                                       /* color mode          */

   IGRint               tp_trans_option;               /* the sub_toolpath    */
                                                       /* trans mode          */

   IGRint               tp_speed_option;               /* the sub-toolpath    */
                                                       /*  speed mode         */

   IGRint               color;                         /* the user-defined    */
                                                       /* color               */

   IGRint               trans_flag;                    /* tool translucency   */
                                                       /* mode                */

   IGRint               speed;                         /* the user-defined    */
                                                       /* speed   */
}


implementation

#define C_TOOL                5001
#define C_TOOL_ORIENTATION    5002
#define C_3AXIS_SUB_TOOLPATH  5003
#define C_ARC_SUB_TOOLPATH    5004
#define C_TOOLHOLDER          5005
#define C_END_TOOLPATH        5006
#define C_5AXIS_SUB_TOOLPATH  5007
#define IT_IS_CURVE           5010
#define NC_DIR_E_NAME_DUP     5011
#define IT_IS_LINESTRING      5012
#define NEED_MORE_ORIENTS     5013
#define HAVE_ALL_ORIENTS      5014
#define INVALID_ACTION        6001
#define C_TOOL_COLOR          5001
#define C_TP_COLOR            5002
#define C_USER_COLOR          5003
#define C_GLOBAL_SPEED        5001
#define C_USER_SPEED          5002

#define DEBUG                 0
#define CHECK_RETURN_CODES    1

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

#include "dpmacros.h"
#include "dpstruct.h"
#include "dpdef.h"

#include "grdpbmacros.h"
#include "madef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "hnerr.h"

#include "tools.h"

#include "HSpr_co_imp.h"

/*
 * Local functions.
 */

#include "igrtypedef.h"
#include "igr.h"
#include "stdio.h"
#include "bs.h"
#include "bsdefs.h" 
#include "bserr.h"
#include "bsparameters.h"



/*---assign_bsp_curve------------------------------------------------------------*/

void assign_bsp_curve( struct IGRbsp_curve *curve,
                       IGRdouble           *command,
                       IGRint              *num_quadwords )


/* 
 * Abstract:    assign bsp_curve to disp_list commands
 *
 * History:   07/00/88   KMJ   Created
 *
 */

{
   uint16  *val16;
   double  *val64;
   int     *val32;
   int     size;
   int     i;

   *num_quadwords += 1;

   val16 = (uint16 *)command;

   *val16++ = (uint16)curve->order;    /* order   */
   *val16 = 0;                         /* flags   */

   if(curve->periodic)
   {
      *val16 |= CV_PERIODIC_M;
   }

   if(curve->non_uniform)
   {
      *val16 |= CV_NON_UNIFORM_M;
   }

   if(curve->rational)
   {
      *val16 |= CV_RATIONAL_M;
   }

   if(curve->planar)
   {
      *val16 |= CV_PLANAR_M;
   }

   if(curve->phy_closed)
   {
      *val16 |= CV_PHY_CLOSED_M;
   }

   val16++;

   val32 = (int *)val16;
   
   *val32++ = curve->num_poles;
   
   val64 = (double *)val32;

   size = 3 * curve->num_poles;
   *num_quadwords += size;

   for (i=0; i<size; i++)
   {
      *val64++ = curve->poles[i];
   }

   if (curve->non_uniform)
   {
      size = curve->order + curve->num_poles;
      *num_quadwords += size;
      for (i=0; i<size; i++) *val64++ = curve->knots[i];
   }
   
   if (curve->rational)
   {
      size = curve->num_poles;
      *num_quadwords += size;
      for (i=0; i<size; i++)   *val64++ = curve->weights[i];
   }
}


/*
 *  Prototype declaration for static functions
 */


%safe
#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* NCcretpi.I */

static void CreateCoordSystem( IGRvector vector, 
                               IGRvector x, 
                               IGRvector y, 
                               IGRvector z);

#undef __

%endsafe


/*---CreateCoordSystem------------------------------------------------------------*/
/*
Rotation matrix to convert from local (tool) to global coord. system
   (x[0] y[0] z[0])
   (x[1] y[1] z[1])
   (x[2] y[2] z[2])
*/

static void CreateCoordSystem ( IGRvector   vector,
                                IGRvector   x,
                                IGRvector   y, 
                                IGRvector   z )

{
   IGRint i;
   IGRdouble size = 0.0;


   for (i = 0; i < 3; i++)
   {
      size += vector[i] * vector[i];
   }

   size = sqrt (size);

   for (i = 0; i < 3; i++)
   {
      z[i] = vector[i] / size;
   }

   if ((z[2] > 0.99999) || (z[2] < -0.99999))
   {
      x[0] = 1.0;
      x[1] = 0.0;
      x[2] = 0.0;
      y[0] = 0.0;
      y[1] = z[2];
      y[2] = 0.0;
   }
   else
   {
      IGRdouble denominator;

      denominator = sqrt (z[0] * z[0] + z[1] * z[1]);

      x[0] = - z[1] / denominator;
      x[1] =   z[0] / denominator;
      x[2] =   0.0;
      y[0] = - z[0] * z[2] / denominator;
      y[1] = - z[1] * z[2] / denominator;
      y[2] =   denominator;
   }
}


from GRvg         import GRgetsize, GRgetgeom, GRgetsymb;
from HSNCtoolpth  import add_to_disp_list, my_construct;


state_table

#define C_TOOL                5001
#define C_TOOL_ORIENTATION    5002
#define C_3AXIS_SUB_TOOLPATH  5003
#define C_ARC_SUB_TOOLPATH    5004
#define C_TOOLHOLDER          5005
#define C_END_TOOLPATH        5006
#define C_5AXIS_SUB_TOOLPATH  5007
#define IT_IS_CURVE           5010
#define NC_DIR_E_NAME_DUP     5011
#define IT_IS_LINESTRING      5012
#define NEED_MORE_ORIENTS     5013
#define HAVE_ALL_ORIENTS      5014
#define INVALID_ACTION        6001
#define C_TOOL_COLOR          5001
#define C_TP_COLOR            5002
#define C_USER_COLOR          5003
#define C_GLOBAL_SPEED        5001
#define C_USER_SPEED          5002

#define erase                 0


state    *         
   on EX_RJT_MOVEON state .
   on EX_RESTART    state .


state    construct_tp_obj
message  "Create NC toolpath objects"
prompt   "Key in toolpath object name:"      
filter   get_event

   on EX_DATA
      state .
   on EX_STRING
      do create_tp_obj
         on NC_DIR_E_NAME_DUP
            state dup_tp_obj
         on INVALID_ACTION
            do status "Invalid object name, try again"
            state .
         on SUCCESS
            state select_options
      state .
   on EX_BACK_UP
      state .


state    dup_tp_obj
execute  print_tp_obj
status   "Object name duplicated, delete old tp obj?"
prompt   "Key in toolpath object name to be deleted:"      
filter   get_event

   on EX_DATA
      state .
   on EX_STRING
      do del_tp_obj
         on INVALID_ACTION
            do status "Object name not found"
            state construct_tp_obj
         on SUCCESS
            state construct_tp_obj
      state .
   on EX_BACK_UP
      state .


state    select_options
message  "Create NC toolpath objects"
status   "1)tool 2)orient 3)3axis 4)arc 5)holder 6)END 7)5axis"
prompt   "Select option:"      
filter   get_event

  on EX_DATA
     state .
  on EX_STRING
     do get_options
        on C_TOOL      
           state set_tool
        on C_TOOL_ORIENTATION   
           state set_tool_orientation
        on C_3AXIS_SUB_TOOLPATH   
           state set_tax_sub_toolpath
        on C_ARC_SUB_TOOLPATH
           state set_arc_sub_toolpath
        on C_5AXIS_SUB_TOOLPATH   
           state set_fax_sub_toolpath
        on C_END_TOOLPATH
           do assign_command
           state terminate
        on ELSE
           do status "Invalid option, try again"
              state .
     state .
  on EX_BACK_UP
     state .


state            set_tool
status           "Set tool"
prompt           "Select tool"
locate_eligible  "+GRcurve"
locate_rtree     "+GRcurve"
accept_prompt    "Accept / Reject the located tool"
relocate         "Tool not located, try again"
filter           locate

   on EX_DATA
      do erase_hilight
      do classify_curve
         on IT_IS_CURVE
            do process_curve
            do disconnect_located erase
            state tool_translucency
      state .
   on EX_RJT_MOVEON
      state select_options
   on EX_BACK_UP
      state .

state            set_toolholder
status           "Set toolholder"
prompt           "Select toolholder"
locate_eligible  "+GRcurve"
locate_rtree     "+GRcurve"
accept_prompt    "Accept / Reject the located toolholder"
relocate         "Toolholder not located, try again"
filter           locate

   on EX_DATA
      do erase_hilight
      do classify_curve
         on IT_IS_CURVE
            do process_curve
            do assign_command
            do disconnect_located erase
            do chain_locate
            state select_options
      state .
   on EX_RJT_MOVEON
      state select_options
   on EX_BACK_UP
      state .

   
state            set_tool_orientation
status           "Set tool orientation"
prompt           "Select orientation"
locate_eligible  "+GRcurve"
locate_rtree     "+GRcurve"
accept_prompt    "Accept / Reject the located tool orientation"
relocate         "Tool orientation not located, try again"
filter           locate

   on EX_DATA   do erase_hilight
      do classify_curve
         on IT_IS_CURVE
            do process_curve
            do disconnect_located erase
            do chain_locate
            do assign_command
            state select_options
      state .
   on EX_RJT_MOVEON
      state select_options
   on EX_BACK_UP
      state .


state            set_tax_sub_toolpath
status           "Set three-axis sub-toolpath"
prompt           "Select sub-toolpath"
locate_eligible  "+GRcurve"
locate_rtree     "+GRcurve"
accept_prompt    "Accept / Reject the located sub-toolpath"
relocate         "Sub-toolpath not located, try again"
filter           locate

   on EX_DATA
      do erase_hilight
      do classify_curve
         on IT_IS_CURVE
            do process_curve
            do disconnect_located erase
            do chain_locate
            state toolpath_color
      state .
   on EX_RJT_MOVEON
      state select_options
   on EX_BACK_UP
      state .


state   set_arc_sub_toolpath
status      "Set arc sub-toolpath"
prompt      "Select arc sub-toolpath"
locate_eligible   "+GRcurve"
locate_rtree   "+GRcurve"
accept_prompt   "Accept / Reject the located arc sub-toolpath"
relocate   "Arc sub-toolpath not located, try again"
filter      locate

   on EX_DATA
      do erase_hilight
      do classify_curve
         on IT_IS_CURVE
            do process_curve
            do disconnect_located erase
            do chain_locate
            state toolpath_color
      state .
   on EX_RJT_MOVEON
      state select_options
   on EX_BACK_UP
      state .


state            set_fax_sub_toolpath
status           "Set five-axis sub-toolpath"
prompt           "Select sub-toolpath (linestring)"
locate_eligible  "+GRcurve"
locate_rtree     "+GRcurve"
accept_prompt    "Accept / Reject the located sub-toolpath"
relocate         "Sub-toolpath (linestring) not located, try again"
filter           locate

   on EX_DATA
      do erase_hilight
      do classify_curve
         on IT_IS_CURVE
            do process_curve
            on IT_IS_LINESTRING
               do disconnect_located erase
               do chain_locate
               state set_sub_toolpath_orientations
            state .
      state .
   on EX_RJT_MOVEON
      state select_options
   on EX_BACK_UP
      state .


state            set_sub_toolpath_orientations
status           "Set toolpath orientations"
prompt           "Select local orientation"
locate_eligible  "+GRcurve"
locate_rtree     "+GRcurve"
accept_prompt    "Accept / Reject the located toolpath orientation"
relocate         "Select orientation"
filter           locate

   on EX_DATA
      do erase_hilight
      do classify_curve
         on IT_IS_CURVE
            do process_toolpath_orientation
               on HAVE_ALL_ORIENTS
                  do disconnect_located erase
                  do chain_locate
                  state toolpath_color
            state .
      state .
   on EX_RJT_MOVEON
      state select_options
   on EX_BACK_UP
      state .


state    toolpath_color
message  "Define toolpath color"
status   "(1)use tool color  (2)toolpath color  (3)user define"
prompt   "Enter toolpath color:"
filter   get_event

   on EX_DATA
      state .
   on EX_STRING
      do get_color_options
         on C_TOOL_COLOR
            state toolpath_translucency
         on C_TP_COLOR   
            state toolpath_translucency
         on C_USER_COLOR   
            state input_tp_color
         on ELSE
            do status "Invalid option, try again"
            state .
      state .
   on EX_BACK_UP
      state .


state    toolpath_translucency
message  "Define toolpath translucency"
status   "-1 means use tool translucency"
prompt   "Enter toolpath translucency:"
filter   get_event

   on EX_DATA
      state .
   on EX_STRING
      do get_trans_options
      state toolpath_speed
   on EX_BACK_UP
      state .


state    tool_translucency
message  "Define tool translucency"
prompt   "Enter tool translucency:"
filter   get_event

   on EX_DATA
      state .
   on EX_STRING 
      do get_tool_trans
      do assign_command
      state select_options
   on EX_BACK_UP
      state .


state    input_tp_color
message  "Define toolpath color"
prompt   "Key in color index:"   
filter   get_event

   on EX_DATA
      state .
   on EX_STRING
      do get_color_index
      state toolpath_translucency
   on EX_BACK_UP
      state .


state    toolpath_speed
message    "Define toolpath speed"
status      "(1) use global speed  (2) user define"
prompt      "Enter toolpath speed:"
filter      get_event

   on EX_DATA
      state .
   on EX_STRING
      do get_speed_options
         on C_GLOBAL_SPEED
            do assign_command
            state select_options
         on C_USER_SPEED
            state input_tp_speed
         on ELSE
            do status "Invalid option, try again"
            state .
      state .
   on EX_BACK_UP
      state .


state    input_tp_speed
message  "Define toolpath speed"
prompt   "Key in speed [1 - 16]:"   
filter   get_event

   on EX_DATA
      state .
   on EX_STRING
      do get_speed
      do assign_command
      state select_options
   on EX_BACK_UP
      state .




/*--- create_tp_obj -----------------------------------------*/
action create_tp_obj

{
   IGRlong   sts1;

   sts1 = om$construct( msg        = message HSNCtoolpth.my_construct(),
                        classname  = "HSNCtoolpth",
                        osnum      = me->ModuleInfo.md_id.osnum,
                        p_objid    = &me->tp_id);

   OM_ERRCHK( sts1, "NCcretp.I: om$construct failed.");

#if DEBUG
   fprintf(stderr,
           "create_tp_obj: me->tp_id=%d, me->ModuleInfo.md_id.osnum=%d\n", 
           me->tp_id, me->ModuleInfo.md_id.osnum);
#endif
   
   sts1 = di$add_name( objname = me->event1.event.keyin,
                       objid   = me->tp_id);

   if (sts1 != DIR_S_SUCCESS)
   {
      *sts = (sts1 == DIR_E_NAME_DUP) ? NC_DIR_E_NAME_DUP : INVALID_ACTION;

      DI_ERRCHK( sts1, "NCcretp.I: di$add_name failed.");
   }

   if (*sts == NC_DIR_E_NAME_DUP)   /* duplicated name   */
   {
      sts1 = om$send(   msg      = message NCcretp.print_tp_obj(sts),
                        targetid = my_id);
   }
}
/*--- del_tp_obj -----------------------------------------*/
action del_tp_obj

{
   IGRlong   sts1;

   sts1 = di$rm_name (regexp = me->event1.event.keyin);

   if (sts1 != DIR_S_SUCCESS)
   {
      *sts = INVALID_ACTION;
      DI_ERRCHK( sts1, "NCcretp.I: di$rm_name failed.");
   }

   sts1 = om$send (msg = message NCcretp.print_tp_obj(sts),targetid = my_id);
}

/*--- print_tp_obj -----------------------------------------*/
action print_tp_obj

{
   IGRlong    sts1;
   char       dirname[80]; 
   OM_S_OBJID diid; 
   OMuword    dios; 
   char       **lines; 
   int        count;
   int        i;

   sts1 = di$pwd(p_dirid = &diid, p_osnum=&dios, dirname=dirname);
   DI_ERRCHK( sts1, "pwd failed.");

   fprintf(stderr, "DIosnum=%d, DIdirid=%d, pwd=%s, NOD have:\n",
           dios, diid, dirname);

   sts1 = di$ls(lines = &lines, ptr = &count);
   DI_ERRCHK( sts1, "ls failed.");
   for (i=0;i<count;i++)
   {
      fprintf(stderr,"%s, ",lines[i]); free(lines[i]);
   }

   fprintf(stderr,"\n");free (lines);
}


/*--- get_options -----------------------------------------*/
action get_options
{
   sscanf(me->event1.event.keyin, "%d", sts);

   /* *sts = me->event1.event.value only can be used for EX_TEXT */
   *sts += 5000;

   me->command_id = *sts;
}

/*--- get_color_options -----------------------------------------*/
action get_color_options
{
   sscanf(me->event1.event.keyin, "%d", sts);

   if (*sts == 0)
   {
      *sts = 1;
   }

   me->tp_color_option = (*sts += 5000);
}

/*--- get_trans_options -----------------------------------------*/
action get_trans_options
{
   sscanf(me->event1.event.keyin, "%d", sts);
   me->tp_trans_option = *sts;
}

/*--- get_tool_trans -----------------------------------------*/
action get_tool_trans
{
   sscanf(me->event1.event.keyin, "%d", sts);
   me->trans_flag = *sts;
}

/*--- get_color_index  -----------------------------------------*/
action get_color_index
{
   sscanf(me->event1.event.keyin, "%d", &(me->color));
   me->tp_color_option = C_USER_COLOR;
}

/*--- get_speed_options -----------------------------------------*/
action get_speed_options
{
   sscanf(me->event1.event.keyin, "%d", sts);
   if (*sts == 0)
   {
      *sts = 1;
   }
   me->tp_speed_option = (*sts += 5000);
}

/*--- get_speed  -----------------------------------------*/
action get_speed
{
   sscanf(me->event1.event.keyin, "%d", &(me->speed));

   if (me->speed < HSNC_MIN_SIM_SPEED)
   {
      me->speed = HSNC_DEFAULT_SIM_SPEED;
   }

   if (me->speed > HSNC_MAX_SIM_SPEED)
   {
      me->speed = HSNC_MAX_SIM_SPEED;
   }

   me->tp_speed_option = C_USER_SPEED;
}

/*--- erase_hilight -----------------------------------------*/
action erase_hilight
{
   IGRlong   msg;

   dp$erase_hilite( msg = &msg );
}


/*--- chain_locate -----------------------------------------*/
action chain_locate
{
   IGRlong  size = sizeof( struct GRevent ) - sizeof( IGRlong ) * 2;
   IGRlong  msg;
   IGRlong  sts1;
   int      response = EX_DATA;

   sts1 = ex$putque( msg      = &msg,
                     byte     = &size,
                     response = &response,
                     buffer   = (IGRchar *)&ME.CEO_LOCATE->event1.event );
}


/*------------------------------------------------------------------*/
action  classify_curve 
{
   IGRlong         sts1;
   struct GRevent  event;
   OMuword         elem_classid;
   OMuword         GRcurve_classid;   



   sts1 = om$get_classid( classname = "GRcurve",
                          p_classid = &GRcurve_classid );
   OM_ERRCHK( sts1, "get_classid: Get element classid error" );

#if DEBUG
   fprintf(stderr,"GRcurve id = %d\n",    GRcurve_classid );
#endif

   event = me^^CEO_LOCATE.event1;
   me->curve_id = event.located_object[0].located_obj;
   sts1 = om$get_classid( osnum     = me->curve_id.osnum,
                          objid     = me->curve_id.objid, 
                          p_classid = &elem_classid );
   OM_ERRCHK( sts1, "Get tool classid error" );

#if DEBUG
   fprintf(   stderr,
         "classify_curve: id.osnum=%d, id.objid=%d, elem_classid = %d\n",
         me->curve_id.osnum,
         me->curve_id.objid,
         elem_classid );
#endif

   /* determine whether the object is really a curve */
   if (om$is_ancestry_valid(subclassid   = elem_classid,
                            superclassid = GRcurve_classid) != OM_I_INVANCESTRY)
   {
      *sts = IT_IS_CURVE;
   }
   else
   {
#if DEBUG
      fprintf(stderr, "Located object is not a curve\n");
#endif
      *sts = OM_I_INVANCESTRY;
   } 
}


/* --------------------------------------------------------------------- */
action process_curve 
{
   double   xform[16];
   IGRlong  sts1;
   IGRlong   msg;
   IGRlong  size;
   short    type = MAIDMX;
   IGRchar  *curve2;


   MAidmx (&msg, xform);   

   sts1 = om$send( msg      = message GRvg.GRgetsize( &msg,
                                                      &type,
                                                      xform,
                                                      &size ),
                   targetos = me->curve_id.osnum,
                   targetid = me->curve_id.objid);

   OM_ERRCHK( sts1, "process_curve: GRgetsize failed" ); 
   MSG_ERRCHK( msg, "process_curve: GRgetgeom failed" ); 

#if DEBUG
   fprintf(stderr, "process_curve: size=%d, type=%d\n", size, type);
#endif

   if (size < 0) 
   {
      fprintf(stderr, "process_curve: unable to getsize\n");
      return( OM_S_SUCCESS );
   }

   curve2 = (IGRchar *) om$calloc(num = 1, size = size);

   sts1 = om$send( msg      = message GRvg.GRgetgeom( &msg,
                                                      &type,
                                                      xform,
                                                      curve2),
                   targetos = me->curve_id.osnum,
                   targetid = me->curve_id.objid);

   OM_ERRCHK( sts1, "process_curve: GRgetgeom failed" ); 
   MSG_ERRCHK( msg, "process_curve: GRgetgeom failed" ); 

   me->curve = (struct IGRbsp_curve *) curve2;        

#if DEBUG
   fprintf(stderr,"process_curve:\n"); nc_debug_curve (me->curve, 0);
#endif

   if (me->curve->order == 2)
   {
      me->num_orients = 0;
      *sts = IT_IS_LINESTRING;
   }
   else
   {
      *sts = IT_IS_CURVE;
   }
}
/* --------------------------------------------------------------------- */
action process_toolpath_orientation 
{
   double               xform[16];
   IGRlong              sts1;
   IGRlong              msg;
   IGRlong              size;
   short                type = MAIDMX;
   struct IGRbsp_curve  *curve2;


   MAidmx (&msg, xform);   

   sts1 = om$send( msg     = message GRvg.GRgetsize( &msg,
                                                     &type,
                                                     xform,
                                                     &size ),
                  targetos = me->curve_id.osnum,
                  targetid = me->curve_id.objid);

   OM_ERRCHK( sts1, "process_toolpath_orientation: GRgetsize failed" ); 
   MSG_ERRCHK( msg, "process_toolpath_orientation: GRgetgeom failed" ); 

#if DEBUG
   fprintf(stderr, "process_toolpath_orientation: size=%d, type=%d\n",
           size, type);
#endif

   if (size < 0) 
   {
      fprintf(stderr, "process_toolpath_orientation: unable to getsize\n");
      return( OM_S_SUCCESS );
   }
   curve2 = (struct IGRbsp_curve *) om$calloc(num = 1, size = size);

   sts1 = om$send( msg      = message GRvg.GRgetgeom( &msg,
                                                      &type,
                                                      xform,
                                                      (IGRchar *)curve2),
                   targetos = me->curve_id.osnum,
                   targetid = me->curve_id.objid);
   OM_ERRCHK( sts1, "process_toolpath_orientation: GRgetgeom failed" ); 
   MSG_ERRCHK( msg, "process_toolpath_orientation: GRgetgeom failed" ); 

#if DEBUG
   fprintf(stderr,"process_toolpath_orientation:\n");
   nc_debug_curve (me->curve, 0);
#endif

   /* get the orientation vector */
   me->orient[(3 * me->num_orients)] = curve2->poles[3] - curve2->poles[0];
   me->orient[(3 * me->num_orients) + 1] = curve2->poles[4] - curve2->poles[1];
   me->orient[(3 * me->num_orients) + 2] = curve2->poles[5] - curve2->poles[2];

#if DEBUG
   fprintf(stderr, "ORIENT #%d, x=%f, y=%f, z=%f\n",
            me->num_orients,
            me->orient[(3 * me->num_orients)],
            me->orient[(3 * me->num_orients) + 1],
            me->orient[(3 * me->num_orients) + 2]);
#endif

   /* set the return code */
   if ((++me->num_orients) == me->curve->num_poles)
   {
      *sts = HAVE_ALL_ORIENTS;
   }
   else
   {
      *sts = NEED_MORE_ORIENTS;
   }
}


/* --------------------------------------------------------------------- */
action   assign_command
{
   int                 i;
   double              *val64;
   IGRlong             sts1;
   IGRlong             msg;
   IGRvector           axis;
   IGRvector           x;
   IGRvector           y;
   IGRvector           z;
   struct GRsymbology  element_symb;

   uint32             *val32;
   real32             *flt32;
   int16              *val16;
   uint8              *val8;


   val8 = (uint8 *)me->command;        
   *val8++ = (uint8)(me->command_id - 5001);   /* lower order, assign options */
   *val8++ = (uint8) NC_TOOLPATH_COMMAND;      /* higher order = 64           */
   me->num_quadwords = 1;                      /* 1 double                    */

   switch (me->command_id)
   {
      case C_TOOL:
      case C_TOOLHOLDER:

         val16 = (int16 *) val8;               /* translucency                */
         *val16 = me->trans_flag;

         val8 += 2;         
         flt32 = (real32 *)val8;
         *flt32++ = 180.0;                     /* testing data, should be     */
                                               /* concav_parm later           */

         val32 = (uint32 *)flt32;      

         sts1 = om$send( msg      = message GRvg.GRgetsymb( &msg,
                                                            &element_symb ),
                         targetos = me->curve_id.osnum,
                         targetid = me->curve_id.objid);
         OM_ERRCHK( sts1, "NCcretp.sl:  GRgetsymb send failed" );

#if DEBUG
         fprintf( stderr, "color, weight, and style=(%d,%d,%d,%d)\n",
                  element_symb.display_attr.color,   /* 0 = green */
                  element_symb.display_attr.weight,    
                  element_symb.display_attr.style);
#endif

         *val32++ = 0;                         /* was rgb_value */
         val16 = (int16 *)val32;
         *val16++ = element_symb.display_attr.color;
         val8  = (uint8 *)val16;
         *val8++  = element_symb.display_attr.weight;    
         *val8++  = element_symb.display_attr.style;
         me->num_quadwords += 1;

         /* read NURB into command display list            */
         val64 = (double *)val8;

         assign_bsp_curve(me->curve, val64, &me->num_quadwords);
         break;

      case C_TOOL_ORIENTATION:
         val8 += 6;                            /* dummy      */
         for (i=0;i<3;i++)
         {
            axis[i] = me->curve->poles[i+3] - me->curve->poles[i];
         }
         val64 = (double *) val8;
   
         /* generate temp. 3x3 rotation xform            */
   
#if DEBUG
         fprintf(stderr,"pole2=(%lf, %lf, %lf), pole1=(%lf,%lf,%lf)\n",
                 me->curve->poles[3], me->curve->poles[4], me->curve->poles[5],
                 me->curve->poles[0], me->curve->poles[1], me->curve->poles[2]);
         fprintf(stderr,"axis=(%lf, %lf, %lf)\n", axis[0], axis[1], axis[2]);
#endif

         CreateCoordSystem(axis, x, y, z);

#if DEBUG
         fprintf(stderr,"CreateCoordSystem:\n x=(%f, %f, %f)\n y=(%f, %f, %f)\n z=(%f, %f, %f)\n",
            x[0],x[1],x[2],y[0],y[1],y[2],z[0],z[1],z[2]);
#endif

         for (i=0; i<3; i++) 
         {   
            *val64++ = x[i];
            *val64++ = y[i];
            *val64++ = z[i];
         }
         me->num_quadwords += 9;
         break;

      case C_3AXIS_SUB_TOOLPATH:
      case C_ARC_SUB_TOOLPATH:
         val16 = (int16 *)val8;
         switch (me->tp_color_option)
         {
            case C_TOOL_COLOR : 
               *val16 = HSNC_USE_TOOL_COLOR;
               break;

            case C_TP_COLOR :
               sts1 = om$send( msg      = message GRvg.GRgetsymb(&msg,
                                                                 &element_symb),
                               targetos = me->curve_id.osnum,
                               targetid = me->curve_id.objid);
               OM_ERRCHK( sts1, "NCcretp.sl:  GRgetsymb send failed" );
#if DEBUG
               fprintf(   stderr,
                     "toolpath: color=%d\n",
                     element_symb.display_attr.color);
#endif

               *val16 = element_symb.display_attr.color;
               break;

            case C_USER_COLOR :
               *val16 = me->color;
               break;
         }

#if DEBUG
         fprintf(stderr, "tp color = %d\n", *val16);
#endif

         val16++;
         val32 = (uint32 *)val16;   
         *val32++ = 0;
         val16 = (int16 *)val32;               /* rgb                         */

         *val16 = (me->tp_speed_option == C_GLOBAL_SPEED) ?
                                        HSNC_USE_GLOBAL_SPEED : me->speed; 

#if DEBUG
         fprintf(stderr, "tp speed = %d\n", *val16);
#endif

         val16++;
         *val16 = me->tp_trans_option;        /* translucency                 */
         val8 = (uint8 *)val16;
         val8 += 6;                           /* place holder to guarantee    */
                                              /* alignment                    */
         val64 = (double *)val8;
         me->num_quadwords += 1;

         assign_bsp_curve(me->curve, val64, &me->num_quadwords);
         break;

      case C_5AXIS_SUB_TOOLPATH:
         val16 = (int16 *)val8;

         switch (me->tp_color_option)
         {
            case C_TOOL_COLOR : 
               *val16 = HSNC_USE_TOOL_COLOR;
               break;

            case C_TP_COLOR :
               sts1 = om$send(msg      = message GRvg.GRgetsymb(&msg,
                                                                &element_symb ),
                              targetos   = me->curve_id.osnum,
                              targetid   = me->curve_id.objid);
               OM_ERRCHK( sts1, "NCcretp.sl:  GRgetsymb send failed" );

#if DEBUG
               fprintf( stderr, "toolpath: color=%d\n",
                        element_symb.display_attr.color);
#endif

               *val16 = element_symb.display_attr.color;
               break;

            case C_USER_COLOR :
               *val16 = me->color;
               break;
         }
#if DEBUG
         fprintf(stderr, "tp color = %d\n", *val16);
#endif

         val16++;
         val32 = (uint32 *)val16;   
         *val32++ = 0;
         val16 = (int16 *)val32;              /* rgb                          */
         *val16 = (me->tp_speed_option == C_GLOBAL_SPEED) ?
                               HSNC_USE_GLOBAL_SPEED : me->speed; 

#if DEBUG
         fprintf(stderr, "tp speed = %d\n", *val16);
#endif

         val16++;
         *val16++ = me->tp_trans_option;     /* translucency                  */
         *val16++ = (int16)me->num_orients;
         val8 = (uint8 *)val16;
         val8 += 2;                          /* place holder to guarantee     */
                                             /* alignment                     */
         val64 = (double *)val8;
         me->num_quadwords += 1;

         /* assign the location/orientation points */
         for (i = 0; i < me->curve->num_poles; i++)
         {
            *val64++ = me->curve->poles[(3 * i) + 0];
            *val64++ = me->curve->poles[(3 * i) + 1];
            *val64++ = me->curve->poles[(3 * i) + 2];
            *val64++ = me->orient[(3 * i) + 0];
            *val64++ = me->orient[(3 * i) + 1];
            *val64++ = me->orient[(3 * i) + 2];

#if DEBUG
            fprintf(stderr,"IN NCCRETP: x=%f, y=%f, z=%f\n",
                    me->curve->poles[(3 * i) + 0],
                    me->curve->poles[(3 * i) + 1],
                    me->curve->poles[(3 * i) + 2]);

            fprintf(stderr,"IN NCCRETP: Nx=%f, Ny=%f, Nz=%f\n",
                    me->orient[(3 * i) + 0],
                    me->orient[(3 * i) + 1],
                    me->orient[(3 * i) + 2]);
#endif

            me->num_quadwords += 6;
         }
         break;

      case C_END_TOOLPATH:
         break;

      default:
         fprintf(stderr,"internal NCcretp.sl coding error\n");
         break;
   }   

#if DEBUG
   fprintf(stderr," before add_to_disp_list, me->command_id=%d\n",
           me->command_id);
   fprintf(stderr,"                 me(assign_command)->num_quadwords=%d\n",
           me->num_quadwords);
#endif

   sts1 = om$send( msg      = message HSNCtoolpth.add_to_disp_list(
                                                            me->command, 
                                                            &me->num_quadwords),
                   targetos = me->ModuleInfo.md_id.osnum,
                   targetid = me->tp_id);
   OM_ERRCHK( sts1, "NCcretp.I: om$send HSNCtoolpth.add_to_disp_list failed.");
}
