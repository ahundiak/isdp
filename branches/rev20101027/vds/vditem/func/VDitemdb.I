/* $Id: VDitemdb.I,v 1.4 2001/02/13 21:52:28 jdsauby Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vditem/func/VDitemdb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemdb.I,v $
 *	Revision 1.4  2001/02/13 21:52:28  jdsauby
 *	Modified for problems with interference check
 *	
 *	Revision 1.3  2001/02/11 17:52:17  ahundiak
 *	Renamed VDris2 to VDrisc
 *	
 *	Revision 1.2  2001/02/02 19:03:39  jdsauby
 *	JS, JTS CR4087.
 *	
 *	Revision 1.1  2001/01/10 18:04:41  art
 *	sp merge
 *	
# Revision 1.2  2000/12/11  17:25:44  pinnacle
# js
#
# Revision 1.1  2000/12/06  19:05:56  pinnacle
# Created: vds/vditem/func/VDitemdb.I by jdsauby for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/95  HV      Moved from smfit/cmd
 * 01/10/01  ah      sp merge
 *
 * -------------------------------------------------------------------*/


class implementation Root;

#include <stdio.h>
#include <string.h>

#include "igetypedef.h"     /* these two needed for gr.h, order of includes */
#include "igrtypedef.h"     /* important, also needed for IGRint ...        */
#include "gr.h"             /* struct GRid, GRmd_env  ..                    */

#include "OMprimitives.h"   /* om$send                                      */
#include "OMmacros.h"       /* indirectly for OM_S_SUCCESS, OM_E_NODYNMEM   */

#include "msdef.h"          /* MSSUCC, MSFAIL                               */
#include "DIdef.h"          /* DI_PATH_MAX                                  */
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"

#include "parametric.h"     /* ret_struct,  macro_generic ..                */

#include "ACattrib.h"       /* AC_ATTRIB_TEXT ..                            */
#include "ACrg_collect.h"   /* struct ACrg_coll                             */

#include "exmacros.h"      
#include "vdparmacros.h"      

#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"

#include "AS_status.h"      /* as$status                                    */
#include "VDItemDB.h"
#include "VDItemDBUtil.h"
#include "VDct1Ris.h"
#include "VDobj.h"
#include "VDppl1.h"
#include "VDrisc.h"
#include "VDpdm.h"


from ACdb_info	     import ACgive_db_structure;
from NDmacro	     import ACgive_structure;
from NDmacro         import ACreturn_foot;
from ACcpx           import ACfind_temp_obj;
from ACcpx_defn      import ACgive_name;
from ACcpx           import find_macro ;
from NDnode          import NDgive_structure;
from ACmacro_defn    import ACgive_feet_desc, ACgive_temp_desc;
from ACrg_collect    import AClist_attribute,
		            ACcreate,
			    GRchgname,
			    ACset_list_attribute;
from expression      import NDgive_value;
from VDSroot         import VDSgetCompDesc;
from VDSroot         import VDGetModel;
from VDSroot	     import VDreviewParameters, VDgetParameters;

/*
 * Exception Objects.
 */
extern 	GRclassid 	OPP_ACdb_info_class_id;
extern 	GRclassid 	OPP_VDdrawing_class_id;
extern 	GRclassid 	OPP_VDSroot_class_id;
extern 	GRclassid 	OPP_VDdrwObj_class_id;
extern 	GRclassid 	OPP_VDdrw3d_class_id;
extern	GRclassid	OPP_VDdrwGm_class_id;

/* -------------------------------------------------------------
 * Add attributes from customizable PPL, to the collector
 * I - collectID      - collection object
 * I - mat_id_key     - key value which is used to query the attributes
 * ***/
IGRstat VDitemdbAddAttributesToCollector( collectID, mat_id_key )
   TGRid	*collectID;
   IGRchar	*mat_id_key;
{

    TVDitemdbCollAttrs	list;
    TVDitemdbCollAttrs	*listx;

    IGRint		i,j,numAttrs;
    IGRstat		retFlag = 0;
    IGRstat		traceFlag = 0;
    IGRlong		status,retcode;
    IGRchar		buf[80];

    TGRid		pplID;
    IGRint		pplRet;

    // say hi
    if (traceFlag) printf(">>> VDitemdbAddAttributesToCollector\n");

    // init
    if (! collectID) goto wrapup;
    if (! mat_id_key) goto wrapup;

    vd$item_init( list = &list );


    // load the PPL
    vdppl$Load(name = VDITEMDB_PPL_NAME_ATTRS, pplID = &pplID);
    if (pplID.objid == NULL_OBJID) goto wrapup;
    if (traceFlag) printf("### Loaded the PPL <%d>\n",pplID.objid);

    // set the PPL data
    strcpy(buf,mat_id_key);
    vdppl$SetData(pplID = &pplID,
	    name = "KEY_VALUE",
	    size = 80,
	    data = buf);
    
    listx = &list;

    vdppl$SetData(pplID = &pplID,
	    name = "KEY_ATTRS",
	    size = sizeof(TVDitemdbCollAttrs*),
	    data = (IGRchar*)&listx);


    // run the ppl function
    vdppl$Run(pplID = &pplID, name = VDITEMDB_PPL_F_ATTRS, ret = &pplRet);
    if (pplRet == 0) goto wrapup;
    if (traceFlag) printf("### Returned From PPL\n");


    if (list.cnt == 0) goto wrapup;

    if (traceFlag) {
	for (i = 0; i < list.cnt; i++) {
	    printf("attr name = %s\n",list.attrs[i].name);
	}
    }

    // Set the collection list
    numAttrs = list.cnt;
    status = 
    om$send( msg = message ACrg_collect.ACset_list_attribute( &retcode, 
		numAttrs, list.attrs ),
	    senderid = NULL_OBJID,
	    targetid = collectID->objid,
	    targetos = collectID->osnum );
    as$status( action = RET_STATUS );

    if (! (status & 1) ) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    vd$item_free( list = &list );
    if (pplID.objid != NULL_OBJID) vdppl$Delete(pplID = &pplID);
    if (traceFlag) printf("<<< VDitemdbAddAttributesToCollector <%d>\n",retFlag);

    return retFlag;

}


/* --------------------------------------------------------------
 * Get the ItemDB collector ID if it exists.  If it does not exist
 * create it.
 * I - mat_id_key
 * O - path_name
 * O - collectID
 */
IGRstat VDitemdbGetItemDBCollector( mat_id_key, path_name, collectID)
  IGRchar *mat_id_key;
  IGRchar *path_name;
  TGRid   *collectID;
{
    IGRlong    status,
    	       retcode,
    	       dirstat,
	       retFlag;
    
    IGRchar    cur_dir[DI_PATH_MAX];
    TGRid      tmp_obj;
    GRspacenum cur_os;

    IGRstat  traceFlag = 0;

    // init
    retFlag 		= 0;
    collectID->objid 	= NULL_OBJID;
    cur_dir[0]          = '\0';

    // say hi
    if (traceFlag) printf(">>> VDitemdbGetItemDBCollector\n");

    // get the current directory
    dirstat = di$pwd( dirname = cur_dir );
    if ( dirstat != DIR_S_SUCCESS ) goto wrapup;
    if (traceFlag) printf ("cur_dir = %s\n",cur_dir);

    // need an osnum
    ex$get_cur_mod( id = &tmp_obj.objid, osnum = &cur_os );
    
    // determine the current path
    status = di$give_pathname(osnum    = cur_os,
	                      pathname = path_name);
    
    if ( status != DIR_S_SUCCESS )
    {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return retFlag ;
    }

    // Get / Create itemdb directory
    strcat( path_name, ":itemdb" );

    status = di$translate ( objname = path_name,
	    		    osnum   = collectID->osnum,
			    p_objid = &collectID->objid,
			    p_osnum = &collectID->osnum );
    if (status != DIR_S_SUCCESS)
    {
	di$mkdir(dirname = path_name,
		 osnum   = collectID->osnum );
    }

    // Get / Create the mat_id_key directory
    strcat (path_name,":");
    strcat (path_name,mat_id_key);

    status = di$translate ( objname = path_name,
	    		    osnum   = collectID->osnum,
			    p_objid = &collectID->objid,
			    p_osnum = &collectID->osnum );
    
    if ( status != DIR_S_SUCCESS )
    {
	if ( status == DIR_W_NAME_NOT_FOUND )
	{

             /* ------------------------------------------------------
              * Create the collector, with the mat_id_key name
              * */
              status = om$construct (
			classname = "ACrg_collect",
			osnum     = collectID->osnum,
			msg 	  = message ACrg_collect.ACcreate (
						&retcode, path_name ),
			p_objid   = &(collectID->objid));

              as$status ();

	      if ( collectID->objid == NULL_OBJID ) goto wrapup;

	      	
	      /** Add all attributes to the collector. **/
	      status = VDitemdbAddAttributesToCollector( collectID, mat_id_key );
	      if ( !(status & 1) ) goto wrapup;
	}
    }

    // done
    if( collectID->objid != NULL_OBJID ) retFlag = 1;

wrapup:
    if ( cur_dir[0] != '\0' ) {
	status = di$cd( dirname = cur_dir );
    }

    if (traceFlag) printf("<<< VDitemdbGetItemDBCollector <%d>\n",retFlag);
    return retFlag;
}

/*---------------------------------------------------------------------
 * Get the attributes from the collector.  
 * I - keyValue      - the itemdb key by which the attributes are stored against
 * 0 - Collection    - the list of attribute names, type, and value
 * O - NbCollect     - the number of attributes in the list
 * *****/
IGRstat VDitemdbGetItemDBCollectorAttributes( IGRchar             *keyValue,
					      TVDitemdbCollAttrs  *list)
{
   IGRlong		retcode;
   IGRlong 		sts,
   			status,retFlag;
   IGRchar		pathName[PATH_MAX];
   struct GRid		collId;
   struct ACrg_coll     plist[100];
   struct ACrg_coll	*pplist;
   IGRint               i, NbColl;

   // init
   if (! keyValue ) goto wrapup ;
   if (! list ) goto wrapup ;
   if (! list->attrs ) goto wrapup ;

   retFlag = 0;

   // get the collector object.
   collId.objid = NULL_OBJID ;
   pathName[0] = '\0';
   NbColl = 0;

   sts = VDitemdbGetItemDBCollector( keyValue, pathName, &collId);
   if ( (!(sts & 1)) || (collId.objid == NULL_OBJID) ) goto wrapup;

   // Get attributes the number of attributes.

   pplist = plist;
   status = 
   om$send (msg = message ACrg_collect.AClist_attribute( &retcode, VDITEMDB_MAX_ATTRS, 
				NULL, &NbColl ),
		    	  senderid = NULL_OBJID,
		    	  targetid = collId.objid,
		    	  targetos = collId.osnum );
   if( !( status & 1) && ( NbColl == 0) ) goto wrapup;

   if ( NbColl > 100 ) { 
       pplist = malloc( NbColl * sizeof(struct ACrg_coll) );
   }
   
   // get the list of attributes
   status = 
   om$send (msg = message ACrg_collect.AClist_attribute( &retcode, VDITEMDB_MAX_ATTRS, 
	                        plist, &NbColl ),
		    	  senderid = NULL_OBJID,
		    	  targetid = collId.objid,
		    	  targetos = collId.osnum );
   if( !( status & 1) && ( NbColl == 0) ) goto wrapup;

   
   for (i = 0; i < NbColl; i++) {
        vd$item_add( list = list, attr = &plist[i] );
   }

   // done
   retFlag = 1;

wrapup:
   if ( pplist != plist ) free( pplist );
   return retFlag;
}

/* -----------------------------------------------
 * ask a customizable PPL for a list of attributes
 * and values for a given mat_id_key
 */
IGRstat VDgetItemDbParameters(IGRlong		*status,
			      struct GRid       *object,
			      struct GRmd_env	*md_env,
			      IGRint            *count,
			      struct ACrg_coll  **plist )
{
    IGRstat		traceFlag = 0;
    IGRstat 		retFlag   = OM_S_SUCCESS;
    IGRstat 		sts;
    IGRint  		rc;
    TGRid   		myGRid;

    IGRint 		i,index;
    IGRchar 		keyValue[128];
    struct ACrg_coll   	*pColl ;

    TVDitemdbCollAttrs	list;

    vd$item_init( list = &list );
    
    // say hi
    if (traceFlag) printf(">>> VDgetItemDbParameters\n");

    // Arg Check
    if (object->objid == NULL_OBJID) goto wrapup;
    if ( ! count ) goto wrapup ;

    // init
    keyValue[0]                 = '\0';
    myGRid.objid 		= object->objid;
    myGRid.osnum 		= object->osnum;


    // get the keyValue
    VDitemdbGetKeyValue( &rc,&myGRid,VDITEMDB_KEY_VALUE,keyValue );
    if (keyValue[0] == '\0') goto wrapup;

    if (traceFlag) printf("### keyValue = %s\n",keyValue);

    // get the number of attributes from the collector
    sts = VDitemdbGetItemDBCollectorAttributes( keyValue, &list ); 
    if ( (!(sts & 1)) || (list.cnt == 0) ) goto wrapup;

    if (traceFlag) printf("### list.cnt = %d\n",list.cnt);

    // allocate some more memory
    pColl = realloc(*plist, (*count + list.cnt) * sizeof(struct ACrg_coll));
    *plist = pColl;

    // set the plist values
    for (i = 0; i < list.cnt; i++) {

	index = *count + i;
	pColl[index] = list.attrs[i] ;

	if( 0 ){
	    printf(" Att[%d]<%s> = <%s> \n", index, pColl[index].name, 
		    pColl[index].desc.value.att_txt );
	}

    }  // for list.cnt 

    // set the count
    *count += list.cnt;

    // done

wrapup:
    // Free up list
    vd$item_free( list = &list );
    if (traceFlag) printf("<<< VDgetItemDbParameters <%d> count <%d>\n",retFlag,*count);
    return retFlag;
}

/* ------------------------------------------------------
 * FUNCTION:  Traffic director to determine which customizable
 *            PPL to call dependent on object ancestory.
 * INPUT:     object
 * OUTPUT:    keyValue
 *
 * The PPL and function to be called depends on the component name,
 * the possible component names (or categories) are:
 *                      "beam",
 *        		"cable",
 *			"connect-comp",
 *			"equipment",
 *			"guide",
 *			"hvac",
 *			"joint",
 *			"nozzle",
 *			"pipe",
 *			"plate",
 *			"rway",
 *			"stiffener",
 *			"struct-surf",
 *			"terminal",
 *			"structure",
 *			"stage",
 *			"Macro"
 * For an updated list, see $VDS/vdtbl/func/VDdrwcomp.C function VD_compInit ()
 */

IGRstat VDitemdbGetMatIDForObject(TGRid   *myGRid, 
				  IGRchar *keyValue )
{
    IGRstat traceFlag = 0;
    IGRstat retFlag   = 0;
    IGRstat sts;

    IGRchar macName [PATH_MAX];
    IGRchar compName[PATH_MAX];
    IGRchar *cName;

    IGRchar pplName [PATH_MAX];
    IGRchar pplFunct[PATH_MAX];
    TGRid   pplID;
    IGRint  pplRet;


    IGRchar  matKey[128];
    TGRid    matID;

    // Arg check
    if (myGRid->objid == NULL_OBJID) goto wrapup;
    if (keyValue)                    keyValue[0] = '\0';

    // init
    pplName[0]    = '\0';
    pplFunct[0]   = '\0';
    pplID.objid   = NULL_OBJID;
    compName[0]   = '\0';
    macName[0]    = '\0';

    matID.objid = myGRid->objid;
    matID.osnum = myGRid->osnum;
    matKey[0]     = '\0';


    // get the macro name of the object
    VD_drwGetACcpxInfo( &matID, macName, 1 );

    // get the component name for the macro  
    cName = compName;
    VD_compGetCompFromMacro( macName, PATH_MAX, &cName );
    if (compName[0] == '\0') goto wrapup;

#if 0  
    printf("### printing comp names...\n");  
    VD_compPrintCompNames();

    printf("### printing table...\n");
    VD_compPrintCompTable();
#endif

    if (traceFlag) printf("### compName = %s\n",compName);

    /* -----------------------------------------------------
     * The PPL and function to be executed depends on the
     * compName or "category" of the object.
     * Set the PPL and function.
     */
    if      (!strcmp(compName,"beam")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_STRUCT);
	strcpy(pplFunct,VDITEMDB_PPL_F_STRUCT_BEAM);
    }

    else if (!strcmp(compName,"cable")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_CABLE);
    }

    else if (!strcmp(compName,"connect-comp")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_CON_COMP);
    }

    else if (!strcmp(compName,"equipment")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_VDS);
	strcpy(pplFunct,VDITEMDB_PPL_F_VDS_EQUIP);
    }

    else if (!strcmp(compName,"guide")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_GUIDE);
    }

    else if (!strcmp(compName,"hvac")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_HVAC);
    }

    else if (!strcmp(compName,"joint")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_STRUCT);
	strcpy(pplFunct,VDITEMDB_PPL_F_STRUCT_JOINT);
    }

    else if (!strcmp(compName,"nozzle")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_NOZZLE);
    }

    else if (!strcmp(compName,"pipe")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_PIPE);
    }

    else if (!strcmp(compName,"plate")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_STRUCT);
	strcpy(pplFunct,VDITEMDB_PPL_F_STRUCT_PLATE);
    }

    else if (!strcmp(compName,"rway")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_RWAY);
    }

    else if (!strcmp(compName,"stiffener")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_STRUCT);
	strcpy(pplFunct,VDITEMDB_PPL_F_STRUCT_STFNR);
    }

    else if (!strcmp(compName,"struct-surf")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_STRUCT);
	strcpy(pplFunct,VDITEMDB_PPL_F_STRUCT_SURF);
    }

    else if (!strcmp(compName,"terminal")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_ROUTE);
	strcpy(pplFunct,VDITEMDB_PPL_F_ROUTE_TERM);
    }

    else if (!strcmp(compName,"structure")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_STRUCT);
	strcpy(pplFunct,VDITEMDB_PPL_F_STRUCT_STRUCT);
    }

    else if (!strcmp(compName,"stage")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_VDS);
	strcpy(pplFunct,VDITEMDB_PPL_F_VDS_STAGE);
    }

    else if (!strcmp(compName,"Macro")) {
	strcpy(pplName, VDITEMDB_PPL_NAME_VDS);
	strcpy(pplFunct,VDITEMDB_PPL_F_VDS_MACRO);
    }

    else {
	printf("###  Could not determine type for KEY_VALUE generation\n");
	goto wrapup;

    }

    // Make sure there is a PPL and function to run
    if (pplName[0]  == '\0') goto wrapup;
    if (pplFunct[0] == '\0') goto wrapup;


    if (traceFlag) {
	printf("### pplName  = %s\n",pplName);
	printf("### pplFunct = %s\n",pplFunct);
    }

    // load the PPL
    vdppl$Load(name = pplName, pplID = &pplID);
    if (pplID.objid == NULL_OBJID) goto wrapup;

    // set the PPL data
    vdppl$SetData(pplID = &pplID,
	    name = "KEY_VALUE_OBJID",
	    size = sizeof(TGRid),
	    data = (IGRchar*)&matID);


    // run the ppl function
    vdppl$Run(pplID = &pplID, name = pplFunct, ret = &pplRet);
    if (pplRet == 0) goto wrapup;

    // get the data from the PPL
    vdppl$GetData(pplID = &pplID,
	    name  = "KEY_VALUE",
	    size  = 128,
	    data  = matKey);


    // done
    if (matKey[0] != '\0') {
	strcpy(keyValue,matKey);
	retFlag = 1;
    }

wrapup:
    
    if (pplID.objid != NULL_OBJID) vdppl$Delete(pplID = &pplID);
    return retFlag;

}

/* --------------------------------------------------------
 * FUNCTION: wrapped around VDitemdbGetKeyValueForObject.  
 * Used to handle the possibility of more than one key.
 */
IGRstat VDitemdbGetKeyValue(IGRint  *rc, 
			    TGRid   *myGRid,
			    IGRchar *foot_name,
			    IGRchar *keyValue )
{
  IGRstat traceFlag = 0;
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  //TGRobj_env objOE;
  
  IGRchar part_num  [128];
  //IGRchar part_id [80];

  // say hi
  if (traceFlag) printf (">>> VDitemdbGetKeyValue\n");

  // Arg check
  if (myGRid->objid == NULL_OBJID) goto wrapup;
  if (foot_name     == NULL)       goto wrapup;
    
  // init
  part_num[0] = '\0';
  
  // Say hi
  if (traceFlag) printf("### VDitemdbGetKeyValue, foot_name = %s\n",foot_name);
  
  // really only need a key value if getting attributes from a database
  // make sure logged into PDM first
  sts = VDpdmVerifyLogin();
  if (!(sts & 1)) goto wrapup;

  // function to be executed depends on the key or foot_name
  if (!strcmp( foot_name, VDITEMDB_KEY_VALUE )) {
    // get it
    sts = VDitemdbGetMatIDForObject( myGRid, part_num );
    if (!(sts & 1) || (part_num[0] == '/0')) goto wrapup;
    
    // set it
    strcpy(keyValue,part_num);

    // done
    retFlag = 1;
    goto wrapup;
  }
  
  // nothing else to look at

 wrapup:
  if (retFlag) *rc = OM_S_SUCCESS;
  if (traceFlag) printf("<<< VDitemdbGetKeyValue %d\n",retFlag);
  return retFlag;
  
}


/* ----------------------------------------------------------
 * This function returns the value of an attribute given the
 * attribute name, and the keyValue.
 * 0 - rc                 - return code
 * I - keyValue           - will be used to search DDC to find attributes
 * I - foot_name          - attribute name
 * 0 - foot_value         - attribute value
 ***/
IGRstat VDitemdbGetAttrInfo( IGRint  *rc, 
			     IGRchar *keyValue,
			     IGRchar *foot_name,
			     IGRchar *foot_value )
{
  IGRstat traceFlag = 0;
  IGRstat retFlag   = 0;
  IGRstat sts;

  struct ACrg_coll	Attrs[VDITEMDB_MAX_ATTRS];
  IGRint		NbAttrs, i;

  TVDitemdbCollAttrs	list;
  
  // Arg Check
  if (*keyValue  == NULL) goto wrapup;
  if (*foot_name == NULL) goto wrapup;

  // init
  vd$item_init( list = &list );

  // say hi
  if (traceFlag) printf(">>> VDitemdbGetAttrInfo \n");

  // First we need to get the attributes from the collector
  NbAttrs = 0;
  sts = VDitemdbGetItemDBCollectorAttributes( keyValue, &list );
  if ( (!(sts & 1)) && (list.cnt == 0) ) goto wrapup;

  if (traceFlag) printf ("### got the collector attributes\n");
  // Cycle through attributes to find the attribute value
  for ( i = 0; i < list.cnt; i++ ) {
  	
     switch (list.attrs[i].desc.type) {
		
	case AC_ATTRIB_TEXT:
			
		if ( !strcmp( list.attrs[i].name, foot_name ) ) {
		    strcpy ( foot_value, list.attrs[i].desc.value.att_txt );
		    retFlag = 1;
		    goto wrapup;
		}
		break;

	case AC_ATTRIB_DOUBLE:

		if ( !strcmp( list.attrs[i].name, foot_name ) ) {
		    sprintf ( foot_value,"%f", list.attrs[i].desc.value.att_exp );
		    retFlag = 1;
		    goto wrapup;
		}
		break;

	default:

		retFlag = 0;
		break;
     }  // end of switch
  }  // end of for loop


  // done
  retFlag = 0;
  
wrapup:
  vd$item_free( list = &list );
  if (traceFlag) printf("<<< VDitemdbGetAttrInfo %d\n",retFlag);
  return retFlag;
}


end implementation Root;

