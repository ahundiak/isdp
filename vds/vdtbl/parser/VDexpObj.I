/* $Id: VDexpObj.I,v 1.2 2001/07/27 22:29:36 ylong Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser / VDexpObj.I
 *
 * Description:
 *	Object space functions
 *	
 *	Extra junk variables used to quiet the compiler about unused parameters
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDexpObj.I,v $
 *	Revision 1.2  2001/07/27 22:29:36  ylong
 *	TR5473
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/01/06  18:11:02  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by yzhu for vds
#
# Revision 1.4  1998/01/05  21:09:54  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by s250_int for vds
#
# Revision 1.3  1997/10/07  13:15:58  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by mdong for vds
#
# Revision 1.2  1997/07/09  15:59:12  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/06/10  18:00:58  pinnacle
# Replaced: vdtbl/parser/*Obj.I for:  by v240_int for vds.240
#
# Revision 1.7  1996/06/10  17:52:36  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by tlbriggs for vds.240
#
# Revision 1.6  1996/06/09  15:44:14  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by v240_int for vds.240
#
# Revision 1.5  1996/06/09  15:40:56  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by v240_int for vds.240
#
# Revision 1.4  1996/06/08  00:00:18  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by tlbriggs for vds.240
#
# Revision 1.3  1996/05/03  19:42:42  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by tlbriggs for vds.240
# Revision 1.3  1996/05/03  19:42:42  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by tlbriggs for vds.240
#
# Revision 1.2  1995/09/26  00:41:54  pinnacle
# Replaced: vdtbl/parser/VDexpObj.I for:  by tlbriggs for vds.240
#
# Revision 1.1  1995/08/21  19:00:44  pinnacle
# Created: vdtbl/parser/VDexpObj.I by tlbriggs for vds.240
#
 *
 * History:
 *	08/19/95   tlb	created
 *	09/26/95   tlb	Change EvalName to return only basename of object
 *	04/20/96   tlb  Add expEvalMacroName
 *	05/08/96   tlb  Add expEvalObjFile
 *	05/30/96   tlb  Add VD_expObjInit, VD_expObjDynTable, 
 *			Add functions from VDexpFunc.C: VD_expEvalAttr
 *			Rename VD_expEval* to VD_expObj*
 *			Add syntax checking cases
 *			Add position argument to all functions
 *			Change verbose attribute print
 *	06/10/96   tlb  Add check for ACdb_info ancestrey
 *			Change attr functions to return null on syntax check
 *
 *************************************************************************/
class implementation VDSroot;

#include <string.h>
#include "VDScheckin.h"			/* VDGetDynTableName args, return */
#include "ACattrib.h"			/* AC_ATTRIB_TEXT */

#include "exmacros.h"			/* ex$get_cur_mod */
#include "DIprims.h"			/* di$give_pathname */
#include "PDUerror.h"			/* PDM_S_SUCCESS */
#include "VDBload.h"			/* VDB_MAX_CATALOG_LEN */
#include "VDdrwlo.h"			/* for VDdrwlo_pr.h*/
#include "VDdrwlo_pr.h"			/* VD_Return_Attr */
#include "v_strngproto.h"		/* VD_strncpy, VD_strncat, ..*/
#include "v_miscmacros.h"		/* VD_SEND.. */
#include "v_miscmacros.h"		/* VD_SEND */
#include "vdparmacros.h"		/* vd$get_parameters */
#include "vdtr_macros.h"		/* Tree Macros */
#include "v_dbgmacros.h"		/* vd$get_parameters */

#include "VDexpdef.h"

extern  GRclassid     OPP_ACdb_info_class_id;

/* ---------------------------------------------------------------*/
/* Initialize object list if needed
 *	there must be at least one object in the list
 */
void
VD_expObjInit ( int			*num_objs,
		struct GRobj_env 	*Obj)
{
	long	msg;

	if (! *num_objs) {

		/* Create a null object env */
		Obj->obj_id.objid = NULL_OBJID;
		Obj->obj_id.osnum = OM_Gw_current_OS;
 		ex$get_cur_mod( id    = &Obj->mod_env.md_id.objid,
                		osnum = &Obj->mod_env.md_id.osnum);
 		Obj->mod_env.md_env.matrix_type = MAIDMX;
 		MAidmx( &msg, Obj->mod_env.md_env.matrix) ;

		/* reset number of objects, object list */
		*num_objs = 1;
		vd_expGlobals.objList = Obj;
		}
}
/* ---------------------------------------------------------------*/
/* Get objid
 */
void
VD_expObjId  ( struct GRobj_env   	obj_env,
		int			pos,
		VD_execRes		*res)
{
	int 	junk;
	junk = pos;

	res->type = VD_int;
	res->_ival =  obj_env.obj_id.objid;
}
/* ---------------------------------------------------------------*/
/* Get osnum
 */
void
VD_expObjOsnum ( struct GRobj_env   	obj_env,
		 int			pos,
		 VD_execRes		*res)
{
	int 	junk;
	junk = pos;

	res->type = VD_int;
	res->_ival =  obj_env.obj_id.osnum;
}
/* ---------------------------------------------------------------*/
/* Evaluate object name
 *	currently, same as 'basename' in vddraw/drw/VDdrwfcnsupp.I
 */
void
VD_expObjName (struct GRobj_env   	obj_env,
		int			pos,
		VD_execRes		*res)
{
	long			sts, rc ;
	GRname			name ;
	struct GRobj_info	info;
	char			*basename = NULL;
	char			*last = NULL;
	int			trunc;
	int 	junk;
	junk = pos;

	res->type = VD_string;
	*res->_sval = '\0';

	/* syntax check */
	if (!XFLAG) {
		strcpy (res->_sval, "obj_name");
		return;
		}

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		strcpy (res->_sval, "None");
		return;
		}

	sts = _VD_SEND_OBJN ( 	obj_env.obj_id,
				GRgraphics.GRgetname( &rc, name ));

	/* return basename if possible */
	if (sts & rc & 1) {
        	/*
         	 * Extract basename from full pathname.
         	 */
        	if( basename = strrchr( name, DIR_G_car_dir ) )
			basename++ ;
        	else
			basename = name ;

        	/*
         	 * Remove trailing numbers
         	 */
        	if( last = strrchr( basename, '_' ) )
			*last ='\0';
		}

	/* else return macro type */
	else {
		sts = _VD_SEND_OBJN (   obj_env.obj_id,
					GRgraphics.GRgetobjinfo( &rc, &info ));
		if( !( sts & 1 & rc ) )   {
			res->type = VD_string;
			*res->_sval = '\0';
			return;
			}
		else			  basename = info.type;
		}


        VD_strncpy( res->_sval, basename, VD_K_tokMAX_SIZE, &trunc ) ;
}

/* ---------------------------------------------------------------*/
/* Evaluate macro name
 */
void
VD_expObjMacroName 	(struct GRobj_env 	obj_env,
			int			pos,
			VD_execRes 		*res 	)
{
	int 	junk;
	junk = pos;

	res->type = VD_string;
	*res->_sval = '\0';

	/* syntax check */
	if (!XFLAG) {
		strcpy (res->_sval, "macro_name");
		return;
		}

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		return;	
		}

	/* Get ACcpx object macro name */
	if (!VD_drwGetACcpxInfo (&obj_env.obj_id, res->_sval, TRUE)) {
		if (!VD_drwGetGRhdrInfo( &obj_env.obj_id, res->_sval, TRUE )) {
			*res->_sval = '\0';
			}
		}
}
/* ---------------------------------------------------------------*/
void
VD_expObjCurFile ( struct GRobj_env       obj_env,
		 int			pos,
		 VD_execRes		*res 	)
{
	VD_tktxt	str;
	char *		ptr;
	int 		junk;
	struct GRobj_env 	Obj;
	extern char * strrchr ();

	junk = pos;
	Obj.obj_id.objid = obj_env.obj_id.objid;


	if (!ex$filename (name = str, len = VD_K_tokMAX_LENG)) {
		VD_expPrintWarn ("Filename too long");
		res->type = VD_null;
		}
	else {
		/* set ptr to basename */
		ptr = strrchr (str, '/');
		if (!ptr)
			ptr = str;	/* already have basename */
		else
			ptr++;		/* set to actual name */
		strcpy (res->_sval, ptr);
		res->type = VD_string;
		}
}
/* ---------------------------------------------------------------*/
/* Evaluate object file name
 */
void
VD_expObjFile 	(struct GRobj_env 	obj_env,
		 int			pos,
		 VD_execRes 		*res 	)
{
	int		sts;
    	GRname 		path_name;
	int			trunc;

	res->type = VD_string;
	*res->_sval = '\0';

	/* syntax check */
	if (!XFLAG) {
		strcpy (res->_sval, "obj_file_name");
		return;
		}

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		return;	
		}

    	sts = di$give_pathname( osnum 		= obj_env.obj_id.osnum,
	    		     	pathname	= path_name );
    	if( sts != DIR_S_SUCCESS ) {
		di$report_error( sts 	 = sts,
				 comment = "Error in di$give_pathname" );
		VD_expReportError ( pos, res, "Cannot evaluate object file name");
		}
	else
        	VD_strncpy( res->_sval, strrchr(path_name, ':' )+1,
						VD_K_tokMAX_SIZE, &trunc ) ;
}
/*------------------------------------------------------------------*/
/* Find dynamic table name
 *	Returns: TRUE/FALSE
 */
void
VD_expObjDynTable ( 	struct GRobj_env        obj_env,   /* I: object */
			int			pos,
		 	VD_execRes 		*res 	)
{
	int  			nbCatalogs, sts;
	struct GRid		obj;
 	struct ACobj_info_1 	obj_info_1;
	struct vdscatalog 	*VdsCatalogs = NULL;
	int 	junk;
	junk = pos;

	res->type = VD_null;

	/* syntax check */
	if (!XFLAG) {
		strcpy (res->_sval, "dynamic_table");
		return;
		}

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		return;	
		}

	obj.objid = obj_env.obj_id.objid;
	obj.osnum = obj_env.obj_id.osnum;

	if (!vd_$is_ancestry_valid (	object =  &obj,
					classid = OPP_ACdb_info_class_id)){
		res->type = VD_null;
		VD_expPrintWarn ("object cannot be posted to a dynamic table");
		return;	
		}

  	VdsGet_db_info( &obj, &obj_info_1, 1 );
 	if (obj.objid == NULL_OBJID) goto wrapup;

	/* If connected to the database - try to read VDSCATALOGS */
	if ( VDSverify_login () == PDM_S_SUCCESS) {
  		VDReadVdsCatalogs( &nbCatalogs, &VdsCatalogs );
		/* ignore return status - vdscatalogs table may not exist */
		}
	else
		VD_expPrintWarn ("using default mapping - not connected to the database ") ;

  	sts = VDGetDynTableName( obj_info_1.quantity, obj, obj_env.mod_env,
                           REG_CHECKIN, REP_MODEL, nbCatalogs, VdsCatalogs,
                           res->_sval );
  	if( sts == VDS_E_DYNAMIC_TABLE_NOT_FOUND || res->_sval == NULL )
		res->type = VD_null;
	else
		res->type = VD_string;

wrapup:
	_FREE(VdsCatalogs);
	return;
}
/* ---------------------------------------------------------------*/
/* Find assembly name of file for a given object
 */
void
VD_expObjPdmId ( struct GRobj_env       obj_env,   /* I: object */
		 int			pos,
	    	 VD_execRes		*res)
{
	VD_execRes	Str;
	int		sts;
	char		catalog[VDB_MAX_CATALOG_LEN];
	char		partid[VDB_MAX_CATALOG_LEN];
	char		revision[VDB_MAX_CATALOG_LEN];
	VD_tktxt 	buf ;

	extern 		PDMGetPartInfoGivenFileName(), _pdm_status();

	res->type = VD_string;
	*res->_sval = '\0';

	/* syntax check */
	if (!XFLAG) {
		strcpy (res->_sval, "pdmid");
		return;
		}

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		return;	
		}

	/* verify user is connected to database */
	if ( VDSverify_login () != PDM_S_SUCCESS) {
		VD_expReportError ( pos, res, "No connection to database");
		UI_status ( "Database login required to evaluate expression");
		return;
		}

	VD_expObjFile (obj_env, pos, &Str);
    	sts = PDMGetPartInfoGivenFileName(Str._sval, catalog, partid, revision);
    	_pdm_status("PDMGetPartInfoGivenFileName", sts);

	if (sts == PDM_S_SUCCESS) {
 		sprintf (buf,"%s = '%s' and %s = '%s' and %s = '%s'",
				"assembly_cat", catalog, 
				"assembly_nam", partid,
				"assembly_ver", revision);
		strcpy (res->_sval, buf);
		}
	else
		VD_expPrintWarn ( "file not checked into PDU");
}

/* ---------------------------------------------------------------*/
/* Evaluate coded attribute value
 *	Called directly by the interpreter
 */
void
VD_expObjCodedAttr ( struct GRobj_env   	obj_env,
		 	VD_execRes		*attr,
			int			pos,
		 	VD_execRes		*res,
			int			is_long_flag)
{
	int			sts;
	long			msg;
	struct ACrg_coll	list;
	VD_execRes		Attr;
	char			*prefix;
	int 	junk;
	junk = pos;

	/* syntax check */
	if (!XFLAG) {
		res->type = VD_null;
		goto wrapup;
		}

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		goto wrapup;
		}

	/* Evaluate attribute values */
	strcpy ( list.name, attr->_sval);
	sts = VD_Return_Attr (&msg, 1, &(obj_env.obj_id), &list,
					&(obj_env.mod_env), is_long_flag);
	if (! (msg & sts & 1))
		res->type = VD_null;
	else {
		switch (list.desc.type){
			case AC_ATTRIB_TEXT:
				res->type = VD_string;
				strcpy (res->_sval, list.desc.value.att_txt);
				break;
			case AC_ATTRIB_DOUBLE:
				res->type = VD_double;
				res->_dval = list.desc.value.att_exp;
				break;
			case AC_ATTRIB_TYPE_NOT_DEF:
			default:
				res->type = VD_null;
			}
		}
wrapup:
	if (VERB) {
		prefix = (is_long_flag) ? "#" : "##";
		Attr.type = VD_string;
		strcpy (Attr._sval, prefix);
		strcat (Attr._sval, attr->_sval);
		VD_expPrintAttr (&Attr, res);
		}
}
/* ---------------------------------------------------------------*/
/* Evaluate attribute value
 *	Called directly by the interpreter
 */
void
VD_expObjAttr ( struct GRobj_env   	obj_env,
		 VD_execRes		*attr,
		 int			pos,
		 VD_execRes		*res)
{
	int			sts;
	long			msg;
	struct ACrg_coll	list;
	int 	junk;
	junk = pos;

	/* syntax check */
	if (!XFLAG) {
		res->type = VD_null;
		goto wrapup;
		}

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		goto wrapup;
		}
 
	/* Evaluate attribute values */
	strcpy ( list.name, attr->_sval);

	if( !strncmp( list.name, "SA_MOD:",7) ){

		/*
		 * Check if select object is not a Tree object.
		 * If a TREE object, process is OK.
		 * Any Other object, remove SA_MOD from attribute name.
		 */
		__DBGpr_str(" Attr Name ", list.name );

		if( !vdtr$IsTreeAncestry(nodeID = &obj_env.obj_id) ){

			/* Remove SA_MOD from attribute name */
			strcpy( list.name, &(attr->_sval[7]) );
		}
	}
		
	sts = vd$review_params (pMsg 		= &msg,
				pComponent 	= &(obj_env.obj_id),
				NbParams 	= 1,
				pList		= &list,
				pMdEnv		= &(obj_env.mod_env) ) ;
        if (! (msg & sts & 1))
                res->type = VD_null;
        else {
                switch (list.desc.type){
                        case AC_ATTRIB_TEXT:
                                res->type = VD_string;
                                strcpy (res->_sval, list.desc.value.att_txt);
                                break;
                        case AC_ATTRIB_DOUBLE:
                                res->type = VD_double;
                                res->_dval = list.desc.value.att_exp;
                                break;
                        case AC_ATTRIB_TYPE_NOT_DEF:
                        default:
                                res->type = VD_null;
                        }
                }
wrapup:
	if (VERB)
		VD_expPrintAttr (attr, res);

}
/* ---------------------------------------------------------------*/
/* Print object attributes */

void
VD_expObjPrintAttr (	struct GRobj_env        obj_env,
			int			pos,
		 	VD_execRes		*res)
{
      	int             	i, count;
      	IGRlong            	sts, msg;
      	struct ACrg_coll   	*list;
	int 	junk;
	junk = pos;

	/* syntax check */
	if (!XFLAG) {
		res->type = VD_string;
		strcpy (res->_sval, "attr");
		goto wrapup;
		}
 
	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		return;	
		}

       	sts = vd$get_parameters(
			  sts = &msg,
                          object = &(obj_env.obj_id),
                          md_env = &(obj_env.mod_env),
                          count = &count );
	if (! (msg & sts & 1)) goto wrapup;

	/* no attributes */
	if (! count) {
		printf ("\tno attributes\n");
		goto wrapup;
		}

       	list = (struct ACrg_coll *) _MALLOC( count,  struct ACrg_coll );
	_CheckMem (list, sts, msg, wrapup);

       	sts = vd$get_parameters(
		    	  sts = &msg,
                          object = &(obj_env.obj_id),
                          md_env = &(obj_env.mod_env),
                          plist  = list,
                          size = count,
                          count = &count );
	if (! (msg & sts & 1)) goto wrapup;

	/* print attributes */
	for (i=0; i<count; i++)  {
		switch (list[i].desc.type){
			case AC_ATTRIB_TEXT:
				printf ("\t%s : %s\n", list[i].name,
						list[i].desc.value.att_txt);
				break;
			case AC_ATTRIB_DOUBLE:
				printf ("\t%s : %d\n", list[i].name,
						list[i].desc.value.att_exp);
				break;
			case AC_ATTRIB_TYPE_NOT_DEF:
			default:
				printf ("\t%s : ??\n", list[i].name);
			}
		}
wrapup:
	VD_expSetTrue (res);
	return;
}

/* ---------------------------------------------------------------*/
/* Get Object Catalog, PartId and revision based on OSNUM.
 */
VD_expOsnumPDMId( struct GRid		*objId,   /* I: object */
		 char			*catalog,
		 char			*partid,
		 char			*revision )
{
	int		sts;
	GRname		path_name ;
	char		lCatalog[VDB_MAX_CATALOG_LEN];
	char		lPartid[VDB_MAX_CATALOG_LEN];
	char		lRevision[VDB_MAX_CATALOG_LEN];
	extern 		PDMGetPartInfoGivenFileName(), _pdm_status();

        SetProc ( VD_expOsnumPDMId ); Begin
	/* Null object */
	if (objId->objid == NULL_OBJID) {
		return	FALSE;
	}

	/* verify user is connected to database */
	if ( VDSverify_login () != PDM_S_SUCCESS) {
		UI_status ( "Database login required to evaluate expression");
		return FALSE;
	}

        sts = di$give_pathname( osnum           = objId->osnum,
                                pathname        = path_name );
	if( !(sts & 1 )){	return FALSE ; }
	__DBGpr_str(" PathName " , path_name );

    	sts = PDMGetPartInfoGivenFileName(path_name,
					lCatalog, lPartid, lRevision);
    	_pdm_status("PDMGetPartInfoGivenFileName", sts);
	if (sts == PDM_S_SUCCESS) {
		if( catalog )	strcpy( catalog,	lCatalog );
		if( partid  )	strcpy( partid ,	lPartid );
		if( revision )	strcpy( revision,	lRevision );
	}
	else
		return FALSE ;

	End
	return TRUE ;
}

end implementation VDSroot;
