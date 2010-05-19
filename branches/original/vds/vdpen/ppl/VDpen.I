class implementation Root;

#include "FI.h"
#include "VDmsg.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDsa.h"
#include "VDobj.h"
#include "vdrefmacros.h"
#include "vdsmacros.h"

//#define  vdsDEBUG
#include "v_dbgmacros.h"

extern	int  GRconfirm_box();
extern	EX_findmod();
extern	VDpms_findall_ancestryobjects();

from	ci_macro	import	find_macro;
from	GRgraphics	import	GRgetobjinfo;
from	GRvg		import	GRputname;
from	GRvg		import	GRputsymb;
from	GRvg		import	GRgetsymb;
from	ACrg_collect	import	ACget_named_attribute;
from	NDmacro		import	ACreturn_foot;
from	ACcpx		import	ACfind_exp_temp_obj;

%safe
static	IGRint	CMD_SRC = 0;
%endsafe

#define	nbStructToCut	12
#define	nbTypeList	5

IGRint VDpenGetCmdSrc()
{
	return CMD_SRC;
}


void VDpenSetCmdSrc( int cmd_src )
{
	CMD_SRC = cmd_src;
}

extern FILE *VD_openFile();

/*--------------------------------------------------------------------
 * Reset structure_to_cut to original value
 */
IGRlong	VDpenReadDataList(	IGRchar		*fileName,
				IGRchar		*listName,
				IGRchar		**list, 
				IGRint		*itemLen,
				IGRint		*count ) 
{
	IGRlong		sts = 0, msg;
	IGRint		maxLen = 0, cnt = 0;
	IGRchar		fname[80], filePath[80], buf[80], tmpBuf[80];
	IGRchar		*ptr = NULL;
	FILE		*fp = NULL;

	fname[0]	= '\0';
	filePath[0]	= '\0';

	if( !listName || !list || !itemLen || !count ) goto wrapup;

	*list = NULL;
	*count = 0;

	if( !fileName || fileName[0] == 0 ) {
		strcpy( fname, "DataLists" );
	}
	else {
		strcpy( fname, fileName );
	}

	vd$file_path(	msg				= &msg,
			fileToFind			= fname,
			dirToSearchFirst		= ".",
			dirInProdPathToSearchThen	= "config/penetrations",
			absPathName			= filePath);

	if( !(msg&1) || filePath[0] == '\0' ) goto wrapup;

	__DBGpr_str("filePath", filePath);

	fp = VD_openFile( &msg, filePath, "r" );
	if( !fp ) goto wrapup;

	while( fgets( buf, DI_PATH_MAX, fp ) ) {
		while( (ptr = strchr( buf, '\n' ) ) != NULL ) *ptr = ' ';
		VD_stripString(buf);

		__DBGpr_str("buf from file", buf);

		if( buf[0] != '%' ) continue;
		buf[0] = ' ';
		VD_stripString(buf);
		if( !strcmp( buf, listName ) ) {
			while( fgets( tmpBuf, DI_PATH_MAX, fp ) ) {
				if( tmpBuf[0] == '%' ) break;
				if( tmpBuf[0] == '#' ) {
					tmpBuf[0] = ' ';
					VD_stripString(tmpBuf);
					if( strlen(tmpBuf) > maxLen ) 
						maxLen = strlen(tmpBuf);
					cnt++;
				}
			}
			break;
		}
	}

	maxLen++;
	*count = cnt;
	if( maxLen*cnt < 1 ) goto wrapup;

	*list = _MALLOC( cnt*maxLen, IGRchar );
	if( !list ) goto wrapup;

	rewind(fp);

	cnt = 0;
	while( fgets( buf, DI_PATH_MAX, fp ) ) {
		while( (ptr = strchr( buf, '\n' ) ) != NULL ) *ptr = ' ';
		VD_stripString(buf);
		if( buf[0] != '%' ) continue;
		buf[0] = ' ';
		VD_stripString(buf);
		if( !strcmp( buf, listName ) ) {
			while( fgets( tmpBuf, DI_PATH_MAX, fp ) ) {
				if( tmpBuf[0] == '%' ) break;
				if( tmpBuf[0] == '#' ) {
					tmpBuf[0] = ' ';
					while( (ptr = strchr( tmpBuf, '\n' ) ) != NULL ) *ptr = ' ';
					VD_stripString(tmpBuf);
					strcpy( &(*list)[cnt*maxLen], tmpBuf );
					cnt++;
				}
			}
			break;
		}
	}

	*itemLen = maxLen;

	sts = 1;
wrapup:
	return sts;
}

/*--------------------------------------------------------------------
 * Get and check object name
 */
IGRboolean VDpenCheckForProperName (	TGRid	selObj,
					IGRchar	*objName,
					IGRint	check )
{
	IGRdouble	pnt[3];
	IGRchar		prefix[80];
	IGRchar		preName[2];
	IGRchar		*list = NULL;
	IGRint		nbList = 0, itemLen = 0, i;
	IGRboolean	ret = FALSE;


	objName[0] = 0;
	prefix[0]  = 0;

	vdobj$Get(	objID	= &selObj,
                        objName	= objName);

        if(!strcmp(objName,""))
        {
                goto wrapup;
        }

        if ( check == 1 ){
          if(!VDpenReadDataList(NULL, "name_prefix", &list, &itemLen, &nbList))
          {
                goto wrapup;
          }
          if( !nbList || list == NULL ) goto wrapup;

          for( i = 0; i < nbList; i = i+1 ) {
                prefix[i] = list[i*itemLen];
          }
          prefix[i] = '\0';

          if( strlen(objName) != 9 || objName[5] != '-' ){
		goto wrapup;
          }
          preName[0] = objName[0];
          preName[1] = '\0';
          if( !strpbrk( preName, prefix ) )
          {
		goto wrapup;
          }
        }

	ret = TRUE;
wrapup:
	_FREE( list );
        return ret;
}


/*--------------------------------------------------------------------
 * Reset structure_to_cut to original value
 */
IGRlong	VDpenGetOrigAttr(	TGRid	penID,
				IGRchar	*name,
				IGRchar	*value )
{
	IGRlong         ret = 0, sts, msg;
	TGRmd_env	mod_env;
	TACrg_coll	attr;
	TGRid		attrID, tempID;
	
	if( penID.objid == NULL || !name || !value ) goto wrapup;

	value[0] = '\0';

	sts = om$send(  msg      = message ACcpx.ACfind_exp_temp_obj
						((IGRint*)&msg, 2, &tempID),
			senderid = NULL_OBJID,
			targetid = penID.objid,
			targetos = penID.osnum);
	if (!(msg&sts&1)) {
		goto wrapup;
	}

	sts = om$send ( msg = message NDmacro.ACreturn_foot(
                                                &msg,
                                                "",
                                                &attrID,
                                                &mod_env.md_env.matrix_type,
                                                mod_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = tempID.objid,
			targetos = tempID.osnum);

	if (!(msg&sts&1)) {
		__DBGpr_com("NDmacro.ACreturn_foot failed to get DataColl");
		goto wrapup;
	}

	strcpy(attr.name, name);
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute 
							( &msg, &attr ),
			senderid = NULL_OBJID,
			targetid = attrID.objid,
			targetos = attrID.osnum);
	if (!(msg&sts&1)) {
		__DBGpr_com("ACrg_collect.ACget_named_attribute failed");
		goto wrapup;
	}
	
	if( attr.desc.type == 1 ) {
		strcpy(value, attr.desc.value.att_txt);
	}
	else {
		sprintf(value, "%f", attr.desc.value.att_exp );
	}

	ret = 1;
wrapup:
	return ret;
}

/*--------------------------------------------------------------------
 *  Set form list
 */
IGRlong VDpenFormSetList (	Form	form,
				IGRint	gadget,
				IGRchar	*listName,
				IGRint	defRow )
{
	IGRlong		ret = 0;
	IGRint		len = 0, nbRows = 0, row = -1;
	IGRchar		*list = NULL, buf[80];

	if( !form || gadget < 0 || !listName || listName[0] == '\0' ) {
		goto wrapup;
	}

        ret = VDpenReadDataList(NULL, listName, &list, &len, &nbRows);

	if( !ret || !len || !nbRows || !list) goto wrapup;

	FIfld_set_list_num_rows(form, gadget, 0, nbRows);
	
	for( row = 0; row < nbRows; row++ ) {
	    if( !strcmp( listName, "long_axis" ) ) {
		if( isdigit(list[row*len]) ) {
			sprintf(buf, " %s", &list[row*len] );
		}
		else strcpy( buf, &list[row*len] );
	    }
	    else {
		strcpy( buf, &list[row*len] );
	    }
	    FIfld_set_list_text( form, gadget, row, 0, buf, FALSE);
	    if( defRow == row ) FIg_set_text( form, gadget, buf );
	}

	ret = 1;
wrapup:
	_FREE( list );
	return ret;
}

				
/*--------------------------------------------------------------------
 * Overwrite structure_to_cut in expressions
 */
IGRlong	VDpenFormSetExpList (	Form	form,
				IGRint	datGadget,
				IGRint	resetGadget,
				IGRchar	*name,
				IGRchar	*value,
				IGRint	flag )
{
	IGRlong         ret = 0;
	IGRint		nbRows = 0, maxRows = 0, len = 0, i;
	IGRchar		*list = NULL;

	if( !form ) goto wrapup;
	if(!name || name[0] == '\0' || !value || value[0] == '\0') goto wrapup;

	FIg_set_text( form, datGadget, "" );
	FIfld_set_list_num_rows(form, datGadget, 0, 0);
	if( !flag ) {
		ret = 1;
		goto wrapup;
	}
	
	if( !strcmp( name, "structure_to_cut" ) ) {
		VDpenReadDataList( NULL, name, &list, &len, &nbRows ) ;
	}
	/* not required right now 
	else if( !strcmp( name, "type" ) ) {
		VDpenReadDataList( NULL, name, &list, &len, &nbRows ) ;
	}
	*/
	else goto wrapup;

	if( nbRows < 1 || len < 1 ) goto wrapup;

	FIg_enable( form, datGadget );
	FIg_enable( form, resetGadget );
	FIg_display( form, datGadget );
	FIg_display( form, resetGadget );
	FIg_set_text( form, datGadget, value );
	FIfld_set_list_num_rows(form, datGadget, 0, nbRows);
	for( i = 0; i < nbRows; i++ ) {
	    FIfld_set_list_text( form, datGadget, i, 0, &list[i*len], FALSE);
	}
	ret = 1;
wrapup:
	if( !flag || !ret ) {
		FIg_disable( form, datGadget );
		FIg_erase (  form, datGadget );
		FIg_disable( form, resetGadget );
		FIg_erase( form, resetGadget );
	}
	_FREE( list );
	return ret;
}
				
/*************************************************************************
 * Get nci_macros by macro name, such as penMacro and pcgMacro
 */
IGRlong VDgetMacrosByMacName( 
GRspacenum      cur_osnum,
IGRchar		*macName, 
IGRint		*nb_mac,
TGRid		**macIDs )
{
	IGRlong         ret;
	IGRlong		sts, msg ;
	IGRint          i, nb_obj;
	GRclassid       classid ;
	GRobjid		*obj_list;
	TGRid		*mac_list, objID;
	IGRchar		name[128] ;

	SetProc( VDgetMacrosByMacName ); Begin

	ret = 0 ;
	nb_obj = 0 ;
	*nb_mac = 0 ;
	obj_list = NULL  ;
	mac_list = NULL  ;
	*macIDs	 = NULL  ;

        sts = om$get_classid (	classname = "nci_macro" ,
				p_classid = &classid);
	if( !(sts&1) ) {
		printf("om$get_classid failed\n");
		goto wrapup ;
	}

        sts = VDpms_findall_ancestryobjects (
                                        cur_osnum,
                                        1, 
                                        &classid, 
                                        &nb_obj, 
                                        NULL);
	if( !(sts&1) || !nb_obj ) goto wrapup ;
	__DBGpr_int("nb_obj", nb_obj);

	obj_list = _CALLOC( nb_obj, GRobjid ) ;
	if( obj_list == NULL ) {
		printf("_CALLOC failed for obj_list\n") ;
		goto wrapup ;
	}

	mac_list = _CALLOC( nb_obj, TGRid ) ;
	if( mac_list == NULL ) {
		printf("_CALLOC failed for mac_list\n") ;
		goto wrapup ;
	}

	sts = VDpms_findall_ancestryobjects(
					cur_osnum,
					1, 
					&classid, 
					&nb_obj, 
					obj_list);
	if( !(sts&1) || !nb_obj ) goto wrapup ;

	objID.osnum = cur_osnum ;
	for(i = 0; i < nb_obj; i = i+1 ) {

		objID.objid = obj_list[i] ;
		name[0] = '\0' ;

		// Get macro name name
		vdobj$Get (	objID	= &objID,
				macName	= name);
		if(name[0] == '\0' ) continue ;
		__DBGpr_str("macro name", name);

		if(!strcmp(macName, name) ) {
			__DBGpr_obj("objID", objID);
			mac_list[*nb_mac] = objID ;
			(*nb_mac)++;
		}
	}

	if( (*nb_mac) < 1 ) {
		ret = 1;
		goto wrapup;
	}

	*macIDs = _CALLOC( *nb_mac, TGRid ) ;
	if( macIDs == NULL ) {
		printf("_CALLOC failed for macIDs\n") ;
		goto wrapup ;
	}

	for(i = 0; i < *nb_mac; i = i+1 ) {
		(*macIDs)[i] = mac_list[i] ;
	}

	ret = 1 ;
wrapup:
	_FREE( obj_list ) ;
	_FREE( mac_list ) ;

	End
	return ret ;
}

/*************************************************************************
 * Update all names of penetration and/or penetration control macros
 */
IGRlong VDupdatePenAndPcgNames( 
IGRlong *msg ,
IGRint	nameFlag )	// 1 for pen, 2 for pcg, 3 for both

{
IGRlong         ret;
IGRlong		sts ;
IGRint          i, nb_mac;
GRspacenum      cur_osnum;
TGRid		*macIDs, objID, csID ;
IGRchar		macName[128], csName[128], oldName[128],  newName[128] ;

	*msg = 1 ;
	ret = 0 ;
	nb_mac = 0 ;
	macName[0] = '\0' ;
	macIDs =  NULL ;

	if( nameFlag < 1 || nameFlag > 3 ) {
		UI_status("Invalid Naming Value");
		goto wrapup;
	}

        ex$get_cur_mod ( osnum = &cur_osnum ) ;

	if( nameFlag == 1 || nameFlag == 3 ) {
		strcpy( macName, "penMacro");
		sts = VDgetMacrosByMacName(cur_osnum,macName,&nb_mac,&macIDs);
		if( !(sts&1) || macIDs == NULL ) {
			goto wrapup;
		}

		for( i = 0; i < nb_mac; i++ ) {
			oldName[0] = '\0' ;
			csName[0] = '\0' ;
			csID.objid = NULL_OBJID;

			// Get obj name
			vdobj$Get (	objID	= &macIDs[i],
					objName	= oldName);

			// get coordinate 
			vdobj$GetParent(objID	 = &macIDs[i],
					idx	 = 0,
					parentID = &csID);
			if( csID.objid == NULL_OBJID ) {
				__DBGpr_com("Can't get cs from pen");
				__DBGpr_obj("macIDs[i]", macIDs[i]);
				continue ;
			}
	
			// get coordinate name
			vdobj$Get(	objID	= &csID,
					objName	= csName);

			// generate new obj name
			sprintf(newName, "PEN-%s", csName);
			__DBGpr_str("oldName", oldName);
			__DBGpr_str("newName", newName);
	
			if( strcmp( oldName, newName ) ) {
				sts = om$send(	msg = message GRvg.GRputname
							(msg, newName),
						senderid = NULL_OBJID,
						targetid = macIDs[i].objid,
						targetos = macIDs[i].osnum);
			}
		}
		_FREE( macIDs ) ; macIDs = NULL ; nb_mac = 0 ;
	}

	if( nameFlag == 2 || nameFlag == 3 ) {
		strcpy( macName, "pcgMacro");
		sts = VDgetMacrosByMacName(cur_osnum,macName,&nb_mac,&macIDs);
		if( !(sts&1) || macIDs == NULL ) {
			goto wrapup;
		}

		for( i = 0; i < nb_mac; i++ ) {
			oldName[0] = '\0' ;
			csName[0] = '\0' ;
			csID.objid = NULL_OBJID;
			objID.objid = NULL_OBJID;

			// Get obj name
			vdobj$Get (	objID	= &macIDs[i],
					objName	= oldName);

			// Get pen macro 
			vdobj$GetParent(objID	 = &macIDs[i],
					idx	 = 0 ,
					parentID = &objID );
			if( objID.objid == NULL_OBJID ) {
				__DBGpr_com("Can't get pen from pcg");
				continue ;
			}
			__DBGpr_obj("objID", objID);

			// get coordinate
			vdobj$GetParent(objID	 = &objID,
					idx	 = 0,
					parentID = &csID);
			if( csID.objid == NULL_OBJID ) {
				__DBGpr_com("Can't get cs from pen");
				__DBGpr_obj("objID", objID);
				continue ;
			}
	
			// get coordinate name 
			vdobj$Get(	objID	= &csID,
					objName	= csName);

			// generate new name
			sprintf(newName, "PCG-%s", csName);
			__DBGpr_str("oldName", oldName);
			__DBGpr_str("newName", newName);

			if( strcmp( oldName, newName ) ) {
				sts = om$send(	msg = message GRvg.GRputname
								(msg, newName),
						senderid = NULL_OBJID,
						targetid = macIDs[i].objid,
						targetos = macIDs[i].osnum);
			}
		}
		_FREE( macIDs ) ; macIDs = NULL ;
	}

	ret = 1 ;
wrapup:
	_FREE( macIDs ) ;
	return ret ;
}



/*************************************************************************
 * Fill in the form with object names 
 */
IGRlong VDpenFormFillInObjNames( 
Form	form,
IGRint	gadget,
IGRchar	*macName )
{
IGRlong         ret;
IGRlong		sts, msg ;
IGRint          i, j, nb_mac, refOsCnt, rows;
GRspacenum      cur_osnum, *refOsList;
TGRid		*macIDs, objID;
IGRchar		objName[128] ;

	SetProc(VDpenFormFillInObjNames); Begin

	ret		= 0 ;
	nb_mac		= 0 ;
	refOsCnt	= 0;
	macIDs		= NULL ;
	refOsList	= NULL;

	// First, fill in form with object names from active file

        ex$get_cur_mod ( osnum = &cur_osnum ) ;

	sts = VDgetMacrosByMacName(cur_osnum,macName,&nb_mac,&macIDs);
	if( !(sts&1) || macIDs == NULL ) {
		nb_mac = 0;
	}

	//FIfld_set_list_num_rows( form, gadget, 0, nb_mac );

	for( i = 0; i < nb_mac; i++ ) {
		// Get obj name
		objName[0] = '\0'; ;
		vdobj$Get (	objID	= &macIDs[i],
				objName	= objName);
		FIfld_set_list_text(form, gadget, i, 0, objName, FALSE);
		__DBGpr_str("objName in current file",objName);
	}
	rows = i ;
	_FREE( macIDs ) ; 
	macIDs = NULL ;
	nb_mac = 0 ;

	sts = vd$get_ref_os_list(msg		= &msg,
				main_os		= &cur_osnum,
				num_ref_os	= &refOsCnt,
				ref_os_list	= &refOsList);
	if( !(sts&msg&1) ) goto wrapup ;

	for( i = 0; i < refOsCnt; i++ ) {
		sts = VDgetMacrosByMacName
				(refOsList[i],macName,&nb_mac,&macIDs);
		if(sts) {
		    for( j = 0; j < nb_mac; j++ ) {
			objName[0] = '\0' ;
			vdobj$Get( objID = &macIDs[j], objName = objName);
			FIfld_set_list_text
				(form, gadget, rows, 0, objName, FALSE);
			__DBGpr_str("objName in ref file",objName);
			rows++;
		    }
		}
		
		_FREE( macIDs ) ; 
		macIDs = NULL ;
		nb_mac = 0 ;
	}

	
	ret = 1 ;
wrapup:
	_FREE( macIDs ) ;
	_FREE( refOsList ) ;
	End
	return ret ;
}

/*************************************************************************
 * Get all objects by class name from the file specified by osnum
 */
IGRlong VDgetAllObjectsByClassName( 
GRspacenum      cur_osnum,
IGRchar		*className, 
IGRint		*objCnt,
TGRid		**objIDs )
{
	IGRlong         ret;
	IGRlong		sts, msg ;
	IGRint          i, nb_obj;
	GRobjid		*obj_list;
	GRclassid       classid ;

	SetProc( VDgetAllObjectsByClassName ); Begin

	ret	= 0 ;
	nb_obj	= 0 ;
	*objCnt	= 0 ;
	obj_list	= NULL ;
	*objIDs		= NULL ;

        sts = om$get_classid (	classname = className ,
				p_classid = &classid);
	if( !(sts&1) ) {
		printf("om$get_classid failed\n");
		goto wrapup ;
	}

        sts = VDpms_findall_ancestryobjects (
                                        cur_osnum,
                                        1, 
                                        &classid, 
                                        &nb_obj, 
                                        NULL);
	if( !(sts&1) || !nb_obj ) goto wrapup ;
	__DBGpr_int("nb_obj", nb_obj);

	obj_list = _CALLOC( nb_obj, GRobjid ) ;
	if( obj_list == NULL ) {
		printf("_CALLOC failed for obj_list\n") ;
		goto wrapup ;
	}

	*objIDs = _CALLOC( nb_obj, TGRid ) ;
	if( *objIDs == NULL ) {
		printf("_CALLOC failed for mac_list\n") ;
		goto wrapup ;
	}

	sts = VDpms_findall_ancestryobjects(
					cur_osnum,
					1, 
					&classid, 
					&nb_obj, 
					obj_list);
	if( !(sts&1) || !nb_obj ) goto wrapup ;

	*objCnt = nb_obj ;
	for(i = 0; i < *objCnt; i = i+1 ) {
		(*objIDs)[i].osnum = cur_osnum ;
		(*objIDs)[i].objid = obj_list[i] ;
	}

	ret = 1 ;
wrapup:
	_FREE( obj_list ) ;

	End
	return ret ;
}

/*************************************************************************
 * Check cs name to determin if it comply with official specification
 */
IGRboolean  VDpenCheckCoordName(IGRchar *csName)  
{

	if( strlen(csName) != 9 ) return FALSE;

	if( csName[5] != '-' ) return FALSE;

	if(csName[0] != 'F' && csName[0] != 'P' && csName[0] != 'V' &&
	   csName[0] != 'E' && csName[0] != 'M' ){
		return FALSE;
	}

	return TRUE;
}


/*************************************************************************
 * Fill in the form with cs names specified by pen and pcg macros
 */
IGRlong VDpenFormFillInCoordNames( 
Form	form,
IGRint	gadget)
{
IGRlong         ret;
IGRlong		sts, msg ;
IGRint          i, j, csCnt, refOsCnt, rows;
GRspacenum      cur_osnum, *refOsList;
TGRid		*csIDs, objID;
IGRchar		csName[128] ;

	ret		= 0 ;
	csCnt		= 0 ;
	rows		= 0 ;
	refOsCnt	= 0;
	csIDs		= NULL ;
	refOsList	= NULL;

	// First, fill in form with coord names from active file

        ex$get_cur_mod ( osnum = &cur_osnum ) ;

	sts = VDgetAllObjectsByClassName(cur_osnum,"GRgencs", &csCnt, &csIDs);
	if( !(sts&1) || csIDs == NULL ) {
		csCnt = 0;
	}

	for( i = 0; i < csCnt; i++ ) {
		// Get obj name
		csName[0] = '\0'; ;
		vdobj$Get (	objID	= &csIDs[i],
				objName	= csName);
		if( VDpenCheckCoordName(csName) ) {
			FIfld_set_list_text
				(form, gadget, rows, 0, csName, FALSE);
			rows++ ;
		}
		__DBGpr_str("csName in current file",csName);
	}
	_FREE( csIDs ) ; 
	csIDs = NULL ;
	csCnt = 0 ;

	sts = vd$get_ref_os_list(msg		= &msg,
				main_os		= &cur_osnum,
				num_ref_os	= &refOsCnt,
				ref_os_list	= &refOsList);

	if( !(sts&msg&1) ) goto wrapup ;

	for( i = 0; i < refOsCnt; i++ ) {
		sts = VDgetAllObjectsByClassName
				(refOsList[i],"GRgencs", &csCnt, &csIDs);
		for( j = 0; j < csCnt; j++ ) {
			csName[0] = '\0' ;
			vdobj$Get( objID = &csIDs[j], objName = csName);
			if( VDpenCheckCoordName(csName) ) {
				FIfld_set_list_text
					(form, gadget, rows, 0, csName, FALSE);
				__DBGpr_str("csName in ref file",csName);
				rows++;
			}
		}
		
		_FREE( csIDs ) ; 
		csIDs = NULL ;
		csCnt = 0 ;
	}

	
	ret = 1 ;
wrapup:
	_FREE( csIDs ) ;
	_FREE( refOsList ) ;
	return ret ;
}

/*--------------------------------------------------------------------------
 * Move all ROOT-pcgMacro's to layer 301 and change color to magenta
 */
IGRlong	VDpen_movePcg()
{
	IGRlong		retFlag = 0, sts, msg;
	GRspacenum      cur_osnum;
	IGRint		i, nb_mac = 0;
	TGRid		*macIDs = NULL;
struct	GRobj_info	info;
struct	GRsymbology	symb;

 
        ex$get_cur_mod ( osnum = &cur_osnum ) ;

	sts = VDgetMacrosByMacName( cur_osnum, "pcgMacro", &nb_mac, &macIDs );
	if( !(sts&1)) {
		__DBGpr_com("Failed to get osnum");
		goto wrapup;
	}

	for(i = 0; i < nb_mac; i++) {
		sts = om$send( msg = message GRgraphics.GRgetobjinfo
							(&msg, &info),
						senderid = NULL_OBJID,
						targetid = macIDs[i].objid,
						targetos = macIDs[i].osnum);
		__DBGpr_str("info", info.type);

		if(!strncmp(info.type, "ROOT", 4) ) {
			sts = om$send ( 
				msg	 = message GRvg.GRgetsymb(&msg, &symb),
                                senderid = NULL_OBJID,
                                targetid = macIDs[i].objid,
                                targetos = macIDs[i].osnum );

			if( !(msg&1) ) continue;

			symb.display_attr.color = 6;
			symb.level = 301;
			sts = om$send ( 
				msg	 = message GRvg.GRputsymb(&msg, &symb),
				senderid = NULL_OBJID,
				targetid = macIDs[i].objid,
				targetos = macIDs[i].osnum);
		}
	}

	retFlag = 1;
wrapup:
	_FREE(macIDs);
	return retFlag;
}

end implementation Root;

