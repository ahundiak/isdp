#ifndef GRprims
#define GRprims
/*
---------------------------------------------------------------------------

	Name:			GRprims.h
	Author:			Henry Bequet
	Creation Date:		May-02-1988
	Operating System(s):	Unix SYSV, v2

	Abstract:
        ---------
        	The following GRoup 0.0 "primitives" are actually "macros"
	which are operated on by the OM pre-processor.  Their purpose,
 	usage, and format are described in more detail in the 
 	"GRoup 0.0 User Writeup".

		Basically, this file contains macros of the form:

	#omdef gr$<function_name> ( <parameters> ) 

      	   ... 
            	
	#endomdef
	
       
        Notes:
        ------

        
	--- Standard names ---
	This list has standard names to use for things
	like object space number (osnum). This will provide an 
    	assurance of a standard interface. It is not complete, and
	should be updated as new names appear in macros.

	class name			classname
	class id			classid
        pointer to classid              p_classid
        pointer to class list           p_classes
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
	pointer	(int *)			ptr

        GRoup name (char *)             groupname
        path name (char *)              pathname
        GRoup object id                 groupid
        pointer to groupid              p_groupid
        execution status (long *)       sts
        osnum + objid			grid
        pointer to grid			grids
        oldpasswd			the old group passwd
        newpasswd			the new group passwd

        Error Codes :
        -------------

        The following error codes are returned by the GRoup sub-system.
        They are defined in the GRdef.h file.


        Dependance :
        ------------

        This file depends on the following file :

                        GRdef.h
                        GRtypedef.h
          

	Revision History:               05/05/1988 - Creation Date
        -----------------               

---------------------------------------------------------------------------*/
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

extern void GRDisableValidate __(());
extern void GREnableValidate __(());
extern int GRadd_group __((GRchar *groupname, GRint type, GRchar *passwd));
extern int GRcg __((GRchar *groupname, GRchar *passwd, GRspacenum *p_osnum,
		GRobjid *p_groupid, GRint *p_groupind, GRint flag));
extern int GRchange_group __((GRchar *objname, GRobjid objid,
		GRspacenum osnum, GRobjid new_gr_id, GRchar *new_gr_name,
		GRchar *new_passwd, GRchar *old_passwd));
extern int GRchange_passwd __((GRchar *name, GRchar *old_passwd,
		GRchar *new_passwd));
extern int GRinit __((void));
extern int GR_match __((GRchar *candidate, GRchar *crypted, GRchar *salt));
extern int GRpasswd __((GRchar *passwd, GRchar *crypted, GRchar *salt));
extern int GRpwg __((GRchar *groupname, GRobjid *p_groupid,
		GRspacenum *p_osnum, GRint *p_groupind));
extern int GRreport_error __((GRint status, GRchar *comment));
extern int GRvalidate __((GRint type, GRint groupind));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------------------*/


/* This macro is used to display an error message corresponding to
   the specified status.

   return status :
                      GR_S_SUCCESS : successful operation

      Argument description :
      --------------------

        GRint  sts       : the status					(IN)
        GRchar *comment  : a comment to be printed with   		(IN)
                           the error message
*/

#omdef gr$report_error ( sts, comment = NULL )
       GRreport_error ( sts, comment )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to add a group name in the GRoup sub-system 

   return status :
                      GR_S_SUCCESS : successful operation
                      GR_E_NAME_DUP: name duplicated
                      GR_E_OVFLOW  : overflow error
                      GR_E_ABORT   : GRoup error

      Argument description :
      --------------------

        GRchar *groupname       : the name of the group       		(IN)
        
        GRchar *passwd		: the pass word of the group		(IN)

        GRint  type		: the type of the group			(IN)
*/

#omdef gr$add_group ( groupname, 
                      type,
                      passwd )
       GRadd_group ( (groupname), (type), (passwd)  )
#endomdef

/*---------------------------------------------------------------------------*/


/* This macro is used to remove a group name in the GRoup sub-system 

   return status :
                      GR_S_SUCCESS : successful operation
                      GR_E_OVFLOW  : overflow error
                      GR_E_ABORT   : GRoup error

      Argument description :
      --------------------

        GRchar *groupname       : the name of the group to be removed	(IN)
*/

#omdef gr$rm_group ( groupname )
       DIR_W_NOT_IMPL
#endomdef

/*---------------------------------------------------------------------------*/


/* This macro is used to validate an operation.

   return status :
                   GR_S_SUCCESS         : operation is valid
                   GR_E_PRIVATE		: the group is private
                   GR_E_READ_ONLY	: the group is read only
                   GR_E_ABORT           : GRoup error

      Argument description :
      --------------------

	GRchar     type		: the type of the operation		(IN)

        GRint      groupind	: the group index the operation has	(IN)
                                  to be validated for.
*/

#omdef gr$validate (  type,
                      groupind = me->index )
       GRvalidate ( (type), (groupind) )
#endomdef

/*---------------------------------------------------------------------------*/

/* This macro returns the current GRoup.  The name is returned in 
   groupname, the objid in p_groupid and the osnum in p_osnum.  Note that
   each argument may be NULL if no value has to be returned.

   return status :
                   GR_S_SUCCESS : successful operation
                   GR_E_ABORT   : GRoup error

      Argument description :
      --------------------

        GRchar *groupame      : the name of the current			(OUT)
		                GRoup

        GRobjid *p_groupid    : the current GRoup objid			(OUT)
        
        GRspacenum *p_osnum   : the current GRoup object		(OUT)
                                space number

        GRint *p_groupind     : the current GRoup index			(OUT)
        
*/ 

#omdef gr$pwg ( p_groupid  = (GRobjid *) NULL,
                p_groupind = (GRint *) NULL,
                p_osnum    = (GRspacenum *) NULL,
                groupname  = (GRchar *) NULL )
       GRpwg ( (groupname), (p_groupid), (p_osnum), (p_groupind) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to change the current GRoup.  It may return the
   osnum and objid of the new current GRoup.

   return status :
                   GR_S_SUCCESS : successful operation
                   GR_E_OVFLOW  : overflow error
                   GR_E_ABORT   : GRoup error

      Argument description :
      --------------------

        GRchar *groupname    : the name of the GRoup to be  		(IN)
		               the current one

        GRchar *passwd	     : the passwd of the GRoup to be  		(IN)
		               the current one

        GRspacenum *p_osnum  : the object space number of the   	(OUT)
                               new current GRoup

        GRobjid *p_groupid   : the new current GRoup objid		(OUT)
        
        GRint *p_groupind    : the new current GRoup index		(OUT)
        
        GRint flag           : the previous GRoup name    		(IN)
*/

#omdef gr$cg ( groupname,
               passwd     = (GRchar *) NULL,
               p_groupid  = (GRobjid *) NULL,
               p_groupind = (GRint *) NULL,
               p_osnum    = (GRspacenum *) NULL,
	       flag       = 0 )
       GRcg ( (groupname), (passwd), (p_osnum),
              (p_groupid), (p_groupind), (flag) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to change the passwd of a group.

   return status :
                   GR_S_SUCCESS : successful operation
                   GR_E_OVFLOW  : overflow error
                   GR_E_ABORT   : GRoup error

      Argument description :
      --------------------

        GRchar *groupname    	: the name of the GRoup to be updated	(IN)

        GRchar *old_passwd	: the name of the old group passwd	(IN)

        GRchar *new_passwd    	: the name of the new group passwd	(IN)

*/

#omdef gr$change_passwd ( groupname,
                          old_passwd,
                          new_passwd )
       GRchange_passwd ( (groupname), (old_passwd), (new_passwd) )
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to initialize the directory structure for use with
   the group protection scheme.

   return status :


      Argument description :
      --------------------


*/

#omdef gr$init ()
       GRinit  ()
#endomdef


/*---------------------------------------------------------------------------*/


/* This macro is used to change an object's group.

   return status :
                   GR_S_SUCCESS : successful operation
                   GR_E_INVARG  : invalid argument
                   GR_E_ABORT   : GRoup error

      Argument description :
      --------------------

        GRchar     *objname    	: name of the object to alter		(IN)

        GRobjid    objid    	: objid of the object to alter 		(IN)

        GRspacenum osnum    	: osnum of the object to alter		(IN)

        GRint      new_gr_id    : objid of new group  {OPTIONAL}	(IN)

        GRchar     *new_gr_name : name of new group   {OPTIONAL}	(IN)

        GRchar     *new_passwd  : passwd of new group {OPTIONAL}	(IN)

        GRchar     *old_passwd  : passwd of old group 			(IN)

*/

#omdef gr$change_group ( objname = NULL,
                         objid = NULL_OBJID,
                         osnum = OM_Gw_current_OS,
                         new_gr_id = NULL,
                         new_gr_name = NULL,
                         new_passwd = NULL,
                         old_passwd = NULL )
       GRchange_group ( (objname), (objid), (osnum), (new_gr_id),
			(new_gr_name), (new_passwd), (old_passwd) )
#endomdef


/*---------------------------------------------------------------------------*/

#endif
