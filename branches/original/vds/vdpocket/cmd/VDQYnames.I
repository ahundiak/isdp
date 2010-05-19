/* $Id: VDQYnames.I,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/cmd / VDQYnames.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDQYnames.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.20  1996/01/10  20:54:44  pinnacle
# Replaced: vdpocket/cmd/VDQYnames.I for:  by yzhu for vds.240
#
# Revision 1.19  1995/09/14  22:42:02  pinnacle
# Replaced: vdpocket/cmd/VDQYnames.I for:  by yzhu for vds.240
#
# Revision 1.18  1995/09/04  19:30:58  pinnacle
# Replaced: vdpocket/cmd/VDQYnames.I for:  by yzhu for vds.240
#
# Revision 1.17  1995/08/30  15:42:34  pinnacle
# Replaced: vdpocket/cmd/VDQYnames.I for:  by yzhu for vds.240
#
# Revision 1.16  1995/07/24  19:00:30  pinnacle
# Replaced: vdpocket/cmd/VDQYnames.I for:  by hverstee for vds.240
#
# Revision 1.15  1995/05/01  14:36:26  pinnacle
# Replace: vdpocket/cmd/VDQYnames.I by yzhu for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdQYnpt;

#include <memory.h>
#include <malloc.h>
#include <string.h>
#ifndef NT
#include <sys/param.h>
#else
#include <stdlib.h>
#define MAXPATHLEN _MAX_PATH
#endif

#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMspecify.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDQYdef.h"
#include "growner.h"
#include "vdparmacros.h"
#include "DIquery.h"
#include "bsmalloc.h"
#include "VDmem.h"
#include "v_dbgmacros.h"

/* #define DEBUG  1  */ 
%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int my_strcmp __((char **p_st1, char **p_st2));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


from ACmacro_defn import ACgive_feet_desc;
from ACrg_collect import AClist_attribute;

static my_strcmp ( p_st1, p_st2 )
                   char **p_st1, **p_st2;
{
  	return strcmp ( *p_st1, *p_st2 );
}


/****************************************************************************/
VDQYget_macro_names ( names, count )
                    char ***names	/* The macro names		OUT */;
                    int  *count		/* The number of macros		OUT */;
/*
   This function returns the valid macros of the current design file.
*/
{
  OM_S_CLASSLIST     class_list;
  int                i, status;
  OMuword            macro_def_clid;
  static char        **macro_names = 0;
  struct GRmd_env    md_env;
  IGRlong	     msg, NumberOfBytes, BytesReceived;
  static int         nb_macros = 0;
  IGRchar	     regexp[DI_PATH_MAX];

        SetProc( VDQYget_macro_names ); Begin
  	/* free the previous list */
  	if (nb_macros)
  	{
    		for (i = 0; i < nb_macros; i++) {
                   _FREE(macro_names [i] );    
                        macro_names[i] = NULL;    
                }
                _FREE(macro_names); 
                	macro_names = NULL;         
    		nb_macros = 0;
  	}
  
  	/* get the list of valid macros */
  	class_list.w_flags = OM_CLST_subclass;
  	class_list.w_count = 1;
  	status = om$get_classid ( classname = "ACcpx_defn", 
                            p_classid = &macro_def_clid );
  	if (status != OM_S_SUCCESS)
    	return status;
  	class_list.p_classes = &macro_def_clid;

  	NumberOfBytes = sizeof(md_env);
  	gr$get_module_env( msg    = &msg,
		    sizbuf = &NumberOfBytes,
		    buffer = &md_env,
		    nret   = &BytesReceived);

  	if(!(msg&1)) return OM_E_ABORT;
  	status = di$give_pathname(	pathname = regexp,
				osnum = md_env.md_id.osnum);
  	if (status != 1)
    		return status;
  	strcat(regexp,":constructs_lib:*:constructs:*");

       	macro_names = NULL;         
  	status = 
        di$dump ( regexp = regexp,
                     lines = &macro_names,
                     ptr = &nb_macros,
                     p_classes = &class_list,
                     options = 0 );
  	if (status != OM_S_SUCCESS)
    	return status;

  	for (i = 0; i < nb_macros; i++)
    	di$split ( pathname = macro_names [i], name = macro_names [i] );
    
  	/* let's sort the list */
  	qsort ( (char *)macro_names, (unsigned)nb_macros, sizeof ( char * ), 
                 	(int (*) ())my_strcmp);

  	*names = macro_names;
  	*count = nb_macros;
        End
  	return OM_S_SUCCESS;
}
/*********************************************************************
 History:
    10/6/94 	yzhu     modified it for mutiple query choise
**********************************************************************/
method set_locate_eligible( IGRlong * msg )
{
IGRint                  status = OM_S_SUCCESS ;
OMuword                 idClassList[200];
OM_S_CLASSLIST          *locEligible = NULL;
IGRint                  i,j;
IGRchar                 wholeqrystr[8*QUERY_LEN];
IGRint                  qry_count;
IGRchar                 **querylist;
IGRchar                 **query_class_name;
IGRint                  cl_count;
IGRlong                 sts;
OMuword                 my_os1;
OM_S_OBJID              my_id1;
struct GRmd_env         my_env1;
IGRint                  syntax1;
IGRint                  listnum = 200;
IGRlong                 msg1;
IGRlong                 NumberOfBytes,
                        BytesReceived;
IGRchar                 **classname;
IGRint                  count;
IGRint                  k, found_flag;
IGRint                  Maxword;

	SetProc( set_locate_eligible ); Begin

        *msg = MSSUCC;
        sts  = MSSUCC;
        qry_count  = 0;
        my_os1 = 0;
        my_id1 = 0;
        syntax1 = 1;
      
        
        NumberOfBytes = sizeof(my_env1);
        BytesReceived = 0;
        gr$get_module_env(      msg    = &msg1,
                                sizbuf = &NumberOfBytes,
                                buffer = &my_env1,
                                nret   = &BytesReceived);
 
         

        querylist = NULL;
        listnum   = Qrylistnum;
        VDmalloc_str_list(&querylist, listnum, Qrylistlen);

        strcpy(wholeqrystr, me->buffercontent1);
        /* get seperate query */ 
        VDQYget_individual_query(	wholeqrystr,
					&querylist,
					listnum,
					&qry_count );

        /*
	 * Check each of the queries and accept only the valid one to
	 * process. VDDIprocess_query calls the syntax parser and returns
	 * >= 0 when TRUE.
	 * VDQYget_query_names reads the parser buffer and sort the seclected
	 * classes or macro names.
         */
        cl_count  = 0;
        query_class_name = NULL;
        VDmalloc_str_list(&query_class_name, Qrynamenum, Qrynamelen);

        for( j=0; j<qry_count; j++ ){

          if( VDDIprocess_query(	querylist[j],
                                	&my_os1,
                               	 	&my_id1,
                                	&my_env1,
                                	syntax1 ) >= 0 ){

             VDQYget_query_names(	&query_class_name,
					&cl_count);
          }
        }

        __DBGpr_int(" cl_count of query_class_name ", cl_count);

	/*
	 * initialization of the locate eligibility clases.
	 */
        locEligible = &me->locate_eligible_thing ;
        locEligible->w_count = 0;
        locEligible->w_flags = OM_CLST_subclass;

        /*
         * get the class information from the query string.
         */
        for( i=0 ; i<cl_count; i++ ){
           found_flag = FALSE;
	  /*
	   * first Check if name corresponds with an existing classname.
	   */
          status =
          om$get_classid(classname = query_class_name[i],
                         p_classid = &idClassList[locEligible->w_count] );
          if( status&1 ){
		/*
		 * increment the list.
		 */
                locEligible->w_count++;
                /*
                 * special case for route
                 */
                if(!(strcmp(query_class_name[i], "VRHComp"))) {
                   status =
                   om$get_classid(classname = "VRHCorentity",
                         p_classid = &idClassList[locEligible->w_count] );
                   if( status&1 ){
                         locEligible->w_count++;
                   }
                }
                if(!(strcmp(query_class_name[i], "VRPComp"))) {
                   status =
                   om$get_classid(classname = "VRPCorentity",
                         p_classid = &idClassList[locEligible->w_count] );
                   if( status&1 ){
                         locEligible->w_count++;
                   }
                }
                if(!(strcmp(query_class_name[i], "VRCComp"))) {
                   status =
                   om$get_classid(classname = "VRRCorentity",
                         p_classid = &idClassList[locEligible->w_count] );
                   if( status&1 ){
                         locEligible->w_count++;
                   }
                }
          }
          else{
		/*
		 * check query_class_name[i] against MacClsStr
                 * there are two cases: 
                 *  a: get class name from macro name like PPccdef, HVccdef
                 *  b: get class name from macro name with wildcard
                 */ 
		count = 0;
  		Maxword = 80;

  		classname = NULL ;

  		status =
  		VDqry_macroclassname(	query_class_name[i], 
					NULL, 
                                      	&count);

                __DBGpr_int(" match count of query_class_name ", count);

		if( count ){

  		  VDmalloc_str_list(	&classname, count, Maxword );

  		  status =
  		  VDqry_macroclassname(	query_class_name[i], 
                                        &classname, 
                                        &count );
                      
                  if(status){
        	    for( k=0 ; k<count; k++ ){
                      status =
                      om$get_classid(
                             classname = classname[k],
                             p_classid = &idClassList[locEligible->w_count] );
                      if( status&1 ){
                              locEligible->w_count++;
                              found_flag = TRUE;
               	      }
                    }
                  }

		  /*
		   * Free classname buffer.
		   */
		  VDfree_str_list(classname, count);

		} /* if (count) */

                if( !found_flag ) { /*test if it is existing macro name */ 
	          /*
		   * check if name correspond with an existing macro in
                   * macro labrary. the regular expression can be used.
                   * we set all macro objects as ACcpx class.  
		   */
                  status =
                  vd$qry_check_macro(	msg  = &msg1,
                                        name = query_class_name[i] );
                  if( ! (status&msg1&1) ){
                    continue;
                  }
                  else{
		    /*
		     * set the default macro subclass for macro.
		     */
                    status =
                    om$get_classid(
                              classname = "ACcpx",
                              p_classid = &idClassList[locEligible->w_count] );
                    if( status&1 ){
                              locEligible->w_count++;
                    } 
                  }
              }  
	  }  /*if( !(status&1)) */  
          /* 
           * consider VSimgFeature, if first two char of query_class name 
           * are VS, add VSfeature as an locEligible class, we use macro 
           * name to select relative VSimgFeature because the image of 
           * VSstfbeam has same macro name and diff class name.  
           */
          
          if (query_class_name[i][0] == 'V' &&
              query_class_name[i][1] == 'S' ) {
 
           __DBGpr_com(" add VSfeature class to be loc eligible");
           status =   
           om$get_classid(
                              classname = "VSfeature",
                              p_classid = &idClassList[locEligible->w_count] );
                    if( status&1 ){
                    	      locEligible->w_count++;
                    } 
          }

           
	  /*
	   * check on buffer limitations.
	   */
          if( locEligible->w_count > 200 )  {
/*		printf(" locEligible cannot be more than 200\n"); */
                break;
          }     
        } /* end for */

	/*
	 * set the found classes into the locate eligibility structure.
	 */

		
        if ( locEligible->w_count ) {

          	status =
          	om$vla_set_dimension(
			varray  = me->eligible_classids,
                        size    = locEligible->w_count );

          	for( i=0 ; i<locEligible->w_count ; i++ ){
                  	me->eligible_classids[i] = idClassList[i] ;
                }
          	locEligible->p_classes    = me->eligible_classids ;
          	me->locate_eligible       = locEligible;
        }
		
	
	me->form_display_flag = 1; /* make form non display */

       /*
	* free allocations
	*/

       VDfree_str_list(querylist, listnum);
       VDfree_str_list(query_class_name, Qrynamenum);

       End
       return OM_S_SUCCESS;

} /* set_locate_eligible */

/*********************************************************************
 History:
    10/6/94     yzhu     created for get individual query from combined
                         query string
 note:
      querylist sholde be malloc and free in calling function:

       querylist = NULL;
       listnum   = Qrylistnum;
       VDmalloc_str_list(&querylist, listnum, Qrylistlen);

        VDQYget_individual_query(	wholeqrystr,
					&querylist,
					listnum,
					&qry_count );
       VDfree_str_list(querylist, listnum);

**********************************************************************/
VDQYget_individual_query( wholeqrystr, querylist, listmax, qry_count )
IGRchar         *wholeqrystr;                   /* int */
IGRchar         ***querylist;                    /* out */
IGRint		listmax;			/* int */
IGRint          *qry_count;                     /* out */
{
IGRchar                 tmp[8*QUERY_LEN],
                        ttmp[8*QUERY_LEN],
                        *ptr1 = NULL,
                        ttmp1[8*QUERY_LEN];
IGRint                  len,j;

        SetProc( VDQYget_individual_query ); Begin
        /* 
         * max number of querylist is 200. querylist should be free 
         * in call function 
         */  

        tmp[0]	='\0';
        ttmp[0] ='\0';

        j = 0;
        strcpy( ttmp, wholeqrystr);
        len = strlen(ttmp);

        while( len != NULL){
            ptr1 = strchr(ttmp,';');
            if(ptr1 == NULL) break;
            else{
                len = len - strlen(&ptr1[0]) + 1;
                strncpy(ttmp1,ttmp,len);
                ttmp1[len] = '\0';
                strcpy( (*querylist)[j],ttmp1);
                                   /* ttmp1: fisrt part of ttmp */
                j = j + 1;
                ttmp1[0] = '\0';
                strcpy( ttmp, &ptr1[1]);
                                     /* ttmp: second part of ttmp */
                len = strlen(ttmp);

		if( j >= listmax ) break ;
            }
        } /* end while */

        *qry_count = j;
        End
        return 1;

} /* get_individual_query */

end implementation VDCmdQYnpt;
