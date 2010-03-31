
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

class implementation HStex_table;

#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"

#include "hsmacros.h"
#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"

%safe
static int HS_texture_objid[256];
static int first_time_creation  = 1;
%endsafe

/*----------------------HSinit_texture_objid-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void  HSinit_texture_objid(void)
#else
	void  HSinit_texture_objid()
#endif

{
 IGRint i;
 for (i=0;i<256;i++)
 {
   HS_texture_objid[i] = NULL_OBJID;
 }
}

/*----------------------HSinit_texture_objid-----------------------------------*/


/*----------------------HSset_texture_objid-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSset_texture_objid( GRspacenum osnum,
				     GRobjid objid )
#else
	void HSset_texture_objid(osnum,objid)
	GRobjid objid;
	GRspacenum osnum;
#endif
{
  HS_texture_objid[osnum] = objid;
 
}


/*----------------------HSset_texture_objid-----------------------------------*/




/*----------------------HSreset_texture_objid-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSreset_texture_objid( GRspacenum osnum )
#else
	void HSreset_texture_objid(osnum)
	GRspacenum osnum;
#endif

{
 
  HS_texture_objid[osnum] = NULL_OBJID;
}


/*----------------------HSreset_texture_objid-----------------------------------*/


/*----------------------HSadd_texture_filename----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSadd_texture_filename( IGRchar *filename,
					IGRint active,
				unsigned short *index,
				       GRobjid modid,
				    GRspacenum modos )
#else
	IGRint HSadd_texture_filename(filename, active, index,modid,modos)
	IGRchar		*filename;
	IGRint		active;
	unsigned short	*index;
	GRobjid		modid;
	GRspacenum	modos;
#endif

{
   GRobjid           obj_id;
   GRspacenum        obj_os;
   GRobjid           mod_id;
   GRspacenum        mod_os;
   int               sts;

   if (modid == NULL_OBJID)
   {
      ex$get_modid(mod_osnum = modos,mod_id = &mod_id);
      mod_os = modos;
   }
   else
    {
      mod_id = modid;
      mod_os = modos;
    }
   HSget_object_id(mod_id,mod_os,&obj_id,&obj_os);
   sts = om$send(msg = message HStex_table.add_texture_file(filename, active, index),
                 senderid = NULL_OBJID,
                 targetid = obj_id,
	         targetos = mod_os);
   if (!(1&sts))
       return(FALSE);
   else
       return(TRUE);
}
   
/*----------------------HSadd_texture_filename----------------------------------*/



/*----------------------HSget_object_id------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	HSget_object_id( GRobjid mod_id,
		      GRspacenum mod_os,
			 GRobjid *obj_id,
		      GRspacenum *obj_os )
#else
	HSget_object_id(mod_id, mod_os, obj_id, obj_os)

	GRobjid           mod_id;
	GRspacenum        mod_os;
	GRobjid           *obj_id;
	GRspacenum        *obj_os;
#endif

 {
  int status; 

   
        if ((HS_texture_objid[mod_os] == NULL_OBJID) || (first_time_creation))
        {
                if (first_time_creation)
                {
                   first_time_creation = 0;
                   HSinit_texture_objid();
                }
        	status = ex$get_super(mod_id = mod_id,
				  mod_osnum = mod_os,
				  super_name = "HStex_table",
				  create = TRUE,
				  super_class = "HStex_table",
				  super_id = obj_id,
				  super_osnum = obj_os); 
                HS_texture_objid[mod_os] = *obj_id;
        }
        else
                *obj_id = HS_texture_objid[mod_os];
return(OM_S_SUCCESS);
 }

/*----------------------HSget_object_id------------------------------------------*/




/*----------------------HSadd_texture_ref_ct-------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint  HSadd_texture_ref_ct( unsigned short index,
					     GRobjid modid,
					  GRspacenum modos )
#else
	IGRint  HSadd_texture_ref_ct(index, modid, modos)
	unsigned short index;
	GRobjid           modid;
	GRspacenum        modos;
#endif
{

GRobjid           mod_id;
GRspacenum        mod_os;
GRobjid           obj_id;
GRspacenum        obj_os;
int               sts;


  if (modid == NULL_OBJID)
   {
      ex$get_modid(mod_osnum = modos,mod_id = &mod_id);
      mod_os = modos;
   }
   else
    {
      mod_id = modid;
      mod_os = modos;
    }
   HSget_object_id(mod_id,mod_os,&obj_id,&obj_os);
   sts = om$send(msg= message HStex_table.add_ref_ct(index),
                 senderid = NULL_OBJID,
                 targetid = obj_id,
                 targetos = mod_os);
   if (!(1&sts))
      return(FALSE);
   else
      return(TRUE);
}
/*----------------------HSadd_texture_ref_ct-------------------------------------*/



/*----------------------HSrev_texture_file---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSrev_texture_file( IGRchar *filename,
				  IGRint *ref_ct,
				  IGRint fst_time,
				 GRobjid modid,
			      GRspacenum modos )
#else
	void HSrev_texture_file(filename,ref_ct,  fst_time, modid, modos)

	IGRchar *filename;
	IGRint *ref_ct;
	IGRint fst_time;
	GRobjid           modid;
	GRspacenum        modos;
#endif

{

GRobjid           mod_id;
GRspacenum        mod_os;
GRobjid           obj_id;
GRspacenum        obj_os;
int               sts;


  if (modid == NULL_OBJID)
   {
      ex$get_modid(mod_osnum = modos,mod_id = &mod_id);
      mod_os = modos;
   }
   else
    {
      mod_id = modid;
      mod_os = modos;
    }
   HSget_object_id(mod_id,mod_os,&obj_id,&obj_os);
   sts = om$send(msg= message HStex_table.review_texture_file(filename, 
                                                            ref_ct, fst_time),
                 senderid = NULL_OBJID,
                 targetid = obj_id,
                 targetos = mod_os);
}

/*----------------------HSrev_texture_file---------------------------------------*/




/*----------------------HSdel_texture_file---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSdel_texture_file( unsigned short index,
					  GRobjid modid,
				       GRspacenum modos )
#else
	IGRint HSdel_texture_file(index, modid, modos)
	unsigned short   index;
	GRobjid           modid;
	GRspacenum        modos;
#endif

{

GRobjid           mod_id;
GRspacenum        mod_os;
GRobjid           obj_id;
GRspacenum        obj_os;
int               sts;


  if (modid == NULL_OBJID)
   {
      ex$get_modid(mod_osnum = modos,mod_id = &mod_id);
      mod_os = modos;
   }
   else
    {
      mod_id = modid;
      mod_os = modos;

    }
   HSget_object_id(mod_id,mod_os,&obj_id,&obj_os);
   sts = om$send(msg= message HStex_table.delete_texture_file(index),
                 senderid = NULL_OBJID,
                 targetid = obj_id,
                 targetos = mod_os);
   if (!(1&sts))
       return(FALSE);
   else
       return(TRUE);
}
/*----------------------HSdel_texture_file---------------------------------------*/




/*----------------------HSinq_texture_file---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSinq_texture_file( IGRchar *filename,
				    IGRint *status,
				   GRobjid modid,
				GRspacenum modos )
#else
	IGRint HSinq_texture_file(filename, status, modid, modos)
	
	IGRchar           *filename;
	IGRint            *status;
	GRobjid           modid;
	GRspacenum        modos;
#endif

{

GRobjid           mod_id;
GRspacenum        mod_os;
GRobjid           obj_id;
GRspacenum        obj_os;
int               sts;


  if (modid == NULL_OBJID)
   {
      ex$get_modid(mod_osnum = modos,mod_id = &mod_id);
      mod_os = modos;
   }
   else
    {
      mod_id = modid;
      mod_os = modos;

    }
   HSget_object_id(mod_id,mod_os,&obj_id,&obj_os);
   sts = om$send(msg= message HStex_table.inquire_texture_file(filename, status),
                 senderid = NULL_OBJID,
                 targetid = obj_id,
                 targetos = mod_os);
   if (!(1&sts))
       return(FALSE);
   else
       return(TRUE);
}
/*----------------------HSinq_texture_file---------------------------------------*/



/*----------------------HSret_texture_file---------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSret_texture_file( unsigned short index,
					  IGRchar *filename,
					  GRobjid modid,
				       GRspacenum modos )
#else
	IGRint HSret_texture_file(index, filename,  modid, modos)

	unsigned short    index;
	IGRchar           *filename;
	GRobjid           modid;
	GRspacenum        modos;
#endif

{

GRobjid           mod_id;
GRspacenum        mod_os;
GRobjid           obj_id;
GRspacenum        obj_os;
int               sts;


  if (modid == NULL_OBJID)
   {
      ex$get_modid(mod_osnum = modos,mod_id = &mod_id);
      mod_os = modos;
   }
   else
    {
      mod_id = modid;
      mod_os = modos;

    }
   HSget_object_id(mod_id,mod_os,&obj_id,&obj_os);
   sts = om$send(msg= message HStex_table.retrieve_texture_file(index, filename),
                 senderid = NULL_OBJID,
                 targetid = obj_id,
                 targetos = mod_os);
   if (!(1&sts))
       return(FALSE);
   else
       return(TRUE);
}
/*----------------------HSret_texture_file---------------------------------------*/




/*----------------------HSchg_texture_entry--------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSchg_texture_entry( unsigned short old_index,
				  unsigned short new_index,
					 GRobjid modid,
				      GRspacenum modos )
#else
	void HSchg_texture_entry(old_index, new_index, modid, modos)
	unsigned short    old_index, new_index;
	GRobjid           modid;
	GRspacenum        modos;
#endif

{
   if (old_index !=0)   
      HSdel_texture_file(old_index, modid, modos);
   if (new_index !=0)
      HSadd_texture_ref_ct(new_index, modid, modos);
}
/*----------------------HSchg_texture_entry--------------------------------------*/

/*----------------------HStex_verify_index-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HStex_validate_index( unsigned short index,
					     IGRint *valid_index,
					    GRobjid modid,
					 GRspacenum modos )
#else
	IGRint HStex_validate_index(index, valid_index,modid,modos)

	unsigned short    index;
	IGRint            *valid_index;
	GRobjid           modid;
	GRspacenum        modos;
#endif

{

GRobjid           mod_id;
GRspacenum        mod_os;
GRobjid           obj_id;
GRspacenum        obj_os;
int               sts;


  if (modid == NULL_OBJID)
   {
      ex$get_modid(mod_osnum = modos,mod_id = &mod_id);
      mod_os = modos;
   }
   else
    {
      mod_id = modid;
      mod_os = modos;

    }
   HSget_object_id(mod_id,mod_os,&obj_id,&obj_os);
   sts = om$send(msg= message HStex_table.validate_index(index, valid_index),
                 senderid = NULL_OBJID,
                 targetid = obj_id,
                 targetos = mod_os);
   if (!(1&sts))
       return(FALSE);
   else
       return(TRUE);
}


end implementation HStex_table;
