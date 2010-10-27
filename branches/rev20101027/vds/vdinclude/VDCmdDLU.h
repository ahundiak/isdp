
/* $Id: VDCmdDLU.h,v 1.2 2001/01/26 22:53:31 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdinclude/VDCmdDLU.h
 *
 * Description:
 *
 *      include file to define DLU Command gadgets
 *       (drawing layout utilities command)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdDLU.h,v $
 *      Revision 1.2  2001/01/26 22:53:31  ad
 *      *** empty log message ***
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1998/01/27  20:10:24  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by azuurhou for
 *
 * Revision 1.2  1997/10/21  04:23:56  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by ksundar for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.8  1996/03/14  23:59:18  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by hverstee for vds.240
 *
 * Revision 1.7  1995/09/11  13:42:12  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by hverstee for vds.240
 *
 * Revision 1.6  1995/09/05  22:51:26  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by hverstee for vds.240
 *
 * Revision 1.5  1995/08/29  20:21:56  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by hverstee for vds.240
 *
 * Revision 1.4  1995/08/18  20:55:10  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by hverstee for vds.240
 *
 * Revision 1.3  1995/08/15  23:37:16  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by hverstee for vds.240
 *
 * Revision 1.2  1995/06/19  19:39:30  pinnacle
 * Replaced: vdinclude/VDCmdDLU.h for:  by hverstee for vds.240
 *
 * Revision 1.1  1995/06/07  21:12:38  pinnacle
 * Created: vdinclude/VDCmdDLU.h by tdumbach for vds.240
 *
 * Revision 1.1  1995/04/29  16:31:00  pinnacle
 * Created: vdinclude/VDCmdDLU.h by hverstee r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *	01/19/01	ylong		ETL4989, no TR# yet
 * -------------------------------------------------------------------*/

#ifndef  VDCmdDLU_h

#define  VDCmdDLU_h

/*       error messages             */

#define VD_DLU_EMSG_MEM    "Memory allocation error, terminated"
#define VD_DLU_EMSG_NTYP   "Type <%s> does not exist"
#define VD_DLU_EMSG_NLOC   "Parameter object is locally modified - Continue?"
#define VD_DLU_EMSG_NPAR   "Parameter object <%s> does not exist"
#define VD_DLU_EMSG_NDBC   "Parameter object is a DB copy - Continue?"
#define VD_DLU_EMSG_NDBO   "Parameter object will overwrite DB - Continue?"
#define VD_DLU_EMSG_NDBP   "Parameter object <%s> posted to DB"
#define VD_DLU_EMSG_NDBE   "Error occurred during Post to DB, check logfile"
#define VD_DLU_EMSG_NOPAR  "Parameter Type not set"
#define VD_DLU_EMSG_NOTAB  "Table Name not set"
#define VD_DLU_EMSG_NODB   "Not logged into Database"
#define VD_DLU_EMSG_NOIDD  "Database Delete disallowed, Not Owner"
#define VD_DLU_EMSG_NOIDP  "Database Post disallowed, Not Owner"
#define VD_DLU_EMSG_FIDEL  "%s <%s> deleted from File"
#define VD_DLU_EMSG_DBDEL  "%s <%s> deleted from Database"

/*       form numbers                                     */

#define VD_DLU_UTILFORM            0
#define VDN_DLU_UTILFORM           "VDDlo_ssutil"

/*       command types                                     */

#define VD_DLU_CMD_DELETE          0
#define VD_DLU_CMD_POST            1

/*       object types                  */

#define VD_DLU_PAR_NONE            0
#define VD_DLU_PAR_DLO             1
#define VD_DLU_PAR_TYP             2
#define VD_DLU_PAR_SRT             3
#define VD_DLU_PAR_SUM             4
#define VD_DLU_PAR_ADS             5
#define VD_DLU_PAR_EXP             6
#define VD_DLU_PAR_EXP_TYP         7
#define VD_DLU_PAR_ALL		   8

/*       predefined objects lists      */

#define VD_DLU_OL_ALL   "All"
#define VD_DLU_OL_DLO   "Table Layout"
#define VD_DLU_OL_STC   "Sort Criterion"
#define VD_DLU_OL_SUC   "Summarization Criterion"
#define VD_DLU_OL_ADS   "Attribute Driven Symbol"
#define VD_DLU_OL_EXP   "Expression Table"

#define VD_DLU_DO_FILE  "Design File"
#define VD_DLU_DO_DB    "Database"
#define VD_DLU_DO_BOTH  "File and DB"

/*       delete level states           */

#define VD_DLU_DST_NONE            0
#define VD_DLU_DST_LOCAL           1
#define VD_DLU_DST_DB              2
#define VD_DLU_DST_BOTH            3

#define VD_DLU_PAR_LENGTH         30

/* --------------------------------------------------------- */
/*       Gadgets for VDDlo_ssutil form                       */
/* --------------------------------------------------------- */

#define VD_DLU_FLD_MSG             9
#define VD_DLU_FLD_MSG2           11
#define VD_DLU_FLD_DESCR          21
#define VD_DLU_FLD_TIMEST         24
#define VD_DLU_FLD_USERID         16
#define VD_DLU_FLD_DBOWNER        25
#define VD_DLU_FLD_LOCAL          26

#define VD_DLU_FLD_PARAM          14
#define VD_DLU_FLD_TABTYP         40
#define VD_DLU_FLD_TABNAM        131
#define VD_DLU_FLD_DELOPT         19

#define VD_DLU_TXT_POST           13
#define VD_DLU_TXT_DELETE         33
#define VD_DLU_TXT_TABTYP         12
#define VD_DLU_TXT_DELOPT         18


/*       special return codes                 */

#define VD_DLU_RETC_NODB         2112

#endif

