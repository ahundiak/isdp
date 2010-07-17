/* $Id: VSedgetparam.I,v 1.1.1.1 2001/01/04 21:10:35 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsedge/VSedgetparam.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSedgetparam.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/05/18  19:17:24  pinnacle
# TR_179900603
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/31  14:33:46  pinnacle
# Update include list
#
 *
 * History:
 *      MM/DD/YY        AUTHOR	DESCRIPTION
 *      10/31/97        ah      added header
 *      05/17/99        ejm     Added ACcheckin_candidate, ACgive_structure,
 *				  ACget_db_info overrides
 ***************************************************************************/

class implementation VSedge3Datt;

#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "VDmem.h"
#include "vsedgeattr.h"
#include "VDchn.h"
/*
#define vsDEBUG 1
#define vserrDEBUG 1
*/
#include "vsdbgmacros.h"

from ACrg_collect	import 	AClist_attribute, ACget_named_attribute;

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
  struct GRid 		attr_col;
  struct ACrg_coll 	list_att[ATT_NB_ATT];

  SetProc( VSedge3Datt_VDgetParameters ); Begin
  /* Check the input arguments */
  if ( !msg || !md_env ) return OM_E_INVARG;
  __DBGpr_me();

  /* Initialization      */
  sts             = OM_S_SUCCESS;
  *msg            = MSSUCC;
  *nbParams       = 0;
  *parList        = NULL;

  sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, 2, &attr_col),
                	targetid = my_id );
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
  IGRlong 		sts;
  IGRint 		loc_sts, i=0, index=-1;
  struct ret_struct    	attr_rs;
  struct GRid 		attr_col;

  SetProc( VSedge3Datt_VDreviewParameters ); Begin
  /* Check the input arguments */
  if ( !msg || !nb_params || !parlist || !md_env ) return OM_E_INVARG;
  __DBGpr_me();

  /* Initialization */
  *msg  	  = MSSUCC;
  sts   	  = OM_S_SUCCESS;

  sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, 2, &attr_col),
                	targetid = my_id );
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


/******************************************************************************

  Overridden Message
        ACcheckin_candidate from ACdb_info

  Abstract
        Set to prevent edge attributes from being posted to database.

  Arguments
	IGRint CheckinType;           I: VDS_NORMAL_CHECKIN or VDS_FAST_CHECKIN
	IGRint *p_CheckinCandidate);  O: FALSE, object not a checkin candidate

  Notes/Remarks
        Eliminates diagnostic, "ACget_db_info: No data base information
                        available".
	Change FALSE to TRUE to invoke ACget_db_info.

  Status/Return Code
        OM_S_SUCCESS

*******************************************************************************/

method ACcheckin_candidate( int CheckinType, *p_CheckinCandidate )
{
        long    sts;


  SetProc( VSedge3Datt_ACcheckin_candidate ); Begin


        *p_CheckinCandidate = FALSE;

	sts  = OM_S_SUCCESS;

  End
        return sts ;

} /* method ACcheckin_candidate */


/******************************************************************************

  Overridden Message
        ACgive_structure from VSfeature, NDmacro

  Abstract
        Process edge attributes so that command, Review Attributes, will
	print their values on it's form.

  Arguments
	IGRlong	*msg;                 O: Error status returned
	IGRint  *notUsed;             I: Not used
	IGRchar *attrName;	      I: Name of attribute
	struct ret_struct  *attrVal;  O: Value of attribute returned
	struct GRmd_env    *myEnv;    I: Used for edge's object space number

  Status/Return Code
        OM_S_SUCCESS or error status from ACget_named_attribute

*******************************************************************************/
method ACgive_structure(IGRlong			*msg;
			IGRint 			*notUsed;
			IGRchar			*attrName;
			struct	ret_struct	*attrVal;
			struct	GRmd_env	*myEnv	)
{
  IGRlong sts;
  struct GRid 		collID, edgeID;
  struct ACrg_coll	col;
  IGRchar name[128];
  IGRchar *p;
 

  SetProc( VSedge3Datt_ACgive_structure ); Begin

  *msg  	  = 0;
  sts   	  = 0;

  // Arg check
  if ((attrName == NULL) || (attrVal == NULL)) goto wrapup;

  edgeID.objid = my_id;
  edgeID.osnum = myEnv->md_id.osnum;
 
  // Get the collector
  vdchn$Get2(objID  = &edgeID,
             chnIDx = VDCHN_IDX_PARENT,
             nth    = 2,
             outID  = &collID);
  if (collID.objid == NULL_OBJID) goto wrapup;

  // name is case sensitive, lower is standard but edges use upper
  strcpy(name,attrName);
  __DBGpr_str("name", name);
  for(p = name; *p; p++) {
    if ((*p >= 'a') && (*p <= 'z')) *p -= 32;
  }
  // Hack for stupid space
  if (!strcmp(name,"SPEC_NUMBER")) strcpy(name,"SPEC NUMBER");
 
  // Ask for the attribute
  memset(&col,0,sizeof(col));
  strcpy(col.name,name);

  sts = om$send(msg = message
          ACrg_collect.ACget_named_attribute(msg,&col),
          senderid = NULL_OBJID,
          targetid = collID.objid,
          targetos = collID.osnum);
  if (!(sts & *msg & 1)) goto wrapup;

  // Extract value
  switch(col.desc.type) {

  case AC_ATTRIB_DOUBLE:
    __DBGpr_dbl("value", col.desc.value.att_exp);
    attrVal->type = double_type;
    attrVal->var.root_pm_st.value  = col.desc.value.att_exp;
    break;

  case AC_ATTRIB_TEXT:
    __DBGpr_str("value", col.desc.value.att_txt);
    attrVal->type = text_type;
    strcpy(attrVal->var.text_st.text_string,col.desc.value.att_txt);
    break;

  default: goto wrapup;

  }

  // Done
  sts             = OM_S_SUCCESS;
  *msg            = MSSUCC;

wrapup:
  End
  return sts;

} /* method ACgive_structure */


/******************************************************************************

  Overridden Message
        ACget_db_info from VSfeature

  Abstract
        Retrieve data base information (catalog name, part number, etc.)

  Arguments
	IGRlong	*msg;                 O: Error status  returned
	struct ACdb_info   *dbInfo;   O: Database info returned

  Notes/Remarks
	For future posting of edge attributes;
	Change FALSE to TRUE in ACcheckin_candidate to invoke ACget_db_info.

  Status/Return Code
        OM_S_SUCCESS or error status from VSforwardToOriginal

*******************************************************************************/
method ACget_db_info(   long                    *msg ;
                        struct ACdb_info        *dbInfo ; )
{

        long                    sts,            /* OM return code       */
                                VSrc ;          /* Self-explanatory     */

  SetProc( VSedge3Datt_ACget_db_info ); Begin

  *msg  	  = 0;
  sts   	  = 0;

        *dbInfo->catalog        = *dbInfo->part_num     = *dbInfo->revision
                                = *dbInfo->usage        = '\0' ;
        /*
         * Traverse the graph up through all the consumed parts till you
         * find a source part.
         */
        *msg = MSFAIL ;
        sts = om$send(  msg     = message VSfeature.VSforwardToOriginal(
                                        &VSrc,
                                        OM_e_wrt_message,
                                        message ACdb_info.ACget_db_info(
                                                                 msg, dbInfo )),
                        targetid= my_id ) ;
        __CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;

        dbInfo->serial_no = my_id ;

  // Done
  sts             = OM_S_SUCCESS;
  *msg            = MSSUCC;

wrapup:
  End
  return sts;

} /* method ACget_db_info */

end implementation VSedge3Datt;
