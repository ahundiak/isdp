/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/write.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: write.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/12  23:17:34  pinnacle
 * Loading RT functions
 *
 *
 * History:
 *	01/12/98	Onay	Integration date.
 *
 *************************************************************************/

#include <alloca.h>
#include <stdio.h>
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "GMlist.h"
#include "GMdef.h"
#include "GMerrordef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "GMhcode.h"
#include "vrdef.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "vrmacros.h"
#include "VRsize.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "GMndg.h"
#include "GMerrordef.h"
#include "rtiges.h"
#include "AS_status.h"
#include "msdef.h"
#include "VRDbStruct.h"
#include "VRmacros.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "acrepdef.h"
#include "VRclsymb.h"
#include "msdef.h"
#include "msmacros.h"
#include "VRcompdef.h"
#include "dp.h"
#include "grmacros.h"
#include "VRsketchdef.h"
#include "VRcordef.h"
#include "VRpriv_attr.h"
#include "godef.h"
#include "PDUerror.h"

/* Globals */
static struct GRid RTSysParam;
static struct GRid RTUsrParam;
struct GRmd_env Active_env;     /* Module Environment */

extern int RtChangeProp();
extern int RtGetSegment();
extern int RtSharePlanes();

int RT_init_write( batch_mode, route_file, seed_file, unit_flag, db_name,
		  db_username, db_passwd )
IGRboolean batch_mode;
IGRchar *route_file;
IGRchar *seed_file;
IGRint unit_flag;
IGRchar *db_name;
IGRchar *db_username;
IGRchar *db_passwd;
{
  int status = OM_S_SUCCESS;
  IGRlong msg;
  int size, nb_byte;

  if( VDSverify_login() != PDM_S_SUCCESS )
  {
    printf( "No connection to database\n" );
    return RTERR_DB_LOGIN;
  }

  /* initialize the product	*/
  status = VRinit_products();

  /* get active module environment */
  size = sizeof( Active_env );
  status =
  gr$get_module_env
  (
         msg = &msg,
         sizbuf = &size,
         buffer = &Active_env,
         nret = &nb_byte
  );
  gm$status();

  RTSysParam.osnum = Active_env.md_id.osnum;

  status = VR$active_params(    operation       = VR_RETRIEVE,
                                mode            = VR_SYSTEM_MODE,
                                VRproduct       = VR_PIPING,
                                act_param_id    = &RTSysParam,
                                status          = status );    /* l value */

  as$status( action = RET_STATUS );


  RTUsrParam.osnum = Active_env.md_id.osnum;

  status = VR$active_params(    operation       = VR_RETRIEVE,
                                mode            = VR_USER_MODE,
                                VRproduct       = VR_PIPING,
                                act_param_id    = &RTUsrParam,
                                status          = status );    /* l value */

  as$status( action = RET_STATUS );

 exception:

  return RTSUCC;
}

int RT_exit_write()
{
  return RTSUCC;
}

IGRint RTconvert( IgrMatrix, tmatrix )
IGRdouble *IgrMatrix;
t_matrix  *tmatrix;
{
  IGRint ii;

  if( tmatrix == NULL || IgrMatrix == NULL )
   return RTERR;

  for( ii=0; ii < 3; ++ii )
  {
    IgrMatrix[ ii*4 ]     = tmatrix->x[ii];
    IgrMatrix[ ii*4 + 1 ] = tmatrix->y[ii];
    IgrMatrix[ ii*4 + 2 ] = tmatrix->z[ii];
    IgrMatrix[ ii*4 + 3 ] = tmatrix->translate[ii];
  }

  return RTSUCC;
}

/* This logic can handle fitting to fitting type of networks. */

int RTput_piping_entity2( PART_SPEC, sys_name, pipeline_id, part_type,
			 data_block_ptr, iinfo, inlet_cpt, outlet_cpt,
			 EndOfRun, route_id )
p_spec *PART_SPEC;
char *sys_name;
char *pipeline_id;
int part_type;
void *data_block_ptr;
insul_info *iinfo;
write_cpt_struct *inlet_cpt;
write_cpt_struct *outlet_cpt;
struct GRid *route_id;
IGRint EndOfRun;
{
 int    status = OM_S_SUCCESS;
 IGRint retType, retNbCpts;
 struct GRid RouteId;
 struct GRid CorId;
 static struct GRid PreCompId;
 static IGRshort PreCptNum;
 static struct GRid PreSegId;
 static IGRshort bFirst = TRUE;
 struct GRid SegmentId;
 IGRshort FreeCpt = -1;
 p_spec tmp_spec;
 component_info tmp_info;

 route_id->objid = NULL_OBJID;
 route_id->osnum = 0;

 RouteId.objid = NULL_OBJID;
 RouteId.osnum = 0;

 if( bFirst )
 {
#ifdef DEBUG
   printf( "first time\n" );
#endif
   PreCompId.objid = NULL_OBJID;
   PreSegId.objid  = NULL_OBJID;
   SegmentId.objid = NULL_OBJID;
   bFirst = FALSE;
 }

 if( inlet_cpt->route_id.objid != NULL_OBJID )
 {
#ifdef DEBUG
   printf( "inlet cpt is not NULL\n" );
#endif
   /* strictly speaking we need a sgment id along with inlet_cpt.
      VRGeneric.VRGetSupports */

   PreCompId = inlet_cpt->route_id;
   PreCptNum = inlet_cpt->port_num;
 }

 if( part_type == PART_TYPE_LINEAR_PIPE_SECTION &&
     inlet_cpt->route_id.objid == NULL_OBJID &&
     PreCompId.objid == NULL_OBJID )
 {
   tmp_spec = *PART_SPEC;
   strcpy( tmp_spec.comp_code, "dangle" );
   tmp_info.n_ports = 1;

   tmp_info.transform.translate[0]
	 = ((linear_pipe_info *)data_block_ptr)->start_coord[0];
   tmp_info.transform.translate[1]
	 = ((linear_pipe_info *)data_block_ptr)->start_coord[1];
   tmp_info.transform.translate[2]
	 = ((linear_pipe_info *)data_block_ptr)->start_coord[2];

   status = RTorient_dangle(
	 ((linear_pipe_info *)data_block_ptr)->start_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[2],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[2],
	 &(tmp_info.transform) );

   if( status != RTSUCC )
    return RTERR;

   status = RTput_component( &tmp_spec, sys_name, pipeline_id,
			     PART_TYPE_COMPONENT, &tmp_info,
			     iinfo, TRUE, &RouteId, &retType,
			     &retNbCpts );
 }

 if( part_type == PART_TYPE_COMPONENT ||
     part_type == PART_TYPE_BENT_PIPE_SECTION )
 {
#ifdef DEBUG
    printf( "placing component\n" );
#endif
    status = RTput_component( PART_SPEC, sys_name, pipeline_id, part_type,
		     	      data_block_ptr, iinfo, TRUE, &RouteId,
			      &retType, &retNbCpts );

    *route_id = RouteId;

    
    if( PreCompId.objid != NULL_OBJID )
    {
       status = RTget_free_cpt( &RouteId, &FreeCpt );
#ifdef DEBUG
       printf( "id:%d  cpt:%d\n", RouteId.objid, FreeCpt );
#endif

#ifdef DEBUG
       printf( "PreCompId:%d PreCptNum:%d  RouteId:%d FreeCpt:%d\n",
		PreCompId.objid, PreCptNum, RouteId.objid, FreeCpt );
#endif

       status =
       VRConnectComponents( &PreCompId, PreCptNum, &RouteId,
		            FreeCpt,
			    &PreSegId, &SegmentId, &Active_env,
			    &CorId );
       as$status( action = RET_STATUS );
    }

  if( RouteId.objid != NULL_OBJID )
    {
#ifdef DEBUG
      printf( "save routid, cptnum\n" );
#endif
      PreCompId = RouteId;

        status = RTget_free_cpt( &RouteId, &FreeCpt );
#ifdef DEBUG
        printf( "id:%d  cpt:%d\n", RouteId.objid, FreeCpt );
#endif

      PreCptNum = FreeCpt;
      PreSegId  = SegmentId;
    }
 }

 if( RouteId.objid != NULL_OBJID &&
     part_type == PART_TYPE_LINEAR_PIPE_SECTION )
 {
      PreCompId = RouteId;

      FreeCpt = 0;
#ifdef DEBUG
      printf( "id:%d  cpt:%d\n", RouteId.objid, FreeCpt );
#endif

      PreCptNum = FreeCpt;
      PreSegId  = SegmentId;
 }

 if( EndOfRun )
 {
  bFirst = TRUE;

  if( part_type == PART_TYPE_LINEAR_PIPE_SECTION &&
      PreCompId.objid != NULL_OBJID )
  {
   tmp_spec = *PART_SPEC;
   strcpy( tmp_spec.comp_code, "dangle" );
   tmp_info.n_ports = 1;

   tmp_info.transform.translate[0]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[0];
   tmp_info.transform.translate[1]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[1];
   tmp_info.transform.translate[2]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[2];

   status = RTorient_dangle(
	 ((linear_pipe_info *)data_block_ptr)->end_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[2],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[2],
	 &(tmp_info.transform) );

   if( status != RTSUCC )
    return RTERR;

   status = RTput_component( &tmp_spec, sys_name, pipeline_id,
			     PART_TYPE_COMPONENT, &tmp_info,
			     iinfo, TRUE, &RouteId, &retType, &retNbCpts );

   FreeCpt = 0;

#ifdef DEBUG
   printf( "Connect Previous Comp to dangle\n" );
   printf( "PreCompId:%d  PreCptNum:%d  RouteId:%d  FreeCpt:%d\n",
	    PreCompId.objid, PreCptNum, RouteId.objid, FreeCpt );
#endif

   status =
   VRConnectComponents( &PreCompId, PreCptNum, &RouteId,
		        FreeCpt,
			&PreSegId, &SegmentId, &Active_env,
			&CorId );
   as$status( action = RET_STATUS );
  }/* part_type == PART_TYPE_LINEAR_PIPE_SECTION */
#ifdef DEBUG
  printf( "end of run\n" );
#endif
 }/* EndOfRun */

  return RTSUCC;
}

int RTput_component( PART_SPEC, sys_name, pipeline_id, part_type,
		     data_block_ptr, iinfo, bDisFlag, route_id,
		     pType, pNbCpts )
p_spec *PART_SPEC;
char *sys_name;
char *pipeline_id;
int part_type;
void *data_block_ptr;
insul_info *iinfo;
IGRboolean bDisFlag;
struct GRid *route_id;
IGRint *pType;
IGRint *pNbCpts;
{
  struct GRid SysParam, UsrParam, TmpUsrPar;
  IGRlong retcode = MSSUCC;
  struct ACrg_coll ListAttr[5];
  IGRint NbAttr, type, NbCpts;
  struct GRid SymbId, CompId;
  struct GRsymbology Symb;
  IGRint NbMissingParams = 0;
  int    status = OM_S_SUCCESS;
  double TxMatrix[16];
  IGRchar compcode[12], p_spec[9];
  IGRshort TrmdElbow = FALSE;

  SysParam.objid = NULL_OBJID;
  SysParam.osnum = Active_env.md_id.osnum;

  UsrParam.objid = NULL_OBJID;
  UsrParam.osnum = Active_env.md_id.osnum;

  CompId.objid = NULL_OBJID;
  CompId.osnum = Active_env.md_id.osnum;


  switch( part_type )
  {
    case PART_TYPE_LINEAR_PIPE_SECTION:
     /* ((linear_pipe_info *)(data_block_ptr))->x */
     /* Start-Coordinate  End-Coordinate */
     break;

    case PART_TYPE_BENT_PIPE_SECTION:
     /* Start-Coordinate  Center-Coordinate  End-Coordinate  T-Matrix */
     status = RTconvert( TxMatrix,
			 &(((bent_pipe_info *)(data_block_ptr))->transform) );
     if( status == RTERR )
      return status;

     break;

    case PART_TYPE_COMPONENT:
    /* Start-Coordinate  End-Coordinate  Third-Coordinate  T-Matrix */

#ifdef DEBUG
     printf( "x) %lf  %lf  %lf\n",
	       (((component_info *)(data_block_ptr))->transform).x[0],
		(((component_info *)(data_block_ptr))->transform).x[1],
		(((component_info *)(data_block_ptr))->transform).x[2] );

     printf( "y) %lf  %lf  %lf\n",
	       (((component_info *)(data_block_ptr))->transform).y[0],
		(((component_info *)(data_block_ptr))->transform).y[1],
		(((component_info *)(data_block_ptr))->transform).y[2] );

     printf( "z) %lf  %lf  %lf\n",
	       (((component_info *)(data_block_ptr))->transform).z[0],
		(((component_info *)(data_block_ptr))->transform).z[1],
		(((component_info *)(data_block_ptr))->transform).z[2] );

     printf( "o) %lf  %lf  %lf\n",
	       (((component_info *)(data_block_ptr))->transform).translate[0],
		(((component_info *)(data_block_ptr))->transform).translate[1],
	(((component_info *)(data_block_ptr))->transform).translate[2] );
#endif

     status = RTconvert( TxMatrix,
			 &(((component_info *)(data_block_ptr))->transform) );
     if( status == RTERR )
      return status;

     break;

    default:
     printf( "undefined part type\n" );
     return RTERR;
  }


  VR$ModifyCollection
       ( p_msg			= &retcode,
         Operation              = VR_MERGE_COLL,
         Type                   = VR_RG_COLL,
         p_InputCollectionId    = &RTSysParam,
         p_OutputCollectionId   = &SysParam );

  NbAttr = 0;

#ifdef DEBUG
  printf( "g_size:%lf\n", (IGRdouble)(PART_SPEC->g_size) );
#endif
  strcpy( ListAttr[NbAttr].name, VR_N_GDIAMETER_DB );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
  ListAttr[NbAttr].desc.value.att_exp = (IGRdouble)(PART_SPEC->g_size);
  NbAttr ++;

#ifdef DEBUG
  printf( "r_size:%lf\n", (IGRdouble)(PART_SPEC->r_size) );
#endif
  strcpy( ListAttr[NbAttr].name, VR_N_RDIAMETER_DB );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
  ListAttr[NbAttr].desc.value.att_exp = (IGRdouble)(PART_SPEC->r_size);
  NbAttr ++;

  strcpy( ListAttr[NbAttr].name, VR_N_SEQ_NUMBER_AN );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
  strcpy( ListAttr[NbAttr].desc.value.att_txt, pipeline_id );
  NbAttr ++;

#ifdef DEBUG
  printf( "pipe_spec:%s\n", PART_SPEC->pipe_spec );
#endif
  strcpy( ListAttr[NbAttr].name, VR_N_CLASS_AN );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
  strcpy( ListAttr[NbAttr].desc.value.att_txt, PART_SPEC->pipe_spec );
  NbAttr ++;

  strcpy( ListAttr[NbAttr].name, VR_N_SYST_NAME_AN );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
  strcpy( ListAttr[NbAttr].desc.value.att_txt, sys_name );
  NbAttr ++;

  /*strcpy( ListAttr[NbAttr].name, VR_N_FLUID_CODE_AN );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
  strcpy( ListAttr[NbAttr].desc.value.att_txt, sys_name );
  NbAttr ++;*/

  /*
  strcpy( ListAttr[NbAttr].name, VR_N_INSUL_TYPE_AN );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
  strcpy( ListAttr[NbAttr].desc.value.att_txt, iinfo->matl_desc );
  NbAttr ++;

  strcpy( ListAttr[NbAttr].name, VR_N_INSUL_THK_DB );
  ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
  ListAttr[NbAttr].desc.value.att_exp = (IGRdouble)(iinfo->thickness );
  NbAttr ++;
  */

  /*
  VR_UPDATE_COLL: If the output and input coll's have parameters in
		  in common, replace output coll parameters with input
		  coll parameters.
  VR_UNION_COLL : Add to the output, all parameters which do not exist
		  in the input collection.
  VR_MERGE_COLL : UPDATE + UNION
  */

  VR$ModifyCollection
       ( p_msg			= &retcode,
         Operation              = VR_MERGE_COLL,
         Type                   = VR_RG_COLL,
         p_ParamsListToModify   = ListAttr,
         NbParamsToModify       = NbAttr,
         p_OutputCollectionId   = &SysParam );

  strcpy( compcode, PART_SPEC->comp_code );
  strcpy( p_spec, PART_SPEC->pipe_spec );

  if( (strcmp(compcode, "EL90T") == 0)	||
      ((strcmp(compcode, "EL90") == 0) && (strcmp(p_spec, "N5") == 0)) )
  {
    /* add missing parameter to UsrParam */

    VR$ModifyCollection
       ( p_msg                  = &retcode,
         Operation              = VR_MERGE_COLL,
         Type                   = VR_RG_COLL,
         p_InputCollectionId    = &RTUsrParam,
         p_OutputCollectionId   = &UsrParam );

    NbAttr = 0;

    strcpy( ListAttr[NbAttr].name, VR_N_BEND_ANG_DB );
    ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
    ListAttr[NbAttr].desc.value.att_exp = (IGRdouble)(90.0);
    NbAttr ++;

    VR$ModifyCollection
       ( p_msg                  = &retcode,
         Operation              = VR_MERGE_COLL,
         Type                   = VR_RG_COLL,
         p_ParamsListToModify   = ListAttr,
         NbParamsToModify       = NbAttr,
         p_OutputCollectionId   = &UsrParam );

    TmpUsrPar = UsrParam;

    TrmdElbow = TRUE;
  }

  SymbId.osnum = Active_env.md_id.osnum;
  VR$symbology( return_code = &retcode,
                symb_id     = &SymbId,
                symb        = &Symb );

#ifdef DEBUG
  if( strcmp(compcode, "dangle") == 0 )
   printf( "place dangle\n" );
#endif

  if( strcmp(compcode, "dangle") == 0 )
  {
    status = VR$Evaluate( p_msg = &retcode,
                        Product = VR_PIPING,
                        ItemNum = VR_DANGLING,
                        SStatus = 0,
                        p_Option = (IGRshort *)&(PART_SPEC->option),
                        Symbology = &Symb,
                        Representation = AC_3D_REP,
                        p_Type = &type,
                        p_NbCpts = &NbCpts,
                        p_SysParamId = &SysParam,
                        p_UsrParamId = &RTUsrParam,
                        p_ComponentId = &CompId,
                        p_NbMissParams = &NbMissingParams,
                        p_MdEnv = &Active_env );
  }
  else
  {
#ifdef DEBUG
    printf( "comp_code:%s\n", PART_SPEC->comp_code );
    printf( "option:%d\n", PART_SPEC->option );
    printf( "VR$Evaluate\n" );
#endif

    if( !TrmdElbow )
     TmpUsrPar = RTUsrParam; /* global */

    status = VR$Evaluate( p_msg = &retcode,
                        Product = VR_PIPING,
                        AABBCCcode = PART_SPEC->comp_code,
                        SStatus = 0,
                        p_Option = (IGRshort *)&(PART_SPEC->option),
                        Symbology = &Symb,
                        Representation = AC_3D_REP,
                        p_Type = &type,
                        p_NbCpts = &NbCpts,
                        p_SysParamId = &SysParam,
                        p_UsrParamId = &TmpUsrPar,
                        p_ComponentId = &CompId,
                        p_NbMissParams = &NbMissingParams,
                        p_MdEnv = &Active_env );
  }

  if( !( status & 1 & retcode) )
  {
        ex$message(     field   = ERROR_FIELD,
                        in_buff = "Component not found in data base !");
        return RTERR;
  }

  if( part_type == PART_TYPE_BENT_PIPE_SECTION ||
      part_type == PART_TYPE_COMPONENT )
  {
#ifdef DEBUG
    printf( "orient component\n" );
#endif

    status = VR$OrientComp( p_retmsg = &retcode,
                            p_CmpId = &CompId,
                            Matrix = TxMatrix,
                            Angle = 0.0,
                            p_MdEnv = &Active_env
                          );

    if( !( status & 1 & retcode ) )
     return RTERR;
  }

#ifdef DEBUG
  printf( "display\n" );
#endif

  if( bDisFlag )
  {
    status = gr$display_object(
                        object_id = &CompId,
                        md_env = &Active_env );

    as$status( action = RET_STATUS );
  }


  *route_id = CompId;

  /*
  *pType = type;

  printf( "after indirection for pType\n" ); */

  *pNbCpts = NbCpts;

  return RTSUCC;
}

int VRConnectComponents( CompId1, CptNum1, CompId2, CptNum2,
		          pPrevSegId, pSegmentId, pModEnv,
			  pCorId )
struct GRid *CompId1;
IGRshort CptNum1;
struct GRid *CompId2;
IGRshort CptNum2;
struct GRid *pPrevSegId;
struct GRid *pSegmentId;	/* O */
struct  GRmd_env *pModEnv;
struct GRid *pCorId;		/* O */
{
  IGRlong msg, status;
  IGRshort nIndex[2];
  /*struct GRid CorId;*/
  IGRdouble matrix[16];
  IGRdouble StPoint[3], EnPoint[3];
  int NumbPar;
  struct ACrg_coll AttList[3];
  IGRint nb_cpts1, nb_cpts2;

  pSegmentId->osnum = pModEnv->md_id.osnum;
  pPrevSegId->osnum = pModEnv->md_id.osnum;
  CompId1->osnum    = pModEnv->md_id.osnum;
  CompId2->osnum    = pModEnv->md_id.osnum;

  
  status = vr$review_topology( pMsg = &msg,
                               pComponent = CompId1,
                               CptNum = CptNum1,
			       pTee = matrix,
                               pMdEnv = pModEnv );
  as$status( action = RET_STATUS );

  StPoint[0] = matrix[3];
  StPoint[1] = matrix[7];
  StPoint[2] = matrix[11];



  status = vr$review_topology( pMsg = &msg,
                               pComponent = CompId2,
                               CptNum = CptNum2,
			       pTee = matrix,
                               pMdEnv = pModEnv );
  as$status( action = RET_STATUS );

  EnPoint[0] = matrix[3];
  EnPoint[1] = matrix[7];
  EnPoint[2] = matrix[11];



  if( pPrevSegId->objid == NULL_OBJID )
  {
    status = VR$PlaceSegment(
			    p_retmsg = &msg,
			    Product = VR_PIPING,
			    p_SegmentPt0 = StPoint,
			    p_SegmentPt1 = EnPoint,
			    p_CurMdEnv = pModEnv,
			    p_NewSegmentId = pSegmentId );
    as$status();
  }
  else
  {
    status = VR$PlaceSegment(
			    p_retmsg = &msg,
			    Product = VR_PIPING,
			    p_SegmentPt0 = StPoint,
			    p_SegmentPt1 = EnPoint,
			    p_PrevSegId  = pPrevSegId,
			    p_CurMdEnv = pModEnv,
			    p_NewSegmentId = pSegmentId );
    as$status();
  }

  
  NumbPar = 1;
  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = CompId1,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = pModEnv );

   nb_cpts1 = (IGRint)AttList[0].desc.value.att_exp;


  NumbPar = 1;
  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = CompId2,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = pModEnv );

   nb_cpts2 = (IGRint)AttList[0].desc.value.att_exp;

   

  nIndex[0] = 0;
  nIndex[1] = 1;

  status =
  VRConnect( &msg, CompId1, &CptNum1, nb_cpts1,
             pSegmentId, (IGRint)1, &nIndex[0], pModEnv  );
  as$status();

  status =
  VRConnect( &msg, CompId2, &CptNum2, nb_cpts2,
             pSegmentId,(IGRint)1, &nIndex[1], pModEnv  );
  as$status();


  VRUpdateGeometry( &msg, NULL, CompId1, pModEnv );
  VRUpdateGeometry( &msg, NULL, CompId2, pModEnv );

  pCorId->objid = NULL_OBJID;
  pCorId->osnum = pModEnv->md_id.osnum;

  status =
  VR$ComputeCorrection(   		p_retmsg 	= &msg,
                                        CorType         = VR_NO_FTF,
                                        p_SegmentId     = pSegmentId,
                                        p_MdEnv         = pModEnv,
                                        p_CorId         = pCorId );
  as$status();

  if( pCorId->objid != NULL_OBJID )
  {
    status = gr$display_object(
           	      object_id = pCorId,
                      md_env = pModEnv );

    as$status();
   }

  return OM_S_SUCCESS;
}

int RTget_free_cpt( CompId, FreeCptNo )
struct GRid *CompId;
IGRshort    *FreeCptNo;
{
  IGRint ii, nb_cpts;
  int NumbPar;
  struct ACrg_coll AttList[3];
  IGRlong msg, status;
  struct GRid NextId;

  *FreeCptNo = -1;

  NumbPar = 1;
  strcpy( AttList[0].name, VR_N_NB_CONNECT_IN );

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = CompId,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = &Active_env );

  as$status( action = RET_STATUS );

  nb_cpts = (IGRint)AttList[0].desc.value.att_exp;

  for( ii=0; ii < nb_cpts; ++ii )
  {
    status = vr$review_topology( pMsg = &msg,
                                 pComponent = CompId,
                                 CptNum = ii,
                                 pNeighbor = &NextId,
                                 pMdEnv = &Active_env );
    as$status( action = RET_STATUS );

    if( NextId.objid == NULL_OBJID )
     break;
  }

  if( ii < nb_cpts )
   *FreeCptNo = ii;
  else
   *FreeCptNo = -1;

  return RTSUCC;
}

/* Put Piping Entity - revised */
int RT_put_piping_entity( PART_SPEC, sys_name, pipeline_id, part_type,
			  data_block_ptr, iinfo, inlet_cpt, outlet_cpt,
			  StartOfRun, route_id )
p_spec *PART_SPEC;
char *sys_name;
char *pipeline_id;
int part_type;
void *data_block_ptr;
insul_info *iinfo;
write_cpt_struct *inlet_cpt;
write_cpt_struct *outlet_cpt;
IGRint StartOfRun;
struct GRid *route_id;
{
 int    status = OM_S_SUCCESS;
 IGRint retType, retNbCpts;
 IGRint ii;
 struct GRid RouteId;
 struct GRid DangleOne;
 struct GRid DangleTwo;
 struct GRid DnglId;
 struct GRid CorId;
 struct GRid PipeId;
 struct GRid PreSegId  = {0, 0, };
 struct GRid pre_seg_id  = {0, 0, };
 static struct GRid FirDangle = {0, 0, };
 struct GRid SegmentId;
 IGRshort FreeCpt = -1;
 p_spec tmp_spec;
 component_info tmp_info;
 int NumbPar;
 struct ACrg_coll AttList[5];
 IGRlong msg;
 IGRchar CompCode[7], NeiCompCode[7];
 IGRshort NextCptNum = -1;
 IGRint TmpCptNum = -1;
 struct GRid NextId;
 IGRint ArraySize = 5;
 struct GRid NewSegId;
 struct GRid SegIds[2];
 struct GRid TeeSegId;
 IGRint NbSupports;
 IGRshort  GivenAction = 0;
 IGRdouble NextPoint[3];
 IGRdouble PipeDia;
 IGRdouble SplitPoint[3], Point[3];
 IGRdouble EndPoint[6];
 IGRdouble matrix[16];
 IGRint nb_cpts;
 IGRshort CptNum1 = 0;
 IGRshort CptNum2 = 1;
 IGRshort CptNum[2];
 IGRshort nIndex[2];
 IGRshort sIndex[2];

 route_id->objid = NULL_OBJID;
 route_id->osnum = 0;

 RouteId.objid = NULL_OBJID;
 RouteId.osnum = 0;

 DnglId.objid = NULL_OBJID;
 DnglId.osnum = 0;

 PreSegId.objid = NULL_OBJID;
 PreSegId.osnum = Active_env.md_id.objid;

 CorId.objid = NULL_OBJID;
 CorId.osnum = Active_env.md_id.objid;

 if( StartOfRun &&	 				/* special case */
     part_type == PART_TYPE_LINEAR_PIPE_SECTION &&
     inlet_cpt->route_id.objid == NULL_OBJID )
 {
#ifdef DEBUG
   printf( "First Linear Pipe\n" );
#endif

   /* place a dangle at pipe start coordinates */
   tmp_spec = *PART_SPEC;
   strcpy( tmp_spec.comp_code, "dangle" );
   tmp_info.n_ports = 1;

   tmp_info.transform.translate[0]
	 = ((linear_pipe_info *)data_block_ptr)->start_coord[0];
   tmp_info.transform.translate[1]
	 = ((linear_pipe_info *)data_block_ptr)->start_coord[1];
   tmp_info.transform.translate[2]
	 = ((linear_pipe_info *)data_block_ptr)->start_coord[2];

   status = RTorient_dangle(
	 ((linear_pipe_info *)data_block_ptr)->start_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[2],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[2],
	 &(tmp_info.transform) );

   if( status != RTSUCC )
    return RTERR;

   status = RTput_component( &tmp_spec, sys_name, pipeline_id,
			     PART_TYPE_COMPONENT, (void *)&tmp_info,
			     iinfo, TRUE, &DangleOne, &retType,
			     &retNbCpts );
   if( status != RTSUCC )
    return RTERR;

   FirDangle = DangleOne;

   /* place a dangle at pipe end coordinates */
   tmp_spec = *PART_SPEC;
   strcpy( tmp_spec.comp_code, "dangle" );
   tmp_info.n_ports = 1;

   tmp_info.transform.translate[0]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[0];
   tmp_info.transform.translate[1]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[1];
   tmp_info.transform.translate[2]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[2];

   status = RTorient_dangle(
	 ((linear_pipe_info *)data_block_ptr)->end_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[2],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[2],
	 &(tmp_info.transform) );

   if( status != RTSUCC )
    return RTERR;

   status = RTput_component( &tmp_spec, sys_name, pipeline_id,
			     PART_TYPE_COMPONENT, (void *)&tmp_info,
			     iinfo, TRUE, &DangleTwo, &retType,
			     &retNbCpts );

   if( status != RTSUCC )
    return RTERR;

   /* connect the above dangles with a linear pipe */
   status =
   VRConnectComponents( &DangleOne, 0, &DangleTwo, 0,
			&PreSegId, &SegmentId, &Active_env,
			&CorId );
   as$status( action = RET_STATUS );

   if( SegmentId.objid != NULL_OBJID )
   {
     status = RtChangeProp( &SegmentId );
     as$status( action = RET_STATUS );
   }

   status = vr$review_topology( pMsg = &msg,
                                pComponent = &DangleOne,
                                CptNum = 0,
                                pNeighbor = &PipeId,
                                pMdEnv = &Active_env );
   as$status( action = RET_STATUS );

   *route_id = PipeId;
 }
 else if( part_type == PART_TYPE_COMPONENT ||
	  part_type == PART_TYPE_BENT_PIPE_SECTION )
 {
   if( inlet_cpt->route_id.objid != NULL_OBJID )
   {
#ifdef DEBUG
     printf( "Component/Bent-Pipe\n" );
#endif
     /* Get the Component Code of the inlet object */
     NumbPar = 1;
     strcpy( AttList[0].name, VR_N_COMP_CODE_AN );

     status =
     vr$review_parameters( pMsg            = &msg,
                           pComponent      = &inlet_cpt->route_id,
                           NbParams        = NumbPar,
                           pList           = AttList,
                           pMdEnv          = &Active_env );

     strcpy( CompCode, AttList[0].desc.value.att_txt );

     if( strcmp(CompCode, "PIPING") == 0 )
     {
       if( strcmp(&PART_SPEC->comp_code[1], "OLET") == 0 )
       {
	 /* find diameter of the inlet pipe and the Green diameter
	    of the olet */
	 NumbPar = 1;
	 strcpy( AttList[0].name, VR_N_GDIAMETER_DB );         /* npd green */

	 status =
	 vr$review_parameters( pMsg            = &msg,
                       	       pComponent      = &inlet_cpt->route_id,
                               NbParams        = NumbPar,
                               pList           = AttList,
                               pMdEnv          = &Active_env );
	 as$status();

	 PipeDia = AttList[0].desc.value.att_exp;

	 if( PipeDia == PART_SPEC->g_size )
	 {

#ifdef DEBUG
	   printf( "Place Olet\n" );
#endif

	   /* Evaluate & Orient the new component */
           status = RTput_component( PART_SPEC, sys_name, pipeline_id,
				     part_type, data_block_ptr, iinfo,
				     TRUE, &RouteId, &retType, &retNbCpts );
	   if( status == RTERR )
	    return RTERR;

	   /* Find the split point */
	   SplitPoint[0] =
		 ((component_info *)data_block_ptr)->transform.translate[0];

	   SplitPoint[1] =
		 ((component_info *)data_block_ptr)->transform.translate[1];

	   SplitPoint[2] =
		 ((component_info *)data_block_ptr)->transform.translate[2];

	   /* Get the Segment Id */
	   status = VRSkGetPipeVirtualSupportInfo( &inlet_cpt->route_id,
						   SplitPoint,
						   &Active_env, &SegmentId,
						   NULL,
                               			   EndPoint );
	   as$status();

	   nb_cpts = 2;

	   nIndex[0] = 0;
	   nIndex[1] = 1;

	   /* split the segment */
  	   status = VR$SplitSegment( p_retmsg = &msg,
				     SharePlanes = TRUE,
                                     p_SegmentToSplitId = &SegmentId,
                                     p_SplitPoint = SplitPoint,
                                     p_MdEnv = &Active_env,
                                     p_NewSegmentId = &NewSegId
                        );
           as$status();

	   /* connect the olet to both segments *
  	   status =
  	   VRConnect( &msg, &RouteId, &CptNum1, nb_cpts,
             	      &SegmentId, (IGRint)1, &nIndex[1], &Active_env );
  	   as$status();

  	   status =
  	   VRConnect( &msg, &RouteId, &CptNum2, nb_cpts,
             	      &NewSegId,(IGRint)1, &nIndex[0], &Active_env );
  	   as$status();*/

	   CptNum[0] = 0;
	   CptNum[1] = 1;
	   SegIds[0] = SegmentId;
	   SegIds[1] = NewSegId;
	   sIndex[0] = 1;
	   sIndex[1] = 0;
  	   status =
  	   VRConnect( &msg, &RouteId, CptNum, nb_cpts,
             	      SegIds, (IGRint)2, sIndex, &Active_env );
  	   as$status();


  	   VRUpdateGeometry( &msg, NULL, &RouteId, &Active_env );

	   *route_id = RouteId;

	   return RTSUCC;
	 }
       }

#ifdef DEBUG
       printf( "Extend & Replace\n" );
#endif
       /* conventional case */
       /* Get the dangle id from the pipe id */
       for( ii=0; ii < 2; ++ii )
       {
         /*C Find neighbor */
         status =
         vr$review_topology ( pMsg = &msg,
                              pComponent = &inlet_cpt->route_id,
                              CptNum = ii,
                              pNeighbor  = &NextId,
                              pNeighCpt  = &TmpCptNum,
                              pMdEnv = &Active_env );
         as$status();

	 NextCptNum = (short)TmpCptNum;

	 /* Get the Component Code of the Neighbor */
	 NumbPar = 1;
	 strcpy( AttList[0].name, VR_N_COMP_CODE_AN );

	 status =
	 vr$review_parameters( pMsg            = &msg,
                               pComponent      = &NextId,
                               NbParams        = NumbPar,
                               pList           = AttList,
                               pMdEnv          = &Active_env );

	 strcpy( NeiCompCode, AttList[0].desc.value.att_txt );

	 if( strcmp(NeiCompCode, "dangle") == 0 &&
	     !(NextId.objid == FirDangle.objid &&
	       NextId.osnum == FirDangle.osnum) )
	 {
	   DnglId = NextId;
	   break;
	 }
       }/* for ii */

       if( DnglId.objid )
       {
	 /* get the control segment */

	 status = vr$review_topology( pMsg = &msg,
                                      pComponent = &DnglId,
                               	      CptNum = 0,
                               	      pTee = matrix,
                               	      pMdEnv = &Active_env );
	 as$status( action = RET_STATUS );

	 Point[0] = matrix[3];
	 Point[1] = matrix[7];
	 Point[2] = matrix[11];

	 /* Get the Segment Id */
	 status = VRSkGetPipeVirtualSupportInfo( &inlet_cpt->route_id,
						 Point,
						 &Active_env, &SegmentId,
						 NULL,
                               			 EndPoint );
	 as$status();

	 pre_seg_id = SegmentId;

	 /* extend the pipe upto the placement point of the component */
	 GivenAction = IS_AN_EXTEND;
	 GivenAction &= ~VR_SHARE_PLANES;

	 NextPoint[0] =
	   (((component_info *)(data_block_ptr))->transform).translate[0];
	 NextPoint[1] =
	   (((component_info *)(data_block_ptr))->transform).translate[1];
	 NextPoint[2] =
	   (((component_info *)(data_block_ptr))->transform).translate[2];

	 status = VR$PlaceSegment( p_retmsg     = &msg,
				   Product      = VR_PIPING,
				   GivenAction  = GivenAction,
				   p_SegmentPt0 = NULL,
				   p_SegmentPt1 = NextPoint,
				   p_PrevSegId  = &SegmentId,
				   p_CurMdEnv   = &Active_env );
	 as$status();

#ifdef DEBUG
	 printf( "Evaluate & Orient the Component/Bent-Pipe\n" );
#endif
	 /* Evaluate & Orient the new component */
         status = RTput_component( PART_SPEC, sys_name, pipeline_id, part_type,
                                   data_block_ptr, iinfo, FALSE, &RouteId,
                                   &retType, &retNbCpts );
	 if( status == RTERR )
	  return RTERR;


	 /* Disconnect old comp and connect new one */
	 status = VRReConnect( &msg, &DnglId, &RouteId, 0, retNbCpts,
                        0, NULL, &Active_env );

	 as$status();

	 /* delete the old object */
	 status = gr$delete_object(
           			msg = &msg,
           			md_env = &Active_env,
           			object_id = &DnglId );
	 as$status();

	 /* erase the pipe, will display it later */
	 status = VRUndisplayComponent( &inlet_cpt->route_id, &Active_env );
	 as$status();

	 /* display the new object */
	 status = gr$display_object(
                        object_id = &RouteId,
                        md_env = &Active_env );

	 as$status( action = RET_STATUS );

	 *route_id = RouteId;

	 VRUpdateGeometry( &msg, NULL, &RouteId, &Active_env );

	 CorId.objid = NULL_OBJID;
         CorId.osnum = Active_env.md_id.osnum;

	 status =
	 VR$ComputeCorrection( p_retmsg        = &msg,
                               CorType         = VR_NO_FTF,
                               p_SegmentId     = &SegmentId,
                               p_MdEnv         = &Active_env,
                               p_CorId         = &CorId );
	 as$status();

	 if( CorId.objid != NULL_OBJID )
	 {
	   status = gr$display_object(
           	      object_id = &CorId,
                      md_env = &Active_env );

	   as$status();
	 }

       }
     }
     else if( strcmp(CompCode, "FLANGE") == 0 &&
	      (strcmp(PART_SPEC->comp_code, "GATE") == 0  ||
	       strcmp(PART_SPEC->comp_code, "BALL") == 0  ||
	       strcmp(PART_SPEC->comp_code, "GLOBE") == 0 ||
	       strcmp(PART_SPEC->comp_code, "CHECK") == 0 ||
	       strcmp(PART_SPEC->comp_code, "BFLANG") == 0 )
	    )
     {
	/* destroy flange at inlet */

	RtGetSegment( &inlet_cpt->route_id, &PreSegId );

	/* extend the pipe upto the placement point of the component */
	GivenAction = IS_AN_EXTEND;
	GivenAction &= ~VR_SHARE_PLANES;

	NextPoint[0] =
	  (((component_info *)(data_block_ptr))->transform).translate[0];
	NextPoint[1] =
	  (((component_info *)(data_block_ptr))->transform).translate[1];
	NextPoint[2] =
	  (((component_info *)(data_block_ptr))->transform).translate[2];

	status = VR$PlaceSegment( p_retmsg     = &msg,
                             	  Product      = VR_PIPING,
                             	  GivenAction  = GivenAction,
                             	  p_SegmentPt0 = NULL,
                             	  p_SegmentPt1 = NextPoint,
                             	  p_PrevSegId  = &PreSegId,
                             	  p_CurMdEnv   = &Active_env );
	as$status();

	/* Evaluate & Orient the new component */
	status = RTput_component( PART_SPEC, sys_name, pipeline_id, part_type,
                             	  data_block_ptr, iinfo, FALSE, &RouteId,
                             	  &retType, &retNbCpts );
	if( status == RTERR )
    	 return RTERR;

	/* Disconnect the flange and connect the new component */
	status = VRReConnect( &msg, &inlet_cpt->route_id, &RouteId, 0,
			      retNbCpts, 0, NULL, &Active_env );

	as$status();

	/* erase the flange */
	status = VRUndisplayComponent( &inlet_cpt->route_id, &Active_env );
	as$status();

	/* delete the flange */
	status = gr$delete_object(
                           msg = &msg,
                           md_env = &Active_env,
                           object_id = &inlet_cpt->route_id );
	as$status();

	/* display the new object */
	status = gr$display_object(
                       object_id = &RouteId,
                       md_env = &Active_env );

	as$status( action = RET_STATUS );

	*route_id = RouteId;

	VRUpdateGeometry( &msg, NULL, &RouteId, &Active_env );

	CorId.objid = NULL_OBJID;
	CorId.osnum = Active_env.md_id.osnum;

	status =
	VR$ComputeCorrection( p_retmsg        = &msg,
                              CorType         = VR_NO_FTF,
                              p_SegmentId     = &PreSegId,
                              p_MdEnv         = &Active_env,
                              p_CorId         = &CorId );
	as$status();

	if( CorId.objid != NULL_OBJID )
	{
	  status = gr$display_object(
                      object_id = &CorId,
                      md_env = &Active_env );

	  as$status();
	}

     }
     else if( (strcmp(CompCode, "FLANGE") == 0 ||
	       strcmp(CompCode, "GATE") == 0   ||
	       strcmp(CompCode, "BALL") == 0   ||
	       strcmp(CompCode, "GLOBE") == 0  ||
	       strcmp(CompCode, "CHECK") == 0  ||
	       strcmp(CompCode, "BFLANG") == 0 )
	    && strcmp(PART_SPEC->comp_code, "FLANGE") == 0
	    )
     {
	/* place correction instead of flange */

        /* place a dangle at pipe end coordinates */
        tmp_spec = *PART_SPEC;
        strcpy( tmp_spec.comp_code, "dangle" );
        tmp_info.n_ports = 1;

        tmp_info.transform.translate[0] =
           (((component_info *)(data_block_ptr))->transform).translate[0];
        tmp_info.transform.translate[1] =
           (((component_info *)(data_block_ptr))->transform).translate[1];
        tmp_info.transform.translate[2] =
           (((component_info *)(data_block_ptr))->transform).translate[2];

        status = vr$review_topology( pMsg = &msg,
                                pComponent = &inlet_cpt->route_id,
                                CptNum = 0,
                                pTee = matrix,
                                pMdEnv = &Active_env );
        as$status( action = RET_STATUS );

        status = RTorient_dangle(
	  (((component_info *)(data_block_ptr))->transform).translate[0],
	  (((component_info *)(data_block_ptr))->transform).translate[1],
	  (((component_info *)(data_block_ptr))->transform).translate[2],
          matrix[3],
          matrix[7],
          matrix[11],
          &(tmp_info.transform) );

        if( status != RTSUCC )
         return RTERR;

        status = RTput_component( &tmp_spec, sys_name, pipeline_id,
                             PART_TYPE_COMPONENT, (void *)&tmp_info,
                             iinfo, TRUE, &DangleTwo, &retType,
                             &retNbCpts );

        if( status != RTSUCC )
         return RTERR;

        FreeCpt = -1;
        status = RTget_free_cpt( &inlet_cpt->route_id, &FreeCpt );

        if( status == RTERR )
         return RTERR;

        status = RtGetSegment( &inlet_cpt->route_id, &PreSegId );
        as$status();

        /* connect the inlet component & the dangle with a linear pipe */
        status =
        VRConnectComponents( &inlet_cpt->route_id, -1, &DangleTwo, 0,
                             &PreSegId, &SegmentId, &Active_env,
                             &CorId );
        as$status( action = RET_STATUS );

        if( SegmentId.objid != NULL_OBJID )
        {
          status = RtChangeProp( &SegmentId );
          as$status( action = RET_STATUS );
        }

        status = vr$review_topology( pMsg = &msg,
                                pComponent = &DangleTwo,
                                CptNum = 0,
                                pNeighbor = &PipeId,
                                pMdEnv = &Active_env );
        as$status( action = RET_STATUS );

        *route_id = PipeId;
     }
     else
     {
       /* fitting to fitting */

#ifdef DEBUG
       printf( "FittingToFitting\n" );
#endif

       /* Evaluate & Orient the new component */
       status = RTput_component( PART_SPEC, sys_name, pipeline_id, part_type,
                                   data_block_ptr, iinfo, TRUE, &RouteId,
                                   &retType, &retNbCpts );
       if( status == RTERR )
        return RTERR;

       status = RtGetSegment( &inlet_cpt->route_id, &PreSegId );
       as$status();

       /* connect the two components */
       status =
       VRConnectComponents( &inlet_cpt->route_id, -1, &RouteId, -1,
			&PreSegId, &SegmentId, &Active_env,
			&CorId );
       as$status();

       VRUpdateGeometry( &msg, NULL, &inlet_cpt->route_id, &Active_env );
       VRUpdateGeometry( &msg, NULL, &RouteId, &Active_env );

       *route_id = RouteId;
     }
   }
   else
   {
     /* just place the component */

#ifdef DEBUG
     printf( "Just Place\n" );
#endif

     /* Evaluate & Orient the new component */
     status = RTput_component( PART_SPEC, sys_name, pipeline_id, part_type,
                               data_block_ptr, iinfo, TRUE, &RouteId,
                               &retType, &retNbCpts );
     if( status == RTERR )
      return RTERR;

     *route_id = RouteId;
   }
 }
 else if( part_type == PART_TYPE_LINEAR_PIPE_SECTION &&
	  inlet_cpt->route_id.objid != NULL_OBJID )
 {
#ifdef DEBUG
   printf( "Linear Pipe\n" );
#endif

   /* Get the Component Code of the inlet object */
   NumbPar = 1;
   strcpy( AttList[0].name, VR_N_COMP_CODE_AN );

   status =
   vr$review_parameters( pMsg            = &msg,
                         pComponent      = &inlet_cpt->route_id,
                         NbParams        = NumbPar,
                         pList           = AttList,
                         pMdEnv          = &Active_env );
   as$status();

   strcpy( CompCode, AttList[0].desc.value.att_txt );

   if( strcmp(CompCode, "PIPING") == 0 )
   {
     /* extend control segment */

     /* get start coordinate of inlet pipe */
     status = vr$review_topology( pMsg = &msg,
                                  pComponent = &inlet_cpt->route_id,
                                  CptNum = 0,
                                  pMatrix = matrix,
                                  pMdEnv = &Active_env );
     as$status( action = RET_STATUS );

     Point[0] = matrix[3];
     Point[1] = matrix[7];
     Point[2] = matrix[11];

     /* Get the Segment Id */
     status = VRSkGetPipeVirtualSupportInfo( &inlet_cpt->route_id,
                                             Point,
                                             &Active_env, &SegmentId,
                                             NULL,
                                             EndPoint );
     as$status();


     /* extend the pipe upto the end point of the current pipe */
     GivenAction = IS_AN_EXTEND;
     GivenAction &= ~VR_SHARE_PLANES;

     NextPoint[0] =
       ((linear_pipe_info *)data_block_ptr)->end_coord[0];
     NextPoint[1] =
       ((linear_pipe_info *)data_block_ptr)->end_coord[1];
     NextPoint[2] =
       ((linear_pipe_info *)data_block_ptr)->end_coord[2];

     status = VR$PlaceSegment( p_retmsg     = &msg,
                               Product      = VR_PIPING,
                               GivenAction  = GivenAction,
                               p_SegmentPt0 = NULL,
                               p_SegmentPt1 = NextPoint,
                               p_PrevSegId  = &SegmentId,
                               p_CurMdEnv   = &Active_env );
     as$status();

     CorId.objid = NULL_OBJID;
     CorId.osnum = Active_env.md_id.osnum;

     status =
     VR$ComputeCorrection( p_retmsg        = &msg,
                           CorType         = VR_NO_FTF,
                           p_SegmentId     = &SegmentId,
                           p_MdEnv         = &Active_env,
                           p_CorId         = &CorId );
     as$status();

     if( CorId.objid != NULL_OBJID )
     {
        status = gr$display_object(
                      object_id = &CorId,
                      md_env = &Active_env );

        as$status();
     }

     *route_id = inlet_cpt->route_id;

   }
   else
   {
     /* place a dangle at pipe end coordinates */
     tmp_spec = *PART_SPEC;
     strcpy( tmp_spec.comp_code, "dangle" );
     tmp_info.n_ports = 1;

     tmp_info.transform.translate[0]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[0];
     tmp_info.transform.translate[1]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[1];
     tmp_info.transform.translate[2]
	 = ((linear_pipe_info *)data_block_ptr)->end_coord[2];

     status = RTorient_dangle(
	 ((linear_pipe_info *)data_block_ptr)->end_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->end_coord[2],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[0],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[1],
	 ((linear_pipe_info *)data_block_ptr)->start_coord[2],
	 &(tmp_info.transform) );

     if( status != RTSUCC )
      return RTERR;

     status = RTput_component( &tmp_spec, sys_name, pipeline_id,
			     PART_TYPE_COMPONENT, (void *)&tmp_info,
			     iinfo, TRUE, &DangleTwo, &retType,
			     &retNbCpts );

     if( status != RTSUCC )
      return RTERR;

     FreeCpt = -1;
     status = RTget_free_cpt( &inlet_cpt->route_id, &FreeCpt );

     if( status == RTERR )
      return RTERR;

     status = RtGetSegment( &inlet_cpt->route_id, &PreSegId );
     as$status();

     /* connect the inlet component & the dangle with a linear pipe */
     status =
     VRConnectComponents( &inlet_cpt->route_id, -1, &DangleTwo, 0,
			&PreSegId, &SegmentId, &Active_env,
			&CorId );
     as$status( action = RET_STATUS );

     if( SegmentId.objid != NULL_OBJID )
     {
       status = RtChangeProp( &SegmentId );
       as$status( action = RET_STATUS );
     }

     status = vr$review_topology( pMsg = &msg,
                                pComponent = &DangleTwo,
                                CptNum = 0,
                                pNeighbor = &PipeId,
                                pMdEnv = &Active_env );
     as$status( action = RET_STATUS );

     *route_id = PipeId;
   }
 }

 if( outlet_cpt->route_id.objid != NULL_OBJID )
 {
   /* Get the component code of the outlet component */
     NumbPar = 1;
     strcpy( AttList[0].name, VR_N_COMP_CODE_AN );

     status =
     vr$review_parameters( pMsg            = &msg,
                           pComponent      = &outlet_cpt->route_id,
                           NbParams        = NumbPar,
                           pList           = AttList,
                           pMdEnv          = &Active_env );

     strcpy( CompCode, AttList[0].desc.value.att_txt );

     if( strcmp(CompCode, "TEE") == 0 )
     {
       if( strcmp(PART_SPEC->comp_code, "PIPING") == 0 )
       {
	/* extend pipe & replace dangle with outlet_cpt */

	/* find the placement point of the TEE */
	status = vr$review_topology( pMsg = &msg,
                                     pComponent = &outlet_cpt->route_id,
                               	     CptNum = 0,
                               	     pTee = matrix,
                               	     pMdEnv = &Active_env );
	as$status( action = RET_STATUS );

	Point[0] = matrix[3];
	Point[1] = matrix[7];
	Point[2] = matrix[11];

        /* extend the pipe */
	GivenAction = IS_AN_EXTEND;
	GivenAction &= ~VR_SHARE_PLANES;

	status = VR$PlaceSegment( p_retmsg     = &msg,
				  Product      = VR_PIPING,
				  GivenAction  = GivenAction,
				  p_SegmentPt0 = NULL,
				  p_SegmentPt1 = Point,
				  p_PrevSegId  = &SegmentId,
				  p_CurMdEnv   = &Active_env );
	as$status();


	/* Disconnect the dangle and connect the TEE. */

	status = VRReConnect( &msg, &DangleTwo,
			      &outlet_cpt->route_id,
		              NULL, 3, 0, NULL, &Active_env );

	as$status();

       status = RtGetSegment( &outlet_cpt->route_id, &TeeSegId );
       as$status();

        status = RtSharePlanes( &SegmentId, &TeeSegId, &Active_env );
        as$status();

	/* delete the dangle */
	status = gr$delete_object(
           			msg = &msg,
           			md_env = &Active_env,
           			object_id = &DangleTwo );
	as$status();

	/* display the TEE */
	status = gr$display_object(
                        object_id = &outlet_cpt->route_id,
                        md_env = &Active_env );

	as$status( action = RET_STATUS );

        VRUpdateGeometry( &msg, NULL, &outlet_cpt->route_id, &Active_env );

	status =
	VR$ComputeCorrection( p_retmsg        = &msg,
                              CorType         = VR_NO_FTF,
                              p_SegmentId     = &SegmentId,
                              p_MdEnv         = &Active_env,
                              p_CorId         = &CorId );
	as$status();

	if( CorId.objid != NULL_OBJID )
	{
	   status = gr$display_object(
           	      object_id = &CorId,
                      md_env = &Active_env );

	   as$status();
	}
       }
       else
       {
	/* connect components */
	status = RtGetSegment( &RouteId, &PreSegId );	/* important */
	as$status();

	status =
	VRConnectComponents( &RouteId, -1, &outlet_cpt->route_id, -1,
			     &PreSegId, &SegmentId, &Active_env,
			     &CorId );
	as$status( action = RET_STATUS );

        status = RtGetSegment( &outlet_cpt->route_id, &TeeSegId );
        as$status();

        status = RtSharePlanes( &SegmentId, &TeeSegId, &Active_env );
        as$status();
       }
     }
     else if( strcmp(CompCode, "PIPING") == 0 &&
	      strcmp(&PART_SPEC->comp_code[1], "OLET") == 0 )
     {
       /* Get the Pipe Diameter */
       NumbPar = 1;
       strcpy( AttList[0].name, VR_N_GDIAMETER_DB );         /* npd green */

       status =
       vr$review_parameters( pMsg            = &msg,
                      	     pComponent      = &outlet_cpt->route_id,
                             NbParams        = NumbPar,
                             pList           = AttList,
                             pMdEnv          = &Active_env );
       as$status();

       PipeDia = AttList[0].desc.value.att_exp;

       if( PipeDia == PART_SPEC->g_size )
       {
	 /* split point */
	 Point[0] =
	    (((component_info *)data_block_ptr)->transform).translate[0];

	 Point[1] =
	    (((component_info *)data_block_ptr)->transform).translate[1];

	 Point[2] =
	    (((component_info *)data_block_ptr)->transform).translate[2];

	 /* get pipe segment id */
	 status = VRSkGetPipeVirtualSupportInfo( &outlet_cpt->route_id,
						 Point,
						 &Active_env, &SegmentId,
						 NULL,
                               			 EndPoint );
	 as$status();

	 nb_cpts = 2;

	 nIndex[0] = 0;
	 nIndex[1] = 1;

	 /* split the segment */
  	 status = VR$SplitSegment( p_retmsg = &msg,
				   SharePlanes = TRUE,
                                   p_SegmentToSplitId = &SegmentId,
                                   p_SplitPoint = Point,
                                   p_MdEnv = &Active_env,
                                   p_NewSegmentId = &NewSegId
                        	);
         as$status();

	 /* connect the olet to both segments *
  	 status =
  	 VRConnect( &msg, &RouteId, &CptNum1, nb_cpts,
             	    &SegmentId, (IGRint)1, &nIndex[1], &Active_env );
  	 as$status();

  	 status =
  	 VRConnect( &msg, &RouteId, &CptNum2, nb_cpts,
             	    &NewSegId,(IGRint)1, &nIndex[0], &Active_env );
  	 as$status();*/

	 CptNum[0] = 0;
	 CptNum[1] = 1;
	 SegIds[0] = SegmentId;
	 SegIds[1] = NewSegId;
	 sIndex[0] = 1;
	 sIndex[1] = 0;
  	 status =
  	 VRConnect( &msg, &RouteId, CptNum, nb_cpts,
             	    SegIds, (IGRint)2, sIndex, &Active_env );
  	 as$status();

	 status = RtSharePlanes( &pre_seg_id, &SegmentId, &Active_env );
	 as$status();

  	 VRUpdateGeometry( &msg, NULL, &RouteId, &Active_env );

	 CorId.objid = NULL_OBJID;
         CorId.osnum = Active_env.md_id.osnum;

	 status =
	 VR$ComputeCorrection( p_retmsg        = &msg,
                               CorType         = VR_NO_FTF,
                               p_SegmentId     = &SegmentId,
                               p_MdEnv         = &Active_env,
                               p_CorId         = &CorId );
	 as$status();

	 if( CorId.objid != NULL_OBJID )
	 {
	   status = gr$display_object(
           	      object_id = &CorId,
                      md_env = &Active_env );

	   as$status();
	 }
       }
     }
 }

  return RTSUCC;
}
