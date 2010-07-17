/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt_STEP/RTeqp.I
 *
 * Description:
 *      This is another copy of the vrrt/RTeqp.I file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: RTeqp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/11/06  19:20:30  pinnacle
# initial revision
#
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/
class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "rteqp.h"
#include "VRDbStruct.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "vrparameters.h"
#include "vrmacros.h"
#include "VRDbParamDef.h"
#include "macro.h"
#include "nddef.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "vdsmacros.h"
#include "VRdbcodlst.h"
#include "VDmacdef.h"
#include "grmacros.h"
#include "acrepdef.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRact_params.h"
#include "VRattr_def.h"
#include "VRdef.h"
#include "VREquipment.h"
#include "acmacros.h"
#include "acdef.h"
#include "ACattrib.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "ACdb_info.h"
#include "VDScheckdef.h"
#include "VRmacros.h"
#include "dp.h"

#include "VRcsdef.h"		/* just this one */
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
 
from VREquipment import VRGetSearch;
from VREquipment import VRGetMatrix;
from NDnode	 import NDget_objects;
from NDnode	 import	NDchg_state;
from VRNozzle	 import VRGetMatrix;
from VRGeneric	 import VREvaluate;
from ACdb_info	 import	ACset_db_info;
from VREquipment import	VRPlaceNozzleFeet;
from GRgraphics	 import	GRdisplay;
from GRvg	 import GRchgprops;
from VRCnrlSeg	 import VRChgSegState;
from VRCnrlSeg	 import VRget_terminators;

extern GRclassid OPP_VRPNozz_class_id;
extern GRclassid OPP_VREquipment_class_id;
extern GRclassid OPP_ACrg_collect_class_id;
extern GRclassid OPP_VRCnrlSeg_class_id;

extern int RTconvert();

int RTget_piping_equipment( PiEqpId, eqp_stk_numb, trans_mtx, insul_info,
			    num_ports, eqp_ports )
struct GRid	*PiEqpId;		/* I */
char		*eqp_stk_numb;		/* O */
t_matrix	*trans_mtx;		/* O */
struct insul_info      *insul_info;	/* O */
int             *num_ports;		/* O */
eqp_port	**eqp_ports;		/* O	Array of Structures */
					/* 	Memory for eqp_ports is
						allocated inside
					 	RTget_piping_equipment */
{
  IGRint status, ii, dummy = 0;
  int size, nb_byte;
  int NumbPar;
  IGRint nb_child, NbGrChild;
  IGRint jj;
  IGRlong msg;
  struct GRid DummyId;
  struct GRid *child;
  struct GRid *GrandChild;
  struct GRmd_env ModEnv;
  GRclassid ObjClass;
  GRclassid ClassId;
  IGRmatrix tmatrix;
  struct ACrg_coll AttList[5];
  static eqp_port *ports = NULL;

  if( ports )
   free( ports );

  ports = (eqp_port *)malloc( 10*sizeof(eqp_port) );


  if( ports == NULL )
  {
    printf( "No dynamic memory\n" );
    return RTERR;
  }

  /* validate & initialize variables */
  if( !PiEqpId )
   return RTERR;

  if( num_ports )
   *num_ports = 0;
  else
  {
    printf( "'num_ports' should be a valid pointer\n" );
    return RTERR;
  }

  if( eqp_stk_numb )
   eqp_stk_numb[0] = '\0';
  else
  {
    printf( "eqp_stk_numb is a NULL pointer\n" );
    return RTERR;
  }

  if( trans_mtx == NULL )
  {
    printf( "trans_mtx is a NULL pointer\n" );
    return RTERR;
  }

  if( insul_info == NULL )
  {
    printf( "insul_info is a NULL pointer\n" );
    return RTERR;
  }

  if( !eqp_ports )
  {
    printf( "'eqp_ports' should be a valid pointer\n" );
    return RTERR;
  }

  /* validate AbstractDataType/Classid */
  status = om$get_classid(
           osnum   = PiEqpId->osnum,
           objid   = PiEqpId->objid,
           p_classid = &ObjClass );
  as$status();

  if( om$is_ancestry_valid( subclassid   = ObjClass,
      superclassid = OPP_VREquipment_class_id ) != OM_S_SUCCESS )
  {
    printf( "Object should be of class VREquipment\n" );
    return RTERR;
  }


  /* get active module environment */
  size = sizeof( ModEnv );
  status =
  gr$get_module_env
  (
         msg = &msg,
         sizbuf = &size,
         buffer = &ModEnv,
         nret = &nb_byte
  );
  as$status();

  /* get equipment attributes */
  /*NumbPar = 3;
  strcpy( AttList[0].name, "eqp_family" );	* catalog name *
  strcpy( AttList[1].name, "eqp_partno" );	* part number *
  strcpy( AttList[2].name, "eqp_partrev" );	* part revision */

  NumbPar = 1;
  strcpy( AttList[0].name, "eqp_partno" );      /* part number */

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = PiEqpId,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = &ModEnv );
  as$status( action = RET_STATUS );

  if( msg&1 )
  {
    strcpy ( eqp_stk_numb, AttList[0].desc.value.att_txt );
    /*strcat ( eqp_stk_numb, "-" );

    strcat ( eqp_stk_numb, AttList[1].desc.value.att_txt );
    strcat ( eqp_stk_numb, "-" );

    strcat ( eqp_stk_numb, AttList[2].desc.value.att_txt );*/

  }

  /* Get Transformation Matrix */
  status =
  om$send( msg = message VREquipment.VRGetMatrix
                         ( &msg, dummy, &DummyId, tmatrix, &ModEnv ),
                         senderid = NULL_OBJID,
                         targetid = PiEqpId->objid,
                         targetos = PiEqpId->osnum
	 );
  as$status ( action = RET_STATUS );

  if( !( msg & 1 ) ) return RTERR;

  status = RTcon_mat( tmatrix, trans_mtx );

  /*printf( "x) %lf  %lf  %lf\n", trans_mtx->x[0], trans_mtx->x[1],
				trans_mtx->x[2] );

  printf( "y) %lf  %lf  %lf\n", trans_mtx->y[0], trans_mtx->y[1],
		                trans_mtx->y[2] );

  printf( "z) %lf  %lf  %lf\n", trans_mtx->z[0], trans_mtx->z[1],
		                trans_mtx->z[2] );

  printf( "o) %lf  %lf  %lf\n", trans_mtx->translate[0],
		        	trans_mtx->translate[1],
		      		trans_mtx->translate[2] );*/

  /* Get insulation information */
  NumbPar = 2;
  strcpy( AttList[0].name, VR_N_INSUL_TYPE_AN );
  strcpy( AttList[1].name, VR_N_INSUL_THK_DB );

  status =
   vr$review_parameters( pMsg            = &msg,
                         pComponent      = PiEqpId,
                         NbParams        = NumbPar,
                         pList           = AttList,
                         pMdEnv          = &ModEnv );
  as$status( action = RET_STATUS );

  if( msg == MSSUCC )
  {
    /* Extract insulation-type, insulation-thickness & stock-number */
    strcpy( insul_info->matl_desc,
	  AttList[0].desc.value.att_txt );

    insul_info->thickness = AttList[1].desc.value.att_exp;
  }
  else
  {
    insul_info->matl_desc[0]		= '\0';
    insul_info->thickness		= 0.0;
  }

  switch( VRenq_proj_units() )
  {
    case VR_METRIC_UNITS :
     strcpy( insul_info->thickness_units, "mm" );
     break;

    case VR_IMPERIAL_UNITS :
     strcpy( insul_info->thickness_units, "IPS" );
     break;

    case VR_MIXED_UNITS :
     strcpy( insul_info->thickness_units, "mixed" );
     break;

    default:
     strcpy( insul_info->thickness_units, "unknown" );
   }/* end switch on unit */

  /* Get list of nozzles */
  status =
  om$send( msg = message NDnode.NDget_objects
			 ( ND_CHILDREN|ND_IN_BUF, NULL, 0,
                           &child, 0, OM_K_MAXINT, &nb_child ),
                         senderid = NULL_OBJID,
                         targetid = PiEqpId->objid,
                         targetos = PiEqpId->osnum
	 );
  as$status ( action = RET_STATUS );

  for( ii=0; ii < nb_child; ii++ )
  {
    status =
    om$send( msg = message NDnode.NDget_objects
			 ( ND_CHILDREN|ND_IN_BUF, NULL, 0,
                           &GrandChild, 0, OM_K_MAXINT, &NbGrChild ),
                         senderid = NULL_OBJID,
                         targetid = child[ii].objid,
                         targetos = child[ii].osnum
	 );
    as$status ( action = RET_STATUS );

    for( jj=0; jj < NbGrChild; jj++ )
    {
      /* Find VRPNozz */
      /* get class id */
      om$get_classid( objid           = GrandChild[jj].objid,
                      osnum           = GrandChild[jj].osnum,
                      p_classid       = &ClassId );

      if( ClassId == OPP_VRPNozz_class_id )
      {
        /*printf( "Nozzle Id: %d, %d\n",
                 GrandChild[jj].objid, GrandChild[jj].osnum );*/
	*num_ports = *num_ports + 1;

        ports[jj].noz_id = GrandChild[jj];

	/* Get transformation matrix */
	status =
	om$send( msg = message VRNozzle.VRGetMatrix
			       ( &msg, dummy, (struct GRid *)NULL,
				 tmatrix, &ModEnv ),
                       senderid = NULL_OBJID,
                       targetid = GrandChild[jj].objid,
                       targetos = GrandChild[jj].osnum,
	        );
	as$status( action = RET_STATUS );

	status = RTcon_mat( tmatrix, &(ports[jj].port_orient) );

  	/*printf( "x) %lf  %lf  %lf\n", ports[jj].port_orient.x[0],
				      ports[jj].port_orient.x[1],
				      ports[jj].port_orient.x[2] );

	printf( "y) %lf  %lf  %lf\n", ports[jj].port_orient.y[0],
				      ports[jj].port_orient.y[1],
		                      ports[jj].port_orient.y[2] );

	printf( "z) %lf  %lf  %lf\n", ports[jj].port_orient.z[0],
				      ports[jj].port_orient.z[1],
		                      ports[jj].port_orient.z[2] );

	printf( "o) %lf  %lf  %lf\n", ports[jj].port_orient.translate[0],
		        	      ports[jj].port_orient.translate[1],
		      		      ports[jj].port_orient.translate[2] );*/

	ports[jj].coords[0] = ports[jj].port_orient.translate[0];
	ports[jj].coords[1] = ports[jj].port_orient.translate[1];
	ports[jj].coords[2] = ports[jj].port_orient.translate[2];

	/* not supported by i/route */
	ports[jj].p_label[0] = '\0';

      }
    }
  }


  *eqp_ports = ports;

  return RTSUCC;
}

IGRint RTcon_mat( IgrMatrix, tmatrix )
IGRdouble *IgrMatrix;	/* I */
t_matrix  *tmatrix;	/* O */
{
  IGRint ii;

  if( tmatrix == NULL || IgrMatrix == NULL )
   return MSFAIL;

  for( ii=0; ii < 3; ++ii )
  {
    tmatrix->x[ii]		= IgrMatrix[ ii*4 ];
    tmatrix->y[ii]		= IgrMatrix[ ii*4 + 1 ];
    tmatrix->z[ii]		= IgrMatrix[ ii*4 + 2 ];
    tmatrix->translate[ii]	= IgrMatrix[ ii*4 + 3 ];
  }

  return MSSUCC;
}

int RTget_piping_equip_attr( PiEqpId, num_ports, eq_portinfo,
                             catalog_name, revision_num,
                             access_env, insulation_env )
struct GRid	*PiEqpId;        /* I */
int		*num_ports;      /* O */
eq_port_info 	**eq_portinfo;   /* O */
char		*catalog_name;   /* O */
int		*revision_num;   /* O */
IGRboolean	*access_env;     /* O */
IGRboolean	*insulation_env; /* O */
{
  GRclassid ObjClass;
  GRclassid ClassId;
  int size, nb_byte;
  IGRint status;
  IGRint nb_child, NbGrChild;
  IGRint ii, jj;
  IGRint dummy = 0;
  int NumbPar;
  IGRchar LongText[40], error[30];
  struct GRmd_env ModEnv;
  IGRlong msg;
  struct GRid *child;
  struct GRid *GrandChild;
  IGRmatrix tmatrix;
  struct ACrg_coll AttList[12];
  static eq_port_info *ports = NULL;


  if( ports )
   free( ports );

  ports = (eq_port_info *)malloc( 10*sizeof(eq_port_info) );


  if( ports == NULL )
  {
    printf( "No dynamic memory\n" );
    return RTERR;
  }

  /* validate & initialize variables */
  if( !PiEqpId || !num_ports || !eq_portinfo || !catalog_name ||
      !revision_num || !access_env || !insulation_env )
    return RTERR;

  *num_ports = 0;

  /* validate AbstractDataType/Classid */
  status = om$get_classid(
           osnum   = PiEqpId->osnum,
           objid   = PiEqpId->objid,
           p_classid = &ObjClass );
  as$status();

  if( om$is_ancestry_valid( subclassid   = ObjClass,
      superclassid = OPP_VREquipment_class_id ) != OM_S_SUCCESS )
  {
    printf( "Object should be of class VREquipment\n" );
    return RTERR;
  }


  /* get active module environment */
  size = sizeof( ModEnv );
  status =
  gr$get_module_env
  (
         msg = &msg,
         sizbuf = &size,
         buffer = &ModEnv,
         nret = &nb_byte
  );
  as$status();

  /* Get list of nozzles */
  status =
  om$send( msg = message NDnode.NDget_objects
			 ( ND_CHILDREN|ND_IN_BUF, NULL, 0,
                           &child, 0, OM_K_MAXINT, &nb_child ),
                         senderid = NULL_OBJID,
                         targetid = PiEqpId->objid,
                         targetos = PiEqpId->osnum
	 );
  as$status ( action = RET_STATUS );

  for( ii=0; ii < nb_child; ii++ )
  {
    status =
    om$send( msg = message NDnode.NDget_objects
			 ( ND_CHILDREN|ND_IN_BUF, NULL, 0,
                           &GrandChild, 0, OM_K_MAXINT, &NbGrChild ),
                         senderid = NULL_OBJID,
                         targetid = child[ii].objid,
                         targetos = child[ii].osnum
	 );
    as$status ( action = RET_STATUS );

    for( jj=0; jj < NbGrChild; jj++ )
    {
      /* Find VRPNozz */
      /* get class id */
      om$get_classid( objid           = GrandChild[jj].objid,
                      osnum           = GrandChild[jj].osnum,
                      p_classid       = &ClassId );

      if( ClassId == OPP_VRPNozz_class_id )
      {
        /*printf( "Nozzle Id: %d, %d\n",
                 GrandChild[jj].objid, GrandChild[jj].osnum );*/
	*num_ports = *num_ports + 1;

	/* Get transformation matrix */
	status =
	om$send( msg = message VRNozzle.VRGetMatrix
			       ( &msg, dummy, (struct GRid *)NULL,
				 tmatrix, &ModEnv ),
                       senderid = NULL_OBJID,
                       targetid = GrandChild[jj].objid,
                       targetos = GrandChild[jj].osnum,
	        );
	as$status( action = RET_STATUS );

	status = RTcon_mat( tmatrix, &(ports[jj].port_orient) );

  	/*printf( "x) %lf  %lf  %lf\n", ports[jj].port_orient.x[0],
				      ports[jj].port_orient.x[1],
				      ports[jj].port_orient.x[2] );

	printf( "y) %lf  %lf  %lf\n", ports[jj].port_orient.y[0],
				      ports[jj].port_orient.y[1],
		                      ports[jj].port_orient.y[2] );

	printf( "z) %lf  %lf  %lf\n", ports[jj].port_orient.z[0],
				      ports[jj].port_orient.z[1],
		                      ports[jj].port_orient.z[2] );

	printf( "o) %lf  %lf  %lf\n", ports[jj].port_orient.translate[0],
		        	      ports[jj].port_orient.translate[1],
		      		      ports[jj].port_orient.translate[2] );*/

	ports[jj].cp_coord[0] = ports[jj].port_orient.translate[0];
	ports[jj].cp_coord[1] = ports[jj].port_orient.translate[1];
	ports[jj].cp_coord[2] = ports[jj].port_orient.translate[2];

	/* not supported by i/route */
	ports[jj].label[0] = '\0';

	/* get nozzle attributes */
	NumbPar = 4;

	strcpy( AttList[0].name, VR_N_GDIAMETER_DB );   /* npd green */
	strcpy( AttList[1].name, VR_N_PREP_G_IN );	/* end prp g */
	strcpy( AttList[2].name, VR_N_SCH_THK_G_AN );   /* sched. thickness g */
	strcpy( AttList[3].name, VR_N_RATING_G_DB );    /* pres. rating g */

	status =
	vr$review_parameters( pMsg            = &msg,
                              pComponent      = &GrandChild[jj],
                              NbParams        = NumbPar,
                              pList           = AttList,
                              pMdEnv          = &ModEnv );
	as$status( action = RET_STATUS );

	ports[jj].nom_pipe_size = AttList[0].desc.value.att_exp;
	strcpy( ports[jj].wall_thickness, AttList[2].desc.value.att_txt );
	ports[jj].pressure_ratings = AttList[3].desc.value.att_exp;

	/* get code listed attribute */
	LongText[0] = NULL;
	status = vd$get_alias( p_msg = &msg,
        product = PIPING,
        type = VR_P_END_COND_LSTNUM,
        i_code = (int)AttList[1].desc.value.att_exp,
        o_lname = LongText,
        p_error = error );

	strcpy( ports[jj].port_end_prep, LongText );

	switch( VRenq_proj_units() )
	{
	  case VR_METRIC_UNITS :
	   strcpy( ports[jj].nom_pipe_size_type, "mm" );
	   ports[jj].pressure_rating_unit = RT_kpa;
	   break;

	  case VR_IMPERIAL_UNITS :
	   strcpy( ports[jj].nom_pipe_size_type, "IPS" );
	   ports[jj].pressure_rating_unit = RT_psi;
	   break;

	  case VR_MIXED_UNITS :
	   strcpy( ports[jj].nom_pipe_size_type, "mixed" );
	   ports[jj].pressure_rating_unit = -1;
	   break;

	  default:
	   strcpy( ports[jj].nom_pipe_size_type, "unknown" );
	   ports[jj].pressure_rating_unit = -1;
	}/* end switch on unit */
      }
    }
  }

  *eq_portinfo = ports;
  /* get equipment attributes */
  NumbPar = 2;
  strcpy( AttList[0].name, "eqp_family" );	/* catalog name */
  strcpy( AttList[1].name, "eqp_partrev" );	/* part revision */

  status =
  vr$review_parameters( pMsg            = &msg,
                        pComponent      = PiEqpId,
                        NbParams        = NumbPar,
                        pList           = AttList,
                        pMdEnv          = &ModEnv );
  as$status( action = RET_STATUS );

  strcpy( catalog_name, AttList[0].desc.value.att_txt );
  strcpy( revision_num, AttList[1].desc.value.att_txt );

  return RTSUCC;
}

int RT_put_equipment( equip_spec, sys_name, matrix, iinfo, route_id, numb_noz,
		      noz_ids )
e_spec		equip_spec;	/* I */
char		*sys_name;	/* I */
t_matrix	matrix;		/* I */
struct insul_info *iinfo;	/* I */
struct GRid	*route_id;	/* O */
int		*numb_noz;	/* O */
struct GRid	**noz_ids;	/* O */
{
  struct GRmd_env ModEnv;
  IGRlong msg;
  int size, nb_byte;
  IGRint status = OM_S_SUCCESS;
  IGRint NbMissingTemp = 0;
  IGRint jj;
  GRclassid CompClass;
  struct GRid SysParamId, UsrParamId, MissParamId;
  struct GRid CmpId;
  struct GRsymbology symb;
  struct ACrg_coll *p_MissingParamsList;
  struct ACrg_coll Collection[7];
  /*struct VRdbEquipPart Part;*/
  IGRchar macro_lib[100];
  struct ACdb_info DbInfo;
  IGRmatrix IgrMatrix;
  static struct GRid *nozzles = NULL;
  GRclassid ObjClass;
  enum GRdpmode EraMode;

  if( nozzles )
   free( nozzles );

  nozzles = (struct GRid *)malloc( 20*sizeof(struct GRid) );


  if( nozzles == NULL )
  {
    printf( "No dynamic memory\n" );
    return RTERR;
  }

  /* get active module environment */
  size = sizeof( ModEnv );
  status =
  gr$get_module_env
  (
         msg = &msg,
         sizbuf = &size,
         buffer = &ModEnv,
         nret = &nb_byte
  );
  as$status();

  /* initailize */
  *numb_noz = 0;
  *noz_ids = NULL;

  CompClass = OPP_VREquipment_class_id;

  SysParamId.objid = NULL_OBJID;
  SysParamId.osnum = ModEnv.md_id.osnum;

  UsrParamId.objid = NULL_OBJID;
  UsrParamId.osnum = ModEnv.md_id.osnum;

  MissParamId.objid = NULL_OBJID;
  MissParamId.osnum = ModEnv.md_id.osnum;

  CmpId.objid = NULL_OBJID;
  CmpId.osnum = ModEnv.md_id.osnum;

  SysParamId.osnum = ModEnv.md_id.osnum;

  /*| ----- Initialize Sys Collection ----- */
  status =
  om$construct( classid = OPP_ACrg_collect_class_id,
                p_objid = &SysParamId.objid,
                osnum   = SysParamId.osnum,
                msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
  as$status( action = RET_STATUS );

  /*| ----- Initialize Usr Collection ----- */
  status =
  om$construct( classid = OPP_ACrg_collect_class_id,
                p_objid = &UsrParamId.objid,
                osnum   = UsrParamId.osnum,
                msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
  as$status( action = RET_STATUS );

  symb.display_attr.color	= 1;
  symb.display_attr.weight	= 0;
  symb.display_attr.style	= 0;
  symb.level			= 1;

  /*"EquipNumber = <%s> \n",equip_spec.part_num*/
  /*"CmpId         = %d %d \n",CmpId.objid, CmpId.osnum*/
  /*"UsrParamId    = %d %d \n",UsrParamId.objid, UsrParamId.osnum*/
  /*"SysParamId    = %d %d \n",SysParamId.objid, SysParamId.osnum*/
  /*"MissParamId = %d %d \n",MissParamId.objid, MissParamId.osnum*/
  /*"color         = %d\n", symb.display_attr.color*/
  /*"weight        = %d\n", symb.display_attr.weight*/
  /*"style         = %d\n", symb.display_attr.style*/
  /*"level         = %d\n", symb.level*/

  /*status = VRdbGetEqOccur( &msg, "equip_list", equip_spec.part_num,
				 	NULL, &Part, NULL );
    we wouldn't want our code to dependend on EquipNo

  if( !status&1 )
   return RTERR;

  VDSget_eqp_library( Part.Familly, macro_lib );

  status = ac$construct_path( mode    = AC_ADD_PATH | AC_INQ,
			      name    = macro_lib );
  as$status();
	
  strcpy( Collection[0].name, VR_N_MACRO_NAME_AN );
  Collection[0].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[0].desc.value.att_txt, Part.Familly );

  strcpy( Collection[1].name,"eqp_family" );
  Collection[1].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[1].desc.value.att_txt, Part.Familly );

  strcpy( Collection[2].name, "eqp_partno" );
  Collection[2].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[2].desc.value.att_txt, Part.PartNb );

  strcpy( Collection[3].name, "eqp_partrev" );
  Collection[3].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[3].desc.value.att_txt, Part.PartRev );*/

  VDSget_eqp_library( equip_spec.catalog_name, macro_lib );

  status = ac$construct_path( mode    = AC_ADD_PATH | AC_INQ,
			      name    = macro_lib );
  as$status();
	
  strcpy( Collection[0].name, VR_N_MACRO_NAME_AN );
  Collection[0].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[0].desc.value.att_txt, equip_spec.catalog_name );

  strcpy( Collection[1].name,"eqp_family" );
  Collection[1].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[1].desc.value.att_txt, equip_spec.catalog_name );

  strcpy( Collection[2].name, "eqp_partno" );
  Collection[2].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[2].desc.value.att_txt, equip_spec.part_num );

  strcpy( Collection[3].name, "eqp_partrev" );
  Collection[3].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[3].desc.value.att_txt, equip_spec.revision );

  strcpy( Collection[4].name, VR_N_INSUL_TYPE_AN );
  Collection[4].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[4].desc.value.att_txt, iinfo->matl_desc );

  strcpy( Collection[5].name, VR_N_INSUL_THK_DB );
  Collection[5].desc.type = AC_ATTRIB_DOUBLE;
  Collection[5].desc.value.att_exp = (IGRdouble)(iinfo->thickness );

  strcpy( Collection[6].name, VR_N_SYST_NAME_AN );
  Collection[6].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[6].desc.value.att_txt, sys_name );

  status =
  VR$ModifyCollection( p_msg			= &msg,
		       Operation		= VR_MERGE_COLL,
		       p_ParamsListToModify	= Collection,
		       NbParamsToModify		= 7,
		       p_OutputCollectionId	= &SysParamId );

  NbMissingTemp = 0;
  status = VREvaluateEquip(     &msg,
                                equip_spec.part_num,
                                &symb,
                                AC_3D_REP,
                                &SysParamId,
                                &UsrParamId,
                                &MissParamId,
                                &CmpId,
                                &NbMissingTemp,
				&p_MissingParamsList,
                                &ModEnv );

  /*"EquipNumber = <%s> \n",equip_spec.part_num*/
  /*"CmpId         = %d %d \n",CmpId.objid, CmpId.osnum*/
  /*"UsrParamId    = %d %d \n",UsrParamId.objid, UsrParamId.osnum*/
  /*"SysParamId    = %d %d \n",SysParamId.objid, SysParamId.osnum*/
  /*"MissParamId = %d %d \n",MissParamId.objid, MissParamId.osnum*/
  /*"NbMissing     = %d \n", NbMissingTemp*/

  if( !(status&0x01) || !(msg&0x01) )
  {
    printf( "Error in VREvaluate\n" );
    return RTERR;
  }

  /* EQUIP object */
  DbInfo.quantity = EQUIPMENT_OBJ;

  status =
  om$send( msg = message ACdb_info.ACset_db_info( &msg, &DbInfo),
           senderid = NULL_OBJID,
           targetid = CmpId.objid,
           targetos = CmpId.osnum );
  as$status();

  EraMode = GRbehe;
  /* erase equipment */
  status =
  om$send( msg      = message GRgraphics.GRdisplay(
	   &msg, 
	   &ModEnv.md_env.matrix_type,
	   ModEnv.md_env.matrix, 
	   &EraMode, 
	   &ModEnv.md_id ),
  senderid = NULL_OBJID,
  targetid = CmpId.objid,
  targetos = CmpId.osnum );
  as$status();

  status = RTconvert( IgrMatrix, &matrix );

  if( status == RTERR )
   return status;

  status = VR$OrientComp( p_retmsg = &msg,
                          p_CmpId  = &CmpId,
                          Matrix   = IgrMatrix,
                          p_MdEnv  = &ModEnv );


  if( !(status&1&msg) )
   return RTERR;

  if( CmpId.objid != NULL_OBJID )
  {
    IGRint i, NbNozzle = 0;
    enum GRdpmode Mode;
    struct GRid	NozzleIds[20];

    Mode = GRbd;

    for( i=0; i<20; i++ ) 
    {
      NozzleIds[i].objid = NULL_OBJID;
      NozzleIds[i].osnum = ModEnv.md_id.osnum;
    }

    status =
    om$send( msg 	   = message VREquipment.VRPlaceNozzleFeet(
				     &msg, &NbNozzle, NozzleIds,
				     &ModEnv ),
    senderid = NULL_OBJID,
    targetid = CmpId.objid,
    targetos = CmpId.osnum );
    as$status( );

    /* display equipment */
    status =
    om$send( msg      = message GRgraphics.GRdisplay(
				&msg, 
				&ModEnv.md_env.matrix_type,
				ModEnv.md_env.matrix, 
				&Mode, 
				&ModEnv.md_id ),
    senderid = NULL_OBJID,
    targetid = CmpId.objid,
    targetos = CmpId.osnum );
    as$status();

    /*"NbNozzle = %d\n",NbNozzle*/

    for( i=1, jj=0; i <= NbNozzle; i++ )
    {
      /*"NozzleIds[%d] = %d\n",i,NozzleIds[i].objid*/
      if( NozzleIds[i].objid != NULL_OBJID )
      {
  	/* Select piping nozzles */
	status = om$get_classid(
			osnum   = NozzleIds[i].osnum,
			objid   = NozzleIds[i].objid,
			p_classid = &ObjClass );
	as$status();

	if( om$is_ancestry_valid( subclassid   = ObjClass,
	    superclassid = OPP_VRPNozz_class_id ) == OM_S_SUCCESS )
	{
	  nozzles[jj] = NozzleIds[i];
	  jj++;
	  *numb_noz = *numb_noz + 1;
	}

	status =
	om$send( msg      = message GRgraphics.GRdisplay(
				    &msg, 
				    &ModEnv.md_env.matrix_type,
				    ModEnv.md_env.matrix, 
				    &Mode, 
				    &ModEnv.md_id ),
        senderid = NULL_OBJID,
	targetid = NozzleIds[i].objid, 
	targetos = NozzleIds[i].osnum );
  	as$status();
      }
    }
    *noz_ids = nozzles;
    *route_id = CmpId;
  }

  return RTSUCC;
}

int RtChangeProp( SegmentId )
struct GRid *SegmentId;		/* I */
{
   IGRshort action, mask;
   IGRlong msg;
   IGRlong status;
   IGRboolean EvalConst;		/* to set segment-state */

   /* update Cnrl Seg state */
   mask   = GRIS_LOCATABLE;
   action = 1;
   status = om$send( msg      = message GRvg.GRchgprops(&msg,&action,&mask),
		     senderid = NULL_OBJID,
                     targetid = SegmentId->objid,
                     targetos = SegmentId->osnum );
   as$status( action = RET_STATUS );

   EvalConst = TRUE;
   status = om$send( msg      = message VRCnrlSeg.VRChgSegState( VR_UNKNOWN,
                                                         VR_EVALUATE_CONST ),
		     senderid = NULL_OBJID,
                     targetid = SegmentId->objid,
                     targetos = SegmentId->osnum );
   as$status( action = RET_STATUS );

  return MSSUCC;
}

/* Should be called only for those components which have only one
   control segment as a parent. Eg. End Components. */

int RtGetSegment( CompId, SegmentId )
struct GRid *CompId;		/* I */
struct GRid *SegmentId;		/* O */
{
  struct GRid *parent;
  IGRint nb_parent, ii;
  IGRint status;
  GRclassid ObjClass;

  /* initialize segment id */
  SegmentId->objid = NULL_OBJID;
  SegmentId->osnum = OM_Gw_current_OS;

  /* Get the list of parents */
  status =
  om$send( msg = message NDnode.NDget_objects
                         ( ND_ROOT | ND_IN_BUF, NULL, 0,
                           &parent, 0, OM_K_MAXINT, &nb_parent ),
                           senderid = NULL_OBJID,
                           targetid = CompId->objid,
                           targetos = CompId->osnum );
  as$status ( action = RET_STATUS );

  for( ii=0; ii < nb_parent; ii++ )
  {
    /* validate AbstractDataType/Classid */
    status = om$get_classid(
           osnum   = parent[ii].osnum,
           objid   = parent[ii].objid,
           p_classid = &ObjClass );
    as$status();

    if( om$is_ancestry_valid( subclassid   = ObjClass,
        superclassid = OPP_VRCnrlSeg_class_id ) == OM_S_SUCCESS )
    {
      *SegmentId = parent[ii];
      break;
    }
  }

  return MSSUCC;
}


int RtSharePlanes( PrevSegId, SegmentId, pModEnv )
struct GRid *PrevSegId;		/* I */
struct GRid *SegmentId;		/* I */
struct GRmd_env *pModEnv;	/* I */
{
  struct GRid  SrcPlanesId[8];	/* list of initial planes */
  struct GRid  NewPlanesId[16];	/* planes parents of CnrlSegs */
  IGRint nb_father;		/* used by get_planes message */
  IGRint NextIndex;		/* index of end plane */
  IGRint FirstIndex;		/* index of end plane */
  IGRint ConcFlag = 0;
  IGRboolean flag = FALSE;	/* used by def_planes function */
  IGRlong status, retcode;
  IGRdouble cmp_pt[6];

  /* Get previous segment's end points. */
  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
       	             	     ( &retcode, NULL, pModEnv, cmp_pt, NULL ),
                    senderid = NULL_OBJID,
                    targetid = PrevSegId->objid,
       	            targetos = PrevSegId->osnum );
  as$status( action = RET_STATUS );

  /* get all needed information to share planes */

  /*| get planes */
  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, &SrcPlanesId[4], 4, NULL, 0,
                                 OM_K_MAXINT, &nb_father ),
                    senderid = NULL_OBJID,
                    targetid = SegmentId->objid,
                    targetos = SegmentId->osnum );
  as$status ( action = RET_STATUS );

  NextIndex = 7;

  /* get previous segment's source planes */
  status = om$send( msg = message NDnode.NDget_objects
                          ( ND_ROOT, SrcPlanesId, 4, NULL, 0, OM_K_MAXINT,
                            &nb_father ),
                    senderid = NULL_OBJID,
                    targetid = PrevSegId->objid,
                    targetos = PrevSegId->osnum );
  as$status ( action = RET_STATUS );

  FirstIndex = 3;	/* end plane of previous segment */

  /* update src list to call def_planes */
  SrcPlanesId[0] = SrcPlanesId[FirstIndex];

  SrcPlanesId[3] = SrcPlanesId[NextIndex]; /* end plane of segement */
  SrcPlanesId[4] = SrcPlanesId[5];
  SrcPlanesId[5] = SrcPlanesId[6];

  ConcFlag = 0;

  status = VR$DefineSegPlanes(        p_retmsg        = &retcode,
                                      TopoFlag        = VR_PLANES_PLANES,
                                      p_InPutPlanes   = SrcPlanesId,
                                      p_SegmentPt0    = &cmp_pt[0],
                                      p_SegmentPt1    = &cmp_pt[3],
                                      SharePlanes     = flag,
                                      InPutPlanesType = ConcFlag,
                                      p_MdEnv         = pModEnv,
                                      p_OutPutPlanes  = NewPlanesId );
   as$status ( action = RET_STATUS );

   /* connect dependents of SrcPlanes to NewPlanes */
   status = VRskUpdateConnection( SrcPlanesId, NewPlanesId, 6 );
   as$status ( action = RET_STATUS );

  return MSSUCC;
}

end implementation Root;
