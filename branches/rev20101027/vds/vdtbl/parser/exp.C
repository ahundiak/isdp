/* $Id: exp.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdtbl/parser/ exp.c
 *
 * Description:
 *  	Standalone interactive testing program for attribute expression
 *		interpreter
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: exp.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1996/06/08  00:02:42  pinnacle
 * Replaced: vdtbl/parser/exp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/08/21  18:51:42  pinnacle
 * Replaced: vdtbl/parser/exp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:33:50  pinnacle
 * Replaced: vdtbl/parser/exp.C for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  21:06:12  pinnacle
 * Created: vdtbl/parser/exp.C by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/29/95	tlb		created file
 *	07/27/95	tlb		Added func for attributes,
 *						verbose, printing
 *	08/19/95	tlb		Added unit conversion func,
 *					Added memory allocation func.
 *					Added stubs for object, db functions
 * --------------------------------------------------------------------*/
#include <stdio.h>
#include <string.h>
#include "v_drwproto.h"
#include "VDexpdef.h"

#define BUF_LEN		256
char 	buffer [BUF_LEN] ;


/* main test routine */
main ( int		 argc,
   	char		 *argv[])
{
	long			status;
	char 			*str;
	struct GRobj_env	list[2];
	struct GRobj_env	*obj_list;
	VD_execRes		value;
	int			num_obj;
	char			*def_argv = "2";

	printf ("Interactive Query Test\t(type 'q' to end)\n\n");

	if (!argc)
		argv[1] = def_argv;

        switch (argv[1][0]) {
		case '0': 	num_obj = 0; 
				obj_list = NULL;
				break;

		case '1': 	num_obj = 1; 
				list[0].obj_id.osnum  = 2;
				list[0].obj_id.objid  = 101;
				obj_list = list;
				break;

		default: 	num_obj = 2; 
				list[0].obj_id.osnum  = 2;
				list[0].obj_id.objid  = 101;
				list[1].obj_id.osnum  = 2;
				list[1].obj_id.objid  = 202;
				obj_list = list;
				break;
		}


	/* read 1st query */
	printf ("query>");
	str = gets (buffer);

	while (str != NULL && strcmp(buffer, "quit") ) {

		printf ("'%s'\n", str);

		/* skip comments */
		if (buffer[0] != '#') {
			status = VD_expParse (buffer, TRUE, VD_EXP_VERBOSE,
						num_obj, list, &value);
			VD_drwVerbValType( "\t\t\t\t-> %@", &value );
			printf ("\t%s\n", (status == VD_STATUS_OK) ? "OK" :
				((status == VD_STATUS_WARN ) ? "WARN" : "ERROR" ));
			}

		printf (">");
		str = gets (buffer);
		}

}

#include <stdlib.h>

#ifdef FOO
/*=======Copied ======================================================*/
/* copied from vdmisc/VDstringUtil.C */

char *VD_strncpy( toStr, fromStr, nchars, truncated )

char            *toStr ;
const char      *fromStr ;
register int    nchars,
                *truncated ; {

/*
Abstract
        Copies at most 'nchars - 1' characters of `fromStr' to `toStr' and
        terminates `toStr' with a '\0'. If truncation has occurred,
        `*truncated' is set to TRUE else it is set to FALSE.
Arguments
        OUT     char            *toStr          Destination string.
        IN      const char      *fromStr        Origin string.
        IN      int             nchars          Size of `toStr'.
        OUT     int             *truncated      TRUE/FALSE.
Returns
        `toStr'.
Note
        `toStr' must handle at least `nchars' characters (including the
space
        for the trailing '\0' ).
*/

        if( !fromStr && nchars ) {
                *toStr = '\0' ;
                truncated = 0 ;
        } else {
                nchars-- ;
                strncpy( toStr, fromStr, nchars )[nchars] = '\0' ;
                *truncated = strlen( fromStr ) > nchars ;
        }

        return toStr ;

} /* VD_strncpy */
#endif

/*=======Faked ======================================================*/
char *
VD_malloc ( 	int	size,
		int	line,
		char 	* file)
{ return (malloc(size)); }

char *
VD_calloc ( 	int	size,
		int	line,
		char 	* file)
{ return (calloc ( (unsigned )1, (unsigned) size)); }

char *
VD_realloc ( 	char	*ptr,
		int	size,
		int	line,
		char 	* file)
{ return (realloc ( ptr, (unsigned) size)); }

void
VD_free ( 	char	*ptr,
		int	line,
		char 	* file)
{ free(ptr); }


EX_filename1( char *name, int len )
{
	strncpy (name, "Interactive", len);
	return (MSSUCC);
}
/*-----------------------------*/
#include "OMerrordef.h"
#include "ACattrib.h"			/* types for ACrg_coll */
#include "vdparmacros.h"		/* vd$review_parameters */

int
VDreviewParams (  long             *pMsg,
                      struct GRid      *pComponent,
                      int               NbParams,
                      struct ACrg_coll *pList,
                      struct GRmd_env  *pMdEnv )
{
	*pMsg = MSSUCC;

	/* Fake it for now - value based on first char of attr name */
	switch (pList->name[0]) {
		case 'd'|'D':
			pList->desc.type = AC_ATTRIB_DOUBLE;
			pList->desc.value.att_exp = 1.99;
			break;
		case 'n'| 'N':
			pList->desc.type = AC_ATTRIB_TYPE_NOT_DEF;
			*pMsg = MSFAIL;
			break;
		default:
			pList->desc.type = AC_ATTRIB_TEXT;
			strcpy (pList->desc.value.att_txt, pList->name);
			break;
		};
	return OM_S_SUCCESS;
}
/*-----------------------------*/
void
VD_expEvalName (struct GRobj_env   	obj_env,
		VD_execRes		*res)
{
	res->type = VD_string;
	strcpy (res->_sval, "VDequidef (desk)");
} 

/*-----------------------------*/
extern int
VD_unit2sys	(	long			*msg,
			char			*table,
			char			*unit,
			double			*p_value )
{
	char 	*c;
	double 	d;

	*msg = MSSUCC;

	d = strtod (table, &c);
	while (isspace(*c))
		c++;
	if (strcmp (unit, "DISTANCE")) {
		*msg = MSFAIL;
		goto wrapup;
		}

	if (!strcmp (c, "m"))
		*p_value = d * 36;
	else if (!strcmp (c, "cm"))
		*p_value = d / 2.54;
	else {
		printf ("\tStandalone test only supports 'm' and 'cm'\n");
		*msg = MSFAIL;
		}
wrapup:

	return *msg & 1;
}

/*-----------------------------*/
extern int
VD_sys2unit	(	long			*msg,
			char			*table,
			char			*unit,
			double			*p_value )
{
	char 	*c;
	double 	d;

	*msg = MSSUCC;

	d = strtod (table, &c);
	while (isspace(*c))
		c++;
	if (strcmp (unit, "DISTANCE")) {
		*msg = MSFAIL;
		goto wrapup;
		}

	if (!strcmp (c, "m"))
		*p_value = d / 36;
	else if (!strcmp (c, "cm"))
		*p_value = d * 2.54;
	else
		*msg = MSFAIL;
wrapup:

	return *msg & 1;
}
/*=======Stubs ======================================================*/
int VDyydrwlineno;
int VDyydrwnerrs;

int
VD_getObjVal	(long			*msg,
		const struct GRobj_env	*object,
		VD_execRes		*value )
{return MSSUCC;}

const char *VD_drwKwFromTokType ( int wp) 	
{ return "keyword";}

int VD_drwIsNewExtraction() 			
{return TRUE;}

void VD_drwSetExtractionFlg( int flag ) 	
{}

FILE * VD_openFile(
	long		*msg ,
	char		*filename,
	char		*openType ) 	
{return stdout;}

char	*VD_drwGetInputFileName __(( void )) 	
{return "file";}

int VD_pplLoad(char *ppl_name, char *entry, struct GRid *ppl_id) 
{return FALSE;}
int VD_pplRun(char *ppl_name, char *entry, struct GRid ppl_id, int *val)
{ return FALSE;}
int VD_pplPushArgs(int num, void **list, int *size)
{ return FALSE;}
int VD_pplDelete(struct GRid ppl_id)
{ return FALSE;}


#include "PDUerror.h"			/* PDM_S_SUCCESS */
#define NULL_OBJID	0
/* ---------------------------------------------------------------*/
/* Initialize object list if needed
 *	there must be at least one object in the list
 */
void
VD_expObjInit ( int			*num_objs,
		struct GRobj_env 	*Obj)
{
	if (! *num_objs) {

		/* Create a null object env */
		Obj->obj_id.objid = NULL_OBJID;
		Obj->obj_id.osnum = 0;
 		Obj->mod_env.md_id.objid = 1;
                Obj->mod_env.md_id.osnum = 0;

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
	int 	junk;
	junk = pos;

	res->type = VD_string;
	*res->_sval = '\0';

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		strcpy (res->_sval, "None");
		return;
		}

	strcpy (res->_sval, "obj_name");
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

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) 
		return;	

	strcpy (res->_sval, "macro_name");
}

/* ---------------------------------------------------------------*/
void
VD_expObjCurFile ( struct GRobj_env       obj_env,
		 int			pos,
		 VD_execRes		*res 	)
{
	int 		junk;
	struct GRobj_env 	Obj;

	junk = pos;
	Obj.obj_id.objid = obj_env.obj_id.objid;


	res->type = VD_string;
	strcpy (res->_sval, "file_name");
}
/* ---------------------------------------------------------------*/
/* Evaluate object file name
 */
void
VD_expObjFile 	(struct GRobj_env 	obj_env,
		 int			pos,
		 VD_execRes 		*res 	)
{
	res->type = VD_string;
	*res->_sval = '\0';

	/* syntax check */
	strcpy (res->_sval, "obj_file_name");
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
	int 	junk;
	junk = pos;

	res->type = VD_string;
	*res->_sval = '\0';

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) 
		return;	

	strcpy (res->_sval, "dynamic_table");
}
/* ---------------------------------------------------------------*/
/* Find assembly name of file for a given object
 */
void
VD_expObjPdmId ( struct GRobj_env       obj_env,   /* I: object */
		 int			pos,
	    	 VD_execRes		*res)
{

	res->type = VD_string;
	*res->_sval = '\0';

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) 
		return;	

	strcpy (res->_sval, "pdmid");
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
	VD_execRes		Attr;
	char			*prefix;
	int 	junk;
	junk = pos;

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		return;
		}

	res->type = VD_string;
	strcpy (res->_sval, "cattr");
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
	int 	junk;
	junk = pos;

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) {
		res->type = VD_null;
		return;
		}
	res->type = VD_string;
	strcpy (res->_sval, "attr");
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
	int 	junk;
	junk = pos;

	/* Null object */
	if (obj_env.obj_id.objid == NULL_OBJID) 
		return;

	res->type = VD_string;
	strcpy (res->_sval, "print_attr");
}

/*--------------VDexpDb.C ------------------------------------------*/
void
VD_expDbSelect ( const VD_drwArgLst		*list,
		 int				pos,
	    	 VD_execRes			*res)
{
	long		sts;
	VD_tktxt 	query ;
	int		trunc;

	/* empty  list */
	if (!list)  {
		VD_expReportError ( pos, res, "No query specified");
		return;
		}

	/* syntax check */
	if (!XFLAG) {
		res->type = VD_string;
		strcpy (res->_sval, "db_select_result");
		return;
		}

	/* construct query */
	query[0] = '\0';
        while( list ) {

		/* convert to string */
		if (!VD_expStrncat (query, list->arg, &trunc))
			goto wrapup;

		if (trunc) {
			VD_expReportError ( pos, res, "Query too long");
			goto wrapup;
			}
                list = list->next ;
	 	}

	/* execute query */
	sts = VD_expDbQuery (query, pos, res);

wrapup:
	return ;

}
/* ---------------------------------------------------------------*/
/* execute SQL select on dynamic table
 *	dyn_select (<attr> )
 *	dyn_select (<attr> , <dyanamic table name>)
 */
void
VD_expDbDynSelect (   const VD_drwArgLst		*list,
			int				pos,
			VD_execRes			*res)
{
	VD_execRes	Str;
	VD_tktxt 	query, buf ;
	int		trunc;

	/* empty  list */
	if (!list) goto wrapup;

	/* syntax check */
	if (!XFLAG) {
		res->type = VD_string;
		strcpy (res->_sval, "dyn_select_result");
		return;
		}

	/* construct query */
	strcpy (query, "select ");

	/*
 	 * Attr name
	 */
	if (!VD_expStrncat (query, list->arg, &trunc))
		goto wrapup;
	if (trunc) goto trunc;

	/*
 	 * Table name
	 */
	VD_strncat ( query,  " from ", VD_K_tokMAX_SIZE, &trunc);
	/* No table given */	
	if (!list->next) {
		VD_expObjDynTable (CUR_OBJ, pos, &Str);
		if (!VD_expStrncat ( query, Str, &trunc))
			goto wrapup;
		}
	/* table is given */	
	else {
    		list = list->next ;
		if (!VD_expStrncat (query, list->arg, &trunc))
			goto wrapup;
		}
	if (trunc) goto trunc;


	/*
 	 * Objid
	 */
	sprintf (buf, " where comp_seqno = %d and ", CUR_OBJ.obj_id.objid);
	VD_strncat ( query, buf, VD_K_tokMAX_SIZE, &trunc);
	if (trunc) goto trunc;

	/*
	 * Filename (Assembly name)
 	 */
	VD_expObjPdmId(CUR_OBJ, pos, &Str);
	/* Check for error here */

	VD_expStrncat (query, Str, &trunc);
	if (trunc) goto trunc;

	/* execute query */
	if (VD_expDbQuery (query, pos, res) == -1 )
		VD_expPrintWarn (
			"Purge dynamic table to remove multiple values") ;
wrapup:
	return ;
trunc:
	/* query was truncated */
	VD_expReportError ( pos, res, "Query too long");
	goto wrapup;
}

int
VD_expDbQuery (	VD_tktxt	query,
		int		pos,
		VD_execRes	*res)
{
	printf ("query: %s\n", query);
	res->type = VD_string;
	strcpy (res->_sval, "query_result");
	return (TRUE);
}
