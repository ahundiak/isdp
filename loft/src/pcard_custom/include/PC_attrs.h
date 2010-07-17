/****************************************************************/
/*								*/
/*		PcTools library		         		*/
/*								*/
/*	contains functions for attributes mgmt		        */
/*								*/
/*		Maciej Jablkowski 				*/
/*								*/
/*		Intergraph, February 2000			*/
/*								*/
/****************************************************************/
/*
   02-18-2000   print_ACrg_coll     
                get_usr_attrs
                put_usr_attrs
                set_usr_attrs
                mod_usr_attrs       
                get_usr_attr        
                get_named_attr      
                set_usr_attr        
                print_ret_str
                fprint_ret_str
                
*****************************************************************/

#ifndef MJATTRS_H_INCLUDED
#define MJATTRS_H_INCLUDED 1

//#define TOOLS_DEBUG

#define USR_ATTR_LIST_SIZE 	30
#define STR 			1
#define DBL 			2



/*========================================================

  ==========================================================*/



/*
=========================================================
int print_ACrg_coll( struct ACrg_coll *list,
		     int              attr_count )
=========================================================

    This function is used to print the list of user
    attributes:

    struct ACrg_coll *list_ptr    I : pointer to the 
                                      attributes list

    int attr_count                I : number of attributes 
                                      in list;
*/
print_ACrg_coll( list, count )
/****************************/
struct ACrg_coll	*list;
int			count;
{
  int i;
  char *types[2];

  types[0] = (char *) malloc (6*sizeof(char));
  types[1] = (char *) malloc (6*sizeof(char));
  strcpy( types[0], "string" );
  strcpy( types[1], "double" );
  for( i = 0; i < count; i = i + 1 )
  {
    printf( "Attrib [%6s]: %15s ", types[list[i].desc.type-1], list[i].name );
    if( list[i].desc.type == 1 )
      printf( " : %s\n", list[i].desc.value.att_txt );  
    else if( list[i].desc.type == 2 )
      printf( " : %f\n", list[i].desc.value.att_exp );  
  }
}  



/*
=========================================================
int get_usr_attrs( struct ACrg_coll *list_ptr,
		   int              *attr_count,
                   struct GRid      object );
=========================================================

    This function is used to get the list of user
    attributes attached to object:

    struct ACrg_coll *list_ptr    O : pointer to the 
                                      attributes list

    int *attr_count             I/O : expected number of
                                      attributes in list;
                                      returns number retrieved

    struct GRid object            I : object to get 
                                      attributes from
*/
get_usr_attrs( list_ptr, attr_count, object )
/*******************************************/
struct ACrg_coll *list_ptr;
int		 *attr_count;  
struct GRid	 object;
{
  IGRlong 	stat, msg;
  int		 num_ret;
  struct GRid 	foot;

  stat = ci$send( msg = message VSfeature.VSgetUsrAttributes( &msg, &foot ),
                  targetid = object.objid,
                  targetos = object.osnum );
  stat = ci$send( msg = message ACrg_collect.AClist_attribute( 	&msg,
								*attr_count,
                                                		list_ptr,
								&num_ret ),
                  targetid = foot.objid,
                  targetos = foot.osnum );
  if( !( stat & 1 ) )
  {
    printf("GET_USR_ATTRS failed (cannot get list ptr)\n");
    return(1);
  }
  *attr_count = num_ret;
  return( 0 );
}



/*
=========================================================
int put_usr_attrs( struct ACrg_coll *list_ptr,
		   int              attr_count,
                   struct GRid      object );
=========================================================

    This function is used to add the list of user
    attributes to existing usrAttrBox attached to
    object:

    struct ACrg_coll *list_ptr    I : pointer to the 
                                      attributes list

    int attr_count                I : expected number of
                                      attributes in list

    struct GRid object            I : object to get 
                                      attributes from
*/
put_usr_attrs( list_ptr, attr_count, object )
/*******************************************/
struct ACrg_coll *list_ptr;
int		 attr_count;  
struct GRid	 object;
{
  IGRlong 	stat, msg;
  struct GRid   foot;

  stat = ci$send( msg = message VSfeature.VSgetUsrAttributes( &msg, &foot ),
                  targetid = object.objid,
                  targetos = object.osnum );
  if( !( stat & 1 ) )
  {
    printf("PUT_USR_ATTRS failed (%d[%d])\n", object.objid, object.osnum);
    return(1);
  }
  stat = ci$send( msg = message ACrg_collect.ACadd_list_attribute( &msg,
								attr_count,
                                                		list_ptr ),
                  targetid = foot.objid,
                  targetos = foot.osnum );
    if( !( stat & 1 ) )
    {
      printf("PUT_USR_ATTRS failed (cannot get list ptr)\n");
      return(1);
    }
  return( 0 );
}



/*
=========================================================
int set_usr_attrs( struct ACrg_coll *list_ptr,
		   int              attr_count,
                   struct GRid      object );
=========================================================

    This function is used to kill existing list of attributes
    and attach the new list of user attributes to object:

    struct ACrg_coll *list_ptr    I : pointer to the 
                                      attributes list

    int attr_count                I : expected number of
                                      attributes in list

    struct GRid object            I : object to get 
                                      attributes from
*/
set_usr_attrs( list_ptr, attr_count, object )
/*******************************************/
struct ACrg_coll *list_ptr;
int		 attr_count;  
struct GRid	 object;
{
  IGRlong	stat, msg;
  struct GRid   foot;

  stat = ci$send( msg = message VSfeature.VSgetUsrAttributes( &msg, &foot ),
                  targetid = object.objid,
                  targetos = object.osnum );
  if( !( stat & 1 ) )
  {
    printf("SET_USR_ATTRS failed (%d[%d])\n", object.objid, object.osnum);
    return(1);
  }
  stat = ci$send( msg = message ACrg_collect.ACset_list_attribute( &msg,
								attr_count,
                                                		list_ptr ),
                  targetid = foot.objid,
                  targetos = foot.osnum );
  if( !( stat & 1 ) )
  {
    printf("SET_USR_ATTRS failed (cannot get list ptr)\n");
    return(1);
  }
  return( 0 );
}



/*
=========================================================
int mod_usr_attrs( struct ACrg_coll *list_ptr,
		   int              attr_count,
                   struct GRid      object );
=========================================================

    This function is used to modify the list of user
    attributes attached to object:

    struct ACrg_coll *list_ptr    I : pointer to the 
                                      attributes list

    int attr_count                I : expected number of
                                      attributes in list

    struct GRid object            I : object to get 
                                      attributes from
*/
mod_usr_attrs( list_ptr, attr_count, object )
/*******************************************/
struct ACrg_coll *list_ptr;
int		 attr_count;  
struct GRid	 object;
{
  IGRlong 	stat, msg;
  struct GRid 	foot;

  stat = ci$send( msg = message VSfeature.VSgetUsrAttributes( &msg, &foot ),
                  targetid = object.objid,
                  targetos = object.osnum );
  if( !( stat & 1 ) )
  {
    printf("MOD_USR_ATTRS failed (%d[%d])\n", object.objid, object.osnum);
    return(1);
  }
  stat = ci$send( msg = message ACrg_collect.ACmod_list_attribute( &msg,
								attr_count,
                                                		list_ptr ),
                  targetid = foot.objid,
                  targetos = foot.osnum );
  if( !( stat & 1 ) )
  {
    printf("MOD_USR_ATTRS failed (cannot get list ptr)\n");
    return(1);
  }
  return( 0 );
}
/*
=========================================================
int get_usr_attr( char        *value_ptr,
		  char        *name,
                  struct GRid object );
=========================================================

    This function is used to get the named user
    attribute from list attached to object:

    char *value_ptr              O : pointer to needed value

    char *name		         I : name of attribute

    struct GRid object           I : object to get 
                                     attributes from
*/
get_usr_attr( value_ptr, name, object )
/*******************************************/
char 		*value_ptr;
char 		*name;
struct GRid	object;
{
  IGRlong 	stat, msg;
  int		i, count;
    
  struct GRid           foot;
  struct ACrg_coll      attr[USR_ATTR_LIST_SIZE];
   
  msg=0;
  count = USR_ATTR_LIST_SIZE;
  msg = get_usr_attrs( attr, &count, object );
  if( msg )
  {
    printf("GET_USR_ATTR failed (cannot get named attr ptr)\n");
    return( 1 );
  }
  i = 0;
  while( i < count )
  {
    if( !strcmp( name, attr[i].name ) )
    {
      switch( attr[i].desc.type )
      {
        case STR : 
          strcpy( value_ptr, attr[i].desc.value.att_txt ); 
          break;
        case DBL : 
          *(double *)value_ptr = attr[i].desc.value.att_exp;
          break;
        default :
          printf("GET_USR_ATTR: Bad type of parameter\n");
          return(1);
          break;                   
      }
      return(0);
    }
    i = i + 1;
  }
  printf("GET_USR_ATTR failed (attr of name <%s> does not exist)\n", name);
  return( 1 );
}



/*
=========================================================
int get_named_attr( char        	*name,
	 	    struct ACrg_coll    *list_ptr,
                    struct GRid 	 object );
=========================================================

    This function is used to get the named attribute from 
    the list of user attributes attached to object:

    char             *name      I  : name of attribute

    struct ACrg_coll *list_ptr I/O : list pointer

    struct GRid object          I  : object to get 
                                     attributes from
*/
get_named_attr( name, list_ptr, object )
/*******************************************/
char             *name;
struct ACrg_coll *list_ptr;
struct GRid	 object;
{
  IGRlong 	stat, msg;
  struct GRid 	foot;

  stat = ci$send( msg = message VSfeature.VSgetUsrAttributes( &msg, &foot ),
                  targetid = object.objid,
                  targetos = object.osnum );
  if( !( stat & 1 ) )
  {
    printf("MOD_USR_ATTRS failed (%d[%d])\n", object.objid, object.osnum);
    return(1);
  }
  strcpy( list_ptr->name, name );
  stat = ci$send( msg = message ACrg_collect.ACget_named_attribute( &msg,
                                                		list_ptr ),
                  targetid = foot.objid,
                  targetos = foot.osnum );
  if( !( stat & 1 ) )
  {
    printf("MOD_USR_ATTRS failed (cannot get list ptr)\n");
    return(1);
  }
  return( msg );
}



/*
=========================================================
int set_usr_attr( char             *name,
                  int               type,
		  double           *value,
                  struct GRid       object );
=========================================================

    This function is used to add or create if neccessary
    an attribute of 'name' and 'value' to object:

    char        *name      I : name of attribute to be added

    int          type      I : type of value
 
    double      *value     I : value of attribute

    struct GRid  object    I : object to add attributes to
*/
set_usr_attr( name, type, value, object )
/***************************************/
char         *name;
int           type;
char         *value;
struct GRid   object;
{
  struct ACrg_coll list[1];

  if( type <1 && type>2 )
    return(1);

  strcpy( list[0].name, name );

  if( get_named_attr( name, list, object ) )
  {

#ifdef TOOLS_DEBUG
    printf("MODIFYING %s with %f\n", name, value );
#endif

    list[0].desc.type = type;

    if( type == 1 )
      strcpy( list[0].desc.value.att_txt, value );
    else
      list[0].desc.value.att_exp = (double) *value;

    return( mod_usr_attrs( list, 1, object ) );
  }
  else
  {

#ifdef TOOLS_DEBUG
    printf("CREATING %s with %f\n", name, value );
#endif

    list[0].desc.type = type;

    if( type == 1 )
      strcpy( list[0].desc.value.att_txt, value );
    else
      list[0].desc.value.att_exp = (double) *value;

    return( put_usr_attrs( list, 1, object ) );
  }   
  return(0);
}


/*
=========================================================
void print_ret_str( struct ret_struct	rst )
=========================================================

    This function is used to print the contetnts of
    given ret_struct.

    struct ret_struct	rst	I : given ret_struct
*/
char * print_ret_str( rst )
struct ret_struct   rst;
{
  char ret_line[80];

  if( rst.type & point_generic )
  {
    sprintf( ret_line,  "Point [%lf, %lf, %lf]\n", rst.var.point_st.pt[0],
                  rst.var.point_st.pt[1], rst.var.point_st.pt[2] );
    printf("%s\n", ret_line );
  }
  else
  if( rst.type & ref_generic )
  {
    sprintf( ret_line,  "CS [%lf, %lf, %lf, etc]\n", rst.var.ref_st.t[0],
                  rst.var.ref_st.t[1], rst.var.ref_st.t[2] );
    printf("%s\n", ret_line );
  }
  else
  if( rst.type & line_generic )
  {
    sprintf( ret_line,  "Line Segment [%lf, %lf, %lf][%lf, %lf, %lf]\n", 
                  rst.var.line_st.p0[0],
                  rst.var.line_st.p0[1], rst.var.line_st.p0[2], 
                  rst.var.line_st.p1[0],
                  rst.var.line_st.p1[1], rst.var.line_st.p1[2] );
    printf("%s\n", ret_line );
  }
  else
  if( rst.type & parameter_generic )
  {
    sprintf( ret_line,  "Parameter " );
    if( rst.type == double_type )
      sprintf( ret_line,  "%s%lf\n", ret_line, rst.var.root_pm_st.value );
    if( rst.type == text_type )
      sprintf( ret_line,  "%s%lf\n", ret_line, rst.var.text_st.text_string );
    printf("%s\n", ret_line );
  }
  else
  if( rst.type & conic_generic )
  {
    if( rst.type == circle_type )
      sprintf( ret_line,  "Circle ");
    if( rst.type == arc_type )
      sprintf( ret_line,  "Arc ");
    sprintf( ret_line,  "%s[%lf, %lf, %lf] R=%lf\n", ret_line,
             rst.var.circle_st.cent_p[0],
             rst.var.circle_st.cent_p[1], rst.var.circle_st.cent_p[2],
             rst.var.circle_st.rad );
    printf("%s\n", ret_line );
  }
  else
  if( rst.type & macro_generic )
  {
    sprintf( ret_line,  "Macro \"%s\" of type %d\n", rst.var.macro_st.name,
                  rst.var.macro_st.hdr_type );
    printf("%s\n", ret_line );
  }
  else
  if( rst.type & class_generic )
  {
    sprintf( ret_line,  "Class \"%s\"\n", rst.var.class_st.name );
    printf("%s\n", ret_line );
  }
  else
  if( rst.type & debug_type )
  {
    sprintf( ret_line,  "Debug data\n" );
    printf("%s\n", ret_line );
  }
  else 
  if( rst.type & lbs_generic )
  {
    sprintf( ret_line,  "Local bounded system\n" );
    printf("%s\n", ret_line );
  }
  else 
  if( rst.type & curve_generic )
  {
    sprintf( ret_line,  "Curve\n" );
    printf("%s\n", ret_line );
  }
  else 
  if( rst.type & surface_generic )
  {
    sprintf( ret_line,  "Surface\n" );
    printf("%s\n", ret_line );
  }
  else 
  if( rst.type & solid_generic )
  {
    sprintf( ret_line,  "Solid\n" );
    printf("%s\n", ret_line );
  }
  else 
  if( rst.type & set_generic )
  {
    sprintf( ret_line,  "Set of elements\n" );
    printf("%s\n", ret_line );
  }
  else 
  if( rst.type & other_generic )
  {
    sprintf( ret_line,  "Unknown type\n" );
    printf("%s\n", ret_line );
  }
  return( NULL );
}

/*
=========================================================
void fprint_ret_str( struct ret_struct	rst,
                    FILE               *fp )
=========================================================

    This function is used to print the contetnts of
    given ret_struct.

    struct ret_struct	rst	I : given ret_struct
    FILE               *fp      I : output file pointer
*/

void fprint_ret_str( rst, fp )
struct ret_struct   rst;
FILE               *fp;
{
  if( rst.type & point_generic )
    fprintf( fp, "Point [%lf, %lf, %lf]\n", rst.var.point_st.pt[0],
                  rst.var.point_st.pt[1], rst.var.point_st.pt[2] );
  else
  if( rst.type & ref_generic )
    fprintf( fp, "CS [%lf, %lf, %lf, etc]\n", rst.var.ref_st.t[0],
                  rst.var.ref_st.t[1], rst.var.ref_st.t[2] );
  else
  if( rst.type & line_generic )
    fprintf( fp, "Line Segment [%lf, %lf, %lf][%lf, %lf, %lf]\n", 
                  rst.var.line_st.p0[0],
                  rst.var.line_st.p0[1], rst.var.line_st.p0[2], 
                  rst.var.line_st.p1[0],
                  rst.var.line_st.p1[1], rst.var.line_st.p1[2] );
  else
  if( rst.type & parameter_generic )
  {
    fprintf( fp, "Parameter " );
    if( rst.type == double_type )
      fprintf( fp, "%lf\n", rst.var.root_pm_st.value );
    if( rst.type == text_type )
      fprintf( fp, "%lf\n", rst.var.text_st.text_string );
  }
  else
  if( rst.type & conic_generic )
  {
    if( rst.type == circle_type )
      fprintf( fp, "Circle ");
    if( rst.type == arc_type )
      fprintf( fp, "Arc ");
    fprintf( fp, "[%lf, %lf, %lf] R=%lf\n", rst.var.circle_st.cent_p[0],
             rst.var.circle_st.cent_p[1], rst.var.circle_st.cent_p[2],
             rst.var.circle_st.rad );
  }
  else
  if( rst.type & macro_generic )
    fprintf( fp, "Macro \"%s\" of type %d\n", rst.var.macro_st.name,
                  rst.var.macro_st.hdr_type );
  else
  if( rst.type & class_generic )
    fprintf( fp, "Class \"%s\"\n", rst.var.class_st.name );
  else
  if( rst.type & debug_type )
    fprintf( fp, "Debug data\n" );
  else 
  if( rst.type & lbs_generic )
    fprintf( fp, "Local bounded system\n" );
  else 
  if( rst.type & curve_generic )
    fprintf( fp, "Curve\n" );
  else 
  if( rst.type & surface_generic )
    fprintf( fp, "Surface\n" );
  else 
  if( rst.type & solid_generic )
    fprintf( fp, "Solid\n" );
  else 
  if( rst.type & set_generic )
    fprintf( fp, "Set of elements\n" );
  else 
  if( rst.type & other_generic )
    fprintf( fp, "Unknown type\n" );
  return;
}
  

#endif
