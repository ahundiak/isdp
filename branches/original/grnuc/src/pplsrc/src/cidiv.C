/*
 *	Etienne   BEEKER
 *	Dominique GARDELLA
 *
 * contient des routines diverses pour l'interpreteur de commandes
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

#include <errno.h>
#include <ctype.h>
#include <string.h>

extern char			errmess[] ;
extern struct instance_ci	*ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;
extern struct CI_FILE_DES	Ci_file_des[];	

extern char *malloc();


int CIgetvarno(s, xdata)
char *s;
struct instance_ci *xdata;
/*
 * renvoie l'indice de s dans la table tab
 */
{
    register i;

#ifdef DEBUG
printf("CIgetvarno: xdata = %d,  nbvar = %d, var: %s\n", (int)xdata, xdata->nbvar, s);
fflush(stdout);
#endif

    for( i=0; i<xdata->nbvar; i++){
	if (strcmp(xdata->vartable[i], s) == 0)
	    return i;
    }
    
    return -1;
}


int getnofile(nom, new_use)
char	*nom,		/* name of the file or process */
	 new_use;	/* read or write? ordinary file or process ? */
/*
** Teste si le fichier de nom "nom" figure dans la table "file_des".
** Si le fichier est rencontre pour la premiere fois, il y est insere.
** Valeur retournee :
**   indice dans 'file_des' si O.K., -1 sinon.
** Modifications:
** - 08/09/87: Expansion des eventuelles variables 'shell' contenues dans 'nom'.
** - 11/09/87: Argument supplementaire du a l'implementation des 'pipes'.
*/
{
    int i_f;		/* indice du fichier */
    int i1, i2,		/* indices sur nom */
    	j;		/* indice sur 'nom_E' */
    char nom_E[80],	/* 'nom' expanse */
    	 sh_var[80],	/* valeur d'une variable 'shell' */
    	*ptr,		/* some mere pointer pointing on somewhere */
	 old_use,	/* what has already be done with the file */
	*getenv();	/* c.f. doc. 3C */
    static char prems = 1;	/* degeu. mais provisoire*/

/* Au premier appel, il faut initialiser 'Ci_file_des' */
    if ( prems )
    {
	for (i_f = 0; i_f < MAX_FILE; i_f++)
	{
	    *Ci_file_des[i_f].name = 0;
	    Ci_file_des[i_f].state = 0;
	}
	prems = 0;
    }

/* Expansion des eventuelles variables 'shell' dans 'nom' */
    i1 = j = 0;
    if ( new_use & 0xC )    /* DG 17/09: pas d'expansion pour les commandes */
	strcpy(nom_E, nom);
    else
        while ( 1 )
        {
	    if ((ptr = strchr(nom + i1, '$')) == NULL)
	    {
	        strcpy(nom_E + j, nom + i1);
	        break;
	    }
	    else
	    {
	        i2 = ptr - nom;
	        strncpy(nom_E + j, nom + i1, i2 - i1);
	        j += i2 - i1;
	        i1 = i2;
	        for (; nom[i2] != '/' && nom[i2] != 0; i2++) ;
	        strncpy(sh_var, nom + i1 + 1, i2 - i1);
	        sh_var[i2 - i1 - 1] = 0;
	        if ((ptr = getenv(sh_var)) == NULL)
	        {
	    	    nom_E[j] = '$';
	    	    i1++; j++;
		    continue;
	        }
	        else
	        {
		    strcpy(nom_E + j, ptr);
		    j += strlen(ptr);
		    i1 = i2;
	        }
	    }
        }

/* Recherche dans la table des fichiers deja rencontres */
    for (i_f = 0; i_f < MAX_FILE; i_f++)
	if ( !strcmp(nom_E, Ci_file_des[i_f].name)
	  || !strcmp(nom, Ci_file_des[i_f].name) )
	{
	    /* Verification de la coherence de la requete */
	    old_use = Ci_file_des[i_f].state;
	    if ( ( (old_use & 0x3) && (new_use & 0xC) )
	      || ( (old_use & 0xC) && (new_use & 0x3) ) )
	    {
		sprintf(errmess,
		"%s cannot be considered a command and a file at the same time",
		nom_E);
		erreur(errmess);
		return -1;
	    }
            return i_f;
	}

/* Pour un 'pipe', il est sympa de verifier ici que l'executable existe, popen
   ne decelant auncune erreur dans le cas contraire. */
/*    if ( (new_use & 0xC) && (access(nom_E, 1) == -1) )
/*    {
/*	sprintf(errmess, "%s: Cannot access, %s", nom_E, sys_errlist[errno]);
/*	erreur(errmess);
/*	return -1;
/*    }
*/

/* Si new_use == 0, on se contente de rechercher un fichier deja existant */
    if ( !new_use )
	return -1;

/* Recherche d'une place disponible dans la table et M.a.j. de celle_ci */
    for (i_f = 0; i_f < MAX_FILE; i_f++)
	if ( !(*Ci_file_des[i_f].name) )
	    break;
    if ( i_f >= MAX_FILE )
    {
	erreur("too many open files");
	return -1;
    }
    strcpy(Ci_file_des[i_f].name, nom_E);
    Ci_file_des[i_f].state = 0;
    return i_f;
}


erreur(s)
char *s;
{
    fprintf(stderr, "CI: %s\n", s);
    fflush(stderr);
    UI_status(s);
}


linerreur(s, linenumber)
char *s;
int linenumber;
{
	fprintf(stderr, "CI: line %d:%s\n", linenumber, s);
}


int ischar( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is of type character, 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    if ( ci_data->vartypetable[var_nb] == CI_CHAR )
	return 1;
    else
	return 0;
}


int isshort( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is of type short integer, 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    if ( ci_data->vartypetable[var_nb] == CI_SHORT )
	return 1;
    else
	return 0;
}


int isint( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is of type integer, 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    if ( ci_data->vartypetable[var_nb] == CI_INT )
	return 1;
	
    return 0;
}

int ispointer( var_nb )
int var_nb ;		/* variable number */
{
    if( ci_data->vartypetable[var_nb] & PTR )
	return 1;
	
    return 0;
}


int isdouble( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is of type double, 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    if ( ci_data->vartypetable[var_nb] == CI_DOUBLE )
	return 1;
    else
	return 0;
}


isfunction( var_nb )
int var_nb ;		/* variable number */
{
    return ( ci_data->varflagtable[var_nb] & CI_FUNC );
}


isextern( var_nb )
int var_nb ;		/* variable number */
{
    return ( ci_data->varflagtable[var_nb] & CI_XTRN );
}


int isGRobj( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is an object, 0 otherwise.
** AF Sept 88: GRobj must be compatible with ints to allow OM_S_OBJID to work!
*/
int var_nb ;		/* variable number */
{
	return (    ci_data->vartypetable[var_nb] == CI_GROBJ
		 || ci_data->vartypetable[var_nb] == CI_INT  );
}


int isstring( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is of type string of characters, 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    /* array of CHAR */
    if ( ( ci_data->vartypetable[var_nb] == CI_CHAR )
      && ( ci_data->vardimtable[var_nb] > 0 ) )
	return 1;

    /* pointer on CHAR */
    if (  ci_data->vartypetable[var_nb] == ( CI_CHAR | PTR ) )
	return 1;

    return 0;
}


int ispoint( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is of type point ( i.e. a 3 doubles array ), 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    /* array of more than 3 doubles */
    if( (ci_data->vartypetable[var_nb] == CI_DOUBLE)
     &&(ci_data->vardimtable[var_nb] >= 3 ) )
	return 1;

    /* pointer on doubles */
    if( ci_data->vartypetable[var_nb] == ( CI_DOUBLE | PTR ))
	return 1;

    return 0;
}


int isarray( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, is an array (whatever the type of the elements), 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    if ( (ci_data->vardimtable[var_nb] > 0) )
	return 1;

    return 0;
}


int isnumvalue( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, has a numeric value, 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    if ( isintvalue(var_nb) )
	return 1;
    if( isdouble(var_nb) && !isarray(var_nb) )
        return 1;

    return 0;
}


int isintvalue( var_nb )
/*   Return 1 if the variable, whose index is var_nb in the variable 
** table, has an integer value, 0 otherwise.
*/
int var_nb ;		/* variable number */
{
    if ( ( ischar(var_nb) || isshort(var_nb) || isint(var_nb) )
        && !isarray(var_nb) )
        return 1;
    if(ispointer(var_nb))
        return 1;
    return 0;
}


int isstruct( var_nb )
int var_nb ;		/* variable number */
{
    if( ci_data->vartypetable[var_nb] == CI_STRUCT )
	return 1;
	
    return 0;
}

/*----------------------------------------------------------------------------*/
int alloc_ci_IGE( p_IGEinfo )

ci_IGE **p_IGEinfo ;

/* -- Allocates data related to IGE. Must be called AFTER "alloc_ci_data".
      OUTPUT : address of pointer to malloc
      RETURNS: TRUE if successfully completed,
	       FALSE if memory allocation failed.
      
      EB Dec 1, '87
      add initialization
   -- */

{
	if (( *p_IGEinfo = (ci_IGE *) malloc( sizeof( ci_IGE ) ) ) == NULL )
   		return FALSE ;

	/* initialization */
	/* prompts and status messages */
/* RM
	( *p_IGEinfo )->flagprompt = FALSE ;
	strcpy( ( *p_IGEinfo )->promptmess , "" ) ;
	strcpy( ( *p_IGEinfo )->messagemess, "" ) ;
   end RM */
	return TRUE ;
}
/*----------------------------------------------------------------------------*/
void free_ci_IGE( IGEinfo )

ci_IGE *IGEinfo ;

/* -- Frees data related to IGE. Must be called BEFORE "free_ci_data".
      INPUT : pointer to structure to be freed
   -- */

{
   free( IGEinfo ) ;
}
/*----------------------------------------------------------------------------*/
cieditvar(i)
int i;
/* debug */
{
	int	ty, *p_i, ind, dim ;
	short	*p_s ;
	double	*p_d ;

	ty = ci_data->vartypetable[i];

/* Index, name, address */
  printf( "var #%d name = <%s> address = %d", i, ci_data->vartable[i], cival(i) ) ;
  fflush(stdout);
  
  if( isarray( i ) ) {
	if( isstring( i ) ) {
		printf( "STRING = <%s>\n", st_cival(i) ) ;
	} else {
		dim = ci_data->vardimtable[i] ;

		switch( ty ) {
			case CI_INT	:
			printf( "ARRAY of ints " ) ;
			p_i = (int *)cival( i ) ;
			for( ind = 0 ; ind < dim ; ind++ ) {
				printf( "\t[%d]:\t%d\n", ind, p_i[ind] ) ;
			}
			break ;
			case CI_SHORT	:
			printf( "ARRAY of shorts " ) ;
			p_s = (short *)cival( i ) ;
			for( ind = 0 ; ind < dim ; ind++ ) {
				printf( "\t[%d]:\t%d\n", ind, p_s[ind] ) ;
			}
			break;
			case CI_DOUBLE	:
			printf( "ARRAY of doubles " ) ;
			p_d = (double *)cival( i ) ;
			for( ind = 0 ; ind < dim ; ind++ ) {
				printf( "\t[%d]:\t%lf\n", ind, p_d[ind] ) ;
			}
			break;
	      		default:
			break;
		}
	}
  	fflush(stdout);
  } else {
	/* pointer */
	if( ty & PTR ) printf( "POINTER (%u) TO ", p_cival( i ) );
	ty &= (~PTR);

	/* type */
	switch( ty ) {
		case CI_INT	: printf( "INT "	); break;
		case CI_SHORT	: printf( "SHORT "	); break;
		case CI_DOUBLE	: printf( "DOUBLE "	); break;
		case CI_CHAR	: printf( "CHAR "	); break;
		case CI_GROBJ	: printf( "GROBJ "	); break;
		case CI_STRUCT	: printf( "STRUCT "	); break;
		case CI_VOID	: printf( "VOID "	); break;
		default		: printf( "UNKNOWN TYPE :%d ", ty ); break;
	}
	printf( "\n" ) ;
	fflush(stdout);
  }
}		


void editinstr( instr )
struct ci_instruction *instr;
/*
 * edit one instr for debugging, very tacky way
 */
{
	int j,k;

	printf("line %d, type %d nbinstr %d\n", 
		instr->paramlist[instr->nbparam], instr->type, instr->nbparam );
	fflush(stdout);
  	for(j=0; j<instr->nbparam;j++){
  		k = instr->paramlist[j];
		if ( k>=0 && k <ci_data->nbvar )
			printf("\tpm %d : %s\n",j,ci_data->vartable[k]);
			fflush(stdout);
	}
	
}
