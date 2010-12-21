class implementation SMCmdCvtFrm;



#define AS_DEBUG 1 
#include "AS_status.h"

/* include/protypes */

struct FRSel 
{
  int nb_cc;
  int size;
  struct GRid *cc;
};

from OMObjSpace import pass;
from GRgraphics import GRfunction;

/*************************************************************************/


#define _start 0

method UpdAllFrmSyst ( long * sts )
{
  int		  status = OM_S_SUCCESS;

OM_S_CLASSLIST		clist;
struct GRfunction_info	f_info;
extern GRclassid	OPP_nci_macro_class_id;
OMuword			classes[1];
int             	SMGiveYourId(); 
long			msg;
struct GRid		attr_grid;
OM_S_OBJID		mod_id;
struct FRSel		sel;
struct GRid		*cc = NULL;
int			i;
IGRchar			file_name[DI_PATH_MAX],
			exp_name[DI_PATH_MAX],
			cur_dir[DI_PATH_MAX];
struct GRid		tmp_obj;
  
  sel.nb_cc	= 0;
  sel.size	= 0;
  sel.cc	= cc;

  /* Test if the expression is already defined : if so the file */
  /* was already update*/

  ex$get_cur_mod( id = &mod_id, osnum = &attr_grid.osnum );

  VDSget_filename(file_name);
  di$pwd(dirname = cur_dir);

  strcat( file_name, ":IGENOD" );
  sprintf(exp_name, "%s:NewFrame", file_name );

  di$cd(dirname = file_name);
  status = di$translate(	objname = exp_name,
				osnum	= attr_grid.osnum,
				p_objid = &tmp_obj.objid);
  if(status == DIR_S_SUCCESS)
   {
#ifdef DEBUG
     printf("File already update\n");
#endif
    di$cd(dirname = cur_dir);
    goto wrapup;
   }
  else
   {
     /* Create the expression of file already update */
     status =  exp$create(exp_name  = exp_name,
			  exp_value = 1.0,
			  osnum     = attr_grid.osnum,
			  p_exp_id  = &tmp_obj);
     if(!(status & 1))
       printf("Can't create expression Newframe\n");
     di$cd(dirname = cur_dir);
   }

  go$build_user_function_buffer(buffer    = &f_info,
				 your_info = &sel);

  classes[0]      = OPP_nci_macro_class_id;
  
  clist.w_count   = 1;
  clist.w_flags   = OM_CLST_subclass;
  clist.p_classes = classes;

  status = om$send(msg = message OMObjSpace.pass
		   (&clist,OM_e_wrt_object,
		    message GRgraphics.GRfunction(&msg,SMGiveYourId, 
			                               (char *) &f_info)),
                         senderid = NULL_OBJID,
			 targetid = OM_GO_current_OS_objid,
			 targetos = attr_grid.osnum);
  as$status(action = RET_STATUS);
  if(msg == MSFAIL) 
   { 
     printf("Warning problem with update of one frame system\n");
     return OM_S_SUCCESS;
   }

  if(sel.nb_cc == 0) goto wrapup;

  for(i=0;i<sel.nb_cc;i++)
    SMUpdFrmSyst(&sel.cc[i]);

  if(sel.nb_cc > 0 && sel.cc != NULL)
    om$dealloc(ptr = sel.cc);

wrapup:
  UI_status( " Verified Conversion of Plane System " );

  goto quit ;

quit:
  return OM_S_SUCCESS;
}

end implementation SMCmdCvtFrm;
