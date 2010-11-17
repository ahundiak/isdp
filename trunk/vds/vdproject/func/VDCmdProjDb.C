/* $Id: VDCmdProjDb.C,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdproject/func / VDCmdProjDb.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdProjDb.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
 *	Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	"igrtypedef.h"
#include	"OMprimitives.h"
#include	"vdbmacros.h"

#define		MAX_WORD	81
#define		MAX_WHERE_SIZE	400

IGRint	VDGetProjectAssmb(project,proj_rev,ass_cat,ass_part,ass_rev,nb_assmb)
IGRchar		*project;
IGRchar		*proj_rev;
IGRchar		***ass_cat;
IGRchar		***ass_part;
IGRchar		***ass_rev;
IGRint		*nb_assmb;
{
   int		i;
   char		*table;
   char		select[MAX_WHERE_SIZE];
   char		search[MAX_WHERE_SIZE];
   int		n_attr;
   int		num,ret_msg;
   char		**buffer;

   sprintf( select,"%s","assembly_cat,assembly_nam,assembly_ver");
   table = "VDS_PROJECT_PARTS";
   if(strcmp(proj_rev,"NULL"))
      sprintf( search, "prj_number = '%s' and prj_version = '%s'",
		   project,proj_rev);
   else
      sprintf( search, "prj_number = '%s'", project);
   n_attr = 3;
   ret_msg =  
   vdb$RisSelect(  select     =    select,
                   table_name =    table,
                   where      =    search,
                   order      =    NULL,
                   group      =    NULL,
                   numselect  =    n_attr,
                   p_numrows  =    &num,
                   p_buffer   =    &buffer );

   if ( ret_msg != 1 ) return 0;
 
   if (num == 0)
   {
      *nb_assmb = 0;
      vdb$RisFreeBuffer ( buffer  =    buffer,
                          size    =    n_attr*num);
      return 1;
   }
   else
   {
      *nb_assmb = num;
      *ass_cat = (char **) om$malloc (size= (*nb_assmb) * sizeof(char *));
      *ass_part = (char **) om$malloc (size= (*nb_assmb) * sizeof(char *));
      *ass_rev = (char **) om$malloc (size= (*nb_assmb) * sizeof(char *));

      for( i=0; i < (*nb_assmb); i++ )
      {
	 (*ass_cat)[i] = (char *) malloc ( MAX_WORD * sizeof(char));
	 (*ass_part)[i] = (char *) malloc ( MAX_WORD * sizeof(char));
	 (*ass_rev)[i] = (char *) malloc ( MAX_WORD * sizeof(char));

	 strcpy((*ass_cat)[i], buffer[i*n_attr]);
	 strcpy((*ass_part)[i], buffer[i*n_attr + 1]);
	 strcpy((*ass_rev)[i], buffer[i*n_attr + 2]);
      }
   }
   vdb$RisFreeBuffer( buffer   =     buffer,
                      size     =      n_attr*num );

   return 1;
}

int  VDGetProjectParts( project, proj_rev, family, partnum, partrev, nb_parts)
IGRchar		*project;
IGRchar		*proj_rev;
IGRchar		***family;
IGRchar		***partnum;
IGRchar		***partrev;
IGRint		*nb_parts;
{
   int		i,ret_msg;
   char		*table;
   char		select[MAX_WHERE_SIZE];
   char		*search;
   int		n_attr;
   int		num;
   char		**buffer;
   char		**ass_cat;
   char		**ass_part;
   char		**ass_rev;
   int		nb_assmb;
   int		search_size;
   int		sts;

   if(VDGetProjectAssmb(project,proj_rev,&ass_cat,&ass_part,&ass_rev,&nb_assmb) != 1)
     return 0;

   sprintf( select,"%s","family,partno,partrev");
   table = "COMPART_DYNAMIC";

   /*
    * MM, ADZ: We estimate that the total size for the where string does not
    *		pas the limit of 200.
    *  Like:
    * "assembly_cat = 'x' and assembly_nam = 'x' and assembly_ver = 'x'  or"
    */

   search_size = ( nb_assmb * 200 );

   search = NULL;
   search = (char *)om$malloc( size = search_size * (sizeof( char )));
   if( ! search ){
	printf(" Malloc failed in VDGetProjectParts \n");
	sts = 0;
	goto wrapup;
   }
	

   if( nb_assmb != 0)
   {
      if(VDprep_dyntab_srch( ass_cat,ass_part,ass_rev,nb_assmb,search) != 1)
      {
	*nb_parts = 0;
	sts = 1;
	goto wrapup; 
      }
   }
   else
   {
      *nb_parts = 0;
      sts = 1;
      goto wrapup;
   }

   n_attr = 3;
   ret_msg = 
   vdb$RisSelect(  select      =   select,
                   table_name  =   table,
                   where       =   search,
                   order       =   NULL,
                   group       =   NULL,
                   numselect   =   n_attr,
                   p_numrows   =   &num,
                   p_buffer    =   &buffer );

   if ( ret_msg != 1 ){
	sts = 0;
	goto wrapup;
   }

   if (num == 0)
   {
      *nb_parts = 0;
      vdb$RisFreeBuffer ( buffer   =      buffer,
                          size     =      n_attr*num);
      sts = 1;
      goto wrapup;
   }
   else
   {
      *nb_parts = num;
      *family = (char **) malloc ( *nb_parts * sizeof(char *));
      *partnum = (char **) malloc ( *nb_parts * sizeof(char *));
      *partrev = (char **) malloc ( *nb_parts * sizeof(char *));

      for( i=0; i < (*nb_parts); i++ )
      {
	 (*family)[i] = (char *) malloc ( MAX_WORD * sizeof(char));
	 (*partnum)[i] = (char *) malloc ( MAX_WORD * sizeof(char));
	 (*partrev)[i] = (char *) malloc ( MAX_WORD * sizeof(char));

	 strcpy((*family)[i], buffer[i*n_attr]);
	 strcpy((*partnum)[i], buffer[i*n_attr + 1]);
	 strcpy((*partrev)[i], buffer[i*n_attr + 2]);
      }
   }
   vdb$RisFreeBuffer(  buffer      =      buffer,
                       size        =      n_attr*num );

   sts = 1;

wrapup:

  if( search ) om$dealloc( ptr = search );
  return sts;
}


IGRint VDprep_dyntab_srch( ass_cat,ass_part,ass_rev,nb_assmb,search)
IGRchar		**ass_cat;
IGRchar		**ass_part;
IGRchar		**ass_rev;
IGRint		nb_assmb;
IGRchar		*search;
{
   int		i;
   char		tmp_str[200];

   if( nb_assmb != 0)
   {
     sprintf( search,
	    "assembly_cat = '%s' and assembly_nam = '%s' and assembly_ver = '%s' ",
	    (ass_cat)[0],(ass_part)[0],(ass_rev)[0] );

     for ( i = 1; i < nb_assmb; i++ )
     {
       sprintf(tmp_str, " or assembly_cat = '%s' and assembly_nam = '%s' and assembly_ver = '%s' ", (ass_cat)[i],(ass_part)[i],(ass_rev)[i] );
       strcat(search,tmp_str);
     }
   }
   else return 0;

   return 1;
}

