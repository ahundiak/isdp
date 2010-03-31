#ifndef ASSEMPRIV_H
#define ASSEMPRIV_H

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private File: assempriv.h                                                 |
 |                                                                           |
 | The file contains information that is meant to be used ONLY by the        |
 | Intergraph Mechanical Development organization.                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Private Assembly Defines                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_ACTIVE_ON_LAYERS     0
#define EM_NOACTIVE_ON_LAYERS   1

/*---------------------------------------------------------------------------+
 |                                                                           |
 |                   Private Assembly Macro Function Prototypes              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" 
{
#endif

extern EMattr * EMget_named_attribute __((IGRchar * name, IGRint num_attrs,
                                          EMattr  * attrs));
extern IGRboolean EMis_local_bounded_system __((struct GRid * id));
extern IGRlong EMadd_obj_to_untree __((struct GRid * id,struct GRid * dir_id,
                                       IGRchar * name));
extern IGRlong EMrem_obj_from_untree __((struct GRid * id,struct GRid * dir_id));
extern IGRlong EMupdate_memb_in_untree __((IGRlong * msg,
                                           struct GRmd_env * mod_env,
                                           IGRchar * dir_id,EMmemb * memb));
extern IGRboolean EMis_om_file __((IGRchar * filename));
extern IGRlong EMreduce_syntax __((IGRchar * syntax,IGRchar * reduced_syntax));
extern IGRboolean EMsyntax_different __((IGRchar * syntax1,IGRchar * syntax2));
extern IGRboolean EMdesc_get_system_mode __(());
extern IGRboolean EMdesc_set_system_mode __((IGRboolean system_mode));

#if defined(__cplusplus)
}
#endif

#endif

