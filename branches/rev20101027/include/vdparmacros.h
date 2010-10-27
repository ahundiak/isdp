/* $Id: vdparmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* I/VDS
 *
 * File:        $VDS/include/vdparmacros.h
 *
 * Description:
 *      This include file provides functionalities
 *      to review specific parameters of a component,
 *      to get the list of all parameters of a component,
 *      to get the list of user attributes of a 
 *      component, and to modify the user attributes.
 *
 *
 * Dependencies:
 *      ACattrib.h
 *
 * History:
 *      08/15/94        R. Manem        Creation 
 *	08/21/94	A. Zuurhout	Add query_on_attr.
 *	10/11/94	y. Zhu	        Add qry_check_macro.
 *	10/28/94	y. Zhu	        Add qry_give_list.
 *	10/28/94	y. Zhu	        Add qry_name_to_objid.
 *	11/1/94	  	y. Zhu	        Add qry_process.
 *	11/2/94	  	y. Zhu	        Add qry_get_mul_objects.
 *	11/2/94	  	y. Zhu	        Add qry_chk_one_object.
 *	15/02/95	R. Manem	Added vd$review_params and
 *					vd$get_params
 *	02/2/95	  	y. Zhu	        Add qry_get_macro_names.
 *	10-97		KDD		vd$getSysAttrib2, vd$getUsrAttrib2
 *      12/18/97        y. zhu          Added vd$db_rev_params and
 *                                      vd$db_get_params, vd$db_get_parameters
 *
 */

/* ---------------------------------------
 * include support files.
 */

#ifndef igrtypedef_include
#     include "igrtypedef.h"
#endif

#ifndef igetypedef_include
#     include "igetypedef.h"
#endif

#ifndef gr_include
#     include "gr.h"
#endif

#ifndef growner_include
#     include "growner.h"
#endif

#ifndef	msdef_include
#	include	"msdef.h"
#endif

#ifndef	acrg_collect_include
#	include	"ACrg_collect.h"
#endif

#ifndef	vd_pardef_include
#	include	"vdpardef.h"
#endif

/* ----------------------------------------
 * Protoypes
 */

#ifndef vd_parmacros_include
#       define vd_parmacros_include

/*
 * Attribute type VD_ATTRIB_DELETE is used to indicate to the 
 * vd$modUsrAttributes macro that the user attribute is to be deleted.
 */

#define  VD_ATTRIB_DELETE   0
#define  VDDYSTART          4
#define  VDATSTART          8
#define  VDATPIECE          0
#define  VDATSTAGE          1

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif


extern IGRint  VDReviewParameters __((  long             *pMsg,
                                        struct GRid      *pComponent,
                                        int               NbParams,
                                        struct ACrg_coll *pList,
                                        struct GRmd_env  *pMdEnv ));

extern IGRint  VDreviewParams __((  long             *pMsg,
                                    struct GRid      *pComponent,
                                    int               NbParams,
                                    struct ACrg_coll *pList,
                                    struct GRmd_env  *pMdEnv ));

extern IGRint VDget_parameters __((  IGRlong          *sts,
                                     struct GRid      *object_id,
                                     IGRchar          *object_name,
                                     struct GRmd_env  *md_env,
                                     struct ACrg_coll *plist,
                                     IGRint           size,
                                     IGRint           *count,
                                     IGRboolean       first_time ));

extern IGRint VDgetParams __((  IGRlong          *sts,
                                struct GRid      *object,
                                struct GRmd_env  *md_env,
                                IGRint           *count,
                                struct ACrg_coll **plist ));

extern IGRint  VDDbreviewParams __((  long             *sts,
                                      struct GRid      *object,
                                      struct GRmd_env  *md_env,
                                      int              count,
                                    IGRchar          *table,
                                      struct ACrg_coll *plist));

extern IGRint VDDbget_parameters __((IGRlong          *sts,
                                     struct GRid      *object,
                                     IGRchar          *table,
                                     struct GRmd_env  *md_env,
                                     struct ACrg_coll *plist,
                                     IGRint           size,
                                     IGRint           *count));
extern IGRint VDDbgetParams __((IGRlong          *sts,
                                struct GRid      *object,
                              IGRchar          *table,
                                struct GRmd_env  *md_env,
                                IGRint           *count,
                                struct ACrg_coll **plist ));

extern IGRint VDSgetAttributes2 __(( IGRint                *NumUsrAttr,
                                     IGRint                *NumSysAttr,
                                     IGRint                *NumMisAttr,
                                     struct ACrg_coll      **UsrAttr,
                                     struct ACrg_coll      **SysAttr,
                                     struct ACrg_coll      **MisAttr,
                                     struct GRid           *UsrParId,
                                     struct GRid           *SysParId,
                                     struct GRid           *MisParId,
                                     struct GRid           object )); 

extern IGRint VDSgetUsrAttr2 __(( IGRint           *NumUsrAttr,
                                  struct ACrg_coll **UsrAttr,
				  struct GRid	   *UsrParId,
				  struct GRid      object ));

extern IGRint VDSgetSysAttr2 __(( IGRint           *NumSysAttr,
	                          struct ACrg_coll **SysAttr,
	                          struct GRid      *SysParId,
	                          struct GRid      object)); 

extern IGRlong VDgetSysAttrs __(( IGRlong          *sts,
                                  struct GRid      object,
                                  struct GRmd_env  *md_env,
                                  IGRint           *nbAttrs,
                                  struct ACrg_coll **att ));

extern IGRlong VDgetUsrAttrs __(( IGRlong          *sts,
                                  struct GRid      object,
                                  struct GRmd_env  *md_env,
                                  IGRint           *nbAttrs,
                                  struct ACrg_coll **att ));

extern IGRlong VDmodUsrAttrs __(( IGRlong          *sts,
                                  struct GRid      object,
                                  struct GRmd_env  *md_env,
                                  IGRint           nbAttrs,
                                  struct ACrg_coll *att ));

extern	IGRint VDquery_on_attr __((IGRlong		*msg,
				  struct GRobj_env	*object,
				  IGRchar		*operant1,
				  IGRint		operator,
				  IGRchar		*operant2));

extern	IGRint VDqry_check_macro __((IGRlong		*msg,
				  IGRchar		*name));

extern	IGRint VDqry_give_list __((IGRlong		*sts,
				   IGRint               list_size,  
		                   struct GRid          *list,                
		                   struct GRmd_env      *md_env_list,          
				   IGRint               *count,            
		                   IGRint               ref_file));         

extern	IGRint VDqry_name_to_objid __((IGRlong		*sts,
				   IGRchar              *name,  
		                   struct GRid          *objid));                
extern	IGRint VDqry_process __((  IGRlong		*sts,
				   struct GRobj_env     *objects, 
                                   IGRint		nb_objects,
				   struct GRid          *queries, 
                                   IGRint		nb_queries,
				   struct GRobj_env     **found, 
                                   IGRint		*nb_found));
 
extern	IGRint VDqry_get_mul_objects __((  IGRlong	*sts,
				   struct GRobj_env    *objects, 
                                   IGRint		nb_objects,
				   IGRchar              *query, 
				   struct GRobj_env     *found, 
                                   IGRint		*nb_found));

extern	IGRint VDqry_chk_one_object __((  IGRlong	*sts,
				   struct GRid          *objects, 
                                   IGRint		nb_objects,
				   IGRchar              *query, 
				   struct GRid          *found)); 

extern  IGRint VDqry_get_macro_names __((     IGRlong       *sts,
                                              IGRchar       **macronames,
                                              IGRint        *count));  
#if defined(__cplusplus)
}
#endif

/*+Me
  External Macro vd$review_parameters

  Abstract
      This macro returns, from the object defined by pComponent, the types
      and values of the parameters specified in pList filled in before 
      calling.

  Arguments
      long                *pMsg           (O)    returns MSFAIL if any
                                                 parameter fails ( in this case,
                                                 its returned type is 
                                                 AC_ATTRIB_TYPE_NOT_DEF );
      struct GRid         *pComponent     (I)    component's object id.
      int                 NbParams        (I)    number of names initialized
                                                 in the List array.
      struct ACrg_coll    *pList          (I/O)  pointer to the List array.
      struct GRmd_env     *pMdEnv         (I)    module environment.

  Status/Return Code
      OM_S_SUCCESS    : if success

-Me*/
  

#omdef vd$review_parameters (   pMsg,
                                pComponent,
                                NbParams,
                                pList,
                                pMdEnv )

VDReviewParameters ( (pMsg), (pComponent), (NbParams), (pList), (pMdEnv))

#endomdef

/*+Me
  External Macro vd$review_params

  Abstract
      This macro returns, from the object defined by pComponent, the types
      and values of the parameters specified in pList filled in before
      calling.  It is similar to the vd$review_parameters macro.  Has been
      introduced after introducing methods at VDSroot level.

  Arguments
      long                *pMsg           (O)    returns MSFAIL if any
                                                 parameter fails ( in this case,
                                                 its returned type is
                                                 AC_ATTRIB_TYPE_NOT_DEF );
      struct GRid         *pComponent     (I)    component's object id.
      int                 NbParams        (I)    number of names initialized
                                                 in the List array.
      struct ACrg_coll    *pList          (I/O)  pointer to the List array.
      struct GRmd_env     *pMdEnv         (I)    module environment.

  Status/Return Code
      OM_S_SUCCESS    : if success


-Me*/


#omdef vd$review_params (   pMsg,
                            pComponent,
                            NbParams,
                            pList,
                            pMdEnv )

VDreviewParams ( (pMsg), (pComponent), (NbParams), (pList), (pMdEnv))

#endomdef


/*+Me
  External Macro vd$get_parameters

  Abstract
      The macro is used to get all the parameters and their values   
      of any given object.  Normally the macro would be called       
      twice; once to get the number of parameters, and the second         
      time, to get the list of parameters and their values.                  

  Arguments
      IGRlong            *sts             (O)    return code
      struct GRid        *object_id       (I)    id of the object
      struct GRmd_env    *md_env          (I)    module environment
      struct ACrg_coll   *plist           (O)    pointer to the list array
      IGRint             size             (I)    size of the array plist
      IGRint             *count           (O)    number of parameters returned 
                                                 if plist is not NULL, else 
                                                 total no of parameters for 
                                                 the object

  Examples

       vd$get_parameters( sts = &sts,
                          object = &obj,
                          md_env = &mod_env,
                          count = &count )

       list = (struct ACrg_coll *) malloc( sizeof( struct ACrg_coll ) *
                                                   count );

       vd$get_parameters( sts = &sts,
                          object = &obj,
                          md_env = &mod_env,
                          plist  = list,
                          size = count,
                          count = &count )

  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : some error

-Me*/

#omdef vd$get_parameters(   sts,
                            object,
                            md_env,
                            plist = NULL,
                            size = 0,
                            count )
     VDget_parameters( (sts), (object), "", (md_env), 
			(plist), (size), (count), TRUE );
#endomdef


/*+Me
  External Macro vd$get_params

  Abstract
      The macro is used to get all the parameters and their values
      of any given object.
      Simply sends message VDgetParameters to the object.  Introduced after
      introducing messages at VDSroot.

  Arguments
      IGRlong            *sts             (O)    return code
      struct GRid        *object          (I)    id of the object
      struct GRmd_env    *md_env          (I)    module environment
      IGRint             *count           (O)    number of parameters
      struct ACrg_coll   **plist          (O)    pointer to the list array

  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : some error

  Remarks
      Memory for the output list of parameters will be allocated by the macro
      and has to be freed by the caller.

-Me*/

#omdef vd$get_params(   sts,
                        object,
                        md_env,
                        count,
                        plist )
     VDgetParams( (sts), (object), (md_env), (count), (plist) );
#endomdef

/*------------------------------
# General get attributes macro API. 
*       As defined by the first, second and third ACrg_collect parent. 
*
*       NOT SUITABLE FOR ALL DESIGNS/IMPLEMENTATIONS,
*       that involve DB, Macro, instance, etc. "system"/"user" like parameters.
* 12-97 KDD
------------------------------*/
#omdef vd$getAttrib2    (   object,
                            NumUsrAttr  = NULL,
                            NumSysAttr  = NULL,
                            NumMisAttr  = NULL,
                            UsrParId    = NULL, 
                            SysParId    = NULL, 
                            MisParId    = NULL,
                            UsrAttr     = NULL,
                            SysAttr     = NULL,
                            MisAttr     = NULL)

        VDSgetAttributes2( (NumUsrAttr), (NumSysAttr), (NumMisAttr),
			   (UsrAttr),    (SysAttr),    (MisAttr),
			   (UsrParId),   (SysParId),   (MisParId), (object) );
#endomdef


/*------------------------------
# This macro gets the user attributes of an object.
*       As defined by the second ACrg_collect parent. 
*
*       NOT SUITABLE FOR ALL DESIGNS/IMPLEMENTATIONS,
*	that involve DB, Macro, instance, etc. "user" like parameters.
* 10-97 KDD
*
*----------------------------
* Parameters:
*
* O: IGRint           *NumUsrAttr - pointer to number of attributes in the
*                                       User Collection.  Can be NULL.
*
* O: struct ACrg_coll **UsrAttr   - pointer to list of User attribues.
*                                       Can be NULL.
*
* O: struct GRid      *UsrParId   - pointer the object ID of the collection.
*                                       Can be NULL.
*
* I: struct GRid      object      - Target ObjectID.
*
*----------------------------
* NOTE:
*
* User attributes       = Dynamic attributes + Additional Attributes.
*
* Dynamic attributes    - user can change value only.
* Additional Attributes - user can change/remove attribute name + type + value.
------------------------------*/
#omdef vd$getUsrAttrib2(    object,
                            NumUsrAttr 	= NULL,
                            UsrAttr    	= NULL,
			    UsrParId	= NULL )

#if (!om$specified (UsrParId) && !om$specified (UsrAttr)) 
#omerror "Must specify UsrParId or UsrAttr."
#else
	VDSgetUsrAttr2 ( (NumUsrAttr), (UsrAttr), (UsrParId), (object));
#endif


#endomdef


/*------------------------------------------------------------------------------
* This macro gets system attributes of an object.
* It returns attributes object ID and/or list.
*
*       As defined by the first ACrg_collect parent. 
*
*       NOT SUITABLE FOR ALL DESIGNS/IMPLEMENTATIONS,
*       that involve DB, Macro, instance, etc. "system" like parameters.
*
* 10-97 KDD
*
*----------------------------
* Parameters:
*
* O: IGRint           *NumSysAttr - pointer to number of attributes in the
*                                       User Collection.  Can be NULL.
*
* O: struct ACrg_coll **SysAttr   - pointer to list of System attribues.
*                                       Can be NULL.
*
* O: struct GRid      *SysParId   - pointer the object ID of the collection.
*                                       Can be NULL.
*
* I: struct GRid      object      - Target ObjectID.
------------------------------------------------------------------------------*/
#omdef vd$getSysAttrib2(    object,
                            NumSysAttr  = NULL,
                            SysAttr     = NULL,
                            SysParId    = NULL )

#if !om$specified (SysParId) && !om$specified (SysAttr) 
#omerror "Must specify SysParId or SysAttr."
#else
        VDSgetSysAttr2 ( (NumSysAttr), (SysAttr), (SysParId), (object));
#endif

#endomdef


/*------------------------------------------------------------------------------
* This macro gets system attributes of an object.
*	Suitable for all VDSroot objects. 
*	It subtracts the system parameters out of the whole list of parameters. 
*
* 10-97 KDD
*
*----------------------------
* Parameters:
*
* O: IGRlong	      *sts	  - return status. if != 1 error. 
*
* O: IGRint           *nbAttrs    - pointer to number of attributes in the
*                                       User Collection.  Can be NULL.
*
* O: struct ACrg_coll **att       - pointer to list of System attribues.
*				    Can be NULL.
*                                   The Program allocates memory.  
*				    The caller must free the memory _FREE(attr).
*
* I: struct GRmd_env  *md_env	  - module env of an object.
*
* I: struct GRid      object      - Target ObjectID.
------------------------------------------------------------------------------*/
#omdef vd$getSysAttributes( sts,
                            object,
                            md_env = NULL,
                            nbAttrs,
                            att )
 
       VDgetSysAttrs( (sts), (object), (md_env), (nbAttrs), (att) );
 
#endomdef



/*+Me
  External Macro vd$getUsrAttributes

  Abstract
      The macro is used to get the user attributes of any given object.  

  Arguments
      IGRlong            *sts             (O)    return code
      struct GRid        object           (I)    id of the object
      struct GRmd_env    *md_env          (I)    module environment of object
      IGRint             *nbAttrs         (O)    number or user attributes
      struct ACrg_coll   **att            (O)    List of user attributes

  Examples

          IGRint nbAttrs;
          struct ACrg_coll *att;

          status = vd$getUsrAttributes( sts     = &msg,
                                        object  = obj,
                                        nbAttrs = &nbAttrs,
                                        att     = &att );

  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : if some other error
-Me*/
  
#omdef vd$getUsrAttributes( sts,
                            object,
                            md_env = NULL,
                            nbAttrs,
                            att )

       VDgetUsrAttrs( (sts), (object), (md_env), (nbAttrs), (att) );

#endomdef



/*+Me
  External Macro vd$modUsrAttributes

  Abstract
       The macro is used to modify the user attributes of an object 
       based on the following logic :

            If the type of the attribute is VD_ATTRIB_DELETE, it is deleted.
            otherwise,
                If the attribute exists, it is modified to reflect
                the new type and value.
                If the attribute does not exist, it is created with the
                new type and value.

  Arguments
      IGRlong            *sts             (O)    return code
      struct GRid        object           (I)    id of the object
      struct GRmd_env    *md_env          (I)    module environment of object
      IGRint             nbAttrs          (I)    number of user attributes
                                                 to be modified
      struct ACrg_coll   *att             (I)    List of attributes to be 
                                                 modified

  Notes/Remarks
      The type of an attribute (att[i].desc.type) can have the following
      values :

              VD_ATTRIB_DELETE
              AC_ATTRIB_TEXT
              AC_ATTRIB_DOUBLE

  Examples

    To add the attributes :
       string attribute "useratt0"  with value "1001"
       double attribute "useratt1"  with value 234.561
       string attribute "useratt2"  with value "steel"
    and to delete the attribute
       useratt3

         struct ACrg_coll    att[4];

         for( i = 0 ; i < 4 ; i++ )
             sprintf( att[i].name, "useratt%1d", i );

         att[0].desc.type = AC_ATTRIB_TEXT;
         att[1].desc.type = AC_ATTRIB_DOUBLE;
         att[2].desc.type = AC_ATTRIB_TEXT;
         att[3].desc.type = VD_ATTRIB_DELETE;
         
         strcpy( att[0].desc.value.att_txt, "1001" );
         att[1].desc.value.att_exp = 234.561
         strcpy( att[2].desc.value.att_txt, "steel" );
         

          * get the object id of the object whose user attributes are
          * to be modified

          status = vd$modUsrAttributes( sts     = &msg,
                                        object  = obj,
                                        nbAttrs = 4,
                                        att     = att );

  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : if some other error
-Me*/


#omdef vd$modUsrAttributes( sts,
                            object,    
                            md_env = NULL,
                            nbAttrs,
                            att )

       VDmodUsrAttrs( (sts), (object), (md_env), (nbAttrs), (att) );

#endomdef

/*+Me
  External Macro vd$query_on_attr

  Abstract
      The macro is used to test the user attributes of any given object with
      an given value. The attribute can be an attribute of any type and a
      symbology representation of the object.

  Arguments
      IGRlong            *msg             (O)    return code
      struct GRobj_env   *object          (I)    id of the object
      IGRchar            *operant1        (I)    attribute/symbology of object
      IGRint             operator         (I)    Operator between operants
      IGRchar		 *operant2        (I)    Attribute value to test on.

  Examples

	  struct GRobj_env	obj;
          IGRchar		*operant1 = "system_id";
	  IGRint		operant  = VD_cnt_qry_EQUAL;
	  IGRchar		*operant2 = "1234"

          status = vd$query_on_attr( sts      = &msg,
                                     object   = &obj,
                                     operant1 = operant1,
				     operator = operant,
				     operant2 = operant2 );

  Status/Return Code
      OM_S_SUCCESS    : if query is TRUE.
      OM_W_ABORT      : otherwise
-Me*/
  
#omdef vd$query_on_attr( msg,
                         object,
			 operant1,
			 operator,
			 operant2 )

       VDquery_on_attr( (msg), (object), (operant1), (operator), (operant2) );

#endomdef

/*+Me
  External Macro vd$qry_check_macro

  Abstract
      The macro is used to test if the input name belong to a macro, if it is,
      retune true.

  Arguments
      IGRlong            *msg             (O)    return code
      IGRchar            *name            (I)    object name

  Examples
          IGRlong		msg;
          IGRchar		*name = "macr1";

          status =
	  vd$qry_check_macro(	sts      = &msg,
				name     = name);

  Status/Return Code
      OM_S_SUCCESS    : if name is a macro name.
      OM_W_ABORT      : otherwise
-Me*/

#omdef vd$qry_check_macro( msg,
                         name)

       VDqry_check_macro( (msg), (name));

#endomdef

/*+Me
  External Macro vd$qry_get_id_list

  Abstract
      The macro is used to get all defined queries; The queries are
      returned into an external defined list.
      In case the list is undefined (= NULL ), the macro returns the
      number of queries found in current (and reference) file.
      The macro returns OM_S_SUCCESS if any query is found. If list is
      defined, the found queries are listed.

      If "ref_file" == TRUE, the macro look for queries in the current
      design file and in the reference files. Default, we only check in
      the active design file.

  Arguments

	IGRlong                 *msg;         (o) return code
	IGRint                  list_size;    (i) query list size limit
	struct GRid             *list;        (o) query id list
	struct GRmd_env         *envlist;     (o) query env list         
	IGRint                  *count;       (o) query count
	IGRint                  ref_file;     (i) ref_file(default = FALSE) 

  Examples
	IGRlong                 msg;                    
	IGRint                  list_size;              
	struct GRid             *list;              
	struct GRmd_env         *envlist;              
	IGRint                  count; 

	status =
	vd$qry_get_id_list(	msg	= &msg,
				count	= &count );

	list_size = count ;
	list = (struct GRid *) om$malloc( size = count * sizeof(struct GRid));
	envlist = (struct GRmd_env *) om$malloc( size = 
                                      count * sizeof(struct GRmd_env));

	status =
	vd$qry_get_id_list(	msg	  = &msg,
                                list_size = list_size,
                                list      = list,
                                md_env_list = envlist,
                                count     = &count );

  Status/Return Code
      OM_S_SUCCESS    : if query list is got.
      OM_W_ABORT      : otherwise
-Me*/

#omdef vd$qry_get_id_list(	msg,
				list_size	= 0,
				list		= NULL,
				md_env_list	= NULL,
				count,
				ref_file	= FALSE )

        VDqry_give_list( (msg), (list_size), (list), (md_env_list), (count), (ref_file) );

#endomdef

/*+Me
  External Macro vd$qry_name2id

  Abstract
      The macro is used to get query id and query name lists,
      retune true if get query list and give out list and size of list.

  Arguments

        IGRlong                 *sts;         	(o) return code
	struct GRid             *objid;  	(o) objid list
	IGRchar                 *name;  	(i) name list

  Examples
        IGRlong                 msg;
	IGRchar                 *name;         
	struct GRid             *objid;  


        status =
	vd$qry_name2id( sts   = &msg,
                        name  = name,
                        objid = objid);

  Status/Return Code

      OM_S_SUCCESS    : if object if found.
      OM_W_ABORT      : otherwise
-Me*/

#omdef vd$qry_name2id( sts, name, objid)

  	VDqry_name_to_objid( (sts), (name), (objid) );

#endomdef

/*+Me
  External Macro vd$qry_process

  Abstrat

    This function return list of objects which match with the query
    and list number.

  Arguments

        IGRlong                 *sts;             (o) return code
        struct GRobj_env        *objects;         (i) object list
        IGRint                  *nb_objects;      (i) number of objects
        struct GRid             *queries;         (i) query list
        IGRint                  *nb_queries;      (i) number of queries
        struct GRobj_env        **found;          (o) list of objects found
        IGRint                  *nb_found;        (o) number of found objects
           
  Examples
        IGRlong                 msg;
        struct GRobj_env        *objects;         
        IGRint                  nb_objects;     
        struct GRid             *queries;     
        IGRint                  nb_queries;   
        struct GRobj_env        *found;      
        IGRint                  nb_found;  

        (assume we have known the objects, nb_objects, queries,
                nb_queries)

        nb_found = 0;
        found = NULL;       
        ** found is allocated in function vd$qry_process *** 
        vd$qry_process( sts  	   = &msg,
                        objects    = objects,
        		nb_objects = nb_objects,
        		queries    = queries,
        		nb_queries = nb_queries,
        		found      = &found,
        	        nb_found   = &nb_found);
 
        ** user should free found: 
            if(found) free(found);

  Status/Return Code

      OM_S_SUCCESS    : if object if found.
      OM_W_ABORT      : otherwise
-Me*/

#omdef vd$qry_process(  sts, 
			objects, 
			nb_objects, 
			queries, 
                        nb_queries, 
			found 		=  NULL,  
			nb_found )

        VDqry_process( (sts), (objects), (nb_objects), (queries), 
                              (nb_queries), (found), (nb_found));

#endomdef

/*+Me
  External Macro vd$qry_get_mul_objects

  Abstrat

    This function return list of objects which match with the query
    and list number.

  Arguments

        IGRlong                 *sts;             (o) return code
        struct GRobj_env        *objects;         (i) object list
        IGRint                  *nb_objects;      (i) number of objects
        IGRchar                 *query;           (i) query
        struct GRobj_env        *found;           (o) list of objects found
        IGRint                  *nb_found;        (i/o) number of found objects

  Examples
        IGRlong                 msg;
        struct GRobj_env        *objects;         (known)
        IGRint                  nb_objects;       (known)
        IGRchar                 buffer[80];
        struct GRobj_env        *found;
        IGRint                  num;
        IGRint 			nb_querie;

        num = 0;
        nb_queries = 5;
        strcpy(buffer, "select GR3dpoint where color = red;");
        for( i = 0; i < nb_queries; i++) {
        	vd$qry_get_mul_objects( sts        = &msg,
                        		objects    = objects,
                        		nb_objects = nb_objects,
                        		query      = buffer,
                        		found      = found,
                        		nb_found   = &num);
        }

  Status/Return Code
      OM_S_SUCCESS    : if object is found.
      OM_W_ABORT      : otherwise

-Me*/
#omdef vd$qry_get_mul_objects( sts, 
                               objects, 
                               nb_objects, 
                               query,
                               found, 
			       nb_found )

        VDqry_get_mul_objects( (sts), (objects), (nb_objects), (query),
                              (found), (nb_found));

#endomdef

/*+Me
  External Macro vd$qry_chk_one_object

  Abstrat

   This function try to find if there is any object matching with query.

  Arguments

        IGRlong                 *sts;             (o) return code
        struct GRid             *objects;         (i) object list
        IGRint                  *nb_objects;      (i) number of objects
        IGRchar                 *query;           (i) query
        struct GRid             *found;           (o) list of objects found

  Examples
        IGRlong                 msg;
        struct GRid             *objects;   	(known)
        IGRint                  nb_objects;   	(known)
        IGRchar                 buffer[80];
        struct GRid             *found;

        strcpy(buffer, "select GR3dpoint where color = red;");  
        vd$qry_chk_one_object( sts        = &msg,
                                objects    = objects,
                                nb_objects = nb_objects,
                        	query      = buffer,
                                found      = found);

  Status/Return Code

      OM_S_SUCCESS    : if object is found.
      OM_W_ABORT      : otherwise
-Me*/
#omdef vd$qry_chk_one_object( sts, objects, nb_objects, query,
                               found )

        VDqry_chk_one_object( (sts), (objects), (nb_objects), (query),
                              (found));

#endomdef

/*+Me
  External Macro vd$qry_get_macro_names

  Abstrat
    This function returns the valid macros of the current design file.
   
  Arguments

        IGRlong                 *sts;             (o) return code
        IGRchar                 **macronames;     (o) macro names array
        IGRint                  *count;           (i/o) number of macro names

  Examples
        IGRlong                 sts;
        IGRchar                 **macronames;     
        IGRint                  count;

        count = 0; 
        status =
        vd$qry_get_macro_names( msg     = &sts,
                                count   = &count );

        names = NULL ;
        names = (char **) malloc(count * sizeof(char*));  
        for( i=0 ; i<count ; i++ ) {
                        names[i] = NULL ;
                        names[i] = (char *) malloc( Maxword * sizeof(char));  
        }
        status =
        vd$qry_get_macro_names( msg        = &sts,
                                macronames = macronames,
                                count      = &count );


  Note: user need to free names 
        if(macronames) 
                for (i = 0; i < count; i++) {
                   if(macronames [i] ) {
                        free ( macronames [i] );
                   }
                }
                free ( macronames );
         }

  Status/Return Code

      OM_S_SUCCESS    : if object is found.
      OM_W_ABORT      : otherwise
-Me*/
#omdef vd$qry_get_macro_names( msg, 
                               macronames = NULL,
                               count ) 
      
       VDqry_get_macro_names( (msg), (macronames), (count));  

#endomdef

/*+Me
----------------------------------------------------------------------------
  External Macro vd$db_review_params

  Abstract
      This macro returns, from the object defined by pComponent, the types
      and values of the parameters specified in pList filled in before
      calling. Information will be retrieved from Database only.


  Arguments
      long                *msg           (O)    returns MSFAIL if any
                                                parameter fails ( in this case,
                                                its returned type is
                                                AC_ATTRIB_TYPE_NOT_DEF );
      struct GRid         *object        (I)    component's object id.
      struct GRmd_env     *md_env        (I)    module environment.
      int                 count          (I)    number of names initialized
                                                in the List array.
      char              *table         (I)    Database table
      struct ACrg_coll    *pList         (I/O)  pointer to the List array.

  Status/Return Code
      OM_S_SUCCESS    : if success
----------------------------------------------------------------------------
-Me*/

#omdef vd$db_review_params (   sts,
                               object,
                               md_dev = NULL,
                             count,
                             table  = NULL,
                               plist)

VDDbreviewParams ( (sts), (object), (md_dev), (count), (table),(plist));

#endomdef


/*+Me
--------------------------------------------------------------------------
  External Macro vd$db_get_params

  Abstract
      The macro is used to get all the parameters and their values
      of any given object from a dynamic table. The table can be from
      the following types:
              - Dynamic Posting Table (default)
              - Assembly Tree posting Table
              _ User Defined Production Table
      This process will interact with the database only.


  Arguments
      IGRlong            *sts             (O)    return code
      struct GRid        *object          (I)    id of the object
      struct GRmd_env    *md_env          (I)    module environment
      char             *table           (I)    database table name
      IGRint             *count           (O)    number of parameters
      struct ACrg_coll   **plist          (O)    pointer to the list array

  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : some error

  Remarks
      Memory for the output list of parameters will be allocated by the macro
      and has to be freed by the caller.
-----------------------------------------------------------------------------
-Me*/

#omdef vd$db_get_params(sts,
                        object,
                        table  = NULL,
                        md_env = NULL,
                        count,
                        plist )
     VDDbgetParams( (sts), (object), (table), (md_env), (count), (plist) );
#endomdef


/*+Me
--------------------------------------------------------------------------
  External Macro vd$db_get_parameters

  Abstract
      The macro is used to get all the parameters and their values
      of any given object from a dynamic table. The table can be from
      the following types:
                - Dynamic Posting Table (default)
                - Assembly Tree posting Table
                _ User Defined Production Table
      This process will interact with the database only.
      Normally the macro would be called twice; once to get the number
      of parameters, and the second time, to get the list of parameters
      and their values.

  Arguments
      <Data Type>       <Name>  <I/O>   <Description>

      IGRlong          *sts         O     return code
      struct GRid      *object      I     GRid of the object
      IGRchar          *table       I     table name .
      GRmd_env         *md_env      I     module environment of the object
      struct ACrg_coll *plist       O     Pass NULL if list of parameters
                                          not needed; otherwise pass pointer
                                          to an ACrg_coll structure.  Memory
                                          has to be allocated before calling
                                          the function.
      IGRint           size         I     Size of the plist passed
      IGRint           *count       O     No of parameters returned.
                                          If plist = NULL, count is the total
                                          number of parameters for the object

  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_E_NODYNMEM   : not enough dynamic memory available
      OM_W_ABORT      : some error

  Remarks
-----------------------------------------------------------------------------
-Me*/

#omdef vd$db_get_parameters(sts,
                            object,
                            table  = NULL,
                            md_env = NULL,
                            plist = NULL,
                            size = 0,
                          count)

 VDDbget_parameters( (sts), (object),(table),(md_env),(plist),(size),(count));

#endomdef


#endif /* vd_parmacros_include */

