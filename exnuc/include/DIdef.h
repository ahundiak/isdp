#ifndef didef
/*

   ABSTRACT :
   --------
   
   This file contains usefull definitions for the directory stuff.
   
   HISTORY :
   -------

   06/22/1987 : HGB - Creation Date
   03/18/1988 : HGB - Move to OM
   05/02/1988 : HGB - Protection
   08/11/1988 : HGB - DIfree macro
   08/29/1988 : HGB - DI... data types
   09/01/1988 : HGB - OM compatible error codes
   10/21/1991 : HGB - include limits.h rather than defining PATH_MAX
   05/14/1992 : EMS - change PATH_MAX to DI_PATH_MAX (as 1023)

   This file depends on the following files : DItypedef.h

   Note that IGRdir error codes follow OSA standards,  where:

	 bits <0-2>:	severity
			0	warning
			1	success
			2	error
			3	information
			4	severe (fatal) error
			5-7	undefined

	 bits <3-15>	message number (bit 15 set, since facility spec.)

	 bits <16-26>	facility (OM)
*/

#define didef

/*  Define the Directory Path Max  */

#define DI_PATH_MAX	1023


/* Miscellaneous Definitions */

#ifndef NULL
#define NULL            0
#endif

#define DIR_TILDA       '~'
#define TRAILER_MAX     100


/* Definitions used by the options for the ls and find commands */
#define OPT_TRAILER  1	/* Add trailer to object names		*/
#define OPT_LEVEL    2	/* Indent the output to reflect levels	*/
#define OPT_SYS      4	/* Reserved for internal use		*/
#define OPT_CLASS    8	/* Check for class list			*/
#define OPT_ALL     16	/* Display object name starting with .	*/


/* The different storage tables */
#define DIR_D_OBJID_STRING   0	/* key is OM_S_OBJID, datum is string	*/
#define DIR_D_STRING_OBJID   1	/* key is string, datum is OM_S_OBJID   */
#define DIR_D_GRID_STRING    2	/* key is GRid, datum is string		*/
#define DIR_D_STRING_GRID    3	/* key is string, datum is GRid		*/
#define DIR_D_OBJID_POINTERS 4	/* key is OM_S_OBJID, datum is DIdual	*/


/* The group types */
#define DIR_D_PRIVATE	  0	/* private group : no read, no write	*/
#define DIR_D_READ	  1	/* read only group : no write		*/
#define DIR_D_READ_WRITE  2	/* read/write group			*/


/* Maximum number of object spaces that may be loaded */
#define DIR_MAX_OS 256

/* Error Messages */
#define	DIR_FACILITY_CODE	0x250

/* Error numbering (starts from there) */
#define DIR_ERROR_BASE		500

#ifndef WARN

#define WARN 0
#define SUCC 1
#define ERRO 2
#define INFO 3
#define SEVE 4

#endif


#define DIR_S_SUCCESS (SUCC)

#define DIR_E_ABORT         (DIR_FACILITY_CODE << 16)+0X8000+((131)<< 3)+(ERRO)
#define DIR_E_INVARG        (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 0)<< 3)+(ERRO)
#define DIR_E_NAME_DUP      (DIR_FACILITY_CODE << 16)+0X8000+((61)<< 3)+(ERRO)
#define DIR_E_DIR_DUP       (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 2)<< 3)+(ERRO)
#define DIR_E_SYNTAX        (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 3)<< 3)+(ERRO)
#define DIR_E_OVFLOW        (DIR_FACILITY_CODE << 16)+0X8000+((44)<< 3)+(ERRO)
#define DIR_E_ILL_NAME      (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 5)<< 3)+(ERRO)
#define DIR_E_ILL_LINK      (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 6)<< 3)+(ERRO)
#define DIR_E_NO_NAME       (DIR_FACILITY_CODE << 16)+0X8000+((65)<< 3)+(ERRO)
#define DIR_E_DIR_NOT_EMPTY (DIR_FACILITY_CODE << 16)+0X8000+((66)<< 3)+(ERRO)

#define DIR_E_PERMISSION (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 100)<< 3)+(ERRO)
#define DIR_E_PRIVATE    (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 101)<< 3)+(ERRO)
#define DIR_E_READ_ONLY  (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 102)<< 3)+(ERRO)

#define DIR_W_NAME_NOT_FOUND (DIR_FACILITY_CODE << 16)+0X8000+((63)<< 3)+(WARN)
#define DIR_W_DIR_NOT_FOUND  (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 200)<< 3)+(WARN)
#define DIR_W_NOT_IMPL       (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 201)<< 3)+(WARN)
#define DIR_W_NO_NAME        (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 202)<< 3)+(WARN)

#define DIR_I_DIR_EMPTY (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 300)<< 3)+(INFO)
#define DIR_I_REORG     (DIR_FACILITY_CODE << 16)+0X8000+((DIR_ERROR_BASE + 301)<< 3)+(INFO)


/* Type of request */
#define DIR_R_READ	0
#define DIR_R_WRITE	1


/* Data type definitions */

#define DIstring_node  struct { DIchar *str; }
#define DIstring_objid struct { DIchar *str; DIobjid id; }
#define DIdual         struct { DIint counter; DIchar **dirnames;\
                                DIchar **objnames; }
#define DIstring_ptr   struct { DIobjid id; DIdual pointers; }
#define DIstring_grid  struct { DIchar *str; DIgrid id; }

#endif
