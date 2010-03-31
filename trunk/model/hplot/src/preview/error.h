#ifndef ERROR_H
#define ERROR_H

#define CHECK_DL_ERROR( stat ) \
   if ( (stat) != DL_SUCCESS ) \
      { \
      fprintf( stderr, "DL ERROR: %d in file %s at line: %d\n",  \
         stat, __FILE__, __LINE__ ); \
      exit( 1 ); \
      }
 
#define CHECK_WL_ERROR( stat ) \
   if ( (stat) != WL_SUCCESS ) \
      { \
      fprintf( stderr, "WL ERROR: %d in file %s at line: %d\n",  \
         stat, __FILE__, __LINE__ ); \
      exit( 1 ); \
      }
 
#endif
