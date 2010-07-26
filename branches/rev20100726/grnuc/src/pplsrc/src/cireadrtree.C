/*
 * cireadrtree: read the last objects touched in the RTREE for
 * the Command Language
 *
 * MUST BE LINKED WITH GOOD OMrtree library
 *
 * Etienne BEEKER (FRANCE)
 * creation: 4-4-87
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


#ifdef CIREADRTREE
#include "OMrtreeops.h"
extern double ci_give_value();
extern struct instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;
extern char errmess[];
#endif

int cireadrtree(func)
struct ci_instruction *func;
/*
 * calls functions reading in the rtree the last objects touched
 */
{

#ifdef CIREADRTREE
	int i, i1, i2, i3;
	struct GRid tmpj[SZ_RTREE_FIFO];	
	int nb;
	int op_code, nb_wanted;
	OM_S_RTREE_OP **px, *x, rtree_elt;
	int estunGRobj;
	
	i1 = func->paramlist[1];
	estunGRobj = ((ci_data->vartypetable[i1] & ~PTR) == CI_GROBJ );

	i2 = func->paramlist[2];
	i3 = func->paramlist[3];

	nb_wanted= (int)ci_give_value(i2);	/* nb objects wanted */
	if( nb_wanted > SZ_RTREE_FIFO || nb_wanted < 0  ){
		sprintf(errmess,
		"warning: readrtree, number of object wanted (%d) out of range [0-%d]\nset to 1",
			nb_wanted, SZ_RTREE_FIFO );
		erreur(errmess);
		nb_wanted = SZ_RTREE_FIFO;
	}

	op_code = (int)ci_give_value(i3);
	if( op_code > 4 || op_code < 0  ){
		sprintf(errmess,
		"warning: readrtree, op code (%d) out of range [0-4]\nset to 0",
					 op_code);
		erreur(errmess);
		op_code = 0;
	}

	/* fill tmpj en tenant compte de op_code  */
	x = &rtree_elt;
	px = &x;

	nb = 0;
	for(;;){
		som_rtree_get_op(px);
		if( px == NULL || x == NULL || nb >= SZ_RTREE_FIFO )
				/* 3rd test for security */
			break;
		if(op_code == 0 || (*px)->op_code == op_code ){
			tmpj[nb].objid = (*px)->objid;
			tmpj[nb].osnum = (*px)->osnum;
			nb++;
		}
	}

	if(nb <= nb_wanted){
		i_cival(func->paramlist[0]) = nb;
		for(i=0;i<nb;i++){
			if( estunGRobj )
				((OM_S_OBJID *)st_cival(i1))[i] = tmpj[i].objid;
			else {	
				/********** KLUDGE *********************/
				/* only for simulated arrays of GRid's */
				/* i.e. Grid declared one after the other */
				/* only the address of the 1rst element is passed */
				char *ptmp;
				ptmp = p_cival(i1) + i*sizeof(struct GRid);
				*((short *)ptmp) = tmpj[i].osnum;
				ptmp += 4;	/* an int after a short in a struct */
				*((OM_S_OBJID *)ptmp) = tmpj[i].objid;
			}
		}
	} else {
		i_cival(func->paramlist[0]) = nb_wanted;
		for(i=nb-nb_wanted; i<nb; i++){
			int ix = i-nb+nb_wanted;
			if( estunGRobj )
				((OM_S_OBJID *)st_cival(i1))[ix] = tmpj[i].objid;
			else {	
				/********** SAME KLUDGE *********************/
				char *ptmp;
				ptmp = p_cival(i1) + ix*sizeof(struct GRid);
				*((short *)ptmp) = tmpj[i].osnum;
				ptmp += 4;	
					/* an int after a short in a struct */
				*((OM_S_OBJID *)ptmp) = tmpj[i].objid;
			}
		}
	}

#endif

	return 1;
}
