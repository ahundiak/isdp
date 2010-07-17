/****************************************************************************/
/*     FILE NAME   -  VRVerFunk.I                                           */
/*                                                                          */
/*     Functions:   VRPrintVerify                                           */
/*                  VRPrintErrHead                                          */
/*                  VRPrintVerHead                                          */
/*                  VRPrintVerObj                                           */
/*                                                                          */
/*     CHANGE HISTORY                                                       */
/*                                                                          */
/*     21 - NOV - 94  Lori   Initial Version                                */
/*
 * 09/05/96 ah TR179600629 Made report narrower
 *
 */
/*                                                                          */
/****************************************************************************/


class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "EXgrid.h"
#include "VRreports.h"
#include "VRverify.h"
#include "vrdef.h"

/* print a new line and check if a new page is needed in error report */
#define F_NEWLINE_ERROR   fprintf(FileData[ERROR_NUM].File_ptr, "\n");\
                          FileData[ERROR_NUM].LineCnt += 1;\
                          if ( FileData[ERROR_NUM].LineCnt > NUMBER_OF_ERR_LINES )\
                          {\
                             FileData[ERROR_NUM].LineCnt = 0;\
                             fprintf(FileData[ERROR_NUM].File_ptr, "\f");\
			     VRPrintErrHead( FileData, NULL );\
                          }\

/* print a new line in Verbose report */
#define F_NEWLINE_VB      fprintf(FileData[VERBOSE_NUM].File_ptr, "\n");\
                          FileData[VERBOSE_NUM].LineCnt += 1;\
                      
/****************************************************************************/
/*                                                                          */
/*D   FUNCTION NAME   -  VRPrintVerify                                      */
/*D                                                                         */
/*D   Abstract:                                                             */
/*D    This function prints lines in the verbose and error reports for      */
/*D    the network validation command                                       */
/*D                                                                         */
/*D    TO BE CALLED WITH MACRO VR$PrintVerify                               */
/*D                                                                         */
/*D   VRPrintVerify  (    IGRboolean         Test,                          */
/*D                       IGRchar            *ErrorBuf,                     */
/*D                       IGRchar            *OKBuf,                        */
/*D                       IGRboolean         Verbose,                       */
/*D                       struct GRid        *ErrObj,                       */
/*D                       GRobjid            Object,                        */
/*D                       GRspecenum         OSnum,                         */
/*D                       IGRdouble          *OrigCoor,                     */
/*D                       IGRint             *ErrorCnt,                     */
/*D                       struct VRvfy_file  *FileData)                     */
/*D                                                                         */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D    Name          I/O        Description                                 */
/*D    -------------------------------------------------------------------  */
/*D                                                                         */
/*D    Test            I         Test to determine if error                 */
/*D    *ErrorBuf       I         Message to print if error                  */
/*D    *OKBuf          I         Message to print if no error               */
/*D    Verbose         I         Print Verbose report?                      */
/*D    *ErrObj         I         Object causing the error if any            */
/*D    Object          I         Object being tested                        */
/*D    OSnum           I         OSnum of object being tested               */
/*D    *OrigCoor       I         Coordinates of object being tested         */
/*D    *ErrorCnt      I/O        Total number of errors                     */
/*D    *FileData      I/O        Error and Verbose file info                */
/*                                                                          */
/****************************************************************************/


VRPrintVerify(Test, ErrorBuf, OKBuf, Verbose, ErrObj, Object,
	      OSnum, OrigCoor, ErrorCnt, FileData)

IGRboolean            Test;
IGRchar               *ErrorBuf;
IGRchar               *OKBuf;
IGRboolean            Verbose;
struct     GRid       *ErrObj;
GRobjid               Object;
GRspacenum            OSnum;
IGRdouble             *OrigCoor;
IGRint                *ErrorCnt;
struct    VRvfy_file  *FileData;

{
  if( Test ) /* Error has occurred, update error report */
    {
      if( ErrorCnt )   /* update error count */
	*ErrorCnt += 1;      

      if ( FileData[ERROR_NUM].File_ptr )
	{
	  fprintf(FileData[ERROR_NUM].File_ptr,"%8d %3d ",
		  Object,OSnum); 
	  
	  if( OrigCoor ) /* Coordinates are present, print them */
	    fprintf(FileData[ERROR_NUM].File_ptr,
		    "%10.3f %10.3f %10.3f ",
		    OrigCoor[0],OrigCoor[1],OrigCoor[2]);
	  
	  else  /* skip space for missing coordinates */
	    fprintf(FileData[ERROR_NUM].File_ptr,"%*c", 33, ' ');

	  if( ErrObj != NULL ) /* An object causing the error is given, print it */
	    fprintf(FileData[ERROR_NUM].File_ptr,
		    "Object: (%d,%d) ", 
		    ErrObj->objid, ErrObj->osnum);
	  
	  /* print out the error buffer to the error file */
	  fprintf(FileData[ERROR_NUM].File_ptr,"%s",ErrorBuf);
	  F_NEWLINE_ERROR; /* print new line and check if new page needed */
	}
      
      if ( Verbose ) /* a verbose report is being printed, update the error */
	{
	  if (FileData[VERBOSE_NUM].File_ptr)
	    {
	      fprintf(FileData[VERBOSE_NUM].File_ptr,"%*c ERROR: ", TAB,' ');
	      if( ErrObj != NULL )
		{
		  fprintf(FileData[VERBOSE_NUM].File_ptr,
			  "Object: (%d, %d) ", 
			  ErrObj->objid, ErrObj->osnum);	       	
		}
	      fprintf(FileData[VERBOSE_NUM].File_ptr," %s", ErrorBuf);
	      F_NEWLINE_VB; /* add new line and check if new page is needed */
	    }
	}
    }

  /* Check if a verbose report is to be printed */
  /* and if there is something to print         */

  else if ( Verbose && OKBuf ) 
    {
      if ( FileData[VERBOSE_NUM].File_ptr )
	{
	  if( ErrObj != NULL)   /* See if there is an object to print */
	    fprintf(FileData[VERBOSE_NUM].File_ptr,
		    "%*c Object: (%d, %d) ", TAB, ' ', 
		    ErrObj->objid, ErrObj->osnum);
	  else
	    fprintf(FileData[VERBOSE_NUM].File_ptr,"%*c ",TAB,' ');
	  
	  /* print the validation message */
	  fprintf(FileData[VERBOSE_NUM].File_ptr,"%s",OKBuf);
	  F_NEWLINE_VB;
	}
    }

  return OM_S_SUCCESS;

} /* End VRPrintVerify */

/****************************************************************************/
/*                                                                          */
/*D    FUNCTION NAME   -  VRPrintErrHead                                    */
/*D                                                                         */
/*D    Abstract:                                                            */
/*D     This function prints the header for the error report in the         */
/*D     validate command                                                    */
/*D                                                                         */
/*D    IGRint VRPrintErrHead ( struct VRvfy_file  *FileData,                */
/*D                            IGRchar            *date                     */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D    Name          I/O        Description                                 */
/*D    -------------------------------------------------------------------  */
/*D                                                                         */
/*D    *FileData      I/O        File info to be updated                    */
/*D    *date           I         Date to be printed on report               */
/*                                                                          */
/****************************************************************************/

static char save_date[30];

VRPrintErrHead( FileData, date )
struct VRvfy_file *FileData;
IGRchar           *date;
{
  if ( FileData[ERROR_NUM].File_ptr )
    {
      /* if We are given the date use it, otherwise use the old date */
      if( date )
	strcpy(save_date, date);

      /* print the title */
      fprintf(FileData[ERROR_NUM].File_ptr,
	      "%*c VERIFICATION ERROR REPORT \n", 20, ' ');
      
      /* print the date */
      fprintf(FileData[ERROR_NUM].File_ptr,
	      "%*c %s \n", 20, ' ', save_date);
      
      /* print the 1st line of the column header */
      fprintf(FileData[ERROR_NUM].File_ptr, 
	"      Object              Location\n");
 
      /* print the 2nd line of the column header */
      fprintf(FileData[ERROR_NUM].File_ptr, 
        "      ID  OS       X          Y          Z    Error Description\n");
      
      /* print the underline */
      fprintf(FileData[ERROR_NUM].File_ptr,
        "------------------------------------------------------------------------\n");
      
      /* update the error report line count */
      FileData[ERROR_NUM].LineCnt += 5;
    }
  return OM_S_SUCCESS;
} /* end VRPrintErrHead */

/****************************************************************************/
/*                                                                          */
/*D    FUNCTION NAME   -  VRPrintVerHead                                    */
/*D                                                                         */
/*D    Abstract:                                                            */
/*D     This function prints the header for the Verbose report in the       */
/*D     validate command                                                    */
/*D                                                                         */
/*D    IGRint VRPrintVerHead ( struct VRvfy_file  *FileData,                */
/*D                            IGRchar            *date                     */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D    Name          I/O        Description                                 */
/*D    -------------------------------------------------------------------  */
/*D                                                                         */
/*D    *FileData      I/O        File info to be updated                    */
/*D    *date           I         Date to be printed on report               */
/*                                                                          */
/****************************************************************************/

VRPrintVerHead( FileData, date )
struct VRvfy_file *FileData;
IGRchar           *date;
{
  if ( FileData[VERBOSE_NUM].File_ptr )
    {
      /* print the title */
      fprintf(FileData[VERBOSE_NUM].File_ptr,
	      "%*c VERIFICATION VERBOSE REPORT \n", CNTRTAB, ' ');
      
      /* print the date */
      fprintf(FileData[VERBOSE_NUM].File_ptr,
	      "%*c %s \n", CNTRTAB+2, ' ', date);
      
      /* update the verbose report line count */
      FileData[VERBOSE_NUM].LineCnt += 2;
  }    
  return OM_S_SUCCESS;
} /* end VRPrintVerHead */
  
/****************************************************************************/
/*                                                                          */
/*D    FUNCTION NAME   -  VRPrintVerObj                                     */
/*D                                                                         */
/*D    Abstract:                                                            */
/*D     This function prints the subheader in the verbose report for each   */
/*D     object which needs to be verified                                   */
/*D                                                                         */
/*D    IGRint VRPrintVerObj  ( struct VRvfy_file  *FileData,                */
/*D                            struct GRid        *Object,                  */
/*D                            IGRchar            *Type)                    */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D    Name          I/O        Description                                 */
/*D    -------------------------------------------------------------------  */
/*D                                                                         */
/*D    *FileData      I/O        File info to be updated                    */
/*D    *Object         I         Object being verified                      */
/*D    *Type           I         Type of object being verified              */
/*D                              ex. Component, Correction, etc.            */
/*                                                                          */
/****************************************************************************/

VRPrintVerObj ( FileData, Object, Type, Product )
struct VRvfy_file *FileData;
struct GRid       *Object;
IGRchar           *Type;
IGRshort          Product;
{
  
IGRchar          ProductName[10];

  ProductName[0] = NULL;
  if ( FileData[VERBOSE_NUM].File_ptr )
    {
      switch(Product)
	{
	case VR_PIPING:
	  {
	    strcpy(ProductName,"Piping");
	    break;
	  }
	case VR_HVAC:
	  {
	    strcpy(ProductName,"HVAC");
	    break;
	  }
	case VR_RWAY:
	  {
	    strcpy(ProductName,"RWAY");
	    break;
	  }
	}	  
      

      fprintf(FileData[VERBOSE_NUM].File_ptr, "\n");
      FileData[VERBOSE_NUM].LineCnt += 1;
      
      /* header for next object to verify */
      fprintf(FileData[VERBOSE_NUM].File_ptr,
	      "Verifications for Object (%d, %d), %s %s \n",Object->objid, 
	      Object->osnum, ProductName, Type);
      fprintf(FileData[VERBOSE_NUM].File_ptr, "%s","------------------------------------------------------------------------------\n");
      FileData[VERBOSE_NUM].LineCnt += 2; /*update line count */
    }

  return OM_S_SUCCESS;
} /* End VRPrintVerObj */

end implementation Root;
  

















