#include <stdio.h>
#include "FS.h"
#include "FFerrdef.h"

#define FF_DEFINE_ERRMSG

FF_report_error( status )

	int	status;

{
	int	error_type;
	int	error_msg;


	static char *err_type[] = {
	   "\n*** WARNING ***\n",
	   "\n*** SUCCESS ***\n",
	   "\n*** ERROR ***\n",
	   "\n*** INFORMATION ***\n",
	   "\n*** SEVERE ERROR ***\n"
	   };

   static char *err_msg[] = {
     "FF-SCREEN_INFO_ERROR, Reconfigure virtual screens to one plane.\n",
     "FF-LOAD_VLT_ERROR, Failure to load the vlt.\n",
     "FF-DIR_PATH_ERROR, Invalid pathname to a directory found.\n",
     "FF-MALLOC_ERROR, Failure to allocate dynamic memory.\n",
     "FF-KERNAL_NOT_LOADED, Unable to load font into the kernal.\n",
     "FF-LOAD_REPLACED, A Loaded Font was trashed in load request.\n",
     "FF-LOAD_DUPLICATED, Font was duplicated in the load request.\n",
     "FF-REPFILE_NOT_OPENED, Error opening the report file.\n",
     "FF-FILE_NOT_OPEN, Font file not open.\n",
     "FF-FILE_TREE_ERROR, Failure in ftw system call to walk file tree.\n",
     "FF-FILE_SEEK_ERROR, failure on file seek.\n",
     "FF-FILE_READ_ERROR, Error reading a font file.\n",
     "FF-FILE_STAT_ERROR, Error in file status buffer.\n",
     "FF-FILE_NOT_FS, Font file is not a Font Server file.\n",
     "FF-FILE_NOT_AFM, Font file is not an Abobe Font Metrics file.\n",
     "FF-FILE_NOT_FLIB, Font file is not an VAX Font Library file.\n",
     "FF-FILE_NOT_CLOSED, Error closing the font file.\n",
     "FF-FILE_WRITE_ERROR, Error writing the font file.\n",
     "FF-CHAR_NOT_FOUND, Character(s) not fount in font file.\n",
     "FF-CHAR_INTER_ALLOCATE, Unable to allocate a character buffer(s).\n",
     "FF-CHAR_RET_ALLOCATE, Unable to return a character buffer(s).\n",
     "FF-CHAR_TO_BIG, Resulting character is to big.\n",
     "FF-CHAR_INVALID_TYPE, Invalid character element type found.\n",
     "FF-CHAR_INTEG_QUEST, Char integrity questionable with scale factor.\n",
     "FF-FONT_NOT_LOADED, The font was not successfully loaded.\n",
     "FF-FONT_NOT_OPENED, Error opening Font file.\n",
     "FF-FONT_WRONG_VERSION, Font version incompatible with font service.\n",
     "FF-FONT_ALREADY_LOADED, The font was loaded by a previous command.\n",
     "FF-FONT_INTER_ALLOCATE, Unable to allocate the font buffer(s).\n",
     "FF-FONT_INVALID_DESCRIPTOR, Font file descriptor is an invalid value.\n",
     "FF-FONT_DESCRIPTOR_NOT_FOUND, Font file descriptor was not found.\n",
     "FF-FONT_MAXOFFSETS, Offset greater than the font file size.\n",
     "FF-FONT_ID_RANGE_ERROR, Failure to allocate dynamic memory.\n",
     "FF-FONT_OUTLREAD_ERROR, Failure to read an outline data record.\n",
     "FF-FONT_OUTL_REC_ERROR, Undefined character outline record found.\n",
     "FF-FONT_OUTL_ERROR, Undefined outline found in record.\n",
     "FF-FONT_INVALID_BLKHEAD, Invalid data in font section block header.\n",
     "FF-FONT_PLAID_FUNC_ERROR, Plaid function item/record not recognised.\n",
     "FF-FONT_PLAID_ZONE_ERROR, Plaid zone item/record not recognised.\n",
     "FF-FONT_PLAID_EDGE_ERROR, Plaid edges not followed by plaid zones.\n",
     "FF-FONT_OUTL_STATE_ERROR, outline record type/state not recognised.\n",
     "FF-SYMFILE_BUILD_ERROR, Error building the symbol file.\n",
     "FF-KERNTBL_NOT_FOUND, No kerning table in the font file.\n",
     "FF-LIGTBL_NOT_FOUND, No ligature table in the font file.\n",
     "FF-TRACKTBL_NOT_FOUND, No kern track tables in the font file.\n",
     "FF-MAP_NOT_FOUND, Invalid character mapping request.\n",
     "FF-ERRDEF_NOT_DEFINED, The Font Server error message is not defined.\n"
     };

   if ( FF_MSG( status ) ){
      error_type =  status & 0x00000007;
      error_msg  = ((status & 0x000000f8) >> 3) + 2;
      }

   printf("%s", err_type[error_type]);
   printf("%s", err_msg[error_msg]);

   return;
}




FS_report_error( status )

	int	status;

{
	int   index;

   static char *FSerr_msg[] = {
     "FS-NO_ERROR  No error occurred.\n",
     "FS-ERROR  General error.\n",
     "FS-INVAID_FONT  Invalid font id.\n",
     "FS-INVALID_CHAR  Invalid character id.\n",
     "FS-INVALID_CM_FILE  Invalid typeface id.\n",
     "FS-CANT_ALLOC  Memory cannot be allocated.\n",
     "FS-CANT_MAKE_FONT  An error occurred while making the font.\n",
     "FS-FILE_NOT_FOUND  The file cannot be found.\n",
     "FS-FILE_NOT_WRITTEN  The file cannot be written.\n",
     "FS-INVALID_SYMBOL_FILE  Invalid Environ V symbol font.\n",
     "FS-INVALID_TF_FILE  Invalid typeface file.\n",
     "FS-INVALID_FONT_FILE  Invalid bitmap font file.\n",
     "FS-INVALID_CHAR_MAP  Invalid character mapping",
     "FS-UNDEFINED  Undefined error type found.\n",
     };

    switch ( status ) {

       case FS_NO_ERROR :
        index = 0;
        break;

      case FS_ERROR :
        index = 1;
        break;

      case FS_INVALID_FONT :
        index = 2;
        break;

      case FS_INVALID_CHAR :
        index = 3;
        break;

      case FS_INVALID_CM_FILE :
        index = 4;
        break;

      case FS_CANT_ALLOC :
        index = 5;
        break;

      case FS_CANT_MAKE_FONT :
        index = 6;
        break;

      case FS_FILE_NOT_FOUND :
        index = 7;
        break;

      case FS_FILE_NOT_WRITTEN :
        index = 8;
        break;

      case FS_INVALID_SYMBOL_FILE :
        index = 9;
        break;

      case FS_INVALID_TF_FILE :
        index = 10;
        break;

      case FS_INVALID_FONT_FILE :
        index = 11;
        break;

      case FS_INVALID_CHAR_MAP :
        index = 12;
        break;

      default :
        index = 13;
        break;

      }

   printf("%s", FSerr_msg[index]);

   return;
}
