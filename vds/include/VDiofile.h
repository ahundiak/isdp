/* $Id: VDiofile.h,v 1.2 2001/02/23 16:27:33 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDiofile.h
 *             
 *
 * Description: Definitions for basic io on table expressions files
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDiofile.h,v $
 *      Revision 1.2  2001/02/23 16:27:33  paul_noel
 *      Correct struct def
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/16/01  pn      Creation
 ***************************************************************************/

#define VDIO_FILE_NAME_LEN     24
#define VDIO_LINE_LEN         128
#define VDIO_STR_LEN          128

/***************************************************************************
 *
 * STRUCTURE TO DEFINE FILE FOR RETRIEVAL 
 * Output: filebuf is a pointer to a list of lines contained in a file
 *         MEMORY ALLOCATED HERE
 * Input : filename is the name of the file
 * Output: lines is the count of the lines in the file
 * Input : linelength is the length of the line usually set to VDIO_LINE_LEN
 * Input : partpath is the partial path to the file you are looking to open
 *
 ***************************************************************************/

typedef struct  {
  IGRchar *filebuf ;
  IGRchar filename[VDIO_FILE_NAME_LEN];
  IGRint  lines;
  IGRint  linelength;
  IGRchar partpath[VDIO_STR_LEN];
} VDioBufDat ;


