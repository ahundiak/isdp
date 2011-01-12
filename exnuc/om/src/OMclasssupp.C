/*
-------------------------------------------------------------------------------
Name:			OMclasssupp.c
Author:			Chuck Puckett
Creation Date:		10-sep-1985
Operating System(s):	Unix SYSV, v2
Abstract:

	This module contains class support routines.

Revision History:

rme001  27-jun-1986     Split from OMclasses.c. Modify for 4.0 data structures.
                        Remove references to relation objects.

ems001  09-oct-1986     Added som_build_internal_classlist function - private

ems002  13-may-1987     Fixed bug in som_build_internal_classlist to 
                         allocate using highest filed classid for size
                         instead of OM_Gw_next_class_index.

ems003  25-may-1987     Added hash for classnames in som_get_class.

ems004  15-oct-1987     Fixed bug in som_build_internal_classlist where
                         classids greater than OM_GA_fa_mapsize[OS] were
                         being added to list - therefore they were out of
                         range - caused problem with malloc headers.

geo001	09-dec-1987	Get active classid via spacemap instead of from objhdr.

ems005  16-oct-1989     Add som_dload_class function.
-------------------------------------------------------------------------------
*/

#ifndef OM_D_OBJECTCOMM
#include 	"OMobjectcomm.h"
#endif

#ifndef OM_D_METACLASS
#include 	"OMmetaclass.h"
#endif

#ifndef OM_D_INTPRIMS
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#endif

#ifdef BIG_ENDIAN
#include "OMport.h"
extern OMuint	OM_Gf_ioMode;
extern void	*OM_Gp_inst_in;
extern void	*OM_Gp_inst_out;
#endif

#include <stdio.h>
#include <string.h>
#ifdef BIG_ENDIAN
#include <sys/param.h>
#endif
#ifndef NT
#include <dload.h>
// #include <error.h>
#endif
#include "version.h"

#ifndef NT
extern  void			*dload_address_lookup();
#endif

extern	OMuword			OM_Gw_min_opp_major_version;
extern	OMuword			OM_Gw_last_opp_minor_version;
extern	OMuword			OM_Gw_major_version;
extern	OMuword			OM_Gw_minor_version;
extern  OM_S_CLASS_HASH_ENT     OM_GA_class_hash[];
extern  int			OM_Gf_class_init;
#ifndef NT
extern  OMuint                  OM_Gf_dload_mode,
                                OM_Gf_dload_opts,
                                OM_Gf_dload_unresolved,
                                OM_Gf_verbose_warning;
extern  int                     OM_Gi_number_of_appl_ids;
extern  INGR_p_PRODUCT_DEF      OM_GA_appl_version[];
#endif


/* +++ 4.0 +++++++++++++++++++++++++++++++++++++++++++++++++ som_get_classid */

/*
    Description:

    This routine looks up the classid based on a class name, object id, 
    or an instance pointer.

*/

int som_get_classid (
OMuword		OSnum,          /*  object space number  */
char            *classname,     /*  class name  */
OM_S_OBJID      objid,          /*  object id   */
OM_p_OBJECTHDR  p_object,       /*  object instance pointer  */
OMuword		*p_classid)	/*  place to put class id    */

{
   int                  sts;
   OM_p_CLASSDEF        p_cld;

   if(p_object)
      sts = om$get_class
            ( osnum=OSnum,
              object=p_object,
              p_classid=p_classid,
              pp_cld=&p_cld);
   else if (classname)
      sts = om$get_class
            ( osnum=OSnum,
              classname=classname,              
              p_classid=p_classid,
              pp_cld=&p_cld);
   else
      sts = om$get_class
            ( osnum=OSnum,
              objid=objid,
              p_classid=p_classid,
              pp_cld=&p_cld);

   if (!(1&sts)) return (sts);

   return (OM_S_SUCCESS);
}


/*
    Description:

    This routine will find a classname given a classid,
    an object id and object space number, or an object instance
    pointer.

*/

int som_get_classname (
OMuword		OSnum,          /*  object space number  */
OMuword		classid,	/*  class id    */
OM_S_OBJID      objid,          /*  object id   */
OM_p_OBJECTHDR  p_object,       /*  object instance pointer  */
char            *classname)     /*  class name  */
{

   int	                sts;
   OM_p_CLASSDEF        p_cld;

   /*  Get pointer to ACLD  */

   if (classid != OM_K_NOTUSING_CLASSID)
   {
      /*  validate the classid and get an ACLD pointer  */

      if ( (classid >= OM_Gw_next_class_index)      ||
           (NULL == (p_cld = OM_GA_active_classes[classid])) )
      {
         return (OM_E_NOSUCHCLASS);
      }
   }             
   else 
   {
      if(!p_object)
         sts = om$get_class
               ( osnum=OSnum,
                 objid=objid,
                 pp_cld=&p_cld);
      else
         sts = om$get_class
               ( osnum=OSnum,
                 object=p_object,
                 pp_cld=&p_cld);

      if (!(1&sts)) return (sts);
   }

   strncpy (classname,p_cld->s_name,OM_K_MAXCLASS_LEN);
   return (OM_S_SUCCESS);
}


/*
    Description:

    This routine returns a pointer to an active class definition and
    the active classid given a class name, object id, or an instance 
    pointer.  (If p_classid is NULL then the classid will NOT be 
    returned.)

*/

int som_get_class (
OMuword         OSnum,          /* object space number  */
char		*classname,     /* class name */
OM_S_OBJID      objid,          /* object id  */
OM_p_OBJECTHDR	p_object,       /* object instance pointer */
OMuword         *p_classid,     /* place to put classid  */
OM_p_CLASSDEF	*pp_cld)	/* pointer to CLD pointer */

{
   int			ii;
   OM_p_CLASSDEF	p_testcld;
   OMuword              classid;
   OM_p_OSD             p_OSD;
   OM_S_RIP		rip;
   OMuint               hash_ndx;
   char                 *here;
   OM_p_CLASS_HASH_ENT  p_hash;

   rip.p_object = NULL;

   if (classname != NULL)  
   { 
      /*-----------------------*/
      /*  CASE: by class name  */
      /*-----------------------*/

      for (hash_ndx = 0, here = classname, ii = 0; *here; here++, ii++)
        hash_ndx += *here << ii;

      hash_ndx %= OM_K_CLASS_HASH_MAX;

      p_hash = &OM_GA_class_hash[hash_ndx];
      if ( p_hash->p_acld )
      {
         while (p_hash)
         {
            if (!strcmp(p_hash->p_acld->s_name,classname))
            {
               if (p_classid != NULL)  *p_classid = p_hash->p_acld->w_classid;
               *pp_cld = p_hash->p_acld;
               return (OM_S_SUCCESS);
            }
            p_hash = p_hash->next;
         }
      }

      /* class not present in hash table     */
      /* search all active classes for match */
      if (OM_Gf_class_init)
      {
        if (p_classid != NULL) *p_classid = (OMuword) -1;
        *pp_cld = NULL;
        return (OM_E_NOSUCHCLASS);
      }

      for (ii=OM_Gw_next_class_index-1; ii >= 0 ; ii--)
      {
         if (NULL != (p_testcld = OM_GA_active_classes[ii]))
         {
            if (!strcmp(classname, p_testcld->s_name))
            {
               /* add a new entry to the hash */
               if ( p_hash )
               {
                  p_hash->p_acld = p_testcld;
               }
               else
               {
                  p_hash = om$malloc ( structure = OM_S_CLASS_HASH_ENT );
                  p_hash->p_acld = p_testcld;
                  p_hash->next = OM_GA_class_hash[hash_ndx].next;
                  OM_GA_class_hash[hash_ndx].next = p_hash;
               }
               if (p_classid != NULL)  *p_classid = p_testcld->w_classid;
               *pp_cld = p_testcld;
               return (OM_S_SUCCESS);
            }
         }
      } 

      /* if here, we found no class name that matched */

      if (p_classid != NULL) *p_classid = (OMuword) -1;
      *pp_cld = NULL;
      return (OM_E_NOSUCHCLASS);
   }

   /*  Validate the osnum and get pointer to OS descriptor  */

   if ( (OM_Gw_maxOS <= OSnum ) || (NULL == (p_OSD = OM_GA_OSDs[OSnum])) )
   {
      return (OM_E_NOSUCHCLASS);
   }

   if (p_object != NULL)
   {
      /*-------------------------------------*/
      /*  CASE:  by object instance pointer  */
      /*-------------------------------------*/ 

      if(p_OSD->Spacemap[p_object->oid].flags & OM_SM_unknown_obj)
	      return (OM_E_NOSUCHCLASS);
 
      /* 
       * Found that for some invalid objects, i.e. with correct
       * objid but wrong osnum, the check for OM_SM_unknown_obj
       * does'nt work. (flags contain 0). The check below  
       * tracks them.  - Srikanth. 
       */
      if( OM_OBJ_INVALID(p_OSD->Spacemap[p_object->oid].flags) )
	      return (OM_E_NOSUCHOBJ);
      classid = p_OSD->Spacemap[p_object->oid].p_acld->w_classid;

   }
   else 
   {
      if ( !IF_NULL_OBJID(objid) && objid < p_OSD->CurSpaceMapSize )
      {
         /*-----------------------*/
         /*  CASE:  by object id  */
         /*-----------------------*/ 

         if (OM_OBJ_INVALID(p_OSD->Spacemap[objid].flags))
              return (OM_E_NOSUCHOBJ);
         if(p_OSD->Spacemap[objid].flags & OM_SM_unknown_obj)
	      return (OM_E_NOSUCHCLASS);
         classid = p_OSD->Spacemap[objid].p_acld->w_classid;
      }

      else
      {
         /*-------------------*/
         /*  bad parameter(s) */
         /*-------------------*/

         return (OM_E_INVARG);
      }
   }

   /*-------------------------------------*/
   /*  CASE:  by object instance pointer  */
   /*-------------------------------------*/

   if ( (classid  >= OM_Gw_next_class_index)  ||
        (NULL == (*pp_cld = OM_GA_active_classes[classid])) )
   {
      return (OM_E_NOSUCHCLASS);
   }

   if (p_classid != NULL) *p_classid = classid;
   
   return (OM_S_SUCCESS);
}


/*
    Description:

    This routine is used to test whether or not a class is in the ancestry 
    of another class.  Using either classnames or classids.

*/

int som_is_ancestry_valid(
OMuword  sub_classid,               /*  active classid of subclass    */
OMuword  super_classid,             /*  active classid of superclass  */
char     *sub_classname,            /*  class name for sub class      */
char     *super_classname)          /*  class name for super class    */

{
   int              sts;               /*  status variable               */
   OM_p_CLASSDEF    p_cld;             /*  pointer to class definition   */

   /*----------------------------------------------------*/
   /*  Need to have classid of subclass and superclass   */
   /*----------------------------------------------------*/

   if (sub_classid == OM_K_NOTUSING_CLASSID)
   {
      if (sub_classname != NULL)
      {
         sts = om$get_classid
                  ( classname=sub_classname, 
                    p_classid=(OMuword *)&sub_classid );

         if (!(1&sts)) return (sts);
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   if (super_classid == OM_K_NOTUSING_CLASSID)
   {  
      if (super_classname != NULL) 
      {
         sts = om$get_classid 
                  ( classname=super_classname,
                    p_classid=(OMuword *)&super_classid );

         if (!(1&sts)) return (sts);
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   /*  validate the classids  */

   if ( sub_classid < OM_Gw_next_class_index &&  
        super_classid < OM_Gw_next_class_index )
   {

      /*   Get pointer to ACLD of subclass.  */   

      if ( NULL != (p_cld = OM_GA_active_classes[sub_classid]) )
      {

         /*  Test superclass against subclasses' possible range of  */
         /*  ancestor classids.                                     */ 

	 if ( !(super_classid < p_cld->w_baseclass || 
		super_classid > p_cld->w_maxclass))
	 {

            /*  Non NULL entry in translation map means superclass is  */
            /*  an ancestor.                                           */

	    if ( (p_cld->p_transmap[super_classid - p_cld->w_baseclass]) !=
		  OM_K_NULL_TRANS)
            {
                 return (OM_S_SUCCESS);
            }
         }
         return (OM_I_INVANCESTRY);    /* superclass is not ancestor. */
       }
    }
    return (OM_E_NOSUCHCLASS);   /* invalid classid(s) */
}


/* 
    Description:

    This routine will return the class id of the parent of a given class 
    id or class name.  If the indicated class is a union class, the 
    returned classid will be that of the "rightmost" defined parent.

*/
  
int som_get_parent_classid (
OMuword   classid,                  /*  active classid                */
char      *classname,               /*  class name                    */
OMuword   *parent_classid)          /*  address of parent's classid   */

{
   int             sts;                /*  returned status value        */
   OM_p_CLASSDEF   p_cld;              /*  pointer to classes' ACLD     */
   OMuword         *p_parent_classid;  /*  pointer to parent's classid  */

   /*---------------*/
   /*  Get classid  */
   /*---------------*/

   if (classid == OM_K_NOTUSING_CLASSID)
   {
      if (classname != NULL)
      {
         /*  get the classid from the classname  */

         sts = om$get_classid
                  ( classname=classname,
                    p_classid=(OMuword *)&classid);

         if (!(1&sts))  return (sts);
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   /*---------------------------------------*/
   /*  get pointer to ACLD and find parent  */
   /*---------------------------------------*/

   if ( classid < OM_Gw_next_class_index )
   {
      if ( NULL != (p_cld = OM_GA_active_classes[classid]) )
      {

         sts = OM_I_ISAUNION;

         switch (p_cld->w_numparents)
         {
         case 0:
            return (OM_I_NOPARENT);

         case 1:
            sts = OM_S_SUCCESS;

            /*  Parent classid is pointed to by       */
            /*  A_ancestor_list[0]->p_classid.        */
            /*  Fall through and get parent classid   */

         default:   
            /*  union class  */

            p_parent_classid = 
                  p_cld->A_ancestor_list[p_cld->w_numparents-1].p_classid;

            *parent_classid = *p_parent_classid;
            return (sts);
         }   
      }
   }
   return (OM_E_NOSUCHCLASS);
}


/*
    Description:

    This routine will return the class name of the parent of a given 
    class id or class name.  

    If this routine is being used to trace a class's ancestry,
    the trace loop will want to test for OM_I_NOPARENT in order to
    terminate.  The OM_I_NOPARENT return code will only be returned 
    if the class passed in is "Root".

    If the class represents a union class, then the classname
    returned will be that of the "rightmost" parent.

*/

int som_get_parent_classname (
OMuword  classid,             /*  class id                       */
char     *classname,          /*  class name                     */
char     *parent_classname)   /*  class name of parent (output)  */

{
   int              sts;                 /*  status variable              */
   OM_p_CLASSDEF    p_cld;               /*  pointer classes' ACLD        */ 
   OM_p_CLASSDEF    p_parent_cld;        /*  pointer to parent's ACLD     */
   OMuword          parent_classid;      /*  parent's active classid      */

   /*--------------------------------*/
   /*  Get pointer to classes ACLD.  */
   /*--------------------------------*/

   if (classid != OM_K_NOTUSING_CLASSID)
   {
      if ( (classid >= OM_Gw_next_class_index)  ||
           (NULL == (p_cld = OM_GA_active_classes[classid])) )
      {
         return (OM_E_NOSUCHCLASS);
      }
   }  
   else
   {
      if (classname != NULL)
      {
         sts = om$get_class
                  ( classname=classname,
                    pp_cld=&p_cld );

         if (!(1&sts))  return(sts);
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   /*--------------------------------*/
   /*  ok, get the parent classname  */
   /*--------------------------------*/

   sts = OM_I_ISAUNION;

   switch (p_cld->w_numparents)
   {
      case 0:
         return (OM_I_NOPARENT);

      case 1:
          sts = OM_S_SUCCESS;

          /*  Fall through to get parent classname  */
        
      default:

          /*  Union class.  */

          if ( (OM_Gw_next_class_index > (parent_classid =
                *(p_cld->A_ancestor_list[p_cld->w_numparents-1].p_classid)))
               &&
               (NULL != (p_parent_cld = OM_GA_active_classes[parent_classid])))
          {
             strncpy (parent_classname,p_parent_cld->s_name,OM_K_MAXCLASS_LEN);
             return (sts);
          }
          else
          {
             return (OM_E_NOSUCHCLASS);
          }
   }
}


/*
    Description:

    This routine will return the count of the number of parents of a 
    given class id or classname.  

*/

int som_get_parent_count (
OMuword   classid,                  /*  active classid                */
char      *classname,               /*  classname                     */
OMuword   *parent_count)            /*  address of count of parents   */

{
   OM_p_CLASSDEF   p_cld;          /*  pointer to classes' ACLD     */
   int             sts;

   /*---------------*/
   /*  Get classid  */
   /*---------------*/

   if (classid == OM_K_NOTUSING_CLASSID)
   {
      if (classname != NULL)
      {
         sts = om$get_classid
                  ( classname=classname,
                    p_classid=(OMuword *)&classid );

         if (!(1&sts)) return (sts);
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   /*--------------------------------------*/
   /*  validate classid and get the count  */
   /*--------------------------------------*/

   if ( classid < OM_Gw_next_class_index )
   {
      if ( NULL != (p_cld = OM_GA_active_classes[classid]) )
      {
         *parent_count = p_cld->w_numparents;
         return (OM_S_SUCCESS);
      }
   }
   return (OM_E_NOSUCHCLASS);
}


/*
    Description:

    This routine will return a list of the classids for all parents of 
    a given class id or class name.  Parent_list is assumed to be 
    allocated to "size" number of elements.

*/

int som_get_all_parents (
OMuword   classid,                  /*  active classid                */
char      *classname,               /*  class name                    */
OMuword   parent_list[],            /*  array to store parents' ids   */
OMuint    size,                     /*  max no. of elements in list   */
OMuint    *count)                   /*  count of parent ids returned  */

{
   OM_p_CLASSDEF     p_cld;              /*  pointer to classes' ACLD      */
   OMuword           *p_parent_classid;  /*  pointer to parent's classid   */
   OMuword           ii,                 /*  counter                       */
                     limit;              /*  invariant                     */
   int               sts;

   /*---------------*/
   /*  Get classid  */
   /*---------------*/

   if (classid == OM_K_NOTUSING_CLASSID)
   {
      if (classname != NULL)
      {
         sts = om$get_classid
                  ( classname=classname,
                    p_classid=(OMuword *)&classid);
       
         if (!(1&sts))  return(sts);
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   /*--------------------*/
   /*  get ACLD pointer  */
   /*--------------------*/

   *count = 0;

   if ( classid < OM_Gw_next_class_index )
   {
      if ( NULL != (p_cld = OM_GA_active_classes[classid]) )
      {
         /*-----------------------------------------*/
         /*  fill parent_list from A_ancestor_list  */
         /*-----------------------------------------*/

         limit = p_cld->w_numparents;
         for (ii=0; ii < limit  &&  ii < size; ii++)
         {
           p_parent_classid = p_cld->A_ancestor_list[ii].p_classid;
           parent_list[ii] = *p_parent_classid;
         }

         *count = ii;

         /*  Was array big enough ?  */

         if (size < p_cld->w_numparents)  return (OM_I_LISTOVFLOW);

         return (OM_S_SUCCESS);
      }
   }
   return (OM_E_NOSUCHCLASS);
}


/*
    Description:

    This routine will return the major and minor version numbers of a 
    given class id or classname.

*/

int som_report_class_version (
OMuword   classid,
char      *classname,
OMuword   *major,
OMuword   *minor)

{
   OM_p_CLASSDEF   p_cld;
   OMuword         my_classid;
   int             sts;

   /*-----------------------*/
   /*  Get an ACLD pointer  */
   /*-----------------------*/

   if (classid != OM_K_NOTUSING_CLASSID)
   {
      if ( (classid >= OM_Gw_next_class_index) ||
           (NULL == ( p_cld = OM_GA_active_classes[classid])) )
      {
         return (OM_E_NOSUCHCLASS);
      }
   }
   else
   {
      if (classname != NULL)
      {
         sts = om$get_class
                  ( classname= classname,
                    p_classid=&my_classid,
                    pp_cld=&p_cld);

         if (!(1&sts)) return(sts);
      }
      else
      {
         return (OM_E_INVARG);
      }
   }

   *major = p_cld -> w_major_version;
   *minor = p_cld -> w_minor_version;
   return (OM_S_SUCCESS);
}

int som_build_internal_classlist ( p_clst, pp_intclst )

OM_p_CLASSLIST  p_clst;
OMbyte          **pp_intclst;
{
   int     sts;
   OMuword fil_classid, i, j;
   OMbyte  *int_clst;

   /*================================================*/
   /*  if user classlist has no entries then return  */
   /*================================================*/

   if (! p_clst->w_count )
   {
      return (OM_S_SUCCESS);
   }

   /*====================================*/
   /*  allocate the internal byte array  */
   /*====================================*/

   if (!(int_clst = (OMbyte *)om$calloc
           (size=sizeof(OMbyte) * OM_GA_fa_mapsize[OM_Gw_current_OS])))
      return (OM_E_NODYNMEM);

   /*===========================================================*/
   /*  put all classes in user classlist in internal classlist  */
   /*===========================================================*/

   for ( i=0; i<p_clst->w_count; i++ )
   {
      fil_classid = OM_GA_active_to_filed[p_clst->p_classes[i]];
      if ( fil_classid < OM_GA_fa_mapsize[OM_Gw_current_OS] ) 
         int_clst[fil_classid] = 1;
   }
  
   /*========================================================*/
   /*  check if subclasses are needed in internal classlist  */
   /*========================================================*/

   if ( p_clst->w_flags & OM_CLST_subclass )
   {
      for ( i=1; i<OM_Gw_next_class_index; i++ )
      {
         if ( OM_GA_active_classes[i] )
         {
            if ( ! int_clst[OM_GA_active_to_filed[i]] )
            {
               for ( j=0; j<p_clst->w_count; j++ )
               {
                  sts = om$is_ancestry_valid ( subclassid = i,
                                   superclassid = p_clst->p_classes[j] );
                  if ( sts == OM_S_SUCCESS )
                  {
                     fil_classid = OM_GA_active_to_filed[i];
                     if ( fil_classid < OM_GA_fa_mapsize[OM_Gw_current_OS] )
                        int_clst[fil_classid] = 1;
                  }
               }
            }
         }
      }      
   }      

   /*=============================================*/
   /*  if negation is set - complement classlist  */
   /*=============================================*/

   if ( p_clst->w_flags & OM_CLST_negation )
   {
      for ( i=0; i<OM_GA_fa_mapsize[OM_Gw_current_OS]; i++ )
      {
         if ( int_clst[i] )
         {
            int_clst[i] = 0; 
         }
         else
         {
            int_clst[i] = 1;
         }
      }
   }

   *pp_intclst = int_clst;
   return (OM_S_SUCCESS);
}

/*
------------- Function Description --------------------------------------------

  Function name:    som_get_message_name ( classname,  classid,  method_index, 
                                           msg_name )

  Input arguments:  char           *classname    Class name of the class
in
                                                 which the method defined
                    OMuword        classid       Class id of the class where
                                                 the method defined.
                    OMuword        method_index  Method index.

   Output argument: char           *msg_name     Message name.


   The function som_get_message_name will get the message name based on class
   name or class id and method index.

-------------------------------------------------------------------------------
*/

int som_get_message_name (
char               *classname,
OMuword            classid,
OMuword            method_index,
char               *msg_name)
{
int                sts;
struct OM_sd_methdefn *p_methdef;
OM_p_CLASSDEF      p_ACLD;

   /*============================================*/
   /*  if classname was given then transform it  */
   /*============================================*/

   if ( classname != NULL )
     {
      if (!(1&(sts = om$get_class (classname=classname,  p_classid=(OMuword *)&classid, 
                                   pp_cld=&p_ACLD))))
        {
         return (sts);
        }
     }
   else if ( classid != OM_K_NOTUSING_CLASSID )
     {
      if (NULL==(p_ACLD=OM_GA_active_classes[classid]))
        {
         return (OM_E_NOSUCHCLASS);
        }
     }
   else
     {
      return (OM_E_INVARG);
     }

   /* Search through the linked list of method definition until the one
      indexed by method_index is found */
   for (p_methdef=p_ACLD->p_methdefns; p_methdef != NULL; p_methdef=p_methdef->next)
     {
      if (p_methdef->w_methidx == method_index)
        {
         strncpy(msg_name,  p_methdef->s_name,  OM_K_MAXCLASS_LEN);
         return (OM_S_SUCCESS);
        }
     }
   return (OM_E_NOSUCHMSG);
}


/*---------------------------------------------*/
/*  som_dload_class(file_list, product_list,   */
/*                  product_path_list)         */
/*                                             */
/*  Function to dload classes into OM          */
/*                                             */
/*  file_list points to a list of full path    */
/*  name of .o files to be dynamically loaded  */
/*                                             */
/*  product_list points to a list of products  */
/*  being dynamically loaded (this may be 0)   */
/*  (e.g., when dyn loading NC, product_list   */
/*  would contain the string "NC", & strings   */
/*  for each component product of NC)          */
/*                                             */
/*  product_path_list points to a list of      */
/*  pathnames for the products being loaded.   */
/*  It can be 0.                               */
/*---------------------------------------------*/

#define OM_K_CLIST_SIZ 64

#argsused
int som_dload_class ( file_list, product_list, product_path_list )
char **file_list;
char **product_list;
char **product_path_list;
{
#if !defined (NT)
   int                    sts, i, j, kk, len, appCount;
   int                    classinit_len = 14;
   int                    list_max, list_cnt=0;
   void                  **handle_list, *dldhandle=NULL;
   OMuword               *AtoF, save_curOS, *class_list=0;
   static char            classinit[]="_OM_class_init";
   OM_p_SPAMAPENT         p_sm;
   OM_p_CREATECLASS_ARGS  p_cc_args;
   INGR_p_PRODUCT_DEF     *prodAppVer;
   OM_p_FUNCPTR           *prodClassList;
   char                   prodAppStr[OM_K_MAXPROD_LEN+14];
   char                   prodClassStr[OM_K_MAXCLASS_LEN+19];

   if ((!file_list) || (!file_list[i=0])) {
      return (OM_E_INVARG);
   }

   /*==================================*/
   /*  dynload the given object files  */
   /*==================================*/

   while(file_list[i]) i++; /* Count the files in the file list */
   if (!(handle_list = (void **) om$calloc(num=i, size=sizeof(void *))))
      return(OM_E_NODYNMEM);
   i = j = 0;
   while ( file_list[i] ) {
      if (!dload_ctrl(GETHANDLE, file_list[i])) /* Already loaded? */
      {
         if (!(handle_list[i] = (char *) dload (file_list[i],
            OM_Gf_dload_opts | INCRLOAD)))
         {
            fprintf (stderr, "som_dload_class: Error during dload of %s\n",file_list[i]);
            return(OM_E_ERROR);
         }
         else
            j++;
      }
      ++i;
   }
   if (!j)     /* If nothing was dloaded */
      return(OM_S_SUCCESS);

   if (!(dldhandle = dload_ctrl(LOADCMPL, DLOAD_PEND, 0))) /* End of incremental dload */
      return(OM_E_ERROR);

   /*==============================*/
   /*  set global dload mode flag  */
   /*==============================*/

   OM_Gf_dload_mode = 1;

   /* class_list will accumulate classids added by dyn load */

   class_list = (OMuword *)om$malloc(size=OM_K_CLIST_SIZ*sizeof(OMuword));
   if (!class_list) {
      OM_Gf_dload_mode = 0;
      return (OM_E_NODYNMEM);
   }
   list_max = OM_K_CLIST_SIZ;

   if (product_list && product_list[0])
   {
      kk = 0;
      while(product_list[kk])
      {

#if defined (CLIX) || defined (SUNOS4)
         sprintf(prodAppStr, "_%s_appl_version", product_list[kk]);
         sprintf(prodClassStr, "_%s_class_definitions", product_list[kk]);
#elif defined (IRIX) || defined (SUNOS5)
         sprintf(prodAppStr, "%s_appl_version", product_list[kk]);
         sprintf(prodClassStr, "%s_class_definitions", product_list[kk]);
#else
#error OS not defined !!
#endif

         if (prodClassList = (OM_p_FUNCPTR *)
             dload_address_lookup(prodClassStr))
         {
            i = 0;
            while (prodClassList[i])
            {
               p_cc_args = (OM_p_CREATECLASS_ARGS) prodClassList[i]();
               if (!(1&(sts = som_create_class(p_cc_args, p_cc_args->p_class_id))))
               {
                  printf("Error during create_class (dload) for %s\n",
                          p_cc_args->s_name);
                  OM_Gf_dload_mode = 0;
                  return(sts);
               }
               if (list_cnt == list_max) {
                  list_max += OM_K_CLIST_SIZ;
                  class_list = (OMuword *)om$realloc(ptr = (char *) class_list,
                                       size = list_max*sizeof(OMuword));
                  if (!class_list) {
                     OM_Gf_dload_mode = 0;
                     return (OM_E_NODYNMEM);
                  }
               }
               class_list[list_cnt++] = *p_cc_args->p_class_id;

               i++;        /* Done with this class */
            }              /* Done with this product's classes */
         }
         if (prodAppVer = (INGR_p_PRODUCT_DEF *)
             dload_address_lookup(prodAppStr))
         {
            int   count, prevEmptyIndex, found;

            for(i = 0, appCount=OM_Gi_number_of_appl_ids;
                (appCount<MAXNUMAPPVER) && prodAppVer[i]; i++)
            {
               prevEmptyIndex = -1;
               j = found = 0;
               for(count=0; (j<MAXNUMAPPVER) && (count<appCount); j++)
               {
                  if (!OM_GA_appl_version[j])
                  {
                     prevEmptyIndex = j;
                     continue;
                  }
                  
                  count++;
                  if (!strncmp(OM_GA_appl_version[j]->curr_version,
                     prodAppVer[i]->curr_version, 8))
                  {
                     found = 1;
                     break;
                  }
               }

               if (!found)
               {
                  /* Didn't find a match */

                  if (prevEmptyIndex == -1)
                     OM_GA_appl_version[j] = prodAppVer[i];
                  else
                     OM_GA_appl_version[prevEmptyIndex] = prodAppVer[i];
                  appCount++;
               }
               else
                  OM_GA_appl_version[j] = prodAppVer[i];
            }              /* Done with this product's version stamps */
            OM_Gi_number_of_appl_ids = appCount;
         }
         kk++;          /* Done with this product */
      }
#ifdef DEBUG
{             /* for debugging the appl ver stamp list */
   int i, j;
   printf("\n\nsom_dload_class:  OM_Gi_number_of_appl_ids %d\n",
      OM_Gi_number_of_appl_ids);
   for(i=j=0; (i<MAXNUMAPPVER) && (j<OM_Gi_number_of_appl_ids); i++)
   {
      if (!OM_GA_appl_version[i])
      {
         printf("[%d]:NULL\n", i);
         continue;
      }
      j++;
      printf("[%d]:%s  0x%x\n",
         i,
         OM_GA_appl_version[i]->curr_version,
         OM_GA_appl_version[i]->appl_specifics);
   }
}
#endif
   }
   else
   {
      /*=====================================*/
      /*  call create class for new classes  */
      /*=====================================*/

      int            numsyms, n;
      struct symdef  *symbuf;
      OM_p_FUNCPTR   (ptr)();

      for (n=0; file_list[n]; n++)
      {
         if (!handle_list[n])
            continue;
         if (numsyms = dload_symbol_lookup((void *) handle_list[n],
            (char *) 0, &symbuf))
         {
            for (i=0; i<numsyms; ++i) {
               if (symbuf[i].flags != DL_TEXT)
                  continue;
               len = strlen(symbuf[i].name);
               if (len > classinit_len) {
                  if (!strcmp(&symbuf[i].name[len-classinit_len],classinit)) {
                     p_cc_args = 
                        ((OM_p_CREATECLASS_ARGS (*)()) (int) symbuf[i].value)();

                     sts = som_create_class ( p_cc_args, p_cc_args->p_class_id );
                     if (!(1&sts)) {
                        printf("Error during create_class (dload) for %s\n",
                                p_cc_args->s_name);
                        OM_Gf_dload_mode = 0;
                        return(sts);
                     }
                     if (list_cnt == list_max) {
                        list_max += OM_K_CLIST_SIZ;
                        class_list = (OMuword *)om$realloc(ptr = (char *) class_list,
                                             size = list_max*sizeof(OMuword));
                        if (!class_list) {
                           OM_Gf_dload_mode = 0;
                           return (OM_E_NODYNMEM);
                        }
                     }
                     class_list[list_cnt++] = *p_cc_args->p_class_id;
                  }
               }
            }
         } 
      }
   }

   /*========================================================*/
   /*  now update for restricted channels - p_chdef->p_type  */
   /*========================================================*/

   OM_channum_init();

#if BIG_ENDIAN
   /*
    *	Load any dictionary info before calling convert instance
    *	for the unknown objects.  We had to have the classes created
    *	before the load dictionary code would work since it puts the
    *	dictionary info into the acld.
    */
   if (product_path_list)
      for (i = 0; product_path_list[i]; ++i)
      {
         char	path[MAXPATHLEN];

         strcpy(path, product_path_list[i]);
         strcat(path, "config/class_defns");
         if (!(1&(sts = som_load_dictionary(path))))
         {
            if (class_list)
               om$dealloc(ptr=class_list);
            return sts;
         }
         strcpy(path, product_path_list[i]);
         strcat(path, "config/dload/port");
         if (!(1&(sts = som_dload_conversion_functions(path))))
         {
            if (class_list)
               om$dealloc(ptr=class_list);
            return sts;
         }
      }
#endif

   /*================================================================*/
   /*  now look for unknown objects in Spacemaps that are now known  */
   /*================================================================*/

   save_curOS = OM_Gw_current_OS;

   for (i=0; (OMuword) i<OM_Gw_maxOS; ++i) {
      if (OM_GA_OSDs[i]) {
         om$make_current_os ( osnum = i );  /* must be current for vla_fixup */
         p_sm = OM_GA_OSDs[i]->Spacemap;
         AtoF = OM_GA_OSDs[i]->ActToFil;
         for (j=0; j<OM_GA_OSDs[i]->CurSpaceMapSize; ++j) {
            if ((p_sm[j].flags & OM_SM_unknown_obj) &&
                (p_sm[j].flags & OM_SM_in_use)) {
               for (kk=0; kk<list_cnt; ++kk) {
                  if (AtoF[class_list[kk]] == (OMuword)p_sm[j].p_acld) {
                     p_sm[j].flags &= ~OM_SM_unknown_obj;
                     p_sm[j].p_acld = OM_GA_active_classes[class_list[kk]];
                     if (p_sm[j].flags & OM_SM_in_mem) {

#if defined BIG_ENDIAN
                        OMuint         size;
                        char           *p_temp;
                        OM_p_OBJECTHDR object=p_sm[j].state.object;
			OMuint         saved_ioMode = OM_Gf_ioMode;

                        if (!(p_temp = (char *) om$malloc(size=
                           (size=OM_GETOBJSIZE(object->i_size)))))
                        {
                           return(OM_E_NODYNMEM);
                        }
			OM_Gf_ioMode = READ_PORT;
			OM_Gp_inst_in = (void *)object;
			OM_Gp_inst_out = (void *)object;
                        OMPORT_CONV_INT((void *) &object->oid, 1);
                        OMPORT_CONV_INT((void *) &object->i_size, 1);
                        OM_BLOCK_MOVE((char *) object, p_temp, size);
                        if (!(1&(sts=som_convert_instance(p_temp,
                           (char *) object, p_sm[j].p_acld))))
                        {
                           fprintf(stderr, "som_dload_class: Conversion failed for class %s\n",
                              p_sm[j].p_acld->s_name);
                           om$dealloc(ptr=p_temp);
                           continue;
                        }
                        om$dealloc(ptr=p_temp);
			OM_Gf_ioMode = saved_ioMode;
#endif

                        om$vla_fixup(p_object=p_sm[j].state.object, type='r');
                     }
                     break;
                  }
               }
            }
         }
      }
   }

   om$make_current_os ( osnum = save_curOS );

   OM_Gf_dload_mode = 0;
   if (class_list)
      om$dealloc(ptr=(char *) class_list);

   return (OM_S_SUCCESS);
#else
printf("\n!! som_dload_class() is not supported on NT !!\n");
return(0);
#endif
}

/*******

int err_intrcpt_noop ( msg, sev )
char *msg;
int   sev;
{
   return (1);
}

int err_intrcpt ( msg, sev )
char *msg;
int   sev;
{
   static unres_flag = 0;

   if (!strncmp(&msg[8],"W-REDEFVAV",10)) {
      unres_flag = 0;
      return (1);
   }
   if (!strncmp(&msg[8],"W-UNRESOLV",10)) unres_flag = 1;
   
   if (sev != ERR_INFO || unres_flag) {
      fprintf(stderr,"%s",msg);
   }
   return (1);
}
*********/

#ifdef DEBUG
static int	chain_len_freq[10+1] = { 0 };
void som_dump_class_hash()
{
	int	ii;
	int	collisions = 0;
	int	entries = 0;
	int	longest_chain = 0;

	for (ii = 0; ii < OM_K_CLASS_HASH_MAX; ++ii)
	{
		char			*name;
		OM_S_CLASS_HASH_ENT	*n, *p;
		int			chain = 1;
		
		p = OM_GA_class_hash + ii;
		if (p->p_acld)
		{
			fprintf(stderr, "[%d] %s", ii, p->p_acld->s_name);
			++entries;
		}
		else
			continue;
		for (n=p->next; n; n=n->next)
		{
			++chain;
			++collisions;
			if (n->p_acld)
			{
				name = n->p_acld->s_name;
				++entries;
			}
			else
				name = "0";
			fprintf(stderr, "->%s", name);
		}
		fprintf(stderr,"\n");
		if (chain > longest_chain)
			longest_chain = chain;
		if (chain > 10)
			++chain_len_freq[0];
		else
			++chain_len_freq[chain];
	}
	fprintf(stderr,"OM_K_CLASS_HASH_MAX=%d\n", OM_K_CLASS_HASH_MAX); 
	fprintf(stderr,"entries=%d\n", entries);
	fprintf(stderr,"collisions=%d\n", collisions);
	fprintf(stderr,"\nlongest_chain=\t\t%d\n", longest_chain);
	for (ii=1; ii < 11; ++ii)
		fprintf(stderr, "%.3d chain\t%d\n", ii, chain_len_freq[ii]);
	fprintf(stderr, ">10 chain\t%d\n", chain_len_freq[0]);
	fprintf(stderr, "\nutilization=\t(%d - %d)/%d = %g\n", 
		entries, collisions, OM_K_CLASS_HASH_MAX,
		(double)(entries-collisions)/(double)OM_K_CLASS_HASH_MAX);
}
#endif
