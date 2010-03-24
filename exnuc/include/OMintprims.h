/*
---------------------------------------------------------------------------

	Name:			OMintprims.h
	Creation Date:		June-27-1986
	Operating System(s):	Unix SYSV, v2

	Abstract:
        ---------
        	The following OM 4.0 "primitives" are actually "macros"
	which are operated on by the OM pre-processor.  Their purpose,
 	usage, and format are described in more detail in the 
 	"OM 4.0 Interface Description."

      
        The macro names begin with the string "om$" and are followed
        by a wonderfully memnomic suffix describing the macro.


        Notes:
        ------
          These macros are *NOT* intended for use by the PUBLIC (the end user),
        but by internal OM programmers and groupies (hence the origin of the
        "int" (INTernal) "prim"-itives).  The file "OMprimitives.h" contains
        "external primitives" which *ARE* aimed at the general public.

        
	--- Standard names ---
	This list has standard names to use for things
	like object space number (osnum). This will provide an 
    	assurance of a standard interface. It is not complete, and
	should be updated as new names appear in macros.

	class name			classname
	class id			classid
        pointer to classid              p_classid
	os number			osnum
	os name				osname
	channel	address			chanaddr
	channel name			channame
	channel number			channum
        channel selector                chanselect
        pointer to channel selector     p_chanselect
	object id			objid
        object instance pointer         object
	cluster number			clusternum
	maximum size			maxsize
	extend size			extsize
	extend count			extcount
	maximum number of objects	maxobjs
	send depth			depth
	number				num
	data structure name		structure
	size				size
	pointer				ptr
	pointer to logical cluster 
			descriptor	p_clustcmp
	pointer to ActCLassDef		p_ACLD

	Revision History:
        -----------------

	rme001	05-may-1987	Removed three primitives: vla_collapse,
				resize_object, and movary.
        Srikanth 02-Nov-1995    Added a check for OM_OBJ_INVALID
                                macros on the incoming object for
                                om$get_class macro.  If we pass the
                                correct objid but the wrong osnum to 
                                om$construct_and_copy macro, the code 
				was crashing in the call to om$get_class
				which tries to get the details of this
				invalid object. (Its flags contain 0 ).
---------------------------------------------------------------------------
*/

#ifndef   OM_D_INTPRIMS 
#define   OM_D_INTPRIMS   1

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int som_cleanup_cluster __((OM_p_LCD lcd));
extern int som_coalesce __((OM_p_PCD p_pcd, OM_p_CLUSTFHDR p_instance));
extern int som_collapse_channel __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANNEL_HDR *pp_chan, OM_p_CHANNEL_DEFN chdef,
		int *p_chandata, OM_p_BIG_TAIL p_tail, OM_p_CLASSDEF p_acld));
extern int som_connect_add_tail __((OM_p_CHANNEL_HDR p_chan, int *p_chandata,
		OM_p_BIG_TAIL p_tail));
extern int som_connect_build_side __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANSELECT chsel, int relidx, OM_p_CONNECT_SIDE s1));
extern int som_connect_chan_alloc __((OM_p_CONNECT_SIDE s1, int num_ents));
extern int som_connect_check_classlist __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_complete_sides __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_disconnect __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_doconnect __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_get_chent __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_if_connected __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2));
extern int som_connect_insert_rel __((OM_p_CONNECT_SIDE s1));
extern int som_connect_move_check __((OM_p_CONNECT_SIDE s1,
		OM_p_CONNECT_SIDE s2, int copy_flag));
extern int som_connect_pside __((OM_p_CONNECT_SIDE s1, OM_p_CONNECT_SIDE s2));
extern int som_connect_release_side __((OM_p_CONNECT_SIDE s1));
extern int som_connect_return_chent __((OM_p_CONNECT_SIDE s1));
extern int som_create_class __((OM_p_CREATECLASS_ARGS p_arglist,
		OMuword *p_classid));
extern int som_delete_object __((OMuword OSnum, OM_p_OBJECTHDR p_instance,
		OM_S_OBJID objid));
extern int som_find_space_in_lcd __((OM_p_LCD lcd, OMuint align_size,
		OM_p_OBJECTHDR *p_instance, OM_p_CSD *p_csd));
extern int som_free_space __((OM_p_LCD lcd, OM_p_OBJECTHDR p_instance,
		OMuint flag, OMuword OSnum, OM_p_PCD pcd));
extern int som_get_any_instance __((OMuword OSnum, OM_S_OBJID objid,
		OM_p_RIP p_rip));
extern int som_get_channel __((OMuword osnum, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
		OM_p_CHANNEL_HDR **ppp_channel, OM_p_CHANNEL_DEFN *pp_chandef,
		int **pp_chandata, OM_p_BIG_TAIL p_tail,
		OM_p_CHANNUM p_channum));
extern int som_get_class __((OMuword OSnum, char *classname, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OMuword *p_classid,
		OM_p_CLASSDEF *pp_cld));
extern int som_get_instance __((OM_p_RIP p_rip, OM_S_OBJID objid));
extern int som_get_mychan __((int myme, OM_p_CLASSDEF p_acld, int p_chan,
		OM_p_CHANNEL_DEFN *pp_chandef, OM_p_CHANNUM p_channum));
extern int som_is_oper_equal __((OMuword osnum1, OMuword osnum2,
		OM_S_OBJID objid1, OM_S_OBJID objid2,
		OM_S_CHANSELECT chanselect1, OM_S_CHANSELECT chanselect2,
		OMbyte *equal));
extern int som_markModifiedCluster __((OMuword clustNum, OMuint objid,
		OMuword osnum));
extern int som_markNoWrite __((OMuword clustNum, OMuint objid, OMuword osnum));
extern int som_object_alloc __((OM_p_OSD p_osd, OM_S_NEIGHBOR neighbor,
		OMuint size, OM_p_OBJECTHDR *p_instance, OMuword *p_sdi));
extern int som_objid_to_tag __((OMuword osnum, OM_S_OBJID objid,
		OMuint *p_tag, OMuword *p_version, OMuint *p_index,
		void *tag_rec, OMuint *p_free, OMuword **pp_version));
extern int som_ordered_send __((OM_E_WRT_FLAG wrt_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_p_CHANNEL_HDR *pp_chan_hdr,
		OM_p_CHANNEL_DEFN p_chandef, OM_p_BIG_TAIL p_tail,
		int *p_chandata, int index1, int index2));
extern int som_recognize_class __((char *cur_class, char *rec_class,
		char *sub_class, char *mth_class, char *mth_name));
extern int som_send_foreign __((OM_E_WRT_FLAG WRT_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_S_OBJID targetid, OMuword osnum,
		OM_S_CHANNUM in_channum));
extern int som_send_object __((OM_E_WRT_FLAG wrt_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_S_OBJID targetid,
		OM_S_CHANNUM channum));
extern int som_setWriteable __((OMuword clustNum, OMuint objid, OMuword osnum));
extern int som_validate_cluster __((OM_p_LCD lcd));
extern int som_vla_collapse_copy __((OM_p_OBJECTHDR p_orig_object,
		OM_p_OBJECTHDR p_copy, OM_p_SPAMAPENT p_copy_spacemap,
		OM_p_CLASSDEF classdef));
extern int som_vla_find_initial_size __((OM_p_CLASSDEF p_acld, OMuint *size));
extern int som_vla_fixup __((OM_p_OBJECTHDR p_object, char type));
extern int som_vla_get_size_of_object __((OM_p_OBJECTHDR myme,
		OM_p_CLASSDEF classdef, int *p_fixed_size, int *p_size));
extern int som_vla_initialize_offsets __((OM_p_CLASSDEF p_acld,
		OM_p_OBJECTHDR p_instance));
extern int som_vla_remove_outriggers __((OMuword osnum,
		OM_p_SPAMAPENT p_spacemap, OM_p_CLASSDEF p_acld,
		OM_p_LCD p_clustcmp));

#if defined(__cplusplus)
}
#endif

/*----------------------------*/
/*	om$create_class:      */
/*----------------------------*/
/*
**	Creates a new class.
*/
#omdef  om$create_class ( create_class_args, p_classid )

      som_create_class( (create_class_args), (p_classid) )

#endomdef

	/* ************************************ */
	/*  connect, disconnect, move_chan,	*/
	/*  and copy_chan private subroutines   */
	/* ************************************ */

/*-------------------------------*/
/*	om$collapse_channel:     */
/*-------------------------------*/
/*
**	Remove holes from channel var len array
*/

#omdef  om$collapse_channel ( osnum, objid, pp_chan, chdef, p_chandata,
                              p_tail, p_acld=(OM_p_CLASSDEF)NULL )

	som_collapse_channel((osnum), (objid), (pp_chan), (chdef), (p_chandata),
                        (p_tail), (p_acld))

#endomdef

/*--------------------------------*/
/*	om$connect_build_side:    */
/*--------------------------------*/
/*
**	Build OM_S_CONNECT_SIDE
*/

#omdef  om$connect_build_side ( osnum, objid, chsel, relidx, side )

	som_connect_build_side((osnum), (objid), (chsel), (relidx), (side))

#endomdef

/*------------------------------------*/
/*	om$connect_complete_sides     */
/*------------------------------------*/
/*
**	Complete OM_S_CONNECT_SIDE ISO related fields.
*/

#omdef  om$connect_complete_sides ( side1, side2 )

	som_connect_complete_sides((side1), (side2))

#endomdef

/*--------------------------------*/
/*	om$connect_disconnect     */
/*--------------------------------*/
/*
**	If ISO then mark ISO entry.  Set channel used false to force return
**	channel by om$connect_release_side
*/

#omdef  om$connect_disconnect ( side1, side2 )

	som_connect_disconnect( (side1), (side2) )

#endomdef

/*-------------------------------*/
/*	om$connect_doconnect     */
/*-------------------------------*/
/*
**	Change channel fields in Side1 to point to target specified by Side2
*/

#omdef  om$connect_doconnect ( side1, side2 )

	som_connect_doconnect((side1), (side2))

#endomdef

/*--------------------------------*/
/*	om$connect_get_chent      */
/*--------------------------------*/
/*
**	Get a pointer to an available channel link entry for side1.
**	Will expand var length array if necessary.
*/

#omdef  om$connect_get_chent ( side1, side2 )

	som_connect_get_chent((side1), (side2))

#endomdef

/*----------------------------------*/
/*	om$connect_if_connected     */
/*----------------------------------*/
/*
**	Determine whether object determined by side1 is already connected
**	to that determined by side2.
*/

#omdef  om$connect_if_connected ( side1, side2 )

	som_connect_if_connected((side1), (side2))

#endomdef

/*--------------------------------*/
/*	om$connect_insert_rel     */
/*--------------------------------*/
/*
**	Determine correct position for a new channel link in an oredred channel
*/

#omdef  om$connect_insert_rel ( side1 )

	som_connect_insert_rel((side1))

#endomdef

/*------------------------------*/
/*	om$connect_pside        */
/*------------------------------*/
/*
**	Builds a OM_S_CONNECT_SIDE for target pointed to by side1.
*/

#omdef  om$connect_pside ( side1, side2 )

	som_connect_pside((side1), (side2))

#endomdef

/*----------------------------------*/
/*	om$connect_release_side     */
/*----------------------------------*/
/*
**	Cause return of channel link entry if not used
**	and release object instance held by side rip.
*/

#omdef  om$connect_release_side ( side1 )

	som_connect_release_side((side1))

#endomdef

/*----------------------------------*/
/*	om$connect_return_chent     */
/*----------------------------------*/
/*
**	Delete channel link entry.
*/

#omdef  om$connect_return_chent ( side1 )

	som_connect_return_chent((side1))

#endomdef

/*----------------------------------*/
/*	om$connect_move_check       */
/*----------------------------------*/
/*
**	Check that move or copy channel can complete without error.
*/

#omdef  om$connect_move_check ( side1, side2, copy_flag )

	som_connect_move_check ((side1), (side2), (copy_flag))

#endomdef

/*----------------------------------*/
/*	om$connect_check_classlist  */
/*----------------------------------*/
/*
**	Check that classlists in both channels will allow connection.
*/

#omdef  om$connect_check_classlist ( side1, side2  )

	som_connect_check_classlist ((side1), (side2) )

#endomdef

/*--------------------------------*/
/*	om$connect_chan_alloc     */
/*--------------------------------*/
/*
**	Allocate (reallocate) a channel structure (vla).
*/

#omdef  om$connect_chan_alloc ( side1, num_ents )

	som_connect_chan_alloc( (side1), (num_ents) )

#endomdef

/*----------------------------------*/
/*	om$connect_add_tail         */
/*----------------------------------*/
/*
**	Add a tail structure to the end of a channel array if there is room
*/

#omdef  om$connect_add_tail ( p_chan, p_chandata, tail )

	som_connect_add_tail( (p_chan), (p_chandata), (tail) )

#endomdef

/*----------------------------*/
/*	om$object_alloc       */
/*----------------------------*/
/*
**	Allocate a new object and return a pointer to it
**              as well as its slot descriptor index (sdi)
*/

#omdef	om$object_alloc ( p_osd, neighbor, size, object, sdi )

	   som_object_alloc((p_osd), (neighbor), (size), (object), (sdi))

#endomdef


/*-------------------*/
/*    om$get_class   */
/*-------------------*/
/*
**    Return active classid and pointer to ACLD.
**    If p_classid is NULL only ACLD is returned.
*/

#omdef om$get_class (osnum=OM_Gw_current_OS,
                     classname=(char *)NULL ^ objid=NULL_OBJID ^ object=(OM_p_OBJECTHDR)NULL,
                     p_classid=(OMuword *)NULL,
                     pp_cld,
                     check_os=1)

#if om$equal(p_classid,(OMuword *)NULL) && !om$equal(object,(OM_p_OBJECTHDR)NULL) && om$equal(check_os,1)

   (
      ( 
         (((OMuword)(osnum)) >= OM_Gw_maxOS)
                        ||
         (OM_GA_OSDs[((OMuword)(osnum))] == NULL)
      )
      ?
         OM_E_NOSUCHOS
      :
         (
            (  
              (! (OM_OBJ_INVALID(OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
                  ((OM_p_OBJECTHDR)(object))->oid].flags)) )
                              &&
	      (! (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
		  ((OM_p_OBJECTHDR)(object))->oid].flags & OM_SM_unknown_obj))
			      &&
               ((*((OM_p_CLASSDEF *)(pp_cld)) = 
                   OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
                   ((OM_p_OBJECTHDR)(object))->oid].p_acld) != NULL) 
                              &&
               (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
                ((OM_p_OBJECTHDR)(object))->oid].p_acld->w_classid < 
                  OM_Gw_numclasses)
                              &&
               (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
                   ((OM_p_OBJECTHDR)(object))->oid].p_acld->w_classid != 0)
                              &&
               (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
                   ((OM_p_OBJECTHDR)(object))->oid].p_acld->w_classid != 
                   OM_K_NOTUSING_CLASSID)
            ) 
            ? 
               OM_S_SUCCESS 
            : 
               OM_E_NOSUCHCLASS
         )
   )

#else
#if om$equal(p_classid,(OMuword *)NULL) && !om$equal(object,(OM_p_OBJECTHDR)NULL) && om$equal(check_os,0)

   (
        (! (OM_OBJ_INVALID(OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
            ((OM_p_OBJECTHDR)(object))->oid].flags)) )
                        &&
        (! (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
            ((OM_p_OBJECTHDR)(object))->oid].flags & OM_SM_unknown_obj))
			&&
         ((*((OM_p_CLASSDEF *)(pp_cld)) = 
          OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
          ((OM_p_OBJECTHDR)(object))->oid].p_acld) != NULL) 
                        &&
         (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
          ((OM_p_OBJECTHDR)(object))->oid].p_acld->w_classid < 
          OM_Gw_numclasses)
                        &&
         (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
          ((OM_p_OBJECTHDR)(object))->oid].p_acld->w_classid != 0)
                        &&
         (OM_GA_OSDs[((OMuword)(osnum))]->Spacemap[
          ((OM_p_OBJECTHDR)(object))->oid].p_acld->w_classid != 
          OM_K_NOTUSING_CLASSID)
      ? 
         OM_S_SUCCESS 
      : 
         OM_E_NOSUCHCLASS
   )

#else
       som_get_class((osnum),(classname),(objid),(object),(p_classid),(pp_cld))
#endif
#endif
#endomdef


/*------------------------*/
/*    om$get_channel      */
/*------------------------*/
/*
**    Returns a pointer to a channel and a pointer to the channel definition
**    given a channel selector and (osnum, objid) or an instance pointer 
**    (object).
*/

#omdef om$get_channel ( osnum=OM_Gw_current_OS,
                        objid=NULL_OBJID,
                        object=(OM_p_OBJECTHDR)NULL,
                        p_chanselect,
                        pp_channel,
                        pp_chandef=(OM_p_CHANNEL_DEFN*)NULL,
                        pp_chandata=(int **)NULL,
                        p_tail=(OM_p_BIG_TAIL)NULL,
                        p_channum=(OM_p_CHANNUM)NULL )


   som_get_channel(	(osnum),(objid),(object),(p_chanselect),
                        (pp_channel),(pp_chandef), (pp_chandata),(p_tail),
                        (p_channum))

#endomdef

/*------------------------------*/
/*       om$get_mychan          */
/*------------------------------*/
/*
**     Given a pointer to an object and its class definition and a pointer
**      to a channel within the object,  this primitive will return the
**      channel number of said channel.  Optionally the channel definition
**      structure will also be returned.  
**
**      NOTE - the classid field of the channel number will contain an
**             active classid.
*/

#omdef om$get_mychan ( p_object, 
                       p_cld, 
                       p_channel, 
                       pp_chandef=NULL,
                       p_channum )

   som_get_mychan((p_object), (p_cld), (p_channel), (pp_chandef), (p_channum))

#endomdef


/*------------------------------*/
/*       om$get_instance        */
/*------------------------------*/
/*
**   given an object id - initialize the RIP structure
*/

#omdef om$get_instance ( objid, p_rip )

   som_get_instance((p_rip),(objid))

#endomdef

/*------------------------------*/
/*       om$release_instance    */
/*------------------------------*/

#omdef om$release_instance ( rip )
#endomdef

/*----------------------------------*/
/*       om$get_any_instance        */
/*----------------------------------*/
/*
**   given an object id and an OS number - initialize the RIP structure
*/

#omdef om$get_any_instance ( osnum, objid, p_rip )

   som_get_any_instance((osnum), (objid), (p_rip))
#endomdef

/*----------------------------------*/
/*       om$release_any_instance    */
/*----------------------------------*/

#omdef om$release_any_instance ( osnum, rip )
#endomdef

/*-------------------------*/
/*   om$make_current_os    */
/*-------------------------*/
/*
**   Change all global variables that refer to the current OS
**     such that the specified osnum will become the current OS
**     
**     NOTE - NOTE - NOTE ---- IT DOES NOT VALIDATE THE GIVEN OSNUM !!! 
*/

#omdef om$make_current_os ( osnum )
{
    OM_Gw_senders_OS = (osnum);
    OM_Gw_current_OS = (osnum);
    OM_Gp_CurOSD = OM_GA_OSDs[OM_Gw_current_OS];
    OM_GO_current_OS_objid = OM_Gp_CurOSD->OSO_Oid;
    OM_GA_active_to_filed = OM_Gp_CurOSD->ActToFil;
    OM_GA_filed_to_active = OM_Gp_CurOSD->FilToAct;
    OM_Gp_CurSpaceMap = OM_Gp_CurOSD->Spacemap;
}
#endomdef

/*--------------------------------------------------------*/
/*       OM_FREE_OBJID                                    */
/*--------------------------------------------------------*/
/*
**  frees the slot in the appropriate spacemap
**  only used by om$delete_object and om$construct
*/

#define OM_FREE_OBJID( objid, osnum ) \
  OM_GA_OSDs[(osnum)]->Spacemap[(objid)] = OM_GS_NULL_SPAMAPENT;

/*------------------------------*/
/*	om$delete_object	*/
/*------------------------------*/
/*
**  Deletes the specified object
**  Only called from Root's delete method and construct
**  NOTE - object is a required argument for OM3.2 compatability
*/

#omdef	om$delete_object ( osnum, object, objid )

	som_delete_object((osnum), (object), (objid))

#endomdef

/*------------------------------*/
/*	om$cleanup_cluster	*/
/*------------------------------*/
/*
** Cleans up virtual memory extents within cluster
*/

#omdef	om$cleanup_cluster ( p_clustcmp )

     som_cleanup_cluster((p_clustcmp))

#endomdef


/*------------------------------------------------------*/
/*	om$is_oper_equal				*/
/*------------------------------------------------------*/
/*
**  Only used by set_operation to determine the equivalence
**  of two operands.  Two operands  are considered equivalent 
**  if their osnums, objids and channel selectors are equal.
**  If the two operands are equal, the equal flag is set to true.
*/

#omdef 	om$is_oper_equal( osnum1, osnum2, objid1, objid2, 
		chanselect1, chanselect2, equal )

	som_is_oper_equal((osnum1), (osnum2), (objid1), 
	   	(objid2), (chanselect1), (chanselect2), (equal))

#endomdef


#define OM_VLA_set_pointers(me,classdef) 1

/*--------------------------------------*/
/*      om$vla_get_size_of_object       */
/*--------------------------------------*/
/*
**      Returns the fixed size of the object and the total size of
**      object. (The total size includes all vla's.)
*/
#omdef om$vla_get_size_of_object(object,
                                 p_cld,
                                 p_fixed_size,
                                 p_total_size)

    som_vla_get_size_of_object((object), (p_cld),
    			(p_fixed_size), (p_total_size))
#endomdef


/*---------------------------------*/
/*      om$vla_collapse_copy       */
/*---------------------------------*/
/*
**      Used to collapse the vla's in a newly constructed copy
**      of an object.
**
**      p_orig_object = pointer to instance of the original
**      p_copy = pointer to the newly constructed copy.
**      p_spacemap = pointer to the spacemap entry of the copy.
**                   (This can be set to zero in the event that a spacemap
**                    entry does not exist.)
**      p_cld = pointer to the acld.
*/
#omdef om$vla_collapse_copy(p_orig_object,
                        p_copy,
                        p_spacemap,
                        p_cld)

    som_vla_collapse_copy((p_orig_object), (p_copy), (p_spacemap), (p_cld))
#endomdef


/*---------------------------------*/
/*      om$vla_find_initial_size   */
/*---------------------------------*/
/*
**      Finds the number of bytes required to construct an object of the 
**      specified class.  (Can be called before an object exists to
**      determine the number of bytes to allocate.)
*/
#omdef om$vla_find_initial_size(p_cld,
                                p_size)                        
    som_vla_find_initial_size((p_cld), (p_size))
#endomdef


/*--------------------------------------*/
/*      om$vla_initialize_offsets       */
/*--------------------------------------*/
/*
**      Establishes initial offsets and pointers for VLAs in a
**      newly constructed object.
*/
#omdef om$vla_initialize_offsets(p_cld, object)
    som_vla_initialize_offsets((p_cld), (object))
#endomdef

/*--------------------------------------*/
/*      om$vla_remove_outriggers        */
/*--------------------------------------*/
/*
**      Used to free memory used by vla outriggers prior to deleting
**      an object.  Saves the overhead of a collapse call.
*/
#omdef om$vla_remove_outriggers ( osnum=OM_Gw_current_OS,
                                  p_spacemap,
                                  p_acld,
                                  p_clustcmp )
    som_vla_remove_outriggers((osnum),(p_spacemap),(p_acld),(p_clustcmp))
#endomdef

/*--------------------------------------*/
/*      om$vla_fixup                    */
/*--------------------------------------*/
/*
**      Used to convert vla pointers to and fro offsets.  Used when putting
**	objects into a file and reading objects from a file.
*/
#omdef om$vla_fixup( p_object, type )
    som_vla_fixup((p_object), (type))
#endomdef

/*---------------------------------*/
/*      om$send_obj_int            */
/*---------------------------------*/
/*
**      Internal send object because public macro does not have
**      channum as an argument.
*/
#omdef om$send_obj_int( mode=OM_e_wrt_object, msg,
	                senderid, targetid, channum )

	som_send_object((mode), (msg), (senderid), (targetid), (channum))
#endomdef


/*---------------------------------*/
/*      om$send_foreign            */
/*---------------------------------*/
/*
**      Internal to send a message to an object in a foreign OS
*/

#omdef om$send_foreign ( mode=OM_e_wrt_object,
                         msg,
                         senderid,
                         targetid,
                         targetos,
                         channum )

	som_send_foreign((mode), (msg), (senderid), (targetid), (targetos), (channum))
#endomdef

/*---------------------------------*/
/*      om$ordered_send            */
/*---------------------------------*/
/*
**      Internal to channel send.
*/
#omdef om$ordered_send ( mode, msg, senderid,
	                 pp_chan_hdr, p_chandef, p_tail, p_chandata,
			 from, to )

	som_ordered_send((mode), (msg), 
			(senderid), (pp_chan_hdr), (p_chandef),
			(p_tail), (p_chandata), (from), (to))
#endomdef

/*-----------------------------*/
/*   om$find_space_in_lcd      */
/*-----------------------------*/
/*
**   Used to search for contiguous space with LCD.
*/

#omdef om$find_space_in_lcd ( p_clustcmp,
                       size,
                       pp_instance,
                       pp_csd )

    som_find_space_in_lcd((p_clustcmp),(size),(pp_instance),(pp_csd))
#endomdef

/*----------------------*/
/*   om$free_space      */
/*----------------------*/
/*
**   Used to free a chunk of memory.
*/

#omdef om$free_space ( p_clustcmp,
                       p_instance,
                       flag,
                       osnum=OM_Gw_current_OS,
                       p_extent )

    som_free_space((p_clustcmp),(p_instance),(flag),(osnum),(p_extent))
#endomdef

/*-------------------------------*/
/*    om$coalesce                */
/*-------------------------------*/
/*
**   Used to coalesce free space in a cluster.
*/

#omdef om$coalesce ( p_extent, p_instance )

   som_coalesce((p_extent),(p_instance))
#endomdef

/*------------------------------*/
/*     om$validate_cluster      */
/*------------------------------*/
/*
**    Used to validate the internal OM memory management data structures
*/

#omdef om$validate_cluster ( p_clustcmp )

   som_validate_cluster((p_clustcmp))
#endomdef

/*---------------------------*/
/*   om$get_tag_data         */
/*---------------------------*/
/*
**   This primitive returns information about a tagged object:
**
**   osnum, objid:  Identify the tagged object.
**   p_tag:         Optional pointer to the returned tag.
**   p_version:     Optional pointer to the returned version.
**   p_index:       Pointer to the returned index in the tag record vla.
**   tag_rec:       Optional address of the first element in the tag record
**                  vla.  (Used to increase efficiency.)
**   p_free:        Optional pointer to the returned index of a hash entry
**                  which has been free'ed.  Note: if p_free is not NULL it
**                  is assumed that the tag record will be removed.  Therefore
**                  the hash entry associated with the tag record is unlinked.
**   pp_version:    Optional returned pointer to the version field in the tag 
**                  record itself.
*/

#omdef om$get_tag_data ( osnum = OM_Gw_current_OS,
                         objid = my_id,
                         p_tag = (OMuint *)NULL,
                         p_version = (OMuword *)NULL,
                         p_index = (OMuint *)NULL,
                         tag_rec = (OM_p_TAG_RECORD)NULL,
                         p_free = (OMuint *)NULL,
                         pp_version = (OMuword **)NULL )

   som_objid_to_tag((osnum),(objid),(p_tag),(p_version),(p_index),(tag_rec),
                    (p_free),(pp_version))

#endomdef

/* Extremely private! */

#omdef om$recognize_class( cur_class,
                           rec_class,
			   sub_class,
			   mth_class,
			   mth_name )

   som_recognize_class((cur_class),(rec_class),(sub_class),(mth_class),(mth_name))

#endomdef

#omdef om$markNoWrite ( clusternum=NULL ^ objid=NULL_OBJID,	/* saw001 */
                        osnum=OM_Gw_current_OS ) 

   som_markNoWrite( (clusternum), (objid), (osnum) )
            	
#endomdef

#omdef om$markModified ( objid=NULL_OBJID, osnum=OM_Gw_current_OS ) /* saw001 */

   som_markModifiedCluster( (NULL), (objid), (osnum) )
            	
#endomdef

#omdef om$markModifiedCluster ( clusternum=NULL,   	/* saw001 */
                                osnum=OM_Gw_current_OS )

   som_markModifiedCluster( (clusternum), (NULL_OBJID), (osnum) )
            	
#endomdef

#omdef om$setWriteable ( clusternum=NULL ^ objid=NULL_OBJID,	/* saw001 */
                        osnum=OM_Gw_current_OS ) 

   som_setWriteable( (clusternum), (objid), (osnum) )
            	
#endomdef


#endif          /* end of "OMintprims.h" ****** DO NOT ADD BELOW HERE ******/
