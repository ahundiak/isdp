#ifndef vdcollmacro_include
#define vdcollmacro_include

/* I/VDS
 *
 * File:        ~VDS/include/vdcollmacros.h
 *
 * Description: This file contains macros for getting info about
 *		collectors
 *
 * History:
 *      11/28/94        Raju MSB
 *
 */

/*============================================================================*/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern long   VDgetAttListFromColl __((
 long			*msg,
 char			*CollName,
 int			*nb_rows,
 char			**AttrNameList,
 char			**AttrTextList,
 int			ListSize
));

extern long   VDgetPfxFromObjid __((
 long			*msg,
 struct GRobj_env	*obj_env,
 char			*pfx_def,
 char			*pfx
));

extern long   VDmatchObjAndPfxdef __((
 long			*msg,
 struct GRobj_env	*obj_env,
 char			*pfx_def,
 IGRboolean		*match
));

#if defined(__cplusplus)
}
#endif

/*============================================================================*/
/* -----------------------------------------------------------------------------

Macro
  vd$get_list_from_coll();

Abstract
  This macro gives list of attribute names and thier definitions from
  collector.

Arguments
  IGRlong               *msg		 O    return status
  char			*coll_name	 I    name of collector
					      see vdcolldef.h
  int			*nb_rows	 O    number of attributes in collector

  char			**attr_name_list O    list attribute names
					      = NULL, if not needed.
  char			**attr_text_list O    list of attribute definitions
					      = NULL, if not needed.
  int			list_size	 I    size of attr_name_list and 
					      attr_text_list
					      = 0, when they are NULL
Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

  EXAMPLE
  long			msg;
  int			nb_rows;
  char			**AttrNameList = NULL,
			**AttrTextList = NULL;

  sts = vd$get_list_from_coll(  msg       =  &msg,
				coll_name =  VD_QRYDEF_DIR_NAME,
				nb_rows   =  &nb_rows   );

  if ( !VDmalloc_str_list ( &AttrNameList, nb_rows, ATTR_NAME ) )
  {
     /* no memory * /
  };
  if ( !VDmalloc_str_list ( &AttrTextList, nb_rows, VD_ATTR_LEN ) )
  {
     /* no memory * /
  };

  sts = vd$get_list_from_coll(  msg		= &msg,
				coll_name	= VD_QRYDEF_DIR_NAME,
				nb_rows		= &nb_rows,
				attr_name_list	= AttrNameList,
				attr_text_list	= AttrTextList,
				list_size	= nb_rows   );

  /* when strings no longer needed * /
  VDfree_str_list ( AttrNameList, nb_rows );
  VDfree_str_list ( AttrTextList, nb_rows );

  ------------------------------------------------------------------------- */

#omdef  vd$get_list_from_coll(  msg,
				coll_name,
				nb_rows,
				attr_name_list	= NULL,
				attr_text_list	= NULL,
				list_size	= 0     )

	VDgetAttListFromColl( (msg), (coll_name), (nb_rows),
			      (attr_name_list), (attr_text_list), (list_size) )

#endomdef

/* -----------------------------------------------------------------------------

Macro
  vd$get_def_and_pfx();

Abstract
  This macro gets definition and prefix given an object id.

Arguments
  IGRlong               *msg		 O    return status
  struct GRobj_env	*obj_env	 I    object whose prefix is needed
  char			*def		 O    prefix definition for the object.
					      max size = ATTR_NAME
						( see ACrg_collect.h )
  char			*pfx		 O    prefix for the object
					      max size = ATTR_TXT
						( see ACrg_collect.h )

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

  EXAMPLE
  long			msg;
  struct GRobj_env	obj_env;
  char			def[ATTR_NAME],
			pfx[ATTR_TXT];

  sts = vd$get_def_and_pfx(	msg      =  &msg,
				obj_env  =  &obj_def,
				pfx_def  =  def,
				pfx	 =  pfx        );


  ------------------------------------------------------------------------- */

#omdef  vd$get_def_and_pfx(	msg,
				obj_env,
				pfx_def,
				pfx 		)

	VDgetPfxFromObjid( (msg), (obj_env), (pfx_def), (pfx) )

#endomdef

/* -----------------------------------------------------------------------------

Macro
  vd$match_obj_and_def();

Abstract
  This macro finds if a given object matches with a given definition.

Arguments
  IGRlong               *msg		 O    return status
  struct GRobj_env	*obj_env	 I    object to be matched
  char			*def		 I    definition to be matched with.
  IGRboolean		*match		 O    = TRUE, matches
					      = FALSE, if no match

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

  EXAMPLE
  long			msg;
  struct GRobj_env	obj_env;
  char			def[ATTR_NAME];
  IGRboolean		match;


  sts = vd$match_obj_and_def(	msg      =  &msg,
				obj_env  =  &obj_def,
				pfx_def  =  def,
				match	 =  &match        );


  ------------------------------------------------------------------------- */

#omdef  vd$match_obj_and_def(	msg,
				obj_env,
				pfx_def,
				match 		)

	VDmatchObjAndPfxdef( (msg), (obj_env), (pfx_def), (match) )

#endomdef

#endif

