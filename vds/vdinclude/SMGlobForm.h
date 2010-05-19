/* $Id: SMGlobForm.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMGlobForm.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMGlobForm.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
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

/* File implementing the definition for the form */

#ifndef SMGlobForm_include
#define SMGlobForm_include

/* The gadget list */
#define G_PRJ 11
#define G_TIT 15
#define G_LPP 44
#define G_BMO 43
#define G_DMO 53
#define G_LOA 51
#define G_DDE 52
#define G_SHE 48
#define G_KEE 55

#define G_CS     40
#define G_ID_CS  19
#define G_SIDE   22
#define G_DIR    26

#define G_ID_FRM 25
#define G_FRM    42

#define G_ID_HULL   16
#define G_HULL_LIST 38

#define G_UNIT 58

/* Name of each gadget */
#define GS_LPP  "Lpp"
#define GS_LOA  "Overall length"
#define GS_DDE  "Design Draft"
#define GS_DEN  "Density of Water"
#define GS_BMO  "Moulded Breadth"
#define GS_DMO  "Moulded Depth"
#define GS_SHE  "Sholl Plating Thickness"
#define GS_KEE  "Keel Plating Thickness"


/* Index in our ACrg of each attributes */
/* The double attributes are from I_LPP to I_KEE (must be conserved) */
#define I_FLG   0
#define I_AOO   1
#define I_LPP   2
#define I_BMO   3
#define I_DMO   4
#define I_LOA   5
#define I_DDE   6
#define I_SHE   7
#define I_KEE   8
#define I_DIR   9
#define I_SIDE  10

/* A reponse for a state */
#define IDENTIFY_HULL   501
#define NO_HULL_DEFINED 502
#define IDENTIFY_CS     503
#define IDENTIFY_FRAME  504

/* A structure to remember the name of associated hull of a global data */
struct globname
{
  struct GRid glob;   /* The global data (NULL_OBJID if not already created) */
  struct GRid hull;    /* The hull associated */
  struct GRmd_env hull_env;  /* The context associated to the hull */
  IGRchar name[ATTR_TXT]; /* Name of the hull */
};


#define MAX_SHIP_TYPE 120


#endif


