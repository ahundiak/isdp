#ifndef lcpriv_include
#define lcpriv_include

struct LClockludge
{
    struct 	GRlc_cvl 	*cvl;
        	OM_p_KEY_DESC   range_key;
};

struct LCupdkludge
{
        IGRlong		*msg;
	IGRshort	*mx_type;        
	IGRdouble	*mat;
enum 	GRdpmode	*mode;
struct	IGRdisplay	*alt_symb;
struct	DP_information	*sp_info;
	OM_p_KEY_DESC	range_key;
};

struct LCpasskludge
{
	OM_p_MESSAGE	msg;
	OM_p_KEY_DESC	p_select_key;
	char		*p_criteria;
	OM_p_KEY_DESC	p_target_key;
	int		(*user_compare)();
	int		*ret;        
};

struct LCskewkludge
{
	OM_p_MESSAGE 	msg;
	OM_p_SKEW_DESC	p_key;
	OM_p_KEY_DESC	p_target_key;
	char		*p_criteria;
	int		(*user_compare)();
	int		*ret;
};

struct LCcheck
{
    OM_S_OBJID objid;
    OMuword    osnum;
    struct LCcheck *next;
};

struct LCroot
{
    IGRint   num_id;
    struct LCcheck *next;
};

struct LCdyn_cursor
{
    IGRdouble		 tolerance;
    struct IGRarc        arc;
    struct DPele_header  header;
    struct DPele_header  cur1;
    struct DPele_header  cur2;
    OM_S_OBJID           gragad_id;
    OMuword              gragad_os;
};

struct LCrtree_alias 
{
    OMuword                alias_class;
    IGRint                 num_entries;
    OMuword                *classids;
    struct   LCrtree_alias *next;
};

struct LC_sd_evselect {
    IGRint (*select_handler)();
    IGRchar *user_args;
    struct EX_button *button;
};

#endif
