/*
---------------------------------------------------------------------------

	Name:			OMprimitives.h
	Creation Date:		June-27-1986
	Operating System(s):	Unix SYSV, v2

	Abstract:
        ---------
        	The following OM 4.0 "primitives" are actually "macros"
	which are operated on by the OM pre-processor.  Their purpose,
 	usage, and format are described in more detail in the 
 	"OM 4.0 Interface Description."

        Notes:
        ------
		These macros are intended for use by the PUBLIC (the
	end user), as well as by internal OM programmers and groupies.
	The file "OMintprims.h" contains "internal primitives" which are
   	not aimed at the general public.

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
	neighbor structure pointer	p_neighbor
	object id pointer		p_objid
	method index			method_index
        message name			msg_name

	Revision History:
        -----------------

jkm001	1-jul-1986	added list of 'standard' macro variable names 

saw001	14-sep-1988	Add no-write non-modified clusters prim macros.

---------------------------------------------------------------------------
*/

#ifndef  OM_D_PRIMITIVES         
#define  OM_D_PRIMITIVES   1  

#include "OMminimum.h"

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

extern char *som_calloc __((OMuint number, OMuint size));
extern int som_cancel_intercept __((OMuword osnum, OM_S_OBJID objid));
extern int som_change_class __((OMuword osnum, OM_S_OBJID objid,
		char *classname, OMuint sd_override));
extern int som_change_os_name __((OMuword OSnum, char *name,
		OM_e_OVRWRT_FLG overwrite));
extern int som_change_os_name_by_name __((char *curr_name, char *name,
		OM_e_OVRWRT_FLG overwrite));
extern int som_change_tag_version __((OMuword osnum, OM_S_OBJID objid,
		OMuword version, OMbyte flag));
extern int som_channel_preset __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANSELECT p_chansel, OMuint size));
extern int som_channel_unpreset __((OMuword os, OM_S_OBJID oid,
		OM_p_CHANSELECT p_chansel, int collapse_flag));
extern int som_construct_and_copy __((OM_p_OBJECTHDR p_object,
		OM_S_OBJID objid, OMuword obj_osnum, OMuword osnum,
		char *osname, OM_S_NEIGHBOR neighbor, OM_p_OBJID p_objid,
		OMuint *p_tag));
extern int som_construct_object __((char *classname, OMuword classid,
		OM_S_OBJID objid, OM_p_OBJECTHDR p_object, OMuword obj_osnum,
		OMuword osnum, char *osname, OM_p_OBJID p_objid,
		OM_p_MESSAGE msg, OM_S_NEIGHBOR neighbor, OMuint *p_tag));
extern int som_construct_os __((OMuint classid, uword *osnum, char *osname,
		OM_p_OBJID p_objid, OMuint initcount, OMuint extcount,
		OMuint *resultcount, OMuint maxobjsize, OMuint loadmode,
		char sameosflag, char *di_logical));
extern int som_construct_os_by_name __((char *classname, uword *osnum,
		char *osname, OM_p_OBJID p_objid, OMuint initcount,
		OMuint extcount, OMuint *resultcount, OMuint maxobjsize,
		OMuint loadmode, char sameosflag, char *di_logical));
extern int som_convert_internal_osname_to_number __((char *name,
		OMuword *OSnum));
extern int som_convert_number_to_internal_osname __((OMuword OSnum,
		char *name));
extern int som_convert_os_name_to_number __((char *name, OMuword *OSnum));
extern int som_convert_os_number_to_name __((OMuword OSnum, char *name));
extern int som_create_big_object __((OMuword clusterid, OMuint size,
		OM_p_OSD p_osd, OM_p_OBJECTHDR *p_instance, OM_p_CSD *p_csd));
extern void som_dealloc __((void *ptr));
extern int som_disable_intercept __((OMuword osnum, OM_S_OBJID objid));
extern int som_dynamic_class __((char *p_parent_class[], OMuword num_parents,
		OMuword maj_version, OMuword min_version,
		char *p_dynamic_class));
extern int som_dynamic_load __((char *object_file));
extern int som_enough_disk_space __((OMuword input_osnum, char *osname,
		char *filename, int filesize));
extern int som_flagged_tag_connects __((OMuword osnum, OMuword tag_osnum,
		OMuint *p_count, OMuint size, OM_p_TAG_CON_INFO p_tag_info,
		OMuword mask));
extern int som_getClusterFromObject __((OMuword *pClustNum, OMuint objid,
		OMuword osnum));
extern int som_get_all_parents __((OMuword classid, char *classname,
		OMuword parent_list[], OMuint size, OMuint *count));
extern int som_get_channel_count __((OMuword osnum, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
		OMuint *count));
extern int som_get_channel_name __((char *channame, OM_S_CHANNUM channum));
extern int som_get_channel_number __((char *channame, OM_p_CHANNUM p_channum));
extern int som_get_channel_objects __((OMuword osnum, OM_S_OBJID objid,
		OM_p_OBJECTHDR p_object, OM_p_CHANSELECT p_chanselect,
		OM_S_OBJECT_LINKAGE list[], OMuint size, OMuint *count));
extern int som_get_classid __((OMuword OSnum, char *classname,
		OM_S_OBJID objid, OM_p_OBJECTHDR p_object, OMuword *p_classid));
extern int som_get_classname __((OMuword OSnum, OMuword classid,
		OM_S_OBJID objid, OM_p_OBJECTHDR p_object, char *classname));
extern int som_get_index __((OMuword osnum_c, OM_S_OBJID objid_c,
		OM_p_OBJECTHDR p_object_c, OM_p_CHANSELECT p_chanselect,
		OM_S_OBJID objid, OMuword osnum2, OMuint *index));
extern int som_get_intercept __((OMuword osnum, OM_S_OBJID objid,
		OMuword *p_target_osnum, OM_p_OBJID p_target_objid));
extern int som_get_mem_info __((int *avail_swap, int *total_swap,
		int *phys_mem, int *avail_om, int *total_om, int *total_free));
extern int som_get_message_name __((char *classname, OMuword classid,
		OMuword method_index, char *msg_name));
extern int som_get_objid_at_index __((OMuword osnum_c, OM_S_OBJID objid_c,
		OM_p_OBJECTHDR p_object_c, OM_p_CHANSELECT p_chanselect,
		OMuint index, OM_S_OBJID *objid, OMuword *osnum2));
extern int som_get_os_senddepth __((OMuword OSnum, OMuint *depth));
extern int som_get_parent_classid __((OMuword classid, char *classname,
		OMuword *parent_classid));
extern int som_get_parent_classname __((OMuword classid, char *classname,
		char *parent_classname));
extern int som_get_parent_count __((OMuword classid, char *classname,
		OMuword *parent_count));
extern int som_get_senddepth __((OMuword osnum, OM_S_OBJID objid,
		OMuword *p_depth));
extern int som_inquire_os __((OMuword osnum, OM_p_DUPINTOS *pp_dup));
extern int som_is_ancestry_valid __((OMuword sub_classid,
		OMuword super_classid, char *sub_classname,
		char *super_classname));
extern int som_is_objid_on_channel __((OMuword osnum_c, OM_S_OBJID objid_c,
		OM_p_OBJECTHDR p_object_c, OM_p_CHANSELECT p_chanselect,
		OM_S_OBJID objid, OMuword osnum2));
extern int som_is_objid_valid __((OMuword OSnum, OM_S_OBJID objid));
extern int som_make_chanselect __((char *channame, OM_S_CHANNUM channum,
		OM_p_CHANNEL_HDR *chanaddr, OM_p_CHANSELECT p_chanselect));
extern int som_make_message __((char *class_name, OMuword classid,
		char *meth_name, OMuword size, void *p_arglist,
		OM_p_MESSAGE p_msg));
extern int som_make_neighbor __((OMuword osnum, OM_S_OBJID objid,
		OM_p_NEIGHBOR p_neighbor));
extern char *som_malloc __((OMuint size));
extern int som_move_tag __((OMuword osnum, OM_S_OBJID old_objid,
		OM_S_OBJID new_objid));
extern int som_objid_to_tag __((OMuword osnum, OM_S_OBJID objid,
		OMuint *p_tag, OMuword *p_version, OMuint *p_index,
		void *tag_rec, OMuint *p_free, OMuword **pp_version));
extern int som_osnum_to_oso_objid __((OMuword osnum, OM_p_OBJID p_objid));
extern int som_parse_channame __((char *channame, char *s_class,
		char *s_channel));
extern char *som_realloc __((char *ptr, OMuint size));
extern int som_remove_object_tag __((OMuword osnum, OM_p_OBJECTHDR p_object,
		OM_S_OBJID objid));
extern int som_report_class_version __((OMuword classid, char *classname,
		OMuword *major, OMuword *minor));
extern void som_report_error __((OMulong sts));
extern int som_report_version __((OMuword *major, OMuword *minor));
extern int som_runtime_init __((int paramc, char *param_list[]));
extern int som_send_channel __((OM_E_WRT_FLAG WRT_flag, OM_p_MESSAGE msg,
		OMuword osnum, OM_S_OBJID senderid, OM_p_CHANSELECT p_chansel,
		int frm, int to));
extern int som_send_foreign __((OM_E_WRT_FLAG WRT_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_S_OBJID targetid, OMuword osnum,
		OM_S_CHANNUM in_channum));
extern int som_send_object __((OM_E_WRT_FLAG wrt_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_S_OBJID targetid,
		OM_S_CHANNUM channum));
extern int som_set_dynamic_defaults __((int paramc, char *param_list[]));
extern int som_set_intercept __((OMuword osnum, OM_S_OBJID objid,
		OMuword target_osnum, OM_S_OBJID target_objid));
extern void som_set_os_type __((OMuword osnum, int *p_num, unsigned char flag));
extern int som_set_tag_os __((OMuword *p_prev_osnum, OMuword osnum));
extern int som_sibling_send __((OM_E_WRT_FLAG WRT_flag, OM_p_MESSAGE msg,
		OM_S_OBJID senderid, OM_p_CHANSELECT p_chansel,
		OM_E_INC_FLAG inclusive));
extern char *som_sm_calloc __((unsigned nelem, unsigned elsize));
extern void som_sm_dealloc __((void *ptr));
extern char *som_sm_malloc __((unsigned request));
extern char *som_sm_realloc __((char *ptr, unsigned nbytes));
extern int som_tag_object __((OMuword osnum, OM_p_OBJECTHDR p_object,
		OM_S_OBJID objid, OMuint *p_tag));
extern int som_tag_to_objid __((OMuword osnum, OMuint tag, OM_p_OBJID p_objid,
		OMuword *p_version));
extern int som_test_connection __((OMuword osnum, OM_S_OBJID objid,
		OM_p_CHANSELECT csel, OMuword tag_osnum, OM_S_OBJID tag_objid,
		OM_p_CHANSELECT tag_csel, OMuword *p_version,
		OMuword *p_tag_version, int force_flag));
extern int som_vla_set_dimension __((int *p_offset, unsigned int *p_count,
                OMuint dim, OMuword osnum, OM_S_OBJID objid,
                OM_p_CLASSDEF p_acld, int move_data));
extern int OMpms_prnt __((char *format, ...));
extern int OMpms_prntHdr __((char *format, ...));

#if defined(__cplusplus)
}
#endif

/*---------------------*/
/*  get channel count  */
/*---------------------*/
/*
**	Counts the number of objids on a specified channel.
**      (snum is used to obtain a pointer to the channel if necessary.)
*/

#omdef  om$get_channel_count ( osnum=OM_Gw_current_OS,
                               objid=NULL_OBJID ^ object=(OM_p_OBJECTHDR)NULL,
                               p_chanselect,
                               count )

    som_get_channel_count(     (osnum), (objid), (object),
                               (p_chanselect), (count))
#endomdef

/*-----------------------*/
/*  get channel objects  */
/*-----------------------*/
/*
** This routine builds a list of object linkages that are on a given channel.
** list is an array of object linkages which must be allocated by the user.
** size is the number of object linkages in the list.
** (osnum is used to obtain a channel pointer if necessary.)
*/
        
#omdef  om$get_channel_objects ( osnum=OM_Gw_current_OS,
                                 objid=NULL_OBJID ^ object=(OM_p_OBJECTHDR)NULL,
                                 p_chanselect,
                                 list,
                                 size,
                                 count )

    som_get_channel_objects((osnum), (objid), (object),
                            (p_chanselect), (list), (size),
                            (count))
#endomdef

/*---------------------*/
/*  get channel number */
/*---------------------*/
/*
**	This gets an object's channel number based on its channel name.
*/

#omdef om$get_channel_number ( channame, p_channum )

    som_get_channel_number((channame),(p_channum))

#endomdef

/*-------------------*/
/*  get channel name */
/*-------------------*/
/*
**	This gets an object's channel name based on its channel number.
**      Channame represents an array of characters and should be di-
**      mensioned to OM_K_MAXCHANNAME_LEN.  (This allows for a channel
**      name with a qualifying class name.)
*/

#omdef om$get_channel_name  ( channum, channame )

    som_get_channel_name((channame),(channum))

#endomdef

/*-------------------*/
/*  make chanselect  */
/*-------------------*/
/*
**   Fills in a channel selector structure given a channame.
**   Always uses the 'num' type.  (This can reduce the number of conversions
**   from channame to channum.)
*/

#omdef  om$make_chanselect ( channame=(char *)NULL ^
                             channum=NULL_CHANNUM  ^
                             chanaddr=(OM_p_CHANNEL_HDR *)NULL,
                             p_chanselect )

   som_make_chanselect((channame),(channum),(chanaddr),(p_chanselect))
#endomdef

/*------------------*/
/*  parse channame  */
/*------------------*/
/*
**  Separates a channame string into two strings: s_class - class name, and
**  s_channel - channel name.  The s_class array should be dimensioned as
**  OM_K_MAXCLASS_LEN characters.  The s_channel array should be dimensioned 
**  as OM_K_MAXCHANNEL_LEN characters.  (If channame does not contain a 
**  class name, s_class[0] will be set to NULL.)
**
**  If pp_dot is not equal to NULL, this macro just returns the pointer to
**  the dot in the existing channame.  If a dot does not exist NULL is 
**  returned.
*/

#omdef om$parse_channame ( channame,
                           s_class=(char *)NULL,
                           s_channel=(char *)NULL,
                           pp_dot=NULL )
#if !om$equal(pp_dot, NULL)
   (
      (
         *((char **)(pp_dot)) = (char *) strrchr(channame, '.')
      )
      ?
         OM_S_SUCCESS
      :  
         OM_S_SUCCESS
   )
#else
   som_parse_channame((channame), (s_class), (s_channel))
#endif
#endomdef

/*-----------------------*/
/*  is objid on channel  */
/*-----------------------*/
/*
**	This routine checks whether or not the given objid is on the
**      the specified channel. The "c" parameters are used to identify
**      the channel. (osnum_c is used to get a channel pointer
**      if necessary.)  objid and osnum2 represent the object to search for.
*/

#omdef om$is_objid_on_channel ( osnum_c=OM_Gw_current_OS,
                              objid_c=NULL_OBJID ^ object_c=(OM_p_OBJECTHDR)NULL,
                              p_chanselect,
                              objid,
                              osnum2=OM_Gw_current_OS )

   som_is_objid_on_channel((osnum_c), (objid_c), (object_c),
                           (p_chanselect), (objid), (osnum2))
#endomdef


/*-------------*/
/*  get index  */
/*-------------*/
/*
**  This routine will return the relative or absolute index of
**  (objid, osnum2) on a channel.   Channel flags dictate the type
**  of index returned.  The "c" parameters are used along with
**  the channel selector to identify the channel.  Indexaddr is
**  the address where the resulting index will be stored.
*/

#omdef om$get_index ( osnum_c=OM_Gw_current_OS,
                      objid_c=NULL_OBJID ^ object_c=(OM_p_OBJECTHDR)NULL,
                      p_chanselect,
                      objid,
                      osnum2=OM_Gw_current_OS,
                      indexaddr )

    som_get_index(     (osnum_c), (objid_c), (object_c), 
                       (p_chanselect), (objid), (osnum2), 
                       (indexaddr))
#endomdef


/*----------------------*/
/*  get objid at index  */
/*----------------------*/
/*
**  This routine will return the objid and osnum of the object at
**  the specified index in an ordered channel.  The index is interpreted
**  as relative or absolute depending on the channel flags.  Objidaddr and
**  osnumaddr are the memory locations where the object info is stored.
**  The other parameters identify the channel and the index.
*/

#omdef om$get_objid_at_index ( osnum=OM_Gw_current_OS,
                               objid=NULL_OBJID ^ object=(OM_p_OBJECTHDR)NULL,
                               p_chanselect,
                               index,
                               objidaddr,
                               osnumaddr)

    som_get_objid_at_index((osnum), (objid), (object), (p_chanselect), (index), (objidaddr), (osnumaddr))
#endomdef

/*------------------------*/
/*  channel preset macro  */
/*------------------------*/
/*
**  This macro is used to preset the size of a given channel.  It is 
**  used when a channel is known to contain a large number of 
**  connections and is not typical of the channel definition.
**  While the channel is in "preset" mode,  there will be no attempt
**  to collapse it.  Size is the number of expected connections.
**  NOTE:  The om$channel_unpreset macro can be used to return the
**         channel to the nornmal state.
*/

#omdef om$channel_preset ( osnum = OM_Gw_current_OS,
                           objid = my_id,
                           p_chanselect,
                           size )
  som_channel_preset((osnum),(objid),(p_chanselect),(size))

#endomdef


/*--------------------------*/
/*  channel unpreset macro  */
/*--------------------------*/
/*
**  This macro is used to return a preset channel back to the
**  state of a normal channel.  The bottom line is that it will
**  be collapsable.  The collapse_flag arg is used to specify
**  whether or not to collapse the channel.
**
*/

#omdef om$channel_unpreset ( osnum = OM_Gw_current_OS,
                             objid = my_id,
                             p_chanselect,
                             collapse_flag = 1 )
  som_channel_unpreset((osnum),(objid),(p_chanselect),(collapse_flag))

#endomdef


/*-----------------------------------*/
/*  object space construction macro  */
/*-----------------------------------*/
/*
** this macro will require either classname or classid to be specified
** as well as a place for osnum and the osname 
*/

#omdef om$construct_os ( classname ^ classid,
                         osnum,
                         osname,
			 p_objid,
			 initcount=0,
                         extcount=0,
		 	 resultcount=0,
                         maxobjsize=0,
			 loadmode=0,
			 sameosflag=0,
                         di_logical=(char *)NULL)

#if om$specified (classname)
  som_construct_os_by_name((classname),(osnum),(osname),(p_objid),(initcount),(extcount),
    (resultcount),(maxobjsize),(loadmode),(sameosflag),(di_logical))

#endif

#if om$specified (classid)
  som_construct_os((classid),(osnum),(osname),(p_objid),(initcount),(extcount),(resultcount),
    (maxobjsize),(loadmode),(sameosflag),(di_logical))

#endif
#endomdef

/*---------------------*/
/*   construct macro   */
/*---------------------*/
/*   The class of object to be constructed can be derived by
**        one of the following: 1) classname  (construct by classname)
**                              2) classid    (construct by classid)
**                              3) objid      (construct by objid)
**                              4) object     (construct using me)
**
**   Note: if objid or object is specified - obj_osnum is the Object Space
**         number of the objid or object specified.
**
**         if osnum and osname are both specified then osname is used.
*/

#omdef om$construct ( classname=(char*)NULL ^
                      classid=OM_K_NOTUSING_CLASSID ^
                      objid=NULL_OBJID ^
                      object=(OM_p_OBJECTHDR)NULL,
                      obj_osnum=OM_Gw_current_OS,
                      osnum=OM_Gw_current_OS,
                      osname=(char *)NULL,
                      p_objid,
                      msg=OM_Gp_NULL_MESSAGE,
                      neighbor=OM_GS_NULL_NEIGHBOR,
                      p_tag=(OMuint *)NULL )

  som_construct_object((classname), (classid), (objid),
                       (object), (obj_osnum), (osnum),
                       (osname), (p_objid), (msg),
                       (neighbor),(p_tag))
#endomdef

/*------------------------------*/
/*   construct and copy macro   */
/*------------------------------*/
/*
**   Given either an instance or an (osnum,objid) pair, construct a copy
**     of the given object in the specified object space.
**
**   Note: if osnum and osname are both specified then osname is used.
*/

#omdef om$construct_and_copy ( objid=NULL_OBJID ^
                               object=(OM_p_OBJECTHDR)NULL,
                               obj_osnum=OM_Gw_current_OS,
                               osnum=OM_Gw_current_OS,
                               osname=(char *)NULL,
                               neighbor=OM_GS_NULL_NEIGHBOR,
                               p_objid,
                               p_tag=(OMuint *)NULL )

   som_construct_and_copy((object), (objid), (obj_osnum), 
                          (osnum), (osname), (neighbor), 
                          (p_objid),(p_tag))
#endomdef

/*----------------*/
/*   send macro   */
/*----------------*/
/*   this macro requires one of the following   1) targetid     (send object)
**                                              2) p_chanselect (channel send)
**
**   the "from" and "to" arguments are used for ordered sends
**
*/

#omdef om$send ( mode=OM_e_wrt_object,
                 msg,
                 senderid=my_id,
                 targetid ^ 
                 p_chanselect,
                 targetos=OM_Gw_current_OS,
                 from=0,
                 to=OM_K_MAXINT,
                 in_line=0 )

#if om$specified (targetid)
#   if om$specified (targetos) && !om$equal(targetos,OM_Gw_current_OS)
        som_send_foreign((mode), (msg), (senderid), (targetid), (targetos),
                                            (NULL_CHANNUM))
#   else
#     if om$equal(in_line,1)
#      if om$equal(targetid,my_id)
#         if om$equal(mode,OM_e_wrt_object)
(
 ((&OM_Gp_CurSpaceMap[my_id])->flags & (OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt))
 ? som_send_object((mode),(msg),(senderid),(targetid),(NULL_CHANNUM))
 : (((OPPp_msg = (msg)),
    ((OPPdefclassid = OPPp_msg->select.DefClassid) != 0 )) /* Root? */
   ? (((OPPdefclassid <= p_ACLD->w_maxclass) &&
       (OPPdefclassid >= p_ACLD->w_baseclass))
      ? ((OPPtndx = p_ACLD->p_transmap[OPPdefclassid - p_ACLD->w_baseclass])
         ? p_ACLD->MsgMap[OPPtndx].MethTbl[OPPp_msg->select.FuncIndex]
            (OPPp_msg, OM_Gw_current_OS, senderid, my_id, &OM_Gp_CurSpaceMap[my_id], 0, p_ACLD )
         : OPP_W_UNKNOWN_MSG
        )
      : OPP_W_UNKNOWN_MSG
     )
   :
     p_ACLD->MsgMap[0].MethTbl[OPPp_msg->select.FuncIndex]
       (OPPp_msg, OM_Gw_current_OS, senderid, my_id, &OM_Gp_CurSpaceMap[my_id], 0, p_ACLD)
  )
)

#         elif om$equal(mode,OM_e_wrt_message)
(
 ((&OM_Gp_CurSpaceMap[my_id])->flags & (OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt))
 ? som_send_object((mode),(msg),(senderid),(targetid),(NULL_CHANNUM))
 : (((OPPp_msg = (msg)),
     (OPPreq_ACLD = OM_GA_active_classes[OPPp_msg->select.ReqClassid]),
    ((OPPdefclassid = OPPp_msg->select.DefClassid) != 0 )) /* Root? */
   ? (((OPPdefclassid <= OPPreq_ACLD->w_maxclass) &&
       (OPPdefclassid >= OPPreq_ACLD->w_baseclass) &&
       (OPPdefclassid <= p_ACLD->w_maxclass) &&
       (OPPdefclassid >= p_ACLD->w_baseclass) &&
       (p_ACLD->p_transmap[OPPdefclassid-p_ACLD->w_baseclass]))
      ? ((OPPtndx = OPPreq_ACLD->p_transmap[OPPdefclassid - 
                                       OPPreq_ACLD->w_baseclass])
         ? OPPreq_ACLD->MsgMap[OPPtndx].MethTbl[OPPp_msg->select.FuncIndex]
            (OPPp_msg, OM_Gw_current_OS, senderid, my_id, &OM_Gp_CurSpaceMap[my_id], 0, p_ACLD )
         : OPP_W_UNKNOWN_MSG
        )
      : OPP_W_UNKNOWN_MSG
     )
   :
     OPPreq_ACLD->MsgMap[0].MethTbl[OPPp_msg->select.FuncIndex]
       (OPPp_msg, OM_Gw_current_OS, senderid, my_id, &OM_Gp_CurSpaceMap[my_id], 0, p_ACLD)
  )
)

#         elif om$equal(mode,OM_e_wrt_parent)
(
 ((&OM_Gp_CurSpaceMap[my_id])->flags & (OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt))
 ? som_send_object((mode),(msg),(senderid),(targetid),(NULL_CHANNUM))
 : (((OPPp_msg = (msg)),
     (OPPreq_ACLD = OM_GA_active_classes
        [*((OM_GA_active_classes[OPPp_msg->select.ReqClassid]->A_ancestor_list+
        (OM_GA_active_classes[OPPp_msg->select.ReqClassid]->w_numparents-1))->p_classid)]),
    ((OPPdefclassid = OPPp_msg->select.DefClassid) != 0 ))  /* Root? */
   ? ((OPPtndx = OPPreq_ACLD->p_transmap[OPPdefclassid - OPPreq_ACLD->w_baseclass])
       ? OPPreq_ACLD->MsgMap[OPPtndx].MethTbl[OPPp_msg->select.FuncIndex]
           (OPPp_msg, OM_Gw_current_OS, senderid, my_id, &OM_Gp_CurSpaceMap[my_id], 0, p_ACLD )
       : OPP_W_UNKNOWN_MSG
      )
   :
     OPPreq_ACLD->MsgMap[0].MethTbl[OPPp_msg->select.FuncIndex]
       (OPPp_msg, OM_Gw_current_OS, senderid, my_id, &OM_Gp_CurSpaceMap[my_id], 0, p_ACLD)
  )
)

#         else
        som_send_object((mode), (msg), (senderid), (targetid), (NULL_CHANNUM))
#         endif
#      else
        som_send_object((mode), (msg), (senderid), (targetid), (NULL_CHANNUM))
#      endif
#     else
        som_send_object((mode), (msg), (senderid), (targetid), (NULL_CHANNUM))
#     endif
#   endif
#else
        som_send_channel((mode), (msg), (targetos), (senderid), (p_chanselect), 
                                            (from), (to))
#endif
#endomdef

/*---------------------------*/
/*     sibling send macro    */
/*---------------------------*/
/*
**     This macro sends a message to all siblings of the senderid, and
**       possibly to the senderid also.  A sibling is defined to be any
**       object on the same "side" of the connection as the senderid.
*/

#omdef om$sibling_send ( mode=OM_e_wrt_object,
                         msg,
                         senderid=my_id,
                         p_chanselect,
                         inclusive=OM_e_inclusive )

   som_sibling_send((mode), (msg), (senderid), (p_chanselect), (inclusive))
#endomdef

/*-------------------------------------*/
/*  object space manipulation macros:  */
/*-------------------------------------*/
/*
**  om$os_name_to_number (osname, p_osnum)
**  om$os_number_to_name (osnum, osname)
**  om$internal_os_name_to_number (osname, p_osnum)
**  om$internal_os_number_to_name (osnum, osname)
**  om$get_os_senddepth (osnum, p_depth)
**
**  All parameters are required...
*/ 

#omdef om$os_name_to_number (osname,p_osnum)
	som_convert_os_name_to_number((osname),(p_osnum))
#endomdef

#omdef om$os_number_to_name (osnum,osname)
	som_convert_os_number_to_name((osnum),(osname))
#endomdef

#omdef om$os_internal_name_to_number (osname,p_osnum)
	som_convert_internal_osname_to_number((osname),(p_osnum))
#endomdef

#omdef om$os_number_to_internal_name (osnum,osname)
	som_convert_number_to_internal_osname((osnum),(osname))
#endomdef



/*-----------------------------*/
/*  Dynamic Memory Operations  */
/*-----------------------------*/

#omdef  om$malloc (structure ^ size)
#if	om$specified (structure)
	(structure *)som_malloc(sizeof(structure))
#else
	(char *)som_malloc((size))
#endif
#endomdef

#omdef  om$calloc (num=1,size ^ structure)
#if	om$specified (structure)
	(structure *)som_calloc((num),sizeof(structure))
#else
	(char *)som_calloc((num),(size))
#endif
#endomdef

#omdef  om$realloc (ptr,size)
	(char *)som_realloc((ptr),(size))
#endomdef

#omdef  om$dealloc (ptr)
	som_dealloc((ptr))
#endomdef


/*--------------------*/
/*  get classid macro */
/*--------------------*/
/*
**  This macro returns the active classid given one of the following:
** 
**    1.  classname
**    2.  objid
**    3.  object     (pointer to object instance)
** 
**  p_classid is the address where the resulting classid is stored.
**  osnum is only used in conjunction with objid to obtain an instance
**  pointer.
*/

#omdef om$get_classid ( osnum=OM_Gw_current_OS,
                        classname=(char *)NULL ^ objid=NULL_OBJID ^ object=(OM_p_OBJECTHDR)NULL,
                        p_classid )

       som_get_classid((osnum),(classname),(objid),(object),(p_classid))

#endomdef
/*----------------------*/
/*  get classname macro */
/*----------------------*/
/*
**  Finds the classname given one of the following:
** 
**    1.  classid
**    2.  objid
**    3.  object     (pointer to object instance)
** 
**  (osnum is only used in conjunction with objid to obtain an instance
**  pointer.)
*/

#omdef om$get_classname ( osnum=OM_Gw_current_OS,
                          classid=OM_K_NOTUSING_CLASSID  ^ 
                          objid=NULL_OBJID ^ 
                          object=(OM_p_OBJECTHDR)NULL,
                          classname )

       som_get_classname((osnum),(classid),(objid),(object),(classname))

#endomdef

/*---------------------------*/
/*  is ancestry valid macro  */
/*---------------------------*/
/*
**  Tests whether or not a super class is in the ancestry of a subclass.
**
**  Requires one of each of the following:
**    
**    1.  sub classid or sub classname
**    2.  super classid or super classname
**
*/

#omdef om$is_ancestry_valid ( subclassid=OM_K_NOTUSING_CLASSID  ^ 
                              subclassname=(char *)NULL,
                              superclassid=OM_K_NOTUSING_CLASSID  ^ 
                              superclassname=(char *)NULL )

    som_is_ancestry_valid((subclassid),(superclassid),
                                             (subclassname),(superclassname))

#endomdef

/*----------------------------*/
/*  get parent classid macro  */
/*----------------------------*/
/*
**  Finds the classid of the parent of a given classid or classname.
**  If the specified class is a union class, the righmost parent's 
**  classid is used. (a status of OM_I_ISAUNION is returned)
**
**  p_parent_classid is the address where the resulting classid is
**  stored.
*/

#omdef om$get_parent_classid (classid=OM_K_NOTUSING_CLASSID ^ classname=(char *)NULL,
                              p_parent_classid)

       som_get_parent_classid((classid),(classname),(p_parent_classid))
#endomdef

/*------------------------------*/
/*  get parent classname macro  */
/*------------------------------*/
/*
**  Finds the classname of the parent of a given classid or classname.
**  If the specified class is a union class, the righmost parent's 
**  classname is used. (a status of OM_I_ISAUNION is returned)
**
*/

#omdef om$get_parent_classname (classid=OM_K_NOTUSING_CLASSID ^ classname=(char *)NULL,
                                parent_classname)

       som_get_parent_classname((classid),(classname),(parent_classname))
#endomdef

/*--------------------------*/
/*  get parent count macro  */
/*--------------------------*/
/*
**  Finds the count of the number of parents of a given classid or 
**  class name.  Parameter count is the address where the count is
**  stored.
*/

#omdef om$get_parent_count (classid=OM_K_NOTUSING_CLASSID ^ classname=(char *)NULL,
                            count)

       som_get_parent_count((classid),(classname),(count))

#endomdef

/*-------------------------*/
/*  get all parents macro  */
/*-------------------------*/
/*
**  Builds a list of parent classids for a given classid or classname.
**  The user must allocate space for the list.  A pointer to the first
**  element (parentlist) and the size of the list are passed in.  Parameter
**  count returns the number of classids put in the parentlist.
*/

#omdef om$get_all_parents (classid=OM_K_NOTUSING_CLASSID ^ classname=(char *)NULL,
                           parentlist,
                           size,
                           count)

       som_get_all_parents((classid),(classname),(parentlist),(size),(count))
#endomdef

/*------------------------------*/
/*  report class version macro  */
/*------------------------------*/
/*
**  Finds the major and minor class version for a given classid or 
**  classname.
**
*/

#omdef om$report_class_version (classid=OM_K_NOTUSING_CLASSID ^ classname=(char *)NULL,
                                major,
                                minor)

       som_report_class_version((classid),(classname),(major),(minor))
#endomdef

/*---------------------------*/
/*  om$report_version macro  */
/*---------------------------*/
/*  
**   This macro will return the major and minor version numbers of 
**     the OM system.
*/

#omdef om$report_version ( major, minor )
   som_report_version((major), (minor))
#endomdef


/*-------------------------*/
/*  om$report_error macro  */
/*-------------------------*/
/*
**	this routine decodes the error code "sts" and reports
**	the corresponding error message to standard output
*/

#omdef om$report_error (sts)

       som_report_error((sts))

#endomdef

/*---------------------------*/
/*  om$set_dynamic_defaults  */
/*---------------------------*/
/*
**	this routine dynamically changes variables to new values
*/

#omdef om$set_dynamic_defaults(paramcnt=0, paramlist=(char **)NULL)

       som_set_dynamic_defaults((paramcnt), (paramlist))

#endomdef

/*-------------------------*/
/*  initialization macro   */
/*-------------------------*/

/* NOTE that this routine will not its index passed into it. */

#omdef om$runtime_init ( paramc=0, param_list=(char **)NULL )

	som_runtime_init((paramc),(param_list))

#endomdef

/*--------------------------*/
/*    om$is_objid_valid     */
/*--------------------------*/
/*
**    Given an OS number and an object id this macro
**     returns OM_S_SUCCESS if the pair is valid
*/

#omdef om$is_objid_valid ( osnum=OM_Gw_current_OS, objid=my_id )

  som_is_objid_valid((osnum), (objid))

#endomdef

/*----------------------------*/
/*      om$get_senddepth      */
/*----------------------------*/
/*
**       gets send depth of (osnum,objid) pair
**       this macro will validate the (osnum,objid) pair
*/

#omdef om$get_senddepth ( osnum=OM_Gw_current_OS,
                          objid=my_id,
                          p_depth )

   som_get_senddepth((osnum), (objid), (p_depth))

#endomdef

/*----------------------------*/
/*      om$os_senddepth       */
/*----------------------------*/
/*
**       gets send depth of an Object Space
**       this macro will validate the given osnum
*/

#omdef om$os_senddepth ( osnum=OM_Gw_current_OS,
                         p_depth )

	som_get_os_senddepth((osnum),(p_depth))
#endomdef

/*---------------------------*/
/*  om$make_message macro    */
/*---------------------------*/
/*
**   This macro builds a message structure - you must supply the parts
*/

#omdef om$make_message ( classname=(char *)NULL ^ classid=OM_K_NOTUSING_CLASSID,
                         methodname,
                         size=0,
                         p_arglist=(void *)NULL,
                         p_msg )
   som_make_message((classname), (classid), (methodname), 
                                       (size), (p_arglist), (p_msg))
#endomdef

/*----------------------------*/
/*      om$make_neighbor      */
/*----------------------------*/
/*
**       This macro fills in a neighbor structure 
**	 given the objid & osnum with which to cluster 
*/

#omdef om$make_neighbor ( osnum=OM_Gw_current_OS,
                          objid=NULL_OBJID, p_neighbor )

	som_make_neighbor((osnum),(objid),(p_neighbor))
#endomdef


/* -------------------*/
/* change os name     */
/* -------------------*/
/* 
    Macro for changing the name of an object space.
*/

#omdef  om$change_os_name( osnum=OM_Gw_current_OS,
			   curr_osname="",
			   new_osname,
			   overwrite = OM_e_no_ovrwrt)

#if	om$specified (osnum) && om$specified(curr_osname)
#omerror "Cannot specify both osnum and curr_osname. Select one."
#elif   om$specified (curr_osname)
	som_change_os_name_by_name((curr_osname),(new_osname),(overwrite))
#else
	som_change_os_name((osnum),(new_osname),(overwrite))
#endif

#endomdef

/*---------------------------------*/
/*      om$vla_set_dimension       */
/*---------------------------------*/
/*
**      Changes the size of a variable length array.  An application
**      should take all the defaults and only specify the name of the
**      array (varray) and the number of elements (size) to which the
**      vla will be dimensioned. (The other parameters are used for
**      specialized calls within the OM system itself)
**      The move_data parameter is used to determine whether or not to
**      move the old data to the newly dimensioned arrary.
*/
#omdef om$vla_set_dimension(varray ^
                            p_vladescr ^
			    pp_data=(int **)NULL,
                            size,
		            p_count=(int *)NULL,
			    osnum=OM_Gw_current_OS,
			    objid=my_id,
                            p_cld=p_ACLD,
                            move_data=1)
#if om$specified (p_vladescr)
    som_vla_set_dimension(&((p_vladescr)->i_offset),&((p_vladescr)->i_count),(size),(osnum),(objid),(p_cld),(move_data))
#elif om$specified(pp_data) && om$specified(p_count)
    som_vla_set_dimension((pp_data),(p_count),(size),(osnum),(objid),(p_cld),(move_data))
#else
    SOM_SET_DIMENSION(varray,size,osnum,objid,p_cld,move_data)
#endif
#endomdef

/*----------------------------*/
/*      om$dimension_of       */
/*----------------------------*/
/*
**      Results in the number of elements currently allocated for the
**      specified array.
*/
#omdef om$dimension_of(varray)
    SOM_DIMENSION_OF(varray)
#endomdef


/*--------------------------*/
/*   om$osnum_to_oso_objid  */
/*--------------------------*/
/*
/* from an os number, get the oid of the oso. 
*/
#omdef om$osnum_to_oso_objid(osnum=OM_Gw_current_OS,p_objid)
	som_osnum_to_oso_objid((osnum),(p_objid))
#endomdef	

/*---------------------------*/
/*   om$enough_disk_space    */
/*---------------------------*/
/* given an osnum or osname, find out if there is enough disk space
/* to hold the os in the file structure which it would be written to.
*/
#omdef om$enough_disk_space(osnum^osname^filename,filesize=0)
#if om$specified(osnum)
	som_enough_disk_space((osnum),(char *)NULL,(char *)NULL,0)
#endif
#if om$specified(osname)
	som_enough_disk_space(0,(osname),(char *)NULL,0)
#endif
#if om$specified(filename)
	som_enough_disk_space(0,(char *)NULL,filename,filesize)
#endif
#endomdef

/*---------------------------*/
/*   om$dynamic_class        */
/*---------------------------*/
#omdef om$dynamic_class(p_parent_class,num_parents,maj_version,min_version,p_dynamic_class)
	som_dynamic_class((p_parent_class),(num_parents),(maj_version),(min_version),(p_dynamic_class))
#endomdef

/*---------------------------------*/
/*   om$enable_tagging             */
/*---------------------------------*/
/*
**   This primitive is called to enable/disable tagging of objects.
**   The primitive returns the previous state of tagging.
**   (TRUE = enabled, FALSE = disabled.)
*/

#omdef om$enable_tagging (flag)
(OM_Gf_tagging_enabled == (OMuint)(flag) ? 
	OM_Gf_tagging_enabled :
	(OM_Gf_tagging_enabled = (OMuint)(flag), !(flag)))
#endomdef

/*------------------------------*/
/*   om$enable_tag_connects     */
/*------------------------------*/
/*
**   This primitive is called to enable/disable tagged connections.
**   The primitive returns the previous state of tagged connections.
**   (TRUE = enabled, FALSE = disabled.)  Formerly om$set_tags.
*/

#omdef om$enable_tag_connects (flag)
(OM_Gf_tagged_connects == (OMuint)(flag) ?
	OM_Gf_tagged_connects :
	(OM_Gf_tagged_connects = (OMuint)(flag), !(flag)))
#endomdef

/*--------------------------------------------*/
/*   Message Intercept Primitives             */
/*	om$set_intercept		      */
/*	om$get_intercept		      */
/*	om$cancel_intercept		      */
/*      om$disable_intercept                  */
/*--------------------------------------------*/

#omdef om$set_intercept ( osnum = OM_Gw_current_OS,
                          objid,
			  target_osnum = OM_Gw_current_OS,
			  target_objid )

     som_set_intercept((osnum),(objid),(target_osnum),(target_objid))
#endomdef

#omdef om$get_intercept ( osnum = OM_Gw_current_OS,
                          objid,
			  p_target_osnum,
			  p_target_objid )

     som_get_intercept((osnum),(objid),(p_target_osnum),(p_target_objid))
#endomdef

#omdef om$cancel_intercept ( osnum = OM_Gw_current_OS, objid )

     som_cancel_intercept((osnum),(objid))
#endomdef

#omdef om$disable_intercept ( osnum = OM_Gw_current_OS, objid )

     som_disable_intercept((osnum),(objid))
#endomdef

/*-------------------------*/
/*   om$set_tag_os         */
/*-------------------------*/
/*
**   This primitive establishes the specified object space as the one
**   which contains tagged objects.  Whenever a connection is made between
**   a tagged object in this OS and one in a different filed OS (and tagged
**   connects are enabled), the connection will be tagged.
*/

#omdef om$set_tag_os ( p_prev_osnum, osnum )

   som_set_tag_os((p_prev_osnum),(osnum))

#endomdef

/*---------------------------*/
/*   om$objid_to_tag         */
/*---------------------------*/
/*
**   This primitive returns an object's tag.  
**
**   osnum, objid:  identify the tagged object.
**   p_tag:         a pointer to the returned tag.
**   p_version:     a pointer to the returned version. (if not NULL).
**
*/

#omdef om$objid_to_tag ( osnum = OM_Gw_current_OS,
                         objid = my_id,
                         p_tag,
                         p_version = (OMuword *)NULL )

   som_objid_to_tag((osnum), (objid),  (p_tag), (p_version),
                    (OMuint *)NULL,(void *)NULL,(OMuint *)NULL,(OMuword **)NULL)

#endomdef


/*---------------------------*/
/*   om$tag_to_objid         */
/*---------------------------*/
/*
**   Given an object's tag and object space number, this primitive 
**   returns the object id of the tagged object.
**
**   osnum:        Object space number containing the tagged object.
**   tag:          The object's tag.
**   p_objid:      Used to return the object id.
**   p_version:    Used to return the version. (if not NULL).
*/

#omdef om$tag_to_objid ( osnum = OM_Gw_current_OS,
                         tag,
                         p_objid,
                         p_version = (OMuword *)NULL )

   som_tag_to_objid((osnum),(tag),(p_objid),(p_version))

#endomdef

/*----------------------*/
/*   om$add_tag         */
/*----------------------*/
/*
**   This primitive is called to add a tag to an object after it has 
**   been constructed.  The object to be tagged is identified by osnum
**   and objid.  The assigned tag is returned via p_tag.  (p_object is
**   for internal use only.  It allows for increased efficiency.)
*/

#omdef om$add_tag ( osnum = OM_Gw_current_OS,
                    objid = my_id,
                    object = (OM_p_OBJECTHDR)NULL,
                    p_tag )

   som_tag_object((osnum),(object),(objid),(p_tag))

#endomdef


/*----------------------*/
/*   om$remove_tag      */
/*----------------------*/
/*
**   This primitive is called to remove a tag from an object.  The object 
**   is identified by osnum and objid.  (p_object is for internal use only.  
**   It allows for increased efficiency.)
*/

#omdef om$remove_tag ( osnum = OM_Gw_current_OS,
                       p_object = (OM_p_OBJECTHDR)NULL,
                       objid = my_id )

   som_remove_object_tag((osnum),(p_object),(objid))

#endomdef


/*----------------------------*/
/*   om$change_tag_version    */
/*----------------------------*/
/*
**   This primitive is called to change the version stored with a tag
**   record.  When tagged connections are re-established, the version
**   stored with the tag record is compared to the version stored in the
**   connection record.  Records with mismatched versions are flagged.
*/

#omdef om$change_tag_version ( osnum = OM_Gw_current_OS,
                               objid = my_id,
                               version = (OMuword)NULL )
#if om$specified (version)

   som_change_tag_version((osnum),(objid),(version),(NULL))

#else

   som_change_tag_version((osnum),(objid),(version),(1))
#endif
#endomdef

/*------------------*/
/*   om$move_tag    */
/*------------------*/
/*
**   This primitive is used to transfer a tag to a previously untagged
**   object.  The new object must retain those channel(s) from the old
**   object that were used in tagged connections.
*/

#omdef om$move_tag ( osnum = OM_Gw_current_OS,
                     old_objid = my_id,
                     new_objid )

   som_move_tag((osnum),(old_objid),(new_objid))

#endomdef

/*-------------------------*/
/*  om$broken_connects     */
/*-------------------------*/
/*
**      This primitive will fill in a user allocated array of type 
**   OM_S_TAG_CON_INFO which will represent the tagged connections
**   that were not resolved at Object Space construct time.  To
**   determine the size of the array needed to hold the info,  set
**   the size argument to zero and the count will be returned.
**   A second call to this primitive with a non-zero size will
**   return the requested data.
*/

/*  flag definitions for tag connect records  */

#define   OM_TCf_version_mismatch        1
#define   OM_TCf_unresolved_connection   2

#omdef om$broken_connects ( osnum = OM_Gw_current_OS,
                            tagged_osnum,
                            p_count,
                            size = 0,
                            p_tag_con_info = (void *)NULL )

  som_flagged_tag_connects((osnum), (tagged_osnum), (p_count), (size), 
                             (p_tag_con_info), OM_TCf_unresolved_connection)

#endomdef

/*-----------------------------*/
/*  om$mismatched_connections  */
/*-----------------------------*/
/*
**      This primitive will fill in a user allocated array of type 
**   OM_S_TAG_CON_INFO which will represent the tagged connections
**   that had version mismatches at Object Space construct time.  To
**   determine the size of the array needed to hold the info,  set
**   the size argument to zero and the count will be returned.
**   A second call to this primitive with a non-zero size will
**   return the requested data.
*/

#omdef om$mismatched_connections ( osnum = OM_Gw_current_OS,
                                   tagged_osnum,
                                   p_count,
                                   size = 0,
                                   p_tag_con_info = (void *)NULL )

  som_flagged_tag_connects((osnum), (tagged_osnum), (p_count), (size), 
                                (p_tag_con_info), OM_TCf_version_mismatch)

#endomdef

/*-------------------------*/
/*  om$test_connection     */
/*-------------------------*/
/*
**      This primitive will return the version counters from the tag record
**   and the tag connect record for a single connection.  There are enough
**   input arguments to represent a unique connection.  It may also be
**   used to force the version counter in the tag connect record to be
**   the same as the version counter in the tag record.
*/

#omdef om$test_connection ( osnum = OM_Gw_current_OS,
                            objid = my_id,
                            p_chanselect,
                            tag_osnum,
                            tag_objid,
                            p_tag_chanselect,
                            p_tag_version,
                            p_tag_connect_version,
                            force_flag = 1 )

  som_test_connection((osnum), (objid), (p_chanselect), (tag_osnum),
                                  (tag_objid), (p_tag_chanselect), 
                                  (p_tag_connect_version), (p_tag_version),
                                  (force_flag))

#endomdef

/*-------------------------*/
/*  om$change_class        */
/*-------------------------*/
/*
**      This primitive takes an object and either promotes or demotes
**  that object to an object of class classname.  The object id remains
**  unchanged and the instance data of the component classes that
**  are common to the old and new classes will be copied.  Other
**  instance data will be lost. The object send depth must be zero
**  (object not in use) in order for this primitive to change the class
**  of the object.  The sd_override argument is only to be used when this
**  is not possible and the user is aware of the side effects that may
**  arise by using the override.  OM takes no responsiblity for runtime
**  mishaps when a user uses the sd_override argument.
*/

#omdef om$change_class(osnum=OM_Gw_current_OS,objid,classname,sd_override=0)
 
  som_change_class((osnum),(objid),(classname),(sd_override))

#endomdef

/* dynamic loader primitive. accepts a required file argument and loads
/* methods from that file 
*/
#omdef om$dynamic_load(filename)

	som_dynamic_load((filename))

#endomdef

/*-------------------------*/
/*  om$get_message_name        */
/*-------------------------*/
/*
**    This primitive takes either classname or classid and a method index, 
**  then get the message name associated with that method.
*/

#omdef om$get_message_name(classname=(char *)NULL ^ classid=NULL_OBJID, 
                           method_index, msg_name)

  som_get_message_name((classname), (classid), (method_index), (msg_name))

#endomdef

/*================================================*/
/* 	Dynamic Shared Memory Operations          */
/*================================================*/

#omdef	om$sm_malloc (structure ^ size)
#if	om$specified (structure)
	(structure *)som_sm_malloc(sizeof(structure))
#else
	(char *)som_sm_malloc((size))
#endif
#endomdef

#omdef	om$sm_calloc (num=1,size ^ structure)
#if	om$specified (structure)
	(structure *)som_sm_calloc((num),sizeof(structure))
#else
	(char *)som_sm_calloc((num),(size))
#endif
#endomdef

#omdef	om$sm_realloc (ptr,size)
	(char *)som_sm_realloc((ptr),(size))
#endomdef

#omdef	om$sm_dealloc (ptr)
	som_sm_dealloc((ptr))
#endomdef

#omdef om$getClusterFromObject ( pClustNum=(OMuword *)NULL, objid=my_id, /* saw001 */
                        osnum=OM_Gw_current_OS ) 

   som_getClusterFromObject( (pClustNum), (objid), (osnum) )
            	
#endomdef

/*------------------*/
/*  om$inquire_os   */
/*------------------*/
/*
**      This primitive will return information about an object space.
**   The information returned is defined by the struct OM_S_DUPINTOS
**   defined in OMminimum.h.  A pointer to the structure will be 
**   returned by this primitive via the argument pp_buf.  The information
**   in the structure MUST NOT be modified.  Treat it as read only!
**
*/

#omdef om$inquire_os ( osnum = OM_Gw_current_OS,
                       pp_buf )

  som_inquire_os((osnum), (pp_buf))

#endomdef

/*-------------------*/
/*  om$set_os_type   */
/*-------------------*/
/*
**   This primitive is used to set/get user definable Object Space types.
**   An example of the type of the object space is "cell file".  The integer
**   pointed to by p_num will be bitwise ORed with any existing value in
**   the "set" operation (flag == 1).
**
**   Another action of this primitive is to get (flag == 0) the
**   current value of the OS type for a given object space.  In this case
**   the entire value of the integer will be returned and it will
**   be up to the user to bitwise AND to check bit settings.
**
**   This macro can also be used to "unset" a given file type when
**   (flag == 2).  The interface in this case is exactly like the set 
**   operation except that the existing value will be ANDed with the
**   one's complement of the integer pointer to by p_num.
**
**   The object space type is originally read from the file header
**   by construct_os, and is stored in the file header by save.
**
**   The flag values are::     0 - get the OS type as unsigned int
**                             1 - set the OS type  (default)
**                             2 - unset the OS type
**                             
*/

#omdef om$set_os_type ( osnum = OM_Gw_current_OS,
			p_num,
			flag = 1 )

  som_set_os_type((osnum), (p_num), (flag))

#endomdef

/*-------------------*/
/*  om$get_mem_info  */
/*-------------------*/
/*
**    Get values of certain memory use variables.  All values are
**    return in bytes, not blocks or pages.
**
**    p_avail_swap   int *, availsmem (available swap memory)
**    p_total_swap   int *, sum of size of swap devices
**    p_phys_mem     int *, size of physical memory
**    p_avail_om     int *, memory available within OM memory regions
**    p_total_om     int *, sum of sizes of OM memory regions
**    p_total_free   int *, availsmem + avail_om
*/

#omdef om$get_mem_info (p_avail_swap = (int *) NULL,
                        p_total_swap = (int *) NULL,
                        p_phys_mem = (int *) NULL,
                        p_avail_om = (int *) NULL,
                        p_total_om = (int *) NULL,
                        p_total_free = (int *) NULL)

   som_get_mem_info( (p_avail_swap), (p_total_swap), (p_phys_mem),
                     (p_avail_om), (p_total_om), (p_total_free))

#endomdef

#endif    /****** end of OMprimitives.h ****** add above this line ******/
