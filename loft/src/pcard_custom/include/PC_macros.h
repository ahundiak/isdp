/****************************************************************/
/*								*/
/*		mj_macros library		         	*/
/*								*/
/*	contains functions for macros & classes		        */
/*								*/
/*		Maciej Jablkowski 				*/
/*								*/
/*		Intergraph, February 2000			*/
/*								*/
/****************************************************************/
/*
   02-18-2000	get_macro_name
                get_macro_params    
                get_macro_template
		get_macro_foot
                get_temp_struct
		get_foot_struct	
                get_str_attr
                get_template_idx
                get_classname
                classcmp
                struct_classcmp
*****************************************************************/

#ifndef MJMACROS_H_INCLUDED
#define MJMACROS_H_INCLUDED 1

#include "AS_status.h"
#include "vdAPIequips.h"


//#define TOOLS_DEBUG

#define CI_EXEC(F, V, N)  ci$exec( file_id = &(F), \
         load    = 0,     \
         delete  = 0,     \
         retval  = &(V), \
         retsize = sizeof(IGRlong), \
         entry   = (N) )


/*
=========================================================
int get_macro_name( char 	** macro_name,
                    struct GRid  * macro_defn
                    struct GRid	   macro );
=========================================================

    This function is used to retrieve name of macro 

    char	  ** macro_name	  O : macro_name

    struct GRid    * macro_defn   O : macro definition

    struct GRid      macro	  I : occurance object
*/
get_macro_name( macro_name, macro_defn, macro_occ )
/*************************************************/
char            **macro_name;
struct GRid 	 *macro_defn;
struct GRid	  macro_occ;
{
  IGRlong status;

  status = ci$send( msg = message ACcpx.find_macro( macro_defn ),
                    targetid = macro_occ.objid,
                    targetos = macro_occ.osnum );
  as$status( sts = status );
  if( !( status & 1 ) )
  { 
    printf( "GET MACRO NAME: ACcpx.find_macro failed (%d[%d])\n", 
            macro_occ.objid, macro_occ.osnum );
    return( 1 );
  }

  status = ci$send( msg = message ACcpx_defn.ACgive_name( macro_name ),
                    targetid = macro_defn->objid,
                    targetos = macro_defn->osnum );

#ifdef TOOLS_DEBUG
  printf("GET_MACRO_NAME: Got name : %s\n", *macro_name ); 
#endif

  as$status( sts = status );
  if( !( status & 1 ) )
  { 
    printf( "GET MACRO NAME: ACcpx_defn.ACgive_name failed (%d[%d])\n", 
            macro_defn->objid, macro_defn->osnum );
    return( 1 );
  }
  return(0);
}
/*
=========================================================
int get_macro_params( char 		** macro_name,
                      struct stemp 	** temps,
		      struct myfeet	** feet,
		      int		 * temp_num,
		      int		 * feet_num,
                      struct GRid	   obj );
=========================================================

    This function is used to retrieve numbers and
    names of macro feet and templates of occurance
    'obj'.

    char	   * macro_name	  O : macro_name

    struct stemp  ** temps	  O : template names 

    struct myfeet ** feet	  O : feet names
 
    int            * temp_num	  O : number of templates

    int		   * feet_num	  O : number of feet

    struct GRid      obj	  I : occurance object
*/
get_macro_params( macro_name, temps, feet, temp_num, feet_num, obj )
/*****************************************************************/
char            **macro_name;
struct stemp 	**temps;
struct myfeet 	**feet;
int		*temp_num;
int		*feet_num;
struct GRid	 obj;
{
  IGRlong 	status;
  struct GRid 	macro;

  get_macro_name( macro_name, &macro, obj );
  status = ci$send( msg = message ACcpx_defn.ACgive_temp_desc( temp_num, 
                                                               temps ),
                    targetid = macro.objid,
                    targetos = macro.osnum );
  as$status( sts = status );
  if( !( status & 1 ) )
  { 
    printf( "GET MACRO PARAMS: ACcpx_defn.ACgive_temp_desc failed (%d[%d])\n", 
            obj.objid, obj.osnum );
    return( 1 );
  }

  status = ci$send( msg = message ACcpx_defn.ACgive_feet_desc( feet_num,
                                                               feet ),
                    targetid = macro.objid,
                    targetos = macro.osnum );
  as$status( sts = status );
  if( !( status & 1 ) )
  { 
    printf( "GET MACRO PARAMS: ACcpx_defn.ACgive_feet_desc failed (%d[%d])\n", 
            obj.objid, obj.osnum );
    return( 1 );
  }
  return(0);
}
/*
=========================================================
int get_macro_template( char 		 * temp_name,
                        struct GRid	 * object,
			struct GRid 	   occurance );
=========================================================

    This function is used to retrieve an objid
    of template of given name

    char	   * temp_name	  I : temp_name

    struct GRid    * template_obj O : template object

    struct GRid      occurance    I : occurance object
*/
get_macro_template( temp_name, template_obj, occurance )
/************************************************/
char 		* temp_name;
struct GRid 	* template_obj;
struct GRid       occurance;
{
    IGRlong status, msg;

    status = ci$send( msg = message ACcpx.ACfind_temp_obj( &msg, temp_name,
                                                           template_obj ),
                      targetid = occurance.objid,
                      targetos = occurance.osnum );
    as$status( sts = status );
    if( !( status & 1 ) ) {
        printf( "GET_MACRO_TEMPLATE: ACcpx.ACfind_temp_obj failed (%d[%d])\n",
                occurance.objid, occurance.osnum );
        return( 1 );
    }
    if( template_obj->objid == 0 ) {
        printf( "GET_MACRO_TEMPLATE returned %d[%d] as template of %d[%d]\n",
                template_obj->objid,
                template_obj->osnum,
                occurance.objid,
                occurance.osnum );
        return(1);
    }
    return(0);
}
/*
=========================================================
int get_macro_foot( char 	** foot_name,
                    struct GRid	 * object,
                    struct GRid    occurance );
=========================================================

    This function is used to retrieve an objid
    of foot of given name

    char	   * foot_name	  I : foot_name

    struct GRid    * foot_obj	  O : foot object

    struct GRid      occurance    I : occurance object
*/
get_macro_foot( foot_name, foot_obj, occurance )
/********************************************/
char 		* foot_name;
struct GRid 	* foot_obj;
struct GRid       occurance;
{
    IGRlong status, msg;

    status = ci$send( msg = message NDmacro.ACreturn_foot( &msg, foot_name,
                                                           foot_obj, NULL, NULL ),
                      targetid = occurance.objid,
                      targetos = occurance.osnum );
    as$status( sts = status );
    if( !( status & 1 ) )
    {
        printf( "GET MACRO FOOT: NDmacro.ACreturn_foot failed (%d[%d])\n",
                occurance.objid, occurance.osnum );
        return( 1 );
    }
    return(0);
}
/*
=========================================================
int get_temp_struct( struct ret_struct  * struct_ptr,
                     char               * temp_name,
                     struct GRmd_env      env,
                     struct GRid          object );
=========================================================

    This function is used to get template attribute
    of given macro occurance:

    struct ret_struct *struct_ptr O : pointer to
                                      attribute struct

    char * temp_name              I : name of template

    struct GRmd_env env           I : module environment

    struct GRid object            I : object to get its
                                      template struct
*/
get_temp_struct( struct_ptr, temp_name, env, object )
/***************************************************/
struct ret_struct * struct_ptr;
char              * temp_name;
struct GRmd_env     env;
struct GRid         object;
{
    IGRlong   stat, msg;

    stat = ci$send( msg = message ACcpx.ACfind_temp_struct( &msg,
                                                            temp_name,
                                                            struct_ptr,
                                                            &env ),
                    targetid = object.objid,
                    targetos = object.osnum );
    as$status( sts = stat );
    if( !( stat & 1 ) )
    {
        printf( "GET_TEMP_STRUCT: ACcpx.ACfind_temp_struct failed (%d[%d])\n",
                object.objid, object.osnum );
        return( 1 );
    }
}
/*
=========================================================
int get_foot_struct( struct ret_struct 	* struct_ptr,
	      	     char 		* foot_name,
              	     struct GRmd_env      env,
	      	     struct GRid 	  object );
=========================================================

    This function is used to get foot attribute
    of given macro occurance:

    struct ret_struct *struct_ptr O : pointer to 
				      attribute struct

    char * foot_name		  I : name of foot
 
    struct GRmd_env env           I : module environment

    struct GRid object            I : object to get its
				      foot struct
*/
get_foot_struct( struct_ptr, foot_name, env, object )
/***************************************************/
struct ret_struct * struct_ptr;
char              * foot_name;
struct GRmd_env     env;
struct GRid         object;
{
  IGRlong	 stat, msg, index;

  index = -1;
  stat = ci$send ( msg = message NDmacro.ACgive_structure( &msg,
                                                        &index,
                                                        foot_name,
                                                        struct_ptr,
                                                        &env),
                  targetid = object.objid,
                  targetos = object.osnum );
#ifdef DEBUG
  //printf("Printing ret_struct:\n");
  //print_ret_str( *struct_ptr );
#endif

  as$status( sts = stat );
  if( !( stat & 1 ) )
  { 
    printf( "GET_FOOT_STRUCT: NDmacro.ACgive_structure failed (%d[%d])\n", 
            object.objid, object.osnum );
    return( 1 );
  }
}

/*
=========================================================
int get_str_attr( struct ret_struct * attr_ptr,
	      char 		* attr_name,
              struct GRmd_env     env,
	      struct GRid 	  object );
=========================================================

    This function is used to get dynamic attribute
    of given structural object.

    struct ret_struct *attr_ptr   O : pointer to 
				      attribute struct

    char * attr_name		  I : name of attribute
 
    struct GRmd_env env           I : module environment

    struct GRid object            I : object to get its
				      attribute
*/
get_str_attr( attr_ptr, attr_name, env, object )
/******************************************/
struct ret_struct * attr_ptr;
char              * attr_name;
struct GRmd_env     env;
struct GRid         object;
{
  return( get_foot_struct( attr_ptr, attr_name, env, object ) );
}
/*
=========================================================
int get_template_idx( struct GRid *template_obj, 
                      struct GRid  object,
                      IGRshort     index);
=========================================================

    This function is used to get the template_obj
    of a given object at index position in template list:
    
    struct GRid *template_obj O : template_obj

    struct GRid object        I : object

    IGRshort                  I : template_obj index
*/
get_template_idx( template_obj, object, index )
/*********************************************/
struct GRid 	*template_obj;
struct GRid	object;
IGRshort        index;
{
  IGRlong	msg, stat;

  stat = ci$send( msg = message ACcpx.ACfind_exp_temp_obj( &msg,
                                                           index,
                                                           template_obj ),
                  targetid = object.objid,
                  targetos = object.osnum );
  as$status( sts = stat );
  if( !( stat & 1 ) )
  {
    printf("GET_SRC failed (%d[%d])\n",object.objid,object.osnum);
    return( 1 );

  }
  if( template_obj->objid == 0 )
  {
    printf( "GET_MACRO_TEMPLATE returned %d[%d] as template of %d[%d]\n",
            template_obj->objid,
            template_obj->osnum,
            object.objid,
            object.osnum );
    return(1);
  }
  return( 0 );
}

/*----------------------------------------------------------------------------
 * Function returns class name of object 
 *----------------------------------------------------------------------------*/

get_classname( classname, object )
char * classname;
struct GRid object;
{

  om$get_classname( objid     = object.objid,
                    osnum     = object.osnum,
                    classname = classname );
  return;
}


/*----------------------------------------------------------------------------
 * Function returns result of object class comparison
 *----------------------------------------------------------------------------*/

int classcmp( classname, object )
  char         *classname;
  struct GRid   object;
{

  IGRchar ObjectClassname[30];
  
  get_classname( ObjectClassname, object );

  return( strcmp( classname, ObjectClassname ));
}

/*----------------------------------------------------------------------------
 * Function checks if given object is a structural one.
 *----------------------------------------------------------------------------*/

int struct_classcmp( object )
  struct GRid   object;
{
  
  IGRchar classname[30], *ptr;
  
  printf("STRUCT CLASSCMP\n");
  
  get_classname( classname, object );

  if( strstr( classname, "VS") == NULL )
    return(1);

  if( strstr( classname, "Beam") == NULL && strstr( classname, "Plate") == NULL )
    return(1);
  
  return( 0 );
  
}

/*----------------------------------------------------------------------------
 * Function gets word w with index n from string s separated by sep.
 *----------------------------------------------------------------------------*/

set_coll_obj( coll, object, index )
/****************************************/
struct VDcollector *coll;
struct GRobj_env    object;
       IGRint       index;
{
  IGRlong sts, msg;



  sts = vd$collectorSetRow ( msg = &msg,
                             idx = index,
                             Col = coll,
                             Obj = &object.obj_id,
                             Env = &object.mod_env );
  as$status ( sts    = sts,
              msg    = "vd$collectorSetRow()",
              test   = (!(sts & 0x00000001 & msg)),
              action = GOTO_VALUE,
              value  = wrapup );
wrapup:
	vd$collectorFree (Col = coll);
	return (sts);
}

/*----------------------------------------------------------------------------
 * Function gets word w with index n from string s separated by sep.
 *----------------------------------------------------------------------------*/

set_coll_val( coll, value, index )
/****************************************/
struct VDcollector *coll;
       IGRdouble    value;
       IGRint       index;
{
  IGRlong sts, msg;

  sts = vd$collectorSetRow ( msg = &msg,
                             idx = index,
                             Col = coll,
                             Val = &value );
  as$status ( sts    = sts,
              msg    = "vd$collectorSetRow()",
              test   = (!(sts & 0x00000001 & msg)),
              action = GOTO_VALUE,
              value  = wrapup );
wrapup:
	return (sts);
}

set_coll_txt( coll, txt, index )
/****************************************/
struct VDcollector *coll;
       IGRchar     *txt;
       IGRint       index;
{
  IGRlong sts, msg;

  sts = vd$collectorSetRow ( msg = &msg,
                             idx = index,
                             Col = coll,
                             Txt = txt );
  as$status ( sts    = sts,
              msg    = "vd$collectorSetRow()",
              test   = (!(sts & 0x00000001 & msg)),
              action = GOTO_VALUE,
              value  = wrapup );
wrapup:
	return (sts);
}

#endif
