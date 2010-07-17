class implementation VLedge2Datt;

#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "VDmem.h"
#include "vledgeattr.h"
/*
#define vsDEBUG 1
#define vserrDEBUG 1
*/
#include "vldbgmacros.h"

from ACrg_collect	import 	AClist_attribute;

/******************************************************************************

  Overridden Message
        VDgetParameters from VDSroot

  Abstract
        Returns the list of all parameters for the object.

  Arguments
        IGRlong           *msg      O      Completion code.
        IGRint            *nbParams O      Number of parameters
        struct ACrg_coll  **parList O      List of parameters
        struct GRmd_env   *md_env   I      Module environment of object

  Notes/Remarks
        - nbParams is the total number of parameters for the object : 0 or more.
        - Memory will be allocated for the list of ACrg_coll structures
          in the method implementation.  Needs to be freed by the caller.
        - IMPORTANT NOTE : the names of the parameters must be the complete
          --------------
          names (for eg : stat_attr:macro_name, or attributes:op_pres )

  Status/Return Code
        OM_S_SUCCESS    : if success
        OM_E_NODYNMEM   : not enough dynamic memory available
        OM_W_ABORT      : if some other error
*******************************************************************************/

method VDgetParameters(        IGRlong                 *msg;
                               IGRint                  *nbParams;
                               struct ACrg_coll        **parList;
                               struct GRmd_env         *md_env )
{
  IGRlong 		sts;
  IGRint		i=0, loc_sts, nb_attr=0;
  struct GRid 		my_grid, edge_3d, attr_col;
  struct ACrg_coll 	list_att[ATT_NB_ATT];

  SetProc( VLedge2Datt_VDgetParameters ); Begin
  /* Check the input arguments */
  if ( !msg || !md_env ) return OM_E_INVARG;
  __DBGpr_me();

  /* Initialization      */
  sts             = OM_S_SUCCESS;
  *msg            = MSSUCC;
  *nbParams       = 0;
  *parList        = NULL;
  my_grid.objid   = my_id;
  my_grid.osnum   = OM_Gw_current_OS;

  sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, 0, &edge_3d),
             	targetid = my_id );
  __CheckRC( sts, loc_sts, "Finding 3-D edge", wrapup );
  __DBGpr_obj( "3-D edge macro : ", edge_3d );

  sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, 2, &attr_col),
                targetid = edge_3d.objid,
		targetos = edge_3d.osnum  );
  __CheckRC( sts, loc_sts, "Finding the attr collection", wrapup );
  __DBGpr_obj( "Edge attr collection : ", attr_col );

  /* find attributes */
  sts = om$send(msg = message ACrg_collect.AClist_attribute
                              ( msg, ATT_NB_ATT, list_att,&nb_attr ),
                       targetid = attr_col.objid,
                       targetos = attr_col.osnum);
  __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

  /* Set the number of total parameters      */
  *nbParams = nb_attr;
  __DBGpr_int(" NbParams  ", *nbParams );

  /* Allocate the memory for collection  */
  *parList = _MALLOC (*nbParams, struct ACrg_coll);
  if ( !*parList )
  {
     printf( "VDgetParameters:Could not allocate dynamic memory\n");
     sts = OM_E_NODYNMEM;
     goto wrapup;
  }

  if( nb_attr>0 )
  {
     for( i=0; i<nb_attr; ++i )      (*parList)[i] = list_att[i];
  }

  *msg = MSSUCC;
  sts  = OM_S_SUCCESS;

wrapup:
  End
  return sts;

}


/******************************************************************************

  Overridden Message
        VDreviewParameters from VDSroot

  Abstract
        Returns the types and values of the parameters specified in the parList
        filled in by the caller.

  Arguments
        IGRlong           *msg        O      Completion code.
        IGRint            nbParams    I      Number of parameters initialized
                                             in the list
        struct ACrg_coll  *parList   I/O     List of parameters
                                                Input  : names of parameters
                                                Output : types and values
        struct GRmd_env   *md_env     I      Module environment of object

  Notes/Remarks
        msg = MSFAIL,   when any one of the parameters is not valid for the
                        object. However other parameter values are output.
                        Type for invalid parameters is set to
                        AC_ATTRIB_TYPE_NOT_DEF.

  Status/Return Code
        OM_S_SUCCESS    : if success (*msg may be MSFAIL)
        OM_W_ABORT      : if some other error

*******************************************************************************/

method  VDreviewParameters(     IGRlong                 *msg;
                                IGRint                  nb_params;
                                struct ACrg_coll        *parlist;
                                struct GRmd_env         *md_env )
{
  IGRlong sts;
  IGRint loc_sts, i=0, index=-1;
  struct ret_struct    attr_rs;
  struct GRid my_grid, edge_3d, attr_col;
  SetProc( VLedge2Datt_VDreviewParameters ); Begin
  /* Check the input arguments */
  if ( !msg || !nb_params || !parlist || !md_env ) return OM_E_INVARG;
  __DBGpr_me();

  /* Initialization */
  *msg  	  = MSSUCC;
  sts   	  = OM_S_SUCCESS;
  my_grid.objid   = my_id;
  my_grid.osnum   = OM_Gw_current_OS;

  sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, 0, &edge_3d),
             	targetid = my_id );
  __CheckRC( sts, loc_sts, "Finding 3-D edge", wrapup );
  __DBGpr_obj( "3-D edge macro : ", edge_3d );

  sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, 2, &attr_col),
                targetid = edge_3d.objid,
		targetos = edge_3d.osnum  );
  __CheckRC( sts, loc_sts, "Finding the attr collection", wrapup );
  __DBGpr_obj( "Edge attr collection : ", attr_col );

  for( i=0; i<nb_params; ++i )
        parlist[i].desc.type     = AC_ATTRIB_TYPE_NOT_DEF;

  for ( i=0; i<nb_params; i++ )
  {
     /* if attribute value already found, go to next one */

     if( parlist[i].desc.type != AC_ATTRIB_TYPE_NOT_DEF ) continue;

     sts = om$send ( msg = message NDmacro.ACgive_structure
                                         ( &loc_sts, &index,
                                         parlist[i].name, &attr_rs, md_env ),
                               targetid = attr_col.objid,
                               targetos = attr_col.osnum );
     if( sts & loc_sts & 1 )
     {
        /* Parameter exists and it has the right type */
        /* Put value in the array */

        if ( attr_rs.type == double_type )
        {
           parlist[i].desc.type          = AC_ATTRIB_DOUBLE;
           parlist[i].desc.value.att_exp = attr_rs.var.root_pm_st.value;
       	}
        else if ( attr_rs.type == text_type )
        {
           parlist[i].desc.type     = AC_ATTRIB_TEXT;
           strcpy (parlist[i].desc.value.att_txt ,
                                        attr_rs.var.text_st.text_string) ;
        }
     }/* end get parameter succeeded */
  }

  *msg = MSSUCC;
  sts  = OM_S_SUCCESS;

wrapup:
  End
  return sts;

}

end implementation VLedge2Datt;
