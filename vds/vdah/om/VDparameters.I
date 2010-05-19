
/* $Id: VDparameters.I,v 1.2 2001/01/10 18:12:25 art Exp $  */

/* I/VDS
 *
 * File:        $VDS/vdutil/VDparameters.I
 *
 * Description:
 *    This file contains the following functions :
 *                  - VDReviewParameters
 *                  - VDget_parameters
 *                  - VDreviewParams
 *                  - VDgetParams
 *
 * Revision History:
 *	$Log: VDparameters.I,v $
 *	Revision 1.2  2001/01/10 18:12:25  art
 *	sp merge
 *	
# Revision 1.2  2000/12/06  19:45:30  pinnacle
# Replaced: vds/vdutil/VDparameters.I for:  by jdsauby for Service Pack
#
# Revision 1.1  2000/12/06  18:56:56  pinnacle
# Created: vds/vdutil/VDparameters.I by ahundiak for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/17  08:24:06  pinnacle
# Replaced: vdutil/VDparameters.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1997/02/04  19:32:42  pinnacle
# Replaced: vdutil/VDparameters.I for:  by v241_int for vds.241
#
# Revision 1.2  1996/09/26  14:29:20  pinnacle
# Replaced: vdutil/VDparameters.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.9  1996/05/29  17:09:50  pinnacle
# Replaced: vdutil/VDparameters.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/08/25  20:51:30  pinnacle
# Replaced: vdutil/VDparameters.I for:  by rmanem for vds.240
#
# Revision 1.7  1995/06/29  15:11:26  pinnacle
# Replaced: vdutil/VDparameters.I for:  by azuurhou for vds.240
#
# Revision 1.6  1995/06/28  20:00:24  pinnacle
# Replaced: vdutil/VDparameters.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/05/01  16:31:20  pinnacle
# Replace: vdutil/VDparameters.I by azuurhou for OPE
#
# Revision 1.4  1995/03/18  21:32:18  pinnacle
# Replaced: vdutil/VDparameters.I by azuurhou r#
#
# Revision 1.3  1995/02/22  21:03:26  pinnacle
# Replaced: vdutil/VDparameters.I by rmanem r#
#
# Revision 1.2  1995/01/03  20:09:12  pinnacle
# Replaced:  vdutil/VDparameters.I r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *                                             
 * History:
 *      07/28/94        R. Manem        Creation
 *	09/09/94	P. Lacroix	Exception rules for VDdrawing.
 *      09/18/94        R. Manem        VDReviewParameters : send VDSgetCompDesc
 *                                      to all ROUTE objects, instead of only
 *                                      VRGeneric subclassed objects
 *	01/03/95	ad, rmn		Changes for VDdrwObj objects, 
 *					route objects
 *	02/15/95	rmn		New functions VDgetParams, 
 *					VDreviewParams
 *	06/28/95	adz		Changed VDdrw Objects.
 *	08/24/95	rmn		Adapted VDReviewParameters to  
 *					handle cpymir objects.
 *	02/04/97	adz		Check for Database Attributes.
 */

class implementation Root;

#include <stdio.h>
#include <string.h>

#include "igetypedef.h"     /* these two needed for gr.h, order of includes */
#include "igrtypedef.h"     /* important, also needed for IGRint ...        */
#include "gr.h"             /* struct GRid, GRmd_env  ..                    */

#include "OMprimitives.h"   /* om$send                                      */
#include "OMmacros.h"       /* indirectly for OM_S_SUCCESS, OM_E_NODYNMEM   */

#include "msdef.h"          /* MSSUCC, MSFAIL                               */
#include "DIdef.h"          /* DI_PATH_MAX                                  */

#include "parametric.h"     /* ret_struct,  macro_generic ..                */

#include "ACattrib.h"       /* AC_ATTRIB_TEXT ..                            */
#include "ACrg_collect.h"   /* struct ACrg_coll                             */

#include "exmacros.h"      
#include "vdparmacros.h"      

#include "EMSmsgdef.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"


//#define	vdsDEBUG	1

#include "v_dbgmacros.h"

#include "AS_status.h"      /* as$status                                    */
#include "VDItemDB.h"       /* additional attributes functions              */

from ACdb_info	     import ACgive_db_structure;
from NDmacro	     import ACgive_structure;
from NDmacro         import ACreturn_foot;
from ACcpx           import ACfind_temp_obj;
from ACcpx_defn      import ACgive_name;
from ACcpx           import find_macro ;
from NDnode          import NDgive_structure;
from ACmacro_defn    import ACgive_feet_desc, ACgive_temp_desc;
from ACrg_collect    import AClist_attribute;
from expression      import NDgive_value;
from VDSroot         import VDSgetCompDesc;
from VDSroot         import VDGetModel;
from VDSroot	     import VDreviewParameters, VDgetParameters;

/*
 * Exception Objects.
 */
extern 	GRclassid 	OPP_ACdb_info_class_id;
extern 	GRclassid 	OPP_VDdrawing_class_id;
extern 	GRclassid 	OPP_VDSroot_class_id;
extern 	GRclassid 	OPP_VDdrwObj_class_id;
extern 	GRclassid 	OPP_VDdrw3d_class_id;
extern	GRclassid	OPP_VDdrwGm_class_id;


/*+fe
  Function VDReviewParameters

  Macro Name
      vd$review_parameters

  Abstract
      Given a list of attribute names, this function returns
      their values in the specified component.

  Arguments
      IGRlong           *pMsg        O     Completion code
      struct GRid       *CompId      I     Specified component
      IGRint            NamesNumber  I     Number of specified names
      struct ACrg_coll  *pList      I/O    Array of parameters
      struct GRmd_env   *pMdEnv      I     Module environment of the object

  Returns
      OM_S_SUCCESS      if success

-fe*/

IGRint	VDReviewParameters ( pMsg, CompId, NamesNumber, pList, pMdEnv )

IGRlong 	 *pMsg;		/* Completion code 		*/
struct GRid	 *CompId;	/* Specified component 		*/
IGRint		 NamesNumber;	/* Number of specified names	*/
struct ACrg_coll *pList;	/* Array of parameters		*/
struct GRmd_env	 *pMdEnv;	/* Module environment of the object */
{
    IGRint               status, i, ind;
    IGRlong              retmsg;
    IGRint               Index = -1;
    IGRchar              cName[80],
			 *macName;
/*
    double		 value = 0;
*/
    struct ret_struct    AttrSt;
    struct GRid		 Temp,
			 locComp,
			 mirComp,
			 macDef;

    SetProc( VDReviewParameters ); Begin

    *pMsg = MSSUCC;

    __DBGpr_obj( "Input object id", (*CompId) );

    macDef.objid = mirComp.objid = NULL_OBJID;

    for ( i=0; i<NamesNumber; i++ )
        pList[i].desc.type     = AC_ATTRIB_TYPE_NOT_DEF;

    /* get the macro name */

    status = _VD_SEND_OBJN( (*CompId), ACcpx.find_macro( &macDef ) );
    __DBGpr_obj( "Macro id", macDef );

    if( (status & 1) && (macDef.objid != NULL_OBJID) )
    {
	status = _VD_SEND_OBJN( macDef, ACcpx_defn.ACgive_name( &macName ) );
	__DBGpr_str( "Macro name", macName );

	if( !strcmp( macName, "cpymir" ) )
	{
	    status =
	    _VD_SEND_OBJN( (*CompId), NDmacro.ACreturn_foot( 	pMsg,
								"miror_obj",
								&mirComp,
								NULL, NULL ) );
/*
	    if( !(status & *pMsg & 1) )
		mirComp.objid = NULL_OBJID;
*/

	    __DBGpr_obj( "miror_obj id", mirComp );
	}
    }

    status = OM_S_SUCCESS;
    *pMsg = MSSUCC;

    /* 
     * loop through both the original object : to handle complete attr names
     * and the miror_obj if present : to handle  short attribute names
     */

    for( ind = 0 ; ind < 2 ; ind++ )
    {
 	if( ind == 0 )
	    locComp = *CompId;
	else if( ind == 1 )  
	{
	    if( mirComp.objid != NULL_OBJID )
	        locComp = mirComp;
	    else
		continue;
	}

	    
    	for ( i=0; i<NamesNumber; i++ )
    	{
	    /* if attribute value already found, go to next one */

          if( pList[i].desc.type != AC_ATTRIB_TYPE_NOT_DEF )
		continue;

	  status = 0 ;

	  if( vd_$is_ancestry_valid(    object  = & locComp ,
                                        classid = OPP_ACdb_info_class_id ) ) {

            __DBGpr_obj( "subclass ACdb", locComp ) ;

            status =
	    om$send(  msg     = message ACdb_info.ACgive_db_structure(
                                        (IGRint *) &retmsg,
					&Index,
					pList[i].name,
					&AttrSt, pMdEnv ),
                      senderid= NULL_OBJID,
                      targetid= locComp.objid,
                      targetos= locComp.osnum ) ;
          }

	  if( !(status & retmsg & 1) ){

            status = om$send ( msg = message NDmacro.ACgive_structure(
                                         (IGRint *) &retmsg, &Index,
                                         pList[i].name, &AttrSt, pMdEnv ),
                               senderid = NULL_OBJID,
                               targetid = locComp.objid,
                               targetos = locComp.osnum );
	  }

          if( (status & retmsg & 1) && (AttrSt.type == double_type ||
					AttrSt.type == text_type) )
            {
                /* Parameter exists and it has the right type */
                /* Put value in the array */

                if ( AttrSt.type == double_type )
                {
                    pList[i].desc.type     = AC_ATTRIB_DOUBLE;
                    pList[i].desc.value.att_exp = AttrSt.var.root_pm_st.value;
                }
                else if ( AttrSt.type == text_type )
                {
                    pList[i].desc.type     = AC_ATTRIB_TEXT;
                    strcpy (pList[i].desc.value.att_txt ,
                        		AttrSt.var.text_st.text_string) ;
                }

            }/* end get parameter succeeded */
            else
            {

                /* 
                 * if it is a ROUTE object, simply send the message 
		 * VDSgetCompDesc. Don't check for VRGeneric subclass, 
		 * because objects like VRPCorentity (subclassed from 
		 * GRowner, ASnode) also respond to the message by sending 
 		 * it to objects on the components channel.
                 */

                om$get_classname( objid        = locComp.objid,
                                  osnum        = locComp.osnum,
                                  classname    = cName );
                              

                if( cName[0] == 'V' && cName[1] == 'R' )
                {

                    status =
                    om$send ( msg = message VDSroot.VDSgetCompDesc( &retmsg, 
                                                                   &pList[i], 
                                                                   pMdEnv ),
                              senderid = NULL_OBJID,
                              targetid = locComp.objid,
                              targetos = locComp.osnum );
/* continue with next parameter 
                as$status ( action = RET_STATUS );
*/

                    if ( !( status & retmsg & 1 ) ) *pMsg = MSFAIL;
                }
                else
                {
                     /*
                      * it is not a Route object either
                      * Last hope : try template objects
                      */

                     Temp.objid = NULL_OBJID;

                     status = om$send( msg  = message ACcpx.ACfind_temp_obj(
                                                        (IGRint *)&retmsg,
                                                        pList[i].name,
                                                        &Temp ),
                                    senderid = NULL_OBJID,
                                    targetid = locComp.objid,
                                    targetos = locComp.osnum );


/*
                     status = om$send( msg  = message expression.NDgive_value(
                                                                &value ),
                                    senderid = NULL_OBJID,
                                    targetid = Temp.objid,
                                    targetos = Temp.osnum );

*/
		    status =
                    _VD_SEND_OBJN( Temp, expression.NDgive_structure(&retmsg,
				&AttrSt, pMdEnv));
                     if( status & retmsg & 1 )
                     {
/*
                          pList[i].desc.type     = AC_ATTRIB_DOUBLE;
                          pList[i].desc.value.att_exp = value;
*/
			if( AttrSt.type == double_type )
			{
                            pList[i].desc.type = AC_ATTRIB_DOUBLE;
                            pList[i].desc.value.att_exp = 
					   AttrSt.var.root_pm_st.value;
			}
			else if( AttrSt.type == text_type )
			{
                            pList[i].desc.type = AC_ATTRIB_TEXT;
                    	    strcpy( pList[i].desc.value.att_txt, 
					   AttrSt.var.text_st.text_string );
			}
                     }
/*
                     else
                          *pMsg = MSFAIL;
*/
                }
            }
        }/* end loop on parameter names */
    }

    End
    return OM_S_SUCCESS;

}/* end VDReviewParameters */


/*+fe
  Function VDreviewParams

  Macro Name
      vd$review_params

  Abstract
      Given a list of attribute names, this function returns
      their values in the specified component.
      This function will send the VDreviewParameters method to the object.
      The default implementation at VDSroot level, is to simply invoke the
      vd$review_parameters macro.

  Arguments
      IGRlong           *pMsg        O     Completion code
      struct GRid       *CompId      I     Specified component
      IGRint            NamesNumber  I     Number of specified names
      struct ACrg_coll  *pList      I/O    Array of parameters
      struct GRmd_env   *pMdEnv      I     Module environment of the object

  Returns
      OM_S_SUCCESS      if success

-fe*/

IGRint	VDreviewParams ( pMsg, CompId, NamesNumber, pList, pMdEnv )

IGRlong 	 *pMsg;		/* Completion code 		*/
struct GRid	 *CompId;	/* Specified component 		*/
IGRint		 NamesNumber;	/* Number of specified names	*/
struct ACrg_coll *pList;	/* Array of parameters		*/
struct GRmd_env	 *pMdEnv;	/* Module environment of the object */
{
    IGRlong 		status = OM_S_SUCCESS;

    SetProc( VDreviewParams ); Begin

    *pMsg = MSSUCC;

    if( vd_$is_ancestry_valid(	object	= CompId,
				classid	= OPP_VDSroot_class_id )){

	status =
	_VD_SEND_OBJN(	*CompId,
			VDSroot.VDreviewParameters( pMsg, NamesNumber,
						pList, pMdEnv ) );
    }
    else
    {
        status = vd$review_parameters( 	pMsg		= pMsg, 
					pComponent	= CompId,
					NbParams	= NamesNumber,
					pList		= pList,
					pMdEnv		= pMdEnv );

    }
    End
    return status;
}

/*+fe
  Function VDget_parameters

  Macro Name
      vd$get_parameters

  Abstract
      The function is used to get all the parameters and their values
      of any given object.  Normally this function would be called
      twice; once to get the number of parameters, and the second
      time, to get the list of parameters and the values.

  Arguments
      <Data Type>       <Name>  <I/O>   <Description>

      IGRlong          *sts         O     return code
      struct GRid      *object_id   I     GRid of the object
      IGRchar          *object_name I     name of the object if exists.  
                                          Set to NULL the first time; 
                                          Recursive calls will set this 
                                          value to the name of the (macro) 
                                          object. The name will be prefixed 
                                          to the parameter name.
      GRmd_env         *md_env      I     module environment of the object
      struct ACrg_coll *plist       O     Pass NULL if list of parameters 
                                          not needed; otherwise pass pointer 
                                          to an ACrg_coll structure.  Memory 
                                          has to be allocated before calling 
                                          the function.
      IGRint           size         I     Size of the plist passed
      IGRint           *count       O     No of parameters returned. 
                                          If plist = NULL, count is the total 
                                          number of parameters for the object
      IGRboolean       first_time   I     TRUE the first time the function 
                                          is called; Recursive calls set this 
                                          argument to FALSE

  Returns
      OM_S_SUCCESS     if success
      OM_E_NODYNMEM    no dynamic memory available

-fe*/


IGRint VDget_parameters( IGRlong           *sts,
                         struct GRid       *object_id,
                         IGRchar           *object_name,
                         struct GRmd_env   *md_env,
                         struct ACrg_coll  *plist,
                         IGRint            size,
                         IGRint            *count,
		         IGRboolean        first_time)
{
int			status,
			msg,
			ifeet,
			nb_feet,
			itemp,
			nb_temp,cnt;
long			loc_msg,
			l_msg;
char			feet_name[ DI_PATH_MAX ];
char			classname[DI_PATH_MAX];
double			value;
struct myfeet		*l_feet = NULL;
struct stemp		*l_temp = NULL;
struct GRid       	NewObj,ItemDb,
			ModelId,
			slist,
			Feet,
			macro_def,
			Temp;
struct GRmd_env		NewEnv;
struct ACrg_coll	*list_att = NULL;
struct ret_struct	rst;
IGRboolean		chk_first_time;

static int		current;

extern OM_S_CHANSELECT ND_father;


    /* 
     * function is called recursively; so initialize some variables the first
     * time it is called (by vd$get_parameters macro)
     */

    *sts = MSSUCC ;
    chk_first_time = first_time ;
    ItemDb.objid = NULL_OBJID ;

    if( first_time )
    {
	*count = 0;
	current = 0;
	first_time = FALSE;
        *sts = MSSUCC;
        
        /* if object is is NULL, set message to fail */

        if( object_id->objid == NULL_OBJID )
        {
            *sts = MSFAIL;
            return( OM_S_SUCCESS );
        }
    }

    if( object_id->objid == NULL_OBJID ){
	*sts = MSSUCC ;
        return( OM_S_SUCCESS );
    }

    if( ! chk_first_time ) goto SAME_OBJ;

    /*
     * special treatment for VDdrawing/VDdrwObj  group objects.
     *	Route components to get the static data attributes.
     */
    status =
    om$get_classname( 	  osnum     = object_id->osnum,
                          objid     = object_id->objid,
                          classname = classname );

    if(	vd_$is_ancestry_valid(	object	= object_id,
				classid	= OPP_VDdrawing_class_id )	||
	vd_$is_ancestry_valid(	object	= object_id,
				classid	= OPP_VDdrwObj_class_id	)){

	/*
	 * get it's parent object.
	 */
	IGRint	index = 0 ;

	if( vd_$is_ancestry_valid(	object	= object_id,
					classid	= OPP_VDdrwObj_class_id )){
		/*
		 * Parent Index is 2nd element.
		 */
		index = 1;
	}

	status =
	om$get_objid_at_index(
       	         	objid           = object_id->objid,
                	osnum           = object_id->osnum,
                	p_chanselect    = &ND_father,
			index		= index,
			objidaddr	= &slist.objid,
			osnumaddr	= &slist.osnum);
    	if( !(status&1))  {
       		 	goto SAME_OBJ;
    	}

    	status =
	om$send(msg = message NDmacro.ACreturn_foot(
					&loc_msg,
					"",
					&NewObj, 
					&NewEnv.md_env.matrix_type,
					NewEnv.md_env.matrix ),
             	senderid = NULL_OBJID,
            	targetid = slist.objid,
            	targetos = slist.osnum );

	if( !(status&loc_msg&1) ){
        	goto SAME_OBJ;
    	}

        NewEnv.md_id.osnum = NewObj.osnum;
        status =ex$get_modid(mod_osnum = NewEnv.md_id.osnum,
                       	     mod_id    = &NewEnv.md_id.objid);

	/*
	 * get parameters of object.
	 */
	VDget_parameters( sts, object_id, object_name, md_env,
			  plist, size, count, first_time );

	/*
	 * get parameters of parent object.
	 */
	VDget_parameters( sts, &NewObj, object_name, &NewEnv,
			  plist, size, count, first_time );

	if( vd_$is_ancestry_valid(	object	= &NewObj,
					classid	= OPP_VDdrw3d_class_id )){
		/*
		 * Parent Index is 2nd element.
		 */
		index = 1;

		status =
		om$get_objid_at_index(
       	         	objid           = NewObj.objid,
                	osnum           = NewObj.osnum,
                	p_chanselect    = &ND_father,
			index		= index,
			objidaddr	= &slist.objid,
			osnumaddr	= &slist.osnum);
	    	if( !(status&1))  {
       		 	return OM_S_SUCCESS ;
    		}

	    	status =
		om$send(msg = message NDmacro.ACreturn_foot(
					&loc_msg,
					"",
					&NewObj, 
					&NewEnv.md_env.matrix_type,
					NewEnv.md_env.matrix ),
      	 	      	senderid = NULL_OBJID,
       		     	targetid = slist.objid,
       		     	targetos = slist.osnum );

		if( !(status&loc_msg&1) ){
       	 		return OM_S_SUCCESS;
    		}

		NewEnv.md_id.osnum = NewObj.osnum;
		status =
		ex$get_modid(mod_osnum = NewEnv.md_id.osnum,
                       	     mod_id    = &NewEnv.md_id.objid);

		/*
		 * get parameters of parent object.
		 */
		VDget_parameters( sts, &NewObj, object_name, &NewEnv,
				  plist, size, count, first_time );

	}

	/*
	 * Check for itemDB with NewObj original object was drawing object.
	 */
	ItemDb = NewObj ;
//	goto ITEM_DB ;

    }
    else if ( om$is_ancestry_valid(	subclassname = classname,
					superclassname = "VRGeneric" )
							== OM_S_SUCCESS ){
        /* 
         * For Route objects, must get the database attributes from the
         * Model object, and the rest of the parameters from the object itself
         */

        status =
	_VD_SEND_OBJN(	*object_id,
			VDSroot.VDGetModel( &loc_msg, &ModelId, md_env ));
        if( !(status & loc_msg & 1) || ModelId.objid == NULL_OBJID )
            goto SAME_OBJ;

	/*
	 * get parameters of object.
	 */

	VDget_parameters( sts, object_id, object_name, md_env,
			  plist, size, count, first_time );

        /* 
         * get parameters for the model object 
         */

        VDget_parameters( sts, &ModelId, object_name, md_env, 
			  plist, size, count, first_time );

	/*
	 * Check for itemDB with object_id original object was drawing object.
	 */
	ItemDb = *object_id ;
//	goto ITEM_DB ;
    }
    else {

SAME_OBJ:

	NewObj.objid = object_id->objid;
	NewObj.osnum = object_id->osnum;
	ItemDb = NewObj ;
	NewEnv = *md_env;
    }
    /*
     * get the structure of the object
     */
    status =
    om$get_classname(     osnum     = NewObj.osnum,
                          objid     = NewObj.objid,
                          classname = classname );

    status =
    _VD_SEND_OBJN(	NewObj,
			NDnode.NDgive_structure(sts,&rst,&NewEnv));
    if( !(status & 1) )
	goto wrapup;

   

    if( rst.type == gen_rg_collect )
    {
      

        /* find the number of collection attributes */

        status =
        _VD_SEND_OBJN(	NewObj,
			ACrg_collect.AClist_attribute( sts, 0, NULL, &nb_feet));
        as$status( action = RET_STATUS );

        (*count) = (*count) + nb_feet;

	__DBGpr_int(" Number Feet ", nb_feet );

        if( plist )
        {

            /* allocate space for the list of attributes */

            list_att = (struct ACrg_coll *)om$malloc( 
            size = ( sizeof( struct ACrg_coll ) * (nb_feet)));

            if( list_att == NULL ) 
            {
                (*count) = (*count) - nb_feet;
                return ( OM_E_NODYNMEM );
            }

            /* get the collection attributes */

            status =
            _VD_SEND_OBJN(	NewObj,
				ACrg_collect.AClist_attribute( sts, nb_feet,
                                                         list_att, &nb_feet));
	    if( !(status&*sts&1)) goto wrapup ;

            /* store the attributes in plist */

            for( ifeet = 0; ifeet < nb_feet && current < size ; ifeet++ )
            {
                if(object_name[0] != '\0')
                    sprintf( feet_name, "%s:%s", object_name,
                             list_att[ifeet].name );
                else
                    strcpy( feet_name, list_att[ifeet].name );

		__DBGpr_int(" Current index ", ifeet );
		__DBGpr_str(" Feet_Name     ", feet_name );

                plist[current] = list_att[ifeet];

                /* update name with prefix, if present, by copying feet_name */

		strcpy( plist[current].name, feet_name );
		current++;
            }

                if( list_att ) 
                    om$dealloc ( ptr = list_att );

            if(current >= size)
                goto wrapup;
        }
    }
    else if( rst.type & macro_generic )
    {

        /* The object is a macro occurence */

	__DBGpr_com(" Object is a macro " );

	/* Added by sundar for the cable CR:179702016 */
        if ( om$is_ancestry_valid(     subclassname = classname,
                                        superclassname = "VCRoot" )
                                                        == OM_S_SUCCESS ) {
            if ( plist == NULL ){
                status =
                _VD_SEND_OBJN( NewObj,
                        VDSroot.VDgetParameters( sts, count, &plist, &NewEnv ));
                _FREE(plist); /* First time we need only count */
            } else {
                _FREE(plist); /* We are allocating memory but 
				 VCRoot.VDgetParameters allocates memory */
                plist=NULL;
                status =
                _VD_SEND_OBJN( NewObj,
                        VDSroot.VDgetParameters( sts, count, &plist, &NewEnv ));
            }
             __DBGpr_int(" count ", *count );
             __DBGpr_obj(" NewObj ", NewObj );

	    return OM_S_SUCCESS ;
	}
	/* Added by sundar end*/

	macro_def.objid = NULL_OBJID;
        status =
        _VD_SEND_OBJN(	NewObj, ACcpx.find_macro( &macro_def ));
	if( !( status & 1 ) || macro_def.objid == NULL_OBJID ){
		goto wrapup;
	}

        if( object_name[0] == '\0') 
        {

            /*
             * Only for the selected macro definition the template values
             * are used; Not for the nested ones.
             */

            status =
            _VD_SEND_OBJN( macro_def,
			   ACmacro_defn.ACgive_temp_desc(&nb_temp,&l_temp));
            as$status();

            for( itemp=0; itemp<nb_temp; itemp++ )
            {

                status =
                _VD_SEND_OBJN(	NewObj,
				ACcpx.ACfind_temp_obj ( &msg,
                                                l_temp[itemp].name, &Temp ));
                if( !(status&msg&1) ) 
                    continue;

		__DBGpr_int(" Temp index ", itemp );
		__DBGpr_str(" temp_name  ", l_temp[itemp].name );

                if( vd_$is_ancestry_valid(object = &Temp,
                                          classid = OPP_expression_class_id )){

                    status =
/*
                    _VD_SEND_OBJN( Temp, expression.NDgive_value(&value));
*/
                    _VD_SEND_OBJN( Temp, expression.NDgive_structure(&l_msg,
				&rst, &NewEnv));
                    if(status & l_msg & 1)
                    {
                        (*count)++;
                        if( plist )
                        {
			if( rst.type == double_type )
			{
                            strcpy( plist[current].name, l_temp[itemp].name );
                            plist[current].desc.type = AC_ATTRIB_DOUBLE;
                            plist[current].desc.value.att_exp = 
					   rst.var.root_pm_st.value;
			}
			else if( rst.type == text_type )
			{
                            strcpy( plist[current].name, l_temp[itemp].name );
                            plist[current].desc.type = AC_ATTRIB_TEXT;
                    	    strcpy( plist[current].desc.value.att_txt, 
					   rst.var.text_st.text_string );
			}
                            current++;
                            if( current >= size )
                                goto wrapup;
                        }
                    }
                }
            }
        }

        /* get the feet of the macro */

        status =
        _VD_SEND_OBJN(	macro_def,
			ACmacro_defn.ACgive_feet_desc( &nb_feet, &l_feet ));
        as$status();

	__DBGpr_int(" Number Feet ", nb_feet );

        for( ifeet = 0; ifeet < nb_feet; ifeet++ )
        {
            status = 
            _VD_SEND_OBJN(	NewObj,
				NDmacro.ACreturn_foot( sts, l_feet[ifeet].name,
                                                       &Feet, NULL, NULL));
	    if( !(status&*sts&1)) continue ;

            if( vd_$is_ancestry_valid(	object	= &Feet,
                                        classid	= OPP_VDdrwGm_class_id )){
		/*
		 * Nothing to see within the VDdrwGm macro.
		 */
		continue ;
	    }

            status =
            _VD_SEND_OBJN(	Feet,
				NDnode.NDgive_structure( sts, &rst, &NewEnv));
            if( !(status&*sts&1)) continue;

            /* create or concatenate feetname */
            if( object_name[0] != '\0' )
                sprintf( feet_name, "%s:%s", object_name,
                         l_feet[ifeet].name );
            else
                strcpy( feet_name, l_feet[ifeet].name );

	    __DBGpr_int("feet_index ", ifeet );
	    __DBGpr_str("feet_name  ", feet_name );
	
            if( rst.type == double_type )
            {
                (*count)++;
		if( plist )
		{
                    strcpy( plist[current].name, feet_name );
                    plist[current].desc.value.att_exp = 
                                           rst.var.root_pm_st.value; 
                    plist[current].desc.type = AC_ATTRIB_DOUBLE;
                    current++;
		}
            }
            else if(rst.type == text_type)
            {
                (*count)++;
		if( plist )
		{
                    strcpy( plist[current].name, feet_name );
                    strcpy( plist[current].desc.value.att_txt, 
					   rst.var.text_st.text_string );
                    plist[current].desc.type = AC_ATTRIB_TEXT;
                    current++;
		}
            }
            else if( rst.type & macro_generic )
            {
                /* search nested feetnames */

	        __DBGpr_int("feet_index ", ifeet );
	        __DBGpr_str("feet_name  ", feet_name );
	
                VDget_parameters( sts, &Feet, feet_name, &NewEnv, 
                                  plist, size, count, first_time );

            }
        }
    }

//ITEM_DB:
#if 0
    // check for attributes in other db tables
    if( chk_first_time ) {
      if( ItemDb.objid != NULL_OBJID ){
	cnt = *count;
	// this time to get the number of additional attributes
	VDgetItemDbParameters( &ItemDb,sts,count,plist );
	
	__DBGpr_int(" Number Feet ", nb_feet );
	
	if( plist){
	  // this time to fill the list
	  VDgetItemDbParameters( &ItemDb,sts,&cnt,plist );
	}
      }
    }
#endif
wrapup :

	*sts = MSSUCC ;
	return OM_S_SUCCESS;

}/* end VDget_parameters */

/*+fe
  Function VDgetParams

  Macro Name
      vd$get_paramsIGRint  cnt;

  Abstract
      The function is used to get all the parameters and their values
      of any given object.  
      Sends VDgetParameters method to the object

  Arguments
      <Data Type>       <Name>  <I/O>   <Description>

      IGRlong          *sts         O     return code
      struct GRid      *object      I     GRid of the object
      GRmd_env         *md_env      I     module environment of the object
      IGRint           *count       O     No of parameters returned.
                                          If plist = NULL, count is the total
                                          number of parameters for the object
      struct ACrg_coll **plist      O     Address of list.  Memory will be
					  allocated

  Returns
      OM_S_SUCCESS     if success
      OM_E_NODYNMEM    no dynamic memory available

-fe*/


IGRint VDgetParams( IGRlong           *sts,
                    struct GRid       *object,
                    struct GRmd_env   *md_env,
                    IGRint            *count,
                    struct ACrg_coll  **plist )
{

    IGRlong 		status = OM_S_SUCCESS;
    IGRint 		cnt;
    IGRint flag = 0;

    SetProc( VDgetParams ); Begin
if (object->objid == 10031) flag = 1;
if (flag) printf(">>> Entered VDgetParams\n");
    *sts = MSSUCC;

    if( vd_$is_ancestry_valid(	object	= object,
				classid	= OPP_VDSroot_class_id )){

if (flag) printf("Sending VDgetParameters\n");
        status =
	_VD_SEND_OBJN( *object,
			VDSroot.VDgetParameters( sts, count, plist, md_env ));

	__DBGpr_int ( "count", *count );
if (flag) printf("Getting Db Params\n");
//	status = VDgetItemDbParameters( sts, object, md_env, count, plist );
if (flag) printf("Back from DbParams\n");
	__DBGpr_int ( "count after itemdb", *count );
    }
    else
/*
    if( status == OM_W_UNKNOWN_MSG || status == OM_W_REJECTED_METHOD )
*/
    {
        *count = 0;

        /* get parameter count */

        status = vd$get_parameters(	sts	= sts,
					object	= object,
					md_env	= md_env,
					count	= count );

        CheckRC( status, *sts );

        __DBGpr_int( "count", *count );

        if( !(status & *sts & 1) || !*count )
            goto wrapup;
	
	

        /* allocate memory */
    
        *plist = _MALLOC( *count, struct ACrg_coll );

        if( !*plist )
            vd_$mem_fail( sts = status, msg = sts );

        /* get the parameter list */

        status = vd$get_parameters( sts     = sts,
                                    object  = object,
                                    md_env  = md_env,
				    plist   = *plist,
                                    size    = *count,
                                    count   = count );
        CheckRC( status, *sts );
	
    }

wrapup :

    End
    return status;
}


end implementation Root;



