#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"

int som_recognize_class(cur_class, rec_class, sub_class, mth_class, mth_name )
	char 	*cur_class;
	char 	*rec_class;
	char 	*sub_class;
	char  	*mth_class;
	char	*mth_name;

{
OM_p_CLASSDEF		p_cur_acld, p_sub_acld, p_rec_acld, p_mth_acld;
OM_S_MESSAGE		msg;
OM_S_MSGMAP		sub_msgmap, rec_msgmap;
OMuword			sub_classid, cur_classid, rec_classid, mth_classid;
OMuword			cur_trans_size, new_trans_size;
OMuword			i, rec_entry, tndx, func_index;
int			sts;
char			*new_p;

/***********************************************************/
/* Get aclds and classids for the three classes            */
/***********************************************************/

if (!(1&(sts = om$get_class(classname=sub_class,
			p_classid=&sub_classid,
	    		pp_cld=&p_sub_acld) )))
	return(sts);

if (!(1&(sts = om$get_class(classname=cur_class,
			p_classid=&cur_classid,
	    		pp_cld=&p_cur_acld) )))
	return(sts);

if (!(1&(sts = om$get_class(classname=rec_class,
			p_classid=&rec_classid,
			pp_cld=&p_rec_acld))))
	return(sts);

if (!(1&(sts = om$get_class(classname=mth_class,
			p_classid=&mth_classid,
			pp_cld=&p_mth_acld))))
	return(sts);

/***********************************************************/
/*  Realloc the current transmap if need be                */
/***********************************************************/

if ( p_rec_acld->w_classid < p_cur_acld->w_baseclass )
  {

  /* Rec classid smaller; must grow and re-adjust the transmap */

  new_trans_size = p_cur_acld->w_maxclass - p_rec_acld->w_classid + 1;
  new_p = om$calloc(num=new_trans_size, size=sizeof(OMbyte));
  if ( new_p == NULL )
	return(OM_E_NODYNMEM);

  /* initialize the new transmap to NULL entries */

  for (i=0; i<new_trans_size; i++)
	new_p[i] = OM_K_NULL_TRANS;
  
  /* Move old entries to new location */

  cur_trans_size = p_cur_acld->w_maxclass - p_cur_acld->w_baseclass + 1;
  OM_BLOCK_MOVE(&(p_cur_acld->p_transmap[0]),
	&(new_p[p_cur_acld->w_baseclass-p_rec_acld->w_classid]),
	cur_trans_size);

  /* Free old transmap */

  om$dealloc(ptr=(char *) p_cur_acld->p_transmap);

  p_cur_acld->w_baseclass = p_rec_acld->w_classid;
  p_cur_acld->p_transmap = (OMbyte *)new_p;

  }

else if ( p_rec_acld->w_classid > p_cur_acld->w_maxclass ) 
   {

    /* New classid bigger than transmap can handle; grow */

    new_trans_size = p_rec_acld->w_classid - p_cur_acld->w_baseclass + 1;
    new_p= om$realloc(ptr=(char *) p_cur_acld->p_transmap,
		size=(sizeof(OMbyte)*
		 (new_trans_size)));
    if ( new_p == NULL )
	return(OM_E_NODYNMEM);
    p_cur_acld->p_transmap = (OMbyte *)(new_p);
    p_cur_acld->w_maxclass = p_rec_acld->w_classid;
   }

/***********************************************************/
/*  Realloc the current message map bigger by one entry    */
/***********************************************************/

new_p = om$realloc(ptr=(char *) p_cur_acld->MsgMap,
	size=(sizeof(OM_S_MSGMAP)*
	  (p_cur_acld->NumMsgClasses+p_cur_acld->NumRecClasses+1)));
if ( new_p == NULL )
	return(OM_E_NODYNMEM);
p_cur_acld->MsgMap = (OM_p_MSGMAP)(new_p);

/***********************************************************/
/* Determine where the entry goes in the transmap          */
/* and fill it in.
/***********************************************************/

p_cur_acld->NumRecClasses++;
rec_entry = p_cur_acld->NumMsgClasses + p_cur_acld->NumRecClasses - 1;
p_cur_acld->p_transmap[p_rec_acld->w_classid-p_cur_acld->w_baseclass]=
   (OMbyte) rec_entry;

/* Fill in new message map entries */
/* sub_msgmap is A as a component of B; rec_msgmap is A as a component
   of A   */

sub_msgmap = p_sub_acld->MsgMap[p_sub_acld->NumMsgClasses-2];
#ifdef DEBUG
printf("\n**** Dump msgmap entry of rec component of sub\n");
dump_msgmap(&sub_msgmap, 1);
#endif

p_cur_acld->MsgMap[rec_entry].MethTbl = sub_msgmap.MethTbl;
p_cur_acld->MsgMap[rec_entry].classid = rec_classid;
p_cur_acld->MsgMap[rec_entry].offset = 0;
p_cur_acld->MsgMap[rec_entry].NumChan = 0;
p_cur_acld->MsgMap[rec_entry].ChanDefns = NULL;

rec_msgmap = p_rec_acld->MsgMap[p_rec_acld->NumMsgClasses-1];
#ifdef DEBUG
printf("\n**** Dump msgmap entry of rec component of rec\n");
dump_msgmap(&rec_msgmap, 1);
#endif

#ifdef DEBUG
printf("\n**** Dumping acld of current class after adjusting MsgMap\n");
dump_class(p_cur_acld);
#endif

/* Determine function index of replacement method */

/* Determine which func_ptr entries in A as a component of B were not
   overridden and replace them with the inputed method */

if ( ! ( 1&(sts = om$make_message(classname=mth_class,
			methodname=mth_name,
			p_msg=&msg))))
	return(sts);
func_index = msg.select.FuncIndex;

for ( i=0; i<p_rec_acld->w_nummethods; i++ )
    {
    if ( (sub_msgmap.MethTbl[i])
			==
       (rec_msgmap.MethTbl[i]) )

	{

	/* This method was not overridden */

	tndx = p_cur_acld->p_transmap[mth_classid-p_cur_acld->w_baseclass];
	p_cur_acld->MsgMap[rec_entry].MethTbl[i]
	  = p_cur_acld->MsgMap[tndx].MethTbl[func_index];

	} /* end if */

   } /* end for */

return( OM_S_SUCCESS );

}
