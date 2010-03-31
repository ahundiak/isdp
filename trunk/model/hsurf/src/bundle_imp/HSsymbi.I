
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

class implementation HSsymb;

#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "exmacros.h"
#include "igrdp.h"

#include "hstabdef.h"
#include "hssymb.h"
#include "hstabmacros.h"
#include "hssymbmacros.h"
#include "hsurf.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"


static OM_S_CHANSELECT notification_chanselect, to_parent_chanselect;

%safe
static IGRint notification_crea=0;
static IGRint to_parent_crea=0;
%endsafe

method  super_construct()
{
   IGRint	status = TRUE;
   IGRlong	msg;
   short	num_fields;
   short	sizes[10];
   short	offsets[10];
   GRobjid	reg_symb_objid,modid;
   struct HS_symb	reg_symb;
   struct HSbundsymb	symb;


  /* construct the HStable class that will keep track of regular symbology	*/
	ex$get_modid( mod_osnum = OM_Gw_current_OS, mod_id = &modid );

	status=	ex$attach_super(super_class = "HStable",
			super_id = &reg_symb_objid,modid=modid,mod_osnum=OM_Gw_current_OS);
	if( !( 1 & status) )
	{
		om$report_error(sts=status);
	}
				

  /* set up sizes and offsets for regular symbology		*/

	sizes[0] = sizeof (reg_symb.tex_index);
	sizes[1] = sizeof (reg_symb.shad_style);
	sizes[2] = sizeof (reg_symb.tex_orient);
	sizes[3] = sizeof (reg_symb.finish);
	sizes[4] = sizeof (reg_symb.trans);
	sizes[5] = sizeof (reg_symb.diff_refl);
	sizes[6] = sizeof (reg_symb.spec_refl);
	sizes[7] = sizeof (reg_symb.red);
	sizes[8] = sizeof (reg_symb.green);
	sizes[9] = sizeof (reg_symb.blue);

	offsets[0] = (IGRint) &reg_symb.tex_index - (IGRint) &reg_symb;
	offsets[1] = (IGRint) &reg_symb.shad_style - (IGRint) &reg_symb;
	offsets[2] = (IGRint) &reg_symb.tex_orient - (IGRint) &reg_symb;
	offsets[3] = (IGRint) &reg_symb.finish - (IGRint) &reg_symb;
	offsets[4] = (IGRint) &reg_symb.trans - (IGRint) &reg_symb;
	offsets[5] = (IGRint) &reg_symb.diff_refl - (IGRint) &reg_symb;
	offsets[6] = (IGRint) &reg_symb.spec_refl - (IGRint) &reg_symb;
	offsets[7] = (IGRint) &reg_symb.red - (IGRint) &reg_symb;
	offsets[8] = (IGRint) &reg_symb.green - (IGRint) &reg_symb;
	offsets[9] = (IGRint) &reg_symb.blue - (IGRint) &reg_symb;

	num_fields = 10;

  /* define entry for regular symbology			*/

	status = om$send (	mode = OM_e_wrt_object,
				msg =  message HStable.define_entry(&msg,num_fields,sizes,
								   offsets),
				senderid = my_id,
	   			targetid = reg_symb_objid);
	 

  /* define the HSsymb class entry			*/

	sizes[0] = sizeof (symb.hs_symb_index);
	sizes[1] = sizeof (symb.app_symb_index);
	sizes[2] = sizeof (symb.csw_symb_index);

	offsets[0] = (IGRint) &symb.hs_symb_index - (IGRint) &symb;
	offsets[1] = (IGRint) &symb.app_symb_index - (IGRint) &symb;
	offsets[2] = (IGRint) &symb.csw_symb_index - (IGRint) &symb;

	num_fields = 3;
	status = om$send (	mode = OM_e_wrt_object,
				msg =  message HStable.define_entry(&msg,num_fields,sizes,
								   offsets),
				senderid = my_id,
	   			targetid = my_id);
 
	 


  /* connect the regular symbology to the notification channel (slot 0) of the 
     HSsymb object								*/
  	
 	if (!notification_crea)
        {
		status= om$make_chanselect(channame="HStable.notification",
				        	p_chanselect=&notification_chanselect); 
		notification_crea=1;
	}

  	if (!to_parent_crea)
        {
		to_parent_chanselect.type=OM_e_name;
                to_parent_chanselect.u_sel.name="HStable.to_parent"; 
		to_parent_crea=1;
	}
	
	status = om$send (
				msg =  message Root.connect(to_parent_chanselect,0,my_id,OM_Gw_current_OS,
							   notification_chanselect,0),
				senderid = my_id,
	   			targetid = reg_symb_objid);
       if( !(1 & status) )
        {
            om$report_error(sts=status);
        }

	 

	return(status);

}


method	add_entry( IGRlong   *msg; IGRchar *entry;  IGRint flags; IGRint *index)
{

    IGRint	status = TRUE;
    IGRint	        reg_symb_index;
    struct HS_symb	hs_symb;
    struct HSbundsymb	symbology;
    struct HS_symb_and_app	*disp_attr;

	*msg = MSSUCC;
	disp_attr = (struct HS_symb_and_app *) entry;

  /* extract the regular symbology			*/
	hs_symb.shad_style = disp_attr->shad_style;
	hs_symb.tex_orient = disp_attr->tex_orient;
	hs_symb.tex_index = disp_attr->tex_index;
	hs_symb.finish= disp_attr->finish;
	hs_symb.trans= disp_attr->trans;
	hs_symb.diff_refl= disp_attr->diff_refl;
	hs_symb.spec_refl= disp_attr->spec_refl;
	hs_symb.red= disp_attr->red;
	hs_symb.green= disp_attr->green;
	hs_symb.blue= disp_attr->blue;

  /* send add to regular symbology object		*/


 	if (!notification_crea)
        {
		status= om$make_chanselect(channame="HStable.notification",
				        	p_chanselect=&notification_chanselect); 
		notification_crea=1;
	}

  	if (!to_parent_crea)
        {
		to_parent_chanselect.type=OM_e_name;
                to_parent_chanselect.u_sel.name="HStable.to_parent"; 
		to_parent_crea=1;
	}
	
	status = om$send ( mode = OM_e_wrt_object,
			   msg = message  HStable.add_entry(msg,(IGRchar *) &hs_symb, 0, &reg_symb_index),
			   p_chanselect = &notification_chanselect,
			   senderid = my_id,
			   from = 0,
			   to = 0);

  /* set up HSsymb structure that needs to be added	*/
   
	symbology.hs_symb_index = reg_symb_index;
	symbology.app_symb_index = disp_attr->app_symb_index;
	symbology.csw_symb_index = 0;



  /* now that we have the regular symbolgy index, send wrt to message to add entry	*/

	
	status = om$send ( mode = OM_e_wrt_message,
			   msg =  message HStable.add_entry(msg,(IGRchar *) &symbology,flags,index),
			   senderid = my_id,
			   targetid = my_id);

	return(status);
}


method	 create_entry(IGRlong *msg; IGRchar *entry; IGRint flags; IGRint *index)
{

    IGRint	status = TRUE;
    IGRint	reg_symb_index;
    struct HS_symb	hs_symb;
    struct HSbundsymb	symbology;
    struct HS_symb_and_app  *disp_attr;

	*msg = MSSUCC;
	disp_attr = (struct HS_symb_and_app *) entry;


  /* extract the regular symbology			*/
        hs_symb.shad_style = disp_attr->shad_style;
        hs_symb.tex_orient = disp_attr->tex_orient;
        hs_symb.tex_index = disp_attr->tex_index;
        hs_symb.finish= disp_attr->finish;
        hs_symb.trans= disp_attr->trans;
        hs_symb.diff_refl= disp_attr->diff_refl;
        hs_symb.spec_refl= disp_attr->spec_refl;
        hs_symb.red= disp_attr->red;
        hs_symb.green= disp_attr->green;
        hs_symb.blue= disp_attr->blue;



  /* send create to regular symbology object		*/

 	if (!notification_crea)
        {
		status= om$make_chanselect(channame="HStable.notification",
				        	p_chanselect=&notification_chanselect); 
		notification_crea=1;
	}

  	if (!to_parent_crea)
        {
		to_parent_chanselect.type=OM_e_name;
                to_parent_chanselect.u_sel.name="HStable.to_parent"; 
		to_parent_crea=1;
	}
	
	status = om$send ( mode = OM_e_wrt_object,
			   msg = message  HStable.create_entry(msg,(IGRchar *) &hs_symb, flags, &reg_symb_index),
			   p_chanselect = &notification_chanselect,
			   senderid = my_id,
			   from = 0,
			   to = 0);

  /* set up HSsymb structure that needs to be created	*/

	symbology.hs_symb_index = reg_symb_index;
	symbology.app_symb_index = disp_attr->app_symb_index;
	symbology.csw_symb_index = 0;
        
  /* now that we have the regular symbolgy index, send wrt to message to create entry	*/
	
	status = om$send ( mode = OM_e_wrt_message,
			   msg =  message HStable.create_entry(msg,(IGRchar *) &symbology, flags, index),
			   senderid = my_id,
			   targetid = my_id);
	return(status);
}



method	retrieve_entry(
IGRlong *msg; 
IGRint index; 
IGRchar *entry)
{

    IGRchar	*inst_entry_ptr;
    IGRint	inst_entry_size;
    IGRint	status = TRUE;
    struct HS_symb	hs_symb;
    struct HSbundsymb	*symbology;
    struct HS_symb_and_app *disp_attr;


  /* make sure entry has been defined					*/

	if (ME.HStable->num_fields > 0)
	{
  /* make sure index is valid			*/

	    if (index < ME.HStable->num_entries)
	    {
		disp_attr = (struct HS_symb_and_app *) entry;
		inst_entry_size = ((ME.HStable->entry_size + 3) & 0xfffffffc) + sizeof (IGRint);

		inst_entry_ptr = &ME.HStable->entries[index * inst_entry_size];

  /* make sure entry is not deleted				*/

		if (!(*(IGRint *) inst_entry_ptr & HSENTRY_DELETED))
		{
	

		    symbology =  (struct HSbundsymb *) (inst_entry_ptr + 4);


  /* send to get regular symbology structure			*/

	    	    if (!notification_crea)
		    {
		    	    status= om$make_chanselect(channame="HStable.notification",
			    				    p_chanselect=&notification_chanselect); 
			    notification_crea=1;
		    }

		    if (!to_parent_crea)
		    {
		    	    to_parent_chanselect.type=OM_e_name;
			    to_parent_chanselect.u_sel.name="HStable.to_parent"; 
			    to_parent_crea=1;
		    }
	
		    status = om$send (	mode = OM_e_wrt_object,
						msg = message  HStable.retrieve_entry(msg,
										   symbology->hs_symb_index,
										   (IGRchar *) &hs_symb),
						p_chanselect = &notification_chanselect,
						senderid = my_id,
						from = 0,
						to = 0);

  /* pack display attribute structure with correct values		*/

		disp_attr->shad_style = hs_symb.shad_style;
		disp_attr->tex_orient = hs_symb.tex_orient;
		disp_attr->tex_index = hs_symb.tex_index;
		disp_attr->finish= hs_symb.finish;
		disp_attr->trans= hs_symb.trans;
		disp_attr->diff_refl= hs_symb.diff_refl;
		disp_attr->spec_refl= hs_symb.spec_refl;
		disp_attr->red= hs_symb.red;
		disp_attr->green= hs_symb.green;
		disp_attr->blue= hs_symb.blue;
	        disp_attr->app_symb_index = symbology->app_symb_index;

		}
		else
		{
  /* entry has beed deleted 		*/

	  	    *msg = MSFAIL;
		    status = FALSE;
		}
	    }
	    else
	    {
  /* invalid index			*/
	       *msg = MSFAIL;
	       status = FALSE;
	    }
	}
	else
	{
  /* entry is not defined		*/

	   *msg = MSFAIL;
	   status = FALSE;
	}
	
	return(status);
}

method	delete_entry(
IGRlong *msg; 
IGRint index; 
IGRint flags)
{

    IGRchar	*inst_entry_ptr;
    IGRint	inst_entry_size;
    IGRint	status = TRUE;
    struct HSbundsymb	*symbology;

  /* make sure entry has been defined					*/

	if (ME.HStable->num_fields > 0)
	{

	    *msg = MSSUCC;

  /* make sure index is valid					*/

	    if (index < ME.HStable->num_entries)
	    {
		inst_entry_size = ((ME.HStable->entry_size + 3) & 0xfffffffc) + sizeof (IGRint);

		inst_entry_ptr = &ME.HStable->entries[index * inst_entry_size];

  /* make sure entry is not deleted				*/

		if (!(*(IGRint *) inst_entry_ptr & HSENTRY_DELETED))
		{
	
		    symbology =  (struct HSbundsymb *) (inst_entry_ptr + 4);


  /* delete regular symbology entry					*/

		   if (!notification_crea)
		   {
			   status= om$make_chanselect(channame="HStable.notification",
			   				p_chanselect=&notification_chanselect); 
			   notification_crea=1;
		   }

		   if (!to_parent_crea)
		   {
			to_parent_chanselect.type=OM_e_name;
			to_parent_chanselect.u_sel.name="HStable.to_parent"; 
			to_parent_crea=1;
		   }
	
		    status = om$send (	mode = OM_e_wrt_object,
						msg = message  HStable.delete_entry(msg,
										   symbology->hs_symb_index,
										   0),
						p_chanselect = &notification_chanselect,
						senderid = my_id,
						from = 0,
						to = 0);




  /* delete HSsymb entry						*/
	        
		    status = om$send ( mode = OM_e_wrt_message,
				   msg =  message HStable.delete_entry(msg,index,flags),
				   senderid = my_id,
				   targetid = my_id);


		}
		else
		{
  /* entry is already deleted				*/

		   *msg = MSFAIL;
		   status = FALSE;
		}
	    }
	    else
	    {
  /* invalid index					*/

	       *msg = MSFAIL;
	       status = FALSE;
	    }
	}
	else
	{
  /* entry not defined					*/

	    *msg = MSFAIL;
	    status = FALSE;
	}	

	return(status);
}



method wake_up()
{

    IGRint	status = TRUE;
    IGRint      msg, num_fields;
    IGRint      inst_entry_size, index;
    IGRchar     *inst_entry_ptr;

/*
extern void	HSinit_symb_id();
extern void     HSset_symb_id();
*/
	status = om$send( mode = OM_e_wrt_message,
			  msg =  message HStable.wake_up(),
			  senderid = my_id,
			  targetid = my_id);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	    om$report_error(sts = status);
#endif
	    goto wrapup;
	}


	if (!ex$is_temp_wakeup())
	{
	    HSinit_grsymb_id();
	}
        HSset_symb_id(my_id, OM_Gw_current_OS);

        num_fields = -1;
        hs$get_app_num_fields(msg = (IGRlong *)&msg,
                              num_fields = &num_fields,
                              mod_id = my_id,
                              mod_osnum = OM_Gw_current_OS);
        if ((num_fields ==0 ) || (num_fields == 7))
        {
	    inst_entry_ptr = ME.HStable->entries;
	    inst_entry_size = ((ME.HStable->entry_size + 3) & 0xfffffffc) + sizeof (IGRint);
            index = 0;
            while (index < ME.HStable->num_entries)
            {
                  if ((*((int *)inst_entry_ptr)) & HSENTRY_DELETED) 
                  {
                        inst_entry_ptr += inst_entry_size;
                        index++;
                  }
                  else
                  {
                        ((int *)inst_entry_ptr)[2] = -1;
                        inst_entry_ptr += inst_entry_size;
                        index ++;
                  }
           }
        }


wrapup:

	return(status);
}


method global_class.sleep(int temp_sleep)
{
/*extern void HSreset_symb_id();*/

  HSreset_symb_id(OM_Gw_current_OS);
 /* status = om$send( mode = OM_e_wrt_message,
                    msg =  message HStable.sleep(),
                    senderid = my_id,
                    targetid = my_id); */

  return(OM_S_SUCCESS);
}




end implementation HSsymb;
