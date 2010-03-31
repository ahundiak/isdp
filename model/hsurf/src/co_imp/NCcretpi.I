class implementation NCcretp;



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



#define _construct_tp_obj 0
#define _dup_tp_obj 1
#define _select_options 2
#define _set_tool 3
#define _set_toolholder 4
#define _set_tool_orientation 5
#define _set_tax_sub_toolpath 6
#define _set_arc_sub_toolpath 7
#define _set_fax_sub_toolpath 8
#define _set_sub_toolpath_orientations 9
#define _toolpath_color 10
#define _toolpath_translucency 11
#define _tool_translucency 12
#define _input_tp_color 13
#define _toolpath_speed 14
#define _input_tp_speed 15

method create_tp_obj ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method del_tp_obj ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong   sts1;

   sts1 = di$rm_name (regexp = me->event1.event.keyin);

   if (sts1 != DIR_S_SUCCESS)
   {
      *sts = INVALID_ACTION;
      DI_ERRCHK( sts1, "NCcretp.I: di$rm_name failed.");
   }

   sts1 = om$send (msg = message NCcretp.print_tp_obj(sts),targetid = my_id);
quit:
  return OM_S_SUCCESS;
}

method print_tp_obj ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method get_options ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   sscanf(me->event1.event.keyin, "%d", sts);

   /* *sts = me->event1.event.value only can be used for EX_TEXT */
   *sts += 5000;

   me->command_id = *sts;
quit:
  return OM_S_SUCCESS;
}

method get_color_options ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   sscanf(me->event1.event.keyin, "%d", sts);

   if (*sts == 0)
   {
      *sts = 1;
   }

   me->tp_color_option = (*sts += 5000);
quit:
  return OM_S_SUCCESS;
}

method get_trans_options ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   sscanf(me->event1.event.keyin, "%d", sts);
   me->tp_trans_option = *sts;
quit:
  return OM_S_SUCCESS;
}

method get_tool_trans ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   sscanf(me->event1.event.keyin, "%d", sts);
   me->trans_flag = *sts;
quit:
  return OM_S_SUCCESS;
}

method get_color_index ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   sscanf(me->event1.event.keyin, "%d", &(me->color));
   me->tp_color_option = C_USER_COLOR;
quit:
  return OM_S_SUCCESS;
}

method get_speed_options ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   sscanf(me->event1.event.keyin, "%d", sts);
   if (*sts == 0)
   {
      *sts = 1;
   }
   me->tp_speed_option = (*sts += 5000);
quit:
  return OM_S_SUCCESS;
}

method get_speed ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method erase_hilight ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong   msg;

   dp$erase_hilite( msg = &msg );
quit:
  return OM_S_SUCCESS;
}

method chain_locate ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong  size = sizeof( struct GRevent ) - sizeof( IGRlong ) * 2;
   IGRlong  msg;
   IGRlong  sts1;
   int      response = EX_DATA;

   sts1 = ex$putque( msg      = &msg,
                     byte     = &size,
                     response = &response,
                     buffer   = (IGRchar *)&ME.CEO_LOCATE->event1.event );
quit:
  return OM_S_SUCCESS;
}

method classify_curve ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method process_curve ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method process_toolpath_orientation ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method assign_command ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

end implementation NCcretp;
