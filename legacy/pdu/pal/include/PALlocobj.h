extern OMuword OPP_nci_macro_class_id ;
extern OMuword OPP_ACconst_class_id ;
extern OMuword OPP_GRpart_class_id  ;

/* returns 0 - another command stacked
           1 - successful, object in lgrid is a Par. part
           2 - successful, object in lgrid is a GRpart 
*/
PALloc_obj(prompt,lenv,lgrid,flag)
char *prompt ;
struct GRid *lgrid ;
struct GRmd_env *lenv ;
int flag ;
{
	int 			resp, count, sts, msg ;
	OMuword			classid ;
	char 			com_str[20];
	GRobjid			tmp ;
	struct 	GRid		obj;
	OMuword			classes[5];
        char                    *msg_str;

	/* Set up eligible classes list	*/
	classes[0] = OPP_nci_macro_class_id ;
	classes[1] = OPP_ACconst_class_id ;
	classes[2] = OPP_GRpart_class_id  ;

	tmp = NULL_OBJID;
	count 	= 3;

        msg_str = NULL;
        msg_str = (char *)PDUtranslate_message(PDP_P_ACCEPT_PART);
        sts =  pal$locate( msg = msg, 
               		locate_str = prompt, 
               		acc_str = msg_str, 
               		relocate_str = "", 
			no_of_gr_classes = count, 
			gr_classes = classes, 
			response = resp, 
			objid = obj.objid, 
			osnum = obj.osnum );

	_pdm_debug ("PAL -- After locate : response  = %d", resp);
	_pdm_debug ("PAL -- 	           id        = %d", obj.objid);

       	/* Trap double reset response */
        if(resp == D_RESET)
       	{
           /* Display design form */
       	   PDUdisplay_design_form();
           return(0);
       	}
		/* if RESET */
       	if(resp == RESET) 
	{
		com_str[0] =  '\0' ;
		PALstack_events(3,com_str,RESET,&tmp);
		strcpy(com_str,"PDGtPrOs");
		PALstack_events(1,com_str,EX_CMD_KEY,&tmp);
		return(0);
	}

	/* Assign to input var	*/
	*lgrid  = obj;
	if( flag == 0 ) /* General Locate operation */
		return(1);
	/* If part is GRpart, located a non-parametric part for modification */
	sts = om$get_classid( objid = lgrid  -> objid,
			      osnum = lgrid -> osnum ,
		              p_classid = &classid );
	if( om$is_ancestry_valid( superclassid = OPP_GRpart_class_id,
			subclassid = classid ) == OM_S_SUCCESS )
	{
		/* Check if it is a PDU GRpart		*/
		if( PDUis_PDU_part(lgrid,lenv))
		{
			if( flag == 1 ) /* Modify part */
				return(2);

			com_str[0] = '\0' ;
		        PALstack_events(2,com_str,EX_OBJID,&lgrid -> objid);
			if( flag == 2 )      /* copy part */
					strcpy(com_str,"PDCpPrPt");
				else if( flag == 3 ) /* delete part */
					strcpy(com_str,"PDDlPrPt");
				
	        	     	_pdm_status("PDUput_queue (Case III)", sts);

	                	/* Put edit part command on the queue */
			        PALstack_events(1,&com_str[0],EX_CMD_KEY,&tmp);
				return(0);
		}
	}
	return(1);
}

