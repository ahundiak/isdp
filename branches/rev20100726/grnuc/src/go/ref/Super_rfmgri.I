class implementation Super_rfmgr;

#include "grimport.h"
#include "igetypedef.h"
#include "igr.h"
#include "madef.h"
#include "godef.h"
#include "exdef.h"
#include "gr.h"
#include "grerr.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "ex.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "refpriv.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "refdef.h"
#include <alloca.h>

from GRreffile import GRrfclose, GRrfinit, GRselpass, GRgetrfprops;
from GRcontext import GRchgflag,GRgetosnum,GRgetinstance,GRregenerate,
                      GRnotifymisc;

%safe
int GRinrefwakeup = 0;
%endsafe

/*
        This static variable is used to determine whether a save is in
        progress during wake up.  If so, then the call to EXupdatable_exist
        will not succeed, since all the updatable files were written out
        during the sleep portion of the save.  The static is set in the sleep
        method to indicate to the wake_up that it should go ahead and retrieve
        its reference files.  Otherwise, all attachments would be lost after a
        save.
*/
%safe
static int save_in_progress = FALSE;
%endsafe

method super_construct ()
{
  char  path[DI_PATH_MAX];
  long  status;

  status = DIstmocpy ( path, "ref", 0, OM_Gw_current_OS );
  if (1 & status)
  {
    status = di$mkdir ( dirname = path );
    DIstmocpy ( path, "ref", "refnames", 0, OM_Gw_current_OS );

    status = di$mkdir(dirname = path);
  }

  return OM_S_SUCCESS;
}


method wake_up ()
{
  char                refname[DI_PATH_MAX], logical[DI_PATH_MAX];
  short               flag;
  int                 i, j, same, ctx_index = 0;
  IGRuint             count, ctx_count = 0, nest_count;
  long                msg, OMmsg, status;
  IGRboolean          constr;
  GRspacenum          osnum, ref_osnum, mod_os;
  GRobjid             objid, ref_id;
  struct GRid         context_id, nest_id, symb_super, ctx_array [256], 
                      *ctx_array_ptr = NULL, Super_id;
  struct GRmdenv_info env;
  OM_S_CHANSELECT     chan_def, nest_chan, chan;
  OMuword             PDM_wakeup;
  int                 prev_GRinrefwakeup;
  extern int          GRnb_ro_files;

  OMmsg = OM_S_SUCCESS;

  /*
   * If this is the first wakeup of a reference file manager, (ie) the
   * one in the master file. Then call PDM's hook for selective nested
   * reference file display.
   */
  if (!GRinrefwakeup)
  {
      ex$get_cur_mod ( osnum = &mod_os );

      if (mod_os == OM_Gw_current_OS)
      {
          PDMsetup_reffile_display ();
      }
  }
  
  om$enable_tagging ( flag = TRUE );
  prev_GRinrefwakeup = GRinrefwakeup;
  GRinrefwakeup = 1;
  /* we can ignore a temporary wakeup if we don't have writable files */
  if (ex$is_temp_wakeup ())
      if (!EXupdatable_exist ())
          if (save_in_progress)
              save_in_progress = FALSE;
          else
          {
              GRinrefwakeup=prev_GRinrefwakeup;
              return OM_S_SUCCESS;
          }
  
  /* set up context information  */
  GRsetupcontext ( &msg, &my_id, &OM_Gw_current_OS, &PDM_wakeup );
  if (1 & msg)
  {
    if (PDM_wakeup)
    {
      GRinrefwakeup=prev_GRinrefwakeup;
      return OM_S_SUCCESS;
    }
      
    /* get the context Super's id  */
    GRgetctxsuper(&msg,&Super_id);
    om$make_chanselect ( channame = "GRcontext.to_nested_files",
                         p_chanselect = &nest_chan );

    /* if nested reference file */
    if ( Super_id.osnum != OM_Gw_current_OS )
    {
      om$make_chanselect ( channame = "Super_rfmgr.to_context",
                           p_chanselect = &chan );
      om$get_channel_count ( p_chanselect= &chan,
                             objid = Super_id.objid,
                             osnum = Super_id.osnum,
                             count = &ctx_count );
      if (ctx_count > 256)
        ctx_array_ptr = (struct GRid *) om$malloc( size = ctx_count * sizeof ( struct GRid ));
      else
        ctx_array_ptr = ctx_array;

      for (i = 0; i < ctx_count; ++i)
      {
        status = om$send ( msg = message GRcontext.GRgetosnum ( &msg, &osnum ),
                           senderid = Super_id.objid,
                           targetos = Super_id.osnum,
                           p_chanselect = &chan,
                           from = i, to = i);
        if (!( 1 & status & msg))
          continue;

        if ( osnum == OM_Gw_current_OS)
        {
          /* If the context object represents this object space, send a 
             regenerate message to all context objects nested inside this 
             object space. */
          status = om$send ( msg = message GRcontext.GRgetinstance
                             (&msg,&env.matrix_type,env.matrix,&osnum,&flag,
                              &context_id),
                             senderid = Super_id.objid,
                             targetos = Super_id.osnum,
                             p_chanselect = &chan,
                             from = i, to = i);

          if ( 1 & status & msg)
          {
            /* send message to cause all context objects nested
               inside this object space to recompute in case
               this object space has been retrieved and been altered. */
            om$get_channel_count ( p_chanselect = &nest_chan,
                                   objid = context_id.objid,
                                   osnum = context_id.osnum,
                                   count = &nest_count );
            for (j = 1; j < nest_count; ++j)
            {
              om$send ( msg = message GRcontext.GRregenerate(&msg, &env,
                                                             &same, &nest_id),
                        senderid = context_id.objid,
                        targetos = context_id.osnum,
                        p_chanselect = &nest_chan,
                        from=j, to=j);
              if (! same)
                ctx_array_ptr[ctx_index++]=nest_id;
            }
          }
        }
      }
    }

    /* send init out mgr channel  */
    om$make_chanselect ( channame = "Super_rfmgr.mgr",
                         p_chanselect = &chan_def );
    constr = FALSE;
    om$get_channel_count ( objid = my_id,
                           p_chanselect = &chan_def,
                           count = &count);
    for (i = 0; i<count; ++i)
    {
      /* get the id of the GRreffile  */
      om$get_objid_at_index ( objid = my_id,
                              p_chanselect = &chan_def,
                              index = i,
                              objidaddr = &ref_id,
                              osnumaddr = &ref_osnum );

      /* get the reference files name */
      status = di$untranslate ( objname = refname,
                                objid = ref_id,
                                osnum = ref_osnum );
      if ( 1 & status)
      {
        /* If this is not a nested reference file */
        di$split ( pathname = refname, name = logical );
        if ( Super_id.osnum != OM_Gw_current_OS )
        {
          int        Count;
          OM_S_OBJID Objid;
          char       Name [DI_PATH_MAX];
          
          /*
           * It is a nested file, let's make sure the name is unique
           */
          strcpy ( Name, logical );
          for (Count = 0; ; Count++)
          {
            if (di$translate ( osnum =  Super_id.osnum, path = "ref",
                    objname = logical, p_objid = &Objid ) != DIR_S_SUCCESS)
              break;
            sprintf ( logical, "%s%d", Name, Count );
          }
     }

        /* init the object space  */
        om$send ( mode = OM_e_wrt_object,
                  msg = message GRreffile.GRrfinit(&msg, &constr, logical,
                                                   &osnum, &objid, 
                                                   &context_id),
                  senderid = my_id,
                  targetid = ref_id,
                  targetos = ref_osnum);
        if (msg == OM_E_NO_OS_AVAIL)
        {
          /* if this error is returned, the file cannot be opened, return 
             to module so the session can be terminated and an error box 
             displayed. */
          OMmsg = msg;
          goto wrapup;
        }
      }
    }

    if ( Super_id.osnum == OM_Gw_current_OS ) /* master file wakeup?*/
    {
      /* The symbology override super may be on the super channel
       * before the reference file manager.  It needs to be after
       * the reference file super, to kludge around this problem,
       * the reference file super will send another wakeup to the 
       * symbology override super.  (They promise they can handle
       * 2 wakeups.) This is done for the master file only.
       */

      OMmsg = ex$get_super(create=0,
          mod_osnum = OM_Gw_current_OS,
          mod_id = sender_id,
          super_name = "DEsmsuper",
          super_id = &symb_super.objid,
          super_osnum = &symb_super.osnum);

      if ( (1 & OMmsg) && (!IF_NULL_OBJID(symb_super.objid)))
      {
        om$send(msg = message global_class.wake_up(),
            targetid = symb_super.objid,
            targetos = symb_super.osnum);
      }
    }

    for (j=0; j<ctx_index; ++j)
    {
      /* send message to all objects connected on the misc 
       * channel of the changed context objects to regenerate.
       */

      om$send(msg = message GRcontext.GRnotifymisc(&msg),
          senderid=ctx_array_ptr[j].objid,
          targetid=ctx_array_ptr[j].objid,
          targetos=ctx_array_ptr[j].osnum);
    }

    if (ctx_count > 256)
      om$dealloc ( ptr = ctx_array_ptr );
  }

wrapup:

  /* Tell the user about writable files open read only */
  ex$get_cur_mod ( osnum = &mod_os );
  if (mod_os == OM_Gw_current_OS)
  {
    char        *buffer;
    int         i;
    extern char **GRro_files;
    
    if (GRnb_ro_files)
    {
      buffer = (char *)alloca ( (GRnb_ro_files + 2) * DI_PATH_MAX );

      for (i = 0; i < GRnb_ro_files; i++)
      {
        ex$message ( msgnumb = GR_I_OpenRo,
                     type = "%s",  
                     buff = buffer,
                     var = `GRro_files [i]` );
        UI_error ( buffer );
        free ( GRro_files [i] );
      }
      
      free ( GRro_files );
      GRnb_ro_files = 0;
      GRro_files = NULL;
    }
  }

  di$update_dir_form();

  GRinrefwakeup=prev_GRinrefwakeup;
  return OMmsg;
}

%undef sleep
method sleep ( int type_sleep )
{
  short             action, flag;
  long              OMmsg;
  long              msg;
  long              type;
  int               mode;
  GRspacenum        osnum, setosnum;
  GRobjid           objid, setmgr;
  int               PDM_sleep;
  OM_S_CHANSELECT   chan_def;
  static IGRint     sleep_depth = 0;
  static IGRboolean sleep_cleanup = FALSE;

  /* we can ignore a temporary sleep if we don't have writable files */
  if (type_sleep == EX_TEMP_SLEEP)
    if (!EXupdatable_exist ())
        return OM_S_SUCCESS;
    else
        save_in_progress = TRUE;

  /* what is this ? */
  GRrestore_context_stack ( &PDM_sleep );
  if (PDM_sleep && !Invis_check_override())
    return OM_S_SUCCESS;
  
  /* increment the sleep method depth. */
  sleep_depth++;
  
  /* send close out mgr channel */
  chan_def.type = OM_e_addr;
  chan_def.u_sel.addr = &me->mgr;

  ex$get_cur_mod ( id = &objid, osnum = &osnum );
  ex$file_status ( modid = objid, modos = osnum, mode = &mode );

  /* type is 1 when we want to write */
  type = !mode;

  /* Temporary fix for 1.1, must tell the graphic set manager that
     a sleep is happening so that he can dissolve any isos in the
     reference file space. */
  OMmsg = ex$get_super ( create = 0,
                         mod_osnum = OM_Gw_current_OS,
                         mod_id = sender_id,
                         super_name = GR_GSMGR,
                         super_class = "GRgsmgr",
                         super_id = &setmgr,
                         super_osnum = &setosnum );

  if ((1 & OMmsg) && (!IF_NULL_OBJID(setmgr)))
    om$send ( msg = message global_class.sleep ( type_sleep ),
              targetid = setmgr,
              targetos = setosnum);

  /* if we aren't in the sleep cleanup */
  if (sleep_cleanup == FALSE)
  {
      om$send (mode = OM_e_wrt_object,
               msg = message GRreffile.GRrfclose ( &msg, &type ),
               p_chanselect = &chan_def );
  }
  
  /* my space might be gone at this point */
  if (om$is_objid_valid ( objid = my_id ) == OM_S_SUCCESS)
  {
      chan_def.u_sel.addr = &me->to_context;
      action = 0;
      flag = GRACTIVATED_CONTEXT;
      om$send(msg = message GRcontext.GRchgflag ( &msg, &action, &flag ),
              p_chanselect=&chan_def );
  }

  /* 
   * KLUDGE: If we are finishing up the initial send of the sleep message
   * and if this is the master file's object space we must close any spaces 
   * left open at this point. This is a temporary fix for TR119304581.
   */

#define WRITE_FILE          1
#define DO_NOT_WRITE_FILE   0

  if ((sleep_depth == 1) && (osnum == OM_Gw_current_OS))
  {
      extern struct EX_visible_module   * module_table;
      extern struct EX_invisible_module * invisible_table;
      IGRint                              i;
      OMuint                              count = 0;
          
      om$get_channel_count (objid = my_id,
                            osnum = OM_Gw_current_OS,
                            p_chanselect = &chan_def,
                            count = &count);
      if (count > 0)
      {
          sleep_cleanup = TRUE;
          
          for (i=EX_MAX_INVIS_MODULES -1; i>=0; --i)
          {
              if ((invisible_table[i].obj_space_num != 0)     &&
                  (invisible_table[i].ref_flag == 1)          &&
                  (om$is_objid_valid (osnum = invisible_table[i].obj_space_num,
                                      objid = 0) == OM_S_SUCCESS))
              {
                  IGRchar buffer[1024];
                  
                  om$os_number_to_name (osnum = invisible_table[i].obj_space_num,
                                        osname = buffer);
#ifdef DEBUG
                  printf ("Doing Super_rfmgr.sleep kludge for os = %s.\n",
                          buffer);
#endif

                  /* force a close of the object space. */
                  invisible_table[i].numof_opens = 0;
                  
                  ex$close_module (ftype = EX_invisible,
                                   index = i,
                                   flag  = (type == WRITE_FILE) ? 1 : 0 );
              }
          }

          sleep_cleanup = FALSE;
      }
  }

  sleep_depth--;
  
  return OM_S_SUCCESS;
}


method Super_passon ( long *msg;	/* completion status		
					 *   MSSUCC - successful 
					 *   GRCHANNEL_EMPTY - no one is
					 *	on the mgr channel	*/

		OM_S_MESSAGE *pass_msg) /* the message to pass out the 
					 *  channel	
					 */

{
    IGRuint	count;			/* limits for channel send	*/
    long	OMmsg;			/* return code			*/

    OM_S_CHANSELECT chan_def;		/* channel definition		*/

    OMmsg = OM_S_SUCCESS;
					/* send message out mgr channel	*/
    chan_def.type = OM_e_addr;
    chan_def.u_sel.addr = &me->mgr;

    OMmsg = om$get_channel_count(objid = my_id,
			 	p_chanselect = &chan_def,
			 	count = &count);
    if ( 1 & OMmsg)
    {

    	if (count > 0)
    	{
		/* send message out mgr channel	*/
       	    OMmsg = om$send(mode = OM_e_wrt_object,
                    msg =  pass_msg,
                    p_chanselect = &chan_def,
                    from = 0,
                    to = count - 1 );

    	}
    	else
    	{
	    *msg = GRCHANNEL_EMPTY;
	}
    }

#ifdef DEBUG
	printf("PASSON COMPLETED\n");
	printf("OMmsg = %x\n",OMmsg);
	printf("count  = %d\n",count);
	printf("msg = %x\n",*msg);
#endif

    return(OMmsg);

}
/*\
Name	
	GRselectpass  - passes a message to all reference file attachments
		which match an input mask

Synopsis
	GRselectpass(msg,ref_properties_mask,pass_to_nested_attachments,
		pass_msg,mx_type,matrix,module_id,module_osnum);
	
	long 	*msg		completion code
	unsigned long *ref_properties_mask 
					mask for the properties check
	IGRshort *pass_to_nested_attachments
					flag to indicate whether the
					message should be passed to
					nested reference files
					0 - do not pass
					1 - pass to nested files
 	OM_p_MESSAGE pass_msg		the message to pass

	  ***NOTE the following arguments are included in case you
		have requested the message to be passed to nested 
		spaces and the argument list of the message includes
		the fields.  These values must be updated as you pass
		from one space to the next.

	IGRshort *mx_type		matrix type 
	IGRdouble *matrix		environment matrix
	GRobjid *module_id		module id
	GRspacenum *module_osnum	object space number
					 channel	
Description

	This method passes the input message on to all 	reference files 
	which pass the given input mask check.  The message is also sent
	to nested reference files if requested.  

	If you want all attachments to get the message, you can send
	the mask = 0;

Diagnostics
	The return values in msg are:

	MSSUCC - successful 
	GRCHANNEL_EMPTY - no one is on the mgr channel

Notes
	None.
History
	MAS 	04/21/87	Design date.
\*/

method GRselectpass(long *msg; unsigned long *ref_properties_mask; 
   IGRshort *pass_to_nested_attachments; OM_p_MESSAGE pass_msg; 
   IGRshort *mx_type; IGRdouble *matrix; GRobjid *module_id;
   GRspacenum *module_osnum)
{
    IGRuint	count;			/* limits for channel send	*/

    long	OMmsg;			/* return code			*/

    OM_S_CHANSELECT chan_def;		/* channel definition		*/

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
					/* send message out mgr channel	*/
    chan_def.type = OM_e_addr;
    chan_def.u_sel.addr = &me->mgr;

    OMmsg = om$get_channel_count(objid = my_id,
	 	    p_chanselect = &chan_def,
		    count = &count);
    if ( 1 & OMmsg)
    {
	if (count)
	{
             OMmsg = om$send(mode = OM_e_wrt_object,
	       msg = message GRreffile.GRselpass
		 (msg,ref_properties_mask,
		  pass_to_nested_attachments,pass_msg,
		  mx_type,matrix,module_id,module_osnum),
               p_chanselect = &chan_def,
    	       from = 0,
               to = count);
    	}
    	else
    	{
	    *msg = GRCHANNEL_EMPTY;
	}
    }

#ifdef DEBUG
	printf("PASSON COMPLETED\n");
	printf("OMmsg = %x\n",OMmsg);
	printf("count  = %d\n",count);
	printf("msg = %x\n",*msg);
#endif

    return(OMmsg);
}
/*\
Name
	GRget_channel_count - counts the objects on the
		mgr channel

Synopsis

	 GRget_channel_count(msg,ref_properties_mask,
		count_nested_attachments,count)

	long *msg;		completion code
   	unsigned long *ref_properties_mask;
				properties you want the counted
				objects to match
				NOTE: send 0 if you want a count
				    of all reference file 
				    attachment objects
   	IGRshort *count_nested_attachments;
				indicator for whether you want nested
				attachments counted.
   	long  *count
				the number of attachment objects
				meeting the requested criteria

Description
	This method counts the number of reference file attachment 
 	objects meeting the requested criteria.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	GRCHANNEL_EMPTY - no reference file object in file
	MSFAIL - error
Notes
	None.
History
	MAS 	05/12/87	Design date.

\*/

method GRget_channel_count(long *msg;
   unsigned long *ref_properties_mask;
   IGRshort *count_nested_attachments;
   long  *count)

{
    long	OMmsg,			/* completion codes		*/
		msg1;

    long   	count1;			/* channel count		*/
    int	i;			/* loop index			*/

    unsigned long mask,		/* comparision mask		*/
		props;			/* ref properties		*/

    GRobjid	objid;			/* module object id		*/
    GRspacenum  osnum;			/* module space number		*/
    GRobjid 	Super_id;		/* super id in other spaces	*/

    OM_S_CHANSELECT chan_def;		/* channel definition		*/

    *msg = MSSUCC;			/* initialize variables		*/
    OMmsg = OM_S_SUCCESS;
    *count = 0;

    chan_def.type = OM_e_addr;		/* set up channel definition	*/
    chan_def.u_sel.addr = &me->mgr;

					/* get count			*/
    OMmsg = om$get_channel_count(objid = my_id,
	 	    p_chanselect = &chan_def,
		    count = (IGRuint *) count);
    if (*count == 0)			/* no attachments		*/
    {
	*msg = GRCHANNEL_EMPTY;
    }
    else if ( 1 & OMmsg)
    {					/* properties check requested?	*/
	if (*ref_properties_mask != 0)	
	{
	    count1 = 0;
	    for (i=0; i<*count; ++i)	/* loop for all attachments	*/
	    {				/* get the reference properties	*/
		OMmsg = om$send(
		    msg = message GRreffile.GRgetrfprops(&msg1,&props),
		    p_chanselect = &chan_def,
		    from = i,
		    to = i);

		if (1 & OMmsg)		
	   	{			/* do properties check		*/
		    mask = props & *ref_properties_mask;
		    if (mask == *ref_properties_mask)
		    {			/* attachment meets criteria	*/
			++count1;
		    }
		}
	    }
					/* reset count			*/
	    *count = count1;
	}

	if ( *count_nested_attachments)
	{				/* loop for all invisible spaces*/
	    for (i=0; i< EX_MAX_MODULES; ++i)
	    {
		Get_invisible_objid(i,(&objid));

		if (IF_NULL_OBJID(objid))	
		{			/* terminate loop		*/
		    i = EX_MAX_MODULES;
		}
		else
		{		
		    Get_invisible_osnum(i,(&osnum));
					/* get Super id			*/
		    OMmsg = ex$get_NOD(NODname = "Ref Mgr",
				pobjid = &Super_id,
				modid = objid,
				mod_osnum = osnum);
		    if (1 & OMmsg)
		    {			/* get count for this space	*/
			OMmsg = om$send(
			    msg = message Super_rfmgr.GRget_channel_count
			     	(msg,ref_properties_mask,
			      	 count_nested_attachments,&count1),
			    targetid = Super_id,
			    targetos = osnum);

			if ( 1 & OMmsg & *msg)			   
		  	{
			    *count += count1;
			}
		    }
	    	}
	    }	    
	}     
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }

#ifdef DEBUG
	printf("COUNT COMPLETED\n");
	printf("OMmsg = %x\n",OMmsg);
	printf("count = %d\n",*count);
	printf("msg = %x\n",*msg);
#endif

   return (OMmsg);
}

/*\
Name
	GRget_channel_objects - returns the object-id and
		object space numbers of reference file
		attachment objects

Synopsis

	GRget_channel_objects(msg,ref_properties_mask,
	    get_nested_attachments,objids_array_size,
	    objids,osnums,num_objids_returned)

	long *msg		completion code
   	unsigned long *ref_properties_mask
				properties criteria each object
				must meet
				Note: 0 means find all attachments
				 ignoring properties check.
   	IGRshort *get_nested_attachments
				get nested attachments also
   	long *objids_array_size
				number of objects you have allowed 
				for in the objids array
	GRobjid *objids
				array for returned object ids
   	GRspacenum *osnums
				array for returned object space
				numbers of the objids.
	long *num_objids_returned
				number of objids returned

Description
	This methods finds all reference file attachments on the
	mgr channel.  The attachments are compared to see if they
	meet the desired properties criteria.  If so, the objid and
	corresponding object space number is loaded into the 
	output array.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	GRCHANNEL_EMPTY - no objects on channel
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

method GRget_channel_objects(long *msg;
   unsigned long *ref_properties_mask;
   IGRshort *get_nested_attachments;
   long *objids_array_size; GRobjid *objids;
   GRspacenum *osnums; long *num_objids_returned)

{
    long	OMmsg,			/* completion codes		*/
		msg1;

    long   	count1,			/* channel count		*/
		count;

    int	i;			/* loop index			*/

    unsigned long mask,		/* comparision mask		*/
		props;			/* ref properties		*/

    GRobjid	objid,			/* module object id		*/
		Super_id,		/* super id in other spaces	*/
		*objid_array;
    GRspacenum  osnum,			/* module space number		*/
		*osnum_array;

    OM_S_CHANSELECT chan_def;		/* channel definition		*/


    *msg = MSSUCC;			/* initialize variables		*/
    OMmsg = OM_S_SUCCESS;
    *num_objids_returned = 0;

    chan_def.type = OM_e_addr;		/* set up channel definition	*/
    chan_def.u_sel.addr = &me->mgr;

					/* get count			*/
    OMmsg = om$get_channel_count(objid = my_id,
	 	    p_chanselect = &chan_def,
		    count = (IGRuint *) &count);
    if (count == 0)			/* no attachments		*/
    {
	*msg = GRCHANNEL_EMPTY;
    }
    else if ( 1 & OMmsg)
    {			
        for (i=0; i<count; ++i)		/* loop for all attachments	*/
	{			
	    OMmsg = om$get_objid_at_index(
		    objid = my_id,
		    p_chanselect = &chan_def,
		    index = i,
		    objidaddr = &objids[*num_objids_returned],
		    osnumaddr = &osnums[*num_objids_returned]);

	    if ( 1 & OMmsg)
	    {		
					/* properties check requested?	*/
		if ( *ref_properties_mask != 0 )
		{
		    OMmsg = om$send(
		        msg = message GRreffile.GRgetrfprops(&msg1,&props),
		        targetid = objids[*num_objids_returned],
			targetos = osnums[*num_objids_returned]);

		    if (1 & OMmsg)		
	   	    {			/* do properties check		*/
		        mask = props & *ref_properties_mask;

		        if (mask == *ref_properties_mask)
		        {		/* attachment meets criteria	*/
			    if (*num_objids_returned < *objids_array_size)
			    {
			       ++(*num_objids_returned);
			    }
			}
		    }
		}
		else
		{
	       	    ++(*num_objids_returned);
		}
	    }
	}

	if ( ( *get_nested_attachments) && 
	     (*num_objids_returned < *objids_array_size))
	{				/* loop for all invisible spaces*/
	    for (i=0; i< EX_MAX_MODULES; ++i)
	    {
		Get_invisible_objid(i,(&objid));

		if (IF_NULL_OBJID(objid))	
		{			/* terminate loop		*/
		    i = EX_MAX_MODULES;
		}
		else if (objid != my_id)
		{			/* get Super id			*/
		    Get_invisible_osnum(i,(&osnum));

		    OMmsg = ex$get_NOD(NODname = "Ref Mgr",
				pobjid = &Super_id,
				modid = objid,
				mod_osnum = osnum);
		    if (1 & OMmsg)
		    {			
			count = *objids_array_size - *num_objids_returned;

			osnum_array = &osnums[*num_objids_returned];
			objid_array = &objids[*num_objids_returned];

			OMmsg = om$send(
			 msg = message Super_rfmgr.GRget_channel_objects
			    (msg,ref_properties_mask,
			     get_nested_attachments,&count,
			     objid_array,osnum_array,&count1),
			 targetid = Super_id,
			 targetos = osnum); 

			if ( 1 & OMmsg & *msg)			   
		  	{
			    *num_objids_returned += count1;
			}
		    }
	    	}
	    }	    
	}     
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }

#ifdef DEBUG
	printf("COUNT COMPLETED\n");
	printf("OMmsg = %x\n",OMmsg);
	printf("count  = %d\n",count);
	printf("msg = %x\n",*msg);
#endif

   return (OMmsg);
}
end implementation Super_rfmgr;
