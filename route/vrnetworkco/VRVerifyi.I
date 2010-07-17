/* $Id: VRVerifyi.I,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnetworkco / VRVerifyi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRVerifyi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.7  1996/04/04  21:23:22  pinnacle
# Replaced: vrnetworkco/VRVerifyi.I for:  by hverstee for route240
#
# Revision 1.6  1996/03/05  22:36:34  pinnacle
# Replaced: vrnetworkco/VRVerifyi.I for:  by hverstee for route240
#
# Revision 1.5  1996/03/04  20:47:40  pinnacle
# Replaced: vrnetworkco/VRVerifyi.I for:  by hverstee for route240
#
# Revision 1.4  1996/01/17  00:10:10  pinnacle
# Replaced: vrnetworkco/VRVerifyi.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add prototypes
 *
 *************************************************************************/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS  NAME: VRVerify

     ABSTRACT:  This is the super command for the Verify Network/Global Verify
                Commands.  

     CHANGE HISTORY:

        Lori : 11-21-1994       Creation


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


class implementation VRVerify;

#include <stdio.h>
#include <sys/stat.h>
#include <time.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "EXgrid.h"
#include "AS_status.h"
#include "VDmem.h"
#include "VRverify.h"
#include "VRverifymac.h"
#include "ACrg_collect.h"
#include "vrmacros.h"
#include "vrdef.h"
#include "VRmsg.h"
#include "coparamac.h"
#include "vrtools_pto.h"

from VRGeneric import VRVerifyTopology;
from VRplane import VRVerPlaneTopology;
from VRCorrection import VRVerCorrTopology;
from VRCnrlSeg import VRVerCSTopology;
from VRGeneric import VRVerifyModel;
from VRGeneric import VRVerifyFlow;
from VRGeneric import VRVerifyConnect;
from VRGeneric import VRVerifyAttributes;
from NDnode import NDdisplay;
from VRProduct import VRGetProduct;
from VRCnrlSeg import VRGetSegProduct;

extern GRclassid OPP_VRCorrection_class_id;
extern GRclassid OPP_VRCnrlSeg_class_id;
extern GRclassid OPP_VRComponent_class_id;
extern GRclassid OPP_VRConcComp_class_id;
extern GRclassid OPP_VRplane_class_id;



method init ( int type ; char * str_ptr )
{
  int             i;
  int		  status = OM_S_SUCCESS;

  /*C initialize instance data */

  /*C Call parent init message */
  
  status =
    om$send( msg    = message VDB_LOCATE.init ( type, str_ptr ),
	    mode   = OM_e_wrt_message,
	    targetid = my_id);
  as$status( action = RET_STATUS );

  me->FileData[ERROR_NUM].LineCnt = 0;
  me->FileData[VERBOSE_NUM].LineCnt = 0;
  me->FileData[ERROR_NUM].File_ptr = NULL;
  me->FileData[VERBOSE_NUM].File_ptr = NULL;

  for (i=0; i<3; i++)
  {
    me->NewObj[i].object    = NULL;
    me->NewObj[i].ObjCount  = 0;
    me->NewObj[i].ArraySize = 0;
  }

  me->ErrorCnt = 0;
  me->Product = -1;
  me->NumOfObjects = 0;
  me->LocatedObjects = NULL;
  me->NumToProcess = 0;
  me->ObjToProcess = NULL;
  me->bVerbose = FALSE;
  strcpy(me->ErrorFileName,"VerError");
  strcpy(me->VerbFileName,"VerVerb");
  me->CurrentFile = -1;
  me->bHighlight = FALSE;
  me->bUserExit = FALSE;
  me->bNetCommand = FALSE;
  me->Fencemd_env = NULL;

  return status;
} /* end init */

method delete ( int f_defer_flag )
{
  int                status = OM_S_SUCCESS;
  IGRlong            sts;


  if (!(me->VDB_terminated))
  {
    /*C dehighlight objects */
    status = om$send( msg = message VRVerify.dehighlight ( &sts ),
		   targetid = my_id);

    status = om$send( msg = message VRVerify.free_memory ( &sts ),
		   targetid = my_id);
  
    status = om$send( msg = message VRVerify.close_files ( &sts ),
		   targetid = my_id);
  }

  /*C Call parent delete */
  status = om$send (    mode     = OM_e_wrt_message,
                  msg      = message VDB_LOCATE.delete( f_defer_flag),
                  targetid = my_id);
  as$status( sts = sts, action = RET_STATUS );


  return OM_S_SUCCESS;
}  /* end delete */

method free_memory ( long *sts )
{
  *sts = MSSUCC;

  me->NumOfObjects = 0;
  _FREE ( me->LocatedObjects );

  /*C Set the static by file variable for dynamic array length */
  /*C after memory is freed to 0 in file vrtools/VRSelect.I    */
  VRFreeStaticSelect();

  me->NewObj[CORR_OBJ_NUM].ObjCount = 0;
  me->NewObj[CORR_OBJ_NUM].ArraySize = 0;
  _FREE ( me->NewObj[CORR_OBJ_NUM].object );

  me->NewObj[CS_OBJ_NUM].ObjCount = 0;
  me->NewObj[CS_OBJ_NUM].ArraySize = 0;
  _FREE ( me->NewObj[CS_OBJ_NUM].object );

  me->NewObj[PLANE_OBJ_NUM].ObjCount = 0;
  me->NewObj[PLANE_OBJ_NUM].ArraySize = 0;
  _FREE ( me->NewObj[PLANE_OBJ_NUM].object );

  /*A Free the module environments allocated if a fence was used */
  _FREE ( me->Fencemd_env);
  
  return OM_S_SUCCESS;

} /* end free_memory */

method dehighlight ( long *sts )
{
  IGRint                     i;
  IGRlong                    status;
  struct   GRmd_env          *md_env;
  enum     GRdpmode          mode;

  *sts = MSSUCC;

  mode = GRheo;
  md_env = &me->md_env;

  /* if I have highlighted objects, dehighlight them */
  if( me->bHighlight )
    {
      for( i = 0; i < me->NumOfObjects; i++ )
	{ 
	  if(!me->bNetCommand)
	    md_env = &me->Fencemd_env[i];

	  status = om$send(msg = message NDnode.NDdisplay
			   (0, mode, md_env),
			   targetid = me->LocatedObjects[i].objid,
			   targetos = me->LocatedObjects[i].osnum);
	}
    }
  me->bHighlight = FALSE;
  return OM_S_SUCCESS;
} /* end dehighlight */
      
method set_error ( long *sts )
{
  /*A set the current file to be processed to be the error report file */
  *sts = MSSUCC;
  me->CurrentFile = ERROR_NUM;
  return OM_S_SUCCESS;

} /* end set_error */

method set_verbose ( long *sts )
{
  /*A set the current file to be processed to be the verbose report file */
  *sts = MSSUCC;
  me->CurrentFile = VERBOSE_NUM;
  me->bVerbose = TRUE;
  return OM_S_SUCCESS;
} /* end set_verbose */

method store_file_name( long *sts ) 
{

/*A
   Before storing instance 'me->file_name', this method check if
   the given file name exists and isn't a directory. The value of
   msg are :
        - VR_K_FileIsDirectory  : The given file name is a directory
        - VR_K_FileExist        : The given file name exist.
        - MSSUCC                : The given file name doen't exist.
 */
  IGRlong         status;
  struct stat     state_file ;

  if ( me->CurrentFile == ERROR_NUM ) 
    strcpy( me->ErrorFileName, me->event1.event.keyin ) ;
  else
    strcpy( me->VerbFileName, me->event1.event.keyin ) ;

  /*"file_name : %s\n", me->file_name */

  /* See if the file exists and isn't a directory. */
  status = stat( me->event1.event.keyin, &state_file ) ;

  if( status == 0 )
    {
        /*
         * File exists. See if it's a directory.
         */
        if( S_ISDIR( state_file.st_mode ) ) 
	  {
	    /*|File is a directory */
	    *sts = VR_K_FileIsDirectory ;
	  } 
	else 
	  {
	    /*|File exists */
	    *sts = VR_K_FileExist ;
	  }
      }
  else 
    {
      /*
       * File doesn't exist.
       */
      /*|File doesn't exist */
      *sts = MSSUCC ;
    }

  return OM_S_SUCCESS;
} /* end store_file_name */



method check_response_y( long *response )
{  
 
  /*A checked typed in reponse, default is yes */
  if( !strcmp( "n", me->event1.event.keyin ) ||
      !strcmp( "N", me->event1.event.keyin ) ) 
    {
      *response = FALSE ;
    }
  else
    {
      *response = TRUE ;
    }
	
  return OM_S_SUCCESS;
} /* end check_response_y */



method check_response_n( long *response )
{  

  /*A checked typed in reponse, default is no */
  if( !strcmp( "y", me->event1.event.keyin ) ||
      !strcmp( "Y", me->event1.event.keyin ) ) 
    {
      *response = TRUE ;
    }
  else
    {
      *response = FALSE ;
    }
       
  return OM_S_SUCCESS;

} /* end check_response_n */

	  


method close_files( long * sts )
{
  *sts = MSSUCC;

  if (me->FileData[ERROR_NUM].File_ptr != NULL)
    fclose( me->FileData[ERROR_NUM].File_ptr );
  if (me->FileData[VERBOSE_NUM].File_ptr != NULL)
    fclose( me->FileData[VERBOSE_NUM].File_ptr );
  
  return OM_S_SUCCESS;
} /* end close_files */
	
method open_files( long * sts )
{
/*A
   This method open file on write mode. The value of *sts are :
   - VR_K_CantCreateFile        : Cannot create file.
   - MSSUCC                     : Sucessfull operation.
 */

  me->FileData[ERROR_NUM].File_ptr = fopen( me->ErrorFileName, "w" ) ;
  
  if( !me->FileData[ERROR_NUM].File_ptr ) 
    {
      /*A Cannot create file */
      *sts = VR_K_CantCreateErrFile ;
      return OM_S_SUCCESS;
    }
  else 
    {
      /*A File create */
      *sts = MSSUCC ;
    }
  if (me->bVerbose)
  {
    me->FileData[VERBOSE_NUM].File_ptr = fopen( me->VerbFileName, "w" ) ;
    
    if( !me->FileData[VERBOSE_NUM].File_ptr )  
      {
        /*A Cannot create file */
        *sts = VR_K_CantCreateVerbFile ;
      }
    else
      {
        /*A File create */
        *sts = MSSUCC ;
      }
  }
  return OM_S_SUCCESS;
} /* end open_files */


method title_reports( long * sts )
{

  time_t  dh;

  time( &dh ) ;
  strcpy(me->date, ctime( &dh ));

  /*A Print header on error report */
  VR$PrintErrHead( FileData = me->FileData, date = me->date );

  /*A if printing a verbose report, print that header */
  if( me->bVerbose )
    VR$PrintVerHead( FileData = me->FileData, date = me->date ); 

  return OM_S_SUCCESS;

} /* end title_reports */



method end_reports( long * sts )
{

  /*A  print the error summary on the error report */
  VR$PrintErrorSummary( FileData = me->FileData, 
		       ErrorCnt =&me->ErrorCnt );
  return OM_S_SUCCESS;
} /* end end_reports */
  

method VRVerifyObjects ( long * sts )
{
  int		   status = OM_S_SUCCESS;

  IGRlong          retmsg;
  IGRint           index0;
  GRclassid        ClassId;
  IGRdouble        dOrigCoor[3];
  IGRint           TempError;
  IGRboolean       bValidated;
  struct GRmd_env  *md_env;
  
 /* printf("in verify\n");
  printf("located objid = %d\n", me->ObjToProcess[0].objid); */

  *sts = MSSUCC;
  
  /*A if no located objects, return */
  if( !me->ObjToProcess )
    {
      return OM_S_SUCCESS;
    }
  
  md_env = &me->md_env;
  
  /*A Verify objects based on classid */
  for (index0 = 0 ; ((index0 < me->NumToProcess) && (!me->bUserExit)) ; index0++)
    {
      me->bUserExit = IGEstop();
      UI_status("Processing...");
      /*A Set flag to indicate this object can be validated */
      bValidated = TRUE;

      /*A Store the current error count to be used in comparison */
      TempError = me->ErrorCnt;

      /*A  if the global verify command was used, we should have   */
      /*A  md_env for all objects since they could come from diff  */
      /*A  reference files                                         */
      if ( !me->bNetCommand )
	{
	  if ( !me->Fencemd_env )
	    return OM_S_SUCCESS;
	  md_env = &me->Fencemd_env[index0];
	}

      status = om$get_classid ( objid = me->ObjToProcess[index0].objid,
			        osnum = me->ObjToProcess[index0].osnum,
			        p_classid = &ClassId);
      as$status();


      /*A Validate components and constrained components */
      if ( (om$is_ancestry_valid ( subclassid = ClassId, 
				  superclassid = 
				 OPP_VRComponent_class_id) 
	    
	  == OM_S_SUCCESS ) ||
	    
	    (om$is_ancestry_valid ( subclassid = ClassId, 
				  superclassid = 
				 OPP_VRConcComp_class_id) 
	    
	  == OM_S_SUCCESS ))
	{

      /*A if objects were gotten by fence, set proper product & md_env */
      if( !me->bNetCommand )
	{
	  status = om$send(msg = message VRProduct.VRGetProduct
			   ((IGRshort *)&me->Product,NULL),
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	}
    
	  /*A Update verbose report */
	  if( me->bVerbose )
	    VR$PrintVerObj(FileData = me->FileData,
			   object = &me->ObjToProcess[index0],
			   Type = "Component",
			   Product = me->Product);

	  
	  if( me->bVerbose )
	    VR$PrintVerType(FileData = me->FileData,
			    Type = "Verify Toplogy");

	  
	  status = om$send( msg = message VRGeneric.VRVerifyTopology
			   (sts, md_env, me->NewObj, me->FileData, 
			    me->bVerbose, &me->ErrorCnt, dOrigCoor),
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status();
	  as$status(sts = *sts);


	  if( me->bVerbose )
	    VR$PrintVerType(FileData = me->FileData,
			    Type = "Verify Model");
	  
	  status = om$send( msg = message VRGeneric.VRVerifyModel
			   ( sts, md_env, me->FileData, 
			     me->bVerbose, &me->ErrorCnt, dOrigCoor),
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status();
	  as$status(sts = *sts);
	  
	  if( me->bVerbose )
	    VR$PrintVerType(FileData = me->FileData,
			    Type = "Verify Attributes");

	  status = om$send( msg = message VRGeneric.VRVerifyAttributes
			   ( &retmsg, md_env, me->FileData, 
			     me->bVerbose, &me->ErrorCnt, dOrigCoor ),
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status();
	  as$status(sts = *sts);

	  if( me->bVerbose )
	    VR$PrintVerType(FileData = me->FileData,
			    Type = "Verify Flow and Connectivity");

	  status = om$send( msg = message VRGeneric.VRVerifyFlow
			   ( &retmsg, md_env, me->FileData, 
			     me->bVerbose, &me->ErrorCnt, dOrigCoor ),
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status();
	  as$status(sts = *sts);
	  
	  status = om$send( msg = message VRGeneric.VRVerifyConnect
			   ( &retmsg, md_env, me->FileData, 
			     me->bVerbose, &me->ErrorCnt, dOrigCoor ),
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status();
	  as$status(sts = *sts);
	  
	  
	}
      /*A perform validations on corrections */
      else if ( om$is_ancestry_valid ( subclassid = ClassId, 
				      superclassid = 
				      OPP_VRCorrection_class_id ) 
	       == OM_S_SUCCESS )
	{
	  if( !me->bNetCommand )
	    {
	      status = om$send(msg = message VRProduct.VRGetProduct
			       ((IGRshort *)&me->Product,NULL),
			       targetid = me->ObjToProcess[index0].objid,
			       targetos = me->ObjToProcess[index0].osnum);
	    }
	  
	  if( me->bVerbose )
	    {
	      VR$PrintVerObj(FileData = me->FileData,
			     object = &me->ObjToProcess[index0],
			     Type = "Correction",
			     Product = me->Product);

	      VR$PrintVerType(FileData = me->FileData,
			      Type = "Verify Topology");
	    }
	  

	  status = om$send( msg = message VRCorrection.VRVerCorrTopology
			   ( &retmsg, md_env, me->FileData, 
			      me->bVerbose, &me->ErrorCnt), 
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status(action = RET_STATUS);
	  as$status(sts = *sts, action = RET_STATUS);
	}

      /*A perform validations on control segments */
      else if ( om$is_ancestry_valid (subclassid = ClassId, 
				      superclassid = 
				      OPP_VRCnrlSeg_class_id )
	       == OM_S_SUCCESS ) 
	{	
	  if( !me->bNetCommand )
	    {
	      status = om$send(msg = message VRCnrlSeg.VRGetSegProduct
			       ((IGRshort *)&me->Product),
			       targetid = me->ObjToProcess[index0].objid,
			       targetos = me->ObjToProcess[index0].osnum);
	    }
	  
	  if( me->bVerbose )
	    {
	      VR$PrintVerObj(FileData = me->FileData,
			     object = &me->ObjToProcess[index0],
			     Type = "Control Segment",
			     Product = me->Product);

	      VR$PrintVerType(FileData = me->FileData,
			      Type = "Verify Toplogy");
	    }
	  
	  status = om$send( msg = message VRCnrlSeg.VRVerCSTopology
			   ( &retmsg, me->NewObj, md_env, 
			    me->FileData, me->bVerbose, &me->ErrorCnt),
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status(action = RET_STATUS);
	  as$status(sts = *sts, action = RET_STATUS);
	}

      /*A perform validations on control segments */
      else if ( om$is_ancestry_valid (subclassid = ClassId, 
				      superclassid = 
				      OPP_VRplane_class_id )
	       == OM_S_SUCCESS ) 
	{		  
	  if( me->bVerbose )
	    {
	      VR$PrintVerObj(FileData = me->FileData,
			     object = &me->ObjToProcess[index0],
			     Type = "Plane",
			     Product = -1);

	      VR$PrintVerType(FileData = me->FileData,
			      Type = "Verify Toplogy");
	    }
	  
	  status = om$send( msg = message VRplane.VRVerPlaneTopology
			   ( &retmsg, me->FileData, 
			     me->bVerbose, &me->ErrorCnt), 
			   senderid = NULL_OBJID,
			   targetid = me->ObjToProcess[index0].objid,
			   targetos = me->ObjToProcess[index0].osnum);
	  as$status(action = RET_STATUS);
	  as$status(sts = *sts, action = RET_STATUS);
	}
      else
	if( me->bVerbose )
	  {
	    VR$PrintVerObj(FileData = me->FileData,
			   object = &me->ObjToProcess[index0],
			   Type = "No Verifications Implemented",
			   Product = -1);
	    bValidated = FALSE;
	  }
      

      /*A If the error count has not increased */
      /*A then print object validated */
      if ( (me->ErrorCnt == TempError) && bValidated )
	if( me->bVerbose )
	  VR$PrintNoError(FileData = me->FileData )
   }
  UI_status("");  /* clear the status field */
  return OM_S_SUCCESS;
} /* end VRVerifyObjects */

end implementation VRVerify;




