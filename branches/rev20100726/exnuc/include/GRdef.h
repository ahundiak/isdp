#ifndef grdef
/*

   ABSTRACT :
   --------
   
   This file contains usefull definitions for the group stuff.
   
   HISTORY :
   -------

   05/02/1988 : HGB - Creation Date
   09/02/1988 : HGB - OM & IGRdir compatible error codes

   This file depends on the following files : GRtypedef.h
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

   WARNING !!! : Before adding an error code check that it doesn't introduce
                 any conflict at the directory level
*/

#define grdef

/* Miscellaneous Definitions */

#ifndef NULL
#define NULL            0
#endif

/* The group types */
#define DIR_D_PRIVATE	  0	/* private group : no read, no write	*/
#define DIR_D_READ	  1	/* read only group : no write		*/
#define DIR_D_READ_WRITE  2	/* read/write group			*/
#define DIR_D_PUBLIC      2	/* read/write group			*/


/* System limitations */
#define GR_passwd_max	6	/* maximum password length		*/

/* Error Messages */
#define	GR_FACILITY_CODE	DIR_FACILITY_CODE

/* Error numbering (starts from there) */
#define GR_ERROR_BASE		DIR_ERROR_BASE

#ifndef WARN

#define WARN 0
#define SUCC 1
#define ERRO 2
#define INFO 3
#define SEVE 4
#define PERM 8

#endif

/* Error messages */
#define GR_S_SUCCESS 	(SUCC)

#define GR_E_ABORT      DIR_E_ABORT
#define GR_E_INVARG     DIR_E_INVARG
#define GR_E_OVFLOW     DIR_E_OVFLOW
#define GR_E_NAME_DUP   DIR_E_NAME_DUP

#define GR_E_PERMISSION DIR_E_PERMISSION
#define GR_E_PRIVATE	DIR_E_PRIVATE
#define GR_E_READ_ONLY	DIR_E_READ_ONLY
#define GR_E_PASSWD	(GR_FACILITY_CODE << 16)+0X8000+((GR_ERROR_BASE + 103)<< 3)+(ERRO)

#define GR_W_NAME_NOT_FOUND	DIR_W_NAME_NOT_FOUND
#define GR_W_NOT_IMPL		DIR_W_NOT_IMPL

/* Type of request */
#define GR_R_READ	0
#define GR_R_WRITE	1

/* Usefull macros to malloc memory and test the result */

#define GRmalloc(ptr,type,size,status) {\
                                         if (!((ptr) = (type)malloc(size)))\
                                         {\
                                           fprintf ( stderr, "CAN'T malloc\n" );\
                                           return ( status );\
                                         }\
                                       }
                                       
#define GRrealloc(ptr,type,size,status){\
                                         if (!((ptr) = (type)realloc(ptr,size)))\
                                         {\
                                           fprintf ( stderr, "CAN'T realloc\n" );\
                                           return ( status );\
                                         }\
                                       }


#endif

