/* Data structure for loading the information of a child to be 
   placed in a assembly - Kumar 07/11/93  */
#ifndef PDMapi_h
#define PDMapi_h

typedef struct PDMassembly_member
        {
        int                im_n_citno;
        int                im_n_pcatalogno;
        int                im_n_pitemno;
        int                im_n_ccatalogno;
        int                im_n_citemno;
        int                ir_p_level;
        char               caw_n_setindicator[2];
        char               caw_n_status[3];
        int                im_p_pchildno;
        int                ir_p_childno;
        char               car_n_catalogname[21];
        char               *cpr_n_itemname;
        char               *cpr_n_itemrev;
        char               *cpr_n_itemdesc;
        char               car_p_attached[2];
        double             dr_p_quantity;
        char               car_p_usageid[26];
        char               car_n_cofilename[15];
        int                ir_p_tagno;
        char               car_p_alttagno[26];
        char               car_p_incbom[2];
        char               car_p_incstr[2];
        char               car_p_explode[2];
        char               car_p_history[26];
        struct PDMassembly_member *next;
} * PDMchildren;

#endif
