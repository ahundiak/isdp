/* #######################    APOGEE COMPILED   ######################## */


/*
Name
        GRudsave
Synopsis
        method GRudsave (long *msg; struct GRid *add_id; 
                        struct GRmd_env *add_mod)

        msg             - return status
        add_id          - GRid of object being manipulated
        add_mod         - module of object being manipulated

        This is the latest version as of 1/1/98
Description
        This method saves the object being manipulated on a 
        channel off of the undo object, after deleting any objects
        previously placed on that channel.  If the object is a graphic
        set, it is placed on the GRundo.to_grset channel; otherwise
        it is placed on the GRcmpowner.to_components channel.
        The locatable and displayable bits of the object being
        manipulated are turned off.  If undo is turned off, the object
        is deleted immediately.

Notes
        Initially undo supports only "undelete"

History
        mrm     09/05/86    Creation
                10/14/86    OM 4.0 conversion
                09/23/87    Channel changes
                06/23/89    don't count on me->can_undo; check channel count
                07/24/89    ignore empty channel
        jhw     01/10/90    special check for reference file objects
      anand     09/10/97    Enhancements to delete command defining rules for
                            EMS objects with dependencies. 


	HF	04/01/98	VDS TR # 179800890
				Override of function delete_warn_notify() ONLY !!!
				

				Bugs
        Fence delete of reference file objects will result in an undisplayable
        /unlocatable reference file attachment but the clipping polygon will be
        unchanged.

	Jayadev	10/29/02	TR # MP5601

        
*/
class implementation GRundo;

#include <OMerrordef.h>
#include "grimport.h"
#include "grgsmacros.h"
#include "godef.h"
#include "madef.h"
#include "DImacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "alloca.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include "grmacros.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include <stdlib.h>
#include "nddef.h"

#include "VDmem.h"
#include "vdprdmacros.h"
#include "v_slc.h"
#include "v_slcdef.h"
#include "v_pplslc.h"
#include "v_dbgmacros.h"

from  NDnode import NDget_objects;
extern GRclassid OPP_ACpretend_class_id;

/*
*/

#define  FI_YES     100
#define  FI_NO      200 

IGRint delete_warn_notify(form_label, gadget_label, value, form_ptr )
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{

  switch(gadget_label)
  {
  case FI_YES:
    {
      long stat;
      int  rsp = EX_FORM_FINISHED;
      ex$putque(msg = &stat, response = &rsp);
//    FIf_erase(form_ptr);
      FIf_delete(form_ptr); form_ptr = NULL;		// HF: 04/01/98 TR # 179800890
      
      break;
    }
  case FI_NO:
    {
      long stat;
      int  rsp = EX_RJT_MOVEON;
      ex$putque(msg = &stat, response = &rsp);
//    FIf_erase(form_ptr);
      FIf_delete(form_ptr); form_ptr = NULL;		// HF: 04/01/98 TR # 179800890

      break;
    }
  }
  return(1);
}

void get_dependents(OM_S_OBJECT_LINKAGE *del_obj,
		    struct GRid         **disp_objs,
		    IGRint              *ndeps)
{
    IGRint             status;
    struct GRid        *buffer, delID, **pretendChild;
    struct GRid        *validChildList, *temp_list;
    int                count_c,count_i, nPretends;
    int                ii, jj, kk, nonPretends, tempCount;
    OMuint             childCount;
    GRclassid          obj_class;
    IGRint             *validChild, nValidChildren;
    IGRint             *pretendChildCount;
    OM_S_CHANSELECT    childChannel;
    // arg check
    if((!del_obj)||(!disp_objs)||(!ndeps)) goto wrapup;    

    // init 
    *ndeps           = 0;
    count_c          = 0;
    nPretends        = 0;
    nonPretends      = 0;
    tempCount        = 0;
    childCount       = 0;
    nValidChildren   = 0;
    temp_list        = NULL;
    validChildList   = NULL;
    validChild       = NULL;
    pretendChild     = NULL;
    pretendChildCount= NULL;

    delID.objid = del_obj->S_objid;
    delID.osnum = del_obj->osnum;

    status = om$send
	(msg      = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
						 NULL,0,&buffer,0,OM_K_MAXINT,&count_c),
	 senderid = NULL_OBJID,
	 targetid = delID.objid,
	 targetos = delID.osnum);

    if(!(status&1))
    {
	__DBGpr_obj("Failed in NDnode.NDget_objects: ND_CHILDREN for", delID); 
	goto wrapup;
    }
    if(count_c <= 0)
    {
	__DBGpr_obj("No ND_CHILDREN for", delID); 
	goto try_custom_delete;
    }
    __DBGpr_obj("Object being deleted ", delID); 
    __DBGpr_int("No. of children ", count_c);

    // is each child a valid one
    validChild = _MALLOC(count_c, IGRint );

    // list of children of each valid ACpretend child
    pretendChild = _MALLOC(count_c, struct GRid *);

    // count of children for each valid ACpretend child
    pretendChildCount = _MALLOC(count_c, IGRint );

    for(count_i=0 ; count_i<count_c ; count_i++) 
    {
	pretendChild[count_i]      = NULL;
	pretendChildCount[count_i] = 0;
	validChild[count_i]        = 0;
    }
    // loop on the children to find the no. of pretends;
    // non-pretend children are my direct children and children of ACpretends
    // Also need to account for objects on the notification channel
    //
    // validChild[index] = 0  - not a valid child
    // validChild[index] = 1  - valid ACpretend child
    // validChild[index] = 2  - valid non-ACpretend child
    childChannel.type       = OM_e_name;
    childChannel.u_sel.name = "children";

    for(count_i=0 ; count_i<count_c ; count_i++)
    {
	om$get_classid(osnum     = buffer[count_i].osnum,
		       objid     = buffer[count_i].objid,
		       p_classid = &obj_class);


	if(((om$is_ancestry_valid(subclassid = obj_class,superclassid = OPP_ACpretend_class_id) == OM_S_SUCCESS)))
	{
	    // check to see if these pretends have any children; 
	    // if they do, then they are legal guys or else
	    // they are fake pretends
	    _FREE(temp_list);
	    tempCount = 0;
	    childCount = 0;
	    // get the no. of children and then allocate the temp_list
	    om$get_channel_count ( osnum            = buffer[count_i].osnum,
				   objid            = buffer[count_i].objid,
				   p_chanselect     = &childChannel,
				   count            = &childCount );
	    if(childCount <= 0) continue;

	    temp_list = _MALLOC(childCount, struct GRid);

	    status = om$send
		(msg      = message NDnode.NDget_objects(ND_CHILDREN,
							 temp_list,childCount,NULL,0,OM_K_MAXINT,&tempCount),
		 senderid = NULL_OBJID,
		 targetid = buffer[count_i].objid,
		 targetos = buffer[count_i].osnum);
	    if(!(status&1))
	    {
		__DBGpr_obj("Failed in NDnode.NDget_objects: ND_CHILDREN for", buffer[count_i]);
		goto wrapup;
	    }
	    if(tempCount>0) 
	    {
		// this is a valid ACpretend child of the delete object
		validChild[count_i] = 1;

		// store all the children (list and number) of this ACpretend
		// to fill in the final output list

		pretendChild[count_i] = _MALLOC(tempCount, struct GRid);
		pretendChildCount[count_i] = tempCount;
		for(ii=0; ii<tempCount; ii++)
		{
		    pretendChild[count_i][ii] = temp_list[ii];
		}

		// All the children of this ACpretend are dependents 
		nValidChildren += tempCount;
		nPretends ++;
	    }
	}
	else
	{
	    // this is a valid direct child(non-ACpretend) 
	    // and hence dependent of the delete object
	    validChild[count_i] = 2;
	    nValidChildren ++;
	    nonPretends ++;
	}

    }
    _FREE(temp_list);
    // we may have children who are all invalid

    if(nValidChildren == 0)
    {
	__DBGpr_obj("No VALID ND_CHILDREN for", delID); 
	goto try_custom_delete;
    }

    validChildList = _MALLOC(nValidChildren, struct GRid);

    kk = 0;
    for(ii=0; ii<count_c; ii++)
    {
	// make sure you are handling a valid child
	if(validChild[ii] != 0)
	{
	    switch(validChild[ii])
	    {
		case 1:    // valid ACpretend child

		    for(jj=0; jj<pretendChildCount[ii]; jj++)
		    {
			validChildList[kk] = pretendChild[ii][jj];
			kk++;
		    }
		    break;
		case 2:    // valid non-ACpretend child
		    validChildList[kk].objid = buffer[ii].objid;
		    validChildList[kk].osnum = buffer[ii].osnum;
		    kk++;
		    break;
	    }
	}
    }

try_custom_delete:
    /*
     * ISDP SPECIFIC CUSTOM-DELETION.  MOTIVATION: I/STRUCT'S VSbooBeam
     * objects do not have any 'valid' children/dependents, yet when they are
     * deleted, their parents get deleted as well.  Call PPL that does these
     * checks, and attempt to get the dialog box popping up at other instances
     */
    {
	struct GRobj_env ObjToBeDelOE, CustChildOE;
	IGRint		 NumCustChild=0;

	/* Set our object-to-be-deleted as the input object for our PPL. */
	ObjToBeDelOE.obj_id = delID;

	vd$ppl_set_size( which_info = INPUT_INFO,
			 size = 1);

	vd$ppl_setarg_at_index( which_info = INPUT_INFO,
				index = 0,
				type  = VD_object,
				value = &ObjToBeDelOE );

	if( vd$prd_get_product_info( run_name = "Struct" ) == TRUE )
	{
	    /* Call the PPL. */
	    vd$ppl_exec( file_name = "ISDP_CustDel",
			 func_name = "Struct_CustomDel" );

	    /* Get the objects returned by our PPL and append it to the
	     * validChildList.
	     */
	    vd$ppl_get_size( which_info = OUTPUT_INFO,
			     size = &NumCustChild );
	}

	if( NumCustChild )
	{
	    if( nValidChildren )
	    {
		__DBGpr_int("Attempting to realloc",
						 nValidChildren+NumCustChild);
		validChildList = _REALLOC( validChildList,
					   nValidChildren+NumCustChild,
					   struct GRid );
		__CheckPtr(validChildList,"Unable to realloc validChildList",
			   wrapup);
	    }
	    else
	    {
		__DBGpr_int("Attempting to malloc",NumCustChild);
		validChildList = _CALLOC(NumCustChild, struct GRid);
		__CheckPtr(validChildList,"Unable to malloc validChildList",
			   wrapup);
	    }

	    for( ii=0 ; ii<NumCustChild ; ++ii )
	    {
		IGRint ArgType=VD_object;
		vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
					index	= ii,
					type	= &ArgType,
					value	= &CustChildOE );
		__DBGpr_obj("From ppl_getarg",CustChildOE.obj_id);

		validChildList[nValidChildren+ii] = CustChildOE.obj_id;
		__DBGpr_obj("Adding to Valid Child List",
					   validChildList[nValidChildren+ii]);
	    }
	    nValidChildren += NumCustChild;
	}

	/* Cleanup. */
	vd$ppl_free_args( which_info = INPUT_INFO );
	vd$ppl_free_args( which_info = OUTPUT_INFO );
    }

    // set the output
    *ndeps = nValidChildren;
    *disp_objs = validChildList;

    __DBGpr_int("No. of ACpretends with children ", nPretends);
    __DBGpr_int("No. of non-ACpretend children ", nonPretends);
    __DBGpr_int("Total No. of valid children -- nValidChildren ", nValidChildren);
    __DBGpr_int("Total No. of valid children -- kk ", kk);
    __DBGpr_objlist("Valid Child ", nValidChildren, validChildList);
wrapup:
    if(pretendChild)
    {
	for(count_i=0; count_i<count_c; count_i++)
	    // make sure its a valid ACpretend with children
	    if((validChild[count_i] == 1) && (!pretendChild[count_i]))
	    {
		_FREE(pretendChild[count_i]);
	    }
	_FREE(pretendChild);
    }
    _FREE(temp_list);
    _FREE(validChild);
    _FREE(pretendChildCount);
    return;
}
end implementation GRundo;
