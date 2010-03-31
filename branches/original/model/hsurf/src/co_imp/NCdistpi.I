class implementation NCdistp;



#define IT_IS_COMPOSITE         5001
#define IT_IS_SURFACE           5002
#define IT_IS_COMPCURVE         5004
#define NOT_FOUND               5011
#define INVALID_OBJECT          6001
#define INVALID_TOOLPATH        6002
#define RE_START                6003

#define FRAMENAME               7000
#define BOUNDARY                7001
#define SAVEIT                  7002
#define WINDOW                  7003
#define WIN_NOT_FOUND           7004
#define VALIDATE_FRAMENAME      7005


#define DEBUG                   0
#define NC_DEBUG                0
#define COMP_DEBUG              0
#define CHECK_RETURN_CODES      1
#define ABS(x)                  ( ( x > 0.0 ) ? ( x ) : ( -x ) )
#define TOL                     1.e-5
#define REV_AXIS                100.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

#include "igrtypedef.h"

#include "madef.h"

#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"
#include "hsmachine.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "HStl_global.h"
#include "HStl_window.h"

#include "dp.h"
#include "dpmacros.h"
#include "dpdef.h"

#include "OMmacros.h"

#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "hnerr.h"

#ifndef X11
#include <tools.h>
#endif

#include "igewindef.h"
#include "igewinmacros.h"

#include "hsurf.h"
#include "hswinmacros.h"

#include "EMSommacros.h"

#include "bsconic.h"
#include "bserr.h"
#include "bsdefs.h"

#include "OMerrordef.h"
#include "igecolmacros.h"
#include "igecolor.h"
#include "griomacros.h"
#include "grio.h"
#include "HSpr_co_imp.h"
#include "wl.h"

/*---------------------------
 *  for functions
 *     HSinit_shading_window
 *     HSinitialize_buffers
 *     HSset_edge2_usage
 */
 

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "hslight.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_element.h"

#include "HSe2_mesher.h"
#include "HStl_window.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"
#include "dpdisplay.h"
/*--------------------------
 *  for functions
 *     HScapture_image
 *     HSfile_error
 *     HSpix_count
 *     build_phys_tbl
 */
 
%safe
#include "HSpr_co_func.h"
%endsafe

/*------------------------
 *  for functions
 *     HSclear_window
 *     HSassign_edgeII_vlt_to_window
 */
 
#include "HSpr_dpb_imp.h"

/*------------------------
 *  for function
 *     ShadedNC
 */
 
#include "hsdisplay.h"

/*------------------------
 *  for function
 *     HSsetup_nc_window
 */
#include "HSpr_driver.h"

%safe
#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#include "hnmilling.h"
#include "HSpr_ncv_fun.h"

#undef __

%endsafe


/*---------------------------*/

#ifdef X11
extern Colormap EXcolormap[];

#define INDEXED_COLOR_VLT   0
#define MIDDLE_BUTTON       1
#define SINGLE_CLICK        2
#define DOUBLE_CLICK        4

#endif


extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_GRcompcurve_class_id;

/*
 * Local functions.
 */

#include "bs.h"
#include "bsparameters.h"

#if NC_DEBUG
static FILE *outfile;      /* for debug_tp_obj         */

/*---deassign_bsp_curve------------------------------------------------------------*/

static void deassign_bsp_curve( IGRdouble  *command,
                                int        *num_quadwords )
/*
 * Abstract:    function use to debug bsp_curve in toolpath object
 *
 * History:   07/00/88   KMJ   Created
 *
 */

{
   WLuint16   *val16;
   WLuint16   *flags;
   WLuint16   *order;
   double     *val64;
   int        *val32;
   int        i;
   int        *numPoles;

   *num_quadwords = 1;

   order = val16 = (WLuint16 *) command;

   fprintf(outfile, "    NURB curve, order = %d, ", *val16++);

   flags = val16;
   if (*flags & CV_PERIODIC_M)
   {
      fprintf(outfile, "periodic, ");
   }

   if (*flags & CV_NON_UNIFORM_M)
   {
      fprintf(outfile, "non-uniform, ");
   }

   if (*flags & CV_RATIONAL_M)
   {
      fprintf(outfile, "rational, ");
   }

   if (*flags & CV_PLANAR_M)
   {
      fprintf(outfile, "planar, ");
   }

   if (*flags & CV_PHY_CLOSED_M)
   {
      fprintf(outfile, "physically closed, ");
   }

   val16++; numPoles = val32 = (int *)val16;
   fprintf(outfile, "      num_poles   = %d\n", *val32++);

   val64 = (double *) val32;
   fprintf(outfile, "        Poles (u, x, y, z):\n");

   for (i = 0; i < *numPoles; i++)
   {
      fprintf(outfile, "          %4d %20.12lf %20.12lf %20.12lf\n",
                       i, *val64, *(val64+1), *(val64+2));
      val64 += 3;
   }
   *num_quadwords += 3 * *numPoles;


   if (*flags & CV_NON_UNIFORM_M)
   {
      fprintf(outfile, "        Knots             :\n");
      for (i=0; i<*numPoles+*order; i++)
      {
         fprintf(outfile, "%18.16lf\n", *val64++);
      }
      *num_quadwords = *num_quadwords + *numPoles + *order;
   }

   if (*flags & CV_RATIONAL_M)
   {
      fprintf(outfile, "        Weights           :\n");

      for (i=0; i<*numPoles; i++)
      {
         fprintf(outfile, "%18.16f\n", *val64++);
      }
      *num_quadwords += *numPoles;
   }
}


/*---debug_tp_obj------------------------------------------------------------*/

static void debug_tp_object( double  *disp_list,
                             int     num_quads )
/* 
 * Abstract:    function use to debug toolpath object
 *
 * History:   07/00/88   KMJ   Created
 *
 */

{
   WLint16   *val16;   
   WLuint8   *val8;
   WLuint8   *lower;
   WLuint8   *higher;
   WLuint32  *val32;
   real32    *flt32;
   int       i;
   double    commands[10*HSNC_DISP_LIST_SIZE];
   double    *command;
   IGRint    *num_quadwords;


   for (i=0; i<num_quads; i++)
   {
      *(commands+i) = *(disp_list+i);
   }

   command = commands;


   if ( (outfile = (FILE *)fopen("disp_list.dat", "w")) == NULL)
   {
      printf("debug_tp_object: unable to open output file\n");
   }
   
   fprintf(outfile, "***** entering debug_tp_object\n");
   
   if (command == NULL) 
   {
      fprintf(outfile, "debug_tp_object: input command pointer to NULL\n");
      return;
   }

   while (1)
   {
      lower = (WLuint8 *)command;
      higher = lower + 1;   
      if (*higher == NC_TOOLPATH_COMMAND)
      {
         fprintf(outfile, "\nNC toolpath command: %d, %d\n", *higher, *lower);
         switch (*lower)
         {
            case NC_SET_TOOL:
            case NC_SET_TOOLHOLDER:
               val8 = lower + 4;
               if (*lower == NC_SET_TOOL)
               {
                  fprintf(outfile, "  set tool\n");
               }
               else
               {
                  fprintf(outfile, "  set toolholder\n");
               }

               flt32 = (real32 *)val8;
               fprintf(outfile, "    concav_parm: %f, ", *flt32++);

               val32 = (WLuint32 *)flt32;
               fprintf(outfile, "rgb_value: %d, ", *val32++); 

               val16 = (WLint16 *)val32;
               fprintf(outfile, "color: %d, ", *val16++);

               val8 = (WLuint8 *)val16;
               fprintf(outfile, "weight: %d, ", *val8++);
               fprintf(outfile, "style: %d\n", *val8++);
               
               /* NURB curve             */
               command = (double *)val8;
               deassign_bsp_curve(command, num_quadwords);
               command += *num_quadwords;
               break;

            case NC_SET_TOOL_ORIENTATION:
               command++;
               fprintf(outfile, "  set tool orientation\n");

               for (i = 0; i<3; i++)
               {
                  fprintf(outfile, "     %lf, %lf, %lf\n",
                  *command, *(command+1), *(command+2));
                  command += 3;
               }
               break;

            case NC_SET_3AX_SUB_TOOLPATH:
            case NC_SET_ARC_SUB_TOOLPATH:
               if (*lower == NC_SET_3AX_SUB_TOOLPATH)
               {
                  fprintf(outfile, "  set 3 axis sub_toolpath\n");
               }
               else
               {
                  fprintf(outfile, "  set arc sub_toolpath\n");
               }

               lower += 2;
               val16 = (WLint16 *)lower;
               fprintf(outfile, "    color =%d, ",*val16++);

               val32 = (WLuint32 *)val16;
               fprintf(outfile, "    rgb_value = %d, ",*val32++);

               val16 = (int16 *)val32;
               fprintf(outfile, "    speed =%d\n",*val16);

               command += 2;

               deassign_bsp_curve(command, num_quadwords);
               command += *num_quadwords;
               break;

            case NC_END_TOOLPATH:
               fprintf(outfile, "  end toolpath\n\n");
               break;

            default:
               fprintf(outfile, "  ****** unknown lower order %d ***** \n",
                  *lower);
               break;
         }
      }
      else
      {
         fprintf(outfile, "***** exit debug_tp_object\n");
         fclose(outfile);
         return;
      }
   }
}

/*-- nc_debug_surface --------------------------------------------------------*/

void nc_debug_surface( struct IGRbsp_surface *surf,
                       IGRboolean            flag )

/*
PARAMETERS

surf (IN) -  B-Spline surface to debug
flag (IN) -  if TRUE surface dumped in math format
*/

{
   IGRchar  name;
   IGRint   vi;
   IGRint   ui;
   IGRint   index;
   IGRint   num_bounds;

   if ( flag )
   {
      num_bounds = surf->num_boundaries;
      surf->num_boundaries = 0;
      BSprintbsps( stderr, &name, surf, FALSE );
      surf->num_boundaries = num_bounds;
   }
   else
   {
      fprintf ( stderr, "  u_order       = %d\n", surf->u_order);
      fprintf ( stderr, "  v_order       = %d\n", surf->v_order);
      fprintf ( stderr, "  u_num_poles   = %d\n", surf->u_num_poles);
      fprintf ( stderr, "  v_num_poles   = %d\n", surf->v_num_poles);
      fprintf ( stderr, "  u_num_knots   = %d\n", surf->u_num_knots);
      fprintf ( stderr, "  v_num_knots   = %d\n", surf->v_num_knots);
      fprintf ( stderr, "  rational      = %d\n", surf->rational);
      fprintf ( stderr, "  planar        = %d\n", surf->planar);
      fprintf ( stderr, "  u_phy_closed  = %d\n", surf->u_phy_closed);
      fprintf ( stderr, "  v_phy_closed  = %d\n", surf->v_phy_closed);
      fprintf ( stderr, "  u_periodic    = %d\n", surf->u_periodic);
      fprintf ( stderr, "  v_periodic    = %d\n", surf->v_periodic);
      fprintf ( stderr, "  u_non_uniform = %d\n", surf->u_non_uniform);
      fprintf ( stderr, "  v_non_uniform = %d\n", surf->v_non_uniform);

      if (surf->num_boundaries != 0)
      {
         fprintf ( stderr, "  num_bounds    = %d\n", surf->num_boundaries );
         fprintf ( stderr, "  on_off        = %d\n", surf->on_off );
      }
      fprintf ( stderr, "  \n" );
 
      if (surf->rational != 0)
      {
         fprintf ( stderr, "  Poles (v, u, x, y, z, w):\n");
         for (vi = 0; vi < surf->v_num_poles; vi++)
         {
            for (ui = 0; ui < surf->u_num_poles; ui++)
            {
               fprintf(stderr, "%4d %4d %20.12lf %20.12lf %20.12lf %20.12lf\n",
                            vi, ui,
                            surf->poles[((vi*surf->u_num_poles)+ui) * 3] /
                                       surf->weights[(vi*surf->u_num_poles)+ui],
                            surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 1] /
                                       surf->weights[(vi*surf->u_num_poles)+ui],
                            surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 2] /
                                       surf->weights[(vi*surf->u_num_poles)+ui],
                            surf->weights[(vi*surf->u_num_poles)+ui]);
            }
            fprintf ( stderr, "\n");
         }
      }
      else
      {
         fprintf ( stderr, "  Poles (v, u, x, y, z):\n");
         for (vi = 0; vi < surf->v_num_poles; vi++)
         {
            for (ui = 0; ui < surf->u_num_poles; ui++)
            {
               fprintf ( stderr, "%4d %4d %20.12lf %20.12lf %20.12lf\n",
                           vi, ui,
                           surf->poles[((vi*surf->u_num_poles)+ui) * 3],
                           surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 1],
                           surf->poles[((vi*surf->u_num_poles)+ui) * 3 + 2]);
            }
            fprintf ( stderr, "\n");
         }
      }

      fprintf ( stderr, "\n  U knots:\n");
      for (index = 0; index < surf->u_num_knots; index++)
      {
         fprintf ( stderr, "%18.16lf\n", surf->u_knots[index]);
      }

      fprintf ( stderr, "\n  V knots:\n");

      for (index = 0; index < surf->v_num_knots; index++)
      {
         fprintf ( stderr, "%18.16lf\n", surf->v_knots[index]);
      }
   }
}


/*-- nc_debug_curve --------------------------------------------------------*/

void nc_debug_curve( struct IGRbsp_curve  *curve,
                     IGRboolean           flag )

/*

PARAMETERS

   curve (IN) -  B-Spline curve to debug
   flag  (IN) -  if TRUE, curve dumped in math format
*/

{
   IGRchar  name;
   IGRint   ui;
   IGRint   index;

   if ( flag )
   {
      BSprintbspc( stderr, &name, curve, FALSE );
   }
   else
   {
      fprintf ( stderr, "  order       = %d\n", curve->order);
      fprintf ( stderr, "  num_poles   = %d\n", curve->num_poles);
      fprintf ( stderr, "  num_knots   = %d\n", curve->num_knots);
      fprintf ( stderr, "  rational    = %d\n", curve->rational);
      fprintf ( stderr, "  planar      = %d\n", curve->planar);
      fprintf ( stderr, "  phy_closed  = %d\n", curve->phy_closed);
      fprintf ( stderr, "  periodic    = %d\n", curve->periodic);
      fprintf ( stderr, "  non_uniform = %d\n", curve->non_uniform);
      fprintf ( stderr, "  num_bounds  = %d\n\n", curve->num_boundaries );

      if (curve->rational != 0)
      {
         fprintf ( stderr, "  Poles (u, x, y, z, w):\n");
         for (ui = 0; ui < curve->num_poles; ui++)
         {
            fprintf ( stderr, "%4d %20.12lf %20.12lf %20.12lf %20.12lf\n",
                      ui,
                      curve->poles[(ui) * 3] / curve->weights[ui],
                      curve->poles[(ui) * 3 + 1] / curve->weights[ui],
                      curve->poles[(ui) * 3 + 2] / curve->weights[ui],
                      curve->weights[ui]);
         }
      }
      else
      {
         fprintf ( stderr, "  Poles (u, x, y, z):\n");
         for (ui = 0; ui < curve->num_poles; ui++)
         {
            fprintf ( stderr, "%4d %20.12lf %20.12lf %20.12lf\n",
                      ui,
                      curve->poles[(ui) * 3],
                      curve->poles[(ui) * 3 + 1],
                      curve->poles[(ui) * 3 + 2]);
         }
      }

      fprintf ( stderr, "\n  knots:\n");
      for (index = 0; index < curve->num_knots; index++)
      {
         fprintf ( stderr, "%18.16lf\n", curve->knots[index]);
      }
   }
}
#endif

%safe

#if defined( X11 )
static Bool NC_predproc( Display *display,
                         XEvent  *event,
                         char    *arg)
{
   switch(event->type)
   {
      case KeyPress:

#if NC_DEBUG
         fprintf( stderr, "KeyPress\n" );
         return( 1 );
#endif

      case ButtonPress:

#if NC_DEBUG
         fprintf( stderr, "ButtonPress\n" );
         return( 1 );
#endif

      case Expose:

#if NC_DEBUG
         fprintf( stderr, "Expose\n" );
         return( 1 );
#endif
      case ResizeRequest:

#if NC_DEBUG
         fprintf( stderr, "ResizeRequest\n" );
         return( 1 );
#endif

      case CirculateNotify:

#if NC_DEBUG
         fprintf( stderr, "CirculateNotify\n" );
         return( 1 );
#endif

      case ConfigureNotify:

#if NC_DEBUG
         fprintf( stderr, "ConfigureNotify\n" );
         return( 1 );
#endif

      case DestroyNotify:

#if NC_DEBUG
         fprintf( stderr, "DestroyNotify\n" );
         return( 1 );
#endif

      case GravityNotify:

#if NC_DEBUG
         fprintf( stderr, "GravityNotify\n" );
         return( 1 );
#endif

      case MapNotify:

#if NC_DEBUG
         fprintf( stderr, "MapNotify\n" );
         return( 1 );
#endif

      case ReparentNotify:

#if NC_DEBUG
         fprintf( stderr, "ReparentNotify\n" );
         return( 1 );
#endif

      case UnmapNotify:

#if NC_DEBUG
         fprintf( stderr, "UnmapNotify\n" );
         return( 1 );
#else
         return( 1 );
#endif

      default:
         return(0);
   }
} /* NC_predproc */
#endif
%endsafe

static IGRdouble  old_rot_transpose[3][3];

from GRowner      import GRget_number_components, GRget_components;
from HSNCtoolpth  import read_disp_list, read_num_quadwords,get_object_env;
from IGEgragad    import DPupdate;


#define _specify_tp_object 0
#define _get_tp_osnum 1
#define _process_data 2
#define _process_toolpath 3

method init_env ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint    i;

   me->num_part_objenvs = 0;
   me->num_bg_objenvs = 0;   
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

method get_tp_id_from_name ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   IGRlong     sts1;

#if DEBUG
   char        dirname[80]; 
   OM_S_OBJID  diid; 
   OMuword     dios;
   char        **lines; 
   int         count;
   int         i;

   fprintf(stderr,"get_tp_objname: before di$translate\n");

   sts1 = di$pwd(p_dirid = &diid, p_osnum=&dios, dirname=dirname);
   DI_ERRCHK( sts1, "pwd failed.");

   fprintf(stderr,"DIosnum=%d, DIdirid=%d, pwd=%s, NOD have:\n", 
                   dios, diid, dirname);

   sts1 = di$ls(lines = &lines, ptr = &count);
   DI_ERRCHK( sts1, "ls failed.");

   for (i=0;i<count;i++)
   {
      fprintf(stderr,"%s, ",lines[i]); free(lines[i]);
   }

   fprintf(stderr,"\n");free (lines);
#endif

   
   /* get toolpath object id */
   sts1 = di$translate (objname = me->event1.event.keyin,
                        p_objid = &me->toolpath_objenv.obj_id.objid, 
                        p_osnum = &me->toolpath_objenv.obj_id.osnum);

   if (sts1 != DIR_S_SUCCESS)
   {
      if (sts1 == DIR_W_NAME_NOT_FOUND)
      {
         *sts = NOT_FOUND;
         sscanf( me->event1.event.keyin, "%d", &me->toolpath_objenv.obj_id.objid );
      }         
      else
      {
         *sts = INVALID_TOOLPATH;
      }  
       
#if DEBUG
      DI_ERRCHK( sts1, "NCdistp.I: di$translate failed.");
#endif

   }
   else
   {

#if DEBUG
      fprintf(stderr,"me->toolpath_objenv.obj_id.objid=%d, me->toolpath_objenv.obj_id.osnum=%d\n", 
                      me->toolpath_objenv.obj_id.objid, me->toolpath_objenv.obj_id.osnum);
#endif

   }
quit:
  return OM_S_SUCCESS;
}

method classify_toolpath ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   IGRlong   sts1;
   OMuword   active_classid;
   int       temp;


   sscanf( me->event1.event.keyin, "%d", &temp);

   me->toolpath_objenv.obj_id.osnum = temp;

#if DEBUG
   fprintf(stderr,"classify_toolpath:me->toolpath_objenv.obj_id.objid=%d, me->toolpath_objenv.obj_id.osnum=%d\n",
                   me->toolpath_objenv.obj_id.objid, me->toolpath_objenv.obj_id.osnum);
#endif

   *sts = om$get_classid(   osnum      = me->toolpath_objenv.obj_id.osnum,
                            objid      = me->toolpath_objenv.obj_id.objid,
                            p_classid  = &active_classid);

   if (*sts==OM_S_SUCCESS)
   {
      sts1 = om$is_ancestry_valid( subclassid     = active_classid,
                                   superclassname = "HSNCtoolpth");
      if (sts1 != OM_S_SUCCESS)
      {
         *sts = INVALID_TOOLPATH;

#if DEBUG
         OM_ERRCHK( sts1, "NCdistp.I: om$is_ancestry_valid failed.");
#endif

      }
   }
quit:
  return OM_S_SUCCESS;
}

method verify_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong          msg;
   IGRlong          which_error;
   IGRlong          ret_bytes;
   struct var_list  var_list1[5];

#if DEBUG
   fprintf(stderr, "verify_window: me->gragad_name=%s, me->gragad.objid=%d, ",
                    me->gragad_name, me->gragad.objid );
   fprintf(stderr, "me->gragad.osnum=%d\n", me->gragad.osnum);
#endif

   /* get the name, window number and gpipe id of the window */
   var_list1[0].var             = GRAGAD_NAME;
   var_list1[0].var_ptr         = me->gragad_name;
   var_list1[0].num_bytes       = sizeof( me->gragad_name );
   var_list1[0].bytes_returned  = &ret_bytes;
   var_list1[1].var             = WIN_NO;
   var_list1[1].var_ptr         = (IGRchar *)&(me->lwin_no);
   var_list1[1].num_bytes       = sizeof( IGRint );
   var_list1[1].bytes_returned  = &ret_bytes;
   var_list1[2].var             = GPIPE_ID;
   var_list1[2].var_ptr         = (IGRchar *) &(me->gpipe_id);
   var_list1[2].num_bytes       = sizeof( IGRint );
   var_list1[2].bytes_returned  = &ret_bytes;
   var_list1[3].var             = GRAGAD_INST_STRUCT;
   var_list1[3].var_ptr         = (IGRchar *) &me->gadget_stuff;
   var_list1[3].num_bytes       = sizeof( struct gragad_inst );
   var_list1[3].bytes_returned  = &ret_bytes;
   var_list1[4].var             = END_PARAM;

   *sts = dp$inq_set_gragad( msg          = &msg,
                             inq0_set1    = 0,
                             osnum        = me->gragad.osnum,
                             gragad_objid = me->gragad.objid,
                             which_error  = &which_error,
                             var_list     = var_list1 );

   if ( msg != MSSUCC )
   {
      ex$message( msgnumb = HS_E_InvWindow );
      sleep(3);
      ex$message( in_buff = "",
                  field   = ERROR_FIELD );
      *sts = NOT_FOUND;
   }
quit:
  return OM_S_SUCCESS;
}

method process_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong                         msg;
   IGRlong                         ret_bytes;
   IGRlong                         which_error;
   IGRlong                         sts1;
   IGRlong                         sts2;
   IGRint                          org_x;
   IGRint                          org_y;
   IGRint                          vs_no;
   IGRint                          x_dits;
   IGRint                          y_dits;
   IGRdouble                       range[6];
   IGRdouble                       post_rotation_dummy[4][4];
   struct var_list                 shading_inq_list[2];
   struct HStotal_window_instance  shading_inst;
   IGRuchar                        far_depth_cue;
   struct WLbounds                 area_bounds;

   WLuint16                        lscreen_no;
   int                             screen_type;
   WLuint32                        context_no;
   struct WLcontext_info           context_info;
   struct var_list                 var_list1[2];


   /* get window class */
   om$get_classname( classname = me->win_classname,
                     objid     = me->gragad.objid,
                     osnum     = me->gragad.osnum);

   WLget_active_screen( &lscreen_no, &screen_type );
   CMget_active_context( lscreen_no, &context_no );
   WLget_context_info( context_no, &context_info );

   /* erase the window */
   HSclear_window( me->lwin_no );

   me->was_shading = (strcmp( me->win_classname, "HSgragad" ) == 0);

   if(me->was_shading)
   {
      /* Convert window to wireframe.  This is needed to make NC shaded */
      /* verification work on TRUE color machines.                      */
      hs$convert_shading_window_to_wireframe(msg             = &msg,
                                             win_id          = me->gragad.objid,
                                             win_os          = me->gragad.osnum,
                                             display_message = FALSE,
                                             update          = FALSE );
   }

   if( context_info.base_cmap_type == WL_CMAP_TRUE_COLOR )
   {
      /* we are on a true_color machine */
      me->edgeII_mode = TRUE;
      HSconvert_to_indexed_context( me->lwin_no,
                                    me->gragad.objid,
                                    me->gragad.osnum);

      /* if on a true color machine, we need to make sure we have the  */
      /* proper window and context number                              */
      var_list1[0].var             = WIN_NO;
      var_list1[0].var_ptr         = (IGRchar *)&me->lwin_no;
      var_list1[0].num_bytes       = sizeof( IGRint );
      var_list1[0].bytes_returned  = &ret_bytes;
      var_list1[1].var             = END_PARAM;

      dp$inq_set_gragad( msg          = &msg,
                         inq0_set1    = 0,
                         osnum        = me->gragad.osnum,
                         gragad_objid = me->gragad.objid,
                         which_error  = &which_error,
                         var_list     = var_list1);

      WLget_window_base_context( me->lwin_no, &active_window->context_no);
      active_window->win_no = me->lwin_no;
   }
   else
   {
      me->edgeII_mode = FALSE;
   }

   /* Enable dexels so that the mode is set to NC dexel mode.  This is  */
   /* necessary for true color machines to keep the indexed context.    */
   HSenable_dexels(me->gpipe_id);

   /* change wireframe class to HSgragad */
   hs$convert_wireframe_window_to_shading(msg             = &msg,
                                          win_id          = me->gragad.objid,
                                          win_os          = me->gragad.osnum,
                                          display_message = FALSE,
                                          update          = FALSE );


   x_dits = (me->gadget_stuff.max_x_dep - me->gadget_stuff.min_x_dep) + 1;
   y_dits = (me->gadget_stuff.max_y_dep - me->gadget_stuff.min_y_dep) + 1;

   sts1 = HSinit_shading_window( lscreen_no, 
                                  me->lwin_no,
                                  me->gpipe_id,
                                  x_dits,
                                  y_dits,
                                  HS_STYLE_SMOOTH,
                                  me->gragad.objid,
                                  me->gragad.osnum);
   HSdisable_dexels();

   if ( sts1 )
   {
      /* erase the window */
      HSclear_window( me->lwin_no );

      active_window->type &= (short)(~HShardware_ZB_24);

      if( !me->was_shading )
      {
         shading_inq_list[0].var       = HS_TOTAL_INSTANCE;
         shading_inq_list[0].var_ptr   = (IGRchar *)&shading_inst;
         shading_inq_list[0].num_bytes = sizeof(struct HStotal_window_instance);
         shading_inq_list[0].bytes_returned = &ret_bytes;

         shading_inq_list[1].var = END_PARAM;

         HSget_default_instance( &msg, &which_error, shading_inq_list );
      }

      /* get the window region                      */
      WLget_window_bounds( me->lwin_no, NULL, &area_bounds );
      org_x = area_bounds.x;
      org_y = area_bounds.y;

      hs$get_depth_cues( far_depth_cue = &far_depth_cue );

      /* initialize the tiler structures for the window          */
      status = HSinit_display( me->lwin_no,
                               me->gadget_stuff.min_x_dep + org_x,
                               me->gadget_stuff.min_y_dep + org_y,
                               (me->gadget_stuff.max_x_dep -
                                           me->gadget_stuff.min_x_dep) + 1,
                               (me->gadget_stuff.max_y_dep - 
                                           me->gadget_stuff.min_y_dep) + 1,
                               &(me->gadget_stuff.gragad),
                               255,
                               far_depth_cue,
                               post_rotation_dummy );

      /* paint the background here */
      sts1 = om$send(
                  msg      = message NCdistp.process_background_objects(&sts2),
                  targetid = my_id);

      /* set the tiler into ShadedNC (dexel) mode */
      HSenable_dexels(me->gpipe_id);

      /* get the window's range box for use in setting the z range */
      HSget_top_range( range );

      /* setup the nc window information */
      HSsetup_nc_window( me->gpipe_id, range );
   }
   else
   {
      HSpix_count();
   }

   /* add "-NCVerify" to window name */
   sprintf( me->gragad_name, "%s%s", me->gragad_name, "-NCVerify" );

   /* set the name in the window strip */
   WLset_window_name( me->lwin_no, me->gragad_name ); 
quit:
  return OM_S_SUCCESS;
}

method restore_window ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong        msg;


   if( me->edgeII_mode )   /* now means true color mode */
   {
      HSrestore_window_context( me->lwin_no,
                                me->gragad.objid,
                                me->gragad.osnum );

      me->edgeII_mode = FALSE;

      active_window->type ^= HShardware_ZB_24;
   }

   /* remove "-NCverify" from name */
   me->gragad_name[strlen( me->gragad_name ) - 9] = '\0';

   if ( !me->was_shading )
   {
      /* change shade class to wireframe */
      hs$convert_shading_window_to_wireframe( msg = &msg,
                                              win_id = me->gragad.objid,
                                              win_os = me->gragad.osnum,
                                              display_message = FALSE,
                                              update = FALSE );
   }

   /* set the name in the window strip */
   WLset_window_name( me->lwin_no, me->gragad_name ); 

   /* get the tiler out of ShadedNC (dexel) mode */
   HSdisable_dexels();

   /* update the window */
   dp$gen_update( msg   = &msg,
                  osnum = me->gragad.osnum,
                  objid = me->gragad.objid );
quit:
  return OM_S_SUCCESS;
}

method classify_part ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong sts1;
   OMuword elem_classid;

   sts1 = om$get_classid( osnum     = me->part_objenv.obj_id.osnum,
                          objid     = me->part_objenv.obj_id.objid, 
                          p_classid = &elem_classid );

#if DEBUG
   fprintf( stderr,
            " classify_part: me->part_objenv.obj_id.osnum=%d, objid=%d, ", 
            me->part_objenv.obj_id.osnum, me->part_objenv.obj_id.objid );

   fprintf( stderr,
            "elem_classid = %d\n",
             elem_classid );

#endif

   if ( om$is_ancestry_valid( subclassid   = elem_classid,
                              superclassid = OPP_EMScomposite_class_id )
             != OM_I_INVANCESTRY )
   {
      /* EMScomposite is an ancestor, the object is a solid, composite */
      /* surface, or composite curvce    */
     
      if ( elem_classid == OPP_GRcompcurve_class_id )
      {

#if DEBUG
         fprintf( stderr, "  Located element is a composite curve\n" );
#endif

         ex$message( msgnumb = HS_E_NCVInvObj );
         sleep(3);
         ex$message( in_buff = "",
                     field   = ERROR_FIELD );
         *sts = IT_IS_COMPCURVE;
      }
      else
      {

#if DEBUG
         fprintf( stderr, "  Located element is a composite surface\n" );
#endif

         *sts = IT_IS_COMPOSITE;
      }
   }
   else if (om$is_ancestry_valid( subclassid   = elem_classid,
                                  superclassid = OPP_EMSsurface_class_id ) 
            != OM_I_INVANCESTRY )
   {

#if DEBUG
      fprintf( stderr, "  Located element is a EMSsurface\n" );
#endif

      *sts = IT_IS_SURFACE;
   }
   else
   {

#if DEBUG
      fprintf(stderr, " Located element is not a surface\n");
#endif

      ex$message( msgnumb = HS_E_NCVInvObj );

      sleep(3);

      ex$message( in_buff = "",
                  field   = ERROR_FIELD );

      *sts = OM_I_INVANCESTRY;
   } 
quit:
  return OM_S_SUCCESS;
}

method classify_bgobj ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong sts1;
   OMuword elem_classid;

   sts1 = om$get_classid(  osnum     = me->background_objenv.obj_id.osnum, 
                           objid     = me->background_objenv.obj_id.objid, 
                           p_classid = &elem_classid );

#if DEBUG
   fprintf(stderr, "classify_part: me->bg_object.obj_id.osnum=%d, ",
           me->background_objenv.obj_id.osnum );
   fprintf(stderr, "me->bg_object.obj_id.objid=%d,",
           me->background_objenv.obj_id.objid );
   fprintf(stderr, "elem_classid = %d\n", elem_classid );
#endif

   if ( om$is_ancestry_valid( subclassid = elem_classid,
                              superclassid = OPP_EMScomposite_class_id )
        != OM_I_INVANCESTRY )
   {
      /* EMScomposite is an ancestor the object is a solid, composite surface,*/
      /* or composite curve                                                   */
     
      if ( elem_classid == OPP_GRcompcurve_class_id )
      {

#if DEBUG
         fprintf(stderr, "  Located element is a composite curve\n" );
#endif

         ex$message( msgnumb = HS_E_NCVInvObj );
         sleep(3);
         ex$message( in_buff = "",
                     field = ERROR_FIELD );
         *sts = IT_IS_COMPCURVE;
      }
      else
      {

#if DEBUG
         fprintf( stderr, "  Located element is a composite surface\n" );
#endif

         *sts = IT_IS_COMPOSITE;
      }
   }

   else if (om$is_ancestry_valid( subclassid = elem_classid,
                                  superclassid = OPP_EMSsurface_class_id )
            != OM_I_INVANCESTRY )
   {

#if DEBUG
      fprintf( stderr, "  Located element is a EMSsurface\n" );
#endif

      *sts = IT_IS_SURFACE;
   }
   else
   {

#if DEBUG
      fprintf(stderr, " Located element is not a surface\n");
#endif

      ex$message( msgnumb = HS_E_NCVInvObj );
      sleep(3);
      ex$message( in_buff = "",
                  field = ERROR_FIELD );

      *sts = OM_I_INVANCESTRY;
   } 
quit:
  return OM_S_SUCCESS;
}

method get_components (struct GRid **comp_ids;
                        IGRint      *num_components)
{
  int		  status = OM_S_SUCCESS;


   IGRlong          msg;
   IGRlong          sts1;
   struct GRmd_env  mdenv;
   IGRlong          byte_rcvd;
   IGRlong          num_byte;
   IGRint           buf_size;


   /* get the number of components */
   *num_components = 0;
   sts1 = om$send(mode     = OM_e_wrt_object,
                  msg      = message GRowner.GRget_number_components(
                                                         &msg, num_components ),
                  senderid = NULL_OBJID,
                  targetid = me->part_objenv.obj_id.objid,
                  targetos = me->part_objenv.obj_id.osnum );

   OM_ERRCHK( sts1, "get_components: GRget_number_components send failed" );

#if COMP_DEBUG
   fprintf(stderr,"get_components: num_components = %d\n", *num_components);
#endif

   /* get dpb information */
   num_byte = sizeof( struct GRmd_env );

   sts1 = gr$get_module_env( msg    = &msg,
                             sizbuf = &num_byte, 
                             buffer = &mdenv,
                             nret   = &byte_rcvd);

   OM_ERRCHK( sts1, "get_components: gr$get_module_env failed" );

#if COMP_DEBUG
   fprintf(stderr,"get_components: mdenv->osnum=%d, objid=%d\n",
           mdenv.md_id.osnum, mdenv.md_id.objid);
#endif

   /* allocate array for component ids                   */
   buf_size = *num_components;

   *comp_ids = (struct GRid *)malloc((*num_components) * sizeof( struct GRid ));

#if COMP_DEBUG
   fprintf(stderr,"me->part_objenv.obj_id.osnum=%d, objid=%d\n", 
           me->part_objenv.obj_id.osnum, me->part_objenv.obj_id.objid);
#endif

   sts1 = om$send( mode     = OM_e_wrt_object,
                   msg      = message GRowner.GRget_components( &msg,
                                                                &mdenv,
                                                                *comp_ids,
                                                                buf_size,
                                                                num_components,
                                                                0,
                                                                99999 ),
                   senderid = NULL_OBJID,
                   targetid = me->part_objenv.obj_id.objid,
                   targetos = me->part_objenv.obj_id.osnum );

   OM_ERRCHK( sts1, "get_components: GRget_components send failed" );
quit:
  return OM_S_SUCCESS;
}

method get_bg_components ( struct GRid **comp_ids;
                            IGRint *num_components)
{
  int		  status = OM_S_SUCCESS;


   IGRlong          msg;
   IGRlong          sts1;
   struct GRmd_env  mdenv;
   IGRlong          byte_rcvd;
   IGRlong          num_byte;
   IGRint           buf_size;


   /* get the number of components */
   *num_components = 0;
   sts1 = om$send(mode     = OM_e_wrt_object,
                  msg      = message GRowner.GRget_number_components(
                                                               &msg,
                                                               num_components ),
                  senderid = NULL_OBJID,
                  targetid = me->background_objenv.obj_id.objid,
                  targetos = me->background_objenv.obj_id.osnum );

   OM_ERRCHK( sts1, "get_bg_components: GRget_number_components send failed" );

#if DEBUG
   fprintf(stderr,"get_bg_components: num_components = %d\n", *num_components);
#endif


   /* get dpb information */
   num_byte = sizeof( struct GRmd_env );

   sts1 = gr$get_module_env( msg    = &msg,
                             sizbuf = &num_byte, 
                             buffer = &mdenv,
                             nret   = &byte_rcvd);

   OM_ERRCHK( sts1, "get_components: gr$get_module_env failed" );

#if DEBUG
   fprintf(stderr,"get_components: mdenv->osnum=%d, objid=%d\n",
                   mdenv.md_id.osnum, mdenv.md_id.objid);
#endif

   /* allocate array for component ids                   */
   buf_size = *num_components;

   *comp_ids = (struct GRid *) malloc( (*num_components) * sizeof( struct GRid ) );

#if DEBUG
   fprintf(stderr,"me->background_objenv.obj_id.osnum=%d, objid=%d\n", 
                   me->background_objenv.obj_id.osnum, me->background_objenv.obj_id.objid);
#endif

   sts1 = om$send( mode     = OM_e_wrt_object,
                   msg      = message GRowner.GRget_components( &msg,
                                                                &mdenv,
                                                                *comp_ids,
                                                                buf_size,
                                                                num_components,
                                                                0,
                                                                99999 ),
                   senderid = NULL_OBJID,
                   targetid = me->background_objenv.obj_id.objid,
                   targetos = me->background_objenv.obj_id.osnum );

   OM_ERRCHK( sts1, "get_bg_components: GRget_components send failed" );
quit:
  return OM_S_SUCCESS;
}

method process_part ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   IGRlong      sts1;
   IGRlong      msg;
   struct GRid  *comp_ids;
   struct GRid  *ids_ptr;
   IGRint       num_components;
   IGRint       i;
   IGRint        j;
   IGRmatrix    *matrix_ptr;

   for (j = 0; j < me->num_part_objenvs; j++)
   {
      me->part_objenv.obj_id.objid = me->part_objenvs[j].obj_id.objid;
      me->part_objenv.obj_id.osnum = me->part_objenvs[j].obj_id.osnum;
      me->part_objenv.mod_env = me->part_objenvs[j].mod_env;

      /* get each face for current composite surface */
      comp_ids = NULL;
      sts1 = om$send( msg = message NCdistp.get_components( &comp_ids,
                                                            &num_components),
                      targetid = my_id);

      OM_ERRCHK( sts1, "process_part: get_components send failed" );

      ids_ptr = comp_ids;

#if COMP_DEBUG
      printf("me->gragad.osnum, objid=(%d,%d)\n",
              me->gragad.osnum, me->gragad.objid);

      fprintf( stderr,
               "before call dp$display, comp_ids->(objid, osnum)=(%d,%d),",
               comp_ids->objid, comp_ids->osnum );

      fprintf( stderr,
               " num_components=%d\n",
               num_components);
#endif

      /* send part to tiler in here, it caused me some problems to send all */
      /* oids into dp$display which enabled HSdisbyoid.I.  The problems is  */
      /* in matrices                                                        */
      for (i = 0; i < num_components; i++, comp_ids++)
      {
         matrix_ptr = &me->part_objenv.mod_env.md_env.matrix;
         dp$display( msg   = &msg,
                     osnum = me->gragad.osnum,
                     objid = me->gragad.objid,
                     mtx_type = &me->part_objenv.mod_env.md_env.matrix_type, 
                     matrix = (IGRmatrix **) &matrix_ptr,
                     oids  = comp_ids);
         MSG_ERRCHK( msg, "process_part: dp$display failed" );
      }

      if (ids_ptr)
      {
         free (ids_ptr);
      }
   }
quit:
  return OM_S_SUCCESS;
}

method process_background_objects ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   IGRlong      sts1;
   IGRlong      msg;
   struct GRid  *comp_ids;
   struct GRid  *ids_ptr;
   IGRint       num_components;
   IGRint       i;
   IGRint       j;
   IGRmatrix    *matrix_ptr;

   for (j = 0; j < me->num_bg_objenvs; j++)
   {
      me->background_objenv.obj_id.objid = me->background_objenvs[j].obj_id.objid;
      me->background_objenv.obj_id.osnum = me->background_objenvs[j].obj_id.osnum;
      me->background_objenv.mod_env = me->background_objenvs[j].mod_env;

      /* get each face for current composite surface */
      comp_ids = NULL;

      sts1 = om$send( msg = message NCdistp.get_bg_components (&comp_ids,
                                                               &num_components),
                      targetid = my_id);

      OM_ERRCHK( sts1, "process_part: get_bg_components send failed" );

      ids_ptr = comp_ids;


#if DEBUG
      printf("me->gragad.osnum, objid=(%d,%d)\n",me->gragad.osnum, me->gragad.objid);

      fprintf( stderr,
               "before call dp$display, comp_ids->(objid, osnum)=(%d,%d), ",
               comp_ids->objid, comp_ids->osnum );
      fprintf( stderr,
               "num_components=%d\n",
                num_components );
#endif

      /* send part to tiler in here, it caused me some problems to send all   */
      /* oids into dp$display which enabled HSdisbyoid.I.  The problems is in */
      /* matrices                                                             */

      for (i = 0; i < num_components; i++, comp_ids++)
      {
         matrix_ptr = &me->background_objenv.mod_env.md_env.matrix;
         dp$display(   msg    = &msg,
                       osnum  = me->gragad.osnum,
                       objid  = me->gragad.objid,
                       mtx_type = &me->background_objenv.mod_env.md_env.matrix_type, 
                       matrix = (IGRmatrix **) &matrix_ptr,
                       oids   = comp_ids);
         MSG_ERRCHK( msg, "process_background_object: dp$display failed" );
      }
      if (ids_ptr) free (ids_ptr);
   }
quit:
  return OM_S_SUCCESS;
}

method get_tp_commands ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   IGRlong   sts1;

   /* read disp_list size                        */
   sts1 = om$send (msg      = message HSNCtoolpth.read_num_quadwords(
                                                            &me->num_quadwords),
                   targetos = me->ModuleInfo.md_id.osnum, 
                   targetid = me->toolpath_objenv.obj_id.objid);

   if (me->num_quadwords > HSNC_DISP_LIST_SIZE)            
   {                        
      sts1 = om$vla_set_dimension (varray = me->disp_list,
                                   size   = me->num_quadwords);

      OM_ERRCHK( sts1, "NCdistpi.I: om$vla_set_dimension failed.");

#if DEBUG
      printf("call vla_set_dimension\n");
#endif

   }                        

   /* read disp_list                        */
   sts1 = om$send (msg      = message HSNCtoolpth.read_disp_list(me->disp_list),
                   targetos = me->ModuleInfo.md_id.osnum, 
                   targetid = me->toolpath_objenv.obj_id.objid);
quit:
  return OM_S_SUCCESS;
}

method display_tool (struct IGRbsp_curve  *new_tool;
                    IGRdouble            rot[3][3];
                    IGRpoint             loc)
{
  int		  status = OM_S_SUCCESS;

   IGRboolean                    rational = TRUE;
   IGRboolean                    full     = TRUE;
   IGRboolean                    new_orientation;
   IGRdouble                     ang1;
   IGRdouble                     ang2;
   IGRint                        num_poles = BSCIRCLE_NUM_POLES_MAX;
   IGRlong                       rc;
   IGRlong                       msg;
   IGRlong                       sts1;
   IGRpoint                      point2;
   IGRpoint                      point1;
   IGRshort                      order = BSCIRCLE_ORDER;
   IGRshort                      i;
   IGRshort                      num_boundaries = NULL;

   struct DPele_header           buffer;
   struct IGRdisplay             dis_att;
   union IGRele_attr             ele_att;

   static struct IGRbsp_curve    *tool;
   static struct IGRbsp_surface  *surf; 


   /* if new tool, update the tool and old rotation and free the old surface */
   if (new_tool)   
   {
      if (new_tool)
      {
         tool = new_tool;
      }

      if (surf)
      {
         (void)BSfreesf(&rc, surf);
      }

#if NC_DEBUG
      fprintf(stderr,"display_tool: new tool=%x\n", tool);
                      nc_debug_curve(tool,0);
#endif

      old_rot_transpose[0][0] = 1.0;
      old_rot_transpose[1][1] = 1.0;
      old_rot_transpose[2][2] = 1.0;

      old_rot_transpose[0][1] = 0.0;
      old_rot_transpose[0][2] = 0.0;
      old_rot_transpose[1][2] = 0.0;

      old_rot_transpose[1][0] = 0.0;
      old_rot_transpose[2][0] = 0.0;
      old_rot_transpose[2][1] = 0.0;
   }


   /* if new orientation, rotate the tool                  */
   if (new_orientation = ( ABS(old_rot_transpose[2][0] - rot[0][2]) > TOL || 
                           ABS(old_rot_transpose[2][1] - rot[1][2]) > TOL || 
                           ABS(old_rot_transpose[2][2] - rot[2][2]) > TOL ))
   {
      /* first, rotate back to original orientation */
      sts1 = om$send(msg      = message NCdistp.rotate_curve(old_rot_transpose,
                                                             tool),
                     targetid = my_id);

#if NC_DEBUG
      fprintf(stderr, "\nafter rotate_curve, tool is:\n");
      nc_debug_curve(tool, 0);
#endif

      /* now, rotate to new orientation */
      sts1 = om$send( msg      = message NCdistp.rotate_curve( rot, tool ),
                      targetid = my_id);
#if NC_DEBUG
      fprintf(stderr, "\nafter rotate_curve, tool is:\n");
      nc_debug_curve(tool, 0);
#endif

      /* save the transpose of the rotation matrix */
      old_rot_transpose[0][0] = rot[0][0];
      old_rot_transpose[0][1] = rot[1][0];
      old_rot_transpose[0][2] = rot[2][0];
      old_rot_transpose[1][0] = rot[0][1];
      old_rot_transpose[1][1] = rot[1][1];
      old_rot_transpose[1][2] = rot[2][1];
      old_rot_transpose[2][0] = rot[0][2];
      old_rot_transpose[2][1] = rot[1][2];
      old_rot_transpose[2][2] = rot[2][2];
   }
 
   /* if new tool or new orientation, generate a new surface of revolution */
   if (new_tool || new_orientation)
   {
      /* allocate tool surface                     */
      BSallocsf( tool->order,
                 order,
                 tool->num_poles,
                 num_poles,
                 rational,
                 num_boundaries,
                 &surf,
                 &rc);
 
      BS_ERRCHK(rc, "display_tool: BSallocsf failed\n");
      if (BSERROR(rc))
      {
         return( OM_S_SUCCESS );
      }

      /* form tool axis */
      point2[0] = point1[0] = tool->poles[0];   /* faster */
      point2[1] = point1[1] = tool->poles[1];
      point2[2] = point1[2] = tool->poles[2];

      point2[0] += (REV_AXIS * rot[0][2]);
      point2[1] += (REV_AXIS * rot[1][2]);
      point2[2] += (REV_AXIS * rot[2][2]);

#if NC_DEBUG
      fprintf( stderr,
               "revolution axis: point1=(%lf,%lf,%lf), point2=(%lf,%lf,%lf)\n",
               point1[0],point1[1],point1[2],point2[0],point2[1],point2[2]);
#endif

      /* generate surface of revolution */
      BSsf_rev( &rc, point1, point2, tool, &full, &ang1, &ang2, surf );
      BS_ERRCHK(rc, "display_tool: BSsf_rev failed\n");

      if (BSERROR(rc))
      {
         return( OM_S_SUCCESS );
      }

#if NC_DEBUG
      fprintf(stderr,"\ndisplay_tool: after BSsf_rev, surf is:\n");

      nc_debug_surface(surf, 0);
#endif
   }

   /* move tool to current location */
   sts1 = om$send (msg      = message NCdistp.move_tool(loc, rot, surf),
                   targetid = my_id);

#if NC_DEBUG
   fprintf(stderr,"\ndisplay_tool: after move_tool, surf is:\n");
   nc_debug_surface(surf, 0);
#endif
   
   /* rule line table */
   dis_att.color = dis_att.weight = dis_att.style = 0;

   ele_att.bsqsurf = NULL;
   ems$get_rule_lines(rc = &rc, surf = surf, rlt = &ele_att.bsqsurf);
   OM_ERRCHK( rc, "display_tool: ems$get_rule_lines failed" );

   /* reduce redundant rule lines */
   ele_att.bsqsurf->u_rules -= 1; ele_att.bsqsurf->v_rules -= 1;

   for ( i=0; i<ele_att.bsqsurf->u_rules; i++ )
   {
      *(ele_att.bsqsurf->u_rule_values + i) =
                                     *(ele_att.bsqsurf->u_rule_values + i + 1);
   }

   for ( i=0; i<ele_att.bsqsurf->v_rules; i++ )
   {
      *(ele_att.bsqsurf->v_rule_values + i) =
                                      *(ele_att.bsqsurf->v_rule_values + i + 1);
   }

#if NC_DEBUG
   fprintf(stderr,"RLT: u_rules=%d, v_rules=%d\n",
                   ele_att.bsqsurf->u_rules,ele_att.bsqsurf->v_rules);

   fprintf(stderr,
           "is_polydis=%d, is_surfdis=%d, is_slowdis=%d, type=%d, ",
           ele_att.bsqsurf->is_polydis,
           ele_att.bsqsurf->is_surfdis,
           ele_att.bsqsurf->type );

   fprintf(stderr,
           "rules_specified=%d\n",
           ele_att.bsqsurf->rules_specified);

   fprintf(stderr,"  U rules:\n" );

   for ( i = 0; i < ele_att.bsqsurf->u_rules; i++ )
   {
      fprintf(stderr,"    U[%d] = %lf\n",
                     i, ele_att.bsqsurf->u_rule_values[i] );
   }
   fprintf(stderr,"  V rules:\n" );

   for ( i = 0; i < ele_att.bsqsurf->v_rules; i++ )
   {
      fprintf(stderr,"    V[%d] = %lf\n",
                     i, ele_att.bsqsurf->v_rule_values[i] );
   }
#endif

   /* display tool */
   dp$build_dis_buffer( buffer        = &buffer, 
                        type          = IGRQS,
                        display_att   = &dis_att,
                        ele_spec_att  = ele_att.bsqsurf,
                        geometry      = surf);

   dp$display( msg     = &msg,
               osnum   = me->gragad.osnum,
               objid   = me->gragad.objid,
               mode    = GRhd,
               buffer  = &buffer);

   MSG_ERRCHK( msg, "display_tool: dp$display failed" );

   if (ele_att.bsqsurf)
   {
      free (ele_att.bsqsurf);
   }
quit:
  return OM_S_SUCCESS;
}

method execute_toolpath ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRlong                   sts1;
   IGRlong                   msg;
   IGRint                    return_flag;
   IGRint                    entry_point;
   IGRboolean                cont;
   IGRboolean                done;
   int                       area_no;
   int                       button;
   int                       transition;
   int                       x;
   int                       y;
   int                       kblen;
   struct HSNC_mode_parms    mode_parms;
   struct HSNC_return_parms  return_parms;
   int                       response;
   double                    dbl_response[128];
   char                      *response_data;

#ifdef X11
   struct timeval            timer;
   unsigned long             prev_time; 
   int                       event_found;
   XEvent                    xevent;
   Display                   *win_display;
   int                       screen_type;
   struct WLnative_info      native_info;
   WLuint32                  context_no;
   WLuint16                  lscreen_no;
#else
   int                       event_mask;
   int                       cef;
   int                       timetag;
   int                       curevents;
   char                      keybuf[10];
#endif


#if defined( X11 )
   /* If we are on a machine that runs X, we need to get the display from */
   /* the native_info structure                                           */

   WLget_active_screen( &lscreen_no, &screen_type );
   CMget_active_context( lscreen_no, &context_no );

   WLget_native_info( me->lwin_no, context_no, &native_info );
   win_display = native_info.display;

   while( XCheckIfEvent( win_display, &xevent, NC_predproc, NULL ) );

#elif defined( ENV5 )
   Inq_events( &event_mask );
   if( event_mask & REFRESH_EVENT )
   {
      Clear_refresh_data();
   }

#else
#error "no windowing system has been defined"
#endif

   response_data = (char *)dbl_response;

#if DEBUG
   fprintf(stderr,"me->num_quadwords=%d, me->toolpath_objenv.obj_id.objid=%d, me->toolpath_objenv.obj_id.osnum=%d\n",
                   me->num_quadwords, me->toolpath_objenv.obj_id.objid, me->toolpath_objenv.obj_id.osnum);
#endif

   /*
    * Read and set the mode values.
    */

   hsnc$get_verification_parameters(
                              display_mode      = &mode_parms.display_mode,
                              simulation_speed  = &mode_parms.simulation_speed,
                              shading_style     = &mode_parms.shading_style );

   mode_parms.single_step = TRUE;

   /*
    * Initialize the wireframe display parameters.
    */

   old_rot_transpose[0][0] = 1.0;
   old_rot_transpose[1][1] = 1.0;
   old_rot_transpose[2][2] = 1.0;

   old_rot_transpose[0][1] = 0.0;
   old_rot_transpose[0][2] = 0.0;
   old_rot_transpose[1][2] = 0.0;

   old_rot_transpose[1][0] = 0.0;
   old_rot_transpose[2][0] = 0.0;
   old_rot_transpose[2][1] = 0.0;

   /*
    * Initialize and execute the display list.
    */

   entry_point = SNC_INIT;
   done = FALSE;

   do
   {

#if NC_DEBUG
      fprintf( stderr, "Prior to switch statement\n" );
#endif

      switch (ShadedNC( entry_point,
                        mode_parms,
                        me->disp_list,
                        &return_parms))
      {
         case (SNC_OK) :
            if ( IGEstop() )
            {
               return_flag = ShadedNC( SNC_CHGMODE,
                                       mode_parms,
                                       NULL,
                                       &return_parms );
               IGEresetstop();
            }

#if NC_DEBUG
            fprintf( stderr, "After the switch statement (SNC_OK)\t");
            fprintf( stderr, "display_mode = %d\tHSNC_SIMULATION = %d\n",
                              mode_parms.display_mode, HSNC_SIMULATION );
#endif

            /* display tool wireframe mode                */
            if (mode_parms.display_mode == HSNC_SWVOL_TOOL)
            {
               sts1 = om$send( msg        = message NCdistp.display_tool(
                                                      return_parms.tool,
                                                      return_parms.rotation,
                                                      return_parms.location ),
                               targetid   = my_id );
            }

#if NC_DEBUG
            fprintf( stderr, "Before the ex$message (SNC_OK)\n" );
#endif

            cont = FALSE;

            do
            {
               if (mode_parms.display_mode == HSNC_SIMULATION)
               {
                  ex$message( msgnumb       = HS_I_NCVSimKeys,
                              justification = CENTER_JUS,
                              field         = KEYIN_FIELD );
               }
               else
               {
                  ex$message( msgnumb       = HS_I_NCVSwVolKeys,
                              justification = CENTER_JUS,
                              field         = KEYIN_FIELD );
               }

#if defined( X11 )
               XPeekIfEvent( win_display, &xevent, NC_predproc,NULL);
               switch( xevent.type )
               {
                  case KeyPress:
                  case Expose:
                  case ResizeRequest:
                  case CirculateNotify:
                  case ConfigureNotify:
                  case DestroyNotify:
                  case GravityNotify:
                  case MapNotify:
                  case ReparentNotify:
                  case UnmapNotify:
                     transition = DOUBLE_CLICK;
                     button = 2;
                  default:
                     HSXget_button_data( &area_no, &transition, &button,
                                         &x, &y );

#if NC_DEBUG
                     fprintf( stderr, "Returned from HSXget_button_data\n");
                     fprintf( stderr,
                              "transition = %d\tbutton = %d\tx = %d\ty = %d\n",
                              transition, button, x, y );
#endif

                     /* Now, see if an expose was generated */
                     if( XCheckIfEvent( win_display,
                                        &xevent,
                                        NC_predproc,
                                        NULL) )
                     {
                        switch( xevent.type )
                        {
                           case KeyPress:
                           case Expose:
                           case ResizeRequest:
                           case CirculateNotify:
                           case ConfigureNotify:
                           case DestroyNotify:
                           case GravityNotify:
                           case MapNotify:
                           case ReparentNotify:
                           case UnmapNotify:
                              transition = DOUBLE_CLICK;
                              button = 2;
                              break;
                           default:
                              break;
                        }
                     }

#if NC_DEBUG
                     fprintf( stderr,
                              "After Expose check after HSXget_button_data\n" );
                     fprintf( stderr, "transition = %d\tbutton = %d\n",
                                       transition, button );
#endif

                     break;
               }
#else
               Wait_for_events( BUTTON_EVENT, &cef );
               Get_button_data( &area_no,
                                &x,
                                &y,
                                &button,
                                &transition,
                                &timetag );
               Inq_events( &event_mask );
               if( event_mask & REFRESH_EVENT )
               {
                  transition = DOUBLE_CLICK;
                  button = 2;
               }
#endif

#if NC_DEBUG
               fprintf( stderr, "After Get_button_data\n" );
               fprintf(stderr, "button %d  transition %d\n", button,
                                transition);
#endif

               if (mode_parms.display_mode == HSNC_SWVOL_TOOL)
               {
                  dp$erase_hilite(   msg     = &sts1,
                                     osnum   = me->gragad.osnum,
                                     objid   = me->gragad.objid);
               }

#if NC_DEBUG
               fprintf( stderr, "Before DOUBLE_CLICK test\n" );
#endif

               if (transition == DOUBLE_CLICK)
               {

#if NC_DEBUG
                  fprintf( stderr, "DOUBLE_CLICK\n" );
#endif

                  switch (button)
                  {
                     case(0):   /* Restore */

#if NC_DEBUG
                        fprintf( stderr, "LEFT_BUTTON\n" );
#endif

                        return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL,
                                                &return_parms);
                        *sts = RE_START;
                        done = TRUE;
                        cont = TRUE;
                        break;

                     case(1):   /* Continuous Mode */

#if NC_DEBUG
                        fprintf( stderr, "MIDDLE_BUTTON\n" );
#endif

                        mode_parms.single_step = FALSE;
                        return_flag = ShadedNC( SNC_CHGMODE, mode_parms, NULL,
                                                &return_parms);
                        cont = TRUE;
                        break;

                     case(2):   /* Exit                   */

#if NC_DEBUG
                       fprintf( stderr, "RIGHT_BUTTON\n" );
#endif

                        return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL,
                                                &return_parms);
                        done = TRUE;
                        cont = TRUE;
                        break;
                  }
               }
               else
               {

#if NC_DEBUG
                  fprintf( stderr, "SINGLE_CLICK\n" );
#endif

                  switch (button)
                  {
                     case(0):
                        /* If SIMULATION, Change Speed.  Otherwise Restore.*/

#if NC_DEBUG
                        fprintf( stderr, "LEFT_BUTTON\n" );
#endif

                        if (mode_parms.display_mode == HSNC_SIMULATION)
                        {
                           do
                           {
                              ex$message( in_buff = "", field = KEYIN_FIELD );

                              co$getevent(msg           = &msg,
                                          event_mask    = GRm_STRING |
                                                          GRm_BACK_UP,
                                          msgnum        = HS_P_NCVSetSimSpd,
                                          response      = &response,
                                          response_data = response_data,
                                          event         = &me->event1 );
                              kblen = strlen( me->event1.event.keyin );

                              /* update the speed */
                              sscanf( me->event1.event.keyin, "%d",
                                      &mode_parms.simulation_speed );
                              if (kblen == 0)
                              {
                                 mode_parms.simulation_speed =
                                                        HSNC_DEFAULT_SIM_SPEED;
                              }
                           }
                           while( 
                           (mode_parms.simulation_speed < HSNC_MIN_SIM_SPEED) ||
                           (mode_parms.simulation_speed > HSNC_MAX_SIM_SPEED));

                            ex$message( in_buff = "", field = PROMPT_FIELD );

                            return_flag = ShadedNC( SNC_CHGMODES, mode_parms,
                                                    NULL, &return_parms);
                            cont = TRUE;
                        }
                        else
                        {
                           return_flag = ShadedNC( SNC_CLEANUP, mode_parms,
                                                   NULL, &return_parms);
                           *sts = RE_START;
                           done = TRUE;
                           cont = TRUE;
                        }

                        break;

                     case(1):
                        /* single step */

#if NC_DEBUG
                        fprintf( stderr, "MIDDLE_BUTTON\n" );
#endif

                        mode_parms.single_step = TRUE;
                        cont = TRUE;
                        break;

                     case(2):   /* snap shot, save image. */

#if NC_DEBUG
                        fprintf( stderr, "RIGHT_BUTTON\n" );
#endif

                         me->state = FRAMENAME;
                         sts1 = om$send (msg = message NCdistp.execute_snap(
                                                                        sts ),
                                         targetid = my_id);
                        break;
                  }
               }

#if NC_DEBUG
               fprintf( stderr,
                        "button = %d\ttransition = %d\tDOUBLE_CLICK = %d\n",
                         button, transition, DOUBLE_CLICK );
#endif

               ex$message( in_buff = "", field = KEYIN_FIELD );
            }
            while (!cont);
            break;

         case (SNC_FINISHED) :

            /* display tool wireframe mode */
            if ((mode_parms.display_mode == HSNC_SWVOL_TOOL) &&
                             (!mode_parms.single_step))
            {
               sts1 = om$send( msg      = message NCdistp.display_tool(
                                                        return_parms.tool,
                                                        return_parms.rotation,
                                                        return_parms.location ),
                               targetid = my_id );
 
               OM_ERRCHK( sts1, "execute_toolpath: display_tool send failed" );
            }

            ex$message( msgnumb = HS_I_NCVFinished );
#ifdef X11
            XMaskEvent( win_display, ButtonPressMask, &xevent);
            button = xevent.xbutton.button - 1; 
#else
            Wait_for_events( BUTTON_EVENT, &cef );
            Get_button_data( &area_no, &x, &y, &button, &transition, &timetag );
#endif
            if( button == MIDDLE_BUTTON )
            {
               me->state = FRAMENAME;
               sts1 = om$send (msg = message NCdistp.execute_snap( sts ),
               targetid = my_id);
            }
            else
            {
               ex$message( in_buff = "",
                           field   = KEYIN_FIELD );
            }

            return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL,
                                    &return_parms );
            done = TRUE;
            break;

         case (SNC_ERROR) :
            ex$message( msgnumb = HS_I_NCVExecErr );

#ifdef X11
            XMaskEvent( win_display, KeyPressMask, &xevent);
#else
            Set_keyboard_buffer(keybuf, sizeof(keybuf));
            Enable_events(KEYBOARD_EVENT);
            Wait_for_events (KEYBOARD_EVENT, &curevents);
#endif
            ex$message( in_buff = "",
                        field   = KEYIN_FIELD );
            return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL, 
                                    &return_parms);
            done = TRUE;
            break;

         case (SNC_DLERR) :
            ex$message( msgnumb = HS_I_NCVDispListErr );
#ifdef X11
            XMaskEvent( win_display, KeyPressMask, &xevent);
#else
            Set_keyboard_buffer(keybuf, sizeof(keybuf));
            Enable_events(KEYBOARD_EVENT);
            Wait_for_events (KEYBOARD_EVENT, &curevents);
#endif
            ex$message( in_buff = "",
                        field   = KEYIN_FIELD );
            return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL,
                                    &return_parms);
            done = TRUE;
            break;

         case (SNC_BIGENV) :
            ex$message( msgnumb = HS_I_NCVBigEnv );
#ifdef X11
            XMaskEvent( win_display, KeyPressMask, &xevent );
#else
            Set_keyboard_buffer(keybuf, sizeof(keybuf));
            Enable_events(KEYBOARD_EVENT);
            Wait_for_events (KEYBOARD_EVENT, &curevents);
#endif
            ex$message( in_buff = "",
                        field   = KEYIN_FIELD );
            return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL,
                                    &return_parms);
            done = TRUE;
            break;

         case (SNC_BIGTOOL) :
            ex$message( msgnumb = HS_I_NCVBigTool );
#ifdef X11
            XMaskEvent( win_display, KeyPressMask, &xevent);   
#else
            Set_keyboard_buffer(keybuf, sizeof(keybuf));
            Enable_events(KEYBOARD_EVENT);
            Wait_for_events (KEYBOARD_EVENT, &curevents);
#endif
            ex$message( in_buff = "",
                        field   = KEYIN_FIELD );
            return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL,
                                    &return_parms);
            done = TRUE;
            break;

         case (SNC_NOMEM) :
            ex$message( msgnumb = HS_I_NCVOutOfMem );
#ifdef X11
            XMaskEvent( win_display, KeyPressMask, &xevent);
#else
            Set_keyboard_buffer(keybuf, sizeof(keybuf));
            Enable_events(KEYBOARD_EVENT);
            Wait_for_events (KEYBOARD_EVENT, &curevents);
#endif
            ex$message( in_buff = "",
                        field   = KEYIN_FIELD );
            return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL, 
                                    &return_parms);
            done = TRUE;
            break;

         default:
            ex$message( msgnumb = HS_I_NCVUnknErr );
#ifdef X11
            XMaskEvent( win_display, KeyPressMask, &xevent);
#else
            Set_keyboard_buffer(keybuf, sizeof(keybuf));
            Enable_events(KEYBOARD_EVENT);
            Wait_for_events (KEYBOARD_EVENT, &curevents);
#endif
            ex$message( in_buff = "",
                        field   = KEYIN_FIELD );
            return_flag = ShadedNC( SNC_CLEANUP, mode_parms, NULL,
                                    &return_parms);
            done = TRUE;
            break;
      }  /* end switch( ShadedNC...  */

      entry_point = SNC_EXECUTE;
   }
   while (!done);

   if (mode_parms.display_mode == HSNC_SWVOL_TOOL)
   {
      dp$erase_hilite( msg   = &sts1,
                       osnum = me->gragad.osnum,
                       objid = me->gragad.objid);

   }

quit:
  return OM_S_SUCCESS;
}

method move_tool ( IGRpoint               new_loc;
                  IGRdouble              rot[3][3];
                  struct IGRbsp_surface  *surf)
{
  int		  status = OM_S_SUCCESS;


   IGRint    i3;
   IGRint    i;
   IGRint    num_poles;
   IGRpoint  base;

#if DEBUG
   fprintf(stderr,"move_tool: new_loc=(%lf,%lf,%lf)\n",
                   new_loc[0],new_loc[1],new_loc[2]);
#endif

   num_poles = surf->u_num_poles * surf->v_num_poles; 
   base[0] = surf->poles[0];
   base[1] = surf->poles[1];
   base[2] = surf->poles[2];


   /* straight forward algorithm for fast display */

   if (surf->rational)
   {
      for (i=0; i<num_poles; i++)
      {
         i3 = i * 3;
         surf->poles[i3  ] -= ((base[0] - new_loc[0]) * surf->weights[i]);
         surf->poles[i3+1] -= ((base[1] - new_loc[1]) * surf->weights[i]);
         surf->poles[i3+2] -= ((base[2] - new_loc[2]) * surf->weights[i]);
      }
   }
   else
   {
      for (i=0; i<num_poles; i++)
      {
         i3 = i * 3;
         surf->poles[i3  ] -=  (base[0] - new_loc[0]);
         surf->poles[i3+1] -=  (base[1] - new_loc[1]);
         surf->poles[i3+2] -=  (base[2] - new_loc[2]);
      }
   }
quit:
  return OM_S_SUCCESS;
}

method rotate_curve (IGRdouble            rot[3][3];
                    struct IGRbsp_curve  *curve)
{
  int		  status = OM_S_SUCCESS;

   IGRint    i3;
   IGRint    i;
   IGRpoint  temp;
   IGRpoint  base;

   base[0] = curve->poles[0];
   base[1] = curve->poles[1];
   base[2] = curve->poles[2];


   /* straight forward to speed up display */
   if (curve->rational)
   {
      for (i=0; i<curve->num_poles; i++)
      {
         i3 = i * 3;
         curve->poles[i3  ] -= (curve->weights[i] * base[0]);
         curve->poles[i3+1] -= (curve->weights[i] * base[1]);
         curve->poles[i3+2] -= (curve->weights[i] * base[2]);
   
         temp[0] = curve->poles[i3  ] * rot[0][0] + 
                   curve->poles[i3+1] * rot[0][1] +
                   curve->poles[i3+2] * rot[0][2];
         temp[1] = curve->poles[i3  ] * rot[1][0] + 
                   curve->poles[i3+1] * rot[1][1] +
                   curve->poles[i3+2] * rot[1][2];
         temp[2] = curve->poles[i3  ] * rot[2][0] + 
                   curve->poles[i3+1] * rot[2][1] +
                   curve->poles[i3+2] * rot[2][2];

         curve->poles[i3  ] = temp[0];
         curve->poles[i3+1] = temp[1];
         curve->poles[i3+2] = temp[2];
      }
   }
   else
   {
      for (i=0; i<curve->num_poles; i++)
      {
         i3 = i * 3;
         curve->poles[i3  ] -= base[0];
         curve->poles[i3+1] -= base[1];
         curve->poles[i3+2] -= base[2];
   
         temp[0] = curve->poles[i3  ] * rot[0][0] + 
                   curve->poles[i3+1] * rot[0][1] +
                   curve->poles[i3+2] * rot[0][2];
         temp[1] = curve->poles[i3  ] * rot[1][0] + 
                   curve->poles[i3+1] * rot[1][1] +
                   curve->poles[i3+2] * rot[1][2];
         temp[2] = curve->poles[i3  ] * rot[2][0] + 
                   curve->poles[i3+1] * rot[2][1] +
                   curve->poles[i3+2] * rot[2][2];
   
         curve->poles[i3  ] = temp[0];
         curve->poles[i3+1] = temp[1];
         curve->poles[i3+2] = temp[2];
      }
   }
quit:
  return OM_S_SUCCESS;
}

method execute_snap ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   struct gragad_inst  gragad_info;
   struct var_list     var_list1[3];
   struct IGRdisplay   dis_att; 
   IGRlong             num_pts;
   IGRlong             which_error;
   IGRlong             msg;
   IGRint              message_no;
   IGRlong             ret_bytes;
   IGRint              len;
   IGRint              test;
   IGRint              xl;
   IGRint              yl;
   IGRint              xh;
   IGRint              yh;
   IGRint              xf1 = 0;
   IGRint              yf1 = 0;
   IGRshort            matrix_type;
   IGRchar             ch;
   IGRchar             not_exit;
   IGRdouble           temp;
   IGRdouble           rotation[4][4];
   IGRboolean          value; 
   struct GRevent      event;
   struct GRevent      *ev[2];
   FILE                *fp;
   IGRdouble           bound_pts[6];

   struct WLbounds     window_bounds;
   struct WLbounds     dummy_bounds;
   WLuint32            context_no;
   WLuint16            lscreen_no;
   int                 type_of_screen;

   int                 response = 0;
   double              dbl_response[128];
   char                *response_data;


   response_data = (char *)dbl_response;

   strcpy(response_data, "Save image\n");

   ex$message ( msgnumb = HSM_M_SaveImg );

   ex$message (in_buff = "", 
               field   = PROMPT_FIELD);

   ex$message (in_buff = "", 
               field   = ERROR_FIELD);

   ex$message(field         = KEYIN_FIELD,
              justification = CENTER_JUS,
              in_buff       = "");

   ev[0] = &me->event1;
   ev[1] = &event;

   bound_pts[0] = 1200.0;
   not_exit = TRUE;

   while (not_exit)
   {
      switch (me->state)
      {
         case FRAMENAME:  /* get name of file to save or recall */
            ex$message( msgnumb    = HSM_M_SaveImg );
                        message_no = HS_P_EntImgToSave;

            co$getevent( msg           = &msg,
                         event_mask    = GRm_STRING,
                         msgnum        = message_no,
                         response      = &response,
                         response_data = response_data,
                         event         = &me->event1 );

            switch (me->event1.response)
            {
               case EX_STRING:
                  if ( strlen( me->event1.event.keyin ) != 0)
                  {
                     strcpy(me->filename,me->event1.event.keyin);
                     test = strspn("*", me->filename);
                     len = strlen(me->filename);
                     if ( me->filename[len-1] == '~' | test != 0 )
                     {
                        HSfile_error(8);
                        me->state = FRAMENAME;
                     }
                     else
                     {
                        me->state = VALIDATE_FRAMENAME;
                     }
                  }
                  else
                  {
                     me->state = FRAMENAME;
                  }
                  break; /* end case STRING */

               case EX_BACK_UP:
                  break;

               default:
                  not_exit = FALSE;
                  break;
            } /* end switch (*response ) */

            break; /* end case FRAMENAME */

         case VALIDATE_FRAMENAME:
            if ( (fp = (FILE *)fopen( me->filename, "r" )) != NULL )
            {
            /* the file already exists => see if user wants to overwrite it */
               co$getevent( msg           = &msg,
                            event_mask    = GRm_STRING | GRm_BACK_UP,
                            msgnum        = HS_P_Overwrite,
                            response      = &response,
                            response_data = response_data,
                            event         = &me->event1 );

               switch ( me->event1.response )
               {
                  case EX_STRING :
                     if ( strlen( me->event1.event.keyin ) != 0 )
                     {
                        ch = me->event1.event.keyin[0];
                        ch = ch & 0xDF; /* Force input to upper case. */

                        switch (ch)
                        {
                           case 'Y':
                              me->state = BOUNDARY;
                              break;

                           case 'N':
                              me->state = FRAMENAME;
                              break;

                           default:
                              /* send input back to command server */
                              not_exit = FALSE;
                              break;
                        }
                     } /* end if strlen(-) != 0 */
                     else
                     {
                        /* user entered NULL string */
                        me->state = VALIDATE_FRAMENAME;
                     }
                     break; /* end case EX_STRING */

                  case EX_BACK_UP:
                     me->state = FRAMENAME;
                     break;
 
                  default:
                     not_exit = FALSE;
                     break;
               } /* end switch (*response) */
            }    /* end: file name already exists */
            else
            {
               /* filename doesn't already exist */
               me->state = BOUNDARY;
            }
            break;  /* VALIDATE_FRAMENAME case of state switch */

         case WINDOW:
            me->win_ids[0].objid = me->gragad.objid;
            me->win_ids[0].osnum = me->gragad.osnum;
            me->state = SAVEIT;
            break;  /* end: case WINDOW */

         case WIN_NOT_FOUND :
            ex$message ( msgnumb = HS_E_WinNotFound );
            sleep(3);
            ex$message (in_buff = "", 
                        field   = ERROR_FIELD);

            me->state = WINDOW;

            break; /* end case WIN_NOT_FOUND */

         case BOUNDARY:
            co$getevent( msg           = &msg,
                         event_mask    = GRm_STRING | GRm_BACK_UP,
                         msgnum        = (IGRint)HS_P_SaveWinOrFence,
                         response      = &response,
                         response_data = response_data,
                         event         = &me->event1 );

            switch( me->event1.response )
            {
               case EX_STRING:
                  if ( strlen(me->event1.event.keyin ) != 0 )
                  {
                     ch = me->event1.event.keyin[0];
                     if ( ch == 'w' )
                     {
                          me->state = WINDOW;
                     }
                     else
                     {
                        /* Find out data point positions */
                        co$getevent( msg           = &msg,
                                     event_mask    = GRm_DATA | GRm_BACK_UP,
                                     msgnum        = (IGRint)HS_P_EnterULLR,
                                     response      = &response,
                                     response_data = response_data,
                                     event         = &me->event1 );

                        switch (me->event1.response)
                        {
                           case EX_DATA:
                              dis_att.color = 2;
                              dis_att.weight = 0;
                              dis_att.style = 0;

                              me->win_ids[0].osnum =
                                                 me->event1.event.button.osnum;
                              me->win_ids[0].objid =
                                                 me->event1.event.button.objid;

                              bound_pts[0] = me->event1.event.button.x;
                              bound_pts[1] = me->event1.event.button.y;
                              bound_pts[2] = me->event1.event.button.z;

                              DYrbblock( ev, &dis_att);

                              co$getevent( msg           = &msg,
                                            event_mask    = GRm_DATA |
                                                            GRm_BACK_UP,
                                            msgnum        = 
                                                         (IGRint)HS_P_EnterULLR,
                                            response      = &response,
                                            response_data = response_data,
                                            event         = &me->event1 );

                              switch (me->event1.response)
                              {
                                 case EX_DATA:

                                     me->win_ids[1].osnum =
                                                 me->event1.event.button.osnum;
                                     me->win_ids[1].objid =
                                                 me->event1.event.button.objid;

                                     bound_pts[3] = me->event1.event.button.x;
                                     bound_pts[4] = me->event1.event.button.y;
                                     bound_pts[5] = me->event1.event.button.z;

                                     var_list1[0].var = WLD_TO_VIEWPORT;
                                     var_list1[0].var_ptr =
                                                          (IGRchar *) rotation;
                                     var_list1[0].num_bytes =
                                                        16 * sizeof(IGRdouble);
                                     var_list1[0].bytes_returned = &ret_bytes;

                                     var_list1[1].var = END_PARAM;

                                     status = dp$inq_set_gragad(
                                            msg          = &msg,
                                            inq0_set1    = 0,
                                            osnum        = me->win_ids[0].osnum,
                                            gragad_objid = me->win_ids[0].objid,
                                            which_error  = &which_error,
                                            var_list     = var_list1 );

                                    num_pts = 2;

                                    value = MAtypemx ( &msg,
                                                       rotation,
                                                       &matrix_type );

                                    value = MAoptsxform ( &msg,
                                                          &num_pts,
                                                          &matrix_type,
                                                          rotation,
                                                          bound_pts,
                                                          bound_pts );
                                    me->state = SAVEIT;
                                    break;

                                 default:
                                    not_exit = FALSE;
                                    break;
                              }   /* rubber banding event */
                              break;

                           case EX_BACK_UP:
                              me->state = BOUNDARY;
                              break;

                           default:
                              not_exit = FALSE;
                              break;
                        } /* end switch */

                        if ( me->state == SAVEIT)
                        {
                           if (me->win_ids[0].objid != me->win_ids[1].objid)
                           {
                               ex$message ( msgnumb = HS_E_SecPtInFirstWin);
                               sleep(3);
                               ex$message (in_buff = "", 
                                           field   = ERROR_FIELD);
                               me->state = BOUNDARY;
                           }
                        }
                     }/* fence */
                  } /* if strlen != 0 */
                  break;

               case EX_BACK_UP:
                  me->state = FRAMENAME;
                  break;

               default:
                  not_exit = FALSE;
                  break;
            } /* switch reponse */
            break;/* on BOUNDARY */

         case SAVEIT:
            var_list1[0].var = GRAGAD_INST_STRUCT;
            var_list1[0].var_ptr = (IGRchar *) &gragad_info;
            var_list1[0].num_bytes = sizeof(struct gragad_inst);
            var_list1[0].bytes_returned = &ret_bytes;
            var_list1[1].var = END_PARAM;

            status = dp$inq_set_gragad( msg          = &msg,
                                        inq0_set1    = 0,
                                        osnum        = me->win_ids[0].osnum,
                                        gragad_objid = me->win_ids[0].objid,
                                        which_error  = &which_error,
                                        var_list     = var_list1);

            WLget_window_bounds( gragad_info.win_no, &window_bounds,
                                 &dummy_bounds );

            xl = window_bounds.x;
            yl = window_bounds.y;
            xh = xl + window_bounds.width - 1;
            yh = yl + window_bounds.height - 1;

            if ( bound_pts[0] != 1200.0 )
            {
               if ( bound_pts[1] > bound_pts[4] )
               {
                  temp = bound_pts[4];
                  bound_pts[4] = bound_pts[1];
                  bound_pts[1] = temp;
               }

               if ( bound_pts[0] > bound_pts[3] )
               {
                  temp = bound_pts[3];
                  bound_pts[3] = bound_pts[0];
                  bound_pts[0] = temp;
               }

               xl = xf1 = bound_pts[0];
               yl = yf1 = bound_pts[1];

               xh = bound_pts[3]-bound_pts[0] + 1;
               yh = bound_pts[4]-bound_pts[1] + 1;
            }
            else
            {
               xf1 = 0;
               yf1 = 0;
               xh  = xh-xl +1;
               yh  = yh-yl+1;
               xl  = 0;
               yl  = 0;
            }

            ex$message ( msgnumb = HS_I_SavingImg );
            WLhide_cursor(gragad_info.win_no, 0);
            WLflush(gragad_info.win_no);

            if ( (yh % 8) != 0 )
            {
               yh = (yh/8) * 8;
            }

            if ( ((xh-1) % 8) != 0 )
            {
               xh = (((xh-1)/8) * 8) + 1;
            }

            /*
               get the windows context. It is necessary to get the window's
               context rather than the screen's context, because we may have
               indexed/8 bit windows on a machine that is true color.
               ( i.e raster hidden line, NC, and FEM all create/convert windows
               to 8-bit when on true color machines
            */
            WLget_window_base_context( gragad_info.win_no, &context_no);   

            status = HScapture_image( me->filename, xl, yl, xh, yh,
                                        gragad_info.win_no, context_no);

            WLshow_cursor(gragad_info.win_no);
            WLflush(gragad_info.win_no);

            if ( status != 0 )
            {
               HSfile_error(status);
            }
            else
            {
               ex$message( msgnumb = HS_I_ImgSaved );
               sleep(3);
               ex$message (in_buff = "", 
                           field   = ERROR_FIELD);
            }

            not_exit = FALSE;
            break;

      } /* end switch on state */
   } /* end while not exit */
quit:
  return OM_S_SUCCESS;
}

method get_object_env ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   /* caller must free the bg_obj_envs ptr when done!!! */
   /* set the object envirionment values */
   int i;
   struct GRobj_env *bg_obj_envs, *part_obj_envs;
   IGRlong sts;

   sts = om$send(msg = message HSNCtoolpth.get_object_env 
                                ( &me->num_bg_objenvs, 
                                  &bg_obj_envs,
                                  &me->num_part_objenvs, 
                                  &part_obj_envs,
                                  &me->gragad ),
                 targetos = me->ModuleInfo.md_id.osnum, 
                 targetid = me->toolpath_objenv.obj_id.objid);

   om$vla_set_dimension( varray = me->background_objenvs,
                         size = me->num_bg_objenvs);
   for (i = 0; i < me->num_bg_objenvs; i++)
   {
      me->background_objenvs[i] = bg_obj_envs[i];
   }
   if (bg_obj_envs)
   {
      free( bg_obj_envs );
   }

   om$vla_set_dimension( varray = me->part_objenvs,
                         size = me->num_part_objenvs);
   for (i = 0; i < me->num_part_objenvs; i++)
   {
      me->part_objenvs[i] = part_obj_envs[i];
   }
   if ( part_obj_envs )
   {
      free( part_obj_envs );
   }

   return( sts );
quit:
  return OM_S_SUCCESS;
}

method debug ()
{
  int		  status = OM_S_SUCCESS;

/*
instance
{
   WLhwin_no           hwin_no;
   WLuint32            lwin_no;
   IGRint              gpipe_id;
   IGRint              vlt_no;
   IGRboolean          edgeII_mode;
   IGRchar             win_classname[OM_K_MAXCLASS_LEN];
   IGRchar             gragad_name[32];
   IGRboolean          was_shading;
   struct gragad_inst  gadget_stuff;
   struct GRid         gragad;

   variable IGRdouble          disp_list[HSNC_DISP_LIST_SIZE]; 

   IGRint                      num_quadwords;
   IGRchar                     filename[132];
   struct GRid                 win_ids[40];
   IGRint                      num_part_objenvs;
   struct GRobj_env            part_objenv;
   variable struct GRobj_env   part_objenvs[0];
   IGRint                      num_bg_objenvs;
   struct GRobj_env            background_objenv;
   variable struct GRobj_env   background_objenvs[0];
   struct GRobj_env            toolpath_objenv;
}
*/
   int size;

   printf("NCdistp object: my_id = %d\n",my_id);
   printf("   hwin_no:                  %d\n",me->hwin_no);
   printf("   lwin_no:                  %d %#X\n",me->lwin_no,me->lwin_no);
   printf("   gpipe_id:                 %d \n",me->gpipe_id);
   printf("   vlt_no:                   %d \n",me->vlt_no);
   printf("   edgeII_mode:              %d \n",me->edgeII_mode);
   printf("   win_classname:            %s \n",me->win_classname);
   printf("   gragad_name:              %s \n",me->gragad_name);
   printf("   was_shading:              %d \n",me->was_shading);
   printf("   gragad                    osnum = %d objid = %d\n",
      me->gragad.osnum,me->gragad.objid);

   size = om$dimension_of( varray = me->disp_list );
   printf("   size disp_list:           %d\n",size);
   printf("   num_quadwords:            %d\n",me->num_quadwords);
   printf("   file name:                %s \n",me->filename);
   printf("   win_ids[0]                osnum = %d objid = %d\n",
      me->win_ids[0].osnum,me->win_ids[0].objid);
   size = om$dimension_of( varray = me->part_objenvs );
   printf("   size part_objenvs:  %d\n",size);
   printf("   num_part_objenvs:           %d\n",me->num_part_objenvs);
   printf("   part_objenv.obj_id  osnum = %d objid = %d\n",
      me->part_objenv.obj_id.osnum,me->part_objenv.obj_id.objid);
   printf("             .mod_env.md_id  osnum = %d objid = %d \n",
      me->part_objenv.mod_env.md_id.osnum,me->part_objenv.mod_env.md_id.objid);
   printf("             .mod_env.md_env matrix_type = %d matrix = %#X \n",
      me->part_objenv.mod_env.md_env.matrix_type,me->part_objenv.mod_env.md_env.matrix);
   size = om$dimension_of( varray = me->background_objenvs );
   printf("   size background_objenvs:  %d\n",size);
   printf("   num_bg_objenvs:           %d\n",me->num_bg_objenvs);
   printf("   background_objenv.obj_id  osnum = %d objid = %d\n",
      me->background_objenv.obj_id.osnum,me->background_objenv.obj_id.objid);
   printf("             .mod_env.md_id  osnum = %d objid = %d \n",
      me->background_objenv.mod_env.md_id.osnum,me->background_objenv.mod_env.md_id.objid);
   printf("             .mod_env.md_env matrix_type = %d matrix = %#X \n",
      me->background_objenv.mod_env.md_env.matrix_type,me->background_objenv.mod_env.md_env.matrix);
   printf("   toolpath_objenv.obj_id    osnum = %d objid = %d\n",
      me->toolpath_objenv.obj_id.osnum,me->toolpath_objenv.obj_id.objid);
   printf("             .mod_env.md_id  osnum = %d objid = %d \n",
      me->toolpath_objenv.mod_env.md_id.osnum,me->toolpath_objenv.mod_env.md_id.objid);
   printf("             .mod_env.md_env matrix_type = %d matrix = %#X \n",
      me->toolpath_objenv.mod_env.md_env.matrix_type,me->toolpath_objenv.mod_env.md_env.matrix);
   return(0);      
quit:
  return OM_S_SUCCESS;
}

end implementation NCdistp;
