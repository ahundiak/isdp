class specification DEso (2:1) of global_class, IGEwinsup, GRgraphics;
/*
   This class implements the Symbology Override Table.  It is a subclass
of global_class because it is a super object and it is a subclass of
IGEwinsupp because it needs to be notified when "something" (delete, ...)
happens to a window that has override.
*/

#include <sys/types.h>
#include "igrtypedef.h"
#include "igrdp.h"
#include "DEso.h"

  override IGEwinsup;	/* we want our own channel (must be ordered)	*/
  override GRgraphics;  /* we don't want any instance data of graphics	*/

  instance DEso
  {
    channel
    {
      (many_to_many,
       rel_ordered,
       initial = 0,
       increment = 1) IGEgragad;
    } to_windows    			/* a channel for windows	*/;

    channel
    {
      (many_to_many,
       rel_ordered,
       initial = 0,
       increment = 1) GRcontext;
    } to_contexts    			/* a channel for contexts	*/;

    variable DEsoe soo [0]	 	/* soo entries			*/;
    int            used			/* number of used slots		*/;
    GRspacenum     osnum		/* the os the soo is for	*/;
  };


  override wake_up		/* to reset the go's			*/,
           super_construct	/* to update the list of soos		*/,
           sleep		/* to update the list of soos		*/,
           debug		/* to print useful information		*/,
           pre_delete		/* to cleanup when a window is deleted	*/,
           view_saved 		/* to handle saved views		*/,
           view_recalled 	/* to handle saved views		*/,
           GRdelete		/* selective delete from context	*/;
  
  
  message DEinit ( long *msg; IGRushort osnum; int size );
  /*
     This message is used to initialize the soo.
  
     Argument description:
     --------------------
  
       long *msg   : the return status					(OUT)
  		   MSSUCC: the soo has been initialized
  		   MSFAIL: the soo could not be initialized
  
       ushort osnum: the os the soo is for				(IN)

       int     size: the initial size of the table 			(IN)
                     (if size <= 0 then DE_MINIMUM is used)
  */
  
  
  message DEadd ( long *msg; int type; OM_S_OBJID objid; double u1; double u2;
                  struct IGRdisplay *symb; struct GRid *window; short wn_ndx;
                  struct GRmd_env *md_env; short ctx_ndx );
  /*
     This message is used to add one entry to the soo.
  
     Argument description:
     --------------------
  
       long *msg              : the return status				(OUT)
  			        MSSUCC: the entry has been added
  			        MSFAIL: the entry could not be added
  
       int type    	      : type of the new entry  			(IN)
       
       OM_S_OBJID objid       : graphic object				(IN)
       
       double u1, u2          : u parms					(IN)
       
       struct IGRdisplay *symb: override symbology 			(IN)
       
       struct GRid *window    : window of the override 			(IN)

       short wn_ndx           : index of the window			(IN)
  
       struct GRmd_env *md_env: context of override			(IN)

       short ctx_ndx          : index of the context of the override	(IN)
  */
  
  
  message DEadd_entries ( long *msg; int nb_entries; DEsoe *entries );
  /*
     This message is used to add entries to the soo.
  
     Argument description:
     --------------------
  
       long *msg	: the return status				(OUT)
  			  MSSUCC: the entries have been added
  			  MSFAIL: the entries could not be added
  
       int nb_entries	: the number of entries to add			(IN)
  
       DEsoe *entries	: the entries to be added			(IN)
  */
  
  
  message DEget ( long *msg; int **p_types; double **p_parms; int *p_count;
                  struct IGRdisplay **p_attr, *ele_attr;
                  GRobjid objid, viewid;
                  short *type; IGRmatrix matrix; int sel_flag; int ret_invis );
  /*
     This method returns the display parameters for an object.
  
     Argument description:
     --------------------
  
       long *msg	         : the return status			(OUT)
   				   MSSUCC: successful operation
  				   MSFAIL: failure
  
       int **p_types		 : pointer to static data that contains (OUT)
                                   the types (might be NULL).

       double **p_parms          : pointer to static data that contains	(OUT)
                                   the u parms (u1, u2)
       
       int *p_count              : number of (u1, u2) pairs		(OUT)
       
       struct IGRdisplay **p_attr: pointer to static data that contains	(OUT)
                                   the display parameters.
       
       struct IGRdisplay *ele_attr: pointer to element's original	(OUT)
                                    display parameters.
        
       GRobjid objid	         : the object that has the override	(IN)
   
       GRobjid viewid	         : the window we are displaying in	(IN)

       short *type		 : the matrix type			(IN)

       IGRmatrix matrix          : the matrix itself			(IN)

       int sel_flag		 : what overrides do we return		(IN)
                                   o if sel_flag == 0 then automatic and
                                     manual soo's are returned
                                   o if sel_flag == 1 then only automatic
                                     soo's are returned
                                   o if sel_flag == 2 then only manual 
                                     soo's are returned

       int ret_invis		 : return INVIS SOs if INVIS is OFF?	(IN)
                                   o if INVIS is ON then return all SOs
                                   o if INVIS is OFF then
                                     o  if ret_invis == 0
                                        then do not return INVIS SOs
                                     o  if ret_invis == 1
                                        then return INVIS SOs
  */
  
  
  message DEget_view_index ( long *msg; short *p_window, *p_context; 
                             int add; OM_S_OBJID window, context );
  /*
     This method looks for window/context pair on the to_views channel.
     If a connection is found then its index is returned else the pair
     is connected and the index of this new connection is returned. Note
     that window + context = view.
  
     Argument description:
     --------------------
  
       long *msg	 : the return status				(OUT)
  			   MSSUCC: successful operation
  			   MSFAIL: failure
  
       short *p_window	 : the index on the gra_gad channel		(OUT)

       short *p_context  : the index on the to_contexts channel		(OUT)
       
       int add           : TRUE if entry needs to be added		(IN)
       
       OM_S_OBJID window : the window we are looking for			(IN)
  
       OM_S_OBJID context: the context we are looking for		(IN)
  */
  
  
  message DEchange_size ( long *msg; int new_size );
  /*
     This method is used to change the size of the hash table.
  
     Argument description:
     --------------------
  
       long *msg	: the return status				(OUT)
  			  MSSUCC: successful operation
  			  MSFAIL: failure
  
       int new_size	: the new size					(IN)
  
  */
  
  
  message DEget_size ( long *msg; int *size );
  /*
     This method is used to get the size of the hash table.
  
     Argument description:
     --------------------
  
       long *msg	: the return status				(OUT)
  			  MSSUCC: successful operation
  			  MSFAIL: failure
  
       int *size	: the size					(OUT)
  
  */
  
  
  message DEmodify ( long *msg; int old_type; struct IGRdisplay *old_symbology;
                     double old_u1, old_u2;
                     struct GRid *old_window; struct GRmd_env *old_md_env;
                     int type; struct IGRdisplay *symbology;
                     double u1, u2; GRobjid objid; struct GRid *window; 
                     struct GRmd_env *module; int interference );
  /*
     This message is used to modify an entry of the soo.
  
     Argument description:
     --------------------
  
       long *msg     	               : the return status		(OUT)
  			                 MSSUCC: the entry has been modified
  			                 MSFAIL: the entry could not be modified
  
       int old_type                    : the old type of the entry	(IN)
       
       struct IGRdisplay *old_symbology: the old symbology override 	(IN)
  
       double old_u1, old_u2           : the old u parms		(IN)
       
       struct GRid *old_window         : the old view of the override	(IN)
  
       struct GRmd_env *old_md_env     : the old context of the override(IN)
       
       int type                        : type of the entry		(IN)
       
       struct IGRdisplay *symbology    : the new symbology		(IN)
       
       double u1, u2                   : the new u parms		(IN)
       
       struct GRid *go                 : the object with the override	(IN)
       
       struct GRid *window             : the new view for the override	(IN)
       
       struct GRmd_env *md_env         : the new context of the override(IN)
       
       int interference                : interference checking ? 	(IN)
  */
  
  
  message DEremove_in_view ( long *msg; GRobjid objid;
                             struct GRid *window; struct GRmd_env *md_env );
  /*
     This message is used to remove the override of an object from the soo
     in the specified view. 
  
     Argument description:
     --------------------
  
       long *msg	      : the return status			(OUT)
  			        MSSUCC: the overrides have been removed
  			        MSFAIL: no override was not found
  
       OM_S_OBJID objid       : graphic object				(IN)
       
       struct GRid *window    : window of the override 			(IN)
  
       struct GRmd_env *md_env: context of override			(IN)
  */


  message DEremove ( long *msg; int type; GRobjid objid; double u1, u2;
                     struct IGRdisplay *symb; struct GRid *window;
                     struct GRmd_env *md_env );
  /*
     This message is used to remove one entry from the soo.
  
     Argument description:
     --------------------
  
       long *msg	      : the return status			(OUT)
  			        MSSUCC: the entry has been removed
  			        MSFAIL: the entry was not found
  
       int type    	      : type of the new entry  			(IN)
       
       OM_S_OBJID objid       : graphic object				(IN)
       
       double u1, u2  	      : u parms					(IN)
       
       struct IGRdisplay *symb: override symbology  			(IN)
       
       struct GRid *window    : window of the override 			(IN)
  
       struct GRmd_env *md_env: context of override			(IN)
  */
  
  
  message DEremove_by_objid ( long *msg; OM_S_OBJID objid );
  /*
     This method removes an objid (all of its overrides) from the table.
     It is called (among other things) by delete and drop override.
  
     Argument description:
     --------------------
  
       long *msg       : the return status				(OUT)
  		       MSSUCC: the entries have been removed
  		       MSFAIL: no entry was found
  
       OM_S_OBJID objid: the objid to remove from the table		(IN)
  */
  
  
  message DEdump ( int *p_count; DEsoe **p_buffer; int all );
  /*
     This method dumps the contents of the soo into memory; *buffer points
     to that memory.  Note that the memory will be re-used by the next call
     to DEdump.
  
     Argument description:
     --------------------
  
     int *p_count    : The number of soe's in soes			(OUT)
     
     DEsoe **p_buffer: Pointer to the result				(OUT)
     
     int all         : All entries (including empty and deleted ones) ?	(IN)
  */
  
  
  message DEretrieve ( long *msg; int *p_type; struct IGRdisplay *symb;
                       double *p_u1, *p_u2; GRobjid objid; 
                       double u; struct GRid *window; struct GRmd_env *md_env );
  /*
     This method retrieves an entry from the soo.  The entry is specified by
     objid, view objid, (eventually) context and u parm.  This method is
     mainly used to "locate" a symbology override.
  
     Argument description:
     --------------------
  
     long *msg              : the return status				(OUT)
                              MSSUCC: an entry has been found
                              MSFAIL: no entry was found
  
     int *p_type	    : the type of override			(OUT)
     
     struct IGRdisplay *symb: the symbology				(OUT)
     
     double *p_u1, *p_u2    : parms of override				(OUT)
  
     GRobjid objid          : the objid that has an override		(IN)
  
     struct GRid *window    : the view of the override			(IN)
     
     struct GRmd_env *md_env: the context of the override (can be NULL)	(IN)
     
     double u	            : the u parm of the projected point		(IN)
  */
  
  
  message DEnext ( long *msg; int *p_type; struct IGRdisplay *symb;
                   double *p_u1, *p_u2 );
  /*
     This method retrieves the next entry from the soo.  The next entry is
     only defined when we have a 1/0 overlap and it is defined as the twin
     entry, i.e. the other override to complete the overlap.  This message
     is sent right after a retrieve that returned a DE_OVERLAP type.
  
     Argument description:
     --------------------
  
     long *msg              : the return status				(OUT)
                              MSSUCC: an entry has been found
                              MSFAIL: no entry was found
  
     int *p_type	    : the type of override			(OUT)
     
     struct IGRdisplay *symb : the symbology				(OUT)
     
     double *p_u1, *p_u2    : parms of override				(OUT)
  */

  
  message DEobjid_changed ( long *msg; struct GRid *old_id, *new_id );
  /*
     This method modifies the old_id into the new_id.  The new_id MUST be
     in the same OS.
  
     Argument description:
     --------------------
  
     long *msg          : the return status				(OUT)
                              MSSUCC: entries have been modified
                              MSFAIL: no entry was found
  
     struct GRid *old_id: the old grid of the object			(IN)
                          (i.e. the old object)

     struct GRid *new_id: the new grid of the object			(IN)
                          (i.e. the new object)
  */

end specification DEso;
