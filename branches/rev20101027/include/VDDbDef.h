/* $Id: VDDbDef.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDDbDef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDDbDef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* This include file defines the structures used for accessing the  */
/* Reference and PDM/PDU tables                                     */

#ifndef VDDbdef_include
#define VDDbdef_include


#define         MAX_MACRO_PARAMS    150
#define         MAX_ATTR_LEN        200
#define         MAX_SELECT_SIZE     200
#define         MAX_WHERE_SIZE      400


#define VD_IMPERIAL_UNITS	0
#define VD_MIXED_UNITS		1
#define VD_METRIC_UNITS		2

/* Definitions for Table Creation etc...	*/

#define		VDS_CREATE_TABLE	0
#define		VDS_MODIFY_TABLE	1
#define		VDS_DROP_TABLE		2

#define		VDS_DBTABLE_NOT_FOUND	0
#define		VDS_DBTABLE_FOUND	1

/*
 * definition of missing in dynamic search
 */
#define VD_MISSING_IN_SEARCH		3

#define		MAX_VDS_UNITS_PARAMS	200
#define		MAX_VDS_CONVERT_COLS	20


/*
 * definition of structures for attributes
 */

struct VDSparam_units
{
	char	family_name[20];
	char	param_name[20];
	int	units_set;
	int	units_code;
	double	resolution;
};

struct VDS_convert
{
	int	units_in;
	int	units_out;
	double	cnvr_fctr;
	double	cnvr_offset;
	double	rnd_off_fctr;
};

struct VDSproject
{
	char	prj_number[20];
	char	prj_version[12];
	int	prj_no;
	char	prj_client[41];
	char	prj_name[41];
	char	prj_descr[41];
	char	prj_location[41];
	int	prj_units_set;
	int	checkin_flag;
	char	ship_name[41];
	char	ship_number[41];
	char	ship_user[41];
	char	dept_name[41];
};

/* This structure is based on Views of sch_dynamic tables of PID and EQP */
/* If the ID management changes and the criteria of attribution of ID's  */
/* Changes then this structure would have to disappear. */

struct id_desc
{
	char	tag_number[13];
	char	functional_id[21];
	char	descript[81];
	char	commodity[21];
	char	comp_note[31];
	int	original;
	char	macro_name[30];
};

#endif
