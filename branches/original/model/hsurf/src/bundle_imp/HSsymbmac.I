
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

class implementation HStable;

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"

static IGRint HSsymb_id[266];
%safe
static IGRint	first_time = 1 ;
%endsafe

#if defined(__STDC__) || defined(__cplusplus)
	void HSinit_grsymb_id(void)
#else
	void HSinit_grsymb_id()
#endif

{
    IGRint i;

	for (i=0; i < 266; i++)
	{
	    HSsymb_id[i] = NULL_OBJID;
	}
}

#if defined(__STDC__) || defined(__cplusplus)
	void HSset_symb_id( GRobjid objid,
			 GRspacenum osnum )
#else
	void HSset_symb_id(objid, osnum)
	GRobjid objid;
	GRspacenum osnum;
#endif
{
   HSsymb_id[osnum] = objid;
}

#if defined(__STDC__) || defined(__cplusplus)
	void HSreset_symb_id( GRspacenum osnum )
#else
	void HSreset_symb_id(osnum)
	GRspacenum osnum;
#endif

{
   HSsymb_id[osnum] = NULL_OBJID;
}
	
/*

IGRint HSdefentry(msg,num_fields,sizes,offsets,mod_id,mod_osnum)

  IGRlong		*msg;
   short		num_fields;
   short		*sizes;
   short		*offsets;
   GRobjid		mod_id;
   GRspacenum		mod_osnum;

    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		symb_id;

	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
	  modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

	HSget_grsymb_id(modid,modos,&symb_id);

 

	status = om$send ( msg = message HStable.define_entry(msg,num_fields,
					 sizes,offsets),
			   senderid = NULL_OBJID,
			   targetid = symb_id,
			   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	   om$report_error(sts = status);
#endif
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);

   }
*/


#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSaddsymbentry( IGRlong *msg,
			       IGRchar *entry,
			        IGRint *index,
			       GRobjid mod_id,
			    GRspacenum mod_osnum )
#else
	IGRint HSaddsymbentry(msg,entry,index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRchar		*entry;
	IGRint		*index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif
    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		symb_id;


	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
	  modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

	HSget_grsymb_id(modid,modos,&symb_id);

	status = om$send ( msg =  message HStable.add_entry(msg,entry,0,index),
			   senderid = NULL_OBJID,
			   targetid = symb_id,
			   targetos = modos);

	if (!( 1 & status))
	{
    	   om$report_error(sts = status);
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);

   }

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HScresymbentry( IGRlong *msg,
			       IGRchar *entry,
				IGRint *index,
			       GRobjid mod_id,
			    GRspacenum mod_osnum )
#else
	IGRint HScresymbentry(msg,entry,index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRchar		*entry;
	IGRint		*index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		symb_id;


	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
	  modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

	HSget_grsymb_id(modid,modos,&symb_id);
 

	status = om$send ( msg =  message HStable.create_entry(msg,entry,0,index),
			   senderid = NULL_OBJID,
			   targetid = symb_id,
			   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	   om$report_error(sts = status);
#endif
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);

   }

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSretsymbentry( IGRlong *msg,
				 IGRint index,
				IGRchar *entry,
				GRobjid mod_id,
			     GRspacenum mod_osnum )
#else
	IGRint	HSretsymbentry(msg,index,entry,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		index;
	IGRchar		*entry;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		symb_id;


	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
	  modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

	HSget_grsymb_id(modid,modos,&symb_id);

	status = om$send ( msg =  message HStable.retrieve_entry(msg,index,entry),
		   senderid = NULL_OBJID,
		   targetid = symb_id,
		   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	    om$report_error(sts = status);
#endif
	   status = FALSE;
	}
 	else
	{
	   status = TRUE;
	}

	
    	return(status);

   }

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSdelsymbentry( IGRlong *msg,
				 IGRint index,
				GRobjid mod_id,
			     GRspacenum mod_osnum )
#else
	IGRint	HSdelsymbentry(msg,index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif
    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		symb_id;


	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
	  modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

	HSget_grsymb_id(modid,modos,&symb_id);

	status = om$send ( msg = message   HStable.delete_entry(msg,index,0),
		   senderid = NULL_OBJID,
		   targetid = symb_id,
		   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	    om$report_error(sts = status);
#endif
	   status = FALSE;
	}
 	else
	{
	   status = TRUE;
	}

	
    	return(status);

   }

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSchgsymbentry( IGRlong *msg,
				IGRint old_index,
			       IGRchar *entry,
				IGRint *new_index,
			       GRobjid mod_id,
			    GRspacenum mod_osnum )
#else
	IGRint HSchgsymbentry(msg,old_index,entry,new_index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		old_index;
	IGRchar		*entry;
	IGRint		*new_index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		symb_id;


	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
	  modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

	HSget_grsymb_id(modid,modos,&symb_id);
 

	status = om$send ( msg =  message HStable.change_entry(msg,old_index,entry,0,new_index),
			   senderid = NULL_OBJID,
			   targetid = symb_id,
			   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	   om$report_error(sts = status);
#endif
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);

   }



#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSget_grsymb_id( GRobjid modid,
			      GRspacenum modos,
			         GRobjid *symb_id )
#else
	IGRint	HSget_grsymb_id(modid,modos,symb_id)

	GRobjid		modid;
	GRspacenum	modos;
	GRobjid		*symb_id;
#endif

    {

     IGRint	status;
     GRspacenum	grsymb_os;
extern void HSinit_grsymb_id();

	if (HSsymb_id[modos] == NULL_OBJID || first_time)
	{
	    if (first_time)
	    {
		first_time = FALSE;
		HSinit_grsymb_id();
	    }

	    status = ex$get_super(mod_id = modid,
                          mod_osnum = modos,
                          super_name = "HSSYMB",
                          create = TRUE,
                          super_class = "HSsymb",
                          super_id = symb_id,
                          super_osnum = &grsymb_os);

	    HSsymb_id[modos] = *symb_id;
	}
	else
	{
	    *symb_id = HSsymb_id[modos];
	}

    return(1);

  }   


end implementation HStable;
