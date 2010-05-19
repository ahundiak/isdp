/* $Id: VDSequip_ut.C,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDSequip_ut.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSequip_ut.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
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
 * Revision 1.2  1996/03/07  21:44:02  pinnacle
 * Replaced: vdutil/VDSequip_ut.C for:  by msmanem for vds.240
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
 *	03/07/96	 Mallik		Fix for TR#179600126
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	"igrtypedef.h"
#include	"OMprimitives.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
/*#include 	"VDSequipdef.h"*/
#include	"VDSutil.h"
/* #include 	"AS_status.h" */

#include	"vdbmacros.h"

#define AS_DEBUG

#define	MAX_WORD	81  /* 81 because 80 + \0 = 81 */
#define MAX_WHERE_SIZE  300

extern double 	VDconv_to_vdsunits();

/*
/* VDSget_equip_cat:
/*
/* Get the list of macro equipment catalog and corresponding macro lib name.
/* The partdesc is used as a search criterion (should be "equipment").
/* The array of catalogs is allocated by this function and must be deallocated
/* by the user. To deallocate it, first deallocate equip_list[i] and afterward
/* equip_list. Do the same for macro_lib_partno.
/*
/* */

int VDSget_equip_cat ( partdesc, nb_equip, equip_list, macro_lib_partno,
                       macro_lib_rev)
char           *partdesc;          /* criterion "equipment"         (I) */
int            *nb_equip;          /* Nb equip macro lib found      (O) */
char           ***equip_list;      /* array of equip macro lib name (O) */
char           ***macro_lib_partno;/* array of equip macro lib partno (O) */
char           ***macro_lib_rev;   /* array of equip macro lib rev (O) */
{
  int          i;
  char         table[MAX_WORD];
  char         select[MAX_WHERE_SIZE];
  char         search[MAX_WHERE_SIZE];
  char         order[MAX_WORD];
  char         n_attr;
  char         **buffer;
  int          num,ret_msg;

  sprintf( select, "%s", "n_itemname, n_itemrev");
  sprintf( table , "%s", "pdmlibraries");
  sprintf( search, "%s = '%s'", "n_itemdesc", partdesc);
  sprintf( order , "%s", "n_itemname");
  n_attr = 2;
  ret_msg = 
  vdb$RisSelect(  select      =     select,
                  table_name  =     table,
                  where       =     search,
                  order       =     order,
                  group       =     NULL,
                  numselect   =     n_attr,
                  p_numrows   =     &num,
                  p_buffer    =     &buffer );
 
  if ( ret_msg != 1 ) return 0;

  if (num == 0)
  {
    /* printf("No row found\n");*/
    *nb_equip = 0;
    vdb$RisFreeBuffer (   buffer    =       buffer,
                          size      =        n_attr*num);
    return(1);
  }
  else
  {
    *nb_equip = num;
    *equip_list = (char **) om$malloc (size=(*nb_equip)*sizeof(char*));
    *macro_lib_partno = (char **) om$malloc (size=(*nb_equip)*sizeof(char*));
    *macro_lib_rev = (char **) om$malloc (size=(*nb_equip)*sizeof(char*));
    if((*equip_list) == NULL || (*macro_lib_partno) == NULL
        || (*macro_lib_rev) == NULL) {printf("error malloc\n"); return 0;}

    for(i=0; i<(*nb_equip); i++)
    {
      (*equip_list)[i] = (char *) om$malloc (size=MAX_WORD * sizeof(char));
      (*macro_lib_partno)[i] = (char *) om$malloc (size=MAX_WORD * sizeof(char));
      (*macro_lib_rev)[i] = (char *) om$malloc (size=MAX_WORD * sizeof(char));
      if((*equip_list)[i] == NULL || (*macro_lib_partno)[i] == NULL
          || (*macro_lib_rev)[i] == NULL) 
                {printf("error malloc\n"); return 0;}

      strcpy((*macro_lib_partno)[i],buffer[0+i*n_attr]);
      strcpy((*macro_lib_rev)[i],buffer[1+i*n_attr]);
    }
  }
 vdb$RisFreeBuffer (   buffer    =       buffer,
                       size      =       n_attr*num);


  /* Get the name of the macro lib */
  /* must use the table f_pdmlibraries with the joint on
  /* pdmlibraries.n_itemno = f_pdmlibraries.n_itemnum and the
  /* name of the macro library is given by: n_cofilename
  /* */
  /* */
  /* BUT NOW WE CONCIDERE THAT THE NAME OF THE MACRO LIB IS THE SAME AS
  /* THE NAME OF THE PART ....
  /* */

  for(i=0; i<(*nb_equip); i++)
  {
    strcpy((*equip_list)[i],(*macro_lib_partno)[i]);
  }

  return(1);
}


int VDSget_families(macro_lib_partno, macro_lib_rev, nb_family, family_name)
char        *macro_lib_partno;/* Macro library part number     (I) */
char        *macro_lib_rev;    /* Macro library revision        (I) */
int         *nb_family;         /* number of family retieved (O) */
char        ***family_name;     /* array of family name      (O) */
{
  int       i;
  char      table[MAX_WORD];
  char      select[MAX_WHERE_SIZE];
  char      search[MAX_WHERE_SIZE];
  char      order[MAX_WORD];
  char      n_attr;
  char      **buffer;
  int       num,ret_msg;

  sprintf( select, "%s", "n_catalogname");
  sprintf( table , "%s", "pdmparamloc");
  sprintf( search, "%s = '%s' and %s = '%s' and %s = '%s'",
           "p_macrocat","pdmlibraries","p_macropartno", macro_lib_partno,
           "p_macrorev",macro_lib_rev);
  sprintf( order , "%s", "n_catalogname");
  n_attr = 1;
  ret_msg = 
   vdb$RisSelect(  select       =       select,
                   table_name   =       table,
                   where        =       search,
                   order        =       order,
                   group        =       NULL,
                   numselect    =       n_attr,
                   p_numrows    =       &num,
                   p_buffer     =       &buffer );
  if ( ret_msg != 1) return 0;

  if (num == 0)
  {
    /*printf("No row found\n");*/
    *nb_family = 0;
    vdb$RisFreeBuffer ( buffer   =      buffer,
                        size     =      n_attr*num);
    return(1);
  }
  else
  {
    *nb_family = num;
    *family_name = (char **) om$malloc (size=(*nb_family)*sizeof(char*));
    if((*family_name) == NULL) {printf("error malloc\n"); return 0;}

    for ( i=0; i<(*nb_family); i++)
    {
      (*family_name)[i] = (char *) om$malloc (size=MAX_WORD * sizeof(char));
      if((*family_name)[i] == NULL) {printf("error malloc\n"); return 0;}
      strcpy((*family_name)[i],buffer[0+i*n_attr]);
    }
  }
  vdb$RisFreeBuffer (   buffer      =       buffer,
                        size        =       n_attr*num);
  return(1);
}

int VDSget_family_parts(family_name, nb_parts, part_names, revision_names)
char        *family_name;              /* family name               (I) */
int         *nb_parts;                 /* number of parts retieved  (O) */
char        ***part_names;             /* array of part names       (O) */
char        ***revision_names;         /* array of part revisions   (O) */
{
  int       i;
  char      table[MAX_WORD];
  char      select[MAX_WHERE_SIZE];
  char      order[MAX_WORD];
  char      n_attr;
  char      **buffer;
  int       num,ret_msg;

  sprintf( select, "%s", "n_itemname,n_itemrev");
  sprintf( table , "%s", family_name);
  sprintf( order , "%s", "n_itemname");
  n_attr = 2;
  ret_msg = 
  vdb$RisSelect(  select         =    select,
                  table_name     =    table,
                  where          =    NULL,
                  order          =    order,
                  group          =    NULL,
                  numselect      =    n_attr,
                  p_numrows      =    &num,
                  p_buffer       =    &buffer );
  if ( ret_msg != 1) return 0;

  if (num == 0)
  {
    /*printf("No row found\n");*/
    *nb_parts = 0;
    vdb$RisFreeBuffer (  buffer     =       buffer,
                         size       =       n_attr*num);
    return(1);
  }
  else
  {
    *nb_parts = num;
    *part_names     = (char **) om$malloc (size=(*nb_parts)*sizeof(char*));
    *revision_names = (char **) om$malloc (size=(*nb_parts)*sizeof(char*));
    if((*part_names) == NULL || *revision_names == NULL) 
           {printf("error malloc\n"); return 0;}

    for ( i=0; i<(*nb_parts); i++)
    {
      (*part_names)[i]     = (char *) om$malloc (size=MAX_WORD * sizeof(char));
      (*revision_names)[i] = (char *) om$malloc (size=MAX_WORD * sizeof(char));
      if((*part_names)[i] == NULL || (*revision_names)[i] == NULL) 
               {printf("error malloc\n"); return 0;}
      strcpy((*part_names)[i],buffer[0+i*n_attr]);
      strcpy((*revision_names)[i],buffer[1+i*n_attr]);
    }
  }
  vdb$RisFreeBuffer (  buffer     =       buffer, 
                       size       =       n_attr*num);
  
  return(1);
}

/* ----------------------------------------------------------------------*/
/*
   VDSget_attr:
  
  	This function returns the parameters with their types, theirs values
   and all which are interesting to create a rg_collection. The returned 
   attributes are split into two structures, one for the dynamic, one
   for the static.
  
   	Inside the static returned structure, the family name, part name
   and the revision has been added at the begining.
  
   Notes:
  
  	The VDSatt_equip structures "attr" are allocated by this function 
   and must be freed by the user.
  	
   For me to do:
  	  Get the SC not template.
  
*/  
/* ----------------------------------------------------------------------*/

VDSget_attr(family, part, part_rev, category, nb_stat, stat_attr,
	    nb_dyn, dyn_attr)
char   *family;                     /* family name               (I) */
char   *part;                       /* part name                 (I) */
char   *part_rev;                   /* part revision             (I) */
char   *category;		    /* Category EQUIP/NOT EQUIP	 (I) */
int    *nb_stat;                    /* number of static attr     (O) */
struct VDSatt_family   **stat_attr;  /* static attribute descipt  (O) */
int    *nb_dyn;                     /* number of dyn attr        (O) */
struct VDSatt_family   **dyn_attr;   /* dynamic attribute descipt (O) */
{

  struct ACrg_coll  *static_att = NULL;
  struct ACrg_coll  *dynamic_att = NULL;
  int		    i;

  UI_status (" Querying Database for Attributes .... " );

  if(!VDSGetPartAtt(family,part,part_rev,category, /*int    stat_attr_filled,*/
		nb_stat,&static_att,nb_dyn,&dynamic_att)) return 0;
  if( *nb_stat != 0)
  {
   *stat_attr = (struct VDSatt_family *) om$malloc(size=*nb_stat * sizeof(struct
 VDSatt_family));
   if(*stat_attr == NULL)
   {
    UI_status("ERROR in VDSget_attr, Bad dynamic space alloc");
    return 0;
   }
  }
  for( i =0; i < *nb_stat; i++ )
  {
    strcpy((*stat_attr)[i].attr.name,static_att[i].name );
    (*stat_attr)[i].stat_dyn = STAT_ATTR;
    (*stat_attr)[i].attr.desc.type = static_att[i].desc.type;
    if( static_att[i].desc.type == AC_ATTRIB_TEXT )
      strcpy((*stat_attr)[i].attr.desc.value.att_txt, static_att[i].desc.value.att_txt );
    else
      (*stat_attr)[i].attr.desc.value.att_exp=static_att[i].desc.value.att_exp;
  }

  /* Dynamic Attributes */
  if( *nb_dyn != 0)
  {
   *dyn_attr = (struct VDSatt_family *) om$malloc(size=*nb_dyn * sizeof(struct
 VDSatt_family));
   if(*dyn_attr == NULL)
   {
    UI_status("ERROR in VDSget_attr, Bad dynamic space alloc");
    return 0;
   }
  }
  for( i =0; i < *nb_dyn; i++ )
  {
    strcpy((*dyn_attr)[i].attr.name,dynamic_att[i].name );
    (*dyn_attr)[i].stat_dyn = DYN_ATTR;
    (*dyn_attr)[i].attr.desc.type = dynamic_att[i].desc.type;

/* PL 2 June 94 bug correction dynamic_att and not static_att */

    if( dynamic_att[i].desc.type == AC_ATTRIB_TEXT )
      strcpy((*dyn_attr)[i].attr.desc.value.att_txt, dynamic_att[i].desc.value.att_txt );
    else
      (*dyn_attr)[i].attr.desc.value.att_exp=dynamic_att[i].desc.value.att_exp;
  }

free:
  if(static_att) om$dealloc( ptr = static_att );
  if(dynamic_att) om$dealloc( ptr = dynamic_att );

  return 1;
}

VDSfree_arrays( nb, array1, array2, array3 )
int	nb;
char	**array1;
char	**array2;
char	**array3;
{
    int i;

    if ( array1 != NULL )
    {
	for(i=0;i<nb;i=i+1)
	   if (array1[i] != NULL) om$dealloc(ptr=array1[i]);
	om$dealloc(ptr=array1);
    }
    if ( array2 != NULL )
    {
	for(i=0;i<nb;i=i+1)
	   if (array2[i] != NULL) om$dealloc(ptr=array2[i]);
	om$dealloc(ptr=array2);
    }
    if ( array3 != NULL )
    {
	for(i=0;i<nb;i=i+1)
	   if (array3[i] != NULL) om$dealloc(ptr=array3[i]);
	om$dealloc(ptr=array3);
    }
}

int VdsRemoveNfmPdmAttributes( n_cols, n_rows, attr_buf )
int	n_cols;
int	*n_rows;
char	**attr_buf;
{
	/* The idea is to strip the buffer from all the attributes
	   having nfm or pdm attributes.
	   conditions:  The first attribute is n_name.
	*/

	int	i,j,k;
	char	*p_old;

	for ( i=0, j=0; i < *n_rows; i++ )
	{
	    if ( (strncmp( (attr_buf)[i * n_cols], "n_",2) == 0) ||
		 (strncmp( (attr_buf)[i * n_cols], "p_",2) == 0))
		 continue;
	    else
	    {
	      if( i != j)
	      {
		for ( k = 0; k < n_cols; k++ )
		{
		 /* strcpy((attr_buf)[j*n_cols+k], (attr_buf)[i*n_cols+k] ); */
		   p_old = (attr_buf)[j*n_cols+k];
		   (attr_buf)[j*n_cols+k] = (attr_buf)[i*n_cols+k];
		   (attr_buf)[i*n_cols+k] = p_old;
		}
	      }
	      j++;
	   } 
	}

	/* Free the remaining unwanted rows */

	for( i = j; i < *n_rows; i++)
	{
	   for ( k = 0; k < n_cols; k++ )
	      if ((attr_buf)[i*n_cols+k] != NULL) 
			om$dealloc(ptr=(attr_buf)[i*n_cols+k]);
	}

	*n_rows = j; 

	return 1;
}
