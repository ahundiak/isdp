/* $Id: ci_mac_bib.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / ci_mac_bib.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ci_mac_bib.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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


/*
 * Etienne BEEKER Nov 20th '89
 * converts a function call into a call in another PPL file
 */


str_to_exp(str, exp)
char * str;
struct GRid * exp;
{
  int status;
  int retval;

       push str, exp;
       status=ci$exec( file_name = "ci_mac_bib.u",
		retval = &retval,
		retsize = sizeof(int),
		delete = 0,
		load = LOAD,
	        entry     = "str_to_exp" );

	return retval;
}

exp_to_str(str, exp)
char * str;
struct GRid * exp;
{
  int status;
  int retval;

       push str, exp;
       status=ci$exec( file_name = "ci_mac_bib.u",
		retval = &retval,
		retsize = sizeof(int),
		delete = 0,
		load = LOAD,
	        entry     = "exp_to_str" );

	return retval;
}

loc_solid( solgrid )
struct GRid *solgrid;
{
  int status;
  int retval;

       push solgrid;
       status=ci$exec( file_name = "ci_mac_bib.u",
		retval = &retval,
		retsize = sizeof(int),
		delete = 0,
		load = LOAD,
	        entry     = "loc_solid" );

	return retval;
}


get_surf_at_index(solid, ix, surf_id )
struct GRid solid, *surf_id;
int ix;
/*
 * returns the surface id given its index in a solid
 * on error return 0 and NULL_OBJID
 * uses get_conn_surf
 */
{
       int status;
       int retval;

       push solid, ix, surf_id;
       status=ci$exec( file_name = "ci_mac_bib.u",
		retval = &retval,
		retsize = sizeof(int),
		delete = 0,
		load = LOAD,
	        entry     = "get_surf_at_index" );

	return retval;
}


get_index_of_surf(solid, ix, surf_id )
struct GRid solid, surf_id;
int *ix;
/*
 * returns the index of a given surface in a solid
 * if not found returns -1
 * uses get_conn_surf
 */
{
       int status;
       int retval;

       push solid, ix, surf_id;
       status=ci$exec( file_name = "ci_mac_bib.u",
		retval = &retval,
		retsize = sizeof(int),
		delete = 0,
		load = LOAD,
	        entry     = "get_index_of_surf" );

	return retval;
}

