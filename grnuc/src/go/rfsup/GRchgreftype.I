/*\
Name
    	GRchgreftype - This function is created to change the reference file
	attachement type.
Synopsis

	IGRint GRchgreftype(msg, ref_id, ref_os, file_name, background)
	IGRlong *msg;		Completion code.
	OM_S_OBJID ref_id;	reference attachement id.
	OMuword ref_os;		reference attachement osnum.
	IGRchar *attach_name;	reference attachement name.
	IGRboolean background;  reference attachement type to be set.

Description

	This function is used to change a reference file attachment type.
	The available types are normal and background.  Background
	attachments are only retrieved when attached to the master file.
	The user can specify the attachement to be changed by either
	attachment object id or by attachment filename.

Diagnostics

	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - invalid args passed in

History
        poo     12/14/92    Creation date.
\*/

class implementation Root;

#include <grimport.h>
#include <stdio.h>
#include <OMminimum.h>
#include <OMindex.h>
#include <igrtypedef.h>
#include <igetypedef.h>
#include <igr.h>
#include <gr.h>
#include <msdef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <msdef.h>
#include <msmacros.h>
#include <ref.h>
#include <refdef.h>
#include <DIdef.h>
#include <grdpb.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>

from Super_rfmgr import GRget_channel_count, GRget_channel_objects;
from GRreffile import GRinquireref, GRchgrfprops;

IGRint GRchgreftype(msg, ref_id, ref_os, attach_name, background)
IGRlong *msg;
OM_S_OBJID ref_id;
OMuword ref_os;
IGRchar *attach_name;
IGRboolean background;
{
	char aname[DI_PATH_MAX], *sname;
	short nest, flag;
	IGRboolean pass;
	int sts, i, which_error;
	int sizbuf, nret;
	long count, out_count;
	unsigned long props, ref_properties;
	struct GRid refmgr, ref_grid;
	struct GRinquire_list requests[3];
	OM_S_OBJID *objids = NULL;
	OMuword *osnums = NULL;
	struct GRmd_env md_env;

	sizbuf = sizeof(struct GRmd_env);
	gr$get_module_env(
		msg = msg,
		sizbuf = &sizbuf,
		buffer = &md_env,
		nret = &nret);
	if ( !(*msg & 1) )
	{
		/*printf("Get module info failed: %x\n", *msg);*/
		return(MSSUCC);
	}

	if (ref_id == NULL_OBJID)
	{
		/*printf("Get the reference super\n");*/

		sts =
		ex$get_super (
			mod_id = md_env.md_id.objid,
			mod_osnum = md_env.md_id.osnum,
			super_name = "Ref Mgr",
			super_class = "Super_rfmgr",
			create = 0,
			super_id = &refmgr.objid,
			super_osnum = &refmgr.osnum );
		if ( !(sts & 1) )
		{
			*msg = MSFAIL;
			return(MSSUCC);
		}

		/*printf("refmgr: (%d,%d)\n", refmgr.objid, refmgr.osnum);*/
		nest = FALSE;
		props = 0;

		sts =
		om$send(msg = message Super_rfmgr.GRget_channel_count(
							msg,
							&props,
                                                        &nest,
							&count),
			senderid = NULL_OBJID,
	        	targetid = refmgr.objid,
        	        targetos = refmgr.osnum);
		if (!(sts & *msg & 1))
    		{
        		/*printf("Failed to get attachment count in space %d: ", refmgr.osnum);*/
		        /*printf("%#x, %#x\n", sts, *msg);*/
        		return(MSSUCC);
		}

		/*printf("attachment count = %d\n", count);*/

		osnums = (OMuword *)om$malloc(size = count * sizeof(OMuword));
		objids = (OM_S_OBJID *)om$malloc(size = count * sizeof(OM_S_OBJID));

		/*printf("getting attachment list \n");*/

		sts =
		om$send(msg = message Super_rfmgr.GRget_channel_objects(
        							msg,
								&props,
								&nest,
								&count, 
								objids,
								osnums,
								&out_count),
			senderid = NULL_OBJID,
	                targetid = refmgr.objid,
        	        targetos = refmgr.osnum);
		if (!(sts & *msg & 1) || count != out_count)
		{
        		/*printf("Failed to get attachment list in space %d\n", refmgr.osnum);*/
		        /*printf("%d, %d\n", sts, *msg);*/
        		/*printf("count = %d, out_count = %d\n", count, out_count);*/
			if (objids) free(objids);
			if (osnums) free(osnums);
	        	return(MSSUCC);
		}

		/*printf("retrieve info about the files attached to master file\n");*/

		ref_grid.objid = NULL_OBJID;

		if (attach_name)
		{
			/*printf("check for attach_name <%s>\n", attach_name);*/

			i = 0;
			requests[i].var = REFERENCE_NAME;
			requests[i].num_requested = DI_PATH_MAX;
	       		requests[i].var_ptr = aname;

			i = i + 1;
			requests[i].var = END_REPORT_REQUEST;
			requests[i].var_ptr = NULL;
			requests[i].num_requested = 0;

			pass = FALSE;

			for (i=0; i<count; i++)
			{
			        sts =
				om$send(msg = message GRreffile.GRinquireref(
								msg,
                	                                        &md_env,
                        	                                requests,
                                	                        &which_error,
                                                	        &pass,
                                        	                NULL),
					senderid = NULL_OBJID,
		                        targetid = objids[i],
        		                targetos = osnums[i]);
	        		if (!(sts & *msg & 1))
	        		{
			            /*printf("Failed to get ref name: %#x, %#x\n", sts, *msg);*/
				    if (objids) free(objids);
				    if (osnums) free(osnums);
        			    return(FALSE);
			        }

				sname = &aname[strlen(aname)-1];
				while ((sname != aname) && (*sname != ':'))
					sname--;
				sname++;

				if (!strcmp(sname, attach_name))
				{
					/*printf("file name found\n");*/
	
					ref_grid.objid = objids[i];
					ref_grid.osnum = osnums[i];
					break;
				}
			}
		}

		if (ref_grid.objid == NULL_OBJID)
		{
			/*printf("Failed to get ref name: %s\n", attach_name);*/
			if (objids) free(objids);
			if (osnums) free(osnums);
			*msg = MSFAIL;
			return(MSSUCC);
		}
	}
	else
	{
		ref_grid.objid = ref_id;
		ref_grid.osnum = ref_os;
	}

	ref_properties = GRRF_BACKGROUND;
	flag = background;

	if (ref_grid.osnum != md_env.md_id.osnum)
	{
		/*printf("Cannot change reference type, attachment not in current file\n");*/
		/*printf("osnum = %d\n", ref_grid.osnum);*/
		if (objids) free(objids);
		if (osnums) free(osnums);
		*msg = MSFAIL;
		return(MSSUCC);
	}

	/*printf("object = %d, %d\n", ref_grid.osnum, ref_grid.objid);*/

        sts =
	om$send(msg = message GRreffile.GRchgrfprops(
						msg,
						&flag,
						&ref_properties),
		senderid = NULL_OBJID,
		targetid = ref_grid.objid,
                targetos = ref_grid.osnum);
	if (!(sts & 1))
	{
		/*printf("sts = %#x, msg = %#x\n", sts, *msg);*/
		if (objids) free(objids);
		if (osnums) free(osnums);
		return(MSSUCC);
	}

	if (objids) free(objids);
	if (osnums) free(osnums);

	return(MSSUCC);
}

end implementation Root;

