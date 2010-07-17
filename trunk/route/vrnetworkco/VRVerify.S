/* ******************************************************************

Author   : Lori

Date     : Nov 21, 1994

Abstract : This is the super class for the Verify Network/Global Verify
           commands.

History :
---------

        Date    + Autor +       Description
        ========+=======+==============================================


*********************************************************************** */



class specification VRVerify (1:0) of VDB_LOCATE;

#include <stdio.h>

#include "growner.h"
#include "grio.h"
#include "VRverifys.h"

instance VRVerify
{

  IGRint                 Product;    

			 /*C User wants to exit - clicks stopsign */
  IGRboolean		 bUserExit;

                         /*C number of objects to be verified  */
  IGRint                 NumOfObjects; 

                         /*C list of located objects           */
  struct      GRid       *LocatedObjects; 

			 /*C Pointer to objects to verify      */
  struct      GRid       *ObjToProcess;

			 /*C Number of objects to verify       */
  IGRint                 NumToProcess;

                         /*C objects to be obtained from       */
                         /*C located objects                   */
  struct      VRvfy_objs NewObj[3];    
				       
                         /*C module environment                */
  struct      GRmd_env   md_env;       

                         /*C Validate net? yes: true/no: false */
  IGRboolean             bNetCommand;  
  
                         /*C Verbose Rpt? yes: true/no: false  */
  IGRboolean             bVerbose;     

			 /*C Objects highlighted? yes: true/no: false */ 
  IGRboolean             bHighlight;     

                         /*C Error rpt file name */
  IGRchar                ErrorFileName[GR_MAX_CHAR];

                         /*C Verbose rpt file name*/ 
  IGRchar                VerbFileName[GR_MAX_CHAR];

                         /*C Count of the number of errors    */
  IGRint                 ErrorCnt;      

                         /*C File information    */
  struct      VRvfy_file FileData[NUM_VERIFY_FILES]; 

                         /*C Which file to process            */
  IGRint                 CurrentFile;   

                         /*C date for report                  */
  IGRchar                date[30];         
			
			 /* place to store md_env from fence  */
  struct  GRmd_env       *Fencemd_env;
};

/*C override messages */
override init;
override delete;

/*C Local Messages */

/*C Perform validations on objects */
message VRVerifyObjects ( long * sts );

/*C messages dealing with file operations / command operations */
message check_response_y ( long * sts );
message check_response_n ( long * sts );
message free_memory ( long * sts );
message dehighlight ( long * sts );
message title_reports ( long * sts );
message end_reports ( long * sts );
message set_verbose ( long * sts );
message set_error ( long * sts );
message store_file_name ( long * sts );
message open_files( long * sts );
message close_files( long * sts );




end specification VRVerify;










