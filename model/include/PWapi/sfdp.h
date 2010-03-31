#ifndef _sfdp_proto_h 
#define _sfdp_proto_h

#if defined(__STDC__) || defined(__cplusplus) 
#ifndef _PW_ 
#define _PW_(args) args 
#endif 
#else 
#ifndef _PW_ 
#define _PW_(args) () 
#endif 
#endif 

#if defined(__cplusplus) 
extern "C" 
{ 
#endif

extern PWresult pwGetSfAttrData _PW_((
  PWobjid                 sfobj, 
  PWosnum                 os,
  struct PWsfattrdata     *p_sfattrdata
));

extern PWresult pwGetSfRuleLineTable _PW_((
  PWobjid sfobj,
  PWosnum os,
  int *num_u_rules,
  int *num_v_rules,
  double **u_rule_pars,
  double **v_rule_pars,
  int **num_u_rule_bdrys,
  int **num_v_rule_bdrys,
  double (***u_rule_bdrys)[2],
  double (***v_rule_bdrys)[2]
));

extern void pwFreeSfRuleLineTable _PW_((
  int num_u_rules,
  int num_v_rules,
  double *u_rule_pars,
  double *v_rule_pars,
  int *num_u_rule_bdrys,
  int *num_v_rule_bdrys,
  double (**u_rule_bdrys)[2],
  double (**v_rule_bdrys)[2]
));

extern PWresult pwGetSfRuleLineCvs _PW_((
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  int *num_rule_cvs,
  struct IGRbsp_curve ***rule_cvs
));



#if defined(__cplusplus) 
} 
#endif 

#endif 
