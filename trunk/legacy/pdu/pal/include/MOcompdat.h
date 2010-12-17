#define MAX_QRY_LENGTH 1024
#define MAX_ROWS_RTVD  50 

struct  comp_data {
             int num_dyn,    
                 num_stat,   
                 ismacro,    
                 *indicator,
                 *dyn_ind ; 

                 char **params ,
                      **fields,
                      **stat_msg,
                      **stat_units;

                 char **dyn_names, 
                      **dyn_msg ;  

                 char mac_name[20] ;  
                 char lst_name[30] ;  
        }  ;

