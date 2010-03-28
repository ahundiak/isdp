/*
** ciio.C
**
** Dominique GARDELLA
**
** Contains the only function dealing with files before I/O: ci_file_prep
** Contains the functions achieving the I/O.
*/

 
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "codef.h"
#include "grerr.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"

#include <fcntl.h>
#include <errno.h>


static FILE   *Ci_fin, *Ci_fout;

extern struct instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;

extern struct CI_FILE_DES Ci_file_des[MAX_FILE];
extern char errmess[];
extern char *sys_errlist[];		/* SystemV error messages */

ci_file_prep(instr)
/*
**   Update Ci_fin or Ci_fout, which are the file descriptors used by
** ciread/ciwrite. Prepare the corresponding file for the next
** Input/Output. The first parameter in the instruction represents the
** I/O function number while the second one is the index of the variable
** containing the name of the file.
** Returns 1 when O.K., 0 otherwise.
*/
struct ci_instruction *instr;
{
    register short p0, p1, ind;
    p0 =  instr->paramlist[0];
    p1 =  instr->paramlist[1];

    /* file index */
    if ( strcmp(ci_data->vartable[p0], "write") )
    {   char io_bit;		/* to determine if it's a file or a process */
	if ( *ci_data->vartable[p0] == 'p' )
	    io_bit = P_READ_BIT;
	else
	    io_bit = READ_BIT;
	if ( (ind = getnofile(st_cival(p1), io_bit)) == -1 )
	    return 0;
    }

    if ( !strcmp(ci_data->vartable[p0], "aread")
      || !strcmp(ci_data->vartable[p0], "fread") )
    {
 	/* Open the file for reading, if necessary */
	if ( !(Ci_file_des[ind].state & READ_BIT) )
	{
	    if ( (Ci_fin = fopen(Ci_file_des[ind].name, "r+")) == NULL )
	    {
	    	erreur_io(instr, Ci_file_des[ind].name, "open for reading");
		return 0;
	    }

            /* Update Ci_file_des */
	    Ci_file_des[ind].state |= READ_BIT ;
	    Ci_file_des[ind].r_strm = Ci_fin;
	}
	else
	    Ci_fin = Ci_file_des[ind].r_strm;

	/* aread: read from the current location in the file */
	/* fread: read from the beginning of the file */
        if ( !strcmp(ci_data->vartable[p0], "fread") )
        {
	    /* Set the position at the beginning of the file */
	    if ( fseek(Ci_file_des[ind].r_strm, 0L, 0) != 0 )
	    {
		erreur_io(instr, Ci_file_des[ind].name, "seek");
		return 0;
	    }
        }
    }

    else if( !strcmp(ci_data->vartable[p0], "write") )
        Ci_fout = stdout;

    else if ( !strcmp(ci_data->vartable[p0], "fwrite") )
    {
	/* Write from the beginning of the file */
	/* Eventually, close the file (keep the process tidy) */
	if ( Ci_file_des[ind].state & READ_BIT )
	    if ( fclose(Ci_file_des[ind].r_strm) != 0 )
	    {
		erreur_io(instr, Ci_file_des[ind].name, "close");
	    	return 0;
	    }
	if ( Ci_file_des[ind].state & WRITE_BIT )
	    if ( fclose(Ci_file_des[ind].w_strm) != 0 )
	    {
		erreur_io(instr, Ci_file_des[ind].name, "close");
	    	return 0;
	    }

	/* Eventually, remove the stream */
	if ( access(Ci_file_des[ind].name, 0) == 0 )
	    if ( unlink(Ci_file_des[ind].name) != 0 )
	    {
	        /* What does happen if other processes have also the */
	        /* file open at that time ( XXX l'enigme du sphynx ) */
		erreur_io(instr, Ci_file_des[ind].name, "unlink");
		return 0;
	    }

	/* Create the stream, enabling writing */
	if ( (Ci_fout = fopen(Ci_file_des[ind].name, "a")) == NULL )
	{
	    erreur_io(instr, Ci_file_des[ind].name, "open for writing");
	    return 0;
	}

        /* Update Ci_file_des */
	Ci_file_des[ind].state = WRITE_BIT;
	Ci_file_des[ind].w_strm = Ci_fout;
    }

    else if ( !strcmp(ci_data->vartable[p0], "awrite") )
    {
	/* Append at the end of the file */
	/* Open the file for writing, if necessary */
	if ( !(Ci_file_des[ind].state & WRITE_BIT) )
	{
	    if ( (Ci_fout = fopen(Ci_file_des[ind].name, "a")) == NULL )
	    {
		erreur_io(instr, Ci_file_des[ind].name, "open for writing");
		return 0;
	    }

            /* Update Ci_file_des */
	    Ci_file_des[ind].state |= WRITE_BIT;
	    Ci_file_des[ind].w_strm = Ci_fout;
	}
	else
	    Ci_fout = Ci_file_des[ind].w_strm;
    }

    else if ( !strcmp(ci_data->vartable[p0], "pread") )
    {
	/* Open a pipe for reading, if necessary */
	if ( !(Ci_file_des[ind].state & P_READ_BIT) )
	{
	    if ( (Ci_fin = (FILE *)popen(Ci_file_des[ind].name, "r")) == NULL )
	    {
		erreur_io(instr, Ci_file_des[ind].name, "popen for reading");
		return 0;
	    }

            /* Update Ci_file_des */
	    Ci_file_des[ind].state |= P_READ_BIT;
	    Ci_file_des[ind].w_strm = Ci_fin;
	}
	else
	    Ci_fin = Ci_file_des[ind].r_strm;
    }

    else if ( !strcmp(ci_data->vartable[p0], "pwrite") )
    {
	/* Open a pipe for writing, if necessary */
	if ( !(Ci_file_des[ind].state & P_WRITE_BIT) )
	{
	    if ( (Ci_fout = (FILE *)popen(Ci_file_des[ind].name, "w")) == NULL )
	    {
		erreur_io(instr, Ci_file_des[ind].name, "popen for writing");
		return 0;
	    }

            /* Update Ci_file_des */
	    Ci_file_des[ind].state |= P_WRITE_BIT;
	    Ci_file_des[ind].w_strm = Ci_fout;
	}
	else
	    Ci_fout = Ci_file_des[ind].w_strm;
    }

    else		/* Erreur logicielle */
    {
	erreur("Unknown i/o function");
        return 0;
    }
    return 1;
}


/* AF : error checking removed: conflicts with STOP window:
   After STOP window has been hit fprintf always returns -1 althought is
   has printed correctly...
#define CIM_SCAN(v1,v2) \
  { if ( fscanf(Ci_fin, v1, v2) <= 0 ) \
    { \
	sprintf(errmess, "read error, %s, line %d", sys_errlist[errno], \
		instr->paramlist[instr->nbparam]); \
	erreur(errmess); \
	i_cival(instr->paramlist[0]) = 0; \
	return 1; \
  } }
 */
#define CIM_SCAN(v1,v2) fscanf(Ci_fin, v1, v2) ;

/* AF : error checking removed: conflicts with STOP window:
   After STOP window has been hit fprintf always returns -1 althought is
   has printed correctly...
#define CIM_WRITE(v1,v2) \
  { if ( fprintf(Ci_fout, v1, v2) < 0 ) \
    { \
	sprintf(errmess, "write error, %s, line %d", sys_errlist[errno], \
		instr->paramlist[instr->nbparam]); \
	erreur(errmess); \
	i_cival(instr->paramlist[0]) = 0; \
	return 1; \
  } }
 */
#define CIM_WRITE(v1,v2) fprintf(Ci_fout, v1, v2) ;

int ciread(instr)
struct ci_instruction *instr;
/*
 * Read variables from the file 'Ci_fin'.
 */
{
    register ivar, i, j, dim;

    if ( ci_file_prep( instr ) == 0 )
 	return ISUCCESS;

    for (i=2; i<instr->nbparam; i++)
    {
        ivar = instr->paramlist[i];
	dim = ci_data->vardimtable[ivar];
	if ( dim == 0 )
		dim = 1;

        if( isstring(ivar) )
           CIM_SCAN("%s", st_cival(ivar))
        else if ( ischar(ivar) )
	   CIM_SCAN("%c", cival(ivar))
        else if ( isshort(ivar) )
	   for(j=0; j<dim; j++)
                 CIM_SCAN("%hd", ((short *)(cival(ivar))) + j)
        else if ( isint(ivar) )
	   for(j=0; j<dim; j++)
                 CIM_SCAN("%d", ((int *)(cival(ivar))) + j)
        else if ( isdouble(ivar) )
	   for(j=0; j<dim; j++)
                 CIM_SCAN("%lf", ((double *)(cival(ivar))) + j)
        else if ( isGRobj(ivar) )
	   for(j=0; j<dim; j++)
                 CIM_SCAN("%d", ((int *)(cival(ivar))) + j)
	else
	{
	    sprintf(errmess, "unexpected type for read: %d",
		    ci_data->vartypetable[ivar]);
	    erreur(errmess);
	    return 1;
	}
   }
   i_cival(instr->paramlist[0]) = 1;
   return 1;
}


int ciwrite(instr)
struct ci_instruction *instr;
/*
 * writes variables on the file 'Ci_fout'.
 */
{
    register int ivar, i0, i, j, dim;

    if ( ci_file_prep( instr ) == 0 )
	return ISUCCESS;


    if ( !strcmp(ci_data->vartable[instr->paramlist[0]], "write") )
	i0 = 1;
    else
	i0 = 2;


    for (i=i0; i<instr->nbparam; i++)
    {
	ivar = instr->paramlist[i];

	dim = ci_data->vardimtable[ivar];
	if( dim == 0 )
		dim = 1;

 	if ( isstring(ivar) )
	    CIM_WRITE("%s", st_cival(ivar))
	else if ( ischar(ivar) )
	    CIM_WRITE("%c", c_cival(ivar))
 	else if ( isshort(ivar) )
	    for(j=0; j<dim; j++)
		CIM_WRITE("%hd ", ((short *)(cival(ivar)))[j])
	else if ( isint(ivar) )
	    for(j=0; j<dim; j++)
		CIM_WRITE("%d ", ((int *)(cival(ivar)))[j])
	else if ( isdouble(ivar) )
	    for(j=0; j<dim; j++)
		CIM_WRITE("%lf ", ((double *)(cival(ivar)))[j])
	else if ( isGRobj(ivar) )
	    for(j=0; j<dim; j++)
		CIM_WRITE("%d ", ((int *)(cival(ivar)))[j])
	else
	{
	    sprintf(errmess, "unexpected type for write: %d",
		    ci_data->vartypetable[ivar]);
	    erreur(errmess);
	    return 1;
	}
	fflush(Ci_fout);
   }

   i_cival(instr->paramlist[0]) = 1;
   return 1;
}


#undef CIM_SCAN
#undef CIM_WRITE

void ciclose_all()
/*
 * closes all files
 * called in ci.execute, in the sleep part
 */
{
	int i;

	for(i=0; i<MAX_FILE; i++) {
	      if( Ci_file_des[i].state & READ_BIT)
		   fclose(Ci_file_des[i].r_strm);
	      if( Ci_file_des[i].state & WRITE_BIT)
		   fclose(Ci_file_des[i].w_strm);
	      if( Ci_file_des[i].state & P_READ_BIT)
		   pclose(Ci_file_des[i].r_strm);
	      if( Ci_file_des[i].state & P_WRITE_BIT)
		   pclose(Ci_file_des[i].w_strm);
	      Ci_file_des[i].state = 0;
	      *Ci_file_des[i].name = 0;
	}
}

int ciclose(instr)
struct ci_instruction *instr;
/*
 * Free all the pointers on the file given in argument.
 * Free the corresponding line in 'Ci_file_des'
 */
{
    short ind;		/* file index */

    /* file index */
    if ( (ind = getnofile(st_cival(instr->paramlist[1]), 0)) == -1 )
    {
	sprintf(errmess, "close: cannot find %s in file table",
		st_cival(instr->paramlist[1]));
	erreur(errmess);
	return ISUCCESS;
    }

    /* Eventually, close the file */
    i_cival(instr->paramlist[0]) = 1;
    if ( Ci_file_des[ind].state & READ_BIT )
	if ( fclose(Ci_file_des[ind].r_strm) != 0 )
	{
	    erreur_io(instr, Ci_file_des[ind].name, "close (R)");
	    i_cival(instr->paramlist[0]) = 0;
	}
    if ( Ci_file_des[ind].state & WRITE_BIT )
	if ( fclose(Ci_file_des[ind].w_strm) != 0 )
	{
	    erreur_io(instr, Ci_file_des[ind].name, "close (P)");
	    i_cival(instr->paramlist[0]) = 0;
	}
    if ( Ci_file_des[ind].state & P_READ_BIT )
	if ( pclose(Ci_file_des[ind].r_strm) == -1 )
	{
	    erreur_io(instr, Ci_file_des[ind].name, "pclose (R)");
	    i_cival(instr->paramlist[0]) = 0;
	}
    if ( Ci_file_des[ind].state & P_WRITE_BIT )
	if ( pclose(Ci_file_des[ind].w_strm) == -1 )
	{
	    erreur_io(instr, Ci_file_des[ind].name, "pclose (W)");
	    i_cival(instr->paramlist[0]) = 0;
	}

    /* Update 'Ci_file_des' */
    Ci_file_des[ind].state = 0;
    *Ci_file_des[ind].name = 0;

    return ISUCCESS;
}


erreur_io(instr, file_name, msg)
struct ci_instruction *instr;
char	*file_name,
	*msg;
{
    sprintf(errmess, "%s: cannot %s, %s, line %d",
	    	file_name,
		msg,
		sys_errlist[errno],
		instr->paramlist[instr->nbparam]);
    erreur(errmess);
}

