/* $Id: VDBOMactions.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDBOMactions.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDBOMactions.I,v $
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
# Revision 1.8  1994/12/30  16:34:12  pinnacle
# Replaced:  vdbom/cmd/VDBOMactions.I r#
#
# Revision 1.7  1994/12/21  15:52:50  pinnacle
# Replaced:  vdbom/cmd/VDBOMactions.I r#
#
# Revision 1.6  1994/12/13  20:26:00  pinnacle
# Replaced:  vdbom/cmd/VDBOM[af]*.I r#
#
# Revision 1.5  1994/12/13  15:15:26  pinnacle
# Replaced:  vdbom/cmd/VDBOMactions.I r#
#
# Revision 1.4  1994/12/12  20:47:42  pinnacle
# Replaced:  vdbom/cmd/*.[IS] r#
#
# Revision 1.3  1994/12/09  15:57:26  pinnacle
# Replaced:  vdbom/cmd/VDBOMactions.I r#
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
 *                      R. Manem                Creation
 *
 *      12/07/94        R. Manem        OPE enhancements :
 *                                      - item number generation with prefixes
 *                                      - creation of VDgrset template for
 *                                        macro, for non-assoc BOM case
 *                                      - VDcreateSetName : new function
 *                                        for creating unique name for set
 *                                      - additional attributes in rg_collector
 *                                        template of macro
 *	12/12/94	R. Manem	- generate_item_nos function converted
 *					  to method
 *					- connection of item objects to pfx obj
 *	12/13/94	R. Manem	- bug fix in generate_item_nos method
 *	12/20/94	R. Manem	- correction of num_segs in leader line
 *					  clean up to item manager
 *	12/30/94	R. Manem	- DOn't make_source for creating sets.
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdBOM;


#include "OMprimitives.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "string.h"
#include "vdparmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "AS_status.h"
#include "ex.h"
#include "exproto.h"
#include "grio.h"
#include "VDCmdDef.h"
#include "VDbom.h"
#include "VDSannot.h"
#include "coparamac.h"
#include "coparadef.h"
#include "vdandef.h"
#include "vdanmacros.h"
#include "vdsetmacros.h"
#include "VDSFilter.h"
#include "FI.h"
#include "FEI.h"

/*
#define DEBUG
*/

from ci_macro         import 	init;
from nci_macro        import 	NDdelete;
from NDnode           import 	NDdisplay;
from ACrg_collect     import 	ACget_named_attribute;
from VDgrset          import 	VDSet_flag;
from VDitemMgr        import 	VDgetFreeItemNo, 
				VDcleanUp,
				VDconnectItmObjs;

%safe
static IGRint BOMtableNo = 1;
%endsafe

extern ASmake_source_from_env();
extern GRclassid OPP_nci_macro_class_id;

void VDcreateSetName( IGRchar    *name )
{
     IGRlong		status = 1;
     struct GRid	setGrid;

     while( status == 1 )
     {
          sprintf( name, "_BOMset_%d", BOMtableNo );
     
          status = vd$setname_togrid( set_name	      = name,
                                      set_grid        = &setGrid );
          BOMtableNo++;
     }

#ifdef DEBUG
     printf("\nVDcreateSetName function : Set name = %s", name );
#endif

}


method generate_item_nos( IGRlong *sts )
{
     IGRint 		i,
			n,
			flag,
			size,
			found = 0,
			itemNo;
     IGRchar		*itemPfx = NULL, *pfx = NULL;
     IGRlong		msg;
     IGRpoint		offset = { 0, 0, 0 };
     struct GRid 	mgrId,
			*itemIds = NULL;
     struct GRmd_env 	MOD_ENV;
     struct VDan_ldrline *ldr = NULL;
     IGRlong		status = OM_S_SUCCESS;


     /* allocate space for the item objects */

     itemIds = (struct GRid *)malloc( sizeof( struct GRid ) * me->nbLocObjs );
     if( !itemIds )
     {
          printf("\nERROR : Dynamic Allocation\n");
          status = OM_E_NODYNMEM;
          goto quit;
     }
          
     /* get current module environment */

     size = sizeof( struct GRmd_env );
     status = gr$get_module_env( msg    = &msg,
                                 sizbuf = &size,
                                 buffer = &MOD_ENV,
                                 nret   = &n );

     as$status( action = GOTO_VALUE, value = quit );
 
     /* get the item manager id */

     status = ex$get_super(	mod_id		= MOD_ENV.md_id.objid,
				mod_osnum	= MOD_ENV.md_id.osnum,
				super_name	= "ItemMgr",
				create		= 1,
				super_class	= "VDitemMgr",
				super_id	= &mgrId.objid,
				super_osnum	= &mgrId.osnum );

     as$status( action = GOTO_VALUE, value = quit );

     /* 
      * send a clean up message to the item manager.  Better to clean up
      * before getting free item numbers 
      */

     status = om$send( msg	= message VDitemMgr.VDcleanUp( &msg ),
		       targetid	= mgrId.objid,
		       targetos	= mgrId.osnum );

#ifdef DEBUG
     printf("\nITEM NUMBER GENERATION ................\n");
     printf("\nItem Manager id = <%d, %d>\n", mgrId.objid, mgrId.osnum );
#endif

     for( i = 0 ; i < me->nbLocObjs ; i++ )
     {
          itemIds[i].objid = NULL_OBJID;

          if( itemPfx )
               free( itemPfx );
          itemPfx = NULL;


          /* if object already has item number, continue with the next one */

          status = vd$getItemNoForObj(  obj     = me->locObjs[i].obj_id,
                                        tblName = me->tblName,
                                        found   = &found );
          as$status();

          if( found )
          {

#ifdef DEBUG
     printf("\ngenerate_item_nos : ");
     printf("Object <%d, %d> has item number\n");
#endif

               continue;
          }

          status = om$send( msg		= message VDitemMgr.VDgetFreeItemNo(
								&msg,
								&me->locObjs[i],
								&itemNo,
								&itemPfx,
								me->tblName,
								ASSIGN ),
			    targetid	= mgrId.objid,
			    targetos	= mgrId.osnum );
          as$status();

          if( !(status & msg & 1) )
               continue;

#ifdef DEBUG
     printf("\nObjid = <%d, %d>, item number = %d, item prefix = %s", 
					me->locObjs[i].obj_id.objid, 
					me->locObjs[i].obj_id.osnum,
					itemNo, itemPfx );
#endif

          if( itemPfx[0] == ';' )
          {
               pfx = &itemPfx[1];
               flag = 1;
          }
          else
          {
               pfx = itemPfx;
               flag = 0;
          }
 
          if( me->ldrLine.segs[1].len )
              me->ldrLine.num_segs = 2;
          else
              me->ldrLine.num_segs = 1;

          ldr = me->leaderFlag ? &me->ldrLine : NULL ;

          vd$place_item( object           = &me->locObjs[i],
                         item_num         = itemNo,
			 pfx              = pfx,
			 pfx_flag         = flag,
			 tbl_name         = me->tblName,
                         bln_type         = &me->blnType,
                         bln_sides        = &me->blnSides,
                         bln_size         = &me->blnSize,
			 leader_line	  = ldr,
                         offset           = offset,
                         p_item           = &itemIds[i],
                         window           = &me->window );
#ifdef DEBUG
     printf("\nItem placed : ");
     printf("\nItem Id  = <%d, %d>", itemIds[i].objid, itemIds[i].osnum );
#endif
     }

     /* now connect the item objects to the prefix sets */

     status = om$send( msg	= message VDitemMgr.VDconnectItmObjs( &msg,
								me->nbLocObjs,
								itemIds ),
		       targetid = mgrId.objid,
		       targetos = mgrId.osnum );
     as$status();

quit :

     if( itemPfx )
          free( itemPfx );
     return status;
}

method generate_bom( long *sts )
{
     long status = OM_S_SUCCESS;

     int                i, 
                        n, 
                        rc,
                        size, 
                        nbTemp;
     long               msg;
     IGRchar            setName[80];
     struct GRid        TEMP[MAX_TEMP],
                        setGrid,
                        MAC;
     struct GRmd_env    MOD_ENV;
     struct ACrg_coll   att;

     TEMP[0] = me->coll;

     ASmake_source_from_env( &me->csGrid.obj_id, 
                             &me->csGrid.mod_env, 
                             &TEMP[1], 0);
     
     size = sizeof( struct GRmd_env );
     status = gr$get_module_env( msg    = &msg,
                                 sizbuf = &size,
                                 buffer = &MOD_ENV,
                                 nret   = &n );

     if( me->assocOption )
     {
          /* associative BOM - create individual templates for objects */

          for( i = 0 ; i < me->nbLocObjs ; i++ )
          {
               ASmake_source_from_env( &me->locObjs[i].obj_id, 
                                       &me->locObjs[i].mod_env, 
                                       &TEMP[i+2], 0);
#ifdef DEBUG
     printf("\nSource object : <%d, %d>\n", TEMP[i+2].objid, TEMP[i+2].osnum );
#endif
      
          }
          nbTemp = me->nbLocObjs + 2;
     }
     else
     {
          /* 
           * non-associative BOM - create a VDset of objects as a template 
           */


          /* Create a set name, construct the set, and make it private */

          VDcreateSetName( setName );

          status = vd$create_set( set_name         = setName,
                                  comps            = me->locObjs,
                                  numcomps         = me->nbLocObjs,
                                  set_env          = &MOD_ENV,
                                  set_grid         = &setGrid );
          as$status();
                                  
          if( !(status & 1) )
          {
               *sts = VD_RESTART_CMD;
               printf("\nFailed to construct VDset for non-assoc BOM\n");
               UI_status( "Failed to create BOM\n");
               goto quit;
          }

          status = om$send( msg		= message VDgrset.VDSet_flag(&msg, 1),
			    targetid	= setGrid.objid,
			    targetos	= setGrid.osnum );
          as$status();
								      
          TEMP[2] = setGrid;
          nbTemp = 3;
     }



     if( me->mytype == MODIFY )
     {
          status = om$send( msg = message NDnode.NDdisplay( 0, GRbehe, 
                                                        &me->bomGrid.mod_env ),
                            targetid = me->bomGrid.obj_id.objid,
                            targetos = me->bomGrid.obj_id.osnum );
          as$status()

          status = om$send( msg = message nci_macro.NDdelete( 
                                                    &me->bomGrid.mod_env ),
                            targetid = me->bomGrid.obj_id.objid,
                            targetos = me->bomGrid.obj_id.osnum );
          as$status()
     }

     strcpy( att.name, "%ITEM" );
     att.desc.type = AC_ATTRIB_TEXT;

     status = om$send( msg = message ACrg_collect.ACget_named_attribute( 
                                                                    &msg,
                                                                    &att ),
                       targetid = me->coll.objid,
                       targetos = me->coll.osnum );


     if( msg & 1 )
     {
          status = om$send( mode	= OM_e_wrt_message,
		   	    msg		= message VDCmdBOM.generate_item_nos(
									 sts ),
		   	    targetid	= my_id );
          as$status();
     }

     MAC.objid = NULL_OBJID;
     MAC.osnum = MOD_ENV.md_id.osnum;
     status = om$construct( classid = OPP_nci_macro_class_id,
                            osnum   = MAC.osnum,
                            p_objid = &MAC.objid );
     as$status();

#ifdef DEBUG
     printf("\n\n++++++++++ CALLING PPL INIT +++++++++++++++++++++\n");
#endif

     status = om$send( msg = message ci_macro.init( &rc, 0, "bom",
                                                    nbTemp, TEMP, 
                                                    NULL, &MOD_ENV ),
                       targetid = MAC.objid,
                       targetos = MAC.osnum );
     as$status();

#ifdef DEBUG
     printf("\nAfter initializing macro\n");
#endif

     *sts = VD_SUCCESS;

quit :
     return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------
  Public Message dspAttrs

  Abstract
        Displays the attributes of an element in the form

  Arguments
        int     elmNo           I     Index of element, whose attributes
                                      are to be displayed

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/


method dspAttrs( int elmNo )
{
     int              oldInd;
     long             msg ;
     char             *pForm = me->forms[0].form_ptr ;
     struct GRobj_env elm;

     long status = OM_S_SUCCESS;

     /* get the old object index and dehighlight it */

     oldInd = me->curObjIndex;

     /* 
      * dehighlight only if new element is different  from the previous one 
      * The first time dspAttrs is called, the old index will be equal to
      * the new one, because me->curObjIndex is set to 0 in process_locate
      */

     if( oldInd != elmNo )
     {
          status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex( &msg,
                                                                      oldInd,
                                                                      GRbdhe ),
                            targetid = my_id );
          as$status();
     }

     /* Get the current element and highlight it */
           
     status = om$send( msg = message VDS_LOCATE.getLocObjAtIndex( &msg, 
                                                                  elmNo, 
                                                                  &elm ),
                       targetid = my_id ) ;
     as$status();

     me->curObjIndex = elmNo;

     status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex( &msg,
                                                                 elmNo,
                                                                 GRbdhd ),
                       targetid = my_id );
     as$status();

     /* fill up the attributes in the form */

     status = VDfillAttrForm( &msg, pForm, me->locObjs[elmNo] ) ;

     as$status();

     /* 
      * if more than one object is located, then display the roll through
      * group gadgets, else erase it
      */

     if( me->nbLocObjs == 1 )
          FIg_erase( pForm, VD_ROL_THRU_GRP );
     else
     {
          FIfld_set_value( pForm, VD_ROL_THRU_FLD, 0, 0, 
                           (double)(elmNo+1), FALSE );
          FIg_display( pForm, VD_ROL_THRU_GRP );
     }

     return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message delFromList

  Abstract
        Deletes the specified object from the list of located objects

  Arguments
        long    *sts            O     Completion Code
        int     elmNo           I     Index of element to delete

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/

method delFromList( long *sts; int elmNo )
{
     int i;

     long status = OM_S_SUCCESS;


     /* dehighlight the object before deleting it */

     status = om$send( msg = message VDS_LOCATE.dpLocObjAtIndex( sts,
                                                                 elmNo,
                                                                 GRbdhe ),
                       targetid = my_id );
     as$status();

     /* move the remaining objects one position up in the list */

     for( i = elmNo ; i < me->nbLocObjs - 1 ; i++ )
          me->locObjs[i] = me->locObjs[i+1];

     me->nbLocObjs--;
     om$vla_set_dimension( varray = me->locObjs,
                           size   = me->nbLocObjs );

     if( me->curObjIndex >= me->nbLocObjs && me->curObjIndex )
          me->curObjIndex--;

     return status;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        mouse from VDS_LOCATE

  Abstract
        Based on the mouse position on the bill of materials form 
        this method displays a suitable message in the message field

  Arguments
      long              *msg      O     Completion code
      char              *form     I     pointer to the form
      int               x         I     x coordinate of the mouse position
      int               y         I     y coordinate of the mouse position


 -------------------------------------------------------------------------
-mo*/


method mouse( long     *msg;
              char     *form;
              int      x; 
              int      y )
{
     int   label ;

     if( FIf_find_gadget( form, FI_FORM_GROUP, x, y, &label ) == FI_SUCCESS ) 
     {
          static int  prevLabel  = -1 ;
          static char *prevForm  = NULL ;

          if( prevForm != form || prevLabel != label ) 
          {
               long m ;
               char buffer[80];

               if( form == me->forms[0].form_ptr ) 
               {
                    switch( label ) 
                    {
                         case VD_LST_ATTR_FLD : 
                              m = VD_I_ListOfAttrs ; break ;

                         case VD_COL_DESC_FLD : 
                              m = VD_I_AttrsToBeDisp  ; break ;

                         case VD_GLB_ATTR_FLD : 
                              m = VD_I_LstOfGlobAttr  ; break ;

                         case VD_ROL_PLUS_BTN : 
                              m = VD_I_DpAttNxOb     ; break ;

                         case VD_ROL_MNUS_BTN : 
                              m = VD_I_DpAttPrOb     ; break ;

                         case VD_ROL_THRU_FLD : 
                              m = VD_I_PosCurObj     ; break ;

                         case VD_DEL_LIST_BTN : 
                              m = VD_I_DelObFrSt     ; break ;

                         case VD_ATT_NAME_TXT : 
                         case VD_COL_NAME_TXT : 
                              m = VD_I_NameOfAtt     ; break ;

                         case VD_ATT_TYPE_TXT : 
                              m = VD_I_TypeOfAtt     ; break ;

                         case VD_ATT_VALU_TXT : 
                              m = VD_I_ValueOfAtt     ; break ;

                         case VD_SRT_ORDR_TXT : 
                              m = VD_I_SortOrderVals ; break ;

                         case VD_COL_TITL_TXT : 
                              m = VD_I_TitleForCol    ; break ;

                         case VD_COL_SIZE_TXT : 
                              m = VD_I_WidthOfCol     ; break ;

                         case VD_COL_JUST_TXT : 
                              m = VD_I_JustOfCol      ; break ;

                         case VD_COL_FRMT_TXT : 
                              m = VD_I_FormatOfCol    ; break ;

                         case VD_SELCT_ATT_BTN : 
                              m = VD_I_SelectAtt      ; break ;

                         case VD_UNSEL_ATT_BTN : 
                              m = VD_I_DeselAtt       ; break ;

                         case VD_SEL_GLOB_BTN : 
                              m = VD_I_SelGlobAtt     ; break ;

                         case VD_UNS_GLOB_BTN : 
                              m = VD_I_DeselGlobAtt   ; break ;

                         case VD_NUL_VALU_FLD : 
                              m = VD_I_RepUndefAtt   ; break ;

                         case VD_MOVE_UP_BTN : 
                              m = VD_I_MoveSelRowUp    ; break ;

                         case VD_MOVE_DOWN_BTN : 
                              m = VD_I_MoveSelRowDn    ; break ;

                         case VD_TXT_WDTH_FLD : 
                              m = VD_I_WdthOfTxt    ; break ;

                         case VD_TXT_HGHT_FLD : 
                              m = VD_I_HeightOfTxt    ; break ;

                         case VD_DEF_UNITS_TXT : 
                              m = VD_I_DefUnitsOfDist    ; break ;

                         case VD_LDR_LINE_GAD : 
                              m = VD_I_LdrLine    ; break ;

                         case VD_LDR_LEN1_FLD : 
                              m = VD_I_LdrLineLen1    ; break ;

                         case VD_LDR_LEN2_FLD : 
                              m = VD_I_LdrLineLen2    ; break ;

                         case VD_LDR_ANGL_FLD : 
                              m = VD_I_LdrLineAngle    ; break ;

                         case VD_BOM_ORNT_GAD : 
                              m = VD_I_OrntOfBomTbl   ; break ;

                         case VD_BOM_ASSOC_GAD : 
                              m = VD_I_AssocOfBom   ; break ;

                         case VD_BOM_ASCII_GAD : 
                              m = VD_I_OutToAsciiFile   ; break ;

                         case VD_ASCII_FLNM_FLD : 
                              m = VD_I_ASCIIFlName   ; break ;

                         default                : 
                              m = VD_I_EmptyMessage  ; break ;
                    }
                    ex$message( msgnumb = m,
                                buff    = buffer );

                    FIfld_set_text( form, FI_MSG_FIELD, 0, 0, 
                                    buffer, FALSE ) ;
               }
               prevForm = form ; prevLabel = label ;
          }
     }

     *msg = MSSUCC ;
     return OM_S_SUCCESS ;

} /* method mouse */

method check_item( long *sts )
{
     long             msg;
     struct ACrg_coll att;

     long status  = OM_S_SUCCESS;

     *sts = VD_ERROR;

     strcpy( att.name, "%ITEM" );
     att.desc.type = AC_ATTRIB_TEXT;

     status = om$send( msg = message ACrg_collect.ACget_named_attribute(
                                                                    &msg,
                                                                    &att ),
                       targetid = me->coll.objid,
                       targetos = me->coll.osnum );

     if( status & msg & 1 )
        *sts = VD_SUCCESS;
 
     return OM_S_SUCCESS;
}


end implementation VDCmdBOM;
