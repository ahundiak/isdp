/*
-------------------------------------------------------------------------------
	Name:			FFerrdef.h
	Author:			Stanley E. Williams
	Creation Date:		11-Dec-1986
	Operating System(s)	Unix SysV
	Abstract:

	   This file contains FF error definitions by symbol.  These symbols
	are of the form :

			FF_E_errorname

	   Where "errorname" is the name of the error.  When this file is 
	   included in a module where the symbol FF_D_DEFINE_ERRMSG IS
	   defined, then both the error symbols and a set of error messages 
	   are created.  The error messages are then known by a symbol:

				FF_erm_errorname

	   where "errorname" is the same as in FF_E_errorname.

	   Note that FF error codes folow OSA standards, where:

	   bits <0-2>	severity
			0	warning
			1	success
			2	error
			3	information
			4	severe (fatal) error
			5-7	undefined

	   bits <3-15>	message number (bit 15 is set, since facility spec.)

	   bits <16-26>	facility (FF)

	Revision History:	

-------------------------------------------------------------------------------
*/

/*
$Log: FFerrdef.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:48  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:03  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:02  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:13  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:31  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:31  tim
 * COMMENT : added Log variable
 *
*/

#ifndef FFerrdef_include
#define FFerrdef_include

#define FF_FACILITY_CODE	(0x240)

#define FF_MSG(sts)       (((0x8000 & sts)>> 15) == 1)

#define WARN	               (0)
#define SUCC	               (1)
#define FF_S_SUCCESS        (SUCC)
#define ERRO	               (2)
#define INFO	               (3)
#define SEVE	               (4)

#define FF_WARNING(sts)       ((sts & 7) == 0)
#define FF_SUCCESS(sts)       ((sts & 7) == 1)
#define FF_ERROR(sts)         ((sts & 7) == 2)
#define FF_INFORMATION(sts)   ((sts & 7) == 3)
#define FF_SEV_ERROR(sts)     ((sts & 7) == 4)

#define FATAL_ERROR(sts) ( (((sts & 4) >> 2) == 1) \
                        || (((sts & 2) >> 1) == 1) )

#define SEV_LEV                7

#define FF_ERROR_CK(str,sts) if (FF_ERROR(sts) || FF_SEV_ERROR(sts)){ \
                                 printf("%s%c",str,'\n'); \
                                 return ( sts ); \
                                 } \
                            else if (FF_INFORMATION(sts)  \
                                  || FF_WARNING(sts)){ \
                                 printf("%s%c",str,'\n'); \
                                 FF_report_error(sts); \
                                 }

/*
----------------------------------------------------------------------------
	   Now we define the FF error symbols and messages.
----------------------------------------------------------------------------
*/

#define FF_SCREEN_INFO_ERROR         (((FF_FACILITY_CODE<<13)+0x1000+0)<<3)
#define FF_LOAD_VLT_ERROR            (((FF_FACILITY_CODE<<13)+0x1000+1)<<3)
#define FF_DIR_PATH_ERROR            (((FF_FACILITY_CODE<<13)+0x1000+2)<<3)
#define FF_MALLOC_ERROR              (((FF_FACILITY_CODE<<13)+0x1000+3)<<3)
#define FF_KERNAL_NOT_LOADED         (((FF_FACILITY_CODE<<13)+0x1000+4)<<3)
#define FF_LOAD_REPLACED             (((FF_FACILITY_CODE<<13)+0x1000+5)<<3)
#define FF_LOAD_DUPLICATED           (((FF_FACILITY_CODE<<13)+0x1000+6)<<3)
#define FF_REPFILE_NOT_OPEN          (((FF_FACILITY_CODE<<13)+0x1000+7)<<3)
#define FF_FILE_NOT_OPEN             (((FF_FACILITY_CODE<<13)+0x1000+8)<<3)
#define FF_FILE_TREE_ERROR           (((FF_FACILITY_CODE<<13)+0x1000+9)<<3)
#define FF_FILE_SEEK_ERROR           (((FF_FACILITY_CODE<<13)+0x1000+10)<<3)
#define FF_FILE_READ_ERROR           (((FF_FACILITY_CODE<<13)+0x1000+11)<<3)
#define FF_FILE_STAT_ERROR           (((FF_FACILITY_CODE<<13)+0x1000+12)<<3)
#define FF_FILE_NOT_FS               (((FF_FACILITY_CODE<<13)+0x1000+13)<<3)
#define FF_FILE_NOT_AFM              (((FF_FACILITY_CODE<<13)+0x1000+14)<<3)
#define FF_FILE_NOT_FLIB             (((FF_FACILITY_CODE<<13)+0x1000+15)<<3)
#define FF_FILE_NOT_CLOSED           (((FF_FACILITY_CODE<<13)+0x1000+16)<<3)
#define FF_FILE_WRITE_ERROR          (((FF_FACILITY_CODE<<13)+0x1000+17)<<3)
#define FF_CHAR_NOT_FOUND            (((FF_FACILITY_CODE<<13)+0x1000+18)<<3)
#define FF_CHAR_INTER_ALLOCATE       (((FF_FACILITY_CODE<<13)+0x1000+19)<<3)
#define FF_CHAR_RET_ALLOCATE         (((FF_FACILITY_CODE<<13)+0x1000+20)<<3)
#define FF_CHAR_TO_BIG               (((FF_FACILITY_CODE<<13)+0x1000+21)<<3)
#define FF_CHAR_INVALID_TYPE         (((FF_FACILITY_CODE<<13)+0x1000+22)<<3)
#define FF_CHAR_INTEG_QUEST          (((FF_FACILITY_CODE<<13)+0x1000+23)<<3)
#define FF_FONT_NOT_LOADED           (((FF_FACILITY_CODE<<13)+0x1000+24)<<3)
#define FF_FONT_NOT_OPEN             (((FF_FACILITY_CODE<<13)+0x1000+25)<<3)
#define FF_FONT_WRONG_VERSION        (((FF_FACILITY_CODE<<13)+0x1000+26)<<3)
#define FF_FONT_ALREADY_LOADED       (((FF_FACILITY_CODE<<13)+0x1000+27)<<3)
#define FF_FONT_INTER_ALLOCATE       (((FF_FACILITY_CODE<<13)+0x1000+28)<<3)
#define FF_FONT_INVALID_DESCRIPTOR   (((FF_FACILITY_CODE<<13)+0x1000+29)<<3)
#define FF_FONT_DESCRIPTOR_NOT_FOUND (((FF_FACILITY_CODE<<13)+0x1000+30)<<3)
#define FF_FONT_MAXOFFFETS           (((FF_FACILITY_CODE<<13)+0x1000+31)<<3)
#define FF_FONT_ID_RANGE_ERROR       (((FF_FACILITY_CODE<<13)+0x1000+32)<<3)
#define FF_FONT_OUTLREAD_ERROR       (((FF_FACILITY_CODE<<13)+0x1000+33)<<3)
#define FF_FONT_OUTL_REC_ERROR       (((FF_FACILITY_CODE<<13)+0x1000+34)<<3)
#define FF_FONT_OUTL_ERROR           (((FF_FACILITY_CODE<<13)+0x1000+35)<<3)
#define FF_FONT_INVALID_BLKHEAD      (((FF_FACILITY_CODE<<13)+0x1000+36)<<3)
#define FF_FONT_PLAID_FUNC_ERROR     (((FF_FACILITY_CODE<<13)+0x1000+37)<<3)
#define FF_FONT_PLAID_ZONE_ERROR     (((FF_FACILITY_CODE<<13)+0x1000+38)<<3)
#define FF_FONT_PLAID_EDGE_ERROR     (((FF_FACILITY_CODE<<13)+0x1000+39)<<3)
#define FF_FONT_OUTL_STATE_ERROR     (((FF_FACILITY_CODE<<13)+0x1000+40)<<3)
#define FF_SYMFILE_BUILDERROR        (((FF_FACILITY_CODE<<13)+0x1000+41)<<3)
#define FF_KERNTBL_NOT_FOUND         (((FF_FACILITY_CODE<<13)+0x1000+42)<<3)
#define FF_LIGTBL_NOT_FOUND          (((FF_FACILITY_CODE<<13)+0x1000+43)<<3)
#define FF_TRACKTBL_NOT_FOUND        (((FF_FACILITY_CODE<<13)+0x1000+44)<<3)
#define FF_MAP_NOT_FOUND             (((FF_FACILITY_CODE<<13)+0x1000+45)<<3)

#endif   /* end of FFerrdef_include */
