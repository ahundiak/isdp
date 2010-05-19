/* $Id: VDCmdRvItemi.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdannot/cmd/VDCmdRvItemi.I
 *
 * Description:
 *	Implementation file for VDCmdRvItem. 
 *	Methods :
 *			my_init
 *			sleep
 *			mouse
 *
 * Dependencies:
 *
 * Revision History:
 *
 *      12/14/94        R. Manem        Creation for OPE enhancements
 *	12/20/94	R. Manem	Send clean up to item manager at init
 *	06/15/95	tlb		Modify for new VDitem,VDitemMgr classes.
 *      07/20/95        Y.Zhu           Modify my_init. Add free_instance.
 *      08/10/95        Y.Zhu           Add functions for saving and getting 
 *                                      form location. 
 * -------------------------------------------------------------------*/


class implementation VDCmdRvItem;

#include <stdio.h>
#include <string.h>

#include "OMparameters.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "AS_status.h"
#include "asbox.h"

#include "grdpbmacros.h"
#include "grerr.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "vdandef.h"
#include "VDSannot.h"
#include "FI.h"
#include "VDmsg.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "VDitemNum.h"

#define VD_FP        me^^CEO.forms[0].form_ptr

struct  VDRvItemSetInfo
{
        OM_S_OBJECT_LINKAGE setList;
        IGRchar             setName[80];
} *setListName ;


/*
#define DEBUG
*/

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe


from	VDitemSet	import	VDgetSetInfo;
from	VDitem		import	VDgetItemInfo;
from	VDitemMgr	import	VDcleanUp;
from	VDdrwTblHdr     import  VDgetRowInfo, VDrowNoToGRid; 
from    VDdrwTblRow     import  VDgetItemNumber, VDgetParentObjectList;
from    VDdrwTblRow     import  VDisRowLinedOut;
from    VDdrwTbl        import  VDgetTotalNbOfRows;

extern GRclassid        OPP_VDdrwTblHdr_class_id;
/****************************************************************************
 Function VDRevindexcmp
  a sort function for item number  comparison on ascending
*****************************************************************************/
int  VDRevindexcmp( struct VDitemInfoNew *elm1,
             struct VDitemInfoNew *elm2 )
{
     return strcmp( elm1->itemStr, elm2->itemStr);
}
/****************************************************************************
 Function VDRevSetcmp
  a sort function for item set name comparison on ascending
*****************************************************************************/
int  VDRevSetcmp( struct VDRvItemSetInfo *elm1,
                  struct VDRvItemSetInfo *elm2 )
{
     return strcmp( elm1->setName, elm2->setName);
}
/****************************************************************************
 Function VDRevAllTableCmp
  a sort function for all table names comparison on ascending
*****************************************************************************/
int  VDRevAllTableCmp( struct VD_id_name *elm1,
                       struct VD_id_name *elm2 )
{
     return strcmp( elm1->tbl_name, elm2->tbl_name);
}
/****************************************************************************
 Function VDRevcomp_ItemNmrs
  a function used for help using comp_ItemNumbers sort function
*****************************************************************************/
static int VDRevcomp_ItemNmrs ( struct VDitemInfoNew  *in_row,       
  				struct VDitemInfoNew  *out_row )
{
  char           ItemNumIn      [VD_ITEMNUM_LEN],
                 ItemNumOut     [VD_ITEMNUM_LEN];

  SetProc( VDRevcomp_ItemNmrs ) ; Begin 
  ItemNumIn [0] = ItemNumOut[0] ; 

  strcpy( ItemNumIn, (*in_row).itemStr); 
  strcpy( ItemNumOut, (*out_row).itemStr); 

  End
  return ( VD_comp_ItemNumbers (ItemNumIn, ItemNumOut) );
}

/*+me
 -------------------------------------------------------------------------
  Public Message my_init

  Abstract
        Initializes the instance data.  

  Arguments
        long    *sts           O       Completion code

  Status
      status    OM_S_SUCCESS    success always

 -------------------------------------------------------------------------
-me*/

method my_init( long *sts )
{

    IGRint		i, j,k, 
			size = 0,
			len,
			maxTblLen = 0,
			totalNbItems,
			found,
			index,
			tblIndex = 0,
			*nextFreeIndex = NULL,
			indBuf[50],
			nret,
			nbSets = 0,
			nbItems;

    IGRlong		msg,
			status = OM_S_SUCCESS;

    IGRchar		*itemNo = NULL,
			*tblName = NULL;

    OM_S_CHANSELECT	to_items_chan;
    OM_S_OBJECT_LINKAGE	*setList = NULL,
			*itemList = NULL;
    struct GRid		mgrId;
    struct GRmd_env	mod_env;
    struct GRid		tblId;
    struct GRid		objId;
    IGRint              nbObj,  itemBlnNb, ind, ind0, sflag ;
    struct VDitemInfoNew * objIdItm = NULL;
    struct VDitemInfoNew * tmpItem = NULL; 
    struct VDRvItemSetInfo *setListName = NULL;
    IGRchar             *dirname        = { "drw_tables" },
                        *superClassName = { "VDdrwTbl" };
    IGRint              count = 0, ref_file = 1;
    struct VD_id_name   *IdName = NULL;
    IGRint              size1 = 0, size2 = 0;
    IGRchar             tablename[80];
    IGRint              setflag = FALSE;
    char                loc_sts_str[80], loc_sts_str1[80];
    IGRint              tenprc = 0, tenprc1 = 0;

    SetProc( VDCmdRvItem.my_init); Begin
    *sts = MSSUCC;

    /* give processing message it is useful for large file 12/20/95 */
    loc_sts_str[0] = '\0';
    strcpy( loc_sts_str, "Processing");

    __DBGpr_str(" loc_sts_str ", loc_sts_str);
  
    ex$message (  field         = ERROR_FIELD,
                  justification = CENTER_JUS,
                  in_buff       = loc_sts_str );

    /* initialize the instance data */
    me->windowId.objid = NULL_OBJID;
    me->highlightOpt = TRUE;
    me->fitObjOpt = FALSE;
    me->ballonTog = FALSE;
    me->curTblInSet = TRUE;

    strcpy( me->itemRegExpr, "*" );
    me->fitRatio = 1;
    me->fit3DObject = FALSE;
 
    FIg_set_state( VD_FP, VD_HLT_OPT_BTN, TRUE );
    FIg_set_state( VD_FP, VD_FIT_OBJ_LST, FALSE );
    FIg_set_state( VD_FP, VD_ITM_FIT_3DO, me->fit3DObject );
    FIfld_set_text( VD_FP, VD_ITM_EXPR_FLD, 0, 0, "*", FALSE );
    FIfld_set_value( VD_FP, VD_ITM_FIT_FLD, 0, 0, me->fitRatio, FALSE );
    
    me->nbTables = 0;

    /* init curTblName for store "" */
    status = om$vla_set_dimension( varray       = me->curTblName,
                                   size         = 1 );
    as$status( action = GOTO_VALUE, value = quit );

    size = om$dimension_of(varray = me->tables);
    for( i = 0; i < size; i++ ) 
           me->tables[i].tblName = NULL;

    /* get current module */
    size = sizeof( struct GRmd_env );
    status = gr$get_module_env(	msg	= &msg,
				sizbuf	= &size,
				buffer	= &mod_env,
				nret	= &nret );
    as$status( action = GOTO_VALUE, value = quit );

    __DBGpr_obj( " module_env id ", mod_env.md_id);

    /* get item manager id*/
    status = ex$get_super(	mod_id		= mod_env.md_id.objid,
				mod_osnum	= mod_env.md_id.osnum,
				super_name	= "ItemMgr",
				create		= 0,
				super_class	= "VDitemMgr",
				super_id	= &mgrId.objid,
				super_osnum	= &mgrId.osnum );
    if( !(status & 1) || (mgrId.objid == NULL_OBJID) )
    {
        /* UI_status( "No item sets exist" ); */
        goto NOBALLON;
    }
    __DBGpr_obj( " item manager id ", mgrId);
    
    /*
     * send a clean up message to the item manager.  Better to clean up
     * before using the the lists
     */
    status = om$send( msg      = message VDitemMgr.VDcleanUp( &msg ),
                      targetid = mgrId.objid,
                      targetos = mgrId.osnum );
    CheckRC( status, msg );

    /* 
     * get all the VDitemSet objects connected to the manager 
     */
    nbSets = 0;
    status = om$get_channel_count( objid        = mgrId.objid,
				   osnum	= mgrId.osnum,
                                   p_chanselect = &AS_to_comp,
                                   count        = (OMuint *) &nbSets );

    as$status( action = GOTO_VALUE, value = NOBALLON );

    if( !nbSets )
    {
        /* UI_status( "No item numbers exist" ); */
        goto NOBALLON;
    }

    __DBGpr_int( " nbSets ", nbSets );

    setList = _MALLOC(nbSets,  OM_S_OBJECT_LINKAGE );
    
    if( !setList )
    {
        printf( "\nERROR : Dynamic Allocation\n");
        goto quit;
    }

    status = om$get_channel_objects( objid              = mgrId.objid,
				     osnum		= mgrId.osnum,
                                     p_chanselect       = &AS_to_comp,
                                     size               = nbSets,
                                     list               = setList,
                                     count              = (OMuint *) &nbSets );

    as$status( action = GOTO_VALUE, value = NOBALLON);

    /* initialize the to_item channel */
    status = om$make_chanselect( channame       = "VDitemSet.to_items",
                                 p_chanselect   = &to_items_chan );
    as$status( action = GOTO_VALUE, value = quit );


    /* 
     * loop through each set object, to
     *        get the table name, insert table name in instance list
     *        initialize or increment the item count in the tableInfo structure
     *        update nbTables
     *        update count of total number of item objects
     */

    totalNbItems = 0;

    /* sort set according to tablename */
    if ( nbSets > 1) {
     setListName = NULL;
     setListName = _MALLOC( nbSets, struct VDRvItemSetInfo);

     for( j = 0 ; j < nbSets ; j++ ) {
        /* get the table name */
        status = om$send( msg   = message VDitemSet.VDgetSetInfo( &msg,
                                                                &tblName ),
                          targetid      = setList[j].S_objid,
                          targetos      = setList[j].osnum );
         as$status( action = GOTO_VALUE, value = quit );
    
         __DBGpr_str( " table name in set list :", tblName);

         setListName[j].setList = setList[j];
         setListName[j].setName[0] = '\0';
         strcpy (setListName[j].setName, tblName);

         _FREE(tblName);
         tblName = NULL;
     }
     /* sort setListName */
     if( nbSets > 1) {
          qsort( setListName, nbSets, sizeof(struct VDRvItemSetInfo),
                      (int (*)())VDRevSetcmp );
     }
     /*reset setList */
     for( j = 0 ; j < nbSets ; j++ ) {
         setList[j] = setListName[j].setList;
     }
              
  	_FREE(setListName);
        setListName = NULL;
    
    } /* if ( nbSets > 1) */
 
 
    for( i = 0 ; i < nbSets ; i++ )
    {
        /* get the table name */

        status = om$send( msg		= message VDitemSet.VDgetSetInfo(
								&msg,
								&tblName ),
			  targetid	= setList[i].S_objid,
			  targetos	= setList[i].osnum );
        CheckRC( status, msg );
/*        as$status(); */

        if( !(status&msg&1) ) continue;
 
        len = strlen( tblName );
        maxTblLen = ( len > maxTblLen ) ? len : maxTblLen;

        /* get the number of item objects on its channel */

        nbItems = 0;
        status = om$get_channel_count( objid        	= setList[i].S_objid,
				       osnum		= setList[i].osnum,
                                       p_chanselect 	= &to_items_chan,
                                       count        	= (OMuint *) &nbItems );

        as$status( action = GOTO_VALUE, value = quit );

        __DBGpr_int( " number of item in the set list :", nbItems);

        if( !nbItems )
        {
            _FREE( tblName );
            tblName = NULL;
            continue;
        }

        totalNbItems += nbItems;

        found = 0;
        for( j = 0 ; j < me->nbTables ; j++ )
        {
            if( !strcmp( tblName, me->tables[j].tblName ) )
            {
                found = 1;
                break;
            }
        }

        if( found )
        {
            /* simply update the count */

            me->tables[j].nbItems += nbItems;
        }
        else
        {
            /* must add a new table entry */

            size = om$dimension_of( varray = me->tables );
            if( (me->nbTables + 1) > size )
            {
                /* must resize the vla */

                size += 10;
                status = om$vla_set_dimension(  varray	= me->tables,
						size	= size );
                as$status( action = GOTO_VALUE, value = quit );
            }

            index = me->nbTables++;
            me->tables[index].tblName= NULL;
            me->tables[index].tblName= _MALLOC( (maxTblLen + 1), IGRchar);
 
            me->tables[index].nbItems = nbItems;
            strcpy(me->tables[index].tblName,tblName);
        }
            _FREE(tblName);
            tblName = NULL;
    }


    /* compute the startIndex for all item objects of each table */
    me->tables[0].startIndex = 0;
    for( i = 1 ; i < me->nbTables ; i++ )
        me->tables[i].startIndex = me->tables[i-1].nbItems + 
					me->tables[i-1].startIndex;

	#ifdef DEBUG
    	printf("LIST OF TABLE INFO (%d) :", me->nbTables );
    	for( i = 0 ; i < me->nbTables ; i++ )
        	printf("\n\t%s, %d, %d ", 	me->tables[i].tblName, 
						me->tables[i].nbItems,
						me->tables[i].startIndex );
	#endif

    /* 
     * initialize nextFreeIndex, ( points to the index in me->items array 
     * where the next item entry for that table can be made )
     */

    if( me->nbTables > 50 )
    {
        nextFreeIndex = _MALLOC(me->nbTables, IGRint );
        if( !nextFreeIndex )
        {
            UI_status("Error encountered");
            printf("\nERROR : Dynamic Allocation \n");
            goto quit;
        }
    }
    else
        nextFreeIndex = indBuf;

    for( i = 0 ; i < me->nbTables ; i++ )
        nextFreeIndex[i] = me->tables[i].startIndex;

    /* resize vla me->items */

    status = om$vla_set_dimension( varray	= me->items,
				   size		= totalNbItems );
    as$status( action = GOTO_VALUE, value = quit );

    /* initialize pointers */
    for( i = 0 ; i < totalNbItems ; i++ )
        me->items[i].itemStr = NULL;

    /* 
     * fill up the itemInfo vla
     */

    /* 
     * loop again, to get the item objects, 
     * store them at the proper location, update nextFreeIndex
     */

    for( i = 0 ; i < nbSets ; i++ )
    {
        /* get the table name */

        status = om$send( msg           = message VDitemSet.VDgetSetInfo(
                                                                &msg,
                                                                &tblName ),
                          targetid      = setList[i].S_objid,
                          targetos      = setList[i].osnum );
        as$status( action = GOTO_VALUE, value = quit );

        /* get the number of item objects */

        nbItems = 0;
        status = om$get_channel_count( objid            = setList[i].S_objid,
                                       osnum            = setList[i].osnum,
                                       p_chanselect     = &to_items_chan,
                                       count            = (OMuint *) &nbItems );

        as$status( action = GOTO_VALUE, value = quit );

        if( !nbItems )
        {
            _FREE( tblName );
            tblName  = NULL;
            continue;
        }


        /* find the table name match to get the index */

        found = 0;
        for( j = 0 ; j < me->nbTables ; j++ )
            if( !strcmp( me->tables[j].tblName, tblName ) )
            {
       	        tblIndex = j; 
                found = 1;
                break;
            }

        if( !found )
            goto quit;

        /* allocate space for list of item objects */

        _FREE( itemList );
        itemList = NULL;
        itemList = _MALLOC(nbItems, OM_S_OBJECT_LINKAGE);

        if( !itemList )
        {
            printf( "\nERROR : Dynamic Allocation\n");
            goto quit;
        }

        status = om$get_channel_objects( objid        = setList[i].S_objid,
                                         osnum        = setList[i].osnum,
                                         p_chanselect = &to_items_chan,
                                         size         = nbItems,
                                         list         = itemList,
                                         count        = (OMuint *) &nbItems );

        as$status( action = GOTO_VALUE, value = quit );
     
        tmpItem = NULL;
        tmpItem = _MALLOC( nbItems, struct VDitemInfoNew);

        for( j = 0 ; j < nbItems ; j++ ) { 
            /* get the item string */
            status = om$send( msg       = message VDitem.VDgetItemInfo(
                                                                &msg,
                                                                &itemNo,
                                                                NULL ),
                              targetid  = itemList[j].S_objid,
                              targetos  = itemList[j].osnum );
            as$status( action = GOTO_VALUE, value = quit );

            tmpItem[j].itemId.objid = itemList[j].S_objid;
            tmpItem[j].itemId.osnum = itemList[j].osnum;
            strcpy (tmpItem[j].itemStr, itemNo);
                 
	    _FREE(itemNo);
            itemNo = NULL;
        }
        /* sort tmpItem */
        if( nbItems > 1) {
           qsort ( (char *)tmpItem, nbItems, sizeof(struct VDitemInfoNew),
           (int (*)(const void *, const void *)) VDRevcomp_ItemNmrs );
        }

        for( j = 0 ; j < nbItems ; j++ )
        {
            index = nextFreeIndex[tblIndex]++;

            me->items[index].itemId.objid = tmpItem[j].itemId.objid;
            me->items[index].itemId.osnum = tmpItem[j].itemId.osnum;

            len = strlen( tmpItem[j].itemStr) + 1;

            me->items[index].itemStr=_MALLOC(len, IGRchar);

            if( !me->items[index].itemStr )
            {
                printf( "\nERROR : Dynamic Allocation\n");
                goto quit;
            }

            strcpy (me->items[index].itemStr, tmpItem[j].itemStr);
        }

            _FREE(tblName);
            tblName = NULL;

            _FREE(tmpItem);
            tmpItem = NULL;
    } /* for i */ 

    __DBGpr_com( "LIST OF ITEM INFO" );

    for( i = 0 ; i < totalNbItems ; i++ ){

        __DBGpr_obj( " Item Id ", me->items[i].itemId );
        __DBGpr_str( " Item No.", me->items[i].itemStr);

    }
    itemBlnNb = om$dimension_of ( varray = me->items );    

    /* 
     * add function to get all objects with item number in 
     * the the tables, the tables should exist in the item set (y.zhu 7/18/95)
     */

     size = om$dimension_of ( varray = me->tableNoBln );   

     if(me->nbTables > size ) { 
       status = om$vla_set_dimension( varray       = me->tableNoBln,
                                      size         = me->nbTables);
     }

     ind = 0;

     for( j = 0 ; j < me->nbTables ; j++ ) {

        loc_sts_str[0] = '\0';
        strcpy( loc_sts_str, "Processing");
        /* get table ID from table name */
        status = 
        VDitem_get_tblID_from_tblName(&msg,me->tables[j].tblName, &tblId);
        CheckRC( status, msg );

        if(!(status&msg&1)) continue; 
      
        /* 
         * get row id from table id and 
         * get objects with item naumber from row id 
         */ 

        nbObj = 0;
        status = 
        om$send(  msg  = message VDCmdRvItem.VDget_itemNos_objIds( 
                                             &msg, 
                                             tblId,
                                             &nbObj,
                                             &objIdItm ),
			mode            = OM_e_wrt_message,
                        targetid= my_id );
        CheckRC( status, msg );
        if(!(status&msg&1)) continue; 

        /* sort objIdItm */
        if( nbObj > 1) {
           qsort ( (char *)objIdItm, nbObj, sizeof(struct VDitemInfoNew),
           (int (*)(const void *, const void *)) VDRevcomp_ItemNmrs );
        }

        /*
         * set a table info which includes table name, object number, start
         * index
         */
        strcpy( me->tableNoBln[j].tblName,  me->tables[j].tblName );
        me->tableNoBln[j].startIndex = ind;

        /* get objects which have item number without ballon in same table*/
        ind0 = 0;
        tenprc = nbObj/10 + 1;
        for( k = 0 ; k < nbObj ; k++ ) {

/*          if ( IGEstop() ) break;  */

          /* display status string */
          if ( (k/tenprc)*tenprc == k) {
            strcat ( loc_sts_str, "." );
            ex$message (  field           = ERROR_FIELD,
                        justification   = CENTER_JUS,
                        in_buff         = loc_sts_str );
          }

          sflag = FALSE;

/*          UI_status(" Processing 54 "); */

          tenprc1 = me->tables[j].nbItems/10 + 1;
          loc_sts_str1[0] = '\0';
          strcpy( loc_sts_str1, "Processing");

          for( i = me->tables[j].startIndex ; 
               i < me->tables[j].startIndex + me->tables[j].nbItems ; i++ ) {

              if ( (i/tenprc1)*tenprc1 == i) {
               strcat ( loc_sts_str1, "." );
               ex$message (  field           = ERROR_FIELD,
                        justification   = CENTER_JUS,
                        in_buff         = loc_sts_str1 );
              }

            /* get object id. the object has item number me->items[i].itemStr */
            objId.objid = NULL_OBJID;
            status = VDitem_get_objId_from_itemId(
  			&msg, 
  			me->items[i].itemId, 
  			&objId);   
       	    CheckRC( status, msg );

            if(!strcmp(objIdItm[k].itemStr, me->items[i].itemStr) &&
                objIdItm[k].itemId.objid == objId.objid && 
                objIdItm[k].itemId.osnum == objId.osnum ){
                sflag = TRUE;
                break;
            }
          }
          if( !sflag) {
           ind = ind + 1;
           status = om$vla_set_dimension( varray = me->objItmNoBln,
                                          size   = ind);
           me->objItmNoBln[ind-1] = objIdItm[k];
           ind0 = ind0 + 1;
          }
        } /* for k */
 
        me->tableNoBln[j].nbItems = ind0;

        _FREE ( objIdItm );
        objIdItm = NULL;
    }/* for j */


    __DBGpr_com( "With Ballons");

NOBALLON:

    /*   
     *  Get  all table names from :designfile:usr:drw_tables
     */
    status =
    VD_get_tableName ( sts, dirname, superClassName, &count, ref_file, &IdName);
    as$status( action = GOTO_VALUE, value = quit );

    __DBGpr_int( "No. of table ", count);

    /* sort IdName according name */
    if( count > 1) {
          qsort( IdName, count, sizeof(struct VD_id_name),
                      (int (*)())VDRevAllTableCmp );
    }
 
    /* set me->tableIdName( only  include those with item number ) */ 

    size = om$dimension_of( varray  =  me->tableIdName);  

    for( i = 0; i< count; i++ ) {

     	tablename[0] = '\0';
    	strcat( tablename, IdName[i].tbl_name);
    	strcat( tablename, "[");
    	strcat( tablename, IdName[i].deg_file.fname);
    	strcat( tablename, "]");

        len = strlen(  tablename );
        maxTblLen = ( len > maxTblLen ) ? len : maxTblLen;

        status =
        VDitem_get_tblID_from_tblName(&msg,tablename, &tblId);
            CheckRC( status, msg );
/*        as$status(); */

        if(!(status&msg&1)) continue;

        __DBGpr_obj( "table objects :", tblId);

        /*
         * get row id from table id and
         * get objects with item naumber from row id
         */

        nbObj = 0;
        status =
        om$send(  msg  = message VDCmdRvItem.VDget_itemNos_objIds(
                                             &msg,
                                             tblId,
                                             &nbObj,
                                             &objIdItm ),
                        mode            = OM_e_wrt_message,
                        targetid= my_id );
            CheckRC( status, msg );
        if(!(status&msg&1)) continue;

        if(!nbObj)   continue; /* only keep the table with item number */
    
        __DBGpr_int( " No of objects :", nbObj);

        status = om$vla_set_dimension(  varray  = me->tableIdName,
                                        size    = size + 1);
    
        as$status( action = GOTO_VALUE, value = quit );

        me->tableIdName[size] = IdName[i];

        size++;

           _FREE ( objIdItm );
           objIdItm = NULL;

    } 

    /*  get table list: not in  set list */

    size = om$dimension_of( varray  =  me->tableNoSet);  
    size1 = om$dimension_of( varray  =  me->tableIdName);  
    size2 = om$dimension_of( varray  =  me->tables);  

    __DBGpr_int( " No of tableIdName:", size1);
    __DBGpr_int( " No of tables:", size2);

    for( i = 0; i< size1; i++ ) {

       tablename[0] = '\0';
       strcat( tablename, me->tableIdName[i].tbl_name);
       strcat( tablename, "[");
       strcat( tablename, me->tableIdName[i].deg_file.fname);
       strcat( tablename, "]");

       setflag = FALSE;

      for( j = 0; j< size2; j++ ) {

       if( !me->tables[j].tblName) continue; 

       if ( !strcmp(tablename, me->tables[j].tblName)) {

            setflag = TRUE;
            break;
       }
      }
      if( !setflag ) {
 
            status = om$vla_set_dimension(  varray  = me->tableNoSet,
                                            size    = size + 1 );

            strcpy( me->tableNoSet[size].tblName, tablename);
            size++;
      }
    }

    /* get objects with item in no set table */  
    ind = 0;

    size = om$dimension_of( varray  =  me->tableNoSet);  

    size1 = om$dimension_of( varray  =  me->objItmNoBlnNoSet);  

    __DBGpr_int( " No of tableNoSet:", size);

    for( j = 0 ; j < size ; j++ ) {

        /* get table ID from table name */

        status =
        VDitem_get_tblID_from_tblName(&msg,me->tableNoSet[j].tblName, &tblId);
/*        as$status(); */
                    CheckRC( status, msg );
        if(!(status&msg&1)) continue;

        /*
         * get row id from table id and
         * get objects with item naumber from row id
         */

        nbObj = 0;
        status =
        om$send(  msg  = message VDCmdRvItem.VDget_itemNos_objIds(
                                             &msg,
                                             tblId,
                                             &nbObj,
                                             &objIdItm ),
                        mode            = OM_e_wrt_message,
                        targetid= my_id );
            CheckRC( status, msg );
/*        as$status(); */
        if(!(status&msg&1)) continue;
        
        if(!nbObj) continue;

        /* sort objIdItm */
        if( nbObj > 1) {
           qsort ( (char *)objIdItm, nbObj, sizeof(struct VDitemInfoNew),
           (int (*)(const void *, const void *)) VDRevcomp_ItemNmrs );
        }
        /*
         * set a table info which includes table name, object number, start
         * index
         */

        me->tableNoSet[j].startIndex = size1;

        me->tableNoSet[j].nbItems = nbObj;

        status = om$vla_set_dimension( varray = me->objItmNoBlnNoSet,
                                       size   = size1 + nbObj);
        for ( k = 0; k < nbObj; k++ ) {
            me->objItmNoBlnNoSet[size1 + k] = objIdItm[k];
        }

        _FREE ( objIdItm );
        objIdItm = NULL;
        
	size1 = size1 + nbObj;
    }

    /* initialize current table name, and current index */

    status = om$vla_set_dimension( varray       = me->curTblName,
                                   size         = maxTblLen+1 );
    as$status( action = GOTO_VALUE, value = quit );

    if( me->nbTables ) 
    	strcpy( me->curTblName, me->tables[0].tblName );
    else  
    	strcpy( me->curTblName, "" );

    me->curTblIndex = 0;

    FIfld_set_text( VD_FP, VD_TBL_NAME_FLD, 0, 0,
                        (unsigned char *)me->curTblName, FALSE );

    /* update the associative list of table names */

    FIfld_set_list_num_rows( VD_FP, VD_TBL_NAME_FLD, 0, me->nbTables );

    for( i = 0 ; i < me->nbTables ; i++ )
        VDfld_set_list_text( VD_FP, VD_TBL_NAME_FLD, i, 0,
                                (unsigned char *)me->tables[i].tblName, FALSE );

    /* update the list of item numbers */

    status = om$send(   msg     = message VDCmdRvItem.VDupdateItemList( sts ),
                        mode    = OM_e_wrt_message,
                        targetid= my_id );
    as$status( action = GOTO_VALUE, value = quit );

    __DBGpr_int( " maxTblLen+1:", maxTblLen+1);
    __DBGpr_int( " No of tables", me->nbTables);
    __DBGpr_int( " No of objItmNoBlnNoSet:", size1);
    __DBGpr_str( " curTblName:", me->curTblName);

quit :

    if( nextFreeIndex != indBuf ) _FREE( nextFreeIndex );
    _FREE( setList );
    _FREE( itemList );
    _FREE(itemNo);
    _FREE(tblName);
    _FREE(tmpItem);
    _FREE(setListName);
    _FREE ( objIdItm );
    _FREE( IdName ); 

    End 
    return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        sleep from super_cmd

  Abstract

  Arguments
	

 -------------------------------------------------------------------------
-mo*/

method sleep( int pos )
{
    IGRlong	sts,
    		status = OM_S_SUCCESS;

    status = om$send(	msg 		= message CEO_LOCATE.sleep(pos),
			mode 		= OM_e_wrt_message,
			targetid 	= my_id );

    as$status( action = GOTO_VALUE, value = quit );

    dp$erase_hilite( msg = &sts );

    UI_prompt("");
    UI_message("");
    UI_status("");

     
quit :
    return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        mouse from VDS_LOCATE

  Abstract
        Based on the mouse position on the user attributes form
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
                    case VD_ITM_EXPR_FLD :
                        m = VD_I_regExpForItem ; break ;

                    case VD_HLT_OPT_BTN :
                        m = VD_I_hltOption ; break ;

                    case VD_ITM_LIST_FLD :
                        m = VD_I_listOfItmNos ; break ;

                    case VD_TBL_NAME_FLD :
                        m = VD_I_nameOfCurTbl ; break ;

                    case VD_FIT_OBJ_LST :
                        m = VD_I_optToFitObj ; break ;

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
/*+mo
 -------------------------------------------------------------------------
  Message
       VDget_itemNos_objIds

  Abstract
       This massage is used to get objects with item numbers

  Arguments
      long              *msg      O     Completion code

  Return status/code
      status = OM_S_SUCCESS         if success

  Note : free objIdItm at calling function 
 -------------------------------------------------------------------------
-mo*/
method VDget_itemNos_objIds ( IGRlong *msg;
                              struct GRid tblId;
                              IGRint  *nbObj;
                              struct VDitemInfoNew **objIdItm)
{
IGRlong       	     status = OM_S_SUCCESS;
struct GRid   	     *rowId = NULL;
IGRint               i,j,k;
struct VDitemInfoNew *locObjIdItm = NULL;
struct GRobj_env     *locObjs = NULL;
IGRint               totalNbRows = 0;
IGRint               NbTblHdr = 0, startRow = 0, nbRows = 0, indx = 0;         
struct GRid   	     *TblHdr = NULL;
struct GRid   	     *rowItemId = NULL;
IGRint               rowItemNb = 0,num, numberObj; 
IGRchar              **rowItemNum = NULL;
IGRshort             isLinedOut;

    SetProc(  VDget_itemNos_objIds ); Begin
    *msg = MSSUCC;

    /* get total number of rows in this table */
 
    status =
    om$send (   msg      = message VDdrwTbl.VDgetTotalNbOfRows (msg,
                                                                &totalNbRows),
                targetid = tblId.objid,
                targetos = tblId.osnum,
                senderid = my_id );
    if ( ! (status & *msg & 1) ) {
          *msg = MSFAIL;
          goto wrapup;
    }

    if ( !totalNbRows ) {
          *msg = MSFAIL;
          status = OM_E_ABORT;
          goto wrapup;
    }

    __DBGpr_int(" total number rows ", totalNbRows);

    /* allocate rowId */
    rowId = _MALLOC( totalNbRows, struct GRid ); 
    if( !rowId ) {
         *msg = MSFAIL;
          goto wrapup;
    }
 
    /* get tbl headr number and ids from chan of Class */
    status = 
    VDGetGridsFromChan_of_Class ( msg, tblId, &AS_to_comp,
                            OPP_VDdrwTblHdr_class_id, &NbTblHdr, &TblHdr );
    as$status();
    if( !NbTblHdr && !(status&*msg&1)) {
          *msg = MSFAIL;
          goto wrapup;
    }

    __DBGpr_int(" total number rows ", NbTblHdr);
    __DBGpr_objlist(" table hdr ids ", NbTblHdr, TblHdr);

    for ( i=0; i< NbTblHdr; i++ )
    {
      status = 
      om$send (  msg  = message VDdrwTblHdr.VDgetRowInfo (msg, 
                                                          &nbRows, 
                                                          &startRow),
                        targetid = TblHdr[i].objid,
                        targetos = TblHdr[i].osnum,
                        senderid = my_id );
      if ( ! (status & *msg & 1) ) {
        *msg = MSFAIL;
        goto wrapup;
      }

      __DBGpr_int(" the table hdr:  ", i);
      __DBGpr_int(" number rows in this table hdr ", nbRows);

      for ( j = startRow; j < nbRows + startRow; j++ )
      {
        struct GRid     tmp_id;
        status = om$send ( msg = message VDdrwTblHdr.VDrowNoToGRid (msg, 
                                                                 j, 
                                                                 &tmp_id),
                        targetid = TblHdr[i].objid,
                        targetos = TblHdr[i].osnum,
                        senderid = my_id );

        if ( ! (status & *msg & 1) )
        {
          *msg = MSFAIL;
          goto wrapup;
        }

        rowId[indx] = tmp_id;
      
        __DBGpr_obj(" row Id ", rowId[indx]);
        indx++;
        __DBGpr_int(" index ", indx);

        if ( indx > totalNbRows )
        {
          
          printf (" *** Not enough memory allocated ***\n" );
          status = OM_E_ABORT;
          *msg = MSFAIL;
          goto wrapup;
        }
      }
    }  /* for i */

    indx = 0;

    for ( i=0; i < totalNbRows; i++ )
    {
      char      ItemNum[40];
      IGRint    itemsz = 0;
      ItemNum[0] = '\0';
     
      /* check if the row is line out */
      status =
      _VD_SEND_OBJ( rowId[i], VDdrwTblRow.VDisRowLinedOut(msg,
                                              &isLinedOut ));

      if(!(status&*msg&1)) {
       status = OM_E_ABORT;
       goto wrapup;
      }

      if( isLinedOut == 1) 
        continue;
 
      status = 
      om$send (   msg      = message VDdrwTblRow.VDgetItemNumber ( msg, 
                                                                   &itemsz, 
                                                                   ItemNum ),
                        senderid = my_id,
                        targetid = rowId[i].objid,
                        targetos = rowId[i].osnum );
      if ( status & *msg & 1 )
      {
        if ( ItemNum[0] != '\0' ) {
          indx++;
        }
      }
    }

    rowItemNb = indx;
    /* set row id with itemNum into rowItemId */
    rowItemId = _MALLOC(rowItemNb,struct GRid);
    if ( !VDmalloc_str_list ( &rowItemNum, rowItemNb, 40 ) )
                {
                        if ( rowItemNb )
                            printf(" no memory allocated \n");
                        /* 5/6/96 */
                        status = OM_E_ABORT;
                        goto wrapup;
                }

    indx = 0;
    for ( i=0; i < totalNbRows; i++ )
    {
      char      ItemNum[40];
      IGRint    itemsz = 0;
      ItemNum[0] = '\0';

      /* check if the row is line out */
      status =
      _VD_SEND_OBJ( rowId[i], VDdrwTblRow.VDisRowLinedOut(msg,
                                              &isLinedOut ));

      if(!(status&*msg&1)) {
       status = OM_E_ABORT;
       goto wrapup;
      }

      if( isLinedOut == 1)
        continue;

      status =
      om$send (   msg      = message VDdrwTblRow.VDgetItemNumber ( msg,
                                                                   &itemsz,
                                                                   ItemNum ),
                        senderid = my_id,
                        targetid = rowId[i].objid,
                        targetos = rowId[i].osnum );
      if ( status & *msg & 1 )
      {
        if ( ItemNum[0] != '\0' ) {
          rowItemId[indx] = rowId[i];
          rowItemNum[indx][0] = '\0';
          strcpy(rowItemNum[indx], ItemNum);
          indx++;
        }
      }
    }

    /* get total objects in the row with item number */
    num = 0;
    for ( i=0; i < rowItemNb; i++ ) {
       numberObj = 0;
       status =
       om$send( msg = message VDdrwTblRow.VDgetParentObjectList( 
                                                       msg,
                                                       &numberObj,
                                                       NULL ),
			senderid = my_id,
                        targetid = rowItemId[i].objid,
                        targetos = rowItemId[i].osnum );
       CheckRC( status, *msg );

       if( !numberObj ) continue;

       /*   get locObjs   */
       locObjs = NULL;
       locObjs = _MALLOC(numberObj, struct GRobj_env);

       if( locObjIdItm )
          locObjIdItm = _REALLOC(locObjIdItm, (num + numberObj), 
                                             struct VDitemInfoNew); 
       else 
          locObjIdItm = _MALLOC( (num + numberObj),struct VDitemInfoNew); 

       status =
       om$send( msg = message VDdrwTblRow.VDgetParentObjectList(
                                                       msg,
                                                       &numberObj,
                                                       locObjs ),
                        senderid = my_id,
                        targetid = rowItemId[i].objid,
                        targetos = rowItemId[i].osnum );
  
       for( k = num; k < num + numberObj; k++) {
               locObjIdItm[k].itemId = locObjs[k - num].obj_id;
               locObjIdItm[k].itemStr[0] = '\0';
               strcpy(locObjIdItm[k].itemStr, rowItemNum[i]);
       }

       num = num + numberObj;
       _FREE(locObjs);
       locObjs = NULL;

    }  /* for */

    /* set object with row number */
    *nbObj = num;
    (*objIdItm) = _MALLOC( (*nbObj), struct VDitemInfoNew);
    for ( i = 0; i < (*nbObj); i++) {
              (*objIdItm)[i].itemId = locObjIdItm[i].itemId;
              (*objIdItm)[i].itemStr[0] = '\0';
              strcpy((*objIdItm)[i].itemStr,locObjIdItm[i].itemStr);
    }

wrapup:
  _FREE(rowId);
  _FREE(rowItemId);
  _FREE(locObjIdItm);
  _FREE(locObjs);
  VDfree_str_list ( rowItemNum, rowItemNb);
  _FREE( TblHdr );
  End
  return status;
 
}
/*-----------------------------------------------------------------
 methed  for free instance
------------------------------------------------------------------*/ 

method free_instance( long *sts )
{
IGRint num0,num1,i;

    num0 = om$dimension_of( varray = me->tables );    
    num1 = om$dimension_of( varray = me->items );    
   
    for(i = 0; i < num0; i++) { 
       _FREE(me->tables[i].tblName);
    } 
    for(i = 0; i < num1; i++) { 
       _FREE(me->items[i].itemStr);
    } 

    *sts = MSSUCC;
    return OM_S_SUCCESS;
}
/*-----------------------------------------------------------------
 methed  for save form location
------------------------------------------------------------------*/
method  VDsave_form_pos(long *sts)
{
        FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

        *sts = MSSUCC;
        return OM_S_SUCCESS;
}
/*-----------------------------------------------------------------
 methed  for get form location
------------------------------------------------------------------*/
method  VDset_form_pos(long *sts)
{
        if(x_pos != -1 && y_pos != -1)
                FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

        *sts = MSSUCC;
        return OM_S_SUCCESS;
}

end implementation VDCmdRvItem;
