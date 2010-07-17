/* $Id: VRGenVerify.I,v 1.4 2002/04/10 19:41:15 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrgeneric / VRGenVerify.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRGenVerify.I,v $
 *	Revision 1.4  2002/04/10 19:41:15  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.3  2001/02/20 01:14:11  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 20:44:20  anand
 *	SP merge
 *	
# Revision 1.2  2000/06/07  17:36:12  pinnacle
# Replaced: route/vrgeneric/VRGenVerify.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/05/23  23:18:06  pinnacle
# Created: route/vrgeneric/VRGenVerify.I by lawaddel for Service Pack
#
# Revision 1.3  1999/11/02  13:50:26  pinnacle
# Replaced: vrgeneric/VRGenVerify.I for: TR 179900869 by svngidug for route
#
# Revision 1.2  1999/05/11  06:12:46  pinnacle
# Replaced: vrgeneric/VRGenVerify.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1996/09/20  05:06:50  pinnacle
# Replaced: vrgeneric/VRGenVerify.I for:  by ashankar for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/04/10  15:19:40  pinnacle
# Replaced: vrgeneric/VRGenVerify.I for:  by hverstee for route240
#
# Revision 1.4  1996/01/17  00:01:52  pinnacle
# Replaced: vrgeneric/VRGenVerify.I for:  by r240_int for route240
#
 *
 * History:
 *	11/21/94	Lori	Creation
 *	01/16/96	tlb	Add protoypes
 *	05/11/99	Alwin	Modified the method VRVerifyAttributes, for
 *				TR179900560
 *	11/02/99	Satish  Fix for TR17990869.	
 *    June 07 2k	Anand	Fix for TR179901547. Don't check for number of
 *				system & active attributes match for raceways.
 *      04/05/02        law     TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
class implementation VRGeneric;


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EXgrid.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "VRcompdef.h"
#include "VRparamdef.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "VRcompdef.h"
#include "AS_status.h"
#include "VRDbParamDef.h"
#include "nddef.h"
#include "VRMath.h"
#include "VRverify.h"
#include "VRverifymac.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "vrdbgmacros.h"

#include "vrtools_pto.h"

from VRProduct       import   VRGetSearch;
from ACrg_collect    import   AClist_attribute;
from ACmacro_defn    import   ACgive_name;
from VRProduct       import   VRGetSpecComp;
from ACheader        import   ACfind_model;

#define VRMAXCRIT   10  /* defined in VRinfo.I too */ 

extern GRclassid OPP_ACheader_class_id;
extern GRclassid OPP_ACconst_class_id;
extern GRclassid OPP_VRCnrlSeg_class_id;
extern GRclassid OPP_VRCorrection_class_id;
extern GRclassid OPP_ACrg_collect_class_id;




method VRVerifyChildren( IGRlong *msg; struct GRmd_env *md_env;
			struct VRvfy_objs *NewObj; 
			struct VRvfy_file *FileData;
			IGRboolean bVerbose; IGRint *ErrorCnt;
			IGRdouble *dOrigCoor; IGRint NbCnrlSeg)
{
  IGRlong           retmsg;
  IGRlong           status;
  IGRint            NbChildren, NbCorrection;
  IGRint            i, j;
  struct     GRid   *ChildrenBuffer, CorId[1], MyId;
  GRclassid         ChildClassId, CorClassId;
  IGRboolean        bFound;

  SetProc( VRGeneric_VRVerifyChildren ); Begin
  *msg = MSSUCC;
  i = 0;
  retmsg = 0;
  NbCorrection = 0;
  status = 0;
  while ( (i < me->nNbCpts) && !(retmsg & 1) )
    {  
      status = om$send( msg = message VRGeneric.VRGetCptGeom
		       ( &retmsg, i, dOrigCoor,NULL,NULL, md_env), 
		       targetid = my_id);
      i++;
    }

    /*   printf("x = %6.2f, y = %6.2f, z = %6.2f\n", dOrigCoor[0],
		 dOrigCoor[1], dOrigCoor[2]);  */

  if(  !(retmsg & 1)  || !( status & 1 ) ) 
    
    VR$PrintVerify(Test = ( !(retmsg & 1)  || !( status & 1 ) ) ,
		   ErrorBuf  = "Error obtaining component geometry",
		   Verbose   = bVerbose,
		   object    = my_id, 
		   OrigCoor  = dOrigCoor,
		   ErrorCnt  = ErrorCnt,
		   FileData  = FileData);
  

  /*A Get Children */
  status = om$send( msg = message NDnode.NDget_objects 
		   ( (ND_CHILDREN | ND_IN_BUF), NULL, 0,
		     &ChildrenBuffer, 0,OM_K_MAXINT, &NbChildren),
		   targetid = my_id);

  as$status();
  if (  !( status & 1 ) )
    VR$PrintVerify(Test = (  !( status & 1 ) ) ,
		   ErrorBuf  = "Error obtaining component children",
		   Verbose   = bVerbose,
		   object    = my_id, 
		   OrigCoor  = dOrigCoor,
		   ErrorCnt  = ErrorCnt,
		   FileData  = FileData);
  
  
  
  /*A  Test to see if we are collecting corrections, if we are, search    */
  /*A  through the list of corrections to see if we already have this one */
  /*A  if we do, go on, if not add it to the list */
  if (NewObj[CORR_OBJ_NUM].ArraySize > 0)
    {	
      if ((NewObj[CORR_OBJ_NUM].ArraySize) <= 
	  NewObj[CORR_OBJ_NUM].ObjCount + NbChildren )
	{
	  NewObj[CORR_OBJ_NUM].ArraySize = 
	    NewObj[CORR_OBJ_NUM].ArraySize + NbChildren + 50;
	  NewObj[CORR_OBJ_NUM].object = (struct GRid *) om$realloc
	    (ptr = (char *)NewObj[CORR_OBJ_NUM].object,
	     size = (NewObj[CORR_OBJ_NUM].ArraySize ) *
	     sizeof( struct GRid )  );
	}
      
      
      if ( !(NewObj[CORR_OBJ_NUM].object)  )
	{
	  *msg = MSFAIL;
          End
	  return OM_E_NODYNMEM;
	}
    }

  /*A Validate Child Classes */

  for ( i = 0; i < NbChildren; i++ )
    {
      status =  om$get_classid ( objid = ChildrenBuffer[i].objid,
				osnum = ChildrenBuffer[i].osnum,
				p_classid = &ChildClassId);
	
      as$status();
     
      /*A Count number of Corrections */
      
    if ( om$is_ancestry_valid ( subclassid = ChildClassId,
			        superclassid = OPP_VRCorrection_class_id)
	  == OM_S_SUCCESS )
	{
	  
	  NbCorrection += 1;

	  /*A  If we are storing correction objects the array size will be */
          /*A  greater than zero                                           */
	  if (NewObj[CORR_OBJ_NUM].ArraySize > 0)
	    {
	      bFound = FALSE;
	      
	      /*A   Search for the correction in the current array    */
              /*A   If found exit loop and don't store again in array */
              /*A   If not found, add to array                        */
	      for (j = 0; j < NewObj[CORR_OBJ_NUM].ObjCount; j++)
		{
		  if( (NewObj[CORR_OBJ_NUM].object[j].objid) == 
		     ChildrenBuffer[i].objid && 
		     (NewObj[CORR_OBJ_NUM].object[j].osnum == 
		      ChildrenBuffer[i].osnum ))
		    {
		      bFound = TRUE;
		      break;
		    }
		}
	      if ( !bFound ) 
		{
		  
		  NewObj[CORR_OBJ_NUM].object[NewObj[CORR_OBJ_NUM].ObjCount].objid = 
		    ChildrenBuffer[i].objid;
		  NewObj[CORR_OBJ_NUM].object[NewObj[CORR_OBJ_NUM].ObjCount].osnum = 
		    ChildrenBuffer[i].osnum;
		  NewObj[CORR_OBJ_NUM].ObjCount += 1;
		}
	    }
	}
    }
  
  /*A Is the component a correction component? */
  if ( me->Status & VR_CORRECTION ) 
    {
      /*A Get Owner of Correction Component */
      MyId.objid = my_id;
      MyId.osnum = OM_Gw_current_OS;
      status = ASget_as_owner( &MyId, CorId );
      as$status();
      
      /*A Correction component should have owner */
	VR$PrintVerify(Test = ((CorId[0].objid == NULL_OBJID) 
			       || !(status & 1)),
		       ErrorBuf  = "Error obtaining owner for correction component",
		       Verbose   = bVerbose,
		       object    = my_id, 
		       OrigCoor  = dOrigCoor,
		       ErrorCnt  = ErrorCnt,
		       FileData  = FileData);

      status = om$get_classid ( objid = CorId[0].objid,
			        osnum = CorId[0].osnum,
			        p_classid = &CorClassId);
      as$status();


      /*A Correction component owner should be a Correction */
	VR$PrintVerify(Test = (om$is_ancestry_valid 
			       ( subclassid = CorClassId,
				 superclassid = OPP_VRCorrection_class_id) 
			       != OM_S_SUCCESS),
		       ErrorBuf  = "Invalid owner for correction component",
		       OKBuf     = "Valid owner for correction component",
		       Verbose   = bVerbose,
		       object    = my_id,
		       OrigCoor  = dOrigCoor, 
		       ErrorCnt  = ErrorCnt,
		       FileData  = FileData);


     } 
  else
    {

      /*A Non Correction component should have equal number */
      /*A of Corrections and Control Segments               */

	VR$PrintVerify(Test      =  (NbCnrlSeg != NbCorrection), 
		       ErrorBuf  = "Number of Corrections not equal to Number of Control Segments",
		       OKBuf     = "Number of Corrections equal Number of Control Segments",
		       Verbose   = bVerbose,
		       object    = my_id, 
		       OrigCoor  = dOrigCoor,
		       ErrorCnt  = ErrorCnt,
		       FileData  = FileData);


    }
  End
  return OM_S_SUCCESS;
} /* end VRVerifyChildren */


method VRVerifyModel( IGRlong *msg; struct GRmd_env *md_env; 
		     struct VRvfy_file *FileData;
		     IGRboolean bVerbose; IGRint *ErrorCnt; 
		     IGRdouble *dOrigCoor )
{
  IGRlong                   status, retmsg;
  IGRchar                   szAABBCC[VR_CODE_LENGTH];
  struct      GRid          CacheId;
  IGRchar                   szSearch[VR_SEARCH_LENGTH];
  IGRchar                   szPathName[100], ErrBuf[150], OKBuf[150];
  struct      VRSelectAttr  ParamList[VRMAXCRIT];

  struct      GRid          Header, ModelId, MacDefId;
  IGRdouble                 dMat[16];
  IGRshort                  nType;
  IGRchar                   *model_macro_name, cache_macro_name[80]; 
  IGRint                    NbParams;
  struct      ret_struct    OldAttrRst;
  IGRint                    FootIndex = -1;
  IGRboolean                bMacNameFound, bCatOccFound;
  GRclassid                 ClassId;
  IGRint                    EndLoop = 0;
  IGRboolean                bTest;

  SetProc( VRGeneric_VRVerifyModel ); Begin
  *msg = MSSUCC;

  bMacNameFound = FALSE;
  bCatOccFound = FALSE;
  /*A Verify the Static Cache */
	
  /*A Get AABBCC code */
  strcpy(szAABBCC, me->szAABBCC);
  NbParams = 0;  
  CacheId.objid = NULL_OBJID;

  /*A until a stopsign stop, or an error, or a 
     macroname  or a catalog occurrence is found     */

  while ( EndLoop == 0 )
    {
      EndLoop = IGEstop();

      /*A built in components have hardcoded cache */
      if ( me->Status & VR_BUILT_IN )
	{
	  /*A AABBCC taken as search string */
	  sprintf ( szSearch,"%s:%s", VR_MISC_DIR, szAABBCC );
	}
      else
	{
	  /*A -- build search string -- */
	  
	  status = 
	    om$send ( msg = message VRProduct.VRGetSearch
		     ( &retmsg, &CacheId, 0, &NbParams, 
		      ParamList, szSearch, md_env ),
		     targetid = my_id);
	  if ( !(retmsg & 1) || !( status & 1 ) )
	    {
	      /*A something went wrong */
	      VR$PrintVerify(Test =  ( !(retmsg & 1) || !( status & 1 )),
			     ErrorBuf  = "Error obtaining search string",
			     Verbose   = bVerbose,
			     object    = my_id, 
			     OrigCoor  = dOrigCoor,
			     ErrorCnt  = ErrorCnt,
			     FileData  = FileData);
	      End
	      return OM_S_SUCCESS;
	    } 
	}

      /*A -- look for the cache in the directory -- */
      
      /*A Get the pathname */
      
      di$give_pathname ( osnum = OM_Gw_current_OS, pathname = szPathName );
      
      strcat ( szPathName, ":" );
      strcat ( szPathName, szSearch );
      
      if( ! bVR_IS_PID( me->xform_chan) )
      {
         sprintf(ErrBuf,"Cache: %s not found in directory", szPathName);
         sprintf(OKBuf,"Cache: %s found in directory", szPathName);
      
         bTest = ! ( di$translate ( objname = szPathName,
			     p_objid = &CacheId.objid,
			     p_osnum = &CacheId.osnum )& 1 );

         VR$PrintVerify(Test      = bTest,
		     ErrorBuf  = ErrBuf,
		     OKBuf     = OKBuf,
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      }
      else
      {
        End
	return OM_S_SUCCESS;
      }
  
      if ( bTest )
      {
        End
	return OM_S_SUCCESS; /*A no cache, can't continue */
      }
      

        /*A check for a macro name */
      status = om$send ( msg = message ACncpx.ACgive_structure
			( (IGRint *) &retmsg, &FootIndex, VR_N_MACRO_NAME_AN,
			 &OldAttrRst, md_env ),
			targetid = CacheId.objid,
			targetos = CacheId.osnum);
      
      /*A something went wrong */
      if (  !( status & 1 ) )
	{
	  VR$PrintVerify(Test = ( !(retmsg & 1)  || !( status & 1 ) ) ,
			 ErrorBuf  = "Error obtaining macro name from cache",
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
          End
	  return OM_S_SUCCESS;
	}
      
      /*A  macro name found */
      if ( (retmsg & 1) )
	{
	  strcpy(cache_macro_name, OldAttrRst.var.text_st.text_string); 
	  bMacNameFound = TRUE;
	  break;
	}
      else
	{
	  /*A check for catalog occurrence */
	  status = om$send ( msg = message ACncpx.ACgive_structure
			    ( (IGRint *)&retmsg, &FootIndex, 
			     VR_N_CATAL_OCC_AN,&OldAttrRst, md_env ),
			    targetid = CacheId.objid,
			    targetos = CacheId.osnum);
	  
	  /*A Catalog occurrence found */
	  if ( retmsg & 1)
	    {
	      bCatOccFound = TRUE;
	      break;
	    }
	  else 
	    { 
	      /*A Check for a catalog name */
	      
	      status =  om$send ( msg = message ACncpx.ACgive_structure
				 ( (IGRint *)&retmsg, &FootIndex, 
				  VR_N_CATAL_NAME_AN, &OldAttrRst, md_env ),
				 targetid = CacheId.objid,
				 targetos = CacheId.osnum);
	      
	      /*A Can't continue without a catalog name */
	      if (!(retmsg &1))
		{
		  VR$PrintVerify(Test = ( !(retmsg & 1) ) ,
				 ErrorBuf  = "Error obtaining catalog name from cache",
				 Verbose   = bVerbose,
				 object    = my_id, 
				 OrigCoor  = dOrigCoor,
				 ErrorCnt  = ErrorCnt,
				 FileData  = FileData);
		  
                  End
		  return OM_S_SUCCESS;
		} 	     
	    }
	}   
    }
  
/*A model validation */
  if( bMacNameFound )  
    {
      /*A Model validation */
      status =    om$send( msg = message ACncpx.ACreturn_foot
			  ( &retmsg, "graphics", &Header, &nType, 
			   dMat ),
			  targetid = my_id);
      as$status();
     
      /*A something went wrong, exit */
      if(!(retmsg & 1)  || !( status & 1 ) || 
	 Header.objid == NULL_OBJID)
	
	{
	  VR$PrintVerify(Test = ( !(retmsg & 1)  || !( status & 1 ) ) ,
			 ErrorBuf  = "Error obtaining graphics header from object",
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
	  
	  
	  VR$PrintVerify(Test = (Header.objid == NULL_OBJID),
			 ErrorBuf  = "No Graphics Header Object",
			 OKBuf     = NULL,
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
          End
	  return OM_S_SUCCESS;
	}
      
      status = om$get_classid(objid = Header.objid,
			      osnum = Header.osnum,
			      p_classid = &ClassId);
      as$status();
      
      /*A A valid model/header object is of class ACheader or           */
      /*A of possibly class ACconst if correction component (PIPE/DUCT) */

      VR$PrintVerify(Test = !(  (om$is_ancestry_valid( subclassid = ClassId,
				superclassid = OPP_ACheader_class_id)
			       == OM_S_SUCCESS) ||
			       ((om$is_ancestry_valid
				 ( subclassid = ClassId,
				  superclassid = OPP_ACconst_class_id)
				 == OM_S_SUCCESS) && 
				me->Status & VR_CORRECTION)),
		     ErrObj    = &Header,
		     ErrorBuf  = "Graphics model/header object invalid",
		     OKBuf     = "Graphics model/header object valid",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
    
      if (om$is_ancestry_valid( subclassid = ClassId,
			       superclassid = OPP_ACconst_class_id)
	  == OM_S_SUCCESS)
	{
	  ModelId.objid = Header.objid;
	  ModelId.osnum = Header.osnum;
	}
      else
	{
	  status =    om$send( msg = message ACheader.ACfind_model
			      ( &retmsg, &ModelId),
			      targetid = Header.objid,
			      targetos = Header.osnum);
	  
	  as$status();
	  if ( !(retmsg & 1)  || !( status & 1 )  || ModelId.objid == NULL_OBJID)
	    {
	      VR$PrintVerify(Test = ( !(retmsg & 1)  || !( status & 1 ) ) ,
			     ErrorBuf  = "Error obtaining model object",
			     Verbose   = bVerbose,
			     object    = my_id, 
			     OrigCoor  = dOrigCoor,
			     ErrorCnt  = ErrorCnt,
			     FileData  = FileData);
	      
	      VR$PrintVerify(Test = ( ModelId.objid == NULL_OBJID ) ,
			     ErrorBuf  = "Error no model object",
			     Verbose   = bVerbose,
			     object    = my_id, 
			     OrigCoor  = dOrigCoor,
			     ErrorCnt  = ErrorCnt,
			     FileData  = FileData);
	      
              End
	      return OM_S_SUCCESS;
	    }
	}
      
      /*A Get the macro definition from the model */
      status =    om$send( msg = message ACcpx.find_macro
			  ( &MacDefId ),
			  targetid = ModelId.objid,
			  targetos = ModelId.osnum);
      /*A error check */
      if(!( status & 1 ) || MacDefId.objid == NULL_OBJID)
	{
	  
	  VR$PrintVerify(Test = ( !( status & 1 ) ),
			 ErrorBuf  = "Error obtaining Macro Definition",
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
	  
	  VR$PrintVerify(Test = ( MacDefId.objid == NULL_OBJID ),
			 ErrorBuf  = "No Macro Definition object",
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
          End
	  return OM_S_SUCCESS;
	}
      /*A get macro name from definition */
      status =    om$send( msg = message ACmacro_defn.ACgive_name
			  ( &model_macro_name ),
			  targetid = MacDefId.objid,
			  targetos = MacDefId.osnum);
      /*A error check */
      if( !(status & 1) )
	{  
	  VR$PrintVerify(Test = ( !( status & 1 ) ) ,
			 ErrorBuf  = "Error obtaining macro name from macro definition",
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
          End
	  return OM_S_SUCCESS;
	}
      

      if( !bVR_IS_PID( me->xform_chan) )
      {
         /*A set up report messages */
         sprintf(ErrBuf,
	      "Macro name not consistent between model (%s) and cache (%s)",
	      model_macro_name, cache_macro_name);
         sprintf(OKBuf,
	      "Macro name consistent between model (%s) and cache (%s)", 
	      model_macro_name,
	      OldAttrRst.var.text_st.text_string);
      
         VR$PrintVerify(Test = (strcmp( model_macro_name, cache_macro_name) ),
		     ErrorBuf  = ErrBuf,
		     OKBuf     = OKBuf,
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      }

      
      
    } /*A end verify macro name */

  End
  return OM_S_SUCCESS;
} /* end VRVerifyModel */

method VRVerifyAttributes( IGRlong *msg; struct GRmd_env *md_env; 
		     struct VRvfy_file *FileData;
		     IGRboolean bVerbose; IGRint *ErrorCnt; 
		     IGRdouble *dOrigCoor )
{  

  IGRlong                   status, retmsg;
  IGRshort                  Product;
  struct      GRid          MyId, ActSysId, SysParamId;
  struct      GRid          UserParamId, MissParamId;
  struct      ACrg_coll     ActListAttr[VR_MAX_ATTR], SysListAttr[VR_MAX_ATTR];
  IGRint                    NbActAttr, NbSysAttr;
  IGRboolean                bAttFound;
  IGRchar                   ErrBuf[150];
  IGRint                    i,j;

  SetProc( VRGeneric_VRVerifyAttributes ); Begin 

  /*A System Attributes Validation */
	
  MyId.objid = my_id;
  MyId.osnum = OM_Gw_current_OS;

  /*A get the current product */
  VRGetCmpClass ( &MyId, &Product );
  
  ActSysId.objid = NULL_OBJID;
  ActSysId.osnum = md_env->md_id.osnum;

  /*A Get the active system collection */
  VR$active_params( operation      = VR_RETRIEVE,
		    mode           = VR_SYSTEM_MODE,
		    update_flag    = VR_NOUPDATE,
		    VRproduct      = Product,
		    act_param_id   = &ActSysId,
		    status         = status          );

  __DBGpr_obj( " Active Parameter Collector Id ", ActSysId );

  /*A error check */
  if ( !( status & 1 ) )
  {
      VR$PrintVerify(Test = ( !( status & 1 ) ) ,
		     ErrorBuf  = "Error obtaining active collection object",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      End
      return OM_E_ERROR;
  }
  
  /*A Get the system collection of the object being verified */
  status = om$send ( msg = message VRGeneric.VRGetParams ( &retmsg,
							   &SysParamId,
							   &UserParamId,
							   &MissParamId ),
		targetid = my_id);
  __DBGpr_obj( " System Parameter Collector Id ", SysParamId );

  /*A error check */
  if (!(retmsg&1) || !( status & 1 )  || SysParamId.objid == NULL_OBJID )
  {
      VR$PrintVerify(Test = ( !(retmsg&1) || !( status & 1 ) ) ,
		     ErrorBuf  = "Error obtaining component collection object",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);

      VR$PrintVerify(Test = ( SysParamId.objid == NULL_OBJID ) ,
		     ErrorBuf  = "No system parameter collection object",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      End
      return OM_E_ERROR;
  }

  /* Below if condition - added by Anand as a fix for TR 179901547. The TR
   * description said that 'bogus errors' were being thrown up for raceways.
   * When pointed out that the discrepancy in number of attributes between
   * active and system collection pertained to tier-related attributes of
   * additional cpts, Rod (with Tom and Ed) advised that the check be removed.
   */
  if( Product == VR_CABLING )
  {
      __DBGpr_com(" Don't make further checks for Raceways.");
      End
      return OM_S_SUCCESS;
  }

  /*A Get the attributes from the active collection */
  status = om$send( msg     = message ACrg_collect.AClist_attribute
		   ( &retmsg, VR_MAX_ATTR, ActListAttr, &NbActAttr ),
		   senderid = NULL_OBJID,
		   targetid = ActSysId.objid,
		   targetos = ActSysId.osnum );
  __DBGpr_int(" Nb active collection attributes",NbActAttr);

  /*A error Check */
  if (!(retmsg&1) || !( status & 1 ))
  {
      VR$PrintVerify(Test = ( !(retmsg&1) || !( status & 1 ) ) ,
		     ErrorBuf  = "Error obtaining active collection attributes",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      End
      return OM_E_ERROR;
  }

  /*A List the attributes from the object's collection */
  status = om$send( msg     = message ACrg_collect.AClist_attribute
		   ( &retmsg, VR_MAX_ATTR, SysListAttr, &NbSysAttr ),
		   senderid = NULL_OBJID,
		   targetid = SysParamId.objid,
		   targetos = SysParamId.osnum );
  __DBGpr_int(" Nb component collection attributes",NbSysAttr);

  /*A Error Check */
  if (!(retmsg&1) || !( status & 1 ))
  {
      VR$PrintVerify(Test      = ( !(retmsg & 1) || !( status & 1 ) ) ,
		     ErrorBuf  = "Error obtaining component collection attributes",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      End
      return OM_E_ERROR;
  }

  /* Below lines for debugging purposes, added by Anand */
#ifdef vdsDEBUG
  if( NbActAttr != NbSysAttr )
  {
      IGRboolean bSys[VR_MAX_ATTR]={FALSE}, bAct[VR_MAX_ATTR]={FALSE};

      for( i=0 ; i<NbActAttr ; i++ )
        for( j=0 ; j<NbSysAttr ; j++ )
        {
	    if( bSys[j] )
		continue;

            if( !strcmp(ActListAttr[i].name,SysListAttr[j].name) )
            {
                bSys[j] = bAct[i] = TRUE;
                break;
            }
        }

      for( i=0 ; i<NbActAttr ; i++ )
        if( ! bAct[i] )
            printf(" ********** ACTIVE PARAM %s NOT FOUND IN SYSTEM PARAM ********\n",ActListAttr[i].name );

      for( j=0 ; j<NbSysAttr ; j++ )
        if( ! bSys[j] )
            printf(" ********** SYSTEM PARAM %s NOT FOUND IN ACTIVE PARAM ********\n",SysListAttr[j].name );

  }
#endif


  /*A Validate number of the system collection attributes of the object */

  VR$PrintVerify(Test      = (NbActAttr != NbSysAttr),
		 ErrorBuf  = "Number of System Collection attributes not equal to that of active System Collection",
		 OKBuf     = "Valid number of System Collection attributes",
		 Verbose   = bVerbose,
		 object    = my_id, 
		 OrigCoor  = dOrigCoor,
		 ErrorCnt  = ErrorCnt,
		 FileData  = FileData);
  
  /*A Validate system collection attribute names */
  /* The indices were wrongly used and as a result some of the attributes like 
  "max_depth" though they're present in the collector; the system couldn't 
  recognise them. Modified by Alwin for TR179900560 
  for ( i = 0; i < NbActAttr; i++ )
  ***/
  for ( i = 0; i < NbSysAttr; i++ )
  {
      bAttFound = FALSE;
      /* Commented this for TR179900560   
      for ( j = 0; j < NbSysAttr; j++ )
      ***/
      for ( j = 0; j < NbActAttr; j++ )
      {
	  if ( !strcmp(ActListAttr[j].name, SysListAttr[i].name ))
	  {
	      bAttFound = TRUE;
	      break; // Added by Anand
	  }
      }

      sprintf( ErrBuf, "Attribute %s not in component collection",
							  SysListAttr[i].name);

      VR$PrintVerify(Test      = !bAttFound,
		     ErrorBuf  = ErrBuf,
		     OKBuf     = NULL,
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
  }
    
  End
  return OM_S_SUCCESS;  
}    /* end VRVerifyAttributes */

method VRVerifyFlow( IGRlong *msg; struct GRmd_env *md_env; 
		    struct VRvfy_file *FileData;
		    IGRboolean bVerbose; IGRint *ErrorCnt;
		    IGRdouble *dOrigCoor )
{

  IGRlong       status, retmsg;
  IGRshort      i, FlowDir;
  IGRdouble     FlowRate, OutFlowRate, InFlowRate, MaxFlowRate;
  IGRint        NbInFlow, NbOutFlow;
  IGRchar       ErrBuf[150], OKBuf[150];
 
  SetProc( VRGeneric_VRVerifyFlow ); Begin
  NbInFlow    = 0;
  NbOutFlow   = 0;
  OutFlowRate = 0;
  InFlowRate  = 0;
  
  *msg = MSSUCC;

  /*A Get the flow information at each of the connect point */
  for ( i = 0; i < me->nNbCpts; i++ )
    {
      status = om$send( msg = message VRGeneric.VRGetFlow
		       (&retmsg, i, &FlowDir, &FlowRate, md_env),
		       targetid = my_id);

      /*A Error check */
      if ( !(retmsg & 1) || !( status & 1 ) )
	{
	  VR$PrintVerify(Test = ( !(retmsg & 1) || !( status & 1 ) ) ,
			 ErrorBuf  = "Error obtaining component flow information",
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);
          End
	  return OM_S_SUCCESS;
	}
      
      switch( FlowDir ) 
	{
	case VR_FLOW_IN:             /*A update in flow info */
	  {
	    NbInFlow += 1;
	    InFlowRate += FlowRate;
	    break;
	  }
	case VR_FLOW_OUT:            /*A update out flow info */
	  {
	    NbOutFlow += 1;
	    OutFlowRate += FlowRate;
	    break;
	  }

	}
    }
  

  if ( me->nNbCpts > 1 )
  {
      /*A Component should have at least 1 IN flow connect point */
      
      
      VR$PrintVerify(Test = ((NbInFlow == 0)),
		     ErrorBuf  = "Component has no IN flow connect points",
		     OKBuf     = "Component has IN flow connect point",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
      
      /*A Component should have at least 1 OUT flow connect point */
      
      VR$PrintVerify(Test = ((NbOutFlow == 0) && (me->nNbCpts >1)),
		     ErrorBuf  = "Component has no OUT flow connect points",
		     OKBuf     = "Component has OUT flow connect point",
		     Verbose   = bVerbose,
		     object    = my_id, 
		     OrigCoor  = dOrigCoor,
		     ErrorCnt  = ErrorCnt,
		     FileData  = FileData);
 
    /*A InFlowRate should equal OutFlowRate */

    sprintf(ErrBuf,"In flow rate (%6.2f) not equal Out flow rate (%6.2f)",
  	       InFlowRate, OutFlowRate);
    sprintf(OKBuf,"In flow rate (%6.2f) equal Out flow rate (%6.2f)",
	       InFlowRate, OutFlowRate);
  
    MaxFlowRate = (InFlowRate > OutFlowRate) ? InFlowRate : OutFlowRate;
    MaxFlowRate = (MaxFlowRate > 0) ? MaxFlowRate : 1;
    /***********************************************************************
    *  The following PrintVerify macro has been modified to use 'fabs' 
    *  instead of 'abs' to handle the 'double' arithmetic. Also the tolerance
    *  is changed to 1e-3 from 1e-2.
    *      - For TR179900869.  Satish 
    VR$PrintVerify(Test =  (abs((InFlowRate-OutFlowRate)/MaxFlowRate) > 1e-2 ),
    ***********************************************************************/
    VR$PrintVerify(Test =  (fabs(InFlowRate-OutFlowRate)/MaxFlowRate > VRGetTol(VR_DEFAULT_TOL)),
		   ErrorBuf  = ErrBuf,
		   OKBuf     = OKBuf,
		   Verbose   = bVerbose,
		   object    = my_id, 
		   OrigCoor  = dOrigCoor,
		   ErrorCnt  = ErrorCnt,
		   FileData  = FileData);
  }
  else
    VR$PrintVerify(Test = FALSE,
                     ErrorBuf  = "",
                     OKBuf     = "Component has only 1 connect point",
                     Verbose   = bVerbose,
                     object    = my_id,
                     OrigCoor  = dOrigCoor,
                     ErrorCnt  = ErrorCnt,
                     FileData  = FileData);

  End
  return OM_S_SUCCESS;
} /* end VRVerifyFlow */

method VRVerifyConnect( IGRlong *msg; struct GRmd_env *md_env; 
		       struct VRvfy_file *FileData;
			   IGRboolean bVerbose; IGRint *ErrorCnt;
		       IGRdouble *dOrigCoor )
{
  
  IGRlong          status, retmsg;
  IGRint           i;
  IGRint           NbNeigh, NbCptNeigh;
  struct   GRid    NeighId, CptNeighId;
  IGRshort         NeighCpNum, CptNeighCpNum;
  
  SetProc( VRGeneric_VRVerifyConnect ); Begin
  *msg = MSSUCC;

  /*A Validate neighbors at each connect point */
  for (i = 0; i < me->nNbCpts; i++ )
    {
      /*A Get the neighbors */
      status = om$send( msg = message VRGeneric.VRGetNeighbors
		       (&retmsg, i, i, &NbNeigh, &NeighId, &NeighCpNum, md_env),
		       targetid = my_id);
      /*A Error Check */
      if  ( !(retmsg & 1) || !( status & 1 ) )
	{
	  
	  VR$PrintVerify(Test = ( !(retmsg & 1) || !( status & 1 ) ) ,
			 ErrorBuf  = "Error obtaining component neighbors",
			 Verbose   = bVerbose,
			 object    = my_id, 
			 OrigCoor  = dOrigCoor,
			 ErrorCnt  = ErrorCnt,
			 FileData  = FileData);

	}
      else
	{
	  /*A If object is connected at that connect point validate it */
	  if ( NeighId.objid != NULL_OBJID )
	    {
	      /*A Get the neighbor at the identified connect point */
	      status = om$send( msg = message VRGeneric.VRGetNeighbors
			       (&retmsg, NeighCpNum, NeighCpNum, &NbCptNeigh, &CptNeighId,
				&CptNeighCpNum, md_env),
			       targetid = NeighId.objid,
			       targetos = NeighId.osnum);

	      /*A Error Check */
	      if  ( !(retmsg & 1) || !( status & 1 ) )
		{
		  VR$PrintVerify(Test = ( !(retmsg & 1) || !( status & 1 ) ) ,
				 ErrorBuf  = "Error obtaining component neighbor",
				 Verbose   = bVerbose,
				 object    = my_id, 
				 OrigCoor  = dOrigCoor,
				 ErrorCnt  = ErrorCnt,
				 FileData  = FileData);
		}
	      
	      /*A The neighbor should be this object at the ith connect point */
	      else
		{
		  VR$PrintVerify(Test =  ( (CptNeighCpNum != i) || 
					  (CptNeighId.objid != my_id) ),
				 ErrObj    = &NeighId,
				 ErrorBuf  = "Connectivity violation with this object",
				 OKBuf     = "Connectivity valid with this object",
				 Verbose   = bVerbose,
				 object    = my_id, 
				 OrigCoor  = dOrigCoor,
				 ErrorCnt  = ErrorCnt,
				 FileData  = FileData);
		}
	    }
	}
    }
  End
  return OM_S_SUCCESS;
} /* end VRVerifyConnect */

end implementation VRGeneric;

