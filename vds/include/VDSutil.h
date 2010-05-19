/* $Id: VDSutil.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSutil.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSutil.h,v $
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

#ifndef	 VDSutil_include
#define	 VDSutil_include
#include "ACrg_collect.h"

#define STAT_ATTR       0x0001  /* Static  attribute */
#define DYN_ATTR        0x0002  /* Dynamic attribute */
#define TMP_MAC         0x0010  /* Macro template    */

struct	VDSatt_family
{
   IGRint		stat_dyn;
   struct ACrg_coll	attr;
};

#define SM_ATTRIB_INT	4

/* Structure for attributes of a part */

struct part_attr
{
  int nb_att;
  struct VDSatt_family *att;    /* Array of attributes  */
};

/* One query for one attributes */
struct query_attr
{
  char 	Operator[15];
  char 	name[ATTR_TXT];
  short type;
  union 
  {
     char   att_txt[ATTR_TXT];
     double att_dbl;
     int    att_int;
  } value;
};
 
struct temp_attr
{
  char attr_name[ATTR_TXT];
  char attr_syn[ATTR_TXT];
  IGRshort	type;
};


/**** Definitions for VDIdManage.C  ***********/

#define 	VDS_LIST_OF_IDS		10

    /* Tables defined  */
#define		VDS_PLACED_ID_TBL	"VDS_PLACED_IDS"
#define		VDS_ID_HISTORY_TBL	"VDS_ID_HISTORY"

#define		VDS_ID_ISNOT_USED	1
#define		VDS_ID_IS_USED		2
#define		VDS_ID_IS_DELETED	3
#define		VDS_NEW_ID_FOUND	4
#define		VDS_ID_NOT_MODIFIED	5
 
#endif
