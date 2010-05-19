/* $Id $  */
/*************************************************************************
 * I/VDS
 *
 * File:        $VDS/vdutil/VDDbParams.I
 *
 * Description:
 *    This file contains the following functions :
 *                  - VDDbreviewParams
 *                  - VDDbgetParams
 *                  - VDDbgetParameters
 *
 * Revision History:
 *	$Log $
 *                                             
 * History:
 *      12/19/97        Z. Yuhang       Creation
 **************************************************************************/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include "igetypedef.h"     /* these two needed for gr.h, order of includes */
#include "igrtypedef.h"     /* important, also needed for IGRint ...        */
#include "gr.h"             /* struct GRid, GRmd_env  ..                    */
#include "OMprimitives.h"   /* om$send                                      */
#include "OMmacros.h"       /* indirectly for OM_S_SUCCESS, OM_E_NODYNMEM   */
#include "msdef.h"          /* MSSUCC, MSFAIL                               */
#include "madef.h"          /* MAIDMX                               */
#include "DIdef.h"          /* DI_PATH_MAX                                  */
#include "PDUuser.h"
#include "parametric.h"     /* ret_struct,  macro_generic ..                */
#include "PDUerror.h"
#include "ACattrib.h"       /* AC_ATTRIB_TEXT ..                            */
#include "ACrg_collect.h"   /* struct ACrg_coll                             */
#include "exmacros.h"      
#include "vdparmacros.h"      
#include "vdbmacros.h"      
#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
#include "VDSris_siz.h"
#include "VDScheckdef.h"
#include "VDScheckin.h"
#include "ACdb_info.h"
#include "AS_status.h"      /* as$status                                    */

#define SUCCESS 1

/*
 * Exception Objects.
 */


/*+fe
--------------------------------------------------------------------------
  Function VDDbreviewParams

  Macro Name
      vd$db_review_params

  Abstract
      Given a list of attribute names, this function returns
      their values in the specified component.
      The default implementation at VDSroot level, is to simply invoke the
      vd$review_parameters macro.

  Arguments
      IGRlong           *sts         O     Completion code
      struct GRid       *object      I     Specified component
      struct GRmd_env   *md_env      I     Module environment of the object
      IGRint            count        I     Number of specified names
      IGRchar           *table_name  I     Database table
      struct ACrg_coll  *plist      I/O    Array of parameters

Status/Return Code
      MSSUCC          : if success
      MSFAIL          : some error

-------------------------------------------------------------------------
-fe*/
IGRint	VDDbreviewParams ( sts, object, md_env, count, table_name, plist)
IGRlong 	 *sts;		/* Completion code 		*/
struct GRid	 *object;	/* Specified component 		*/
struct GRmd_env	 *md_env;	/* Module environment of the object */
IGRint		 count;		/* Number of specified names	*/
IGRchar		 *table_name;	/* Database table names		*/
struct ACrg_coll *plist;	/* Array of parameters		*/
{
IGRlong 		status = OM_S_SUCCESS;
char            	**buffer = NULL;
char                    value[MAXWORD];
struct table_attr       pdc_attr;
struct GRmd_env         mod_env;
struct ACobj_info_1     obj_info_1;
struct vdscatalog       *VdsCatalogs = NULL;
char                    dynamic_table[MAXWORD];
char                    select[MAXWORD];
char                    where[MAXWORD];
int                     nbCatalogs, i, nbrows, index, j;
char                    designRep[20];
char                    key[20];
char                    temp[MAXWORD];
int                     startIndex;


    SetProc( VDDbreviewParams ); Begin

    *sts = MSSUCC ;
    dynamic_table[0] = '\0';

    startIndex = VDATSTART;    // for tree or production table

    __DBGpr_com ("VDSverify_login");
    if( VDSverify_login() != PDM_S_SUCCESS )
    {
       UI_status( "User not logged in to Database" );
       *sts = MSFAIL;
       goto wrapup;
    }

    __DBGpr_com ("VdsRisAttach");
    if( VdsRisAttach() != SUCCESS) {
       printf(" Error in VdsRisAttach\n");
       *sts = MSFAIL;
       goto wrapup;
    }

    if( object->objid == NULL_OBJID ){
       printf(" No object is defined\n");
       *sts = MSFAIL;
       goto wrapup;
    }

    /* Initialization */
    pdc_attr.type                 = 0;
    pdc_attr.feet_list            = NULL;
    pdc_attr.format_list          = NULL;
    pdc_attr.table_name[0]        = '\0';

    /* for dynamic Posting Table (default) */
    if ( table_name == NULL ) {
        startIndex = VDDYSTART;    // for dynamic table
        ex$get_cur_mod( id    = &mod_env.md_id.objid,
                        osnum = &mod_env.md_id.osnum );

        mod_env.md_env.matrix_type = MAIDMX; /* Used for ACgive_structure */
        MAidmx( sts, mod_env.md_env.matrix );
        status = VdsGet_db_info( object, &obj_info_1, 1 );

        __DBGpr_com("VDReadVdsCatalogs");
        status = VDReadVdsCatalogs( &nbCatalogs, &VdsCatalogs );

        strcpy( designRep, REP_MODEL );
        strcpy( key, REG_CHECKIN );

        __DBGpr_com("VDGetDynTableName");
        status = VDGetDynTableName( obj_info_1.quantity, *object, mod_env,
                           key, designRep, nbCatalogs, VdsCatalogs,
                           dynamic_table );

        if( status == VDS_E_DYNAMIC_TABLE_NOT_FOUND||(dynamic_table == NULL) )
        {
                *sts = MSFAIL;
                goto wrapup;
        }

        strcpy( pdc_attr.table_name, dynamic_table );
    }
    else {
        strcpy( pdc_attr.table_name, table_name );
    }

    __DBGpr_str("table name", pdc_attr.table_name );
    /* get all column name and type */
    status = vdb$RetrieveAttributes(
                                table_name = pdc_attr.table_name /*pdc_table*/,
                                p_num      = &pdc_attr.nb_feet,
                                p_attr     = &pdc_attr.feet_list,
                                p_type     = &pdc_attr.format_list );

    if( status != SUCCESS ) {
        *sts = MSFAIL;
        goto wrapup;
    }
    __DBGpr_int("nb_feet", pdc_attr.nb_feet);

    if( !plist || !count )
    {
        *sts = MSSUCC;
        goto wrapup;
    }

    for( i = 0; i < count; i ++ ) {
	plist[i].desc.type = AC_ATTRIB_TYPE_NOT_DEF;
    }

    for( i = 0; i < count; i ++ ) {
      if ( plist[i].desc.type != AC_ATTRIB_TYPE_NOT_DEF )
	continue;
      
      /* check if the plist[i].name is in the feet_list */
      index = -1;
      for(j = startIndex; j < pdc_attr.nb_feet; j++ ) {
         if( strcmp( plist[i].name, pdc_attr.feet_list[j]) == 0)
           index = j; 
      } 

      if (index < 0 ) {
        sprintf(temp, "Can not get atrribute for %s", plist[i].name);
        __DBGpr_com ( temp);
	continue;
      }
	
      /* select row */
      sprintf ( where, "comp_seqno = %d", object->objid );
      __DBGpr_str ("where", where);

      strcpy ( select, plist[i].name);

      __DBGpr_str ("select", select);

      status =
      vdb$RisSelect( select     = select,
                     table_name = pdc_attr.table_name,
                     where      = where,
                     numselect  = 1,
                     p_numrows  = &nbrows,
                     p_buffer   = &buffer);

      if( !(status & 1) )  {
        sprintf(temp, "Can not get atrribute for %s", plist[i].name);
        __DBGpr_com ( temp);
	continue;
      }

      __DBGpr_int("nbrows", nbrows);

      if(!strcmp(pdc_attr.format_list[index], "1"))// for char */
      {
         plist[i].desc.type = AC_ATTRIB_TEXT;
         vdb$RisExtractValue (  nbrows    	= nbrows,
                                nbcolumns	= 1,
                                buffer		= buffer,
                                row		= 0,
                                column		= 0,
                                value 		= value)
         strcpy( plist[i].desc.value.att_txt, value);
      }
      else {   // for value */
         plist[i].desc.type = AC_ATTRIB_DOUBLE;
         vdb$RisExtractValue (  nbrows    	= nbrows,
                                nbcolumns	= 1,
                                buffer		= buffer,
                                row		= 0,
                                column		= 0,
                                value 		= value)
         plist[i].desc.value.att_exp = atof(value);
      }       
    }

wrapup :

    vdb$RisFreeBuffer( buffer = buffer, size = 1*nbrows );


    if( pdc_attr.feet_list != NULL ) {
        for( i = 0; i < pdc_attr.nb_feet; ++i ) {
                if( pdc_attr.feet_list[i] != NULL )
                _FREE( pdc_attr.feet_list[i] );

                if( pdc_attr.format_list[i] != NULL )
                _FREE( pdc_attr.format_list[i] ) ;
        }
        _FREE( pdc_attr.feet_list );
        _FREE( pdc_attr.format_list );
    }

    _FREE(VdsCatalogs);

    End
    return status;
}

/*+fe
--------------------------------------------------------------------------
  Function VDDbget_parameters

  Macro Name
      vd$db_get_parameters

  Abstract
      The macro is used to get all the parameters and their values
      of any given object from a dynamic table. The table can be from
      the following types:
                - Dynamic Posting Table (default)
                - Assembly Tree posting Table
                _ User Defined Production Table
      This process will interact with the database only.
      Normally the macro would be called twice; once to get the number
      of parameters, and the second time, to get the list of parameters
      and their values.

  Arguments
      <Data Type>       <Name>  <I/O>   <Description>

      IGRlong          *sts         O     return code
      struct GRid      *object      I     GRid of the object
      IGRchar          *table_name  I     table name .  
      GRmd_env         *md_env      I     module environment of the object
      struct ACrg_coll *plist       O     Pass NULL if list of parameters 
                                          not needed; otherwise pass pointer 
                                          to an ACrg_coll structure.  Memory 
                                          has to be allocated before calling 
                                          the function.
      IGRint           size         I     Size of the plist passed
      IGRint           *count       O     No of parameters returned. 
                                          If plist = NULL, count is the total 
                                          number of parameters for the object

  Returns
      MSSUCC          : if success
      MSFAIL          : some error
----------------------------------------------------------------------------
-fe*/
IGRint VDDbget_parameters( IGRlong           *sts,
                           struct GRid       *object,
                           IGRchar           *table_name,
                           struct GRmd_env   *md_env,
                           struct ACrg_coll  *plist,
                           IGRint            size,
                           IGRint            *count)
{
int			status;
char            	**buffer = NULL;
char            	value[MAXWORD];
struct table_attr       pdc_attr;
struct GRmd_env 	mod_env;
struct ACobj_info_1 	obj_info_1;
struct vdscatalog 	*VdsCatalogs = NULL;
char 			dynamic_table[MAXWORD];
int  			nbCatalogs, i, nbrows;
char                    where[MAXWORD];
char                    select[MAXWORD];
char                    designRep[20];
char                    key[20];
char                    temp[MAXWORD];
int                     startIndex, ii;


    SetProc (  VDDbget_parameters ); Begin

    /* 
     * function is called recursively; so initialize some variables the first
     * time it is called (by vd$get_parameters macro)
     */

    *sts = MSSUCC ;
    dynamic_table[0] = '\0';
    startIndex = VDATSTART;    // for tree or production table

    __DBGpr_com ("VDSverify_login");
    if( VDSverify_login() != PDM_S_SUCCESS )
    {
       UI_status( "User not logged in to Database" );
       *sts = MSFAIL;
       goto wrapup;
    }

    __DBGpr_com ("VdsRisAttach");
    if( VdsRisAttach() != SUCCESS) { 
       // printf(" Error in VdsRisAttach\n");
       *sts = MSFAIL;
       goto wrapup;
    }

    if( object->objid == NULL_OBJID ){
       printf(" No object is defined\n");
       *sts = MSFAIL;
       goto wrapup;
    }

    /* Initialization */
    pdc_attr.type                 = 0;
    pdc_attr.feet_list            = NULL;
    pdc_attr.format_list          = NULL;
    pdc_attr.table_name[0]        = '\0';

    /* for dynamic Posting Table (default) */  
    if ( table_name == NULL ) {
        startIndex = VDDYSTART;    // for dynamic table
        ex$get_cur_mod( id    = &mod_env.md_id.objid,
                        osnum = &mod_env.md_id.osnum );

        mod_env.md_env.matrix_type = MAIDMX; /* Used for ACgive_structure */
        MAidmx( sts, mod_env.md_env.matrix );

     	status = VdsGet_db_info( object, &obj_info_1, 1 );

     	__DBGpr_com("VDReadVdsCatalogs");
     	status = VDReadVdsCatalogs( &nbCatalogs, &VdsCatalogs );

  	strcpy( designRep, REP_MODEL );
  	strcpy( key, REG_CHECKIN );

     	__DBGpr_com("VDGetDynTableName");
     	status = VDGetDynTableName( obj_info_1.quantity, *object, mod_env,
                           key, designRep, nbCatalogs, VdsCatalogs,
                           dynamic_table );

     	if( status == VDS_E_DYNAMIC_TABLE_NOT_FOUND||(dynamic_table == NULL) )
        {
        	*sts = MSFAIL;
         	goto wrapup;
        }

        strcpy( pdc_attr.table_name, dynamic_table );
    }
    else {
        __DBGpr_str( "input table name", table_name);
        strcpy( pdc_attr.table_name, table_name );
    }

    __DBGpr_str("table name", pdc_attr.table_name );
    /* get all column name and type */
    status = vdb$RetrieveAttributes( 
			        table_name = pdc_attr.table_name /*pdc_table*/,
                                p_num      = &pdc_attr.nb_feet,
                                p_attr     = &pdc_attr.feet_list,
                                p_type     = &pdc_attr.format_list );

    if( status != SUCCESS ) {
       	*sts = MSFAIL;
       	goto wrapup;
    }
    __DBGpr_int("nb_feet", pdc_attr.nb_feet);

    if( !plist || !size )
    {
        *sts = MSSUCC;
        *count = pdc_attr.nb_feet - startIndex; 
       	goto wrapup;
    }

    /* select row */
    strcpy ( select, "*");
    sprintf ( where, "comp_seqno = %d", object->objid );
    __DBGpr_str ("where", where);

    status =        
    vdb$RisSelect(   select 	= select,
                     table_name = pdc_attr.table_name, 
                     where   	= where,
                     numselect  = pdc_attr.nb_feet,
                     p_numrows  = &nbrows,
                     p_buffer   = &buffer);
    
    if( !(status & 1) )  {
        __DBGpr_com ( "Can not get atrributes from DB"); 
        *sts = MSFAIL;
        goto wrapup;
    }
    
    __DBGpr_int("nbrows", nbrows);

    ii = 0;
    for ( i = startIndex; i < pdc_attr.nb_feet; i ++ ) {
       strcpy( plist[ii].name,pdc_attr.feet_list[i]); 
       if(!strcmp(pdc_attr.format_list[i], "1"))// for char */
       {
         plist[ii].desc.type = AC_ATTRIB_TEXT;
         vdb$RisExtractValue (  nbrows          = nbrows,
                                nbcolumns       = pdc_attr.nb_feet,
                                buffer          = buffer,
                                row             = 0,
                                column          = i,
                                value           = value)
  
         strcpy( plist[ii].desc.value.att_txt, value); 
       }
       else { 	// for value */
         plist[ii].desc.type = AC_ATTRIB_DOUBLE;
         vdb$RisExtractValue (  nbrows          = nbrows,
                                nbcolumns       = pdc_attr.nb_feet,
                                buffer          = buffer,
                                row             = 0,
                                column          = i,
                                value           = value)
  
         plist[ii].desc.value.att_exp = atof(value);
       }	
       ii = ii + 1;
    } 
     
wrapup :

    vdb$RisFreeBuffer( buffer = buffer, size = nbrows*pdc_attr.nb_feet );

    if( pdc_attr.feet_list != NULL ) {
    	for( i = 0; i < pdc_attr.nb_feet; ++i ) {
      		if( pdc_attr.feet_list[i] != NULL )
       		_FREE( pdc_attr.feet_list[i] );

      		if( pdc_attr.format_list[i] != NULL )
       		_FREE( pdc_attr.format_list[i] ) ;
    	}
    	_FREE( pdc_attr.feet_list );
    	_FREE( pdc_attr.format_list );
    }

    _FREE(VdsCatalogs);

    End
    return OM_S_SUCCESS;

}/* end VDDbget_parameters */

/*+fe
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Function VDDbgetParams

  Macro Name
      vd$db_get_params

  Abstract
      The function is used to get all the parameters and their values
      of any given object.  

  Arguments
      <Data Type>       <Name>  <I/O>   <Description>

      IGRlong          *sts         O     return code
      struct GRid      *object      I     GRid of the object
      GRmd_env         *md_env      I     module environment of the object
      IGRchar          *table_name  I     table_name
      IGRint           *count       O     No of parameters returned.
                                          If plist = NULL, count is the total
                                          number of parameters for the object
      struct ACrg_coll **plist      O     Address of list.  Memory will be
					  allocated here. Need to be free in 
					  the calling function.
					  
										
  Returns
      OM_S_SUCCESS     if success
      OM_E_NODYNMEM    no dynamic memory available

---------------------------------------------------------------------------
-fe*/
int VDDbgetParams( long           	*sts,
                   struct GRid    	*object,
                   char           	*table,
                   struct GRmd_env   	*md_env,
                   int            	*count,
                   struct ACrg_coll  	**plist )
{

    IGRlong 		status = OM_S_SUCCESS;

    SetProc( VDDbgetParams ); Begin

    *sts = MSSUCC;

    *count = 0;

    if( table )  __DBGpr_str (" table_name ", table);
    __DBGpr_obj (" object ", *object);

    __DBGpr_com ("VDSverify_login");
    if( VDSverify_login() != PDM_S_SUCCESS )
    {
       UI_status( "User not logged in to Database" );
       *sts = MSFAIL;
       goto wrapup;
    }

    __DBGpr_com ("VdsRisAttach");
    if( VdsRisAttach() != SUCCESS) {
       // printf(" Error in VdsRisAttach\n");
       *sts = MSFAIL;
       goto wrapup;
    }

    /* get parameter count */
    status = vd$db_get_parameters(	sts	= sts,
					object	= object,
                                        table   = table, 
					count	= count );

    CheckRC( status, *sts );
    __DBGpr_int( "count", *count );

    if( !(status & *sts & 1) || !*count ) {
         *count = 0;
         goto wrapup;
    }

    /* allocate memory */
    *plist = _MALLOC( *count, struct ACrg_coll );

    if( !*plist )
            vd_$mem_fail( sts = status, msg = sts );

    /* get the parameter list */
    status = vd$db_get_parameters( sts     = sts,
                                   object  = object,
                                   table   = table, 
		         	   plist   = *plist,
                                   size    = *count,
                                   count   = count );
    CheckRC( status, *sts );

wrapup :
    End
    return status;
}


end implementation Root;
