#ifndef ci_form_include
#define ci_form_include

char	Utogg;
int	OptioN;
#define form_erase(Opt,object)\
    (object).osnum = 1;\
    OptioN = (Opt);\
    ci$send ( msg = message FIform.erase_form ( OptioN ),\
                targetid = (object).objid,\
                targetos = (object).osnum );\

#define form_init(formno,form_name,object)\
    (object).osnum = 1;\
    ci$send( msg = message FIform.init_form(\
		&return_code, \
		(formno), \
		MY_ID,\
        	(short) 1, \
		&TEMP_GRID.objid, \
		Utogg, \
		(form_name) ),\
             	construct = 1,\
             	targetid = (object).objid,\
             	targetos = (object).osnum );

#define form_display(loc1,loc2,object)\
    (object).osnum = 1;\
    ci$send( msg = message FIform.display_form(\
		&return_code,(loc1),(loc2)),\
             	targetid = (object).objid,\
             	targetos = (object).osnum );

#define form_delete(Opt,object)\
    (object).osnum = 1;\
     ci$send ( msg = message FIform.delete ( Opt ),\
                targetid = (object).objid,\
                targetos = (object).osnum );

#define form_get_value(Num,Form_Data,object)\
    ci$send (msg = message FIform.get_by_value ( \
		&return_code, (Num), (Form_Data) ),\
              	targetid = (object).objid,\
              	targetos = (object).osnum);

#define form_put_value(Num,Form_Data,object)\
    ci$send (msg = message FIform.put_by_value ( \
		&return_code, (Num), (Form_Data) ),\
              	targetid = (object).objid,\
              	targetos = (object).osnum);

#define gadgets_erase(Num,List,object)\
    ci$send( msg = message  FIform.erase_gadgets(\
		&return_code, (Num), (List)),\
                targetid = (object).objid,\
                targetos = (object).osnum);

#define gadgets_restore(Num,List,object)\
    ci$send( msg = message  FIform.restore_gadgets(\
		&return_code, (Num), (List)),\
                targetid = (object).objid,\
                targetos = (object).osnum);

#endif

