/* $Id: SMsearchvol.c,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMsearchvol.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMsearchvol.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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
 * Revision 1.2  1996/04/29  09:13:18  pinnacle
 * Replaced: smspace/func/SMsearchvol.c for:  by ksundar for vds.240
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

/* ********************************************************************* */
/* FILE : searchvol.c  */
/* Given loop on each surfaces, find if  a volume can be constructed */
/* Jean Jasinczuk (ISDC) */
/* Creation Date : June 92  */ 
/* ********************************************************************** */

  /* Algorithm : */
 /*  Let's call surface S0,S1,..,Sn . We generated all possible set with */
 /*  one loop on S0,S1,..Sn,S0,S1,...,Sn . A loop in the same surface can */
 /*  appear two times if there is no edge common to the two surfaces. */
 /*  We test then if each edge of each loop appear exactly two times . If so */
 /*  a solution is found. Else it's not a solution. */


#include <stdio.h>
#include <memory.h>
#include "VDmem.h"


/*#define DEBUG2	1*/
/*#define DEBUG1 1 */

/* Structure defining a loop on the surface */
struct one_loop
{
  int nb_edge;
  int 	*edge;
};

/* Struture defining  all the loop on one surface */
struct loop_on_surf
{
  int nb_loop;
  struct one_loop	*one_loop;
};


struct one_solid
{
  int nb_surf;
  int *surf_index;
  int *loop_index;
};



#define nombre_edge_sur_loop(loop) (loop ? loop->nb_edge : -1)
#define index_edge(loop,num_edge) (loop ? loop->edge[num_edge] : -1)

static void gener_possible_sol();
static int test_possible_sol();
static int increment_cur_loop();
static int copie_sol();
static void list_compatible();
static int cons_compatible();
static void free_compatible();

 /*************************************************************/
 /* SMfind_all_vol()                                          */
 /* This is main fonction to call                             */
 /* Given all loop existing on surfaces, retrieve all         */
 /* volumes which can be created                              */
 /* The solution is given by an array of one_solid of         */
 /* dimension [*nb_vol][nb_surf] .                            */
 /* If *nb_vol > 0 this array must be deallocated by user     */
 /* (call SMfree_all_vol(all_vol,nb_vol) )                    */
 /* It return 0 if memory failure else 1                      */
 /*************************************************************/
SMfind_all_vol(floop,nb_surf,max_edge,all_vol,nb_vol)
struct loop_on_surf floop[];  /* [I] Give all the loop on all surfaces */
int nb_surf;                  /* [I] Total number of surfaces */
int max_edge;                 /* [I] Total number of edge on all surfaces */
struct one_solid **all_vol;   /* [O] Solutions */
int *nb_vol;                  /* [O] Number of solutions found */ 
{
  int i;

  short *cur_loop = NULL;
  /* Index of the current loop to consider */

  struct one_loop **pos_vol = NULL;
  /* One possible solution : tempory array of the loop used */

  short *edge_marque = NULL;
  /* This array is used in the test : declare and allocate here only for speed */
 
  short ***compatible = NULL;
  /* Compatible is an array of nb_surf * nb_loop * nb_compatible_loop */
  /* which give all index of loop compatible with loop on the surface */

  short *sub_indice = NULL;
  /* For each surface, give the index of compatible loop to consider */
  /* To not recompute solution,sub_indice is always greater than */
  /* coresponding cur_loop index */
  
 
  int return_code = 1;

  *nb_vol = 0;
  *all_vol = NULL;

#ifdef DEBUG2
 {
   int i,j,k;

   for(i=0;i<nb_surf;i++)
    {
      printf("\nSurface %d \n",i);
      printf("Nombre de loop %d \n",floop[i].nb_loop);
      for(j=0; j<floop[i].nb_loop; j++)
       {
	 for(k=0 ; k < floop[i].one_loop[j].nb_edge; k++)
	   printf("%d ",floop[i].one_loop[j].edge[k]);
	 printf("\n");
       }
    }
 }
#endif

  /* If no surface or no edge return immediatly */
  if(nb_surf <= 0 || max_edge <= 0)
   { printf("No surface or no edge defined\n"); return 0;}
  
  edge_marque = _CALLOC(max_edge +1, short);
  cur_loop = _CALLOC(2 * nb_surf, short);
  pos_vol  = _CALLOC(2 * nb_surf, struct one_loop *);
  sub_indice = _CALLOC(2 * nb_surf, short);

  if(!edge_marque || !cur_loop || !pos_vol || !sub_indice)
   {printf("Not enough memory\n");return_code = 0; goto wrapup;}

  if(!cons_compatible(floop,nb_surf,&compatible))
    {printf("Not enough memory\n");return_code = 0; goto wrapup;}

  /* If no loop defined of one surface, initialise the loop taken on this */
  /* surf with -1*/
  for(i=0;i<nb_surf;i++)
    if(floop[i].nb_loop == 0) cur_loop[i] = -1; 

  do{
#ifdef DEBUG1
    int i;
    printf("Cur_loop :");
    for(i=0;i<nb_surf;i++) printf("%d ",cur_loop[i]);
    printf("Sub_indice :");
    for(i=0;i<nb_surf;i++) printf("%d ",sub_indice[i]);
    putchar('\n');
#endif

    gener_possible_sol(floop,nb_surf,pos_vol,cur_loop,compatible,sub_indice);
    if(test_possible_sol(nb_surf,pos_vol,edge_marque,max_edge))
      if(!copie_sol(all_vol,nb_vol,cur_loop,nb_surf,compatible,sub_indice))
	{ return_code = 0; goto wrapup; } 
   }while(increment_cur_loop(nb_surf - 1,floop,cur_loop,compatible,sub_indice));

 wrapup: 
  _FREE(edge_marque);
  _FREE(cur_loop) ;
  _FREE(pos_vol) ;
  _FREE(sub_indice) ;
  if(compatible) free_compatible(compatible,floop,nb_surf);
  return return_code;
}
 
/************************************/
/* SMfree_all_vol()                 */
/* Fonction to call to free memory  */
/************************************/
SMfree_all_vol(vol,nb_vol)
struct one_solid *vol;        /* [I] Solution returned by SMfind_all_vol */
int nb_vol;                   /* [I] Nb volumes returned by SMfind_all_vol */ 
{
  int i;

  if(vol == NULL || nb_vol <= 0) return 0;
  for(i=0;i<nb_vol;i++)
   {
     _FREE(vol[i].surf_index) ;
     _FREE(vol[i].loop_index) ;
   }
  _FREE(vol);
  return 1;
}


 /* Construct an array of pointer of one_loop . This array represents */
 /* a set of loop which must be test to find if it's a solution */
 /* */
static void gener_possible_sol(floop,nb_surf,pos_vol,cur_loop,
			      compatible,sub_indice)
struct loop_on_surf floop[];  /* [I] Give all the loop on all surfaces */
int nb_surf;                  /* [I] Total nomber of surface */
struct one_loop **pos_vol;   /* [O]  Loop pointer to test */
short *cur_loop;     /* [I] Array of indice of loop to construct possible sol */ 
short ***compatible; /* [I] Array of compatible loop on the same surface */
short sub_indice[];  /* [I] Array of the indice in compatible loop for a surf */
{
  int num_surf;

  for(num_surf = 0; num_surf < nb_surf; num_surf++)
   {
     if(cur_loop[num_surf] != -1)
      {
	pos_vol[num_surf] = &floop[num_surf].one_loop[cur_loop[num_surf]];
	if(compatible[num_surf] &&
	   compatible[num_surf][cur_loop[num_surf]][sub_indice[num_surf]] != -1)
	  pos_vol[num_surf + nb_surf] =
	    &floop[num_surf].one_loop[compatible[num_surf][cur_loop[num_surf]][sub_indice[num_surf]]];
	else
	  pos_vol[num_surf + nb_surf] = NULL; 
      }
     else
      {
	pos_vol[num_surf] = NULL;
	pos_vol[num_surf + nb_surf] = NULL;
      }
   }
}

/* Test if  an array of pointer of one_loop is a solution */ 
static int test_possible_sol(nb_surf,pos_vol,edge_marque,max_edge)
int nb_surf;               /* [I] */
struct one_loop **pos_vol; /* [I] */
short *edge_marque;        /* [I] */     
int max_edge;              /* [I] */
{
  int edge_to_mark;
  int num_surf;
  int num_edge;
  int nb_def = 0;

  /* Test if number of surface is sufficient */
  for(num_surf = 0; num_surf < 2 * nb_surf; num_surf++)
    if(pos_vol[num_surf]) nb_def++;
  if(nb_def < 2) return 0;

  memset(edge_marque,0,max_edge * sizeof(short));

  for(num_surf = 0; num_surf < 2 * nb_surf; num_surf++)
    for(num_edge = 0;
	num_edge < nombre_edge_sur_loop(pos_vol[num_surf]);
	num_edge++)
     {
       if((edge_to_mark = index_edge(pos_vol[num_surf],num_edge)) >= 0) 
	 edge_marque[edge_to_mark]++;
     }

  /* If it exists an edge which is used only one time or used more */
  /* than 2 time, it can't be a solution*/

  for(num_edge = 0; num_edge < max_edge ; num_edge++)
    if(edge_marque[num_edge] == 1 || edge_marque[num_edge] > 2)
      return 0;
     
  return 1;
}

 /* It increment the cur_loop indice and sub_indice to give the indice of loop */
 /* to consider on each surface */
static int increment_cur_loop(num_surf,floop,cur_loop,compatible,sub_indice)
int num_surf;  /* [I] */
struct loop_on_surf floop[]; /* [I] */
short cur_loop[]; /* [O] */
short ***compatible; /* [I] */
short sub_indice[];  /* [O] */
{
  if(cur_loop[num_surf] == -1)
    if(num_surf == 0) return 0 ; /* No more increment possible */
    else
     {
       if(floop[num_surf].nb_loop > 0 ) cur_loop[num_surf] = 0;
       return(increment_cur_loop(num_surf - 1,floop,cur_loop,
				 compatible,sub_indice));
     }
  if(cur_loop[num_surf] == floop[num_surf].nb_loop -1)
   {
     cur_loop[num_surf] = -1;
     return 1;
   }
  if(compatible[num_surf] &&
     compatible[num_surf][cur_loop[num_surf]][sub_indice[num_surf]] == -1)
   {
     cur_loop[num_surf] += 1;
     sub_indice[num_surf] = 0;
   }
  else
   {
     sub_indice[num_surf] += 1;
   }

  return 1;
}

#define INCREMENT 5 /* Increment of number of solution */

 /* When a solution is found put in the array of solutions (one_solid) */
 /* Verify a solution which contain this volume is not already in the array */
static int copie_sol(vol,nb_vol,cur_loop,nb_surf,compatible,sub_indice)
struct one_solid **vol;       /* [O] Solutions */ 
int *nb_vol;                  /* [O] Number of solution after copy current */
short *cur_loop;              /* [I] */
int nb_surf;                  /* [I] */
short ***compatible;          /* [I] */
short sub_indice[];           /* [I] */
{
  int i,j,k;
  short min,ind_min,ind_max,is_equal;

  if(*nb_vol)
   {
     if(!((*nb_vol+1) % INCREMENT))
      {
	*vol = _REALLOC (*vol,(*nb_vol + INCREMENT), struct one_solid);
	if(!*vol) return 0;
      }
   }
  else
   {
     *vol = _MALLOC(INCREMENT, struct one_solid);
     if(!*vol) return 0;
   }

  (*vol)[*nb_vol].surf_index = _MALLOC(2 * nb_surf, int);
  (*vol)[*nb_vol].loop_index = _MALLOC(2 * nb_surf, int);
  if(!(*vol)[*nb_vol].surf_index || !(*vol)[*nb_vol].loop_index)
    return 0;

  j = 0;
  for(i=0; i < nb_surf; i++)
   {
     if(cur_loop[i] != -1)
      {
	(*vol)[*nb_vol].surf_index[j] = i;
	(*vol)[*nb_vol].loop_index[j] = cur_loop[i];
	j++;
      }
   }

  for(i=0; i < nb_surf; i++)
   {
     if(cur_loop[i] != -1 && compatible[i][cur_loop[i]][sub_indice[i]] != -1)
      {
	(*vol)[*nb_vol].surf_index[j] = i;
	(*vol)[*nb_vol].loop_index[j] =
	  compatible[i][cur_loop[i]][sub_indice[i]];
	j++;
      }
   }
  
  (*vol)[*nb_vol].nb_surf = j;

  /* Verify the solution doesn't already exists (i.e a volume */
  /* with two unconnected componant) */
  for(i=0; i<= *nb_vol - 1; i++)
   {
     /* Examine each volume before this one */
     if((*vol)[*nb_vol].nb_surf <=  (*vol)[i].nb_surf)
       {
	 min = (*vol)[*nb_vol].nb_surf;
	 ind_min = (short) *nb_vol;
	 ind_max = i;
       }
     else
      {
	min = (*vol)[i].nb_surf;
	ind_min = i;
	ind_max =(short)*nb_vol;
      }

     /* Test if each edge of the volume which lowest edge appear in */
     /* the other volume */
     is_equal = 1;
     for(j = 0; j< min; j++)
      {
	for( k=0; k<(*vol)[ind_max].nb_surf; k++)
	 {
	   if((*vol)[ind_min].surf_index[j] == (*vol)[ind_max].surf_index[k] &&
	      (*vol)[ind_min].loop_index[j] == (*vol)[ind_max].loop_index[k])
	     break;
	 }
	if(k == (*vol)[ind_max].nb_surf)
	 {
	   is_equal = 0;
	   break;
	 }
      }

     if(is_equal)
      {
	/* One volume is reunion of other volume and another,suppress this vol */
	if(ind_min == *nb_vol) /* copy last volume to his containing one */
	 {
	   (*vol)[i].nb_surf = (*vol)[*nb_vol].nb_surf;
	   memcpy((*vol)[i].surf_index,(*vol)[*nb_vol].surf_index,
		  (*vol)[*nb_vol].nb_surf * sizeof(int));
	   memcpy((*vol)[i].loop_index,(*vol)[*nb_vol].loop_index,
		  (*vol)[*nb_vol].nb_surf * sizeof(int));
	 }
	/* else simply don't consider last solution */
	_FREE((*vol)[*nb_vol].surf_index);
	_FREE((*vol)[*nb_vol].loop_index);
	return 1;
      }       
   }
  (*nb_vol)++;
 
  return 1;
}  

 /* Debug function */
void print_sol(vol,nb_vol)
struct one_solid *vol;
int nb_vol;
{
  int i,j;

  printf("Nombre de solutions %d\n",nb_vol);
  for(i=0;i<nb_vol;i++)
   {
     printf("\nSolution trouve\n");
     for(j=0;j<vol[i].nb_surf;j++)
      {
	printf("Surface %d index_loop %d\n",vol[i].surf_index[j],
	       vol[i].loop_index[j]);
      }
   }
}

 /* Construct the list of compatible loops to one loop one the same surface */
 /* Two loops on the same surface are consider compatible if there is no */
 /* common edge between the two loops */
static void list_compatible(floop,num_surf,num_loop,list_comp,nb_comp)
struct loop_on_surf floop[];  /* [I] Give all the loop on all surfaces */
int num_surf;                  /* [I] Total number of surfaces */
int num_loop;                 /* [I] */
short *list_comp;             /* [O] */
short *nb_comp;               /* [O] */
{
  int e,e1,i;
  short compatible;
  
  *nb_comp = 0;

  if(num_loop+1 == floop[num_surf].nb_loop)
   {
     *nb_comp = 1;
     list_comp[0] = -1;
     return;
   }

  for(i = num_loop+1;i<floop[num_surf].nb_loop;i++)
   {
     compatible = 1;
     for(e = 0; e < floop[num_surf].one_loop[num_loop].nb_edge; e++)
      {
	for(e1 = 0; e1 < floop[num_surf].one_loop[i].nb_edge; e1++)
	  if(floop[num_surf].one_loop[num_loop].edge[e] ==
	     floop[num_surf].one_loop[i].edge[e1])
	   {
	     compatible = 0;
	     break;
	   }
	if(!compatible) break;
      }
     if(compatible)
      {
	list_comp[*nb_comp] = i;
	(*nb_comp)++;
      }
   }
  list_comp[*nb_comp] = -1;
  (*nb_comp)++;
}

  /* Construct the array of compatible loop in surfaces */
 /* (i.e. loop which have no commom edge on the same surface) */
static int cons_compatible(floop,nb_surf,compatible)
struct loop_on_surf floop[];  /* [I] Give all the loop on all surfaces */
int nb_surf;                  /* [I] Total number of surfaces */
short ****compatible;         /* [O] Array of compatibles loop */
{
  int i,j;
  short list_comp[100];
  short nb_comp;

  *compatible = NULL;
 
  *compatible = _CALLOC(nb_surf,short **);
  if(!*compatible) return 0;
 
  for(i=0;i<nb_surf;i++)
   {
     if(floop[i].nb_loop == 0) { (*compatible)[i] = NULL; continue; }
     (*compatible)[i] = _CALLOC(floop[i].nb_loop, short *);
     if(!(*compatible)[i]) return 0;

      for(j=0;j<floop[i].nb_loop;j++)
       {
	 list_compatible(floop,i,j,list_comp,&nb_comp);
	 /* At least -1 is in the list of compatible, so can calloc */
	 (*compatible)[i][j] = _CALLOC(nb_comp, short);
	 if(!(*compatible)[i][j]) return 0;
	 memcpy((*compatible)[i][j],list_comp,sizeof(short) * nb_comp); 
       }
    }

#ifdef DEBUG1
 {
   int k;
   printf("Liste des loops compatibles\n");
   for(i=0;i<nb_surf;i++)
    {
      printf("\nSurface %d",i);
      for(j=0;j<floop[i].nb_loop;j++)
       {
	 printf("\nLoop %d :",j);
	 k=0;
	 do
	  {
	    printf("%d ",(*compatible)[i][j][k]);
	  }while((*compatible)[i][j][k++] != -1);
       }
    }
   putchar('\n');
 }
#endif

  return 1;
}

/* Free the allocated compatible pointer */
static void free_compatible(compatible,floop,nb_surf)
short ***compatible; /* [I] */
struct loop_on_surf floop[];  /* [I] Give all the loop on all surfaces */
int nb_surf;                  /* [I] Total number of surfaces */
{
  int i,j;

  if(compatible)
   {
     for(i=0;i<nb_surf;i++)
       if(compatible[i])
	{
	  for(j=0;j<floop[i].nb_loop;j++)
	    _FREE(compatible[i][j]) ;
	  _FREE(compatible[i]);
	}
     _FREE(compatible);
   }
}

/* End of file for quick test only (NEVER COMPILE FOR OM) */
#if 0 
#define NB_SURF 8
#define MAX_LOOP 10
#define NB_VOL   20

#define MAX_EDGE 100                  

void init(floop)
struct loop_on_surf *floop;
{
  /* Face avant */
  floop[0].nb_loop = 2;
  floop[0].one_loop[0].nb_edge = 4;
  floop[0].one_loop[0].edge[0] = 0;
  floop[0].one_loop[0].edge[1] = 1;
  floop[0].one_loop[0].edge[2] = 2;
  floop[0].one_loop[0].edge[3] = 3;

  /* Face arriere */
  floop[0].one_loop[1].nb_edge = 4;
  floop[0].one_loop[1].edge[0] = 8;
  floop[0].one_loop[1].edge[1] = 7;
  floop[0].one_loop[1].edge[2] = 5;
  floop[0].one_loop[1].edge[3] = 9;

  /* Face du bas */
  floop[1].nb_loop = 1;
  floop[1].one_loop[0].nb_edge = 4;
  floop[1].one_loop[0].edge[0] = 2;
  floop[1].one_loop[0].edge[1] = 4;
  floop[1].one_loop[0].edge[2] = 7;
  floop[1].one_loop[0].edge[3] = 11;

  /* Face cote droite et gauche */ 
  floop[2].nb_loop = 2;
  floop[2].one_loop[0].nb_edge = 4;
  floop[2].one_loop[0].edge[0] = 10;
  floop[2].one_loop[0].edge[1] = 11;
  floop[2].one_loop[0].edge[2] = 8;
  floop[2].one_loop[0].edge[3] = 3;

  floop[2].one_loop[1].nb_edge = 4;
  floop[2].one_loop[1].edge[0] = 1;
  floop[2].one_loop[1].edge[1] = 4;
  floop[2].one_loop[1].edge[2] = 5;
  floop[2].one_loop[1].edge[3] = 6;

  /* Face du haut */
  floop[3].nb_loop = 1;
  floop[3].one_loop[0].nb_edge = 4;
  floop[3].one_loop[0].edge[0] = 0;
  floop[3].one_loop[0].edge[1] = 6;
  floop[3].one_loop[0].edge[2] = 9;
  floop[3].one_loop[0].edge[3] = 10;


   /* Face avant */
  floop[4].nb_loop = 2;
  floop[4].one_loop[0].nb_edge = 4;
  floop[4].one_loop[0].edge[0] = 12;
  floop[4].one_loop[0].edge[1] = 13;
  floop[4].one_loop[0].edge[2] = 14;
  floop[4].one_loop[0].edge[3] = 15;

  /* Face arriere */
  floop[4].one_loop[1].nb_edge = 4;
  floop[4].one_loop[1].edge[0] = 20;
  floop[4].one_loop[1].edge[1] = 19;
  floop[4].one_loop[1].edge[2] = 17;
  floop[4].one_loop[1].edge[3] = 21;

  /* Face du bas */
  floop[5].nb_loop = 1;
  floop[5].one_loop[0].nb_edge = 4;
  floop[5].one_loop[0].edge[0] = 14;
  floop[5].one_loop[0].edge[1] = 16;
  floop[5].one_loop[0].edge[2] = 19;
  floop[5].one_loop[0].edge[3] = 23;

  /* Face cote droite et gauche */ 
  floop[6].nb_loop = 2;
  floop[6].one_loop[0].nb_edge = 4;
  floop[6].one_loop[0].edge[0] = 22;
  floop[6].one_loop[0].edge[1] = 23;
  floop[6].one_loop[0].edge[2] = 20;
  floop[6].one_loop[0].edge[3] = 15;

  floop[6].one_loop[1].nb_edge = 4;
  floop[6].one_loop[1].edge[0] = 13;
  floop[6].one_loop[1].edge[1] = 16;
  floop[6].one_loop[1].edge[2] = 17;
  floop[6].one_loop[1].edge[3] = 18;

  /* Face du haut */
  floop[7].nb_loop = 1;
  floop[7].one_loop[0].nb_edge = 4;
  floop[7].one_loop[0].edge[0] = 12;
  floop[7].one_loop[0].edge[1] = 18;
  floop[7].one_loop[0].edge[2] = 21;
  floop[7].one_loop[0].edge[3] = 22;
}

void init(floop)
struct loop_on_surf floop[NB_SURF];
{
  /* Face avant */
  floop[0].nb_loop = 3;
  floop[0].one_loop[0].nb_edge = 3;
  floop[0].one_loop[0].edge[0] = 0;
  floop[0].one_loop[0].edge[1] = 1;
  floop[0].one_loop[0].edge[2] = 2;

  floop[0].one_loop[1].nb_edge = 3;
  floop[0].one_loop[1].edge[0] = 1;
  floop[0].one_loop[1].edge[1] = 9;
  floop[0].one_loop[1].edge[2] = 10;

  floop[0].one_loop[2].nb_edge = 4;
  floop[0].one_loop[2].edge[0] = 0;
  floop[0].one_loop[2].edge[1] = 9;
  floop[0].one_loop[2].edge[2] = 10;
  floop[0].one_loop[2].edge[3] = 2;

  /* face du bas */
  floop[1].nb_loop = 3;
  floop[1].one_loop[0].nb_edge = 4;
  floop[1].one_loop[0].edge[0] = 0;
  floop[1].one_loop[0].edge[1] = 3;
  floop[1].one_loop[0].edge[2] = 4;
  floop[1].one_loop[0].edge[3] = 5;

  floop[1].one_loop[1].nb_edge = 4;
  floop[1].one_loop[1].edge[0] = 15;
  floop[1].one_loop[1].edge[1] = 20;
  floop[1].one_loop[1].edge[2] = 19;
  floop[1].one_loop[1].edge[3] = 0;

  floop[1].one_loop[2].nb_edge = 4;
  floop[1].one_loop[2].edge[0] = 15;
  floop[1].one_loop[2].edge[1] = 18;
  floop[1].one_loop[2].edge[2] = 21;
  floop[1].one_loop[2].edge[3] = 4;


  floop[2].nb_loop = 3;
  floop[2].one_loop[0].nb_edge = 3;
  floop[2].one_loop[0].edge[0] = 4;
  floop[2].one_loop[0].edge[1] = 6;
  floop[2].one_loop[0].edge[2] = 7;

  floop[2].one_loop[1].nb_edge = 3;
  floop[2].one_loop[1].edge[0] = 6;
  floop[2].one_loop[1].edge[1] = 11;
  floop[2].one_loop[1].edge[2] = 12;
  
  floop[2].one_loop[2].nb_edge = 4;
  floop[2].one_loop[2].edge[0] = 7;
  floop[2].one_loop[2].edge[1] = 11;
  floop[2].one_loop[2].edge[2] = 12;
  floop[2].one_loop[2].edge[3] = 4;

  /* Face lateral arriere */
  floop[3].nb_loop = 3;
  floop[3].one_loop[0].nb_edge = 4;
  floop[3].one_loop[0].edge[0] = 5;
  floop[3].one_loop[0].edge[1] = 7;
  floop[3].one_loop[0].edge[2] = 8;
  floop[3].one_loop[0].edge[3] = 2;

  floop[3].one_loop[1].nb_edge = 4;
  floop[3].one_loop[1].edge[0] = 2;
  floop[3].one_loop[1].edge[1] = 20;
  floop[3].one_loop[1].edge[2] = 16;
  floop[3].one_loop[1].edge[3] = 24;

  floop[3].one_loop[2].nb_edge = 4;
  floop[3].one_loop[2].edge[0] = 21;
  floop[3].one_loop[2].edge[1] = 7;
  floop[3].one_loop[2].edge[2] = 25;
  floop[3].one_loop[2].edge[3] = 16;

  /* Face transverse longitudinal */
  floop[4].nb_loop = 3;
  floop[4].one_loop[0].nb_edge = 4;
  floop[4].one_loop[0].edge[0] = 1;
  floop[4].one_loop[0].edge[1] = 3;
  floop[4].one_loop[0].edge[2] = 6;
  floop[4].one_loop[0].edge[3] = 8;

  floop[4].one_loop[1].nb_edge = 4;
  floop[4].one_loop[1].edge[0] = 26;
  floop[4].one_loop[1].edge[1] = 19;
  floop[4].one_loop[1].edge[2] = 1;
  floop[4].one_loop[1].edge[3] = 24;

  floop[4].one_loop[2].nb_edge = 4;
  floop[4].one_loop[2].edge[0] = 26;
  floop[4].one_loop[2].edge[1] = 18;
  floop[4].one_loop[2].edge[2] = 6;
  floop[4].one_loop[2].edge[3] = 25;

  /* Face lateral avant */
  floop[5].nb_loop = 3;
  floop[5].one_loop[0].nb_edge = 4;
  floop[5].one_loop[0].edge[0] = 9;
  floop[5].one_loop[0].edge[1] = 13;
  floop[5].one_loop[0].edge[2] = 11;
  floop[5].one_loop[0].edge[3] = 3;

  floop[5].one_loop[1].nb_edge = 4;
  floop[5].one_loop[1].edge[0] = 9;
  floop[5].one_loop[1].edge[1] = 19;
  floop[5].one_loop[1].edge[2] = 14;
  floop[5].one_loop[1].edge[3] = 23;

  floop[5].one_loop[2].nb_edge = 4;
  floop[5].one_loop[2].edge[0] = 14;
  floop[5].one_loop[2].edge[1] = 18;
  floop[5].one_loop[2].edge[2] = 11;
  floop[5].one_loop[2].edge[3] = 22;

  /* Face du haut */
  floop[6].nb_loop = 3;
  floop[6].one_loop[0].nb_edge = 4;
  floop[6].one_loop[0].edge[0] = 8;
  floop[6].one_loop[0].edge[1] = 10;
  floop[6].one_loop[0].edge[2] = 13;
  floop[6].one_loop[0].edge[3] = 12;

  floop[6].one_loop[1].nb_edge = 4;
  floop[6].one_loop[1].edge[0] = 25;
  floop[6].one_loop[1].edge[1] = 17;
  floop[6].one_loop[1].edge[2] = 22;
  floop[6].one_loop[1].edge[3] = 12;

  floop[6].one_loop[2].nb_edge = 4;
  floop[6].one_loop[2].edge[0] = 24;
  floop[6].one_loop[2].edge[1] = 10;
  floop[6].one_loop[2].edge[2] = 23;
  floop[6].one_loop[2].edge[3] = 17;

  /* Face transverse */
  floop[7].nb_loop = 3;
  floop[7].one_loop[0].nb_edge = 4;
  floop[7].one_loop[0].edge[0] = 15;
  floop[7].one_loop[0].edge[1] = 16;
  floop[7].one_loop[0].edge[2] = 17;
  floop[7].one_loop[0].edge[3] = 14;

  floop[7].one_loop[1].nb_edge = 3;
  floop[7].one_loop[1].edge[0] = 15;
  floop[7].one_loop[1].edge[1] = 26;
  floop[7].one_loop[1].edge[2] = 16;

  floop[7].one_loop[2].nb_edge = 3;
  floop[7].one_loop[2].edge[0] = 26;
  floop[7].one_loop[2].edge[1] = 17;
  floop[7].one_loop[2].edge[2] = 14;
}

main()
{
  struct one_solid *all_vol = NULL;
  struct loop_on_surf floop[NB_SURF];     /* Array of all the loop on all */
					 /* the surfaces */
  int nb_vol = 0;
  int nb_surf = NB_SURF;    /* Total number of surfaces */
  int max_edge = MAX_EDGE;  /* How many different edge are in all the loop */

  init(floop);
  SMfind_all_vol(floop,nb_surf,max_edge,&all_vol,&nb_vol);
  print_sol(all_vol,nb_vol);
  SMfree_all_vol(all_vol,nb_vol);
}    
#endif



