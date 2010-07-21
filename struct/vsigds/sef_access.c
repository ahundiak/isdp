/* ----------------------------------------
 * 21 Jul 2010
 * Hardcode this for now
 */
#define _ENVELOPE_AR_ 1

/* begin ifdefs for underbars */
#ifndef _CLIX_P_
#define    stripins_                           stripins
#endif
/* end   ifdefs for underbars */

/* begin ifdefs for underbars */
#ifndef _CLIX_P_
#define    check_ranges_                       check_ranges
#define    roundup_                            roundup
#define    exp_sh_                             exp_sh
#define    form_range_                         form_range
#endif
/* end   ifdefs for underbars */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#define	on_vax	0
#include <malloc.h>
#include <fcntl.h>
#include "sysdata.h"
#include "idenvelope.h"
#include "logfile.h"

#include "cl_type.h"

#if vax
 static	char	log_file_name[8]="log.dat";
#else
 static char	log_file_name[64]={0};
#endif

#include "cl_severe.h"

		int		log_to_stdout;

		char		rewrite_entire_cmp = 0;

static		int		compoffset, compsize, compactive_file;

static 		int		sef_file_desc[2] = { -1 , -1 };
static		short		key_length = 8, zero = 0;
static		int		no_offset = 0 , one = 1, beginning = 0;
key_dgn		kd[2];		/* [O]= set a , [1] = set b		*/
key_dgn		kd_scan[2];	/* [O]= set a , [1] = set b		*/
key_sys		ks;
key_cmp		kc[2];		/* [0] = set a , [1] = set b		*/
key_cmp		kc_scan[2];	/* [0] = set a , [1] = set b		*/
key_shp		ksp[2];
key_shp		kh[2];
key_shp		kp;
static		short		file_access_mode;	/*0=read , 1=create */
static		short		active_file=0; 	/* index to file_desc   */

static		short		num_cmp[2] = {0 , 0};
static		short		num_shp[2] = {0 , 0};
static		short		num_soft_shp[2] = {0 , 0};
static		short		num_exp_shp[2] = {0 , 0};
static		short		num_hole[2] = {0 , 0};
static		short		num_exp_hole[2] = {0 , 0};
static		char		data_reservoir[2] = {1,1};  /* 1=data in reservoir only,0=file open write,2=file open read*/
static		char		log_on = 0;			
static		char		first_sef_write;

/*	int		static		file_size= 0;	*/

/*	struct 		mallinfo 	mi;		*/

static		int		current_position , last_position , buffer_index , next_buffer_index;
static		short		next_record_length;
static		char		last_buffer;
static		key_shp		*active_primitive[2];
static		char		sef_downloading=0;
static		char	        sef_interactive_env=0;


set_interactive_env( inter )
char	*inter;
{
  sef_interactive_env = *inter;
}


SEF_CMP_SIZE( c )
  component_data	*c;
{
  static	short	bytes_before_cp_data = 168; 	/* does not include keys */

  switch ( c->su.size[5] )			/* size[5] = cp_type   */
    {
    case 1 :								/* pipe */
      return ( bytes_before_cp_data + 98 );	
    case 2 :								/* piping components */
      return ( bytes_before_cp_data + ( sizeof(cp_record) * c->su.size[6] ) );
    case 3 :								/* structure */
      return ( bytes_before_cp_data + ( 12 * c->su.size[6] ) );		/* size[6]=no_cp  */
    case 4 :								/* line route */
      return ( bytes_before_cp_data + 25  );
    case 5 :								/* structure */
      return ( bytes_before_cp_data + ( 12 * c->su.size[6] ) + ( 8 * c->su.size[7] ) );		/* size[7]=no_lcp  */
    case 6 :								/* eqp space for pointer */
      return ( bytes_before_cp_data + 25  );
    default :						/* no connect point data specified, therefore no space */
      return ( bytes_before_cp_data );			/* for cp_data will be allocated 		       */
    }
}



SEF_SHAPE_SIZE( s )
  basic_shape_data	*s;
{
  static short	bytes_before_shape = 32; 	/* does not include keys */

  switch ( s->su.size[1] )			/* size[1] = shape type   */
    {
    case 1 :
      return ( bytes_before_shape + sizeof( cyl ) );
    case 2 :
      return ( bytes_before_shape + sizeof( cone ) );
    case 3 :
      return ( bytes_before_shape + sizeof( torus ) );
    case 4 :
      return ( bytes_before_shape + 60 + (s->geom.projected_shape.pu.ps_no_point * 12)     );
    case 5 :
      return ( bytes_before_shape + sizeof( semi_ell ) );
    case 6 :
      return ( bytes_before_shape + 88 + (s->geom.revolved_shape.pu.rs_no_point * 12)     );
    case 8 :
      return ( bytes_before_shape + 12 + (s->geom.cylindrical_string.pu.cs_no_point * 12)     );
    case 9 :
      return ( bytes_before_shape + sizeof( bs_header ) );
    default :
      return ( 0 );
    }

}


#ifndef _ENVELOPE_AR_
SEF_SET_LOG_NAME( log_name )
char	*log_name;
{
 sprintf( log_file_name , "%s" , log_name );
}
#endif
#ifndef _ENVELOPE_AR_
SEF_SET_LOG_STDOUT(  )
{

 log_to_stdout = 1;
}
#endif

#ifndef _ENVELOPE_AR_
SEF_SET_LOG( log_switch )
char	*log_switch;
{
 static	char 	log_open = 0;

 char	*tmp_path;

 log_to_stdout = 0;

 log_on = *log_switch;
 if ( log_on && ( log_open == 0) ) 
   {
   if( strlen(log_file_name) == 0 )
     {
     tmp_path = ( char * ) pds_get_tmp_dir( );
     sprintf( log_file_name , "%slog.dat" , tmp_path );
     }
   log_file = fopen( log_file_name, "w" );
   fprintf( log_file , " -------------Log File Opened--------------\n " );
#ifdef _CLIX_P_
   chmod( log_file_name , S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH );
#else
   _chmod( log_file_name , S_IWRITE );
#endif
   log_open = 1;
   }
 else if ( ( log_on == 0 ) && ( log_open == 1) )	/* close it */ 
   {
   fprintf( log_file , " -------------Log File Closed--------------\n " );
   fclose ( log_file );
   log_open = 0;
#ifndef _CLIX_P_
   transform_clix_file_to_nt( log_file_name );
#endif
   }

}
#endif
#ifndef _ENVELOPE_AR_
SEF_READ_NEXT_RECORD( first, buffer )

char    *first;
short	*buffer;
{
/*  static	char internal_buffer[3072];	*/
/*  static	int  internal_buffer_size = 3072; */
  static	char internal_buffer[8192];
  static	int  internal_buffer_size = 8192; /* optimum for FFS */
  static	int  backup;
  static	int  num_bytes_read;
  static	short 	zero=0, two=2;
  static	short  record_length, index_of_nrl;
  if ( *first ) 
    {
    last_buffer = 0;
    last_position = lseek( sef_file_desc[active_file], no_offset, beginning );
    *first = 0;
    lib$movc5( &zero, &zero, &zero, &internal_buffer_size, internal_buffer );		
    num_bytes_read = read( sef_file_desc[active_file], internal_buffer, internal_buffer_size );

/*    pos = lseek( sef_file_desc[active_file] , no_offset , one );	*/

    if ( num_bytes_read < internal_buffer_size )
      last_buffer = 1;
    current_position = num_bytes_read;
    buffer_index = 0;
    next_buffer_index = 0;
    memcpy( &next_record_length , &internal_buffer[buffer_index+key_length] , two );
    next_record_length = next_record_length + key_length;
    }
  else
    {
    next_buffer_index = buffer_index + next_record_length;
    if (( last_buffer ) && ( next_buffer_index > num_bytes_read ))
      {
      lib$movc5( &zero, &zero, &zero, &internal_buffer_size, internal_buffer );		
      record_length = 0;
      return ( record_length );
      }
    if ( next_buffer_index > internal_buffer_size ) 
      {
      current_position = lseek( sef_file_desc[active_file], no_offset, one);
      backup = (current_position - ( last_position + buffer_index)) *(-1);
      current_position = lseek( sef_file_desc[active_file], backup, one);
      last_position = current_position;
      lib$movc5( &zero, &zero, &zero, &internal_buffer_size, internal_buffer );		
      num_bytes_read = read( sef_file_desc[active_file], internal_buffer, internal_buffer_size );

/*      pos = lseek( sef_file_desc[active_file] , no_offset , one ); 	*/

      if ( num_bytes_read < internal_buffer_size )
        {
	if ( num_bytes_read == 0 ) 
          {
          lib$movc5( &zero, &zero, &zero, &internal_buffer_size, internal_buffer );		
          record_length = 0;
          return ( record_length );
          }
	else
          {
          last_buffer = 1;
          }
        }
      buffer_index = 0;
      next_buffer_index = 0;
      memcpy( &next_record_length , &internal_buffer[buffer_index+key_length] , two );
      next_record_length = next_record_length + key_length;
      }
    }
  record_length = next_record_length;
  if ( record_length < 0 )
    {
    return( -1 );	/* garbage */
    }

  memcpy( buffer , &internal_buffer[buffer_index] , record_length );
  index_of_nrl = buffer_index + record_length + key_length;
  if ( index_of_nrl < ( internal_buffer_size - 1 ) )
    memcpy( &next_record_length , &internal_buffer[ index_of_nrl ], two );
  else
    next_record_length = internal_buffer_size;
  next_record_length = next_record_length + key_length;
  buffer_index = buffer_index + record_length;
  return ( record_length );		/* number of bytes in buffer */
}
#endif



#ifndef _ENVELOPE_AR_
SEF_READ_NEXT_BS_DATA( buffer , buffer_size )

int	*buffer;
int 	*buffer_size;
{

  static	int     backup;
  static	int     num_bytes_read;
  static	int  	pos;
  static	int	local_buffer_size;

 last_buffer = 0;
 local_buffer_size = *buffer_size;
 current_position = lseek( sef_file_desc[active_file], no_offset, one);
 backup = (current_position - ( last_position + buffer_index)) *(-1);
 current_position = lseek( sef_file_desc[active_file], backup, one);
 last_position = current_position;

/*	 lib$movc5( &zero, &zero, &zero, &internal_buffer_size, internal_buffer );		*/

 num_bytes_read = read( sef_file_desc[active_file], buffer, local_buffer_size );

 pos = lseek( sef_file_desc[active_file] , no_offset , one ); 	/* temporary - for debug only	*/

 current_position = lseek( sef_file_desc[active_file], no_offset, one);
 last_position = current_position;
 buffer_index = 0;
 next_buffer_index = 30000;		/* greater than internal buffer size , to set up read next record */
 next_record_length = 30000;
 if ( num_bytes_read < local_buffer_size )
   return( -1 );
 else
   return ( num_bytes_read );		/* number of bytes in buffer */
}
#endif



#ifndef _ENVELOPE_AR_
SEF_READ_CMP( dgn_no, cmp_no, comp ) 		/* reads comp from memory */
short		*dgn_no;
short		*cmp_no;
component_data	*comp;
{
  static	int		size;
  key_cmp	*ac;
  int		size_before_lcp , lcp_size;
  char		*temp , *temp2;

  active_file = (*dgn_no) - 1;
  if ( *cmp_no == 1 ) 
    {
    if ( kd[active_file].first_comp == 0 ) 
      return (-1);
    ac = kd[active_file].first_comp;
    size = ac->cmp_dat.su.size[0];
    size = size + 80;
    memcpy( &kc[active_file] , kd[active_file].first_comp , size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_READ_CMP *************************************\n " );
      L_K_COMP( kd[active_file].first_comp );
      }
*/

    kd[active_file].active_comp = kd[active_file].first_comp;
    }
  else
    {
    kd[active_file].active_comp = kc[active_file].next_key_cmp;
    if ( kd[active_file].active_comp == 0 )
      return ( -1);
    ac = kd[active_file].active_comp;
    size = ac->cmp_dat.su.size[0];
    size = size + 80;
    memcpy( &kc[active_file] , kd[active_file].active_comp, size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_READ_CMP *************************************\n " );
      L_K_COMP( kd[active_file].active_comp );
      }
*/
    }
  size = kc[active_file].cmp_dat.su.size[0];
  if( kc[active_file].cmp_dat.su.size[5] == 5 ) 	/* mpc */
    {
    size_before_lcp = 168 + ( kc[active_file].cmp_dat.su.size[6] * 12 );
    memcpy( comp , &kc[active_file].cmp_dat , size_before_lcp );
    lcp_size = kc[active_file].cmp_dat.su.size[7] * 8 ;
    temp = ( char * ) &comp->cp_data.mpc_cmp.lcp[0][0];
    temp2 = ( char * ) &kc[active_file].cmp_dat;
    temp2 = temp2 + size_before_lcp;
    memcpy( temp , temp2 , lcp_size );
    }
  else
    {
    memcpy( comp , &kc[active_file].cmp_dat, size );
    };
  num_exp_shp[active_file] = 0;
  num_exp_hole[active_file] = 0;
  return 1;
}
#endif


#ifndef _ENVELOPE_AR_
sef_read_cmp_overlap( in_range , dgn_no , cmp_no , comp , overlap ) 	
int		*in_range;
short		*dgn_no;
short		*cmp_no;
short		*overlap;
component_data	*comp;
{
  static	int		size;
  key_cmp	*ac;
  int		size_before_lcp , lcp_size;
  char		*temp , *temp2;
  static	key_cmp		*kc_p;

  active_file = (*dgn_no) - 1;
  if ( *cmp_no == 1 ) 
    {
    if ( kd[active_file].first_comp == 0 ) 
      return (-1);
    ac = kd[active_file].first_comp;

/*
    size = ac->cmp_dat.su.size[0];
    size = size + 80;
    memcpy( &kc[active_file] , kd[active_file].first_comp , size );
*/
    kc_p = kd[active_file].first_comp;

    kd[active_file].active_comp = kd[active_file].first_comp;
    }
  else
    {
/*  kd[active_file].active_comp = kc[active_file].next_key_cmp; */
    kd[active_file].active_comp = kc_p->next_key_cmp;
    if ( kd[active_file].active_comp == 0 )
      return ( -1);
    ac = kd[active_file].active_comp;

/*
    size = ac->cmp_dat.su.size[0];
    size = size + 80;
    memcpy( &kc[active_file] , kd[active_file].active_comp, size );
*/
    kc_p = kd[active_file].active_comp;

    }

  check_ranges_( in_range , ac->cmp_dat.ru.range    , overlap );
  if( *overlap == 1 ) 
    {

    size = ac->cmp_dat.su.size[0];
    size = size + 80;
    memcpy( &kc[active_file] , kd[active_file].active_comp, size );

    size = kc[active_file].cmp_dat.su.size[0];
    if( kc[active_file].cmp_dat.su.size[5] == 5 ) 	/* mpc */
      {
      size_before_lcp = 168 + ( kc[active_file].cmp_dat.su.size[6] * 12 );
      memcpy( comp , &kc[active_file].cmp_dat , size_before_lcp );
      lcp_size = kc[active_file].cmp_dat.su.size[7] * 8 ;
      temp = ( char * ) &comp->cp_data.mpc_cmp.lcp[0][0];
      temp2 = ( char * ) &kc[active_file].cmp_dat;
      temp2 = temp2 + size_before_lcp;
      memcpy( temp , temp2 , lcp_size );
      }
    else
      {
      memcpy( comp , &kc[active_file].cmp_dat, size );
      }
    }
  num_exp_shp[active_file] = 0;
  num_exp_hole[active_file] = 0;
  return 1;
}
#endif


#ifndef _ENVELOPE_AR_
SEF_SCAN_CMP( dgn_no, cmp_no, comp ) 		/* scans comp from memory */
short		*dgn_no;
short		*cmp_no;
component_data	*comp;
{
  static	int		size;
  key_cmp	*ac;

  active_file = (*dgn_no) - 1;
  if ( *cmp_no == 1 ) 
    {
    if ( kd_scan[active_file].first_comp == 0 ) 
      return (-1);
    ac = kd_scan[active_file].first_comp;
    size = ac->cmp_dat.su.size[0];
    size = size + 80;
    memcpy( &kc_scan[active_file] , kd_scan[active_file].first_comp , size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_SCAN_CMP *************************************\n " );
      L_K_COMP( kd[active_file].first_comp );
      }
*/
    kd_scan[active_file].active_comp = kd_scan[active_file].first_comp;
    }
  else
    {
    kd_scan[active_file].active_comp = kc_scan[active_file].next_key_cmp;
    if ( kd_scan[active_file].active_comp == 0 )
      return ( -1);
    ac = kd_scan[active_file].active_comp;
    size = ac->cmp_dat.su.size[0];
    size = size + 80;
    memcpy( &kc_scan[active_file] , kd_scan[active_file].active_comp, size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_SCAN_CMP *************************************\n " );
      L_K_COMP( kd_scan[active_file].active_comp );
      }
*/
    }
  size = kc_scan[active_file].cmp_dat.su.size[0];
  memcpy( comp , &kc_scan[active_file].cmp_dat, size );
  return 1;
}
#endif


#ifndef _ENVELOPE_AR_
SEF_SCAN_CMP_LID( dgn_no, ent , occ , comp ) 	/* scans comp from memory */
short		*dgn_no;
short		*ent;
int		*occ;
component_data	*comp;
{
  int		locc;
  short		cmp_no;
  short		lent;

  lent = *ent;
  locc = *occ;
  active_file = (*dgn_no) - 1;
  cmp_no = 1;
  while ( SEF_READ_CMP( dgn_no , &cmp_no , comp ) == 1 )
    {
    if(( comp->su.size[3] == lent ) && ( comp->nu.cmp_no[1] == locc))  
      {
      return( 1 );
      }
    cmp_no = cmp_no + 1;
    }
  return( 0 );
  }
#endif


#ifndef _ENVELOPE_AR_
SEF_WRITE_EXP_PRIM_RANGE( dgn_no , xrange )
short			*dgn_no;
int			*xrange;
{
  int		*temp;
  int		size;

  active_file = (*dgn_no) - 1;
  temp = ( int * )  ( &active_primitive[active_file]->ru.xrange[0] );
  size = 24;
  memcpy( temp , xrange , size );
  return 1;
} 
#endif
#ifndef _ENVELOPE_AR_
SEF_WRITE_NONEXP_RANGE( dgn_no , xrange )
short			*dgn_no;
int			*xrange;
{
  key_cmp 	*ac;
  int		*temp;
  int		size;

  active_file = (*dgn_no) - 1;
  ac = kd[active_file].active_comp;
  temp = ( int * )  ( &ac->ru.nonxrange[0] );
  size = 24;
  memcpy( temp , xrange , size );
  return 1;
} 
#endif


#ifndef _ENVELOPE_AR_
SEF_READ_NONEXP_RANGE( dgn_no , xrange )
short			*dgn_no;
int			*xrange;
{
  key_cmp 	*ac;
  int		*temp;
  int		size;

  active_file = (*dgn_no) - 1;
  ac = kd[active_file].active_comp;
  temp = ( int * ) ( &ac->ru.nonxrange[0] );
  size = 24;
  memcpy( xrange , temp , size );
  return 1;
} 
#endif
#ifndef _ENVELOPE_AR_
sef_read_nonexp_range_( dgn_no , xrange )
short			*dgn_no;
int			*xrange;
{
  return ( SEF_READ_NONEXP_RANGE( dgn_no , xrange ) );
} 


sef_read_nonexp_range( dgn_no , xrange )
short			*dgn_no;
int			*xrange;
{
  return ( SEF_READ_NONEXP_RANGE( dgn_no , xrange ) );
} 
#endif

#ifndef _ENVELOPE_AR_
SEF_READ_EXP_PRIM_RANGE( dgn_no , xrange )
short			*dgn_no;
int			*xrange;
{
  int		*temp;
  int		size;

  active_file = (*dgn_no) - 1;
  temp = ( int * ) ( &active_primitive[active_file]->ru.xrange[0] );
  size = 24;
  memcpy( xrange , temp , size );
  return 1;
} 
#endif
#ifndef _ENVELOPE_AR_
sef_read_shape_by_type_( shape_type, dgn_no, shp_no, shape )
short			*shape_type;
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( sef_read_shape_by_type( shape_type, dgn_no, shp_no, shape ) );
}


sef_read_shape_by_type( shape_type, dgn_no, shp_no, shape )
short			*shape_type;
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
if ( *shape_type == 1 )
  {
  return( SEF_READ_SHAPE( dgn_no, shp_no, shape ) );
  }
else if ( *shape_type == 2 )
  {
  return( SEF_READ_SOFT_SHAPE( dgn_no, shp_no, shape ) );
  }
}
#endif


#ifndef _ENVELOPE_AR_
SEF_READ_SHAPE( dgn_no, shp_no, shape )		/* reads comp from memory */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int		size;

  active_file = (*dgn_no) - 1;
  if ( *shp_no == 1 ) 
    {
    if ( kc[active_file].first_key_shp == 0 )
      return ( -1 );
    as = kc[active_file].first_key_shp;
    size = as->shp_dat.su.size[0];
    size = size + 56;			/* key length + pointer length */
    memcpy( &ksp[active_file] , kc[active_file].first_key_shp, size );

/*    if ( log_on ) 
      {
      fprintf( log_file, " SEF_READ_SHAPE\n " );
      L_K_SHAPE( kc[active_file].first_key_shp );
      }
*/
    kc[active_file].active_key_shp = kc[active_file].first_key_shp;
    }
  else
    {
    kc[active_file].active_key_shp = ksp[active_file].next_key_shp;
    if ( kc[active_file].active_key_shp == 0 )
      return ( -1);
    as = kc[active_file].active_key_shp;
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &ksp[active_file] , kc[active_file].active_key_shp , size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_READ_SHAPE\n " );
      L_K_SHAPE( kc[active_file].active_key_shp );
      }
*/
    }
  size = as->shp_dat.su.size[0];
  memcpy( shape , &ksp[active_file].shp_dat , size );
  return 1;
}
#endif
#ifndef _ENVELOPE_AR_
sef_read_soft_shape( dgn_no, shp_no, shape )/* reads soft shape from memory */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_READ_SOFT_SHAPE( dgn_no, shp_no, shape ) );
}


sef_read_soft_shape_( dgn_no, shp_no, shape )/* reads soft shape from memory */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_READ_SOFT_SHAPE( dgn_no, shp_no, shape ) );
}



SEF_READ_SOFT_SHAPE( dgn_no, shp_no, shape )/* reads soft shape from memory */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int		size;

  active_file = (*dgn_no) - 1;
  if ( *shp_no == 1 ) 
    {
    if ( kc[active_file].first_soft_shp == 0 )
      return ( -1 );
    as = kc[active_file].first_soft_shp;
    size = as->shp_dat.su.size[0];
    size = size + 56;			/* key length + pointer length */
    memcpy( &ksp[active_file] , kc[active_file].first_soft_shp, size );
    kc[active_file].active_soft_shp = kc[active_file].first_soft_shp;
    }
  else
    {
    kc[active_file].active_soft_shp = ksp[active_file].next_key_shp;
    if ( kc[active_file].active_soft_shp == 0 )
      return ( -1);
    as = kc[active_file].active_soft_shp;
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &ksp[active_file] , kc[active_file].active_soft_shp , size );
    }
  size = as->shp_dat.su.size[0];
  memcpy( shape , &ksp[active_file].shp_dat , size );
  return 1;
}
#endif
#ifndef _ENVELOPE_AR_
sef_read_shape_overlap_type_( st, in_range , dgn_no , shp_no , shape , overlap )		/* reads comp from memory */
short			*st;
int			*in_range;
short			*overlap;
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( sef_read_shape_overlap_type( st, in_range , dgn_no , shp_no , 
  shape , overlap ) );
}



sef_read_shape_overlap_type( st, in_range , dgn_no , shp_no , shape , overlap )		/* reads comp from memory */
short			*st;
int			*in_range;
short			*overlap;
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
if( *st == 1 ) /* want hard */
  {
  return(sef_read_shape_overlap( in_range , dgn_no , shp_no , shape , 
    overlap ));
  }
else
  {
  return(sef_read_soft_shape_overlap( in_range , dgn_no , shp_no , shape , 
    overlap ));
  }
}





sef_read_shape_overlap( in_range , dgn_no , shp_no , shape , overlap )		/* reads comp from memory */
int			*in_range;
short			*overlap;
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int		size;

  static	key_shp		*ksp_p;

  active_file = (*dgn_no) - 1;
  if ( *shp_no == 1 ) 
    {
    if ( kc[active_file].first_key_shp == 0 )
      return ( -1 );
    as = kc[active_file].first_key_shp;

/*
    size = as->shp_dat.su.size[0];
    size = size + 56;		
    memcpy( &ksp[active_file] , kc[active_file].first_key_shp, size );
*/
    ksp_p = kc[active_file].first_key_shp;


    kc[active_file].active_key_shp = kc[active_file].first_key_shp;
    }
  else
    {
/*  kc[active_file].active_key_shp = ksp[active_file].next_key_shp; */
    kc[active_file].active_key_shp = ksp_p->next_key_shp;

    if ( kc[active_file].active_key_shp == 0 )
      return ( -1);
    as = kc[active_file].active_key_shp;
/*
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &ksp[active_file] , kc[active_file].active_key_shp , size );
*/
    ksp_p = kc[active_file].active_key_shp;

    }

  check_ranges_( in_range , as->shp_dat.ru.range , overlap );

  if( *overlap == 1 )
    {
    size = as->shp_dat.su.size[0];
    size = size + 56;		
    memcpy( &ksp[active_file] , kc[active_file].active_key_shp, size );

    size = as->shp_dat.su.size[0];
/*    memcpy( shape , &ksp[active_file].shp_dat , size );  */
    memcpy( shape , &ksp_p->shp_dat , size );
    }
  return 1;
}
#endif

#ifndef _ENVELOPE_AR_
sef_read_soft_shape_overlap( in_range , dgn_no , shp_no , shape , overlap )		/* reads comp from memory */
int			*in_range;
short			*overlap;
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int		size;

  static	key_shp		*ksp_p;

  active_file = (*dgn_no) - 1;
  if ( *shp_no == 1 ) 
    {
    if ( kc[active_file].first_soft_shp == 0 )
      return ( -1 );
    as = kc[active_file].first_soft_shp;
    ksp_p = kc[active_file].first_soft_shp;
    kc[active_file].active_soft_shp = kc[active_file].first_soft_shp;
    }
  else
    {
    kc[active_file].active_soft_shp = ksp_p->next_key_shp;
    if ( kc[active_file].active_soft_shp == 0 )
      return ( -1);
    as = kc[active_file].active_soft_shp;
    ksp_p = kc[active_file].active_soft_shp;
    }

  check_ranges_( in_range , as->shp_dat.ru.range , overlap );

  if( *overlap == 1 )
    {
    size = as->shp_dat.su.size[0];
    size = size + 56;		
    memcpy( &ksp[active_file] , kc[active_file].active_soft_shp, size );
    size = as->shp_dat.su.size[0];
    memcpy( shape , &ksp_p->shp_dat , size );
    }
  return 1;
}
#endif




#ifndef _ENVELOPE_AR_
sef_read_exp_shape_( dgn_no, shp_no, shape )	
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_READ_EXP_SHAPE( dgn_no, shp_no, shape ));
}

sef_read_exp_shape( dgn_no, shp_no, shape )	
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_READ_EXP_SHAPE( dgn_no, shp_no, shape ));
}


SEF_READ_EXP_SHAPE( dgn_no, shp_no, shape )	
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int	size;

  active_file = (*dgn_no) - 1;
  if ( *shp_no == 1 ) 
    {
    if ( kc[active_file].first_exp_shp == 0 )
      return ( -1 );
    as = kc[active_file].first_exp_shp;
    size = as->shp_dat.su.size[0];
    size = size + 56;			/* key length + pointer length */
    memcpy( &ksp[active_file] , kc[active_file].first_exp_shp, size );
    kc[active_file].active_exp_shp = kc[active_file].first_exp_shp;
    }
  else
    {
    kc[active_file].active_exp_shp = ksp[active_file].next_key_shp;
    if ( kc[active_file].active_exp_shp == 0 )
      return ( -1);
    as = kc[active_file].active_exp_shp;
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &ksp[active_file] , kc[active_file].active_exp_shp , size );
    }
  size = as->shp_dat.su.size[0];
  memcpy( shape , &ksp[active_file].shp_dat , size );
  return 1;
}
#endif
#ifndef _ENVELOPE_AR_
sef_read_red_hole_( dgn_no, shp_no, shape )	/* read a reduced hole */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_READ_RED_HOLE( dgn_no, shp_no, shape ));
}

sef_read_red_hole( dgn_no, shp_no, shape )	/* read a reduced hole */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_READ_RED_HOLE( dgn_no, shp_no, shape ));
}





SEF_READ_RED_HOLE( dgn_no, shp_no, shape )	/* read a reduced hole */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int	size;

  active_file = (*dgn_no) - 1;
  if ( *shp_no == 1 ) 
    {
    if ( kc[active_file].first_exp_hole == 0 )
      return ( -1 );
    as = kc[active_file].first_exp_hole;
    size = as->shp_dat.su.size[0];
    size = size + 56;			/* key length + pointer length */
    memcpy( &ksp[active_file] , kc[active_file].first_exp_hole, size );
    kc[active_file].active_exp_hole = kc[active_file].first_exp_hole;
    }
  else
    {
    kc[active_file].active_exp_hole = ksp[active_file].next_key_shp;
    if ( kc[active_file].active_exp_hole == 0 )
      return ( -1);
    as = kc[active_file].active_exp_hole;
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &ksp[active_file] , kc[active_file].active_exp_hole , size );
    }
  size = as->shp_dat.su.size[0];
  memcpy( shape , &ksp[active_file].shp_dat , size );
  return 1;
}
#endif



#ifndef _ENVELOPE_AR_
SEF_READ_HOLE( dgn_no, shp_no, shape )		/* reads comp from memory */
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int		size;

  active_file = (*dgn_no) - 1;
  if ( *shp_no == 1 ) 
    {
    if ( kc[active_file].first_hole == 0 )
      return ( -1 );
    as = kc[active_file].first_hole;
    size = as->shp_dat.su.size[0];
    size = size + 56;			/* key length + pointer length */
    memcpy( &kh[active_file] , kc[active_file].first_hole , size );

/*    if ( log_on ) 
      {
      fprintf( log_file, " SEF_READ_HOLE\n " );
      L_K_SHAPE( kc[active_file].first_hole );
      }
*/
    kc[active_file].active_hole = kc[active_file].first_hole;
    }
  else
    {
    kc[active_file].active_hole = kh[active_file].next_key_shp;
    if ( kc[active_file].active_hole == 0 )
      return ( -1);
    as = kc[active_file].active_hole;
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &kh[active_file] , kc[active_file].active_hole , size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_READ_HOLE\n " );
      L_K_SHAPE( kc[active_file].active_hole );
      }
*/
    }
  size = as->shp_dat.su.size[0];
  memcpy( shape , &kh[active_file].shp_dat , size );
  return 1;
}
#endif



#ifndef _ENVELOPE_AR_
SEF_READ_PRIM( dgn_no, prim_no, shape )		/* reads comp from memory */
short			*dgn_no;
short			*prim_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int		size;

  active_file = (*dgn_no) - 1;
  if ( *prim_no == 1 ) 
    {
    if ( ksp[active_file].first_prim == 0 ) 
      return ( -1 );
    as = ksp[active_file].first_prim;
    size = as->shp_dat.su.size[0];
    size = size + 56;			/* key length + pointer length */
    memcpy( &kp , ksp[active_file].first_prim , size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_READ_PRIM\n " );
      L_K_SHAPE( ksp[active_file].first_prim );
      }
*/
    ksp[active_file].active_prim = ksp[active_file].first_prim;
    }
  else
    {
    as = ksp[active_file].active_prim;
    ksp[active_file].active_prim = as->next_key_shp;	/* should get next prim */
    as = ksp[active_file].active_prim;
    if ( ksp[active_file].active_prim == 0 )
      return ( -1);
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &kp , ksp[active_file].active_prim , size );

/*    if ( log_on )
      {
      fprintf( log_file, " SEF_READ_PRIM\n " );
      L_K_SHAPE( ksp[active_file].active_prim );
      }
*/
    }
  size = as->shp_dat.su.size[0];
  memcpy( shape , &kp.shp_dat , size );
  active_primitive[active_file] = as;
  return 1;
}
#endif

#ifndef _ENVELOPE_AR_
sef_read_exp_prim_( dgn_no, prim_no, shape )		/* reads comp from memory */
short			*dgn_no;
short			*prim_no;
basic_shape_data	*shape;
{
return( SEF_READ_EXP_PRIM( dgn_no, prim_no, shape ));
}

sef_read_exp_prim( dgn_no, prim_no, shape )		/* reads comp from memory */
short			*dgn_no;
short			*prim_no;
basic_shape_data	*shape;
{
return( SEF_READ_EXP_PRIM( dgn_no, prim_no, shape ));
}




SEF_READ_EXP_PRIM( dgn_no, prim_no, shape )		/* reads comp from memory */
short			*dgn_no;
short			*prim_no;
basic_shape_data	*shape;
{
  key_shp	*as;
  static	int	size;

  active_file = (*dgn_no) - 1;
  if ( *prim_no == 1 ) 
    {
    if ( ksp[active_file].first_prim == 0 ) 
      return ( -1 );
    as = ksp[active_file].first_prim;
    size = as->shp_dat.su.size[0];
    size = size + 56;			/* key length + pointer length */
    memcpy( &kp , ksp[active_file].first_prim , size );
    ksp[active_file].active_prim = ksp[active_file].first_prim;
    }
  else
    {
    as = ksp[active_file].active_prim;
    ksp[active_file].active_prim = as->next_key_shp;	/* should get next prim */
    as = ksp[active_file].active_prim;
    if ( ksp[active_file].active_prim == 0 )
      return ( -1);
    size = as->shp_dat.su.size[0];
    size = size + 56;
    memcpy( &kp , ksp[active_file].active_prim , size );

    }
  size = as->shp_dat.su.size[0];
  memcpy( shape , &kp.shp_dat , size );
/*  active_primitive[active_file] = as; */
  return 1;
}
#endif

#ifndef _ENVELOPE_AR_
SEF_WRITE_EXP_SHAPE( dgn_no, shape ) 	/* writes expanded shape to memory */
short			*dgn_no;
basic_shape_data	*shape;
{
  key_shp	*s;
  static        int	size, real_size;
  key_shp	*temp_shp;
  key_cmp 	*ac;
  int		*temp;

  active_file = (*dgn_no) - 1;
  real_size = SEF_SHAPE_SIZE( shape );	
  size = roundup_( &real_size );  		/* size is now / 8  */
  size = size + 56;
  s = (key_shp *) calloc( one, size );  		/* add bytes for keys  and pointers */
  if ( s == 0 )
    return 0;
  temp = ( int * ) &s->shp_dat;
  size = size - 56;
  memcpy( temp , shape , size );	
  s->shp_dat.su.size[0] = real_size;
  s->ku.key[0] = zero;
  s->ku.key[1] = *dgn_no;
  s->ku.key[2] = num_cmp[active_file];
  num_exp_shp[active_file] = num_exp_shp[active_file] + 1;
  s->ku.key[3] = num_exp_shp[active_file];
  s->next_key_shp = 0;
  ac =  kd[active_file].active_comp;

  if ((s->shp_dat.su.size[2] == 1) || (s->shp_dat.su.size[2] == 3))	/* 	solid	*/
    {
    if ( num_exp_shp[active_file] > 1 )
      {
      temp_shp = ac->active_exp_shp;
      temp_shp->next_key_shp = s;		/* link s to previous s */
      }
    else				/* need to update c */
      {
      ac->first_exp_shp = s;
      kc[active_file].first_exp_shp = s;
      }
    ac->active_exp_shp = s;
    }

  return 1 ;
}
#endif


#ifndef _ENVELOPE_AR_
SEF_WRITE_RED_HOLE( dgn_no, shape ) 	/* writes reduced hole to memory */
short			*dgn_no;
basic_shape_data	*shape;
{
  key_shp	*s;
  static        int	size, real_size;
  key_shp	*temp_shp;
  key_cmp 	*ac;
  int		*temp;

  active_file = (*dgn_no) - 1;
  real_size = SEF_SHAPE_SIZE( shape );	
  size = roundup_( &real_size );  		/* size is now / 8  */
  size = size + 56;
  s = (key_shp *) calloc( one, size );  		/* add bytes for keys  and pointers */
  if ( s == 0 )
    return ( 0 );
  temp = ( int * ) &s->shp_dat;
  size = size - 56;
  memcpy( temp , shape , size );	
  s->shp_dat.su.size[0] = real_size;
  s->ku.key[0] = zero;
  s->ku.key[1] = *dgn_no;
  s->ku.key[2] = num_cmp[active_file];
  num_exp_hole[active_file] = num_exp_hole[active_file] + 1;
  s->ku.key[3] = num_exp_hole[active_file];
  s->next_key_shp = 0;
  ac =  kd[active_file].active_comp;
  if ( s->shp_dat.su.size[2] == 2 )	/* 	hole	*/
    {
    if ( num_exp_hole[active_file] > 1 )
      {
      temp_shp = ac->active_exp_hole;
      temp_shp->next_key_shp = s;		/* link s to previous s */
      }
    else				/* need to update c */
      {
      ac->first_exp_hole = s;
      kc[active_file].first_exp_hole = s;
      }
    ac->active_exp_hole = s;
    }
  return ( 1 );
}
#endif

#ifndef _ENVELOPE_AR_
SEF_WRITE_SHAPE( dgn_no, shape ) 	/* writes shape to memory */
short			*dgn_no;
basic_shape_data	*shape;
{
  key_shp	*s;
  static        int		size, real_size;
  key_shp	*temp_shp;
  key_cmp 	*ac;
  int		*temp;

  if( sef_interactive_env == 1 )
    {
    modify_shape_env_type( &shape->su.size[3] );
    }
  active_file = (*dgn_no) - 1;
  real_size = SEF_SHAPE_SIZE( shape );	
  size = roundup_( &real_size );  		/* size is now / 8  */
  size = size + 56;
  s = (key_shp *) calloc( one, size );  		/* add bytes for keys  and pointers */
  if ( s == 0 )
    return ( 0 );
  temp = ( int * ) &s->shp_dat;
  size = size - 56;
  memcpy( temp , shape , size );	
  s->shp_dat.su.size[0] = real_size;
  s->ku.key[0] = zero;
  s->ku.key[1] = *dgn_no;
  s->ku.key[2] = num_cmp[active_file];
  s->next_key_shp = 0;
  ac =  kd[active_file].active_comp;
  if ((s->shp_dat.su.size[2] == 1) || (s->shp_dat.su.size[2] == 3))  /* solid*/
    {
    hard_soft.type = s->shp_dat.su.size[3];
    if( hard_soft.cl_type[0] ==  1 || hard_soft.cl_type[0] == 10 || 
    hard_soft.cl_type[0] == 11 || hard_soft.cl_type[0] == 12 ||
    hard_soft.cl_type[0] == 13 ) 	/* hard - add to hard list */
      {
      num_shp[active_file] = num_shp[active_file] + 1;
      s->ku.key[3] = num_shp[active_file];
      if ( num_shp[active_file] > 1 )
        {
	temp_shp = ac->first_key_shp;
	ac->first_key_shp = s;
        kc[active_file].first_key_shp = s;
	s->next_key_shp = temp_shp;
        }
      else				/* need to update c */
        {
        ac->first_key_shp = s;
        kc[active_file].first_key_shp = s;
        }
      ac->active_key_shp = s;
      }

    else if( hard_soft.cl_type[0] ==  2 || hard_soft.cl_type[0] == 20 ||
    hard_soft.cl_type[0] == 21 || hard_soft.cl_type[0] == 22 ||
    hard_soft.cl_type[0] == 23 ) 	/* soft - add to soft list */
      {
      num_soft_shp[active_file] = num_soft_shp[active_file] + 1;
      s->ku.key[3] = num_shp[active_file];
      if ( num_soft_shp[active_file] > 1 )
        {
	temp_shp = ac->first_soft_shp;
	ac->first_soft_shp = s;
        kc[active_file].first_soft_shp = s;
	s->next_key_shp = temp_shp;
        }
      else				/* need to update c */
        {
        ac->first_soft_shp = s;
        kc[active_file].first_soft_shp = s;
        }
      ac->active_soft_shp = s;
      }
    }

  else							/* 	hole	*/
    {
    num_hole[active_file] = num_hole[active_file] + 1;
    s->ku.key[3] = num_hole[active_file];
    if ( num_hole[active_file] > 1 )
      {
      temp_shp = ac->active_hole;
      temp_shp->next_key_shp = s;
      }
    else
      {
      ac->first_hole = s;
      }
    ac->active_hole = s;
    }
  return ( 1 );
}
#endif


#ifndef _ENVELOPE_AR_
SEF_WRITE_PRIM( dgn_no, prim ) 	/* writes hard primitive shape to memory */
short			*dgn_no;
basic_shape_data	*prim;
{
  key_shp	*s;
  static        int	size , real_size;
  key_shp	*old_top;
  key_shp	*as;
  int		*temp;

  hard_soft.type = prim->su.size[3];
  active_file = (*dgn_no) - 1;
  real_size = SEF_SHAPE_SIZE( prim );	
  size = roundup_( &real_size );  		/* size is now / 8  */
  size = size + 56;
  s = (key_shp *) calloc( one, size );  		/* add bytes for keys  and pointers */
  if ( s == 0 ) 
    return ( 0 );
  temp = ( int * ) &s->shp_dat;
  size = size - 56;
  memcpy( temp , prim , size );	
  s->shp_dat.su.size[0] = real_size;
  s->ku.key[0] = zero;
  s->ku.key[1] = *dgn_no;
  s->ku.key[2] = num_cmp[active_file];
  s->next_key_shp = 0;
  if( hard_soft.cl_type[1] == 1 )
    {
    as = kc[active_file].active_key_shp;
    }
  else
    {
    as = kc[active_file].active_soft_shp;
    }
  if ( ( int ) as->first_prim > 0 ) 
    {
    old_top = as->active_prim;
    old_top->next_key_shp = s;		/* link s to previous prim  */
    }
  else				
    {
    as->first_prim = s;
    }
  as->active_prim = s;
  active_primitive[active_file] = s;
  return ( 1 );
}
#endif

#ifndef _ENVELOPE_AR_
sef_write_exp_prim_( dgn_no, prim ) 		/* writes primitive shape to memory */
short			*dgn_no;
basic_shape_data	*prim;
{
return( SEF_WRITE_EXP_PRIM( dgn_no, prim ));
}


sef_write_exp_prim( dgn_no, prim ) 		/* writes primitive shape to memory */
short			*dgn_no;
basic_shape_data	*prim;
{
return( SEF_WRITE_EXP_PRIM( dgn_no, prim ));
}



SEF_WRITE_EXP_PRIM( dgn_no, prim ) 		/* writes primitive shape to memory */
short			*dgn_no;
basic_shape_data	*prim;
{
  key_shp	*s;
  static        int	size , real_size;
  key_shp	*old_top;
  key_shp	*as;
  int		*temp;

  active_file = (*dgn_no) - 1;
  real_size = SEF_SHAPE_SIZE( prim );	
  size = roundup_( &real_size );  		/* size is now / 8  */
  size = size + 56;
  s = (key_shp *) calloc( one, size );  		/* add bytes for keys  and pointers */
  if ( s == 0 ) 
    return ( 0 );
  temp = ( int * ) &s->shp_dat;
  size = size - 56;
  memcpy( temp , prim , size );	
  s->shp_dat.su.size[0] = real_size;
  s->ku.key[0] = zero;
  s->ku.key[1] = *dgn_no;
  s->ku.key[2] = num_cmp[active_file];
  s->next_key_shp = 0;
  as = kc[active_file].active_exp_shp;
  if ( ( int ) as->first_prim > 0 ) 
    {
    old_top = as->active_prim;
    old_top->next_key_shp = s;		/* link s to previous prim  */
    }
  else				
    {
    as->first_prim = s;
    }
  as->active_prim = s;

  /* active_primitive[active_file] = s;	*/
  return ( 1 );
}
#endif


#ifndef _ENVELOPE_AR_
SEF_REWRITE_SHAPE( dgn_no, shape ) 	/* writes shape to memory */
short			*dgn_no;
basic_shape_data	*shape;
{
  key_shp	*s;
  static   short	size;

  active_file = (*dgn_no) - 1;
  size = SEF_SHAPE_SIZE( shape );
  s = kc[active_file].active_key_shp;
  memcpy( &s->shp_dat , shape , size );

/*  if ( log_on ) 
    {
    fprintf( log_file, " SEF_REWRITE_SHAPE\n " );
    L_K_SHAPE( s );
    }
*/
  return ( 1 );
}
#endif

#ifndef _ENVELOPE_AR_
sef_rewrite_soft_shape_( dgn_no, shape ) 	/* writes shape to memory */
short			*dgn_no;
basic_shape_data	*shape;
{
return( sef_rewrite_soft_shape( dgn_no, shape ) );
}


sef_rewrite_soft_shape( dgn_no, shape ) 	/* writes shape to memory */
short			*dgn_no;
basic_shape_data	*shape;
{
  key_shp	*s;
  static   short	size;

  active_file = (*dgn_no) - 1;
  size = SEF_SHAPE_SIZE( shape );
  s = kc[active_file].active_soft_shp;
  memcpy( &s->shp_dat , shape , size );
  return ( 1 );
}
#endif

#ifndef _ENVELOPE_AR_
SEF_WRITE_CMP( dgn_no, comp ) 		/* writes comp to memory */
short		*dgn_no;
component_data	*comp;
{
  key_cmp	*c;
  static        int	size;
  key_cmp	*old_top;
  char		*temp;
  int		size_before_lcp , lcp_size;


  active_file = (*dgn_no) - 1;
  size = SEF_CMP_SIZE( comp );		
  if( comp->su.size[5] == 5 )		/* mpc */
    {
    lcp_size = comp->su.size[7] * 8;
    size_before_lcp = size - lcp_size;
    }

  comp->su.size[0] = size;
  size = roundup_( &size );  		/* size is now / 8  */
  size = size + 80; 			/* keep it divisable by 8 */
  c = (key_cmp *) calloc ( one, size );		/* add 28 for keys & ptrs */
  if ( c == 0 ) 
    return ( 0 );
  temp = ( char * ) &c->cmp_dat;
  if( ( comp->su.size[5] == 5 ) && ( sef_downloading == 0 ))	/* pack mpcs */
    {
    memcpy( temp , comp , size_before_lcp );
    temp = temp + size_before_lcp;
    memcpy( temp , comp->cp_data.mpc_cmp.lcp , lcp_size );
    }
  else
    {
    size = size - 80;
    memcpy( temp , comp , size );	
    }
  c->cmp_dat.su.size[0] = size;
  c->ku.key[0] = zero;
  c->ku.key[1] = *dgn_no;
  num_cmp[active_file] = num_cmp[active_file] + 1;
  num_shp[active_file] = 0;
  num_soft_shp[active_file] = 0;
  num_hole[active_file] = 0;
  num_exp_shp[active_file] = 0;
  num_exp_hole[active_file] = 0;
  c->ku.key[2] = num_cmp[active_file];
  c->cmp_dat.nu.cmp_no[0] = num_cmp[active_file];
  comp->nu.cmp_no[0] = num_cmp[active_file];
  c->ku.key[3] = zero;
  c->next_key_cmp = 0;
  c->first_key_shp = 0;
  c->first_hole = 0;
  c->first_exp_shp = 0;
  c->first_exp_hole = 0;
  c->first_soft_shp = 0;
  if( c->cmp_dat.su.size[5] == 6 ) 	/* save pointer to eqp cp array */
    {
    c->cmp_dat.cp_data.lrs.lrs_end1[0] = comp->cp_data.lrs.lrs_end1[0];  		
    }

  if (( first_sef_write == 1 ) || ( num_cmp[active_file] == 1 ))
    {
    kd[active_file].first_comp = c;
    kd_scan[active_file] = kd[active_file];
    first_sef_write = 0;
    }
  else
    {
    old_top = kd[active_file].active_comp;
    old_top->next_key_cmp = c;		/* link c to previous c */
    }


  kd[active_file].active_comp = c;

/*  if ( log_on )
    {
    fprintf( log_file, " SEF_WRITE_CMP **************************************\n " );
    L_K_COMP( c );
    }
*/
  return ( 1 );
}
#endif



#ifndef _ENVELOPE_AR_
SEF_REWRITE_CMP( dgn_no, comp ) 		/* rewrites comp to memory */
short		*dgn_no;
component_data	*comp;
{
  key_cmp	*c;
  static  	int	size;

  active_file = (*dgn_no) - 1;
  c = kd[active_file].active_comp;
  size = comp->su.size[0];
  if( rewrite_entire_cmp == 1 )
    {
    memcpy( &c->cmp_dat , comp , size );
    }
  else
    {
    size = 24;
    memcpy( &c->cmp_dat.ru.range , comp->ru.range , size );  /* just update range */
    }
  return ( 1 );
}
#endif

#ifndef _ENVELOPE_AR_
SEF_REWRITE_CMP_EMU_FLAG( dgn_no, comp ) 		
short		*dgn_no;
component_data	*comp;
{
  key_cmp	*c;

  active_file = (*dgn_no) - 1;
  c = kd[active_file].active_comp;
  c->cmp_dat.cu.chr[34] = comp->cu.chr[34];
  return ( 1 );
}


sef_rewrite_cmp_emu_flag_( dgn_no, comp ) 		
short		*dgn_no;
component_data	*comp;
{
return( SEF_REWRITE_CMP_EMU_FLAG( dgn_no, comp ) );
}

sef_rewrite_cmp_emu_flag( dgn_no, comp ) 		
short		*dgn_no;
component_data	*comp;
{
return( SEF_REWRITE_CMP_EMU_FLAG( dgn_no, comp ) );
}
#endif


#ifndef _ENVELOPE_AR_
SEF_WRITE_CMP_F( dgn_no )		/* writes from memory to file */
short		*dgn_no;

/* assume: always called immediately after sef_read_cmp, so data is in kc
*/

{
  static int	status , size ;

  active_file = (*dgn_no) - 1;
/*  pos = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  kc[active_file].cmp_dat.cu.chr[34] = 0;	/* hasnt been emulated */
  size = kc[active_file].cmp_dat.su.size[0] + 8;

  if ( on_vax == 0 )
    {
    UNCVT_COMP( &kc[active_file].cmp_dat );		/* store in vax format */
    }

  status = write(sef_file_desc[active_file], &kc[active_file].ku, size );
  /*file_size = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  return (status);
}
#endif



SEF_WRITE_CMP_FILE( dgn_no, cmp_no, comp )		/* writes from memory to file */
short		*dgn_no;
short		*cmp_no;
component_data	*comp;

/* assume: does not use kc
*/

{
  static int	status , size ;

  active_file = (*dgn_no) - 1;
/*  pos = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  comp->cu.chr[34] = 0;		/* hasnt been emulated */
  size = SEF_CMP_SIZE( comp );
  comp->su.size[0] = size;
  num_cmp[active_file] = *cmp_no;
  kc[active_file].ku.key[0] = zero;
  kc[active_file].ku.key[1] = *dgn_no;
  kc[active_file].ku.key[2] = num_cmp[active_file];
  kc[active_file].ku.key[3] = zero;
  memcpy( &kc[active_file].cmp_dat , comp , size );
  size = kc[active_file].cmp_dat.su.size[0] + 8;

  if ( on_vax == 0 )
    {
    UNCVT_COMP( &kc[active_file].cmp_dat );		/* store in vax format */
    }
  
  compoffset = lseek(sef_file_desc[active_file], no_offset , SEEK_CUR);
  compsize = size;
  compactive_file = active_file;

  status = write(sef_file_desc[active_file], &kc[active_file].ku, size );
  /*file_size = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  return (status);
}

SEF_REWRITE_CMP_RANGE_FILE (range)
int	range [2][3];

{int desc, status, nowat, rangebias;
 key_cmp kc;

 desc = sef_file_desc [compactive_file];
 nowat = lseek (desc, no_offset, SEEK_CUR);

 rangebias = (int) kc.cmp_dat.ru.range - (int)&kc.ku;
 lseek (desc, compoffset+rangebias, SEEK_SET);
 status = write (desc, range, 24);

 lseek (desc, nowat, SEEK_SET);
 return status;
}

SEF_WRITE_CP_FILE( no_more_points , p )
short	*no_more_points;
int	p[3];
{
static	char	first_point=1;
static	short	number_points = 0;
static	char	*point_buffer;
char		*ptr;
static	int	point_buffer_size;
static	int	max_points;
int 		desc , status , nowat , rangebias , size;
key_cmp 	kc;
short		cp_type;

if( first_point )	/* get space for point array */
  {
  first_point = 0;
  max_points = 200; 	/* for debug , change to 200 */
  point_buffer_size = max_points * 12;
  point_buffer = ( char *) calloc( one , point_buffer_size);
  }
if( *no_more_points == 0 ) /* update no_cp and write point buffer to file */
  {
  desc = sef_file_desc[compactive_file];
  nowat = lseek (desc, no_offset, SEEK_CUR);
  rangebias = (int) &kc.cmp_dat.su.size[5] - (int)&kc.ku; /* 5 = cp type */
  lseek( desc , compoffset+rangebias , SEEK_SET );
  cp_type = 6;					/* eqp connect point type */
  status = write ( desc , &cp_type , 2 );
  status = write ( desc , &number_points , 2 );
  lseek( desc , nowat , SEEK_SET );
  size = number_points * 12;  
  status = write ( desc , point_buffer , size );
  number_points = 0;
  }
else	/* save the point into the point buffer */
  {
  if ( number_points >= max_points )
    {
    max_points = max_points + 200;
    point_buffer_size = max_points * 12;
    point_buffer = ( char * ) realloc ( point_buffer , point_buffer_size );
    }
  ptr = point_buffer + ( number_points * 12);
  memcpy( ptr , p , 12 );
  number_points++;
  }
}



SEF_WRITE_SHAPE_FILE( dgn_no, shp_no, shape )		/* writes from memory to file */
short		 	*dgn_no;
short			*shp_no;
basic_shape_data	*shape;

/* assume: does not use ks
*/

{
  static int	status , size ;

  active_file = (*dgn_no) - 1;
/*  pos = lseek( sef_file_desc[active_file] , no_offset , one );	*/

  size = SEF_SHAPE_SIZE( shape );
  shape->su.size[0] = size;
  num_shp[active_file] = *shp_no;
  ksp[active_file].ku.key[0] = zero;
  ksp[active_file].ku.key[1] = *dgn_no;
  ksp[active_file].ku.key[2] = num_cmp[active_file];
  ksp[active_file].ku.key[3] = *shp_no;
  memcpy( &ksp[active_file].shp_dat , shape , size );
  size = ksp[active_file].shp_dat.su.size[0] + 8;

  if ( on_vax == 0 )
    {
    UNCVT_SHAPE( &ksp[active_file].shp_dat );		/* store in vax format */
    }

  status = write(sef_file_desc[active_file], &ksp[active_file].ku, size );
  /*file_size = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  return (status);
}


#ifndef _ENVELOPE_AR_
SEF_WRITE_SHAPE_F( dgn_no )		/* writes from memory to file */
short			*dgn_no;

/* assume: always called immediately after sef_read_shape, so data is in ksp
*/

{
  static int	status , size ;

/*  pos = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  active_file = (*dgn_no) - 1;
  size = ksp[active_file].shp_dat.su.size[0] + 8;		/* dont write pointer - next_key_shp */

  if ( on_vax == 0 )
    {
    UNCVT_SHAPE( &ksp[active_file].shp_dat );		/* store in vax format */
    }

  status = write(sef_file_desc[active_file], &ksp[active_file].ku, size );
  /*file_size = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  return (status);
}
#endif



SEF_WRITE_BS_DATA_F( shape )		/* writes from memory to file */
basic_shape_data	*shape;

{
  static int	status , pos;

  pos = lseek( sef_file_desc[active_file] , no_offset , one );	
  status = write( sef_file_desc[active_file] , shape->geom.bs_head.bs_data , shape->geom.bs_head.bs_data_bytes );
  pos = lseek( sef_file_desc[active_file] , no_offset , one );	
  return (status);
}


SEF_WRITE_HOLE_F( dgn_no )		
short			*dgn_no;

{
  static int	status , size ;

/*  pos = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  active_file = (*dgn_no) - 1;
  size = kh[active_file].shp_dat.su.size[0] + 8;		/* dont write pointer - next_key_shp */
  if ( on_vax == 0 )
    {
    UNCVT_SHAPE( &kh[active_file].shp_dat );		/* store in vax format */
    }
  status = write(sef_file_desc[active_file], &kh[active_file].ku, size );
  /*file_size = lseek( sef_file_desc[active_file] , no_offset , one );	*/
  return (status);
}


SEF_WRITE_DGN( dgn_no , dgn )
short		*dgn_no;
design_data	*dgn;
{
  static int	status , size;
  static int	pos;

  active_file = (*dgn_no) - 1;
  size = sizeof ( *dgn );
  memcpy( &kd[active_file].dgn_dat , dgn , size );
  kd[active_file].dgn_dat.su.size[0] = size;
  kd[active_file].ku.key[0] = 0;
  kd[active_file].ku.key[1] = *dgn_no;
  kd[active_file].ku.key[2] = 0;
  kd[active_file].ku.key[3] = 0;
  if ( data_reservoir[active_file] == 0 ) 	/* file is open for write */
    {
    size = sizeof ( ks );
    pos = lseek( sef_file_desc[active_file], no_offset, beginning );
    status = read ( sef_file_desc[active_file] , &ks , size );
/*    pos = lseek( sef_file_desc[active_file] , no_offset , one );		*/
    size = sizeof ( key_dgn ) - 8;
    status = write(sef_file_desc[active_file], &kd[active_file], size );
/*    pos = lseek( sef_file_desc[active_file] , no_offset , one );		*/
    }
  else
    status = 1;
  return ( 1 );
}


SEF_WRITE_SYS( sys )

struct 	system_data	*sys;
{
  static int	status, size;
  static double	ver = 0.0;
  static int 	pos;


  size = sizeof( *sys );
  memcpy( &ks.sys_dat , sys , size );
  ks.sys_dat.su.size[0] = size;
/* 				file was created on Clipper	*/
  if ( on_vax == 0 ) 
    { 
    ks.sys_dat.su.size[1] = 1;			
    }
  else
    {
    ks.sys_dat.su.size[1] = 0;			
    }
  ks.sys_dat.version = ver;
  ks.ku.key[0] = 0;
  ks.ku.key[1] = 0;
  ks.ku.key[2] = 0;
  ks.ku.key[3] = 0;
  if ( data_reservoir[0] == 0 ) 		/* file is writable */
    {
    if ( on_vax == 0 )
      {
      UNCVT_SYS( &ks.sys_dat );		
      }
    size = sizeof( ks );
    pos = lseek( sef_file_desc[active_file], no_offset, beginning );
    status = write ( sef_file_desc[active_file] , &ks , size );
    pos = lseek( sef_file_desc[active_file] , no_offset , one );
    }
  else
    status = 1;
  return ( 1 );
}


#ifndef _ENVELOPE_AR_
SEF_READ_SYS( sys )

struct 	system_data	*sys;
{
  static int	status, size;
  static int 	pos;

  if ( data_reservoir[active_file] != 1 )	/* file is open for read or write */
    {
    size = sizeof( ks );
    pos = lseek( sef_file_desc[active_file], no_offset, beginning );
    status = read( sef_file_desc[active_file] , &ks , size );
    if ( status > 0 )
      {
      size = sizeof( *sys );
      memcpy( sys , &ks.sys_dat , size );
      if ( (ks.sys_dat.su.size[0] > ( size-4))  && ( ks.sys_dat.su.size[0] < ( size+4 )))
        {
        status = 1;
	}
      else
        {
        status = -1;
        }
      if ( on_vax == 0 )	/* on Clipper and data is VAX format */
        {
	CVT_SYS( sys );
 	}
      }
    }
  else
    {
    size = sizeof( *sys );
    memcpy( sys , &ks.sys_dat , size );
    status = 1;
    }
    return (status);
}
#endif


#ifndef _ENVELOPE_AR_
SEF_READ_DGN( dgn_no, dgn )

design_data	*dgn;
short		*dgn_no;
{
  static int	status, size , buffer_size;
  short  buffer[768];
  char   first;
  

  active_file = (*dgn_no) - 1;
  if ( data_reservoir[active_file] == 1 )		/* no files open , data in memory only */
    {
    size = sizeof( design_data );
    memcpy( dgn , &kd[active_file].dgn_dat , size );
    return( 1 );
    }
  buffer_size = sizeof( buffer ); 
  first = 1;
  status = SEF_READ_NEXT_RECORD( &first, buffer );
  status = SEF_READ_NEXT_RECORD( &first, buffer );
  size = buffer[4];
  memcpy( dgn , &buffer[4] , size );	
  return ( 1 );
}
#endif

#ifndef _ENVELOPE_AR_
SEF_READ_DGN_MEMORY( dgn_no, dgn )

design_data	*dgn;
short		*dgn_no;
{
  int           size;

  active_file = (*dgn_no) - 1;
  size = sizeof( design_data );
  memcpy( dgn , &kd[active_file].dgn_dat , size );
  return ( 1 );
}


sef_read_dgn_memory_( dgn_no, dgn )
design_data	*dgn;
short		*dgn_no;
{
  return( SEF_READ_DGN_MEMORY( dgn_no, dgn ));
}

sef_read_dgn_memory( dgn_no, dgn )
design_data	*dgn;
short		*dgn_no;
{
  return( SEF_READ_DGN_MEMORY( dgn_no, dgn ));
}
#endif



SEF_OPEN_FILE( file_name , type )

  char		*file_name;
  short		*type;
{
  static 	unsigned file_protection = 0400|0200|0100|0040|0020|0010|0004 ;
  static 	int   flags = O_RDWR;
  static        int	status, size;
  design_data		dgn;
  struct	system_data		sys;  
  static 	double	ver = 0.0;
  static 	short	dgn_no = 1;

  
  data_reservoir[0] = 0;
  if ( *type == 1 ) 	/* create a new file */
    {
    first_sef_write = 1;
    file_access_mode = 1;
    sef_file_desc[active_file] = creat( file_name, file_protection );
    if ( sef_file_desc[active_file] < 0 )
      return ( sef_file_desc[active_file] );
    if ( on_vax == 0 ) 
      {
      status = close( sef_file_desc[active_file] );
      sef_file_desc[active_file] = open( file_name, flags, file_protection );
      if ( sef_file_desc[active_file] < 0 )
        return ( sef_file_desc[active_file] );
      }
    size = sizeof( sys );
    ks.sys_dat.su.size[0] = size;
    ks.sys_dat.version = ver;
    if ( on_vax == 0 )
      {
      UNCVT_SYS( &ks.sys_dat );		
      }
    ks.ku.key[0] = 0;
    ks.ku.key[1] = 0;
    ks.ku.key[2] = 0;
    ks.ku.key[3] = 0;
    size = sizeof( ks );
    status = write(sef_file_desc[active_file], &ks, size );
    size = sizeof ( dgn );
    kd[dgn_no - 1].dgn_dat.su.size[0] = size;
    kd[dgn_no - 1].ku.key[0] = 0;
    kd[dgn_no - 1].ku.key[1] = dgn_no;
    kd[dgn_no - 1].ku.key[2] = 0;
    kd[dgn_no - 1].ku.key[3] = 0;
    size = sizeof ( key_dgn ) - 8;		/* dont write pointers */
    status = write(sef_file_desc[active_file], &kd[dgn_no - 1], size );
    dgn_no = dgn_no + 1;
    }
  else
    {
    status = close( sef_file_desc[active_file] );
    sef_file_desc[active_file] = -1;
    data_reservoir[active_file] = 1;		/* only system and design data remain */
    

    }
  return ( one );
}


#ifndef _ENVELOPE_AR_

SEF_APPEND_FILE( file_name )

  char		*file_name;
{
  static unsigned	file_protection = 0400|0200|0100|0040|0020|0010|0004 ;
  static int   flags = O_RDWR;

  active_file = 0;
  data_reservoir[0] = 0;
  first_sef_write = 1;
  file_access_mode = 1;
  sef_file_desc[active_file] = open( file_name, flags , file_protection );
  if ( sef_file_desc[active_file] < 0 )
    return ( sef_file_desc[active_file] );

  return ( one );
}

#endif

#ifndef _ENVELOPE_AR_
SEF_CLOSE_FILE(  )			/* 1 = properly closed */
{
  int			status , size , pos;
  component_data	comp;
  basic_shape_data	shape;
  design_data		dgn;
  short			d_no, c_no, s_no;
  double		ver = 2.0;

  if ( file_access_mode == 1 ) 		/* write to file */
    {
    ks.sys_dat.version = ver;		/* successful completion */
    if ( on_vax == 0 )
      {
      unconvert_double( &ks.sys_dat.version );
      }
    size = sizeof( ks );
    pos = lseek( sef_file_desc[active_file], no_offset, beginning );
    status = write ( sef_file_desc[active_file] , &ks , size );
    d_no = 1;
    c_no = 1;
    status = SEF_READ_DGN( &d_no, &dgn );	/* sets file pointer */
    while ( SEF_READ_CMP( &d_no , &c_no , &comp ) == 1 )
      {
      SEF_WRITE_CMP_F( &d_no );
      s_no = 1;
      while ( SEF_READ_SHAPE( &d_no, &s_no, &shape ) == 1 )
        {
 	SEF_WRITE_SHAPE_F( &d_no );
	if ( shape.su.size[1] == 9 )
	  {
	  SEF_WRITE_BS_DATA_F( &shape );
	  }
        s_no = s_no + 1;
        }
      s_no = 1;
      while ( SEF_READ_HOLE( &d_no, &s_no, &shape ) == 1 )
        {
 	SEF_WRITE_HOLE_F( &d_no );
        s_no = s_no + 1;
        }
      c_no = c_no + 1;
      }
      c_no = c_no -1;
      status = SEF_READ_DGN( &d_no, &dgn );
      dgn.section_set[7] = c_no;
      status = SEF_WRITE_DGN( &dgn.model_no , &dgn );
    } 
  SEF_F_ALL( );		/* free all dynamic memory */
  status = close( sef_file_desc[active_file] );
  sef_file_desc[active_file] = -1;
  data_reservoir[active_file] = 1;		/* only system and design data remain */
  if ( status == 0 )
    return ( one );
  else
    return ( status );
}
#endif


SEF_CLOSE_FILE_ONLY( file_no )			/* 1 = properly closed */
  short		*file_no;
{
  int			status , size , pos;
  double		ver = 2.0;

  active_file = *file_no - 1;
  ks.sys_dat.version = ver;	/* successful completion */
    if ( on_vax == 0 )
      {
      unconvert_double( &ks.sys_dat.version );
      }
  size = sizeof( ks );
  pos = lseek( sef_file_desc[active_file], no_offset, beginning );
  status = write ( sef_file_desc[active_file] , &ks , size );
  status = close( sef_file_desc[active_file] );
  if ( status == 0 )
    return ( one );
  else
    return ( status );
}



#ifndef _ENVELOPE_AR_
SEF_OPEN_FILE_READ( file_name , type , file_no , con_tol )		/* -1 = cannot be opened */

  short		*type;				/* type= 0, will be able to read sys & dgn only */
  char		*file_name;	     	/* type= 1, download entire file to memory , will be able to read all */
  short		*file_no;	/* will set the index into kd, may be 1 or 2		*/
  int		*con_tol;	/* construction tolerance to be added to shapes 	*/
{
  static 	int	file_protection = 0400|0040|0004 ;
  static 	int	flags = O_RDONLY;
  int   	status;
  int		i;
  short		cmp_no , sh_no;
  basic_shape_data   shp ;
  component_data  cmp;
  design_data  dgn;
  int		reduction_tol;

 first_sef_write = 1;
 file_access_mode = 0;
 active_file = *file_no - 1;
 data_reservoir[active_file] = 2;		/* file is open for read */
 num_cmp[active_file] = 0;
 num_shp[active_file] = 0;

 if ( sef_file_desc[active_file] > 0 )
   {
   SEF_CLOSE_FILE( );
   }

 sef_file_desc[active_file] = open( file_name, flags, file_protection );
 if ( sef_file_desc[active_file] < 0 ) 
   return ( sef_file_desc[active_file] );
 else
   {
   data_reservoir[active_file] = 2;
   if ( *type == 1 ) 
     {
     SEF_DOWNLOAD_FILE( file_no );
     if ( *con_tol != 0 )
       {
       reduction_tol = ( *con_tol ) * (int) -1.0;
       status = SEF_READ_DGN( file_no , &dgn );		/* init dgn.range */
       cmp_no = 1;
       while( SEF_READ_CMP( file_no , &cmp_no , &cmp ) == 1 )
         {
	 status = SEF_WRITE_NONEXP_RANGE( file_no , &cmp.ru.range[0][0] ); 

	 sh_no = 1;
	 while( SEF_READ_SHAPE( file_no , &sh_no , &shp) == 1 )
	   {
           if( shape_is_ct_enabled( &cmp , &shp ) == 1 )
             {
	     exp_sh_( &cmp , &shp , con_tol );

             hard_soft.type = shp.su.size[3];
	     hard_soft.cl_type[1] = 4;		/* hard_soft = CT */
             shp.su.size[3] = hard_soft.type;

	     status = SEF_WRITE_EXP_SHAPE( file_no , &shp );
	     form_range_( cmp.ru.range , shp.ru.range , cmp.ru.range );
             }
	   sh_no = sh_no +1;
  	   }

	 sh_no = 1;
	 while( sef_read_soft_shape( file_no , &sh_no , &shp) == 1 )
	   {
           if( shape_is_ct_enabled( &cmp , &shp ) == 1 )
             {
	     exp_sh_( &cmp , &shp , con_tol );
             hard_soft.type = shp.su.size[3];
	     hard_soft.cl_type[1] = 4;		/* hard_soft = CT */
             shp.su.size[3] = hard_soft.type;
	     status = SEF_WRITE_EXP_SHAPE( file_no , &shp );
	     form_range_( cmp.ru.range , shp.ru.range , cmp.ru.range );
             }
	   sh_no = sh_no +1;
  	   }

	 sh_no =1;
	 while( SEF_READ_HOLE( file_no , &sh_no , &shp) == 1 )
	   {
	   exp_sh_( &cmp , &shp , &reduction_tol );

           hard_soft.type = shp.su.size[3];
	   hard_soft.cl_type[1] = 4;		/* hard_soft = CT */
           shp.su.size[3] = hard_soft.type;

	   shp.su.size[3] = 4;		/* hard_soft = CT */
	   status = SEF_WRITE_RED_HOLE( file_no , &shp );
	   sh_no = sh_no +1;
  	   }

	 status = SEF_REWRITE_CMP( file_no , &cmp );
	 if ( on_vax ) 
	   form_range( dgn.range , cmp.ru.range , dgn.range );
	 else
	   form_range_( dgn.range , cmp.ru.range , dgn.range );
	 cmp_no = cmp_no + 1;
	 }
       status = SEF_WRITE_DGN( file_no , &dgn );
       }
     }
   return ( one );
   }
}
#endif


#ifndef _ENVELOPE_AR_
SEF_DOWNLOAD_FILE( dgn_no )

short	*dgn_no;
{  
  short  buffer[768];
  char   first , old_insul;
  static int	status, buffer_size , size , machine_size;
  short  cmp_num, sh_num;
  struct	system_data 	sys;
  basic_shape_data   shp ;
  component_data  cmp;

  sef_downloading = 1;
  active_file = (*dgn_no) - 1;
  buffer_size = sizeof( buffer ); 
  status = 1;
  first = 1;
  sh_num = 0;
  cmp_num = 0;
  while ( status > 0 )
  {
    status = SEF_READ_NEXT_RECORD( &first, buffer );
    if ( status > 0 ) 
      {
      if ( buffer[3] > 0 )	
        {
	sh_num = sh_num + 1;
	size = buffer[4];
        memcpy( &shp , &buffer[4], size );

        modify_shape_env_type( &shp.su.size[3] );

	if ( shp.su.size[1] == 9 ) 		/* bs_header , get the bs_data */
	  {
          shp.geom.bs_head.bs_data = (int *) calloc( one, shp.geom.bs_head.bs_data_bytes );  		
	  SEF_READ_NEXT_BS_DATA( shp.geom.bs_head.bs_data , &shp.geom.bs_head.bs_data_bytes );
	  SEF_WRITE_SHAPE( dgn_no, &shp );  	/* writes shape to memory */
	  }
	else
	  {
	  if ( on_vax == 0  )	/* on clipper and data is in VAX */
	    CVT_SHAPE( &shp );			
	  if ( shp.su.size[3] == 0 ) 
            {
	    shp.su.size[3] = 1;			/* default to hard */
            modify_shape_env_type( &shp.su.size[3] );
            }
          if( ( old_insul == 1 ) && ( cmp.rs.r_d[0] > .001 ) &&
              ( shp.su.size[2] == 1 )) 
            {
            shp.su.size[3] = SOFT; 
            modify_shape_env_type( &shp.su.size[3] );
	    SEF_WRITE_SHAPE( dgn_no, &shp );  	
            stripins_( &kd[active_file].dgn_dat.uor_per_su , &cmp , &shp );
            shp.su.size[3] = HARD;
            modify_shape_env_type( &shp.su.size[3] );
	    SEF_WRITE_SHAPE( dgn_no, &shp );
            }
          else
            {
	    SEF_WRITE_SHAPE( dgn_no, &shp );
	    }
	  }
	}
      else if ( buffer[2] > 0 ) 	
	{
        sh_num = 0;
	cmp_num = cmp_num + 1;
        size = buffer[4];
	memcpy( &cmp , &buffer[4], size );
	if ( on_vax == 0 )	/* on Clipper and data is VAX format */
          {
	  CVT_COMP( &cmp );		
	  }


        if(( sys.version < 1.9 ) && (( cmp.su.size[3] == 5 ) ||
           ( cmp.su.size[3] == 3 ) || ( cmp.su.size[3] == 6 )) )  /* old insul*/ 
          {
          cmp.su.size[1] = 0;	/* clear special pipe like flags */
          cmp.su.size[2] = 0;
          old_insul = 1;
          }
        else
          {
          old_insul = 0;
          }

	if ( cmp.su.size[5] == 6 && cmp.su.size[6] > 0 ) /* eqp cps */
	  {
          size = cmp.su.size[6] * 12;
          cmp.cp_data.lrs.lrs_end1[0] = ( int ) calloc( one , size );  		
	  SEF_READ_NEXT_BS_DATA( ( int * ) cmp.cp_data.lrs.lrs_end1[0] ,
             &size );
          }
   

	SEF_WRITE_CMP( dgn_no, &cmp );		/* writes comp to memory */
	}
      else if ( buffer[1] > 0 ) 	
	{
	sh_num = 0;
	size = buffer[4];
	memcpy( &kd[active_file].dgn_dat , &buffer[4] , size );	
	}
      else
	{	
	sh_num = 0;		
	machine_size = sizeof( sys );
	size = buffer[4];
	if ( machine_size < size )
    	  {
  	  size = machine_size;
	  }
	memcpy( &sys , &buffer[4] , size );
	if ( on_vax == 0 )	/* on Clipper and data is VAX format */
          {
	  CVT_SYS( &sys );
 	  }
	}
      }
  }		/* end while */
sef_downloading = 0;
}
#endif


#ifndef _ENVELOPE_AR_
SEF_L_ALL( d_no )			/* write all comps & shapes from memory to log file */

  short		*d_no;		/* may be 1 or 2		*/

{
  component_data	comp;
  basic_shape_data	shape;
  design_data		dgn;
  short		        c_no, s_no;
  static	int	min_int=0x80000000 , max_int=0x7fffffff;
  int			file_range[6] , i;
  struct	system_data		sys;

  for( i = 0; i<=2; i++ )
    {
    file_range[i] = max_int;
    file_range[i+3] = min_int;
    }

  fprintf( log_file , "Begin logging all records\n" );
 
  SEF_READ_SYS( &sys );
  L_SYSTEM( &sys );
  SEF_READ_DGN( d_no, &dgn );
  L_DESIGN( &dgn );	
  c_no = 1;
  while ( SEF_READ_CMP( d_no , &c_no , &comp ) == 1 )
    {
    L_COMP( &comp );
    form_range_( file_range , comp.ru.range , file_range );
    if( range_within( dgn.range , comp.ru.range ) == 0 )
      {
      fprintf( log_file , " ERROR - component range not within design range\n " );
      }

    create_total_ccdpp_diagnostic_tree( comp.su.size[3], comp.nu.cmp_no[1] );

    s_no = 1;
    while ( SEF_READ_SHAPE( d_no, &s_no, &shape ) == 1 )
      {
      L_SHAPE( &shape );

      if( range_within( comp.ru.range , shape.ru.range ) == 0 )
        {
        fprintf( log_file , " ERROR - shape range not within component range\n " );
        }
      s_no = s_no + 1;
      }

    s_no = 1;
    while ( sef_read_soft_shape( d_no, &s_no, &shape ) == 1 )
      {
      L_SHAPE( &shape );
      if( range_within( comp.ru.range , shape.ru.range ) == 0 )
        {
        fprintf( log_file , " ERROR - shape range not within component range\n " );
        }
      s_no = s_no + 1;
      }

    s_no = 1;
    while ( SEF_READ_HOLE( d_no, &s_no, &shape ) == 1 )
      {
      L_SHAPE( &shape );
      if ( ( shape.su.size[1] != 1 ) && ( shape.su.size[1] != 4 ) )
        {
        fprintf( log_file , " ERROR - unsupported shape type for hole\n " );
        }
      s_no = s_no + 1;
      }
    c_no = c_no + 1;
    }
  if( range_within( file_range , dgn.range ) == 0 )
    {
    fprintf( log_file , " ERROR - envelope file range does not match calculated range\n " );
    }
}
#endif

#ifndef _ENVELOPE_AR_
SEF_LOG_KCS( dummy )
char	*dummy;
{
  *dummy = 0;
  fprintf( log_file , " SEF_LOG_KCS *******************************" );
  fprintf( log_file , "	kc[0].cmp_dat.nu.cmp_no(0)= %d\n", kc[0].cmp_dat.nu.cmp_no[0] );
  fprintf( log_file , "			.occ_no   = %d\n", kc[0].cmp_dat.nu.cmp_no[1] );
  fprintf( log_file , "			.ent_no   = %d\n", kc[0].cmp_dat.su.size[3] );
  fprintf( log_file , "	kc[1].cmp_dat.nu.cmp_no(0)= %d\n", kc[1].cmp_dat.nu.cmp_no[0] );
  fprintf( log_file , "			.occ_no   = %d\n", kc[1].cmp_dat.nu.cmp_no[1] );
  fprintf( log_file , "			.ent_no   = %d\n", kc[1].cmp_dat.su.size[3] );
  return 1;
}
SEF_LOG_KSS( dummy )
char	*dummy;
{
  *dummy = 0;
  fprintf( log_file , " SEF_LOG_KSS *******************************" );
  fprintf( log_file , "	ksp[0].ku.key[3] = %d\n", ksp[0].ku.key[3] );
  fprintf( log_file , "      .active_prim = %d\n", ksp[0].active_prim );
  fprintf( log_file , "	ksp[1].ku.key[3] = %d\n", ksp[1].ku.key[3] );
  fprintf( log_file , "      .active_prim = %d\n", ksp[1].active_prim );
  return 1;
}
#endif

SEF_INIT_SET( model_no )
short 	*model_no;
{

active_file = *model_no - 1;
num_cmp[active_file] = 0;

}


SEF_F_ALL( )
{

  key_cmp	*ac , *dc;
  key_shp	*as , *ds;
  key_shp       *ap , *dp;
  int           i;
  
for( i = 0; i < 2; i++ )
  {
  if ( ( int ) kd[i].first_comp > 0 ) 
    {
    ac = kd[i].first_comp;
    while( ( int ) ac > 0 )
      {
        
      as = ac->first_key_shp;
      while( ( int ) as > 0 )
        {
        ap = as->first_prim;
        while( ( int ) ap > 0 )
          {
          dp = ap;
          ap = ap->next_key_shp;
          free( dp );
          }
        ds = as;
        as = as->next_key_shp;		/* ? */
        free( ds );
        }

      as = ac->first_hole;
      while( ( int ) as > 0 )
        {
        ds = as;
        as = as->next_key_shp;
        free( ds );
        }
        
      as = ac->first_exp_hole;
      while( ( int ) as > 0 )
        {
        ds = as;
        as = as->next_key_shp;
        free( ds );
        }

      as = ac->first_exp_shp;
      while( ( int ) as > 0 )
        {
        ap = as->first_prim;
        while( ( int ) ap > 0 )
          {
          dp = ap;
          ap = ap->next_key_shp;
          free( dp );
          }
        ds = as;
        as = as->next_key_shp;		/* ? */
        free( ds );
        }

      as = ac->first_soft_shp;
      while( ( int ) as > 0 )
        {
        ap = as->first_prim;
        while( ( int ) ap > 0 )
          {
          dp = ap;
          ap = ap->next_key_shp;
          free( dp );
          }
        ds = as;
        as = as->next_key_shp;		/* ? */
        free( ds );
        }
        
      dc = ac;
      ac = ac->next_key_cmp;
      free( dc );
      }
    }
  kd[i].first_comp = 0;
  num_cmp[i] = 0;
  }
}



delete_expanded_shapes( file_no )
short	*file_no;

{

  key_cmp	*ac;
  key_shp	*as , *ds;

  short lactive_file;

  lactive_file = *file_no - 1;
  if ( ( int ) kd[lactive_file].first_comp > 0 ) 
    {
    ac = kd[lactive_file].first_comp;
    while( ( int ) ac > 0 )
      {
      as = ac->first_exp_shp;
      while( ( int ) as > 0 )
        {
        ds = as;
        as = as->next_key_shp;
        free( ds );
        }
      as = ac->first_exp_hole;
      while( ( int ) as > 0 )
        {
        ds = as;
        as = as->next_key_shp;
        free( ds );
        }
      ac = ac->next_key_cmp;
      }
    }

}




#ifndef _ENVELOPE_AR_
SEF_FREE_PRIM( dgn_no , cmp )
short		*dgn_no;		/* may be 1 or 2		*/
component_data  *cmp;

{

  static 	int	status;
  key_cmp	*ac;
  key_shp	*as , *dp , *ap;

  cmp->cu.chr[34] = 0;		/*reset emulation flag to not emulated	*/
  status = SEF_REWRITE_CMP( dgn_no , cmp );
  active_file = *dgn_no - 1;
  ac = kd[active_file].active_comp;
  if( ( int ) ac > 0 )
    {
    as = ac->first_key_shp;
    while( ( int ) as > 0 )
      {
      ap = as->first_prim;
      while( ( int ) ap > 0 )
        {  
	dp = ap;
	ap = ap->next_key_shp;
	free( dp );
        }

      as->first_prim = 0;
      as->active_prim = 0;

      as = as->next_key_shp;		/* ? */
      }
    }
}
sef_free_prim_( dgn_no , cmp )
short		*dgn_no;	
component_data  *cmp;
{
  SEF_FREE_PRIM( dgn_no , cmp );
}
sef_free_prim( dgn_no , cmp )
short		*dgn_no;	
component_data  *cmp;
{
  SEF_FREE_PRIM( dgn_no , cmp );
}
#endif



SEF_COPY_SET( d )
design_data	*d;
{
  int	size;

  kd[1] = kd[0];
  kd[1].dgn_dat.model_no = 2;
  size = sizeof( design_data );
  memcpy( d , &kd[1].dgn_dat , size );
  kd_scan[1] = kd[0];

}

SEF_REDUCE_SET( dgn_no )
short		*dgn_no;
{
key_cmp		*ac;

active_file = (*dgn_no) - 1;
ac = kd[active_file].first_comp;
kd[active_file].first_comp = ac->next_key_cmp;

}



#ifndef _ENVELOPE_AR_
SEF_FLUSH(  )		
{
  int	status;
  component_data	comp;
  basic_shape_data	shape;
  short		d_no, c_no, s_no;

  if ( file_access_mode == 1 ) 		
    {
    d_no = 1;
    c_no = 1;
    while ( SEF_READ_CMP( &d_no , &c_no , &comp ) == 1 )
      {
      SEF_WRITE_CMP_F( &d_no );
      s_no = 1;
      while ( SEF_READ_SHAPE( &d_no, &s_no, &shape ) == 1 )
        {
 	SEF_WRITE_SHAPE_F( &d_no );
        s_no = s_no + 1;
        }

      s_no = 1;
      while ( SEF_READ_SOFT_SHAPE( &d_no, &s_no, &shape ) == 1 )
        {
 	SEF_WRITE_SHAPE_F( &d_no );
        s_no = s_no + 1;
        }

      s_no = 1;
      while ( SEF_READ_HOLE( &d_no, &s_no, &shape ) == 1 )
        {
 	SEF_WRITE_HOLE_F( &d_no );
        s_no = s_no + 1;
        }
      c_no = c_no + 1;
      }
      c_no = c_no -1;

/*
      this would reset the file pointer
      status = SEF_READ_DGN( &d_no, &dgn );
      dgn.section_set[7] = c_no;
      status = SEF_WRITE_DGN( &dgn.model_no , &dgn );
*/

    } 
  SEF_F_ALL( );		
  first_sef_write = 1;			
  if ( status == 0 )
    return ( one );
  else
    return ( 0 );
}
#endif

#ifndef _ENVELOPE_AR_
SEF_OPEN_FILE_READ_VOLUME( file_name , type , file_no , volume , con_tol )		/* -1 = cannot be opened */
  int		*con_tol;
  int		*volume[];
  short		*type;				/* type= 0, will be able to read sys & dgn only */
  char		*file_name;	     	/* type= 1, download entire file to memory , will be able to read all */
  short		*file_no;	/* will set the index into kd, may be 1 or 2		*/
{
  static 	int	file_protection = 0400|0040|0004 ;
  static 	int	flags = O_RDONLY;
  int   	status;
  int		i;
  short		cmp_no , sh_no;
  basic_shape_data   shp ;
  component_data  cmp;
  design_data  dgn;
  int		reduction_tol;

 first_sef_write = 1;
 file_access_mode = 0;
 active_file = *file_no - 1;
 data_reservoir[active_file] = 2;		/* file is open for read */
 num_cmp[active_file] = 0;
 num_shp[active_file] = 0;

 sef_file_desc[active_file] = open( file_name, flags, file_protection );
 if ( sef_file_desc[active_file] < 0 ) 
   return ( sef_file_desc[active_file] );
 else
   {
   if ( *type == 1 ) 
     {
     SEF_DOWNLOAD_FILE_VOLUME( file_no , volume );
     if ( *con_tol != 0 )
       {
       reduction_tol = ( *con_tol ) * ( int ) -1.0;
       status = SEF_READ_DGN( file_no , &dgn );		/* init dgn.range */
       cmp_no = 1;
       while( SEF_READ_CMP( file_no , &cmp_no , &cmp ) == 1 )
         {
	 status = SEF_WRITE_NONEXP_RANGE( file_no , &cmp.ru.range[0][0] ); 

	 sh_no = 1;
	 while( SEF_READ_SHAPE( file_no , &sh_no , &shp) == 1 )
	   {
           if( shape_is_ct_enabled( &cmp , &shp ) == 1 )
             {
	     exp_sh_( &cmp , &shp , con_tol );
             hard_soft.type = shp.su.size[3];
	     hard_soft.cl_type[1] = 4;		/* hard_soft = CT */
             shp.su.size[3] = hard_soft.type;
	     status = SEF_WRITE_EXP_SHAPE( file_no , &shp );
	     form_range_( cmp.ru.range , shp.ru.range , cmp.ru.range );
             }
	   sh_no = sh_no +1;
  	   }

	 sh_no = 1;
	 while( sef_read_soft_shape( file_no , &sh_no , &shp) == 1 )
	   {
           if( shape_is_ct_enabled( &cmp , &shp ) == 1 )
             {
	     exp_sh_( &cmp , &shp , con_tol );
             hard_soft.type = shp.su.size[3];
	     hard_soft.cl_type[1] = 4;		/* hard_soft = CT */
             shp.su.size[3] = hard_soft.type;
	     status = SEF_WRITE_EXP_SHAPE( file_no , &shp );
	     form_range_( cmp.ru.range , shp.ru.range , cmp.ru.range );
             }
	   sh_no = sh_no +1;
  	   }

	 sh_no =1;
	 while( SEF_READ_HOLE( file_no , &sh_no , &shp) == 1 )
	   {
	   exp_sh_( &cmp , &shp , &reduction_tol );
           hard_soft.type = shp.su.size[3];
	   hard_soft.cl_type[1] = 4;		/* hard_soft = CT */
           shp.su.size[3] = hard_soft.type;
	   status = SEF_WRITE_RED_HOLE( file_no , &shp );
	   sh_no = sh_no +1;
  	   }
	 status = SEF_REWRITE_CMP( file_no , &cmp );
	 if ( on_vax ) 
	   form_range( dgn.range , cmp.ru.range , dgn.range );
	 else
	   form_range_( dgn.range , cmp.ru.range , dgn.range );
	 cmp_no = cmp_no + 1;
	 }
       status = SEF_WRITE_DGN( file_no , &dgn );
       }
     }
   return ( one );
   }
}
#endif



#ifndef _ENVELOPE_AR_
SEF_DOWNLOAD_FILE_VOLUME( dgn_no , volume )
int	*volume[];
short	*dgn_no;

{  
  short  buffer[768];
  char   first , old_insul;
  static int	status, buffer_size , size , machine_size;
  short  cmp_num, sh_num;
  struct	system_data 	sys;
  basic_shape_data   shp ;
  component_data  cmp;
  static char  skip_component;
  static short  overlap;

  sef_downloading = 1;
  active_file = (*dgn_no) - 1;
  buffer_size = sizeof( buffer ); 
  status = 1;
  first = 1;
  sh_num = 0;
  cmp_num = 0;
  while ( status > 0 )
  {
    status = SEF_READ_NEXT_RECORD( &first, buffer );
    if ( status > 0 ) 
      {
      if ( buffer[3] > 0 )	
        {
	if ( skip_component == 0 )
	  {
	  sh_num = sh_num + 1;
	  size = buffer[4];
          memcpy( &shp , &buffer[4], size );

          modify_shape_env_type( &shp.su.size[3] );

	  if ( shp.su.size[1] == 9 ) 		/* bs_header , get the bs_data */
	    {
            shp.geom.bs_head.bs_data = (int *) calloc( one, shp.geom.bs_head.bs_data_bytes );  		
	    SEF_READ_NEXT_BS_DATA( shp.geom.bs_head.bs_data , &shp.geom.bs_head.bs_data_bytes );
	    SEF_WRITE_SHAPE( dgn_no, &shp );  	/* writes shape to memory */
	    }
	  else
	    {
	    if ( on_vax == 0 )	/* on clipper and data is in VAX */
	      CVT_SHAPE( &shp );			
	    if ( shp.su.size[3] == 0 ) 
              {
	      shp.su.size[3] = 1;			/* default to hard */
              modify_shape_env_type( &shp.su.size[3] );
              }

            if( ( old_insul == 1 ) && ( cmp.rs.r_d[0] > .001 ) &&
              ( shp.su.size[2] == 1 )) 
              {
              shp.su.size[3] = SOFT; 
              modify_shape_env_type( &shp.su.size[3] );
	      SEF_WRITE_SHAPE( dgn_no, &shp );  	
              stripins_( &kd[active_file].dgn_dat.uor_per_su , &cmp , &shp );
              shp.su.size[3] = HARD;
              modify_shape_env_type( &shp.su.size[3] );
	      SEF_WRITE_SHAPE( dgn_no, &shp );
              }
            else
              {
	      SEF_WRITE_SHAPE( dgn_no, &shp );
	      }
	    }
	  }
	
	else		/* always check for splines */
	  {
	  sh_num = sh_num + 1;
	  size = buffer[4];
          memcpy( &shp , &buffer[4], size );
	  if ( shp.su.size[1] == 9 ) 		/* bs_header , get the bs_data */
	    {
            shp.geom.bs_head.bs_data = (int *) calloc( one, shp.geom.bs_head.bs_data_bytes );  		
	    SEF_READ_NEXT_BS_DATA( shp.geom.bs_head.bs_data , &shp.geom.bs_head.bs_data_bytes );
	    }
	  }
	}
      else if ( buffer[2] > 0 ) 	
	{
        sh_num = 0;
	cmp_num = cmp_num + 1;
        size = buffer[4];
	memcpy( &cmp , &buffer[4], size );
	if ( on_vax ) 
	  {
	  check_ranges( volume , cmp.ru.range , &overlap );
	  }
	else
	  {
	  CVT_COMP( &cmp );		
	  check_ranges_( volume , cmp.ru.range , &overlap );
	  }
	if ( overlap == 0 )
	  {
	  skip_component = 1;
	  if ( cmp.su.size[5] == 6 && cmp.su.size[6] > 0 ) /* eqp cps */
	    {
            size = cmp.su.size[6] * 12;
            cmp.cp_data.lrs.lrs_end1[0] = ( int ) calloc( one , size );  		
	    SEF_READ_NEXT_BS_DATA( ( int * ) cmp.cp_data.lrs.lrs_end1[0] ,
               &size );
	    free( ( int * ) cmp.cp_data.lrs.lrs_end1[0] );
            }

	  }
	else
	  {

          if(( sys.version < 1.9 ) && (( cmp.su.size[3] == 5 ) ||
             ( cmp.su.size[3] == 3 ) || ( cmp.su.size[3] == 6 )) )  /* old insul*/ 
            {
            cmp.su.size[1] = 0;	/* clear special pipe like flags */
            cmp.su.size[2] = 0;
            old_insul = 1;
            }
          else
            {
            old_insul = 0;
            }

	  if ( cmp.su.size[5] == 6 && cmp.su.size[6] > 0 ) /* eqp cps */
	    {
            size = cmp.su.size[6] * 12;
            cmp.cp_data.lrs.lrs_end1[0] = ( int ) calloc( one , size );  		
	    SEF_READ_NEXT_BS_DATA( ( int * ) cmp.cp_data.lrs.lrs_end1[0] ,
               &size );
            }

	  SEF_WRITE_CMP( dgn_no, &cmp );		/* writes comp to memory */
	  skip_component = 0;
	  }
	}
      else if ( buffer[1] > 0 ) 	
	{
	sh_num = 0;
	size = buffer[4];
	memcpy( &kd[active_file].dgn_dat , &buffer[4] , size );	
	}
      else
	{	
	sh_num = 0;		
	size = buffer[4];
	machine_size = sizeof( sys );
	if ( machine_size < size )
    	  {
  	  size = machine_size;
	  }

	memcpy( &sys , &buffer[4] , size );
	if ( on_vax == 0 )	/* on Clipper and data is VAX format */
          {
	  CVT_SYS( &sys );
 	  }
	}
      }
  }		/* end while */
sef_downloading = 0;
}
#endif


#ifndef _ENVELOPE_AR_
sef_read_shape_overlap_( in_range , dgn_no , shp_no , shape , overlap )		/* reads comp from memory */
int			*in_range;
short			*overlap;
short			*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( sef_read_shape_overlap( in_range , dgn_no , 
  shp_no , shape , overlap ));
}
#endif


sef_close_file_only_( file_no )			/* 1 = properly closed */
  short		*file_no;
{
return( SEF_CLOSE_FILE_ONLY( file_no ));
}


#ifndef _ENVELOPE_AR_
sef_scan_cmp_lid_( dgn_no, ent , occ , comp ) 	/* scans comp from memory */
short		*dgn_no;
short		*ent;
int		*occ;
component_data	*comp;
{
return(SEF_SCAN_CMP_LID( dgn_no, ent , occ , comp ));
}
#endif
#ifndef _ENVELOPE_AR_
sef_scan_cmp_lid( dgn_no, ent , occ , comp ) 	/* scans comp from memory */
short		*dgn_no;
short		*ent;
int		*occ;
component_data	*comp;
{
return(SEF_SCAN_CMP_LID( dgn_no, ent , occ , comp ));
}
#endif

#ifndef _ENVELOPE_AR_
sef_scan_cmp( dgn_no, cmp_no, comp ) 		/* scans comp from memory */
short		*dgn_no;
short		*cmp_no;
component_data	*comp;
{
return( SEF_SCAN_CMP( dgn_no, cmp_no, comp ));
}
#endif

sef_write_cmp_file_( dgn_no, cmp_no, comp )		/* writes from memory to file */
short		*dgn_no;
short		*cmp_no;
component_data	*comp;
{
return(SEF_WRITE_CMP_FILE( dgn_no, cmp_no, comp ));
}


sef_write_cmp_file( dgn_no, cmp_no, comp )		/* writes from memory to file */
short		*dgn_no;
short		*cmp_no;
component_data	*comp;
{
return(SEF_WRITE_CMP_FILE( dgn_no, cmp_no, comp ));
}



sef_rewrite_cmp_range_file (range)
int	range [2][3];
{
return( SEF_REWRITE_CMP_RANGE_FILE (range));
}

sef_rewrite_cmp_range_file_ (range)
int	range [2][3];
{
return( SEF_REWRITE_CMP_RANGE_FILE (range));
}



sef_write_shape_file( dgn_no, shp_no, shape )		/* writes from memory to file */
short		 	*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_WRITE_SHAPE_FILE( dgn_no, shp_no, shape ));
}

sef_write_shape_file_( dgn_no, shp_no, shape )		/* writes from memory to file */
short		 	*dgn_no;
short			*shp_no;
basic_shape_data	*shape;
{
return( SEF_WRITE_SHAPE_FILE( dgn_no, shp_no, shape ));
}



sef_write_cp_file( no_more_points , p )
short	*no_more_points;
int	p[3];
{
return( SEF_WRITE_CP_FILE( no_more_points , p ));
}

sef_write_cp_file_( no_more_points , p )
short	*no_more_points;
int	p[3];
{
return( SEF_WRITE_CP_FILE( no_more_points , p ));
}



sef_close_file_only( file_no )
  short		*file_no;
{
return( SEF_CLOSE_FILE_ONLY( file_no ) );
}
