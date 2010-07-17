/***************************************************************************
 * I/VDS
 *
 * File:        cprofiles.h
 *
 * Description:	
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/18/97        maciek          creation date
 *
 ***************************************************************************/
#ifndef myprofiles_include 
#define myprofiles_include

#include	<stdio.h>
#include	"OMprimitives.h"
#include	"cieveryone.h"
#include	"cimacros.h"
#include	"AS_status.h"
#include	"growner.h"
#include        "expmacros.h"

#include	"vdAPIequips.h"
#include        "vsAPImacros.h"
#include        "vdsmacros.h"

/* C externs */

extern calloc(), realloc(), gcvt();
extern GRdisplay_object();

/* MY CONSTANTS */

#define PROF_STR_MAX  20     // Length of text field in the Profiles table
#define PROF_SIZE_MAX 30     // Number of Profiles array

// PROFILE INFO VARIABLES
//***********************

struct Prof_size             // Created to simulate two dim string arrays
{
  char size[PROF_STR_MAX];
};

struct  Profile              // Profile info to store in the form
{
  char   name[PROF_STR_MAX];
  int    size_num;
  char   material[PROF_SIZE_MAX];
  char   grade[PROF_SIZE_MAX];
  struct Prof_size size[PROF_SIZE_MAX];
};



// COMPOSITE PROFILE INFO VARIABLES
//*********************************

struct CProf_size             // Created to simulate two dim string arrays
{
  char    size[PROF_STR_MAX];
  double  web_th, 
          web_h, 
          tfl_th, 
          tfl_w, 
          bfl_th, 
          bfl_w;
};

struct  CProfile              // Profile info to store in the form
{
         char       name[PROF_STR_MAX];
         char       lib[PROF_STR_MAX];
         char       macro[PROF_STR_MAX];
         int        size_num;
         char       material[PROF_SIZE_MAX];
         char       grade[PROF_SIZE_MAX];
  struct CProf_size size[PROF_SIZE_MAX];
};


ReadProfiles( fileName, dirToSearchFirst, dirInProdPathToSearchThen, Profiles )
//*****************************************************************************
         char         *fileName;
         char         *dirToSearchFirst;
         char         *dirInProdPathToSearchThen;
  struct Profile      *Profiles;
{
  char 			line[80], path[80], *ptr;
  FILE 			*fp;
  int  			i, j;

  i=0; j=0;

  // Open File
  //**********
  fp = vd$file_path(	msg                          = &msg,
			fileToFind                   = fileName,
			dirToSearchFirst             = dirToSearchFirst,
			dirInProdPathToSearchThen    = dirInProdPathToSearchThen,
			absPathName                  = path );

  printf("\nProfiles file: %s\n\n", path );
  fp = fopen( path, "rt" );
  if( fp == NULL )
    printf("Cannot open file\n");

  while( !feof( fp ) )
  {
    fgets( line, 80, fp );
    // Comment or invalid line - skip 
    //*******************************
    if( line[0] == '#' || line[0] == ' ' || line[0] == '\n' )
      continue;
    // Profile type line
    //******************
    if( line[0] == '%' )
    { 
      // If not first line - store last number of profile sizes read and set counter = 0
      //********************************************************************************
      if( i )
      {
	Profiles[i-1].size_num = j;
	j = 0;
      }
      // Store profile name
      //*******************
      strncpy( Profiles[i].name, line+1, PROF_STR_MAX-1 );
      rm_spaces( Profiles[i].name );
      i = i+1;
    }
    // Profile size type
    //******************
    else 
    {
      // Store profile size
      //*******************
      strncpy( Profiles[i-1].size[j].size, line, PROF_STR_MAX );
      rm_spaces( Profiles[i-1].size[j].size );
      j = j+1;
    }
  }
  fclose(fp);
  // Store last number of profile sizes
  //***********************************
  Profiles[i-1].size_num = j;
  return(i);
}

PrintProfiles( num, Profiles )
//****************************
       int        num;
struct Profile  *Profiles;
{
  int i, j;
  
  printf("READ %d PROFILES\n\n", num);
  
  for( i = 0; i < num; i = i + 1 )
  {
    printf("Profile %s has %d sizes:\n", Profiles[i].name, Profiles[i].size_num );
    for( j = 0; j < Profiles[i].size_num; j = j + 1 )
      printf("%s\n", Profiles[i].size[j].size );
    printf("\n");
  }
}


ReadCProfiles( fileName, dirToSearchFirst, dirInProdPathToSearchThen, Profiles )
//******************************************************************************
       char         *fileName;
       char         *dirToSearchFirst;
       char         *dirInProdPathToSearchThen;
struct CProfile     *Profiles;
{
  char 			line[80], txt[80],*ptr, path[80];
  FILE 			*fp;
  int  			i, j, k, l;

  i=0; j=0;

  // Open File
  //**********
  fp = vd$file_path(	msg                          = &msg,
			fileToFind                   = fileName,
			dirToSearchFirst             = dirToSearchFirst,
			dirInProdPathToSearchThen    = dirInProdPathToSearchThen,
			absPathName                  = path );

  printf("\nProfiles file: %s\n\n", path );
  fp = fopen( path, "rt" );
  if( fp == NULL )
    printf("Cannot open file\n");

  while( !feof( fp ) )
  {
    fgets( line, 80, fp );

    // Comment or invalid line - skip 
    //*******************************
    if( line[0] == '#' || line[0] == ' ' || line[0] == '\n' )
      continue;
    // Profile type line
    //******************
    if( line[0] == '%' )
    { 
      // If not first line - store last number of profile sizes read and set counter = 0
      //********************************************************************************
      if( i )
      {
	Profiles[i-1].size_num = j;
	j = 0;
      }
      // Store profile name
      //*******************
      word( line+1, Profiles[i].name, 1, ',' );
      word( line+1, Profiles[i].lib, 2, ',' );
      word( line+1, Profiles[i].macro, 3, ',' );
      i = i+1;
    }
    // Profile size type
    //******************
    else 
    {
      // Store profile size
      //*******************
      if( line[0] == ',' )   // End of data from Excel sheet
	goto wrapup;
      if( !strcmp( line, "" ) ) continue;

      word( line, Profiles[i-1].size[j].size, 1, ',' ); 

      word( line, txt, 2, ',' ); 
      Profiles[i-1].size[j].web_h = atof( txt );

      word( line, txt, 3, ',' ); 
      Profiles[i-1].size[j].web_th = atof( txt );

      word( line, txt, 4, ',' ); 
      Profiles[i-1].size[j].tfl_w = atof( txt );

      word( line, txt, 5, ',' ); 
      Profiles[i-1].size[j].tfl_th = atof( txt );

      word( line, txt, 6, ',' ); 
      Profiles[i-1].size[j].bfl_w = atof( txt );

      word( line, txt, 7, ',' ); 
      Profiles[i-1].size[j].bfl_th = atof( txt );

      strcpy( line, "" );
      Profiles[i-1].size_num = j;
      j = j+1;
    }
  }
wrapup:
  fclose(fp);
  // Store last number of profile sizes
  //***********************************
  Profiles[i-1].size_num = j;
  return(i);
}

PrintCProfiles( num, Profiles )
//*****************************
       int        num;
struct CProfile  *Profiles;
{
  int i, j;
  
  printf("READ %d PROFILES\n\n", num);
  
  for( i = 0; i < num; i = i + 1 )
  {
    printf("Profile %s (%s:%s) has %d sizes:\n", Profiles[i].name, Profiles[i].lib,  
	   Profiles[i].macro, Profiles[i].size_num );
    for( j = 0; j < Profiles[i].size_num; j = j + 1 )
      printf("Size[%d,%d]: %s [%gX%g + %gx%g + %gx%g]\n", i, j, Profiles[i].size[j].size, 
	     Profiles[i].size[j].web_h, Profiles[i].size[j].web_th, 
	     Profiles[i].size[j].tfl_w, Profiles[i].size[j].tfl_th,
	     Profiles[i].size[j].bfl_w, Profiles[i].size[j].bfl_th );
    printf("\n");
  }
}

GetProfIndex( text, count, Profiles )
//***********************************
       char     *text;
       int       count;
struct Profile  *Profiles;
{
  int i;
  
  for( i = 0; i < count; i = i+1 )
  {
    if( !strcmp( text, Profiles[i].name ) )
      break;
  }
  return(i);
}

GetCProfIndex( text, count, Profiles )
//************************************
       char      *text;
       int        count;
struct CProfile  *Profiles;
{
  int i;
  
  for( i = 0; i < count; i = i+1 )
  {
    if( !strcmp( text, Profiles[i].name ) )
      break;
  }
  return(i);
}

GetSecIndex( text, index, count, Profiles )
//*****************************************
       char     *text;
       int       index;
       int       count;
struct Profile  *Profiles;
{
  int i;
  
  for( i = 0; i < count; i = i+1 )
  {
    if( !strcmp( text, Profiles[index].size[i].size ) )
      break;
  }
  return(i);
}

GetSecCIndex( text, index, count, Profiles )
//******************************************
       char      *text;
       int        index;
       int        count;
struct CProfile  *Profiles;
{
  int i;
  
  for( i = 0; i < count; i = i+1 )
  {
    if( !strcmp( text, Profiles[index].size[i].size ) )
      break;
  }
  return(i);
}

#endif
