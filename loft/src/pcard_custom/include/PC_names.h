/****************************************************************/
/*								*/
/*		PcTools library		         		*/
/*								*/
/*	contains functions for naming operations                */
/*								*/
/*		Maciej Jablkowski 				*/
/*								*/
/*		Intergraph, February 2000			*/
/*								*/
/****************************************************************/
/*
  02-18-2000	get_obj_name
                put_obj_name
                change_obj_name

*****************************************************************/

#ifndef MJNAMES_H_INCLUDED
#define MJNAMES_H_INCLUDED 1

//#define TOOLS_DEBUG


/*
=========================================================
int get_obj_name( char        *name, 
                  struct GRid object );
=========================================================

    This function is used to get name of given object:

    char        *name    O : name of object

    struct GRid object   I : object to get the name from
*/
get_obj_name( name, object )
/**************************/
char		*name;
struct GRid	object;
{
  IGRlong	stat, msg;

  stat = ci$send( msg = message GRvg.GRgetname( &msg,
                                                name ),
                  targetid = object.objid,
                  targetos = object.osnum );
  as$status( sts = stat );
  if( !( stat & 1 ) )
  { 
    printf( "GET_NAME failed (%d[%d])\n", object.objid, object.osnum );
    return( 1 );
  }
  return (0);
}
/*
=========================================================
int put_name( char        *name, 
              struct GRid object );
=========================================================

    This function is used to put name of given object:

    char        *name    I : name of object

    struct GRid object   I : object to get the name from
*/
put_obj_name( name, object )
/**********************/
char		*name;
struct GRid	object;
{
  IGRlong	stat, msg;

  stat = ci$send( msg = message GRvg.GRputname( &msg,
                                                name ),
                  targetid = object.objid,
                  targetos = object.osnum );
  as$status( sts = stat );
  if( !( stat & 1 ) )
  { 
    printf( "PUT_NAME failed (%d[%d])\n", object.objid, object.osnum );
    return( 1 );
  }
  return (0);
}
/*
=========================================================
int change_name( char            *name, 
                 struct GRmd_env env,
                 struct GRid     object );
=========================================================

    This function is used to change name of given object:

    char        *name    I : name of object

    struct GRmd_env env  I : module environment of object

    struct GRid object   I : object to get the name from
*/
change_obj_name( name, env, object )
/******************************/
char		*name;
struct GRmd_env env;
struct GRid	object;
{
  IGRlong	stat, msg;

  stat = ci$send( msg = message GRvg.GRchgname( &msg,
                                                &env,
                                                name ),
                  targetid = object.objid,
                  targetos = object.osnum );
  as$status( sts = stat );
  if( !( stat & 1 ) )
  { 
    printf( "CHANGE_NAME failed (%d[%d])\n", object.objid, object.osnum );
    return( 1 );
  }
  return (0);
}

#endif
