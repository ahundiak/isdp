/* $Id: VDgenfam.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $ */

/* I/VDS
 *
 * File:     vdinclude/VDgenfam.h
 *
 * Description:
 *      Defines constants for Generate Family Files
 *
 * Dependancies
 *  
 *      VDgenfamfil.sl
 *      VDgenfamfnc.I    
 *
 * Revision History:
 *	$Log: VDgenfam.h,v $
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
 *      25/02/94       Chaya Rao  Created file from ppl file VDgenfamfil.u.
 *
 *              Changed the form related to the command to give a logical
 *              workflow.  Added a new .mb file which includes prompts,
 *              messages, and status information to the command.
 *      19/04/94       Chaya Rao  added gadgets 32 and 33 for default 
 *              support files. 
 */

/****************************************************************************


		File:	VDgenfam.h
		Type:   c include file
		Use:	Defines constants for Generate Family Files
		
***************************************************************************/

#ifndef VDgenfam_include

#define VDgenfam_include


#define FI_INSERT       0
#define FI_REVIEW       1

/* Gadgets */
#define MESS1		9    /* message field    */
#define MESS2		10   /* user input field */
#define FAMILY		19   /* Family/part toggle button */
#define MAC_LIB_TEXT	11   /* text for macro library button */
#define MAC_LIB		15   /* macro library button */
#define MACRO_TEXT	12   /* macro/families text  */
#define MACRO		14   /* macro/families button */ 
#define LIST		17   /* multicolumn field that displays data */ 
#define HIDDEN_FAM_LIST 29   /* multicolumn field that displays data */
#define HIDDEN_PART_LIST 31  /* multicolumn field that displays data */

#define ATT_NAME	18   /* form text */
#define ATT_TYPE	20   /* form text */
#define SYNONYM		21   /* form text */
#define WRITE		22   /* button used to write family/part file */
#define APPEND		23   /* add part  */
#define PART		28   /* text for button PART_LIST */
#define PART_LIST	27   /* button that displays number of parts defined */
#define FILE_CHECK	16   /* button to overwrite family file */
#define FILE_QUIT	24   /* button to quit without overwriting */
#define ATT_TYP_TEXT	25   /* form text */
#define ATT_NAME_TEXT	18   /* form text */
#define ATT_CHAR_TEXT	20   /* form text */
#define ATT_DEF_TEXT	21   /* form text */
#define HIDE_ALL	30   /* toggle button near message field that toggles*/
                             /* between hidden part, family list and LIST */
#define DEF_FILE        32   /* new gadget to show default support files  */
#define DEF_TEXT        33   /* form text                                 */ 

/* MF defines */

#define	VDgen_FAM_LIST	"/tmp/VDGnFmFl.fam"
#define	FAM_NUMB	"/tmp/VDGnFmFl.wc"
#define SUB_PATH        "config/family"
#define FRM_NAME        "VDGenFamFil"
#define predef          "VDGnFmFl" /* names of files in config/family
                                    * start with VDGnFmFl
                                    */
#define MAXWORD		132
#define	NFM1    	"n_catalogname"
#define	NFM2	        "n_cofilename"
#define	NFM3            "n_creator"
#define	PDM1	        "n_creationdate"
#define	PDM2	        "p_creationtime"
#define	PDM3	        "n_itemdesc"
#define	PDM4	        "p_parttype"
#define	PDM5	        "n_itemrev"
#define	PDM6	        "n_itemname"

#endif
