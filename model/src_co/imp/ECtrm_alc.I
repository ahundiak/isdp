

class implementation ECtrim2;

#include "VCdef.h"
#include "OMminimum.h"

/* imported messages */
from GRvg       import GRgetsize,
                       GRgetgeom,
                       GRgeomprops;


#define VCdebug_return    1            /*  test  */






/*  -------------------------------------------- */
/*  This function allocates/prepares curve data  */
/*  -------------------------------------------- */
  
IGRlong ECtrm_alc(                            
    IGRlong              *msg,         /* O  return status (TRUE=no error)  */
    IGRint               task,         /* I  0 = basic / 1 = + properties   */
    struct GRid          object,       /* I  work object                    */  
    struct GRmdenv_info  *env_info,    /* I  matrix + matrix type           */
    struct IGRbsp_curve  **curve_data, /* O  curve data pointer             */
    struct GRprops       *props,       /* O  geom properties                */
           IGRlong       *size         /* O  size of curve                  */
                                 )
 
{
  IGRlong     sts;
  IGRlong     loc_msg;

  *size = -1;
  sts = om$send(msg      = message GRvg.GRgetsize(&loc_msg,
                                                  &env_info->matrix_type,
                                                  env_info->matrix,
                                                  size),
                senderid = NULL_OBJID,     
                targetid = object.objid,
                targetos = object.osnum);
  if (!(1&loc_msg))  Goto (wrapup);

  *curve_data = (struct IGRbsp_curve *) om$malloc(size = *size);
  if (!*curve_data)  Goto (wrapup);

  sts = om$send(msg      = message GRvg.GRgetgeom(&loc_msg,
                                                  &env_info->matrix_type,
                                                  env_info->matrix,
                                                  (char *) *curve_data),
                senderid = NULL_OBJID,
                targetid = object.objid,
                targetos = object.osnum);
  if (!(1&loc_msg)) Goto (wrapup);
 
  if (task)
  {
    sts = om$send(mode = OM_e_wrt_object,
                  msg      = message GRvg.GRgeomprops(&loc_msg,
                                                      &env_info->matrix_type,
                                                      env_info->matrix,
                                                      props),
                  senderid = NULL_OBJID,
                  targetid = object.objid,
                  targetos = object.osnum);
  if (!(1&loc_msg)) Goto (wrapup);
  
  }

  *msg = TRUE;
  return TRUE;


wrapup:
  *msg = FALSE;
  return FALSE;
}



end implementation ECtrim2;
