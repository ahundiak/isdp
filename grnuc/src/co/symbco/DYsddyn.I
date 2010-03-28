/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   DYsddyn

Description
   This function initilazes the neccessary structures used to perform
   dynamic operations for the placement of symbols and cells.  This 
   function forms a shape that is the the size of the symbol definition
   extents.  The cursor is aligned with the origin symbol definition.
   This shape will track the cursor. 

   *msg              IGRlong                    completion message 
   scale[3]          IGRdouble                  active x, y, and z scale
   *angle            IGRdouble                  active angle in radians
   *act_symbol_def   struct GRact_symbol_def    The active symbol.

Return Values
   MSSUCC    - if successful
   MSFAIL    - if failure

History
   HGW  07/15/86 : Design date and Creation date.
   HGW  08/13/86 : Changed terminology.
   HGW  10/06/86 : Convert to 4.0
   HGW  11/06/87 : Changes for version 1.1
   SCW  07/07/92 : ANSI conversion
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "grsymdef.h"
#include "grsym.h"
#include "dpmacros.h"
#include "igrdef.h"
#include "dpstruct.h"

from GRgraphics   import   GRgetrang;

struct DYsddyn_info
{
   struct DPele_header dpele;
   struct IGRpolyline  sym_def_shape;
};

extern IGRboolean  MAidmx();
extern IGRboolean  GRsmplmat();
extern IGRboolean  MAcoptsxform();
extern void        DYdynflags();

#argsused
IGRint DYsdinit (msg, scale, angle, act_symbol_def)
IGRlong     *msg;
IGRdouble   scale[3];
IGRdouble   *angle;
struct GRactive_symbol_def  *act_symbol_def;

{

IGRboolean  status = FALSE;
IGRboolean  set_inq;
IGRboolean  dyn_on;
IGRshort    matrix_type;
IGRlong     om_msg;
IGRlong     ret_msg;
IGRint      five;
IGRboolean  world;
IGRpoint    origin;                    /* symbol origin point     */
IGRmatrix   rot_matrix;                /* view rotation matrix    */
IGRmatrix   place_matrix;              /* symbol placement matrix */
IGRdouble   pts[15];                    
IGRdouble   tpts[15];
IGRdouble   extents[6];
IGRboolean  save_all_windows;
IGRboolean  one_window;
struct      IGRpolyline    line;
struct      DYsddyn_info   info;
struct      IGRdisplay     dis_att;
IGRint      DYsddyn_fun();


   five = 5;
   world = FALSE;
   one_window = FALSE;

   /*
    *  Call function to see if dynamics is on.
    */

   set_inq = 1;
   DPdynflags(&ret_msg, &set_inq, &dyn_on, NULL);

   if (dyn_on)
   {
      om_msg = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRgetrang (&ret_msg, 
                                                    NULL, 
                                                    NULL,
                                                   &world, 
                                                    extents),
               senderid = NULL_OBJID, 
               targetid = act_symbol_def->objid,
               targetos = act_symbol_def->symbol_env.md_id.osnum);

      if (om_msg & ret_msg & 1)
      {
         /*
          *  The origin at which the shape is placed is changed as the
          *  cursor changes.  Therefore use an origin of 0,0,0 and allow
          *  the dyn_fun to add the origin to the shape.
          */
   
         origin[0] = 0;
         origin[1] = 0;
         origin[2] = 0;
   
         /*
          *  Since the symbol/symbol reference will appear the same 
          *  in any view an idenity matrix can be used for the view.
          */
   
         if (status = MAidmx (&ret_msg, rot_matrix))
         {
            /*
             *  Calculate a placement matrix.
             */
   
            if (status = GRsmplmat (&ret_msg, angle, scale, origin, 
                       rot_matrix, place_matrix))
            {
               /*
                *  Build a polyline to represent the extents of 
                *  the symbol definition. Must build a shape since 
                *  there is rotation in the matrix.
                */
   
               line.num_points = 5;
               line.points = pts;
               info.sym_def_shape.num_points = 5;
               info.sym_def_shape.points = tpts;
      
               pts[0] = extents[0];
               pts[3] = extents[0];
               pts[12] = extents[0];

               pts[1] = extents[1];
               pts[10] = extents[1];
               pts[13] = extents[1];

               pts[2] = extents[2];
               pts[5] = extents[2];
               pts[14] = extents[2]; 

               pts[6] = extents[3];
               pts[9] = extents[3];

               pts[4] = extents[4];
               pts[7] = extents[4];

               pts[8] = extents[5];
               pts[11] = extents[5];
   
   
               if (status = MAtypemx(&ret_msg, place_matrix, &matrix_type))
               {
                  /*
                   *  Transform the extents by the matrix.
                   */
      
                  if (status = MAoptsxform (&ret_msg, &five, &matrix_type,
                                            place_matrix, pts, tpts))
                  {
                     dis_att.color = 2;
                     dis_att.weight = 1;
                     dis_att.style = 0;

                     dp$build_dis_buffer(buffer = &info.dpele, 
                     type = IGRPY, display_att = &dis_att, 
                     geometry = &line);

                     /*
                      *  Inquire and save the global flag for all
                      *  windows.
                      */

                     set_inq = 1;   /* Inquire */
                     DPdynflags (&ret_msg, &set_inq, NULL, 
                        &save_all_windows);

                     set_inq = 0;   /* Set */
                     DPdynflags (&ret_msg, &set_inq, NULL, 
                        &one_window);

                     dp$dynamics (dyn_fun = DYsddyn_fun, 
                        information = &info);

                     /*
                      *  Restore the global flag for all windows.
                      */

                     set_inq = 0; /* Set */
                     DPdynflags (&ret_msg, &set_inq, NULL, 
                        &save_all_windows);

                  }
               }
            }
         }
      }else
      {
         status = 0;
      }
   }

   return(status);
}


/*\
Name
   DYsddyn_fun

Description   

   This is the dynamic function that tracks the cursor and displays
   the extents of the symbol/symbol reference.

   *info         struct DYsddyn_info structure formatted in init.

Notes
   See the notes on dynamics for a descripition of other args.

History
   HGW  07/15/86 : Design date and Creation date.
   HGW  08/13/86 : Changed terminology.
\*/

#argsused
IGRint DYsddyn_fun ( info, pnt2, mtx, objects, num_objects, buffers,
                     num_buffers, in_dummy1, in_dummy2, in_dummy3,
                     out_dummy1, out_dummy2, out_dummy3)

struct DYsddyn_info  *info;
struct EX_button     *pnt2;
struct GRid          **objects;
IGRdouble            *mtx;
IGRint               *num_objects;
struct DPele_header  **buffers;
IGRint               *num_buffers;
IGRchar              *in_dummy1;
IGRchar              *in_dummy2;
IGRchar              *in_dummy3;
IGRchar              **out_dummy1;
IGRchar              **out_dummy2;
IGRchar              **out_dummy3;

{
   /* 
    *  Initilaze the geometry struture to a polyline that forms
    *  a shape outlining the extents of the symbol definition.
    *  Because a symbol is view indepentent it is necessary
    *  to multiple the inverse of the view times the points.
    *  Since this is a rotation matrix the transpose can be
    *  used.  The multiplication is done in line for efficiency.
    *  This shape will use the dynamic point as the origin.
    */   

   info->dpele.geometry.polyline->points[0] =    
      (info->sym_def_shape.points[0] * mtx[0] + 
       info->sym_def_shape.points[1] * mtx[4] + 
       info->sym_def_shape.points[2] * mtx[8]) +
       pnt2->x;
   info->dpele.geometry.polyline->points[1] =    
      (info->sym_def_shape.points[0] * mtx[1] + 
       info->sym_def_shape.points[1] * mtx[5] + 
       info->sym_def_shape.points[2] * mtx[9]) + 
       pnt2->y;
   info->dpele.geometry.polyline->points[2] =    
      (info->sym_def_shape.points[0] * mtx[2] +
       info->sym_def_shape.points[1] * mtx[6] + 
       info->sym_def_shape.points[2] * mtx[10]) + 
       pnt2->z;

   info->dpele.geometry.polyline->points[3] =    
      (info->sym_def_shape.points[3] * mtx[0] +
       info->sym_def_shape.points[4] * mtx[4] + 
       info->sym_def_shape.points[5] * mtx[8]) + 
       pnt2->x;
   info->dpele.geometry.polyline->points[4] =    
      (info->sym_def_shape.points[3] * mtx[1] +
       info->sym_def_shape.points[4] * mtx[5] + 
       info->sym_def_shape.points[5] * mtx[9]) + 
       pnt2->y;
   info->dpele.geometry.polyline->points[5] =    
      (info->sym_def_shape.points[3] * mtx[2] +
       info->sym_def_shape.points[4] * mtx[6] + 
       info->sym_def_shape.points[5] * mtx[10]) + 
       pnt2->z;

   info->dpele.geometry.polyline->points[6] =    
      (info->sym_def_shape.points[6] * mtx[0] +
       info->sym_def_shape.points[7] * mtx[4] + 
       info->sym_def_shape.points[8] * mtx[8]) + 
       pnt2->x;
   info->dpele.geometry.polyline->points[7] =    
      (info->sym_def_shape.points[6] * mtx[1] +
       info->sym_def_shape.points[7] * mtx[5] + 
       info->sym_def_shape.points[8] * mtx[9]) + 
       pnt2->y;
   info->dpele.geometry.polyline->points[8] =    
      (info->sym_def_shape.points[6] * mtx[2] +
       info->sym_def_shape.points[7] * mtx[6] + 
       info->sym_def_shape.points[8] * mtx[10]) + 
       pnt2->z;

   info->dpele.geometry.polyline->points[9] =    
      (info->sym_def_shape.points[9] * mtx[0] +
       info->sym_def_shape.points[10] * mtx[4] +
       info->sym_def_shape.points[11] * mtx[8]) + 
       pnt2->x;
   info->dpele.geometry.polyline->points[10] =    
      (info->sym_def_shape.points[9] * mtx[1] +
       info->sym_def_shape.points[10] * mtx[5] + 
       info->sym_def_shape.points[11] * mtx[9]) + 
       pnt2->y;
   info->dpele.geometry.polyline->points[11] =    
      (info->sym_def_shape.points[9] * mtx[2] +
       info->sym_def_shape.points[10] * mtx[6] + 
       info->sym_def_shape.points[11] * mtx[10]) + 
       pnt2->z;

   info->dpele.geometry.polyline->points[12] =    
      info->dpele.geometry.polyline->points[0];
   info->dpele.geometry.polyline->points[13] =    
      info->dpele.geometry.polyline->points[1];
   info->dpele.geometry.polyline->points[14] =    
      info->dpele.geometry.polyline->points[2];

   *buffers = &info->dpele;
   *num_buffers = 1;

   return (TRUE);
}

end implementation Root;
