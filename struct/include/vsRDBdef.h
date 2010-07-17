/* $Id: vsRDBdef.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        include/vsRDBdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsRDBdef.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/02/03  17:33:44  pinnacle
 * TR179800340
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/03/98  ah      TR179800340 Increased MbrNameLen to 72
 ***************************************************************************/
/*
	I/STRUCT
*/
#ifndef vsRDBdef_include
#	define vsRDBdef_include

/*
 * Attribute names as defined by PDM when the database is formatted.
 */
#define PDU_REVISION_ATTR	"n_itemrev"	/* "p_revision" */
#define PDU_PARTID_ATTR		"n_itemname"	/* "p_partnum"	*/
#define PDU_PARTTYPE_ATTR	"p_parttype"
#define PDU_FILENAME_ATTR	"n_cofilename"
#define PDU_NFM_ITEMNUM		"n_itemnum"
#define PDU_NFM_ITEM_NO		"n_itemno"
#define PDU_NFM_CATALOG_NAME	"n_catalogname"

#define VS_K_PDM_macroCat	"p_macrocat"
#define VS_K_PDM_macroPartno	"p_macropartno"
#define VS_K_PDM_macroRev	"p_macrorev"
#define VS_K_PDM_pdmparamloc	"pdmparamloc"

/*
 * Name of material and family, material catalogs, and type attributes,
 * possible values of type in I/PDM.
 */
#define VS_K_PDM_matCat		"material"
#define VS_K_PDM_matAndFamCat	"mat_and_fam"
#define VS_K_PDM_vstypeAttr	"vs_type"
#define VS_K_PDM_profileType	"cross_section"
#define VS_K_PDM_plateType	"plate"

/*
 * In catalog of materials, name of density attribute, name of unit attribute,
 * values of unit attribute.
 * NOTE : the value of the unit attribute is 'e' for english (imperial) units
 * and 'm'/'M' for metric units. If english units are specified, the value of
 * the density is expected to be in "lb/in**3" if unit is 'e' and "lb/ft3" if
 * unit is 'E' ; if metric units are used,
 * the density is expected to be in "g/cm**3" if unit is 'm' and "kg/m**3" if
 * unit is 'M'.
 */
#define VS_K_PDM_densityAttr		"density"
#define VS_K_PDM_unitAttr		"unit"
#define VS_K_PDM_lb_per_cubic_in	'e'
#define VS_K_PDM_lb_per_cubic_ft	'E'
#define VS_K_PDM_g_per_cubic_cm		'm'
#define VS_K_PDM_kg_per_cubic_m		'M'

/*
 * Names of possible basic units used to defined the density.
 * NOTE: since we here hard-code "lb", "in", etc., it is very much dependent of
 * what is put in the distance and mass UOM tables, which may be altered
 * (possibly by the user), BUT there is no other way to convert the user units
 * to database units.
 */
#define VS_K_POUND	"lb_mass"
#define VS_K_INCH	"in"
#define VS_K_FOOT	"ft"
#define VS_K_GRAM	"g"
#define VS_K_KG		"kg"
#define VS_K_CM		"cm"
#define VS_K_METER	"m"

#define VS_K_MAX_CHARS	256
#define VS_K_MAX_PARMS	20

/*
 * Sizes of fields filled by check-in in the Relational Data Base.
 * This values are the number of character in strings with which the RDB
 * was generated.
 */
#define VS_K_rdbFamNameLen	12	/* PDM/PDU family name		*/
#define VS_K_rdbPartNumLen	30	/* PDM/PDU Part Number		*/
#define VS_K_rdbMatNameLen	12	/* Material name		*/
#define VS_K_rdbGrdNameLen	12	/* Grade name			*/
#define VS_K_rdbMbrNameLen	72	/* Basename of member in DI sys., ah was 12 */
#define VS_K_rdbMTOStckLen	20	/* MTO, stock			*/
#define VS_K_rdbMTOSrceLen	20	/* MTO, source			*/
#define VS_K_rdbAppStatLen	 8	/* Approval status		*/
#define VS_K_rdbCstStatLen	 8	/* Construction status		*/

/*
 * Possible values of the member's class.
 */
#define VS_rdb_clUNDEFINED	0
#define VS_rdb_clPRIMARY	1
#define VS_rdb_clSECONDARY	2
#define VS_rdb_clTERTIARY	3
#define VS_rdb_clOTHER		4
#define VS_rdb_clUSER_1		5
#define VS_rdb_clUSER_2		6
#define VS_rdb_clUSER_3		7
#define VS_rdb_clUSER_4		8
#define VS_rdb_clUSER_5		9
#define VS_rdb_MAXCLASSES	10

/*
 *  Possible values of the member beam's type.
 */
#define VS_rdb_bmUNDEFINED	0
#define VS_rdb_bmBEAM		1
#define VS_rdb_bmCOLUMN		2
#define VS_rdb_bmBRACE		3
#define VS_rdb_bmOTHER		4
#define VS_rdb_MAXBMTYPES	5

/*
 *  Possible values of the member plate's type.
 */
#define VS_rdb_plUNDEFINED	0
#define VS_rdb_plSOLID		1
#define VS_rdb_plCLAD		2
#define VS_rdb_plCOATED		3
#define VS_rdb_plOTHER		4
#define VS_rdb_MAXPLTYPES	5


/*
 *  Possible values of the geometrical qualifier of a beam.
 */
#define VS_rdb_bmLINEAR		0
#define VS_rdb_bmCURVED		1
#define VS_rdb_bmTWISTED	2

/*
 *  Possible values of the geometrical qualifier of a plate.
 */
#define VS_rdb_plFLAT		0
#define VS_rdb_plCURVED		1

/*
 * Name of temporary directory where data read from RDB are stored.
 */
#define VS_K_RDBtmp		"rdbCache"

#endif
