/* $Id: VDBOMform.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDBOMform.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDBOMform.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1994/12/30  16:32:06  pinnacle
# Replaced:  vdbom/cmd/VDBOMform.I r#
#
# Revision 1.5  1994/12/28  22:20:18  pinnacle
# Replaced:  vdbom/cmd/VDBOMform.I tr# 179424265
#
# Revision 1.4  1994/12/13  20:26:00  pinnacle
# Replaced:  vdbom/cmd/VDBOM[af]*.I r#
#
# Revision 1.3  1994/12/12  20:47:42  pinnacle
# Replaced:  vdbom/cmd/*.[IS] r#
#
# Revision 1.2  1994/12/07  15:29:24  pinnacle
# Replaced:  vdbom/cmd r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      12/07/94        R. Manem        OPE enhancements :
 *                                      - new gadgets in BOM form
 *                                      - init_form method (new)
 *                                      - rg-collector enhancement
 *                                      - sorting of objects for assoc BOM case
 *
 *	12/12/94	R. Manem	- leader line handling
 *					- update_form : for Modify BOM command
 * 	12/13/94	R. Manem	- Include printf within DEBUG
 *	12/28/94	R. Manem	- TR179424265 : updated the 
 *					  default units on the form for
 *					  Modify BOM command.
 *	12/30/94	R. Manem	- Roll through field : if index > max
 *					  no of object, set it to max.
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdBOM;

#include "string.h"
#include "stdio.h"
#include "stdlib.h"

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "griodef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#include "ACrg_collect.h"
#include "ACattrib.h"

#include "AS_status.h"
#include "exproto.h"

#include "vdparmacros.h"
#include "VDCmdDef.h"
#include "VDbom.h"

#include "UOMdef.h"
#include "UOMmacros.h"

#include "coparamac.h"
#include "coparadef.h"

#include "VDSFilter.h"
#include "FI.h"
#include "FEI.h"

/*
#define DEBUG
*/

from ACrg_collect      import  ACset_list_attribute;
from ACrg_collect      import  AClist_attribute;

extern GRclassid OPP_ACrg_collect_class_id;

int VDfld_get_select_row( char      *form_ptr,
                          int       gadget_label,
                          int       col,
                          int       *row )
{
     int i, nrows, sel;

     FIfld_get_num_rows( form_ptr, gadget_label, &nrows );

     for( i = 0 ; i < nrows ; i++ )
     {
          FIfld_get_select( form_ptr, gadget_label, i, col, &sel );
          if( sel )
          {
               *row = i;
               return 1;
          }
     }
     return 0;
}

method init_form( long *sts )
{
     int       state;
     IGRlong   stat;
     IGRdouble def_len = 0,
               txtWidth = 1,
               txtHeight = 1;
     char      buffer[256];
     char      *form_ptr = NULL;
     struct    GRdpb_text_symb textSymb;

     form_ptr = me->forms[0].form_ptr;
     FIf_reset( form_ptr );

     /* set %ITEM in column description field */

     FIfld_set_num_rows( form_ptr, VD_COL_DESC_FLD, 1 );
     FIfld_set_text( form_ptr, VD_COL_DESC_FLD, 0, 0, "%ITEM", TRUE );
     FIfld_set_text( form_ptr, VD_COL_DESC_FLD, 0, 2, "ITEM", FALSE );
     FIfld_set_text( form_ptr, VD_COL_DESC_FLD, 0, 3, "5", FALSE );
     FIfld_set_text( form_ptr, VD_COL_DESC_FLD, 0, 4, "L", FALSE );
     FIfld_set_text( form_ptr, VD_COL_DESC_FLD, 0, 5, "%s", FALSE );

     FIfld_set_text( form_ptr, VD_GLB_ATTR_FLD, 0, 0, "%OBJ_NAME", TRUE );
     FIfld_set_text( form_ptr, VD_GLB_ATTR_FLD, 1, 0, "%OBJ_TYPE", FALSE );

     /* initialize leader line parameters */

     VDdet_conv_int_ext( DEF_LENGTH, &def_len, me->curOS );

#ifdef DEBUG
     printf("\ninit_form : leader line def length = %g\n", def_len );
#endif

     FIfld_set_value( form_ptr, VD_LDR_LEN1_FLD, 0, 0, def_len, FALSE );
     FIfld_set_value( form_ptr, VD_LDR_LEN2_FLD, 0, 0, def_len, FALSE );
     FIfld_set_value( form_ptr, VD_LDR_ANGL_FLD, 0, 0, DEF_ANGLE, FALSE );

     /* set default units in form */

     state = VDdet_get_def_units( me->ModuleInfo.md_id.osnum,
                                  "Default units : ", buffer );
     if( state )
          FIg_set_text( form_ptr, VD_DEF_UNITS_TXT, buffer );

     /* set default text parameters */

     stat = gr$get_text_symb( msg        = sts,
                              sizbuf     = sizeof(struct GRdpb_text_symb),
                              buffer     = &textSymb );

#ifdef DEBUG
     printf("\nText Symbology : width = %g, height = %g", 
				textSymb.Active_width, textSymb.Active_height );
#endif

     if( stat & *sts & 1 )
     {
          /* convert to working units */

          if( !VDdet_conv_int_ext( textSymb.Active_width, &txtWidth, 
				me->curOS ) )
               printf("\nUnits conversion of text width failed\n"); 
          if( !VDdet_conv_int_ext( textSymb.Active_height, &txtHeight, 
				me->curOS ) )
               printf("\nUnits conversion of text height failed\n"); 

#ifdef DEBUG
     printf("\nAfter conversion : width = %g, height = %g\n", 
				txtWidth, txtHeight );
#endif

          FIfld_set_value( form_ptr, VD_TXT_WDTH_FLD, 0, 0, 
                           txtWidth, FALSE );
          FIfld_set_value( form_ptr, VD_TXT_HGHT_FLD, 0, 0, 
                           txtHeight, FALSE );
     }

     /* erase the ASCII filename group */

     FIg_erase( form_ptr, VD_ASCII_FLNM_GRP );

     /* set the associativity toggle button */

     if( me->nbLocObjs <= MAX_OBJECTS )
          FIg_set_state( form_ptr, VD_BOM_ASSOC_GAD, 1 );
     else
          FIg_set_state( form_ptr, VD_BOM_ASSOC_GAD, 0 );

     goto quit;

quit:
  return OM_S_SUCCESS;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        form_notification from CEO

  Abstract
        Form notification routine for the CO

  Arguments
        int           form_label;     label of form which received user  input
        int           gadget_label;   gadget label  which received user  input
        double        value;          value of gadget ( or field row # )
        char          * form_ptr ;    ptr to I/Forms form which received input



 -------------------------------------------------------------------------
-mo*/


method form_notification( int      form_label; 
                          int      gadget_label; 
                          double   value;
                          char     *form_ptr )
{
     int   resp,
           i,
           sel,
           pos, 
           row,
           str_len,
           col_len,
           srcRow, destRow,
           nrows;
     long  msg;
     double index,
            angle,
            length;
     char  buffer[MAXROWSIZE], 
           sortOrder[4], 
           colName[MAXROWSIZE], 
           colTitle[MAXROWSIZE], 
           colWidth[MAXROWSIZE], 
           format[MAXROWSIZE], 
           just[5],
           value[MAXROWSIZE], 
           info[MAXROWSIZE], 
           type[4];
     FILE  *fp = NULL;

     long status = OM_S_SUCCESS;


     switch( gadget_label )
     {
          case FI_ACCEPT :
          {
               long sts;
               sts = ProcessColDesc( form_ptr );
               if( sts == VD_RESTART_CMD )
                    break;
      
               /* Unhighlight the last object */

               status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex( &sts,
                                                                me->curObjIndex,
                                                                GRbdhe ),
                                 targetid = my_id );
               as$status();

               
               resp = VD_FORM_ACCEPT;
               ex$putque( msg      = &msg, 
                          response = &resp );
               break;
          }

          case FI_CANCEL :
               resp = VD_FORM_CANCEL;
               ex$putque( msg      = &msg, 
                          response = &resp );
               break;

          case VD_LST_ATTR_FLD :
               break;

          case VD_COL_DESC_FLD :
               ProcessColDesc( form_ptr );
               
               break;

          case VD_GLB_ATTR_FLD :
               break;

          case VD_ROL_PLUS_BTN :
          {
               int curInd, totNo;
            
               curInd = me->curObjIndex;
               totNo  = me->nbLocObjs;
       
               if( curInd + 1 >= totNo )
                    break;

               status = om$send( msg = message VDCmdBOM.dspAttrs(curInd + 1),
                                 targetid = my_id );

               as$status();
               break;
          }

          case VD_ROL_MNUS_BTN :
          {
               int curInd, totNo;
            
               curInd = me->curObjIndex;
               totNo  = me->nbLocObjs;
       
               if( curInd == 0 )
                    break;

               status = om$send( msg = message VDCmdBOM.dspAttrs(curInd - 1),
                                 targetid = my_id );

               as$status();
               break;
          }
               
          case VD_DEL_LIST_BTN :
          {
               status = om$send( msg = message VDCmdBOM.delFromList( &msg,
                                                             me->curObjIndex ),
                                 targetid = my_id );
               as$status();

               status = om$send( msg = message VDCmdBOM.dspAttrs(
                                                             me->curObjIndex ),
                                 targetid = my_id );

               as$status();
               break;
          }

          case VD_ROL_THRU_FLD   :
               FIfld_get_value( form_ptr, gadget_label, 0, 0, &index, &sel,
                               &pos );
               if( index > me->nbLocObjs )
               {
                    FIfld_set_value( form_ptr, gadget_label, 0, 0, 
                                     (double)(me->nbLocObjs), FALSE );
                    
                    me->curObjIndex = me->nbLocObjs - 1;
               }
               else
                    me->curObjIndex = index - 1;
               status = om$send( msg = message VDCmdBOM.dspAttrs(
                                                        me->curObjIndex ),
                                 targetid = my_id );

               as$status();
               break;

          case VD_SELCT_ATT_BTN   :

               /* 
                * The selected attribute must be added to the column
                * description list
                */


               FIfld_get_num_rows( form_ptr, VD_COL_DESC_FLD, &nrows );

               /* 
                * first delete blank rows from the list 
                * this is necessary sometimes, for Modify BOM command
                * where blank rows appear unnecessarily, or when user simply
                * edits other columns in the mcf.
                */

               for( i = 0 ; i < nrows ; i++ )
               {
                    /* get attribute name */

                    FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 0, MAXROWSIZE,
                                    (unsigned char *)buffer, &sel, &pos );

                    /* delete row if name is NULL */

                    if( !strlen( buffer ) )
                    {
                         FIfld_delete_rows( form_ptr, VD_COL_DESC_FLD, i, 1 );
                         nrows--;
                    }
               }

               /* get the active attribute name */

               VDfld_get_select_row( form_ptr, VD_LST_ATTR_FLD, 0, &row );
               FIfld_get_text( form_ptr, VD_LST_ATTR_FLD, row, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );

               if( !sel )
                    break;

               if( !( str_len = strlen( buffer ) ) )
                    break;

               /* if attribute already exists in list, don't add it again */

               for( i = 0 ; i < nrows ; i++ )
               {
                    FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 0,
                                    MAXROWSIZE, (unsigned char *)colName,
                                    &sel, &pos );
                    if( !strcmp( buffer, colName ) )
                         goto quit;
               }
               
               /* get the type and value of the attribute */

               FIfld_get_text( form_ptr, VD_LST_ATTR_FLD, row, 1,
                               4, (unsigned char *)type,
                               &sel, &pos ); 
               FIfld_get_text( form_ptr, VD_LST_ATTR_FLD, row, 2,
                               MAXROWSIZE, (unsigned char *)value,
                               &sel, &pos ); 

               /* Increment the number of rows by 1 */

               FIfld_set_num_rows( form_ptr, VD_COL_DESC_FLD, nrows + 1 );

               /* Set the attribute name in the new row */

               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 0,
                               buffer, FALSE );

               /* Set the column title as attribute name in block letters */

               for( i = 0 ; i < str_len ; i++)
                    buffer[i] = (char) toupper( (int) (buffer[i]) );

               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 2,
                               buffer, FALSE );

               /* Compute default width of column */

               if( (col_len = strlen( value )) < DEF_COL_LENGTH )
                    col_len = DEF_COL_LENGTH;
                    
               /* Set the default column width */

               FIfld_set_value( form_ptr, VD_COL_DESC_FLD, nrows, 3, 
                                (double)col_len, FALSE );

               /* Set the default justification */

               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 4,
                               "L", FALSE );

               /* Evaluate and set default format in the form */

               if( type[0] == 't' )
                    sprintf( format, "%cs", '%' );
               else 
                    sprintf( format, "%c.2f", '%');
         
               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 5,
                               format, FALSE );

               FIfld_set_select( form_ptr, VD_COL_DESC_FLD, nrows, 1, TRUE );

               ProcessColDesc( form_ptr );
               break;
                    
          case VD_UNSEL_ATT_BTN   :

               VDfld_get_select_row( form_ptr, VD_COL_DESC_FLD, 0, &row );
               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, row, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );
               if( !sel )
                    break;

               if( !strcmp( buffer, "%ITEM") ||
                   !strcmp( buffer, "%OBJ_NAME") ||
                   !strcmp( buffer, "%OBJ_TYPE") )
                         break;
               FIfld_delete_rows( form_ptr, VD_COL_DESC_FLD, row, 1 );
               FIfld_get_num_rows( form_ptr, VD_COL_DESC_FLD, &nrows );
               if( row == nrows )
                    row--;
               FIfld_set_select( form_ptr, VD_COL_DESC_FLD, row, 1, TRUE );
               break;

          case VD_SEL_GLOB_BTN    :

               /*
                * first delete blank rows from the list
                * this is necessary sometimes, for Modify BOM command
                * where blank rows appear unnecessarily, or when user simply
                * edits other columns in the mcf.
                */

               FIfld_get_num_rows( form_ptr, VD_COL_DESC_FLD, &nrows );

               for( i = 0 ; i < nrows ; i++ )
               {
                    /* get attribute name */

                    FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 0, MAXROWSIZE,
                                    (unsigned char *)buffer, &sel, &pos );

                    /* delete row if name is NULL */

                    if( !strlen( buffer ) )
                    {
                         FIfld_delete_rows( form_ptr, VD_COL_DESC_FLD, i, 1 );
                         nrows--;
                    }
               }
       
               /* get the global attribute to select */

               FIfld_get_active_row( form_ptr, VD_GLB_ATTR_FLD, &row, &pos );
               FIfld_get_text( form_ptr, VD_GLB_ATTR_FLD, row, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );

               if( !sel )
                    break;

               if( !strlen( buffer ) )
                    break;

               FIfld_delete_rows( form_ptr, VD_GLB_ATTR_FLD, row, 1 );
   
               /* Increment the number of rows by 1 */

               FIfld_set_num_rows( form_ptr, VD_COL_DESC_FLD, nrows + 1 );

               /* Set the attribute name in the new row */

               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 0,
                               buffer, FALSE );

               /* Set the column title in the new row */

               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 2,
                               &buffer[1], FALSE );

               /* Set the attribute justification in the new row */

               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 4, 
                                    "L", FALSE );

               /* Set size and format */

               if( !strcmp( buffer, "%ITEM" ))
               {
                    FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 3, 
                                    "5", FALSE );
                    FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 5, 
                                    "%s", FALSE );
               }
               else
               {
                    FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 3, 
                                    "15", FALSE );
                    FIfld_set_text( form_ptr, VD_COL_DESC_FLD, nrows, 5, 
                                    "%s", FALSE );
               }
               Mk1stVisRowActive( form_ptr, VD_GLB_ATTR_FLD );
               FIfld_set_select( form_ptr, VD_COL_DESC_FLD, nrows, 1, TRUE );
               break;

          case VD_UNS_GLOB_BTN    :
       
               VDfld_get_select_row( form_ptr, VD_COL_DESC_FLD, 0, &row );

               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, row, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );

               if( !sel )
                    break;

               if( !strcmp( buffer, "%ITEM") ||
                   !strcmp( buffer, "%OBJ_NAME") ||
                   !strcmp( buffer, "%OBJ_TYPE") )
               { 
                    FIfld_delete_rows( form_ptr, VD_COL_DESC_FLD, row, 1 );

                    FIfld_get_num_rows( form_ptr, VD_GLB_ATTR_FLD, &nrows );
                    FIfld_set_num_rows( form_ptr, VD_GLB_ATTR_FLD, nrows + 1 );
                    FIfld_set_text( form_ptr, VD_GLB_ATTR_FLD, nrows, 0, 
                                    (unsigned char *)buffer, FALSE );
                    MkLstVisRowActive( form_ptr, VD_GLB_ATTR_FLD );
                    FIfld_get_num_rows( form_ptr, VD_COL_DESC_FLD, &nrows );
                    if( row == nrows )
                         row--;
                    FIfld_set_select( form_ptr, VD_COL_DESC_FLD, row, 1, TRUE );
               }
               break;

          case VD_MOVE_UP_BTN    :

          case VD_MOVE_DOWN_BTN    :

               /* get selected row */

               VDfld_get_select_row( form_ptr, VD_COL_DESC_FLD, 0, &row );

               /* get total number of rows */

               FIfld_get_num_rows( form_ptr, VD_COL_DESC_FLD, &nrows );

               /* if move not possible, break */

               if( (gadget_label == VD_MOVE_DOWN_BTN && row == nrows-1) ||
                   (gadget_label == VD_MOVE_UP_BTN && row == 0 ) )
                    break;

               FIfld_set_select( form_ptr, VD_COL_DESC_FLD, row, 0, FALSE );

               /* determine source and destination rows */

               srcRow = row;
               if( gadget_label == VD_MOVE_DOWN_BTN )
                    destRow = srcRow + 1;
               else
                    destRow = srcRow - 1;
                    
               /* 
                * store the fields of the source row 
                * attribute name, column title, width, justification, format
                */

               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, srcRow, 0, MAXROWSIZE,
                               (unsigned char *)colName, &sel, &pos );
               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, srcRow, 1, 4,
                               (unsigned char *)sortOrder, &sel, &pos );
               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, srcRow, 2, MAXROWSIZE,
                               (unsigned char *)colTitle, &sel, &pos );
               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, srcRow, 3, MAXROWSIZE,
                               (unsigned char *)colWidth, &sel, &pos );
               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, srcRow, 4, 5,
                               (unsigned char *)just, &sel, &pos );
               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, srcRow, 5, MAXROWSIZE,
                               (unsigned char *)format, &sel, &pos );

               /* delete the source row */

               FIfld_delete_rows( form_ptr, VD_COL_DESC_FLD, srcRow, 1 );

               /* insert blank row at destination */

               if( destRow == nrows-1 )
                    FIfld_set_num_rows( form_ptr, VD_COL_DESC_FLD, nrows );
               else
                    FIfld_insert_blank_row( form_ptr, VD_COL_DESC_FLD, destRow );

               /* Copy the stored values to this row */

               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, destRow, 0, 
                               colName, FALSE );
               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, destRow, 1, 
                               sortOrder, FALSE );
               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, destRow, 2, 
                               colTitle, FALSE );
               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, destRow, 3, 
                               colWidth, FALSE );
               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, destRow, 4, 
                               just, FALSE );
               FIfld_set_text( form_ptr, VD_COL_DESC_FLD, destRow, 5, 
                               format, FALSE );

               FIfld_set_select( form_ptr, VD_COL_DESC_FLD, destRow, 0, TRUE );

               break;

          case VD_TXT_WDTH_FLD :
          case VD_TXT_HGHT_FLD :
               break;

          case VD_LDR_LINE_GAD :
 
               /* get and leader line status */

               FIg_get_state( form_ptr, gadget_label, &sel );

               /* update display of leader line gadget group, */

               if( sel )
               {
                    me->leaderFlag = 1;
                    FIg_display( form_ptr, VD_LDR_LINE_GRP );
               }
               else
               {
                    me->leaderFlag = 0;
                    FIg_erase( form_ptr, VD_LDR_LINE_GRP );
               }
  
               break;

          case VD_LDR_LEN1_FLD :
          case VD_LDR_LEN2_FLD :

               /* disallow negative values */

               FIfld_get_value( form_ptr, gadget_label, 0, 0,
                                &length, &sel, &pos );
               if( length < 0 )
                    FIfld_set_value( form_ptr, gadget_label, 0, 0,
                                     (double)0, FALSE );
               break;

          case VD_LDR_ANGL_FLD :

               /* validate angle */

               FIfld_get_value( form_ptr, gadget_label, 0, 0, &angle,
                                &sel, &pos );

               /* if angle out of range, reset to default value */

               if( angle < 0 || angle > 360 )
                    FIg_reset( form_ptr, gadget_label );
               break;
                    
          case VD_BOM_ASSOC_GAD :
               FIg_get_state( form_ptr, VD_BOM_ASSOC_GAD, &sel );
               if( sel && me->nbLocObjs > MAX_OBJECTS )
               {
                    sprintf(info, "Associative BOM limited to 150 objects");
                    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, info, FALSE );
                    UI_status( info );
                    FIg_set_state( form_ptr, VD_BOM_ASSOC_GAD, 0 );
               }
               break;

          case VD_BOM_ASCII_GAD :

               /* get gadget status */

               FIg_get_state( form_ptr, gadget_label, &sel );

               /* update display of ASCII filename group */

               if( sel )
                    FIg_erase( form_ptr, VD_ASCII_FLNM_GRP );
               else
               {
                    FIg_display( form_ptr, VD_ASCII_FLNM_GRP );
                    FIfld_pos_cursor( form_ptr, VD_ASCII_FLNM_FLD, 0, 0, 0, 0 );
               }

               break;

          case VD_ASCII_FLNM_FLD :

               /* get the filename */

               FIfld_get_text( form_ptr, gadget_label, 0, 0, MAXROWSIZE,
                               (unsigned char *)buffer, &sel, &pos );
                             
               /* 
                * if filename is NULL, set toggle button to NO ASCII OUTPUT
                * state
                */

               if( !strlen( buffer) )
               {
                    FIg_set_state( form_ptr, VD_BOM_ASCII_GAD, 1 );
                    FIg_erase( form_ptr, VD_ASCII_FLNM_GRP );
                    break;
               }

               /* if file exists, prompt user for overwrite permission */

               if( fp = fopen( buffer, "r" ) )
               {
                    fclose( fp );
                    if( GRconfirm_box( "File exists. Overwrite?" ) != TRUE )
                    {
                         FIfld_set_text( form_ptr, VD_ASCII_FLNM_FLD, 0, 0,
                                         "", FALSE );
                         FIfld_pos_cursor( form_ptr, VD_ASCII_FLNM_FLD, 
                                           0, 0, 0, 0 );
                         break;
                    }
               }

               /* if file cannot be created, print message */

               if( fopen( buffer, "w" ) == NULL )
               {
                    sprintf(info, "Cannot open file <%s> for writing", buffer );
                    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, info, FALSE );
                    UI_status( info );

                    FIfld_set_text( form_ptr, VD_ASCII_FLNM_FLD, 0, 0,
                                    "", FALSE );
                    FIfld_pos_cursor( form_ptr, VD_ASCII_FLNM_FLD, 
                                      0, 0, 0, 0 );
                    break;
               }
               break;

          default :
               break;


      } /* end switch */

quit :
      return OM_S_SUCCESS;

} /* method form_notification */

method store_format( long *sts )
{
     int               i,
                       count,
                       size,
                       index,
                       sel,
                       pos,
                       nbAtt,
                       nrows,
                       len;
     char              name[MAXROWSIZE],
                       fileBuf[MAX_FILEBUF],
                       just[5],
                       sortOrder[4],
                       sortIndex[4],
                       title[MAXROWSIZE],
                       buffer[MAXROWSIZE],
                       format[MAXROWSIZE];
     long              msg;
     IGRdouble         ldr_len = DEF_LENGTH,
		       txtParam = 1;
     struct ACrg_coll *att = NULL;

     long status    = OM_S_SUCCESS;
     char *form_ptr = me->forms[0].form_ptr;

     *sts = VD_SUCCESS;

     /* store the associativity of BOM */

     FIg_get_state( form_ptr, VD_BOM_ASSOC_GAD, &sel );
     if( sel )
          me->assocOption = 1;
     else
          me->assocOption = 0;

     if( me->mytype == CREATE )
     {
          /* 
           * construct the rg collector for storing the attributes 
           * and their layout
           */

          ex$get_cur_mod( osnum = &me->coll.osnum);
          status = om$construct( classid = OPP_ACrg_collect_class_id,
                                 osnum   = me->coll.osnum,
                                 p_objid = &me->coll.objid );
          as$status();
          if(!(status & 1)) 
          {
                *sts = VD_ERROR;
                goto quit;
          }
     }

     nbAtt = 0;

     /* get number of rows in the column description field */

     FIfld_get_num_rows( form_ptr, VD_COL_DESC_FLD, &nrows );

     /* attribute count in rg_collector 
      * extra 13 for :
      *     Name          Desc                               Type
      *     ~~~~          ~~~~                               ~~~~
      * 1   nullAttRep    null attribute representation      text
      * 2   bomOrient     bom orientation                    text
      * 3   ldrLineFlag   leader line present flag           double
      * 4   ldrLength1    leader line length 1               double
      * 5   ldrLength2    leader line length 2               double
      * 6   ldrAngle      leader line angle                  double
      * 7   txtWidth      Text width                         double
      * 8   txtHeight     Text height                        double
      * 9   outFilename   Output ASCII filename              text
      * 10  tblName       BOM table name                     text
      * 11  blnType       Balloon type for item numbers      double
      * 12  blnSize       Size of the balloon                double
      * 13  blnSides      No of sides for balloon            double
      */
 
     count = nrows + 13 ;

     att = (struct ACrg_coll *)malloc( sizeof(struct ACrg_coll) * count );
     if( att == NULL )
     {
          printf("\nERROR : Dynamic allocation\n");
          *sts = VD_ERROR;
          status = OM_E_NODYNMEM;
          goto quit;
     }

     /* 
      * for each non NULL row, add the column name and the layout in the 
      * rg_collector list
      *            attribute name    = column name
      *            attribute type    = AC_ATTRIB_TEXT
      *            attribute value   = "<J> <sort> <len> <title> <format>"
      *                                 where <J> = justification (C, L, R)
      *                                       <sort> = sort order (string)
      *                                       <len> = column width (integer)
      *                                       <title> = column title (string)
      *                                       <format> = display format string 
      */

     for( i = 0 ; i < nrows ; i++ )
     {
          /* get column name */

          FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 0, MAXROWSIZE,
                          (unsigned char *)name, &sel, &pos );

          if( !strlen( name ) )
               continue;

          FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 2, MAXROWSIZE,
                          (unsigned char *)title, &sel, &pos );

          /* get size, justification and format string */

          FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 3, MAXROWSIZE,
                          (unsigned char *)buffer, &sel, &pos );
          size = atoi( buffer );
          FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 4, 5,
                          (unsigned char *)just, &sel, &pos );
          FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 5, MAXROWSIZE,
                          (unsigned char *)format, &sel, &pos );

          /* get sort order */

          FIfld_get_text( form_ptr, VD_COL_DESC_FLD, i, 1, 4,
                          (unsigned char *)sortOrder, &sel, &pos );


          sortIndex[0] = '\0';
          len = strlen(sortOrder);

#ifdef DEBUG
     printf("\nsortOrder = %s, strlen = %d\n", sortOrder, len );
#endif

          if( !len )
               strcpy( sortOrder, NULL_SORT );
          else
          {
               /* store the sorting information */

               strncpy( sortIndex, sortOrder, len-1 );
               sortIndex[len] = '\0';
               index = atoi(sortIndex);
#ifdef DEBUG
     printf("\nstore_format : index = %d, sortOrder = %s, sortIndex= %s\n",
                              index, sortOrder, sortIndex );
     printf("\nlength of sortOrder = %d\n", len );
#endif
               if(index > SORT_LEVEL )
                    printf( "Error in sorting criteria\n" );
               else 
               {
                    me->sortOrderLst[index-1] = sortOrder[len-1];
                    strcpy( me->sortAttrLst[index-1], name );
                    me->colSizeLst[index-1] = size;
                    strcpy( me->formatLst[index-1], format );
               }
#ifdef DEBUG
     printf("\tsortOrder[%d] = %c, sortAttrlst = %s\n", index-1,  
                                me->sortOrderLst[index-1],
                                me->sortAttrLst[index-1] );
     printf("\tcolSizeLst = %d, formatLst = %s\n", me->colSizeLst[index-1],
                                me->formatLst[index-1] );
#endif
          }

          /* set up the rg_collector data */

          strcpy( att[nbAtt].name, name );
          
          att[nbAtt].desc.type = AC_ATTRIB_TEXT;

          sprintf( att[nbAtt].desc.value.att_txt, "%c %s %d %s %s", just[0],
                                              sortOrder, size, title, format );

#ifdef DEBUG
     printf("\nAttribute value = %s", att[nbAtt].desc.value.att_txt );
#endif
          nbAtt++;
     }

     /* set the types of additional attributes */

     for( i = 0 ; i < 2 ; i++ )
          att[nbAtt+i].desc.type = AC_ATTRIB_TEXT;
     for( i = 2 ; i < 8 ; i++ )
          att[nbAtt+i].desc.type = AC_ATTRIB_DOUBLE;
     for( i = 8 ; i < 10 ; i++ )
          att[nbAtt+i].desc.type = AC_ATTRIB_TEXT;
     for( i = 10 ; i < 13 ; i++ )
          att[nbAtt+i].desc.type = AC_ATTRIB_DOUBLE;

     /* get and store the null attribute rep */

     FIfld_get_text( form_ptr, VD_NUL_VALU_FLD, 0, 0, MAXROWSIZE,
                     (unsigned char *)buffer, &sel, &pos );
     strcpy( att[nbAtt].desc.value.att_txt, buffer );
     strcpy( att[nbAtt++].name, "nullAttRep" );

     /* get and store the orientation of the table : BOTTOM_UP or TOP_DOWN */

     FIg_get_state( form_ptr, VD_BOM_ORNT_GAD, &sel );
     if( sel )
          att[nbAtt].desc.value.att_txt[0] = BOTTOM_UP;
     else
          att[nbAtt].desc.value.att_txt[0] = TOP_DOWN;
     att[nbAtt].desc.value.att_txt[1] = '\0';
     strcpy( att[nbAtt++].name, "bomOrient" );

     /* store leader line flag */

     att[nbAtt].desc.value.att_exp = me->leaderFlag;
     strcpy( att[nbAtt++].name, "ldrLineFlag" );

     /* leader line length 1, convert to imperial units before storing */

     /* set up the leader line structure */

     me->ldrLine.num_segs = 2;

     if( me->ldrLine.segs == NULL )
     {
          me->ldrLine.segs = (struct VDan_segs *)malloc( 
				sizeof(struct VDan_segs) * 2);
          if( me->ldrLine.segs == NULL )
          {
               printf("\nERROR : Dynamic Allocation\n");
               *sts = VD_ERROR;
               goto quit;
          }
     }

     FIfld_get_value( form_ptr, VD_LDR_LEN1_FLD, 0, 0, 
                      &ldr_len,
                      &sel, &pos );

     me->ldrLine.segs[0].len = ldr_len;

     VDdet_conv_ext_int( ldr_len, &att[nbAtt].desc.value.att_exp,
				me->curOS );
     strcpy( att[nbAtt++].name, "ldrLength1" );

     /* leader line length 2 */

     FIfld_get_value( form_ptr, VD_LDR_LEN2_FLD, 0, 0, 
                      &ldr_len,
                      &sel, &pos );

     me->ldrLine.segs[1].len = ldr_len;

     VDdet_conv_ext_int( ldr_len, &att[nbAtt].desc.value.att_exp,
				me->curOS );

     strcpy( att[nbAtt++].name, "ldrLength2" );

     /* leader line angle */

     FIfld_get_value( form_ptr, VD_LDR_ANGL_FLD, 0, 0, 
                      &att[nbAtt].desc.value.att_exp,
                      &sel, &pos );
     me->ldrLine.segs[0].angle = att[nbAtt].desc.value.att_exp;
     strcpy( att[nbAtt++].name, "ldrAngle" );

     if( me->ldrLine.segs[0].angle > 90 && me->ldrLine.segs[0].angle < 270 )
          me->ldrLine.segs[1].angle = 180;
     else
          me->ldrLine.segs[1].angle = 0;

     /* text width and height*/

     FIfld_get_value( form_ptr, VD_TXT_WDTH_FLD, 0, 0, 
                      &txtParam,
                      &sel, &pos );
     VDdet_conv_ext_int( txtParam, &att[nbAtt].desc.value.att_exp,
				me->curOS );
     strcpy( att[nbAtt++].name, "txtWidth" );
     FIfld_get_value( form_ptr, VD_TXT_HGHT_FLD, 0, 0, 
                      &txtParam,
                      &sel, &pos );
     VDdet_conv_ext_int( txtParam, &att[nbAtt].desc.value.att_exp,
				me->curOS );
     strcpy( att[nbAtt++].name, "txtHeight" );

     /* store ASCII ouput file name : NULL string for no ASCII output */

     FIg_get_state( form_ptr, VD_BOM_ASCII_GAD, &sel );
     if( sel )
          strcpy( att[nbAtt].desc.value.att_txt, ""); 
     else
     {
          FIfld_get_text( form_ptr, VD_ASCII_FLNM_FLD, 0, 0, MAX_FILEBUF,
                          (unsigned char *)fileBuf, &sel, &pos );
          strcpy( att[nbAtt].desc.value.att_txt, fileBuf );
     }
     strcpy( att[nbAtt++].name, "outFilename" );

     strcpy( att[nbAtt].desc.value.att_txt, me->tblName );
     strcpy( att[nbAtt++].name, "tblName" );

     /* store balloon type, size and sides */

#ifdef DEBUG
     printf("\nstore_format : bln params = %d, %g, %d\n", me->blnType,
						me->blnSize, me->blnSides );
#endif

     att[nbAtt].desc.value.att_exp = me->blnType;
     strcpy( att[nbAtt++].name, "blnType" );
     att[nbAtt].desc.value.att_exp = me->blnSize;
     strcpy( att[nbAtt++].name, "blnSize" );
     att[nbAtt].desc.value.att_exp = me->blnSides;
     strcpy( att[nbAtt++].name, "blnSides" );
     
#ifdef DEBUG
     printf("\nNo of attributes (nbAtt) = %d", nbAtt );
     printf("\nnull att rep = %s\n", att[nbAtt-13].desc.value.att_txt );
     printf("\nbom orientation = %s\n", att[nbAtt-12].desc.value.att_txt );
     printf("\nleader line flag = %g\n", att[nbAtt-11].desc.value.att_exp );
     printf("\nleader len1 = %g\n", att[nbAtt-10].desc.value.att_exp );
     printf("\nleader len2 = %g\n", att[nbAtt-9].desc.value.att_exp );
     printf("\nleader angle = %g\n", att[nbAtt-8].desc.value.att_exp );
     printf("\ntext width = %g\n", att[nbAtt-7].desc.value.att_exp );
     printf("\ntext height = %g\n", att[nbAtt-6].desc.value.att_exp );
     printf("\nOutput filename = %s\n", att[nbAtt-5].desc.value.att_txt );
     printf("\nBOM tbl name = %s\n", att[nbAtt-4].desc.value.att_txt );
     printf("\nBalloon type = %g\n", att[nbAtt-3].desc.value.att_exp );
     printf("\nBalloon size = %g\n", att[nbAtt-2].desc.value.att_exp );
     printf("\nBalloon sides = %g\n", att[nbAtt-1].desc.value.att_exp );
#endif

     /* Set up the new list of attributes in the rg collector */

     status = om$send( msg = message ACrg_collect.ACset_list_attribute( &msg,
                                                                        nbAtt,
                                                                        att ),
                       targetid = me->coll.objid,
                       targetos = me->coll.osnum );
     as$status();


quit :
     if( att )
          free( att );
     return OM_S_SUCCESS;
}

method update_form( long *sts )
{
     IGRchar             just[2],
                         format[MAX_BUF_CHARS],
                         title[MAX_BUF_CHARS],
                         size_str[MAX_BUF_CHARS],
                         buffer[MAXROWSIZE],
			 buf[256],
                         sortOrder[4],
                         fileBuf[MAX_FILEBUF],
                         globAtts[3][MAXROWSIZE];

     IGRint              i, j,
                         nb,
                         state,
                         len,
                         nrows,
                         sel,
                         pos,
                         nbGlbRows,
                         size;

     IGRlong             msg;
     IGRdouble		ldr_len,
			txtParam;
     char               *form_ptr;

     struct ACrg_coll    att[MAX_COLUMNS+13];
     IGRlong             status = OM_S_SUCCESS;
     FILE		*fp = NULL;

     *sts = VD_SUCCESS;

     form_ptr = me->forms[0].form_ptr;

     status = om$send( msg = message VDCmdBOM.dspAttrs( me->curObjIndex ),
                       targetid = my_id );
     
     if( me->assocOption )
          FIg_set_state( form_ptr, VD_BOM_ASSOC_GAD, TRUE );
     else
          FIg_set_state( form_ptr, VD_BOM_ASSOC_GAD, FALSE );

     status = om$send( msg = message ACrg_collect.AClist_attribute( &msg,
                                                             MAX_COLUMNS+13,
                                                             att,
                                                             &nb ),
                       targetid = me->coll.objid,
                       targetos = me->coll.osnum );
     as$status();

#ifdef DEBUG
     printf("\nNo of attributes = %d\n", nb );
#endif

     /* null attribute representation */

     FIfld_set_text( form_ptr, VD_NUL_VALU_FLD, 0, 0, 
                     att[nb-13].desc.value.att_txt, FALSE );

     /* orientation of table */

     if( att[nb-12].desc.value.att_txt[0] == BOTTOM_UP )
          FIg_set_state( form_ptr, VD_BOM_ORNT_GAD, TRUE );
     else if( att[nb-12].desc.value.att_txt[0] == TOP_DOWN )
          FIg_set_state( form_ptr, VD_BOM_ORNT_GAD, FALSE );

     else
          printf("\nOrientation of table unknown\n");

     /* set up the leader line structure */

     me->ldrLine.num_segs = 2;

     if( me->ldrLine.segs == NULL )
     {
          me->ldrLine.segs = (struct VDan_segs *)malloc( 
				sizeof(struct VDan_segs) * 2);
          if( me->ldrLine.segs == NULL )
          {
               printf("\nERROR : Dynamic Allocation\n");
               *sts = VD_ERROR;
               goto quit;
          }
     }

     /* leader line parameters */

     if( att[nb-11].desc.value.att_exp )
     {
          FIg_set_state( form_ptr, VD_LDR_LINE_GAD, TRUE );
          me->leaderFlag = 1;
          FIg_display( form_ptr, VD_LDR_LINE_GRP );
     }
     else
     {
          FIg_set_state( form_ptr, VD_LDR_LINE_GAD, FALSE );
          me->leaderFlag = 0;
          FIg_erase( form_ptr, VD_LDR_LINE_GRP );
     }

     VDdet_conv_int_ext( att[nb-10].desc.value.att_exp, &ldr_len, me->curOS );
     me->ldrLine.segs[0].len = ldr_len;
     FIfld_set_value( form_ptr, VD_LDR_LEN1_FLD, 0, 0, ldr_len, FALSE );

     VDdet_conv_int_ext( att[nb-9].desc.value.att_exp, &ldr_len, me->curOS );
     me->ldrLine.segs[1].len = ldr_len;
     FIfld_set_value( form_ptr, VD_LDR_LEN2_FLD, 0, 0, ldr_len, FALSE );

     FIfld_set_value( form_ptr, VD_LDR_ANGL_FLD, 0, 0, 
			att[nb-8].desc.value.att_exp, FALSE );
     me->ldrLine.segs[0].angle = att[nb-8].desc.value.att_exp;

     if( me->ldrLine.segs[0].angle > 90 && me->ldrLine.segs[0].angle < 270 )
          me->ldrLine.segs[1].angle = 180;
     else
          me->ldrLine.segs[1].angle = 0;

     /* text parameters */

     VDdet_conv_int_ext( att[nb-7].desc.value.att_exp, &txtParam, me->curOS );
     FIfld_set_value( form_ptr, VD_TXT_WDTH_FLD, 0, 0, txtParam, FALSE );

     VDdet_conv_int_ext( att[nb-6].desc.value.att_exp, &txtParam, me->curOS );
     FIfld_set_value( form_ptr, VD_TXT_HGHT_FLD, 0, 0, txtParam, FALSE );

     /* set default units in form */

     state = VDdet_get_def_units( me->ModuleInfo.md_id.osnum,
                                  "Default units : ", buf );
     if( state )
          FIg_set_text( form_ptr, VD_DEF_UNITS_TXT, buf );

#ifdef DEBUG
   printf( "\nModule osnum = %d, units = %s\n", me->ModuleInfo.md_id.osnum,
						buf );
#endif

     /* ASCII filename */

     strcpy( fileBuf, att[nb-5].desc.value.att_txt );
     if( !strlen(fileBuf) )
     {
          FIg_set_state( form_ptr, VD_BOM_ASCII_GAD, TRUE );
          FIg_erase( form_ptr, VD_ASCII_FLNM_GRP );
     }
     else if( (fp = fopen( fileBuf, "w" )) == NULL )
     {
          FIg_set_state( form_ptr, VD_BOM_ASCII_GAD, TRUE );
          FIg_erase( form_ptr, VD_ASCII_FLNM_GRP );
     }
     else
     {
          fclose(fp);
          FIg_set_state( form_ptr, VD_BOM_ASCII_GAD, FALSE );
          FIg_display( form_ptr, VD_ASCII_FLNM_GRP );
          FIfld_set_text( form_ptr, VD_ASCII_FLNM_FLD, 0, 0, fileBuf, FALSE );
     }

     len = strlen( att[nb-4].desc.value.att_txt );
     status = om$vla_set_dimension( varray	= me->tblName,
				    size	= len );
     as$status();
     if( !(status & 1) )
     {
          *sts = VD_ERROR;
          goto quit;
     }
     strcpy( me->tblName, att[nb-4].desc.value.att_txt );

     /* balloon parameters */

     me->blnType	= att[nb-3].desc.value.att_exp;
     me->blnSize	= att[nb-2].desc.value.att_exp;
     me->blnSides	= att[nb-1].desc.value.att_exp;
  
     /* set the column description mcf values */

     nrows = nb - 13;

     FIfld_set_num_rows( form_ptr, VD_COL_DESC_FLD, nrows );

     for( i = 0 ; i < nrows ; i++ )
     {
          sscanf( att[i].desc.value.att_txt, "%c %s %d %s %s", &just[0],
                                          sortOrder, &size, title, format );
          just[1] = '\0';

#ifdef DEBUG
     printf("\njust = %s, sortOrder = %s, size = %d, title = %s, format = %s",
               just, sortOrder, size, title, format );
#endif
          
          sprintf( size_str, "%d", size );
 
          if( !strcmp( sortOrder, NULL_SORT ) )
               strcpy( sortOrder, "" );
          
          FIfld_set_text( form_ptr, VD_COL_DESC_FLD, i, 0, att[i].name, FALSE );
          FIfld_set_text( form_ptr, VD_COL_DESC_FLD, i, 1, sortOrder, FALSE );
          FIfld_set_text( form_ptr, VD_COL_DESC_FLD, i, 2, title, FALSE );
          FIfld_set_text( form_ptr, VD_COL_DESC_FLD, i, 3, size_str, FALSE );
          FIfld_set_text( form_ptr, VD_COL_DESC_FLD, i, 4, just, FALSE );
          FIfld_set_text( form_ptr, VD_COL_DESC_FLD, i, 5, format, FALSE );
     }

     /* make the last visitble row active */

     MkLstVisRowActive( form_ptr, VD_COL_DESC_FLD );

     strcpy( globAtts[0], "%ITEM" );
     strcpy( globAtts[1], "%OBJ_NAME" );
     strcpy( globAtts[2], "%OBJ_TYPE" );

     FIfld_set_num_rows( form_ptr, VD_GLB_ATTR_FLD, 0 );
     nbGlbRows = 0;

     for( i = 0 ; i < 3 ; i++ )
     {
          for( j = 0 ; j < nrows ; j++ )
          {
               FIfld_get_text( form_ptr, VD_COL_DESC_FLD, j, 0, MAXROWSIZE, 
                               buffer, &sel, &pos );
               if( !strcmp( buffer, globAtts[i] ) )
                    break;
          }
          if( j == nrows )
          {
               FIfld_set_num_rows( form_ptr, VD_GLB_ATTR_FLD, nbGlbRows + 1 );
               FIfld_set_text( form_ptr, VD_GLB_ATTR_FLD, nbGlbRows, 0, 
                                                      globAtts[i], FALSE );
               nbGlbRows++;
          }

     }

quit :

     return OM_S_SUCCESS;
}

end implementation VDCmdBOM;
