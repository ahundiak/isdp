/* $Id: VRinterf.I,v 1.1.1.1 2001/01/04 21:12:51 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrflow / VRinterf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRinterf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
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
# Revision 1.7  1996/06/10  18:50:12  pinnacle
# Replaced: vrflow/VRinterf.I for:  by hverstee for route240
#
# Revision 1.6  1996/05/14  20:59:34  pinnacle
# Replaced: vrflow/VRinterf.I for:  by ashankar for route240
#
# Revision 1.5  1996/03/13  22:30:18  pinnacle
# Replaced: vrflow/VRinterf.I for:  by hverstee for route240
#
# Revision 1.4  1996/02/21  16:51:28  pinnacle
# Replaced: vrflow/VRinterf.I for:  by r240_int for route240
#
# Revision 1.3  1996/02/20  13:51:10  pinnacle
# Replaced: vrflow/VRinterf.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/16  23:55:50  pinnacle
# Replaced: vrflow/VRinterf.I for:  by r240_int for route240
#
 *
 * History:
 *	28-Oct-91    Bruno	1.4.3.6	
 *				-The function VRget_deduct_inst has been removed
 *					since it was never called.
 *				- In VRget_resinfo, the MAX_VELOC parameter is
 *					obtained by querying the component 
 *					itself instead of its system 
 *					parameters box.
 *				- In VRstore_flow, remove part of code 
 *					computing and storing the equivalent 
 *					diameter in the component system 
 *					parameter box.Part of this code 
 *					(storage ) has been temporary moved 
 *					to the VRflow.I file, in a function 
 *					called VRupdate_diam.
 *				 	VRstore_flow now stores also the flow 
 *					in the parameters box.
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *************************************************************************/

class implementation ASnode;

#include <stdio.h>
#include "OMerrordef.h"
#include "GMerrordef.h"
#include "GM.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "VRsize.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRattr_def.h"
#include "VRparamdef.h"
#include "VRstructs.h"
#include "madef.h"
#include "HV_param.h"
#include "VRpriv_attr.h"
#include "GMndg.h"
#include "VRprivmacros.h"
#include "VRDbParamDef.h"
#include "vrtools_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define MY_DEBUG
*/
#define MAX_SEP  50           /* Maximum length for a separator in the file   */

from VRGeneric
  import
  VRGetCptProp,
  VRGetFlow,
  VRSetFlow,
  VRGetCompDesc;

extern GRclassid OPP_VRNozzle_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                 VRret_database                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRret_database(filename_a, p_data_list)

  char          *filename_a;  /* IN       Name of the ASCII file              */
  struct GMlist *p_data_list; /* IN/OUT   List containing the data            */
  /*
  Description : Fill the list data_list with the file file_name_a
  Constraint  : The list must be activated before
  */
  /*.VRret_database */  
  {
  int  status= GM_S_SUCCESS; /* Status returned by the om                     */
  FILE         *file_unit;   /* Text file unit                                */
  struct COdatab_hvac data;  /* Data from the simulated data base             */
 
  /*" Open the file %s\n",filename_a*/

  file_unit = (FILE *)fopen(filename_a,"r");
  if(!file_unit){status=GM_F_BAD_FUNCT_ARG;gm$status();}
 
  while(fscanf(file_unit,"%d %lf %lf %lf",&data.shape,
    &data.equiv_diam, &data.width, &data.depth) != EOF)
    {
    /*" Load %d %lf %lf %lf\n",data.shape,data.equiv_diam,data.width,data.depth*/

    status = GMl_add(&data,p_data_list);
    gm$status();
  }/* end while(fscanf)*/

exception:
  if(file_unit) fclose(file_unit);
  return (status);
}/* end VRret_database */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         function VRget_resinfo                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRget_resinfo( p_object, cpt_ind, p_md_env, p_resinfo, call_wrt_equa )

  struct GRid       *p_object; /* IN     Object to inquire                    */
  short             cpt_ind;   /* IN     Index of the connection point        */
  struct GRmd_env   *p_md_env; /* IN     Pointer to the module environment    */
  struct VRres_info *p_resinfo;/* OUT    Pointer to the resizing info         */
  IGRboolean	    *call_wrt_equa; /* OUT */

  /*.VRget_resinfo*/
  /*
  Description : Get the information for the resizing method from an object on
                a connect point: shape, flow, max velocity.
  Constraint  : None
  */ 
  {
  long            msg;         /* Status returned by a message                */
  int             status;      /* Status returned by the om                   */
  struct VRcp_attr attr;       /* Attributes to get form the connect point    */
  double          value;       /* Value of the flow in a connection point     */
  int    foot_ind = -1;        /* Foot index                                  */
  IGRshort       direct;       /* Direction of the flow                       */
  struct ret_struct param;     /* Parameter returned for this value           */

 /*" Get the values of %d.%d at index %d\n",p_object->objid,p_object->osnum,cpt_ind*/

  *call_wrt_equa = TRUE;

  status = om$send
             (msg = message VRGeneric.VRGetCptProp(&msg,cpt_ind,&attr,p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
  gm$status();

  if( !( msg & 1 ) )
  {
    IGRlong	retcode;
    union	VRparam_attr	Params;

    /*| VRGetCptProp failed ==> get param from the parameter box */

    VR$GetDimensionAttributes
       		( p_retmsg		= &retcode,
	 	  Product		= VR_HVAC,
	 	  p_ComponentId		= p_object,
	 	  p_DimAttributes	= &Params,
	 	  p_MdEnv		= p_md_env );
    gm$status();

    p_resinfo->shape = Params.hvac_attr.shape;
    p_resinfo->W_D   = Params.hvac_attr.G_width/Params.hvac_attr.G_depth;

    *call_wrt_equa = FALSE;
  }
  else
  {
    p_resinfo->shape = attr.section_mask & VR_SHAPE;
    p_resinfo->W_D   = attr.width/attr.depth;
  }

  /* -- Get Flow -- */
  status = om$send
             (msg      = message VRGeneric.VRGetFlow
             (&msg, cpt_ind, &direct, &value, p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)) );
  p_resinfo->air_flow = value;

  /* -- Get Max Velocity -- */
  status = om$send
             (msg      = message NDmacro.ACgive_structure
                     ((int *)&msg, &foot_ind, VR_N_MAX_VELOC_DB, &param, p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)) );

  p_resinfo->max_veloc =  param.var.root_pm_st.value;

  /* -- Get Max Depth -- */
  status = om$send
             (msg      = message NDmacro.ACgive_structure
                     ((int *)&msg, &foot_ind, VR_N_MAX_DEPTH_DB, &param, p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)) );

  p_resinfo->max_depth =  param.var.root_pm_st.value;

#ifdef MY_DEBUG
   printf (" resinfo %d %d on cpt %d\n",
          p_object->objid,p_object->osnum,cpt_ind);

  printf (" max velocity = %lf\n",p_resinfo->max_veloc);
  printf (" max depth    = %lf\n",p_resinfo->max_depth);
  printf (" air flow     = %lf\n",p_resinfo->air_flow);
  printf (" shape        = %d\n",p_resinfo->shape);
  printf (" W_D          = %f\n",p_resinfo->W_D);
#endif

exception:
  return(status);

}/* VRget_resinfo */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function VRis_outlet                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRis_outlet(p_object, p_md_env, p_resp)
  
  struct GRid       *p_object; /* IN     Object to test                       */
  struct GRmd_env   *p_md_env; /* IN     Pointer to the module environment    */
  int               *p_resp;   /* OUT    Response of the function             */
  /*.VRis_outlet*/
  {
  /*
  Description : Test if the object is an outlet
  Note : THIS FUNCTION IS A KLUDGE TO AVOID HVAC CAVEATS (TO REMOVE ASAP)
  */
  long             msg;        /* Status returned by a message                */
  int              status;     /* Status returned by the om                   */
  struct ACrg_coll attr;       /* Attributes to get from the composant        */
  IGRint           mask;       /* Mask containing the type of element         */
  GRclassid        obj_class;
  IGRchar          string[100];

  status = om$get_classid(objid = p_object->objid,
				osnum = p_object->osnum,
				p_classid = &obj_class);
  gm$status();

  if( (status & OM_S_SUCCESS) &&
       ( om$is_ancestry_valid
             (subclassid = obj_class,
             superclassid = OPP_VRNozzle_class_id ) == OM_S_SUCCESS ) )
  {
	
      strcpy(attr.name,VR_N_SERVICE_AN );
      VRReviewParameters( &msg, p_object, 1, &attr, p_md_env );

      strcpy( string, attr.desc.value.att_txt );

      if( ( !strcmp( string, "INLET" ) ) || ( ! strcmp ( string, "SUPPLY" ) ) )
  	*p_resp = 0;
      else
  	*p_resp = 1;

      return OM_S_SUCCESS;
  }

  strcpy(attr.name,VR_N_COMP_TOPO_IN);
  status = om$send
             (msg      = message VRGeneric.VRGetCompDesc(&msg, &attr, p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum );
  gm$status();
  mask = (IGRint) attr.desc.value.att_exp;
  *p_resp = (mask == VRH_V_OLET_TOPO);

exception:
  return(status);

}/* end VRis_outlet */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           function VRstore_flow                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRstore_flow(p_md_env, index, p_direct, p_flow, p_object)
  
  struct GRmd_env   *p_md_env; /* IN     Pointer to the module environment    */
  IGRshort          index;     /* IN     Connect point index                  */
  IGRshort          *p_direct; /* IN     Direction of the flow                */
  double            *p_flow;   /* IN     Value of the flow                    */
  struct GRid       *p_object; /* IN     Object to update                     */
  /*.VRstore_flow*/
  {
  /*
  Description : Store the flow for an element, and update the equivalent
                diameter.
  Note : This is a function to avoid duplicating the code for the kludgy 
         outlets.
  */
  long           msg;          /* Status returned by a message                */
  int            status;       /* Status returned by the om                   */

  /*" Store the flow: %lf in the object %d.%d\n",*p_flow,p_object->objid,p_object->osnum*/
  /*"                 at cpt_%d , direction %d\n", index, *p_direct */
  status = om$send
             (msg      = message VRGeneric.VRSetFlow
             (&msg, index, p_direct, p_flow,p_md_env),
              senderid = NULL_OBJID,
              targetid = p_object->objid,
              targetos = p_object->osnum);
  gm$status(test = !((status&1)&&(msg&1)) );

   /* KLUDGE : when storing the flow in the component, store it also in its parameters box */
  {
	  struct ACrg_coll fl_attr;   /* Flow attribute                               */
	  /*" Store the value %lf\n"*/

	  strcpy(fl_attr.name,VR_N_FLOW_RATE_DB);
	  fl_attr.desc.type = AC_ATTRIB_DOUBLE;
	  fl_attr.desc.value.att_exp = *p_flow;
	  status = VRChgCmpAttr(&msg,&fl_attr,p_object,p_md_env);

  }/* end kludge store flow */

exception:
  return(status);
}/* end VRstore_flow */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASnode;

