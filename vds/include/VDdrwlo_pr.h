
/* $Id: VDdrwlo_pr.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/VDdrwlo_pr.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_pr.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
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
 * Revision 1.7  1996/05/31  22:36:22  pinnacle
 * Replaced: include/VDdrwlo_pr.h for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/04/03  20:38:06  pinnacle
 * Replaced: include/VDdrwlo_pr.h for:  by hverstee for vds.240
 *
 * Revision 1.5  1995/09/05  20:02:02  pinnacle
 * Replaced: include/VDdrwlo_pr.h for:  by hverstee for vds.240
 *
 * Revision 1.4  1995/08/25  15:01:08  pinnacle
 * Replaced: include/VDdrwlo_pr.h for:  by hverstee for vds.240
 *
 * Revision 1.3  1995/07/06  14:33:28  pinnacle
 * Replaced: include/VDdrwlo_pr.h for:  by hverstee for vds.240
 *
 * Revision 1.2  1995/06/19  19:16:54  pinnacle
 * Replaced: include/VDdrwlo_pr.h for:  by hverstee for vds.240
 *
 * Revision 1.5  1995/05/31  22:21:58  pinnacle
 * Replaced: include/VDdrwlo_pr.h by hverstee r#
 *
 * Revision 1.4  1995/05/26  16:20:26  pinnacle
 * Replaced: include/VDdrwlo_pr.h by hverstee r#
 *
 * Revision 1.3  1995/05/25  21:44:48  pinnacle
 * Replaced: include/VDdrwlo_pr.h by hverstee r#
 *
 * Revision 1.2  1995/04/25  21:20:38  pinnacle
 * Replaced: include/VDdrwlo_pr.h by hverstee r#
 *
 * Revision 1.1  1995/04/18  21:28:40  pinnacle
 * Created: include/VDdrwlo*.h by tdumbach r#
 * rno
 *
 * Revision 1.4  1995/03/29  22:23:46  pinnacle
 * Replaced: include/VDdrwlo_pr.h by hverstee r#
 *
 * Revision 1.3  1995/03/25  15:30:32  pinnacle
 * Replaced: include/VDdrwlo_pr.h by hverstee r#
 *
 * Revision 1.2  1995/03/08  15:08:38  pinnacle
 * Replaced: include/VDdrwlo_pr.h by hverstee r#
 *
 * Revision 1.1  1995/03/03  21:05:20  pinnacle
 * Created: include/VDdrwlo_pr.h by hverstee r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            include file to define DRWlo function
 *                                       prototypes (public interface)
 *	05/31/96	  tlb	 	Added flag to VD_Return_Attr
 *
 * -------------------------------------------------------------------*/

#ifndef  VDdrwlo_pr_h

#define  VDdrwlo_pr_h

#include "ACrg_collect.h"

/****************************************************************************/
/*      INTERFACE:    drwlo == drawing table layout access                  */
/****************************************************************************/

/* ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_iopen (IGRlong      *msg);

/*   initializes in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_iclose (IGRlong      *msg);

/*   closes in-memory index and frees memory

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_inew  (IGRlong      *msg,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabtyp,
                        struct GRid         *DRWloid);

/*   adds new entry to in-memory index , expands index when necessary

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Tabtyp         I                 Table type
DRWloid        I                 object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_idelete (IGRlong      *msg,
                                 IGRchar      *Tabnam,
                                 IGRchar      *Tabtyp);

/*   deletes local layout, modifies in-memory index 

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Tabtyp         I                 Table type

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_getid (IGRlong      *msg,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabtyp,
                        struct GRid         *DRWloid);

/*   returns  object id of the table layout and creates it from the 
     database if needed

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Tabtyp         I                 Table type
DRWloid        O                 returned object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_getnm (IGRlong      *msg,
                               IGRchar      *Tabtype,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam);

/*   returns a list of available table layout names

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabtype        I                 (optional) table type
nCount         O                 Number of table names
Tabnam         O      yes        Array of Table names

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_getnd (IGRlong      *msg,
                               IGRchar      *Tabtype,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabdesc);

/*   returns a list of available table layout names with descriptions

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabtype        I                 (optional) table type
nCount         O                 Number of table names
Tabnam         O      yes        Array of Table names
Tabdesc        O      yes        Array of Table descriptions

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_getnl (IGRlong      *msg,
                               IGRchar      *Tabtype,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam);

/*   returns a list of available table layout names (local only)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabtype        I                 (optional) table type
nCount         O                 Number of table names
Tabnam         O      yes        Array of Table names

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_gettp (IGRlong      *msg,
                               IGRshort     *nCount,
                               IGRchar      *Tabtype);

/*   returns a list of available table types to limit name list

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         O                 Number of table types
Tabtype        O      yes        Array of table types

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_gettl (IGRlong      *msg,
                               IGRshort     *nCount,
                               IGRchar      *Tabtype);

/*   returns a list of available table types to limit name list
     (local only)

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
nCount         O                 Number of table types
Tabtype        O      yes        Array of table types

   ------------------------------------------------------------------------ */

/***************************************************************************
 *  following functions are translated to messages to the appropriate      *
 *  layout object                                                          *
 ***************************************************************************/

extern IGRint  VD_drwlo_gtab  (IGRlong         *msg,
                               IGRchar         *Tabnam,
                        struct VDdrwlo_tab     *Tabrec);

/*    returns general table layout parameters

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Tabrec         O      yes        Returned table layout record

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_gfix  (IGRlong         *msg,
                               IGRchar         *Tabnam,
                               IGRshort         nGrptyp,
                               IGRdouble        xLode,
                               IGRdouble        yLode,
                               IGRshort         nExt,
                        struct VDdrwlo_extrec  *Exrec,
                               IGRdouble       *dHgt,
                               IGRshort        *nCount,
                        struct VDdrwlo_apifix  *Fldrec);

/*    returns array of fixed (builtin) components of a table layout

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
nGrptyp        I                 group type requested
xLode          I                 section corner x coordinate
yLode          I                 section corner y coordinate
nExt           I                 number of extensions requested
Exrec          I                 extension records
dHgt           O                 total height of field or row
nCount         O                 number of field records to be returned
Fldrec         O      yes        Array of returned records

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_gdata (IGRlong         *msg,
                               IGRchar         *Tabnam,
                               IGRshort         nGrptyp,
                               IGRdouble        xLode,
                               IGRdouble        yLode,
                               IGRshort         nExt,
                        struct VDdrwlo_extrec  *Exrec,
                               IGRdouble       *dHgt,
                               IGRshort        *nCount,
                        struct VDdrwlo_data    *Fldrec);

/*    returns array of replaceable components of a table layout

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
nGrptyp        I                 group type requested
xLode          I                 section corner x coordinate
yLode          I                 section corner y coordinate
nExt           I                 number of extensions requested
Exrec          I                 extension records
dHgt           O                 total height of field or row
nCount         O                 number of data records to be returned
Fldrec         O      yes        Array of returned records

   ------------------------------------------------------------------------ */

extern IGRint  VD_drwlo_grect (IGRlong         *msg,
                               IGRchar         *Tabnam,
                               IGRshort         nGrptyp,
                               IGRshort         nColno,
                               IGRchar         *pFieldid,
                               IGRshort         nExt,
                        struct VDdrwlo_extrec  *Exrec,
                               IGRdouble       *xLow,
                               IGRdouble       *yLow,
                               IGRdouble       *xHig,
                               IGRdouble       *yHig);

/*    returns total size of a table section

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
nGrptyp        I                 group type requested
nColno         I                 column number requested (if column group)
                                  (EN_ALL for all columns -- overall rect)
pFieldid       I                 fieldid requested (if header/trailer group)
                                  (NULL for all fields -- overall rect)
nExt           I                 number of extensions requested
Exrec          I                 extension records
xLow           O                 Returned lower x
yLow           O                 Returned lower y
xHig           O                 Returned upper x
yHig           O                 Returned upper y

   ------------------------------------------------------------------------ */

/*    NOTES:

   1. Lode point (generally bottom left corner) coordinates are optional 
      input. All output coordinates will be corrected for these
   2. Extension records are optional input. 
      By submitting the number of auto extended lines needed for every
      applicable column the program can:
         a. offset the coordinates where needed
         b. extend the vertical lines to cover the increased column height

*/


/****************************************************************************/
/*      INTERFACE:    crsrt == sort criteria table access                   */
/****************************************************************************/

/* ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_iopen (IGRlong      *msg);

/*   initializes in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_iclose (IGRlong      *msg);

/*   closes in-memory index and frees memory

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_inew  (IGRlong      *msg,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);

/*   adds new entry to in-memory index , expands index when necessary

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
DRWloid        I                 object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_idelete (IGRlong      *msg,
                                 IGRchar      *Tabnam);

/*   deletes local criterion modifies in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_getid (IGRlong      *msg,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);

/*   returns  object id of the sort criterion and creates it from the
     database if needed

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
DRWloid        O                 returned object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_getnm (IGRlong      *msg,
                               IGRboolean    bLocal,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam);

/*   returns a list of available sort criteria

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
bLocal         I                 =TRUE Returns local only index
nCount         O                 Number of table names
Tabnam         O      yes        Array of Table names

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_gtab  (IGRlong         *msg,
                               IGRchar         *Tabnam,
                        struct VDdrwlo_sstab   *Tabrec);

/*    returns sort criteria table header

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Tabrec         O      yes        Returned table header record

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsrt_gsort (IGRlong         *msg,
                               IGRchar         *Tabnam,
                               IGRshort         nIndex,
                               IGRshort        *nCount,
                        struct VDdrwlo_sort    *Srtrec);

/*    returns array of one or more sort criteria

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
nIndex         I                 Sortkey index (or VD_DRWLO_EN_ALL)
nCount         O                 Number of records returned
Srtrec         O      yes        Sort criteria records

   ------------------------------------------------------------------------ */


/****************************************************************************/
/*      INTERFACE:    crsum == summarization criteria table access          */
/****************************************************************************/

/* ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_iopen (IGRlong      *msg);

/*   initializes in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_iclose (IGRlong      *msg);

/*   closes in-memory index and frees memory

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_inew  (IGRlong      *msg,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);

/*   adds new entry to in-memory index , expands index when necessary

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
DRWloid        I                 object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_idelete (IGRlong      *msg,
                                 IGRchar      *Tabnam);

/*   deletes local criterion modifies in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_getid (IGRlong      *msg,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);

/*   returns  object id of the summarization criterion and creates it from the
     database if needed

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
DRWloid        O                 returned object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_getnm (IGRlong      *msg,
                               IGRboolean    bLocal,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam);

/*   returns a list of available summarization criteria

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
bLocal         I                 =TRUE Returns local only index
nCount         O                 Number of table names
Tabnam         O      yes        Array of Table names

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_gtab  (IGRlong         *msg,
                               IGRchar         *Tabnam,
                        struct VDdrwlo_sstab   *Tabrec);

/*    returns summarization criteria table header

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Tabrec         O      yes        Returned table header record

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_gsqty (IGRlong         *msg,
                               IGRchar         *Tabnam,
                               IGRchar         *Category,
                               IGRchar         *SubCategory,
                               IGRshort        *nCount,
                        struct VDdrwlo_sqty    *Qtyrec);

/*    returns array of one or more summarization quantity records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Category       I                 Category name (NULL for all)
SubCategory    I                 SubCategory name (NULL for all)
nCount         O                 Number of records returned
Qtyrec         O      yes        Summarization criteria quantity records

   ------------------------------------------------------------------------ */

extern IGRint  VD_crsum_gsmtc (IGRlong         *msg,
                               IGRchar         *Tabnam,
                               IGRchar         *Category,
                               IGRchar         *SubCategory,
                               IGRshort         nIndex,
                               IGRshort        *nCount,
                        struct VDdrwlo_smatch  *Mtcrec);

/*    returns array of one or more summarization match records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Category       I                 Category name (NULL for all)
SubCategory    I                 SubCategory name (NULL for all)
nIndex         I                 Index of match record (or VD_DRWLO_EN_ALL)
nCount         O                 Number of records returned
Mtcrec         O      yes        Summarization criteria match records

   ------------------------------------------------------------------------ */


/****************************************************************************/
/*      INTERFACE:    adsym == attribute driven symbol table access         */
/****************************************************************************/

/* ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_iopen (IGRlong      *msg);

/*   initializes in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_iclose (IGRlong      *msg);

/*   closes in-memory index and frees memory

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_inew  (IGRlong      *msg,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);

/*   adds new entry to in-memory index , expands index when necessary

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
DRWloid        I                 object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_idelete (IGRlong      *msg,
                                 IGRchar      *Tabnam);

/*   deletes local criterion modifies in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name

   ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_getid (IGRlong      *msg,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);

/*   returns  object id of the ADS object and creates it from the
     database if needed

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
DRWloid        O                 returned object id

   ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_getnm (IGRlong      *msg,
                               IGRboolean    bLocal,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam);

/*   returns a list of available ADS table objects

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
bLocal         I                 =TRUE Returns local only index
nCount         O                 Number of table names
Tabnam         O      yes        Array of Table names

   ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_gtab  (IGRlong         *msg,
                               IGRchar         *Tabnam,
                        struct VDdrwlo_sstab   *Tabrec);

/*    returns attribute driven symbol object table header

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
Tabrec         O      yes        Returned table header record

   ------------------------------------------------------------------------ */

extern IGRint  VD_adsym_grec  (IGRlong         *msg,
                               IGRchar         *Tabnam,
                               IGRchar         *AttNam,
                        struct ret_struct      *AttVal,
                               IGRshort        *nCount,
                        struct VDadsym_rec     *AdsRec);

/*    returns array of one or more ADS records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
AttNam         I(optional)       Attribute name to select
AttVal         I(optional)       Attribute value to match
nCount         O                 number of records output
AdsRec         O      yes        ADS records output

   ------------------------------------------------------------------------ */



/****************************************************************************/
/*      INTERFACE:    miscellaneous                                         */
/****************************************************************************/

extern IGRint   VD_Return_Attr (IGRlong      *msg,
                                IGRint        NumPar,
                         struct GRid         *InGrid,
                         struct ACrg_coll    *Return,
                         struct GRmd_env     *md_env,
			 int		      use_long_text);

/*    returns attributes and (in case of codelist) converts to string

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
NumPar         I                 Number of parameters
InGrid         I                 Id of the model element
Return         I/O               Coll struct array, filled on return
md_env         I                 environment structure
use_long_text  I                 Indicates which code listed text should be used
					TRUE  - long text
					FALSE - short text

   ------------------------------------------------------------------------ */

extern IGRint   VD_R_Codelist (IGRint     Product,
                               IGRchar   *Attrnam);

/*    returns codelist number for a product/attribute pair
      if it exists (-1 otherwise)

parameter         I/O        Description
                    
Product            I         Product code number
Attrnam            I         Attribute name
Function value     O         Codelist number    (see VDmacdef.h)

   ------------------------------------------------------------------------ */

extern IGRint   VD_get_fontlist (IGRlong   *msg,
                                 IGRshort  *numfont,
                                 IGRchar   *Fonts);

/*    returns list of available fonts

parameter         I/O        Description

msg                O         Returned error code
numfont            O         Number of fonts in list
Fonts              O         Font names (optional)

   ------------------------------------------------------------------------ */

extern IGRint   VD_DLO_SetIndx (IGRchar      *Userid,
                                IGRchar      *Timest,
                                IGRboolean   *Local,
                                IGRshort     *LcUnit);

/*    Sets system data in table layout ID records

parameter         I/O        Description

Userid             O         User id
Timest             O         Time stamp    
Local              O         Local flag
LcUnit             O         Units of current design file

   ------------------------------------------------------------------------ */

extern IGRint      VD_Find_DBowner (IGRchar      *DBTabnam,
                                    IGRchar      *DBTabkey,
                                    IGRchar      *DBowner);

/*    Retrieve the owner of a database table copy

parameter         I/O        Description

DBTabnam           I         Database table name
DBTabkey           I         Database key (tabnam=)
DBowner            O         Database owner field

   ------------------------------------------------------------------------ */

extern IGRboolean  VD_Allow_DBdel (IGRchar      *DBTabnam,
                                   IGRchar      *DBTabkey);

/*    Determines if a db table can be deleted/overwritten by the
      current user

parameter         I/O        Description

DBTabnam           I         Database table name
DBTabkey           I         Database key (tabnam=)
Function value               =TRUE, delete allowed

   ------------------------------------------------------------------------ */

#endif
