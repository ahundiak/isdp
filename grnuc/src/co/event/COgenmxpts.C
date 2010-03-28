/*
 Name

   CO_ni_matrix_of_pts_by_row_col_delta()

 Abstract

   Non-interactive function to generate  a rectangular matrix of data 
   point events.

 Arguments

   *sts
       return codes
          OM_S_SUCCESS
          OM_E_INVARG
          OM_E_NODYNMEM
          OM_E_NOSUCHOS

   events
       an array of events.  these are usually collected by
       a command object.

       on entry:

         events[0] - # rows
         events[1] - # columns
         events[2] - row delta
         events[3] - column delta
         events[4] - start pt of point matrix

 Status returns
       MSSUCC
       MSFAIL

 History
   srh 09/19/89 : created
   srh 10/31/89 : added forms/variable interface ( thanks RD for the 
                  vector arithmetic lesson )
   dhm 07/14/92 : ANSI conversion.

 Caveats
   points are generated ( come off the queue ) in column order

 */

/*   EH -  End of Header  */


#include    "coimport.h"
#include    "codebug.h"
#include    "OMminimum.h"
#include    "OMprimitives.h"
#include    "igetypedef.h"
#include    "igrtypedef.h"
#include    "godef.h"
#include    "gr.h"
#include    "igr.h"
#include    "igrdp.h"
#include    "msdef.h"
#include    "go.h"
#include    "exdef.h"
#include    "ex.h"
#include    "griodef.h"
#include    "grio.h"
#include    "dpdef.h"
#include    "dp.h"
#include    "grdpbdef.h"
#include    "grdpb.h"
#include    "griomacros.h"
#include    "grdpbmacros.h"
#include    "madef.h"
#include    "comiscmac.h"
#include    "exmacros.h"
#include    "dpmacros.h"
#include    "OMprimitives.h"
#include    "igrmacros.h"

#define  NBR_OF_ROWS        ( IGRlong ) events[0]->event.value
#define  ROW_DELTA                      events[1]->event.value
#define  NBR_OF_COLUMNS     ( IGRlong ) events[2]->event.value
#define  COLUMN_DELTA                   events[3]->event.value
#define  START_POINT                    events[4]->event.button
#define  VIEW_OBJID                     events[4]->event.button.objid
#define  VIEW_OSNUM                     events[4]->event.button.osnum

#define  DEFAULT_NBR_OF_ROWS          ( events[0]->subtype == GRst_DEFAULT )
#define  DEFAULT_NBR_OF_COLUMNS       ( events[2]->subtype == GRst_DEFAULT )

/* variable names for Generate Polar Array of Points commands */
#define ANGLE_OF_ROTATION_NAME     "_GR_ANGLE_OF_ROTATION"
#define GEN_START_PT_TOGGLE_NAME   "_GR_START_PT_TOGGLE"


#define  _X_         (0)
#define  _Y_         (1)
#define  _Z_         (2)

/*
 * ---------------------------------------------------------------------
 *                CO_ni_matrix_of_pts_by_row_col_delta
 * ---------------------------------------------------------------------
 */

IGRlong CO_ni_matrix_of_pts_by_row_col_delta( sts, events )

   IGRlong              *sts;
   struct GRevent       *events[];
{

/* BV - BEGINNING OF VARIABLE LIST */

   IGRboolean
      b_status,
      start_pt_flag = TRUE;


   IGRlong
      status = MSSUCC,
      ret_size,
      row,
      col,
      nbr_rows,
      nbr_cols,
      one = 1,
      which_error;

   IGRdouble
      angle_of_rotation;

   IGRvector
      X_vector,
      Y_vector,
      start_point;

   IGRmatrix
      world_to_view,
      rot_matrix;

   struct   EX_button
      seq_event;        /* software event queue info */

   struct GRIOvar_def
      var;

   struct var_list
      VariableList[2];

   extern IGRboolean
      MAscalvc(),
      MAptsxform(),
      MArotmx(),
      MAaddvc();

/* EV - END OF VARIABLE LIST */



   _m_debug_str( "> CO_ni_matrix_of_pts_by_row_col_delta" );

   nbr_cols = ( DEFAULT_NBR_OF_COLUMNS ) ? 1 : NBR_OF_COLUMNS;
   nbr_rows = ( DEFAULT_NBR_OF_ROWS    ) ? 1 : NBR_OF_ROWS;

   /* Range validation to prevent endless looping */
   if ( nbr_cols < 1 || nbr_rows < 1 )
   {
      status = *sts = MSINARG;
      goto quit;
   }

   /*
    * -----------------------------------------------------------------------
    *  Step 1: GET VARIABLES
    *
    *  Get form parameters from variable table - these will go into 
    *  the dpb when we are allowed add instance data to it
    * -----------------------------------------------------------------------
    */
   status = co$cvtvar( msg    =  sts,
                       alias  =  ANGLE_OF_ROTATION_NAME,
                       osnum  =  VIEW_OSNUM,
                       var    = &var );

   status = co$expreval( msg        =  sts,
                         expression =  var.contents.string,
                         unit_type  =  GRIO_ANGLE,
                         result     = &angle_of_rotation );

   status = co$cvtvar( msg    =  sts,
                       alias  =  GEN_START_PT_TOGGLE_NAME,
                       osnum  =  VIEW_OSNUM,
                       var    = &var );
   start_pt_flag = var.contents.ivalue;

   /*
    * -------------------------------------------------------------------------
    *  Step 2:  Get view's world-to-view matrix from which we will extract the
    *           X and Y unit vectors for the view.
    * -------------------------------------------------------------------------
    */
   VariableList[0].var            =  VIEW_ROTATION;
   VariableList[0].var_ptr        =  ( char * ) world_to_view;
   VariableList[0].num_bytes      =  sizeof( world_to_view );
   VariableList[0].bytes_returned = &ret_size;
   VariableList[1].var            =  END_PARAM;

   status = dp$inq_set_gragad( msg         = sts,
                               osnum        =  VIEW_OSNUM,
                               gragad_objid =  VIEW_OBJID,
                               which_error  = &which_error,
                               var_list     =  VariableList );
   _m_check2q ( status, *sts );

   /*
    * -------------------------------------------------------------------------
    *   Apply rotation to matrix before extracting its X and Y vectors
    * -------------------------------------------------------------------------
    */
   start_point[_X_] = START_POINT.x;
   start_point[_Y_] = START_POINT.y;
   start_point[_Z_] = START_POINT.z;

   if ( !MArotmx( sts,
                 &world_to_view[8],
                 &angle_of_rotation,
                  rot_matrix )
       ) goto quit;

   if ( !MAptsxform( sts,
                    &one, 
                     rot_matrix,
                    &world_to_view[0],   /* x vector */
                     X_vector )
       ) goto quit;

   if ( !MAptsxform( sts,
                    &one, 
                     rot_matrix,
                    &world_to_view[4],   /* x vector */
                     Y_vector )
       ) goto quit;

   /*
    * ----------------------------------------------------------------------
    *  Step 3:  Generate the VIEW coordiantes of each point in the matrix.
    *           Translate each back to WORLD coordinates and put the
    *           world coordiante points on the front of the software queue.
    *           Remember: events come off the queue in ther reverse order
    *           in which they entered.
    * ----------------------------------------------------------------------
    */
   for ( row = nbr_rows - 1; row >= 0 ; row-- )
   {
      IGRdouble row_scale;
      IGRvector 
	 X_scaled_vector,
         Y_scaled_vector,
         start_of_row;

      row_scale = ROW_DELTA * row;

      /* calculate vector to add to row start point */
      b_status = MAscalvc( sts, &row_scale, X_vector, X_scaled_vector );

      /* calculate the start point for this row */
      b_status = MAaddvc( sts, start_point, X_scaled_vector, start_of_row );

      for ( col = nbr_cols - 1; col >= 0 ; col-- )
      {

         IGRlong   size     = sizeof( struct EX_button );
         IGRint    response = EX_DATA;
         IGRvector gen_pt;
         IGRdouble col_scale;

         /* optionally generate start point */
         if ( !start_pt_flag && ( row == 0 ) && ( col == 0 ) ) break;

         col_scale = COLUMN_DELTA * col;

         /* calculate vector to add to row start point */
         b_status = MAscalvc( sts, &col_scale, Y_vector, Y_scaled_vector );

         /* calculate the start point for this row */
         b_status = MAaddvc( sts, start_of_row, Y_scaled_vector, gen_pt );

         status = co$build_button( msg    =  sts,
                                   x      =  gen_pt[_X_],
                                   y      =  gen_pt[_Y_],
                                   z      =  gen_pt[_Z_],
                                   osnum  =  VIEW_OSNUM,
                                   objid  =  VIEW_OBJID,
                                   button = &seq_event );
         _m_check2q( status, *sts );

         status = ex$putque ( msg      =  sts,
                              response = &response,
                              byte     = &size,
                              buffer   = (IGRchar *) &seq_event );
         _m_checkq( status );
      }
   }


quit:
   _m_debug_str( "> CO_ni_matrix_of_pts_by_row_col_delta" );

   return( status );
}

