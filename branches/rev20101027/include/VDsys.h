/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsys.h
 *
 * Description:	UNIX System functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsys.h,v $
 *      Revision 1.1  2001/02/22 23:00:44  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/22/01  ah      Creation
 ***************************************************************************/
#ifndef VDsys_include
#define VDsys_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------
 * vds/vdah/c/VDsys.c
 */
extern IGRstat VDsysFindExeFile __((IGRchar *exeName, IGRchar *exePath));

extern IGRstat VDsysCompressFile   __((IGRchar *fileName));
extern IGRstat VDsysUncompressFile __((IGRchar *fileName));

#define VDSYS_OPTION_COMPRESS   1
#define VDSYS_OPTION_UNCOMPRESS 2

extern IGRstat VDsysCompressOrUncompressFile __((IGRint option, IGRchar *fileName));
extern void    VDsysGetCompressedFileExt     __((IGRchar *ext));

extern IGRstat VDsysCopyFile  __((IGRchar *srcName, IGRchar *desName));

extern IGRstat VDsysChmod __((IGRchar *mode, IGRchar *path));
extern IGRstat VDsysMkdir __((IGRchar *path));

extern IGRstat VDsysDeleteFile __((IGRchar *path));

extern void VDsysGetTimeStamp __((IGRchar *ts));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
