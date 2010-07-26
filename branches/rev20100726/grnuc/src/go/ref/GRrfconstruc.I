/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRconstruct - construct method for the GRreffile class.

Synopsis
    	GRconstruct(arglist)
	
	struct GRvg_construct *arglist;	generic input for all
			classes under GRvg.
Description
	This method loads the instance data of the GRreffile
	object.  

	Additional input information, other than what is 
	specified in the generic GRvg_construct structure, is
	needed by this method.  The additional information is 
	defined in the following structure.

	struct GRrf_info
	{
    	    IGRchar *filename;	 	ptr to file name	
    	    IGRchar *named_view;	ptr to named view name
    	    IGRchar *description;	ptr to the description
    	    struct IGRcv_prism *clip_poly;  ptr to clipping prism
	    IGRchar *prism_classname;   ptr to classname of
					underlying geometry of the
					face of the prism (i.e., if
					the prism is a rectangular cube, 
					the classname is GR3dorthpoly)
       	    IGRint unsigned *ref_properties; reference file properties
            IGRchar *scale;		 string to define scale factor 
	};

	This structure is passed in the GRvg_construct structure as
	class_attr.  This is done as follows:

	struct GRrf_info info;
	struct GRvg_construct arglist;

	arglist.class_attr = (IGRchar *) &rf_info;

	If any of the fields in the GRrf_info structure do not
	apply to your application, you should send in a NULL 
	pointer. The method will check for NULL pointers.

	The filename is the name of the file you want to attach as
	reference file.  This is not a mandatory entry, you
	may construct an empty reference file attachment object 
	and actually attach the file later using the method,
	GRattachfile. 

	The named view is an optional entry.  You may not, however
	specify a named view without specifying a filename.  If
	this occurs, the named view sent in will be ignored.

	The description is an optional entry which associates a
	description with this attachment "window".  When a saved
	view is attached, the description of the saved view is 
	used.

	The clip_poly allows you to input a clipping polygon
	to define the clipping boundaries of your attachment.
	The final clipping polygon will be determined as the
	minimum intersection prism of the the input prism and
	the saved view (if any).

	The ref_properties allow you to set the properties for
	your reference file attachment.  You should use the masks
	defined in refdef.h to set up your properties.

	The scale is an optional entry.  This allows the option
	of storing a string defining the scale factor with the
	attachment.  This gives the commands a means to find
	the scale factor associated with a reference file 
	attachment.  This scale will be applied to the attachment.
	
Diagnostics
	The possible return code values in the arglist->msg 
	field are:

	MSSUCC - successful completion
	GRFILENOTFOUND - requested file not found
	GRVIEWNOTFOUND - requested saved view not found
	GR_I_INV_REQUEST - requested name could not be used, object
	   was constructed but is not named.
	OM_E_NO_OS_AVAIL - no more object spaces can be opened
	MSFAIL - error
Notes
	None.

History
	MAS  	08/20/86 	Design date.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "dpdef.h"
#include "refpriv.h"
#include "refdef.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "grerr.h"
#include "grownmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"

from GRmodule import GRmdaddwrng;
from GRcontext import GRdeletectx;

extern    IGRboolean    MAmulmx();
extern    IGRboolean    MAcpfrlb();

method GRconstruct(struct GRvg_construct *arglist)
{
    GRobjid mod_objid;			/* reference module id		*/
    GRobjid polygon;			/* clipping polygon objid	*/
    GRspacenum mod_osnum;		/* object space number of space
    					   of reference file		*/
    OM_S_CHANSELECT  to_chan,fr_chan;

    struct GRid	mgr_id,			/* reference manager info	*/
		context,
		view_id,
		ref_id;
    struct GRrf_info *rf_info;		/* information passed as class
					   attributes			*/
 
    IGRchar  	osname[OM_K_MAXOSNAME_LEN],
		logical[DI_PATH_MAX];

    IGRboolean	constr_flag=TRUE;	/* flag for update		*/

    IGRshort 	mx_size;		/* matrix size			*/
		
    IGRlong 	i;			/* loop index			*/
    IGRlong 	OMmsg,			/* local return codes		*/
		type;
    IGRlong 	msg;    
    IGRint  	count,
		flag;

    IGRuint     my_tag;

    IGRboolean 	intersect;

    IGRdouble 	points[30];		/* for curve prism		*/
    IGRdouble 	knots[12];		/* for curve prism		*/

    IGRmatrix   tmatrix;
			
    struct IGRlbsys *input_lbsys,lbsys;	/* local bounded system		*/
    struct IGRcv_prism curve_prism;	/* curve prism			*/
    struct GRvg_construct local_arglist;/* local arglist for clippoly	*/
    struct GRmd_env local_env;


    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *(arglist->msg) = MSSUCC;
    polygon = NULL_OBJID;
	
    rf_info = (struct GRrf_info *)arglist->class_attr;
					/* set the properties		*/
    me->properties=(arglist->properties | GRIS_NEW) & (~GRFILLED_DISPLAY);
					/* set reference file properties*/
    me->ref_properties = (rf_info->ref_properties ? 
		*rf_info->ref_properties : GRRF_IS_READ_ONLY);

	/* temporary KLUDGE for OM flag  */

    flag = om$enable_tagging(flag=TRUE);

    om$add_tag(objid = my_id,
	p_tag = &my_tag);

    if (rf_info->scale)			/* load the scale string	*/
    {
	om$vla_set_dimension(varray = me->scale_factor,
 	    size = (strlen(rf_info->scale) + 1));
	strcpy(me->scale_factor,rf_info->scale);
    }

    if (rf_info->description)		/* load the description		*/
    {
	om$vla_set_dimension(varray = me->description,
	    size = (strlen(rf_info->description) + 1));
	strcpy(me->description,rf_info->description);
    }
 					/* load symbology		*/
    if (arglist->display)
    {
	me->display_attr = *(arglist->display);
    }
    me->level =  arglist->level;

					/* pointer to geometry		*/
    input_lbsys = (struct IGRlbsys *)arglist->geometry;

    if (rf_info->filename)
    {
					/* load filename into instance	*/
	om$vla_set_dimension(varray = me->filename,
	    size = (strlen(rf_info->filename) + 1));
    	strcpy(me->filename,rf_info->filename);

					/* create the reference manger	*/
	OMmsg = ex$get_super(
	    mod_id = arglist->env_info->md_id.objid,
	    mod_osnum = arglist->env_info->md_id.osnum,
	    super_name = "Ref Mgr",
	    super_class = "Super_rfmgr",
	    create = 1,
	    super_id = &mgr_id.objid,
	    super_osnum = &mgr_id.osnum);

	/* form the name for the attachment, this is also the
	 * name for mounting the directory system
	 */

	ref_id.objid = my_id;
	ref_id.osnum = OM_Gw_current_OS;

	if (rf_info->filename)
	{
            OMmsg = GRname_reffile(arglist->msg,arglist->name,
		rf_info->filename,&ref_id,&constr_flag,logical);

	    if (! (1 & OMmsg))
	    {
	         goto wrapup;
	    }
	}

	/* Open the reference file.  This function also verifies if
	 * the saved view is valid.
	 */

	OMmsg = GRopenfile(arglist->msg,arglist->env_info,&my_id,
		rf_info->named_view,logical,&mod_osnum,&mod_objid,osname,
		&view_id,&context);

	if ( ! (1 & OMmsg & *(arglist->msg)))
	{
	    goto wrapup;
	}
    }
    if ( 1 & OMmsg)
    {
    	OMmsg = GRloadinstance(arglist->msg,rf_info->scale,
	    &arglist->env_info->md_id.osnum,&mod_osnum,rf_info->filename,
	    input_lbsys,&view_id,&my_id,
	    me->ref_to_master_matrix,me->master_to_ref_matrix,
	    me->vw_rotation,me->vw_volume,me->dp_levels,me->vw_origin,
	    &me->ref_properties);

	if (rf_info->named_view)	/* load named view in instance	*/
	{
	    om$vla_set_dimension(varray = me->saved_view,
		size = (strlen(rf_info->named_view) +1));
				
	    strcpy(me->saved_view,rf_info->named_view);
	}
	if ( (1 & OMmsg) && (rf_info->filename))
	{
	    /* the context object for this attachment must be updated	
	     */

	    OMmsg = GRupdcontext(&msg,arglist->env_info,
		me->ref_to_master_matrix,&constr_flag,&my_id,&context);
	}
    }

    /* 
     * The clip polygon must now be constructed, if one has been
     * sent in use it. If not, the saved view is used.
     */

    if (1 & OMmsg)
    {
	local_arglist = *arglist;
	local_arglist.name = NULL;
	local_arglist.properties = me->properties;
	local_env = *(arglist->env_info);
	local_arglist.env_info = &local_env;
	local_env.md_id.objid = NULL_OBJID;

	if (rf_info->filename)
	{
	    for (i=0; i<3; ++i)
	    {
		lbsys.diag_pt1[i] = me->vw_volume[i];
		lbsys.diag_pt2[i] = me->vw_volume[i+3];
	    }

	    MAlswcmx(&msg,me->vw_origin,me->vw_rotation,tmatrix);
	    mx_size = 4;
	    MAmulmx(&msg,&mx_size,&mx_size,&mx_size,
	    	me->ref_to_master_matrix,tmatrix,lbsys.matrix);

				/* load pointers for clip function	*/
	    curve_prism.curve.poles = points;
	    curve_prism.curve.weights = 0;
	    curve_prism.curve.knots = knots;

	    /* If a clipping polygon was sent in, the minimum intersection
	     * view must be computed.  This is the minimum intersection 
	     * of the saved view in the reference file positioned in the 
	     * master file and the input clipping polygon.
	     */
	   
	    if (rf_info->clip_poly)
	    {		
		if (GRrefvwclp(&msg,&lbsys,rf_info->clip_poly,&intersect,
			&curve_prism))
		{
		    if (! rf_info->prism_classname)
		    {
      	    	        local_arglist.class_attr = "GR3dorthpoly";
		    }
		    else
		    {
			local_arglist.class_attr=rf_info->prism_classname;
		    }
	    	}
	    }
	    else
	    {	
	    	/* call routine to form curve prism from local
	     	 * bounded system.
	     	 */

	        if (MAcpfrlb(&msg,&lbsys,&curve_prism))
		{		
	    	    local_arglist.properties  &= 
		   	(~GRIS_DISPLAYABLE);
      	    	    local_arglist.class_attr = "GR3dorthpoly";
		}
		else
		{
		    OMmsg = OM_E_ABORT;
		    *(arglist->msg) = MSFAIL;
		}
	    }
      	    local_arglist.geometry = (IGRchar *)&curve_prism;
    	}
	else
	{
	    if (rf_info->prism_classname)
	    {
	        local_arglist.class_attr = rf_info->prism_classname;
	    }
	    else
	    {
	        local_arglist.class_attr = "GRbcsubbc";
	    }

      	    local_arglist.geometry = (IGRchar *)rf_info->clip_poly;
	}
	if ( 1 & OMmsg & *(arglist->msg))
	{
				/* construct object			*/
	    OMmsg = om$construct(
	       classname = "GRclippoly",
	       p_objid = &polygon,
	       msg = message GRgraphics.GRconstruct(&local_arglist));

	    if (1 & OMmsg)	/* the objects must be connected	*/
	    {
				/* set up chanselects			*/
	        fr_chan.type = OM_e_addr;
	        fr_chan.u_sel.addr = &me->to_clip;

	        om$make_chanselect(channame = "GRclippoly.to_attachment",
			p_chanselect = &to_chan);

				/* connect the objects			*/
	        OMmsg = om$send(
		    msg = message Root.connect
			 (to_chan,0,my_id,OM_Gw_current_OS,fr_chan,0),
	  	    targetid = polygon);
	    }
        }	    
    }
    if (OMmsg & 1)
    {
        /* 
	 * compute the range of the reference file attachment
	 * in the coordinate system of the master file for
	 * insertion in the master file R-tree.
	 *
	 * The range for the R-tree pass in the reference 
	 * space must also be computed if we opened a file.
	 * 
	 */

	if (rf_info->filename)
	{
            OMmsg = GRgetranges(&msg,arglist->env_info,
		local_arglist.geometry,me->master_to_ref_matrix,
		&my_id,&polygon,me->range);
	}
	else
	{
            OMmsg = GRgetranges(&msg,arglist->env_info,
		local_arglist.geometry,me->master_to_ref_matrix,
		&my_id,&polygon,NULL);
	}	    	    
    }

    if (! (1 & OMmsg))		/* if there was an error		*/
    {				/* delete object space 			*/
	count = om$dimension_of(varray = me->osname);

	if (count)
	{ 

	    type = 3;		/* don't write; indicate construct failed*/
	    om$send(msg = message GRreffile.GRrfclose(&msg,&type),
		targetid = my_id);

	    om$send(msg = message GRcontext.GRdeletectx
		    	(&msg,arglist->env_info),
		targetid = context.objid,
		targetos = context.osnum);
	}
    }
    else
    { 
	if (! rf_info->filename)
	{
				/* get the Super_rfmgr			*/
	    OMmsg = ex$get_super(mod_id = arglist->env_info->md_id.objid,
	    	mod_osnum = arglist->env_info->md_id.osnum,
	    	super_name = "Ref Mgr",
	    	super_class = "Super_rfmgr",
		create = 1,
	    	super_id = &mgr_id.objid,
	    	super_osnum = &mgr_id.osnum);
	}
        if (1 & OMmsg)
        {			/* set up channel info to Super		*/
       	    to_chan.type = OM_e_name;
	    to_chan.u_sel.name = "Super_rfmgr.mgr";

	    fr_chan.type = OM_e_addr;
	    fr_chan.u_sel.addr = &me->to_mgr;

	    i = OM_K_MAXINT;

				/* connect attachment to Super		*/
	    OMmsg = om$send (
		msg = message Root.connect(
			to_chan,i,my_id,OM_Gw_current_OS,fr_chan,i),
		senderid = my_id,
		targetid = mgr_id.objid,
		targetos = mgr_id.osnum);
 	}
    }

wrapup:
    if ( 1 & OMmsg)
    {
	gr$add_to_active_owner(
		msg = &msg,
		mod_env = arglist->env_info,
		objid = my_id);

        /* notify display list of new reference file attachment */
        DPdlist_set_object_space_scales();
    }

    om$enable_tagging(flag=flag);

    return( OMmsg );
}
end implementation GRreffile;
