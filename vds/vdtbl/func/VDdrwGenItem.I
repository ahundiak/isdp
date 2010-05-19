/* $Id: VDdrwGenItem.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $ */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdtbl/func/VDdrwGenItem.I
 *
 * Description:
 *      Function which invokes the  "Generate Item Number Subfornm "
 *
 *
 * Algorithm
 *	Initialize query/prefix data structures
 *	Process user input from form
 *	Mark all rows R_GENERATE which lack item numbers or are < relabel_num
 *	Generate list of all objects for rows with R_GENERATE
 *	For all prefix queries:
 *		Run queries on all objects without prefixes
 *		Assign prefixes to objects which match
 *	Assign null prefix to all rows where generate = TRUE without prefixes
 *	Assign prefix to row if all objects match else null prefix
 *	Generate item numbers for rows with R_GENERATE
 *
 * Notes
 *	Functions are ordered with interface functions at the end of file,
 *	to allow auxillery functions to be declared as static.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwGenItem.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:27  cvs
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
# Revision 1.15  1996/05/08  22:26:40  pinnacle
# Replaced: vdtbl/func/VDdrwGenItem.I for:  by jwfrosch for vds.240
#
# Revision 1.14  1995/10/12  17:43:02  pinnacle
# Replaced: vdtbl/func/VDdrwGenItem.I for:  by tlbriggs for vds.240
#
# Revision 1.13  1995/09/25  23:03:50  pinnacle
# Replaced: vdtbl/func/VDdrwGenItem.I for:  by sundar for vds.240
#
# Revision 1.12  1995/09/18  20:14:06  pinnacle
# Replaced: vdtbl/func/*Item.I for:  by tlbriggs for vds.240
#
# Revision 1.11  1995/09/11  20:40:16  pinnacle
# Replaced: vdtbl/func/*Item.I for:  by tlbriggs for vds.240
#
# Revision 1.10  1995/09/11  15:57:40  pinnacle
# Replaced: vdtbl/func/*Item.I for:  by tlbriggs for vds.240
#
# Revision 1.9  1995/09/07  13:29:58  pinnacle
# Replaced: vdtbl/func/*Item.I for:  by tlbriggs for vds.240
#
# Revision 1.8  1995/09/06  21:19:12  pinnacle
# Replaced: vdtbl/func/VD*Item.I for:  by tlbriggs for vds.240
#
# Revision 1.7  1995/08/21  18:56:38  pinnacle
# Replaced: vdtbl/func/*Item.I for:  by tlbriggs for vds.240
#
# Revision 1.6  1995/07/28  18:47:46  pinnacle
# Replaced: vdtbl/func/*GenItem.I for:  by tlbriggs for vds.240
#
# Revision 1.2  1995/07/20  19:52:44  pinnacle
# Replaced: vdtbl/func/*GenItem.I for:  by tlbriggs for vds.240
#
 * History:
 *      07/05/95        tlb	Creation
 *
 *	07/20/95	tlb	Initailize global lists,
 *				Remove processing of referennce file queries.
 *				Remove compilation warnings
 *
 * 	07/24/95	tlb	Error in call to vd$qry_get_id_list,
 *				Fixup calls to free
 *				Bug in AssignPrefixes for all null summary row
 *
 *	07/25/95	tlb	Fix bug in VD_parseItemNum
 *	07/27/95	tlb	Fix bug in VD_parseItemNum
 *	07/28/95	tlb	Fix bug in VD_parseItemNum
 *	08/18/95	tlb	Use new memory allocation
 *				Fix bug in combining generating row prefix
 *					from object prefixes
 *	09/06/95	tlb	Modify parseItemNum to return suffix
 *	09/07/95	tlb	Fix bug in comment
 *	09/08/95	tlb     Modify parseItemNum return values
 *				Add user defined prefixes, keep suffixes
 *	09/11/95	tlb  	Fix relabel bug, turn-off debugging
 *	09/18/95	tlb  	Fix null prefix start seq number bug
 *	10/10/95	tlb	Ignore lined-out rows.
 *				Form modifications: add relabel flag, 
 *				  preserve user prefix option
 *
 * -------------------------------------------------------------------*/
class implementation Root;


/* * /
#define	vdsDEBUG	1
#define	vdserrDEBUG	1
#define genDEBUG	1
#define genForm	1
#define genInsert	1
#define genParser	1
#define genTRACE	1
/ * */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"			/* GRid, GRmd_env */
#include "growner.h"		/* GRobj_env */
#include "msdef.h"
#include "FI.h"
#include "AS_status.h"
#include "ACrg_collect.h"	/* ATTR_NAME */

#include "vdqrydef.h"
#include "VDitemNum.h"

#include "v_dbgmacros.h"
#include "v_miscmacros.h"	/* _VD_SEND_* macros */

#include "exmacros.h"		/* exputque */
#include "vdparmacros.h"	/* vd$qry_get_id_list */
#include "vdmemmacros.h"	/* vd$malloc_str_list, vd$free_str_list */
#include "vdparmacros.h"	/* vd$qry_get_mul_objects */

%safe
#include "VX_FIproto.h"	/* COB complains - 'message' used as arg */
%endsafe


from VDquery		import	VDgive_structure;
from VDquery		import	VDgive_query;
from VDquery		import	VDgetPfxInfo;
from ACrg_collect	import	ACgive_structure;



/*-----------------------------------------------------------------------*/
/* Debugging/Diagnostics */
#ifdef genTRACE
	#define genDEBUG	1
#endif

#ifdef genDEBUG
	#define _PRINT_INPUT(s)		Gen_PrintInputRowList(s,v)
	#define _PRINT_QUERY(s)		if (v->debug) Gen_PrintQueryList(s,v)
	#define _PRINT_PREFIX(s)	if (v->debug) Gen_PrintPrefixList(s,v)
	#define _PRINT_OBJ(s)		if (v->debug) Gen_PrintObjList(s,v)
	#define _PRINT_ROW(s)		if (v->debug) Gen_PrintRowList(s,v)
	#define _PRINT_SEARCH(s)	if (v->debug) Gen_PrintSearchList(s,v)
#else
	#define _PRINT_INPUT(s)
	#define _PRINT_QUERY(s)
	#define _PRINT_PREFIX(s)
	#define _PRINT_OBJ(s)
	#define _PRINT_ROW(s)
	#define _PRINT_SEARCH(s)
#endif

/*=======================================================================*
 * Data Structures
 *=======================================================================*/

#define	NOT_DEFINED		-99	/* value is not defined */
#define HAS_PREFIX		-88 	/* has a prefix */

/* ---------------------------
 * Query list
 *	queries with prefixes indexed by priority
 *	sorted by priority
 */
typedef struct {
	struct GRid	qry_obj;	/* objid of query */
	short		pfx_index;	/* index of prefix in prefix_list */
	short		index;		/* index from query */
	char		prefix[VD_ITEMNUM_LEN];		/* prefix string */
    } query_t;

/* ---------------------------
 * Prefix list - display structure
 *	distinct prefixes defined by queries, indexed by prefix index
 *	sorted by prefix - null prefix is always last
 */
typedef struct {
	char	prefix[VD_ITEMNUM_LEN];		/* prefix string */
	short 	is_std;				/* sys-defined - has a query */
	short	largest;			/* largest currently in use */
	short	start_num;			/* start number */
	short	relabel_num;			/* relabel number */
    } prefix_t;

/* ---------------------------
 * Object list
 *	list of all objects from rows to be generated.
 *	indexed by object number <= num_obj
 *	unsorted
 *
 */
typedef struct {
	struct GRobj_env	obj;		/* object */
	short			pfx_index;	/* index of prefix found */
	short			row;		/* row object belongs to */
    } obj_t;

/* ---------------------------
 * Row information
 *	indexed by row number
 *
 *	generate indicates whether item number must be generated
 *		prefix index define prefix assigned
 */
typedef struct {
	short		generate;		/* TRUE/FALSE */
	short		pfx_index;		/* index of prefix found */
	int		cur_num;		/* current sequence number */
	char		cur_prefix[VD_ITEMNUM_LEN];	/* prefix string */
	short		is_std;			/* TRUE/FALSE */
	char		suffix[VD_ITEMNUM_LEN];	/* suffix string */
    } row_t;

/* --------------------------
 * Global data strcture
 */
typedef struct {
	short			keep_user;	/* flag to preserve user pfx */
	short			keep_suffix;	/* flag to preserve suffixes */
	short			null_pfx_index;	/* null prefix index */
	int			num_query;	/* list of queries w prefixes */
	query_t			*query_list;
	int			num_prefix;	/* list of distinct prefixes */
	prefix_t		*prefix_list;
	int			num_obj;	/* list of objects in rows */
	obj_t			*obj_list;
	int			num_search;	/* current search list */
	struct GRobj_env	*search_list;
	int			num_row;	/* list of BOM rows */
	row_t			*row_list;
	VD_itemList_t		*rowList;	/* input row list */
	int			debug;		/* debug flag */
    } data_t;

/*-----------------------------------------------------------------------*/
/* Shortcuts */
#define QRY_PFX(q)	v->query_list[(q)].pfx_index
#define QRY_PREFIX(q)	v->query_list[(q)].prefix
#define QRY_OBJ(q)	v->query_list[(q)].qry_obj

#define P_PREFIX(p)	v->prefix_list[(p)].prefix
#define P_IS_STD(p)	v->prefix_list[(p)].is_std
#define P_LARGEST(p)	v->prefix_list[(p)].largest
#define P_START(p)	v->prefix_list[(p)].start_num
#define P_RELABEL(p)	v->prefix_list[(p)].relabel_num

#define R_GENERATE(r)	v->row_list[(r)].generate
#define R_PFX(r)	v->row_list[(r)].pfx_index
#define R_NUM(r)	v->row_list[(r)].cur_num
#define R_CUR_PREFIX(r)	v->row_list[(r)].cur_prefix
#define R_SUFF(r)	v->row_list[(r)].suffix
#define R_IS_STD(r)	v->row_list[(r)].is_std
#define R_PREFIX(r)	((R_PFX(r) == NOT_DEFINED) ? "-99" : \
			(R_PFX(r) == HAS_PREFIX  ? R_CUR_PREFIX(r) : \
							P_PREFIX(R_PFX(r))))

#define O_PFX(o)	v->obj_list[(o)].pfx_index
#define O_ROW(o)	v->obj_list[(o)].row
#define O_OBJ(o)	v->obj_list[(o)].obj
#define O_PREFIX(o)	((O_PFX(o) == NOT_DEFINED) ? "-99" : P_PREFIX(O_PFX(o)))

#define NULL_PFX_INDEX	v->null_pfx_index

/*************************************************************************
 * 			LOCAL FUNCTIONS
 ************************************************************************?

/*=======================================================================
 * Print routines
 *=======================================================================*/

#ifdef genDEBUG
/*-----------------------------------------------------------------------*/
static void
Gen_PrintPrefixList (char 		*comment,
			data_t		*v)
{
	int	i;

	printf ("\n  --%s:\n   Prefix list: \t%d prefixes\n",
						comment, v->num_prefix);
	for (i=0; i < v->num_prefix; i++)
		printf (
		"\t#%d prefix: '%7s'  std: %c  largest: %3d  start: %3d  relabel: %3d\n",
			i, P_PREFIX(i),
			P_IS_STD(i) ? 'x' : ' ',
			P_LARGEST(i), P_START(i), P_RELABEL(i));
}
/*-----------------------------------------------------------------------*/
static void
Gen_PrintQueryList (char 	*comment,
		    data_t	*v)
{
	int	i;

	printf ("\n  --%s:\n   Query list: \t%d queries\n", comment, v->num_query);
	for (i=0; i < v->num_query; i++)
		printf ("\t#%d object: [%d, %d] index: %d  pfx: %d  prefix: '%s'\n",
			i, QRY_OBJ(i).osnum, QRY_OBJ(i).objid,
			v->query_list[i].index, QRY_PFX(i), QRY_PREFIX(i));
}
/*-----------------------------------------------------------------------*/
static void
Gen_PrintObjList (char 		*comment,
		  data_t	*v)
{
	int	i;

	printf ("\n  --%s:\n   Object list: \t%d objects\n", comment, v->num_obj);
	for (i=0; i < v->num_obj; i++)
		printf(
		"\t#%d object: [%d, %d]   row: %2d  pfx: %3d  prefix: '%s'\n"
			, i,
			v->obj_list[i].obj.obj_id.osnum,
			v->obj_list[i].obj.obj_id.objid,
			v->obj_list[i].row, O_PFX(i), O_PREFIX(i));
}
/*-----------------------------------------------------------------------*/
static void
Gen_PrintSearchList (char 	*comment,
		     data_t	*v)
{
	int	i;

	printf ("\n  --%s:\n  Search list: \t%d objects\n",
							comment, v->num_search);
	for (i=0; i < v->num_search; i++)
		printf( "\t#%2d: [%d,%d]\n",
				i,  v->search_list[i].obj_id.osnum,
				v->search_list[i].obj_id.objid );
}
/*-----------------------------------------------------------------------*/
static void
Gen_PrintRowList (char 		*comment,
		  data_t	*v)
{
	int	i;

	printf ("\n  --%s:\n   Row list: \t%d rows\n", comment, v->num_row);
	for (i=0; i < v->num_row; i++) {
		printf ("\t#%d gen: %d std: %d  pfx: %3d prefix: '%s'",
			i, R_GENERATE(i), R_IS_STD(i), R_PFX(i), R_PREFIX(i));
		printf ("\tnum: %d \tsuffix: %s\n", R_NUM(i), R_SUFF(i));
		}
}

/*-----------------------------------------------------------------------*/
static void
Gen_PrintObjs (	char			*heading,
		struct GRobj_env	*list,
		int			num)
{
	int	i;

	printf ("%s", heading);
	for (i=0; i < num; i++)
		printf ("[%d,%d], ",
			list[i].obj_id.osnum, list[i].obj_id.objid );
	printf ("\n");
}

/*-----------------------------------------------------------------------*/
static void
Gen_PrintInputRowList ( char		*comment,
			data_t		*v)
{
	int	i;

	printf ("\n  --%s:\n   Input rows: \t%d\n", comment, v->num_row);
	for (i=0; i < v->num_row ; i++) {
		printf (
		"\t#%d itemNo: '%7s' lineout: %d modified: %d  num: %d  objs: ",
			i, v->rowList[i].itemNo, v->rowList[i].is_lineout, 
			v->rowList[i].is_modified,
			v->rowList[i].num_objs);
		Gen_PrintObjs ("", v->rowList[i].objs, v->rowList[i].num_objs);
		}
}

#endif genDEBUG

/*-----------------------------------------------------------------------*/

/*=======================================================================*
 * Initialization functions
 *=======================================================================*/

/*
 * Provide routine to retrieve global data in form notification
 */
static void
Gen_GetSetData ( data_t		**v,
		int		set)
{
	static	data_t	*data;

	if (set)
		data = *v;
	else
		*v = data;
}
/*--------------------------------------------------------------------*/
/*
 * Initailize row output, row list
 */
static int
Gen_RowInit ( data_t		*v)
{
	int			row;
	IGRlong			sts = OM_S_SUCCESS;
	IGRlong			msg = MSSUCC;

	/* allocate/initialize row_list
	 *	number of rows is greater than zero
	 */
	v->row_list = _MALLOC(v->num_row, row_t);
	_CheckMem (v->row_list, sts, msg, wrapup);

	/* initialize is_modified in output row list */
	for (row=0; row < v->num_row; row++)  {
		v->rowList[row].is_modified = FALSE;
		R_GENERATE(row) = FALSE;
		R_IS_STD(row) = NOT_DEFINED;
		R_PFX(row) = NOT_DEFINED;
		R_NUM(row) = NOT_DEFINED;
		}
wrapup:
	return (sts & 1);
}
/*--------------------------------------------------------------------*/
/* query list sort function */
static int
Gen_compare_query (const void *elm1,
		   const void *elm2 )
{
	return ( ((query_t *)elm1)->index == ((query_t *)elm2)->index ? 0
		: ((query_t *)elm1)->index < ((query_t *)elm2)->index ? -1 : 1);
}
/*--------------------------------------------------------------------*/
/*
 * load prefixed queries into v->query_list, sort on query index
 *	returns MSFAIL/MSSUCC
 */
static int
Gen_LoadQueries (data_t 	*v)
{
	IGRlong			msg = MSSUCC;
	IGRlong			sts = OM_S_SUCCESS;
	IGRint			count, list_size;
	struct GRid		*list = NULL;
	int			i, qry, index;
	char			prefix[ATTR_NAME];

	SetProc (Gen_LoadQueries); Begin

	/* Get total number of queries */
	sts = vd$qry_get_id_list( msg		= &msg,
				  count		= &count,
				  ref_file	= FALSE   );
	as$status (sts = sts & msg, msg = "vd$qry_get_id_list",
			action = GOTO_VALUE, value = wrapup);

	/* No queries defined */
	if ( count == 0 ) goto wrapup;

	/* allocate query_list */
	v->query_list = _MALLOC( count, query_t);
	_CheckMem (v->query_list, sts, msg, wrapup);

	/* allocate local lists for call */
	list = _MALLOC( count, struct GRid);
	_CheckMem (list, sts, msg, wrapup);

	/* Get list of query objid's */
	list_size = count;
	sts = vd$qry_get_id_list( msg		= &msg,
				  count		= &count,
				  list_size	= list_size,
				  list		= list,
				  ref_file	= FALSE   );
	as$status (sts = sts & msg, msg = "VDget_qry_list",
			action = GOTO_VALUE, value = wrapup);

	/* Select queries with prefix information  */
	for (i=0, qry=0; i < count; i++) {

		/* Read prefix, if exists */
		sts = _VD_SEND_OBJN (list[i],
		 		VDquery.VDgetPfxInfo (&msg, &index, prefix));
		if (!(sts & msg & 1)) continue;

		/* Copy  objid, index, prefix */
		memcpy ( (char *)&(QRY_OBJ(qry)), (char *)&(list[i]),
							sizeof(struct GRid));
		strncpy (QRY_PREFIX(qry), prefix, VD_ITEMNUM_LEN);
		(QRY_PREFIX(qry))[VD_ITEMNUM_LEN-1] = '\0';
		v->query_list[qry].index = index;
		qry++;
		}
	/* sort queries by index */
	v->num_query = qry;
	qsort ((char *)v->query_list, v->num_query, sizeof(query_t),
						Gen_compare_query);
	sts = msg = MSSUCC;
wrapup:
	_PRINT_QUERY("Created ");
	_FREE (list);
	End
	return (sts & msg & 1);
}
/*-----------------------------------------------------------------------*/
/* prefix list sort function
 *	all standard prefixes followed by all user prefixes
 */
static int
Gen_compare_prefix (const void *elm1,
		    const void *elm2 )
{
	return strncmp ( ((prefix_t *)elm1)->prefix,
			 ((prefix_t *)elm2)->prefix, VD_ITEMNUM_LEN);
}
/*-----------------------------------------------------------------------*/
/* Insert prefix into prefix_list
 */
static void
Gen_InsertPrefix (char * 	prefix, 	/* prefix to insert */
		  int 		is_std, 	/* is_std flag */
		  int		*pfx_index,	/* index of new prefix record */
		  data_t 	*v)
{
	int		i, cmp, pfx;

   	/* Search list for insertion point
    	 *	list is sorted - stop search when cmp <= 0
 	 */
	for (pfx=0, cmp=1; cmp > 0 && pfx < v->num_prefix; pfx++) {
		cmp = strcmp (prefix, P_PREFIX(pfx));
		#ifdef genInsert
		   printf ("     -- cmp: %d  pfx:%d  '%s', '%s'\n", cmp, pfx,
						prefix, P_PREFIX(pfx));
		#endif
		}

	/* already in list - no insert */
	if (cmp == 0 ) {
		#ifdef genInsert
		   printf ("  ** no insert '%s'  cmp: %d\n", prefix, cmp);
		#endif
		return;
		}

	/* if cmp < 0 then insert before last entry */
	if (cmp < 0)
		pfx --;

	/* return index of new entry */
	*pfx_index = pfx;

	/* shift rest down */
	v->num_prefix++;
	for (i=v->num_prefix-1; i > pfx; i--) {
		memcpy ( (char*)&(v->prefix_list[i]),
						(char*)&(v->prefix_list[i-1]),
						sizeof(prefix_t));
		}

	/* Add new prefix */
	strncpy (P_PREFIX(pfx), prefix, VD_ITEMNUM_LEN);
	P_LARGEST(pfx) = 0;
	P_RELABEL(pfx) = NOT_DEFINED;
	P_IS_STD(pfx) = is_std;

	#ifdef genInsert
	    printf ("  ** insert (%d, '%s' ) at %d\n", is_std, prefix, pfx);

	    _PRINT_PREFIX ("After Insert");
	#endif
}
/*-----------------------------------------------------------------------*/
/* Create sorted prefix list */
static int
Gen_CreatePrefixList (data_t		*v)
{
	int		pfx, qry;
	IGRlong		msg, sts = OM_S_SUCCESS;

	SetProc (Gen_CreatePrefixList); Begin

	/* allocate v->prefix_list
	 *	maximum - all queries plus empty prefix
	 */
	v->prefix_list = _MALLOC( (1 + v->num_query), prefix_t);
	_CheckMem (v->prefix_list, sts, msg, wrapup);

	/* Add null prefix */
	Gen_InsertPrefix ("", TRUE, &pfx, v);

	/* Create prefix_list from query_list */
	for (qry=0; qry < v->num_query; qry++)
		Gen_InsertPrefix (QRY_PREFIX(qry), TRUE, &pfx, v);

	/* Mark all prefixes as standard */
	for (pfx=0; pfx < v->num_prefix; pfx++)
		P_IS_STD(pfx) = TRUE;

	/* Mark the null prefix index
	 *	last of the standard prefixes
	 */
	NULL_PFX_INDEX = v->num_prefix - 1;

	_PRINT_PREFIX ("Standard prefixes");
wrapup:
	End
	return (sts & 1);
}

/*-----------------------------------------------------------------------*/
/*
 * Process row item number
 *	Parse item numbers
 *	if item number is missing  - mark for generation
 *	else
 *		Add user defined prefixes to list
 *		Find largest value for each prefix
 */
static void
Gen_ProcRowItemNum ( data_t	*v)
{
	int		pfx, row;
	IGRlong		msg, sts = OM_S_SUCCESS;
	int		parse_flag;
	prefix_t	node, *pfx_ptr;

	SetProc (Gen_ProcRowItemNum); Begin

	/* Process row item numbers */
	for (row=0; row < v->num_row; row++) {

		/* Parse item number */
		parse_flag = VD_parseItemNum (v->rowList[row].itemNo,
					R_CUR_PREFIX(row), &(R_NUM(row)),
					R_SUFF(row));

		/* Empty string as item number */
		if (!parse_flag) {
			/* Empty strings - mark for generation */
			if (!(v->rowList[row].is_lineout))
				R_GENERATE(row) = TRUE;

			/* user-defined row - null prefix */
			if (!v->rowList[row].num_objs) 
				R_PFX(row) = HAS_PREFIX;
			continue;
			}

		/* Non-null prefix - find in v->prefix_list */
		node.is_std = FALSE;
		strcpy (node.prefix, R_CUR_PREFIX(row));
		pfx_ptr = (prefix_t *) bsearch ((void *)&node,
			(void *)v->prefix_list, v->num_prefix,
			sizeof(prefix_t), Gen_compare_prefix);

		/* Not found in table - add user-defined prefix to list */
		if (!pfx_ptr) {

			/* reallocate prefix list */
			v->prefix_list = _REALLOC (v->prefix_list,
						1 + v->num_prefix, prefix_t);
			_CheckMem (v->prefix_list, sts, msg, wrapup);

		   	/* Insert prefix in prefix list */
			Gen_InsertPrefix (R_CUR_PREFIX(row), FALSE, &pfx, v);

			P_LARGEST(pfx) = R_NUM(row);
			P_RELABEL(pfx) = P_LARGEST(pfx)+ 1;

			/* set pfx_ptr as found by bsearch */
			pfx_ptr = &(v->prefix_list[pfx]);
			}

		/* Record prefix index, number for row */
		R_PFX(row) = HAS_PREFIX;
		if (R_NUM(row) > pfx_ptr->largest) {
			pfx_ptr->largest = R_NUM(row);
			pfx_ptr->relabel_num = R_NUM(row) + 1;
			}
		}

	/* Initialize prefix start, relabel values */
	for (pfx=0; pfx < v->num_prefix; pfx++) {
		P_START(pfx) = P_LARGEST(pfx) + 1;
		if (P_RELABEL(pfx) ==  NOT_DEFINED)
			P_RELABEL(pfx) = (P_LARGEST(pfx) == 0 ) ?
					P_LARGEST(pfx) : P_START(pfx);
		}
wrapup:
	_PRINT_PREFIX ("Add User Defined Prefixes");
	_PRINT_ROW ("Rows after parsing item numbers");
	End;
}

/*--------------------------------------------------------------------*/
/*
 * Create auxillery row list
 *	mark null prefix
 *	add prefix index to rows
 */
static void
Gen_PfxIndices ( data_t	*v)
{
	int		qry, pfx, row, cmp;
	prefix_t	node, *pfx_index;

	/* Add prefix index to all queries */
	for (qry=0; qry < v->num_query; qry++) {
		for (pfx=0,cmp=1; cmp > 0 && pfx < v->num_prefix; pfx++)
			cmp = strcmp(QRY_PREFIX(qry), P_PREFIX(pfx));
		QRY_PFX(qry) = --pfx;
		}
	_PRINT_QUERY ("Queries with prefix index");

	/* Find null prefix */
	*(node.prefix) = '\0';
	pfx_index= (prefix_t *) bsearch ((void *)&node,
			(void *)v->prefix_list, v->num_prefix,
			sizeof(prefix_t), Gen_compare_prefix);
	NULL_PFX_INDEX = pfx_index - v->prefix_list;
	#ifdef genTRACE
	   printf ("null pfx index: %d\n", NULL_PFX_INDEX);
	#endif

	/* Add prefix */
	for (row=0; row < v->num_row; row++) {
		if (R_PFX(row) == NOT_DEFINED)
			continue;
		strcpy (node.prefix, R_CUR_PREFIX(row));
		pfx_index = (prefix_t *) bsearch ((void *)&node,
				(void *)v->prefix_list, v->num_prefix,
				sizeof(prefix_t), Gen_compare_prefix);
		R_PFX(row) = pfx_index - v->prefix_list;
		R_IS_STD(row) = P_IS_STD(R_PFX(row));
		}
	_PRINT_ROW ("Row list with prefix index ");
}

/*--------------------------------------------------------------------*/
static int
Gen_Init ( data_t		*v,
	   VD_itemList_t	*rowList,
	   int			numRows	)
{
	int	flag = FALSE;

	SetProc (Gen_Init); Begin

	/* Initialize global data structure */
	v->rowList = rowList;
	v->num_row = numRows;
	v->keep_user = TRUE;
	v->keep_suffix = TRUE;
	_PRINT_INPUT("Input");

	#ifdef genTRACE
		v->debug = 1;
	#else
		v->debug = 0;
	#endif

	/* initialize sizes */
	v->num_query = v->num_prefix = v->num_obj = 0;
	v->num_search = 0;

	/* initialize lists */
	v->query_list 	= NULL;
	v->prefix_list 	= NULL;
	v->obj_list 	= NULL;
	v->search_list 	= NULL;
	v->row_list 	= NULL;

	Gen_GetSetData(&v, TRUE);

	/* Initialize row list */
	if (!Gen_RowInit (v))
		goto wrapup;

	/* Load queries with prefixes */
	if (!Gen_LoadQueries (v))
		goto wrapup;

	/* Create prefix list */
	if (!Gen_CreatePrefixList(v))
		goto wrapup;

	/* Process Item numbers from List */
	Gen_ProcRowItemNum (v);

	/* Finish updating prefix indices */
	Gen_PfxIndices (v);

	flag = TRUE;
wrapup:
	End
	return flag;
}
/*=======================================================================*
 * Interactive form
 *=======================================================================*/

/*---------------------------------------------------------------------*/
/* Form Gadgets */
#define G_TABLE		20
#define G_RELAB_STD	40
#define G_RELAB_USER	41
#define G_KEEP_SUFFIX	50
#define G_KEEP_USER	51

/* columns */
#define COL_TYPE	0
#define COL_PREFIX	1
#define COL_LARGEST	2
#define COL_START	3
#define COL_IS_RELABEL	4
#define COL_RELABEL	5

static void
Gen_FormInit (Form		fp,
		data_t		*v)
{
	int	pfx;			/* prefix = row on the form */
	char	str[VD_ITEMNUM_LEN+2];

	SetProc (Gen_FormInit); Begin

	FIfld_set_max_num_rows	(fp, G_TABLE, v->num_prefix );
	FIfld_set_num_rows	(fp, G_TABLE, v->num_prefix );

	for(pfx=0; pfx < v->num_prefix; pfx++) {
		sprintf (str, "'%s'", v->prefix_list[pfx].prefix);
		FIfld_set_text (fp, G_TABLE, pfx, COL_TYPE,
					(P_IS_STD(pfx) ? "" : "user"),FALSE);
		FIfld_set_text (fp, G_TABLE, pfx, COL_PREFIX, str, FALSE);
		FIfld_set_value (fp, G_TABLE, pfx, COL_LARGEST,
						(double)P_LARGEST(pfx), FALSE);
		FIfld_set_value (fp, G_TABLE, pfx, COL_START,
						(double)P_START(pfx), FALSE);
		FIfld_set_value (fp, G_TABLE, pfx, COL_RELABEL,
						(double)P_RELABEL(pfx), FALSE);
		}
	End
}

/*---------------------------------------------------------------------*/
/* Get start number from form
 *	validate to ensure uniqueness
 *		if start < relabel - check all items
 *	if not ok - display warning, reset field
 *
 * 	field is assumed to be notify at end of line
 */
static void
Gen_FormGetStartNum (Form	fp,
		     int	pfx,
		     double	dval)
{
	int	i, max = NOT_DEFINED;
	char	warn[120];
	data_t	*v;

	SetProc (Gen_FormGetStartNum); Begin

	/* Get global data */
	Gen_GetSetData(&v, FALSE);

	/* check if updated or if only selected */
	if (dval == P_START(pfx)) {
		End
		return;
		}

	/* check if valid start number */
	if (dval < 0) {
		FIg_set_text( fp, FI_MSG_FIELD,
					"Invalid start num.: must be >= 0");
		FIfld_set_value( fp, G_TABLE, pfx, COL_START,
						(double)P_START(pfx) , FALSE);
		End
		return;
		}
	else if (dval >= SHRT_MAX) {
		FIg_set_text( fp, FI_MSG_FIELD, 
					"Invalid start num.: too large");
		FIfld_set_value( fp, G_TABLE, pfx, COL_START,
						(double)P_START(pfx) , FALSE);
		End
		return;
		}

	/* check if dval is valid start number for current relabel number
	 *	dval must be greater than all sequence for items not relabeled
	 *
	 *	find maximum sequence number which is not relabeled
	 */
	if (dval < P_RELABEL(pfx)){
		for(i=0; i < v->num_row; i++)
			if (R_PFX(i) == pfx && R_NUM(i) < P_RELABEL(pfx)
						   && R_NUM(i) >= dval)
				max = R_NUM(i);
		};

	if (max == NOT_DEFINED) {
		P_START(pfx) = dval;
		#ifdef genFORM
		   printf ("pfx %d, update start num: %d\n", pfx, P_START(pfx));
		#endif
		}
	else {
		sprintf (warn, "Invalid start num.: must be > %d", max);
		FIg_set_text( fp, FI_MSG_FIELD, warn );
		FIfld_set_value( fp, G_TABLE, pfx, COL_START,
						(double)P_START(pfx) , FALSE);
		}
	End
}
/*---------------------------------------------------------------------*/
/* Display relabel value and flag */
static void
Gen_FormDisplayRelabel ( 	Form	fp,
		     		int	pfx,
				data_t	*v,
		     		double	dval)
{
	char	*str;

	/* set relabel value */
	P_RELABEL(pfx) = dval;
	FIfld_set_value( fp, G_TABLE, pfx, COL_RELABEL, dval , FALSE);

	/* mark as relabled if 
	 *	less than largest found
	 *	user-defined  or standard where largest = 0
	 */
	str = "";
	if (dval <= P_LARGEST(pfx) && 
			(!P_IS_STD(pfx) || (P_IS_STD(pfx) && P_LARGEST(pfx)) ))
		str = " x";
	FIfld_set_text (fp, G_TABLE, pfx, COL_IS_RELABEL, str, FALSE);
}
/*---------------------------------------------------------------------*/
/* Get relabel number from form
 *	validate to ensure uniqueness
 *		if start < relabel - check all items
 *	if not ok - display warning, reset field
 *
 * 	field is assumed to be notify at end of line
 */
static void
Gen_FormGetRelabelNum (Form	fp,
		     int	pfx,
		     double	dval)
{
	int	i, max = NOT_DEFINED;
	char	warn[120];
	data_t	*v;

	SetProc (Gen_FormGetRelabeltNum); Begin

	/* Get global data */
	Gen_GetSetData(&v, FALSE);

	/* check if updated or if only selected */
	if (dval == P_RELABEL(pfx)) {
		End
		return;
		}

	/* check if valid relabel number */
	if (dval < 0) {
		FIg_set_text (fp, FI_MSG_FIELD,
					"Invalid relabel num.: must be >= 0");
		FIfld_set_value( fp, G_TABLE, pfx, COL_RELABEL,
					(double)P_RELABEL(pfx) , FALSE);
		End
		return;
		}
	else if (dval >= SHRT_MAX) {
		FIg_set_text( fp, FI_MSG_FIELD,
					"Invalid relabel num.: too large" );
		FIfld_set_value( fp, G_TABLE, pfx, COL_RELABEL,
						(double)P_RELABEL(pfx) , FALSE);
		End
		return;
		}


	/* check if valid relabel number for current start number
	 *	start must be greater than all sequence for items not relabeled
  	 *
	 *	find maximum sequence number which is not relabeled
	 */
	if (P_START(pfx) < dval ){
		for(i=0; i < v->num_row; i++)
			if (R_PFX(i) == pfx && R_NUM(i) < dval
						   && R_NUM(i) > P_START(pfx))
				max = R_NUM(i);
		};

	if (max == NOT_DEFINED) {
		Gen_FormDisplayRelabel (fp, pfx, v, dval);
		#ifdef genFORM
		 printf ("pfx %d, update relabel num: %d\n",pfx,P_RELABEL(pfx));
		#endif
		}
	if (max != NOT_DEFINED) {
		sprintf (warn, "Invalid relabel: Start must be > %d", max);
		FIg_set_text( fp, FI_MSG_FIELD, warn );
		FIfld_set_value( fp, G_TABLE, pfx, COL_RELABEL,
					(double)P_RELABEL(pfx) , FALSE);
		}
	End
}
/*---------------------------------------------------------------------*/
/* Relabel buttons */
static void
Gen_FormRelabelButton (Form fp, int is_std)
{
	int		pfx;
	data_t		*v;

	SetProc (Gen_FormRelabel); Begin

	Gen_GetSetData(&v, FALSE);

	for (pfx=0; pfx < v->num_prefix; pfx++){
		if (is_std == P_IS_STD(pfx)) {
			P_START(pfx) = 1;
			P_RELABEL(pfx) = 0;
			FIfld_set_value( fp, G_TABLE, pfx, COL_START,
					(double)P_START(pfx) , FALSE);
			Gen_FormDisplayRelabel (fp, pfx, v, (double)0);
			}
		}
	End;
}
/*---------------------------------------------------------------------*/
static void
Gen_FormSetSuffixFlag (Form fp, int g_label)
{
	double 		dval;
	data_t		*v;

	Gen_GetSetData(&v, FALSE);

	FIg_get_value (fp, g_label, &dval);
	v->keep_suffix = dval;
}
/*---------------------------------------------------------------------*/
static void
Gen_FormSetUserFlag (Form fp, int g_label)
{
	double 		dval;
	data_t		*v;

	Gen_GetSetData(&v, FALSE);

	FIg_get_value (fp, g_label, &dval);
	v->keep_user = dval;
}
/*---------------------------------------------------------------------*/

static int
VD_drwGenItemFormNot (
	int           f_label,        /* i - The label of the form    */
	int           g_label,        /* i - The label of the gadget  */
	double        value,          /* i - The value of the gadget  */
	Form          fp              /* i - Form pointer             */
	)
{
	int		flag = TRUE;
	int		pfx, col;
	int		pos, r_pos, sel_flag;
	double		dval = value;		/* to keep opp quiet */
	long		msg = f_label;		/* to keep opp quiet */
	int		rsp = EX_FORM_FINISHED;

	/* clear message field */
	FIg_set_text( fp, FI_MSG_FIELD, "" );

	switch ( g_label ) {

		case G_TABLE:
			FIfld_get_active_row (fp, G_TABLE, &pfx, &pos);
			FImcf_get_active_col (fp, G_TABLE, &col, &pos);

			FIfld_get_value (fp, G_TABLE, pfx, col,
				&dval, &sel_flag, &r_pos);

			#ifdef genFORM
			  printf ("Table field: pfx = %d col = %d  value: %g\n",
						pfx, col, dval);
			#endif

			switch (col) {
				case COL_START:
					Gen_FormGetStartNum(fp, pfx, dval);
					break;
				case COL_RELABEL:
					Gen_FormGetRelabelNum(fp, pfx, dval);
					break;
				default:
					fprintf (stderr,
					"Error: No such column: %d\n", col);
				}
			break;

		case G_RELAB_STD:
			Gen_FormRelabelButton(fp, TRUE);
			break;

		case G_RELAB_USER:
			Gen_FormRelabelButton(fp, FALSE);
			break;

		case G_KEEP_SUFFIX:
			Gen_FormSetSuffixFlag (fp, g_label);
			break;

		case G_KEEP_USER:
			Gen_FormSetUserFlag (fp, g_label);
			break;

		case FI_CANCEL:
			rsp = EX_RESTART;
			ex$putque(msg = &msg, response = &rsp);
			flag = FALSE;
			break;

		case FI_ACCEPT:
			ex$putque(msg = &msg, response = &rsp);
			flag = TRUE;
			break;
		}
	return flag;
}
/*---------------------------------------------------------------------*/
static int
Gen_ProcessForm ( data_t	*v)
{
	long	sts;
	Form	fp;
	extern int	VDform_events_loop1( Form fp );

	SetProc (GenProcessForm); Begin

	/* Create, set form notification */
	sts = FIf_new( 0, "VDGenItem", VD_drwGenItemFormNot, &fp);
	if (sts != FI_SUCCESS) {
		fprintf (stderr,
			"Cannot create form: %s, FIf_new failed: sts = %d\n",
			"Generate item numbers", sts);
		goto wrapup;
		}

	/* Initialize gadgats */
	Gen_FormInit (fp, v);

	/* Process events
	 *	VDform_events_loop1 defined in vdmdlv/func/VDdispQryFrm.I
	 */
	FIf_display ( fp );
	sts = VDform_events_loop1 ( fp );

wrapup:
	_PRINT_PREFIX ("After Processing Form");
	End;
	return sts == FI_SUCCESS;

}
/*=======================================================================*
 * Generate Item Numbers
 *=======================================================================*/
/*-----------------------------------------------------------------------*/
/*
 * Create list of objects in generated rows
 */
static int
Gen_CreateObjList ( data_t		*v)
{
	int		i, row, obj;
	IGRlong		msg, sts = OM_S_SUCCESS;

	SetProc (Gen_CreateObjList); Begin

	/* Find size of object list */
	v->num_obj = 0; for (row=0; row < v->num_row; row++) {
		if (R_GENERATE(row) && R_PFX(row) == NOT_DEFINED)
			v->num_obj += v->rowList[row].num_objs;
		}

	/* empty list */
	if (!v->num_obj) goto wrapup;

	/* Create object list */
	v->obj_list = _MALLOC (v->num_obj, obj_t);
	_CheckMem (v->obj_list, sts, msg, wrapup);

	/* Copy objects from each marked row */
	for (row=0, obj=0; row < v->num_row; row++) {
		if (R_GENERATE(row) && R_PFX(row) == NOT_DEFINED) {
			for (i=0; i< v->rowList[row].num_objs; i++) {
				memcpy ( (char *)&(v->obj_list[obj].obj),
					 (char *)&(v->rowList[row].objs[i]),
					sizeof(struct GRobj_env));
				v->obj_list[obj].row = row;
				O_PFX(obj) = NOT_DEFINED;
				obj ++;
				}
			}
		}
wrapup:
	_PRINT_OBJ("Create list of all objects");
	End
	return (sts & 1);
}
/*-----------------------------------------------------------------------*/
/*
 * Create search list of objects for a given query
 */
static int
Gen_CreateSearchList ( data_t		*v)
{
	int		i,obj;
	IGRlong		msg, sts = OM_S_SUCCESS;

	SetProc (Gen_CreateSearchList); Begin

	/* Find size of search list */
	v->num_search = 0;
	for (obj=0; obj < v->num_obj; obj++) {
		if (O_PFX(obj) == NOT_DEFINED)
			v->num_search++;
		}

	/* empty search list */
	if (!v->num_search) goto wrapup;

	/* Create object list */
	v->search_list = _MALLOC (v->num_search, struct GRobj_env);
	_CheckMem (v->search_list, sts, msg, wrapup);

	/* Copy objects without prefixes */
	for (obj=0, i=0; obj < v->num_obj; obj++) {
		if (O_PFX(obj) == NOT_DEFINED) {
			memcpy ( (char *)&(v->search_list[i]),
				 (char *)&(v->obj_list[obj].obj),
				sizeof(struct GRobj_env));
			i++;
			}
		}
wrapup:
	_PRINT_SEARCH ("Create new search list");
	End
	return (sts & 1);
}
/*-----------------------------------------------------------------------*/
/*
 * Run query on current search list
 *	Assign prefixes to matching objects in obj_list
 *
 */
static int
Gen_RunQuery ( int		qry,
		data_t		*v)
{
	IGRlong			msg = MSSUCC;
	IGRlong			sts = OM_S_SUCCESS;
	GRname			query;
	int			num_match;
	int			i, obj;
	char			*select = NULL;
	char			*where = NULL;
	struct GRobj_env	*match_list = NULL;	/* malloc/free here */

	SetProc (Gen_RunQuery); Begin

	/* Read Query */
	sts = _VD_SEND_OBJN (QRY_OBJ(qry),
			VDquery.VDgive_query (&msg, &select, &where, NULL));
	as$status (sts = sts & msg, msg = "VDgive_query",
			action = GOTO_VALUE, value = wrapup);

	/* rebuild query */
	strcpy (query, select);
	if (*where) strcat (query, where);
	#ifdef genDEBUG
	  printf ("  --Query %d   prefix '%s'   query: '%s'\n",
						qry, QRY_PREFIX(qry), query);
	#endif

	/* empty search list */
	if (!v->num_search) goto wrapup;

	/* Allocate search list */
	num_match = 0;
	match_list = _MALLOC (v->num_search, struct GRobj_env);
	_CheckMem (match_list, sts, msg, wrapup);

	/* Run query on object list
	 *	ignore return value - same as nb_found > 0
	 */
	vd$qry_get_mul_objects (	sts		= &msg,
					objects		= v->search_list,
					nb_objects	= v->num_search,
					query		= query,
					found		= match_list,
					nb_found	= &num_match);
	#ifdef genDEBUG
	  printf ("\tobjs: search: %d   match: %d\n", v->num_search, num_match);
	  if (v->debug)
		Gen_PrintObjs ("  --Match list: ", match_list, num_match);
	#endif

	/* Assign prefixes to objects found */
	for (i=0, obj=0; i < num_match; i++) {

		/* find object in obj_list
		 *	prefix not defined -> not in search list
		 *	else try to match objects
		 */
		while (O_PFX(obj) != NOT_DEFINED ||
			!(match_list[i].obj_id.objid == O_OBJ(obj).obj_id.objid
		          && match_list[i].obj_id.osnum ==
						      O_OBJ(obj).obj_id.osnum))
			obj++;

		/* assign prefix */
		O_PFX(obj) = QRY_PFX(qry);
		obj++;
		}
	_PRINT_OBJ("After running query");
wrapup:
	_FREE(select);
	_FREE(where);
	_FREE (match_list);
	End
	return (sts & msg & 1);
}
/*-----------------------------------------------------------------------*/
/*
 * Assign prefixes to rows
 *	no object  = null prefix
 *	row prefix = object prefix if all match else null
 */
static void
Gen_AssignPrefixes ( data_t	*v)
{
	int	obj, row;
	int	row_prefix;

	SetProc (Gen_AssignPrefixes); Begin

	/* update prefixes */
	for (row=0, obj=0; row < v->num_row ; row++) {
		if (R_GENERATE(row)) {

			/* prefix already assigned - user defined row */
			if (R_PFX(row) != NOT_DEFINED) {
				continue;
				}

			/* row with single object */
			if (v->rowList[row].num_objs == 1) {
				if (O_PFX(obj) == NOT_DEFINED)
					R_PFX(row) = NULL_PFX_INDEX;
				else
					R_PFX(row) = O_PFX(obj);

				if (O_ROW(obj) != row)
					fprintf (stderr,
					"Error: mismatch: obj: %d obj_row: %d row: %d\n",
					obj, O_ROW(obj), row);

				obj++;
				continue;
				}

			/* compare prefixes of objects in row */
			row_prefix = O_PFX(obj);
			while (v->obj_list[obj].row == row) {
				if ( row_prefix != O_PFX(obj))
					row_prefix = NOT_DEFINED;
				obj++;
				}

			/* assign row prefix index*/
			if (row_prefix == NOT_DEFINED)
				R_PFX(row) = NULL_PFX_INDEX;
			else
				R_PFX(row) = row_prefix;
			}
		}
	_PRINT_ROW("Prefixes asigned");
	End
}

/*-----------------------------------------------------------------------*/
static int
Gen_GenItemNum ( data_t		*v)
{
	int	qry, row;
	int			flag = FALSE;
	prefix_t	node, *pfx_ptr;

	SetProc (Gen_GenItemNum); Begin

	/* Marking rows for relabeling,
	 *    Null rows were already marked during parsing
 	 *
	 *    assign prefix
	 */
	for (row=0; row < v->num_row; row++) {
		if ((!R_GENERATE(row)) && !(v->rowList[row].is_lineout) &&
					R_NUM(row) >= P_RELABEL(R_PFX(row))) {
			R_GENERATE(row) = TRUE;

			/* user defined prefix */
			if (v->keep_user && !R_IS_STD(row)) {
				strcpy (node.prefix, R_CUR_PREFIX(row));
				pfx_ptr = (prefix_t *) bsearch ((void *)&node,
							(void *)v->prefix_list, 
							v->num_prefix,
							sizeof(prefix_t), 
							Gen_compare_prefix);
				R_PFX(row) = pfx_ptr - v->prefix_list;
				}

			/* no object -> null prefix */
			else if (!v->rowList[row].num_objs)
				R_PFX(row) = NULL_PFX_INDEX;


			/* prefix to be defined by a query */
			else
				R_PFX(row) = NOT_DEFINED;

			}
		}
	_PRINT_ROW ("Rows marked for generation");

	/* Create list of all objects in generated rows */
	if (!Gen_CreateObjList (v))
		goto wrapup;

	/* Assign prefixes to objects based upon queries */
	v->num_search = v->num_obj;
	for (qry=0; v->num_search && qry < v->num_query; qry++ ) {

		/*Create search list of remaining objects */
		if (!Gen_CreateSearchList (v))
			goto wrapup;
		if (!v->num_search)
			break;

		/* Run next query on search list */
		if (!Gen_RunQuery (qry, v))
			goto wrapup;

		/* free current search list */
		_FREE (v->search_list);
		}

	/* Assign prefixes to rows */
	Gen_AssignPrefixes(v);

	/* Generate sequence numbers, update input row list */
	for (row=0; row < v->num_row; row++ ) {
		if (R_GENERATE(row))  {
			if (R_PFX(row) == NOT_DEFINED) {
			   fprintf (stderr,
				"Error - prefix for row %d not defined\n", row);
				continue;
				}
			R_NUM(row) = P_START(R_PFX(row))++;
			sprintf (v->rowList[row].itemNo, "%s%d%s",
					R_PREFIX(row), R_NUM(row),
					(v->keep_suffix ? R_SUFF(row) : ""));
			v->rowList[row].is_modified = TRUE;
			}
		}
	_PRINT_ROW("Item# generated");
	_PRINT_INPUT("Output");
	flag = TRUE;
wrapup:
	_FREE(v->search_list);
	End
	return flag;
}
/*************************************************************************
 * 		EXTERNAL FUNCTIONS
 *************************************************************************/

/* Parse item number
 *	returns status indicating whether itemNo could be parsed
 */
int
VD_parseItemNum (char	*itemNo,
		 char	*prefix,
		 int	*num,
		 char 	*suffix)
{
	char	*ptr, *last, *start;
	char	buf[VD_ITEMNUM_LEN];
	int	sts = TRUE;

	/* Defaults */
	*prefix = '\0';
	*suffix = '\0';
	*num = 0;

	/* Empty string */
	if (!*itemNo) {
		sts = FALSE;
		goto wrapup;
		}

	/* Read suffix
	 * 	scan backwards for end of sequence number
	 */
	ptr = last = itemNo + strlen(itemNo);
	while (!isdigit(*ptr) && ptr != itemNo)
		ptr--;

	/* No sequence number */
	if (!isdigit(*ptr) && ptr == itemNo)  {
		ptr = last; 		/* set ptr to end of prefix */
		sts = 2;
		goto prefix;
		}

	/* Copy suffix
	 *	last = null, ptr = digit
	 */
	if (last-ptr-1 > VD_ITEMNUM_LEN) {
		fprintf (stderr, "Error: item number parser: %s\n",
				"suffix exceeds buffer length");
		sts = FALSE;
		goto wrapup;
		}
	strncpy ( suffix , ptr+1 , last-ptr);
	prefix [last-ptr] = '\0';

	/* read number
 	 * 	allow ptr to go past start of string
	 */
	last = ptr;
	while (isdigit(*ptr) && ptr != itemNo-1)
		ptr--;
	if (last - ptr > VD_ITEMNUM_LEN) {
		fprintf (stderr, "Error: item number parser: %s\n",
				"sequence exceeds internal buffer length");
		sts = FALSE;
		goto wrapup;
		}
	strncpy (buf, ptr+1, last - ptr);
	buf[last-ptr] = '\0';
	*num = atoi(buf);

prefix:
	/* rest is prefix */
	if ( ptr != itemNo-1 ) {

		/* strip leading blanks */
		start = itemNo;
		while ( isspace(*start))
			start++;
		if (ptr-start+1 > VD_ITEMNUM_LEN) {
			fprintf (stderr, "Error: item number parser: %s\n",
				"prefix exceeds buffer length");
			sts = FALSE;
			goto wrapup;
			}
		strncpy ( prefix , start , ptr-start+1 );
		prefix [ptr-start+1] = '\0';
		}
wrapup:
#	ifdef genParser
	printf ("   rc: %d itemNo: '%s'\tprefix: '%s'\tnum: %d\tsuffix: '%s'\n",
					sts, itemNo, prefix, *num, suffix);
#	endif
	return sts;
}

/*-----------------------------------------------------------------------*/
int
VD_drwGenItemNum ( VD_itemList_t	*rowList,
		    int			numRows	 )
{
	int			flag = FALSE;
	data_t			v;		/* global data */

	SetProc (VD_drwGenItemNum); Begin

	/* No rows, no work */
	if (!numRows)
		return MSSUCC;

	if (numRows < 0)
		return MSFAIL;

	/* Get queries, prefixes, setup data structures */
	if (!Gen_Init ( &v, rowList, numRows)) {
		__DBGpr_str ("End", "init failed");
		goto wrapup;
		}

	/* Process form */
	if (!Gen_ProcessForm (&v)) {
		__DBGpr_str ("End", "cancelled");
		goto wrapup;
		}

	/* Generate item numbers */
	if (!Gen_GenItemNum (&v)) {
		__DBGpr_str ("End", "item number genration failed");
		goto wrapup;
		}

	flag = TRUE;
wrapup:
	_FREE (v.query_list);
	_FREE (v.prefix_list);
	_FREE (v.row_list);
	_FREE (v.obj_list);
	_FREE (v.search_list);

	End
	return flag;
}

end implementation Root;
