#define PAL_E_ERROR   0
#define PAL_S_SUCCESS 1
extern OMuword OPP_ACpretdef_class_id;

/* ------------------   PDUis_macro_edited()  -------------------------*/

int PDUis_macro_edited(hdr)
struct GRid *hdr ;

/***********************************************************************/
/*   This function finds out whether the macro definition is edited or */
/*   not.  Input - macro header object                                 */
/***********************************************************************/
{

	int num_org_temp, num_temp_for_placement , props, sts ;
	struct stemp *temp_desc ;
	struct sup   *sup ;

	temp_desc = NULL;
	sup = NULL;

	/* Get original template description as exists at creation time */
	sts = ci$send( msg = message ACcpx_defn.ACgive_temp_desc(
				&num_org_temp,&temp_desc),
                      targetid = hdr  -> objid,
                      targetos = hdr  -> osnum );

	_MO_omerr_chk("PDUis_macro_edited(): ACgive_temp_desc ", sts, wrapup);

	write("numorgtemp = ",num_org_temp,"\n");

	sts = ci$send( msg = message ACmacro_defn.ACgive_upscan(
				&num_temp_for_placement,&props,&sup),
                      targetid = hdr  -> objid,
                      targetos = hdr  -> osnum );

	_MO_omerr_chk("PDUis_macro_edited(): ACgive_upscan : ", sts, wrapup);
	write("num temp for placement = ",num_temp_for_placement,"\n");
	
	if( num_org_temp != num_temp_for_placement )  // macro is edited
		return( PAL_S_SUCCESS );
wrapup:
	return( PAL_E_ERROR);
}


int PDUedit_macro(hdr, dyn_list, num_dyn)
/***********************************************************************/
/*      Edit the macro definition such that, all exp ( text & double ) */
/*      attribs not falling into the input dyn_list, will go into the  */
/*      first collection and the attribs in the dyn_list would go into */
/*      the second collection, the rest locatable templates will be at */
/*      the begining of the template list to the macro                 */
/***********************************************************************/
struct GRid *hdr ;
char **dyn_list;
int num_dyn;
{
	int    i, j, org_num_temp, nb_sup, sts, msg ,back ;
	struct stemp *temp_desc, *new_desc  ;
	struct sup   *supptr ;
	int    count;
	struct myfeet *feet_desc, *new_feet;
	int    nb_feet;
	OM_S_OBJID new_template;

	new_template = NULL_OBJID;

		
	msg = PAL_E_ERROR ;
	temp_desc = NULL;
	new_desc = NULL;
	feet_desc = NULL;
	new_feet = NULL;
	
	supptr = NULL;

	/* Get original template description  and types */
	sts = ci$send( msg = message ACcpx_defn.ACgive_temp_desc(
				&org_num_temp,&temp_desc),
                      targetid = hdr -> objid,
                      targetos = hdr -> osnum );

	_MO_omerr_chk("PDUedit_macro(): ACgive_temp_desc ", sts, wrapup);

	/* EDIT MACRO DEFINITION NOW */

	new_desc = (struct stemp *)malloc( (org_num_temp+2) 
						* sizeof(struct stemp ));
	if ( new_desc == NULL ){
		printf("PDUedit_macro(): Not enough dynamic memory\n");
		goto wrapup;
	}

	supptr  = (struct sup *)malloc(sizeof(struct sup));
	if ( supptr == NULL ){
		printf("PDUedit_macro():Not enough dynamic memory\n");
		goto wrapup;
	}

	/* For each template of the original macro, define down scan (attribute
           name of ACdyn_col and channel index - 'back' )
	*/

	/* set channel nos for non exp type templates first,ie., locatable */
	back = 0 ;
	for( i = 0 ; i < org_num_temp ; i = i + 1 ) {
#ifdef DEBUG
printf(" template: %s, %d %d\n", temp_desc[i].name, i, temp_desc[i].type );
#endif
		strcpy(new_desc[i].name , temp_desc[i].name ) ;  
        	new_desc[i].type = temp_desc[i]. type ; 

		if( !(temp_desc[i].type & parameter_generic)) {
#ifdef DEBUG
printf("graphic template: %s %d %d\n", temp_desc[i].name, i, temp_desc[i].type);
#endif
		        new_desc[i].back =  back ;
#ifdef DEBUG
printf("channel index: %d\n", back);
#endif
			back = back + 1;
        		strcpy(new_desc[i].down_scan,".");/* No Mapping */

		        /* descibe the object connected at each index--'back' */
			strcpy(supptr[back-1].prompt,temp_desc[i].name);
			strcpy(supptr[back-1].up_scan,".");
	
			if( temp_desc[i].type == 65792 ) /* Plane type */
				supptr[back-1].type = 64 ;
			else
				supptr[back-1].type = temp_desc[i].type ;

			supptr = (struct sup *)realloc( supptr, (back+1) *
							sizeof(struct sup));
			if( supptr == NULL ) {
				printf("PDUedit_macro():No dynamic memory\n");
				goto wrapup;
			}
		}
	}

	supptr = (struct sup *)realloc( supptr, (back+2) *
					sizeof(struct sup));
	if( supptr == NULL ) {
		printf("PDUedit_macro():No dynamic memory\n");
		goto wrapup;
	}



	/* set channel nos for  exp type templates now */
	for( i = 0 ; i < org_num_temp ; i = i + 1 ) {

		strcpy(new_desc[i].name , temp_desc[i].name ) ;  
        	new_desc[i].type = temp_desc[i].type ; 

		if( (temp_desc[i].type == double_type) ||
		    (temp_desc[i].type == text_type)  ) {

			for( j = 0; j < num_dyn; j = j +1 )
				if ( !strcmp(temp_desc[i].name, dyn_list[j])) 
		        	{
				write("add dyn_attr ",temp_desc[i].name,"\n");
					new_desc[i].back =  back+1;
        				strcpy(new_desc[i].down_scan,
							 temp_desc[i].name);
					break;
				}
			if( j == num_dyn ) /* Not a dynamic attr */
			{
				write("add stat_attr ",temp_desc[i].name,"\n");
				new_desc[i].back =  back;
        			strcpy(new_desc[i].down_scan,temp_desc[i].name);
			}
		}
	}

	/* Construct two ACpretends and make them  template-feet of the macro */

    	strcpy(new_desc[org_num_temp].name, "stat_temp_feet");
	strcpy(supptr[back].prompt, "Stat_attr_box");
	strcpy(supptr[back].up_scan,"*");
	supptr[back].type = macro_generic ;

    	strcpy(new_desc[org_num_temp+1].name, "dyn_temp_feet");
	strcpy(supptr[back+1].prompt, "Dyn_attr_box");
	strcpy(supptr[back+1].up_scan,"*");
	supptr[back+1].type = macro_generic ;

	nb_sup	= back;
	count = org_num_temp;
	for( i = org_num_temp; i < (org_num_temp + 2) ; i= i+1 )
	{
		new_desc[i].type = macro_generic;
    		strcpy(new_desc[i].down_scan, ".");
		new_desc[i].back =  nb_sup ;
	
		nb_sup = nb_sup + 1;

		sts = om$construct( classid = OPP_ACpretdef_class_id,
			    p_objid = &new_template,
			    osnum = hdr -> osnum );

		_MO_omerr_chk("PDUedit_macro():construct ACpretdef",sts,wrapup);

		sts = ci$send( msg = message ACpretdef.ACsconnect(new_desc,
								 &count ),
						targetid = new_template,
						targetos = hdr->osnum);

		_MO_omerr_chk("PDUeditmacro():ACpretdef.ASsconnect",sts,wrapup);
	}

	/* This message sets the 'templates to input' at placement time */

	sts = ci$send ( msg = message ACmacro_defn.ACtake_template
				( nb_sup, supptr, count, new_desc ),
			targetid = hdr -> objid,
			targetos = hdr -> osnum );

	_MO_omerr_chk("PDUedit_macro() :ACtake_template", sts, wrapup);

	/* Now get the feet description of the original macro and add the dyn_
		collection */

	sts = ci$send( msg = message ACmacro_defn.ACgive_feet_desc( &nb_feet,
								&feet_desc ),
					targetid = hdr->objid,
					targetos = hdr->osnum);

	_MO_omerr_chk("PDUedit_macro() :ACgive_feet_desc", sts, wrapup);

	new_feet = (struct myfeet *) malloc((nb_feet+2)*sizeof(struct myfeet));

	if( new_feet == NULL )
	{
		write(" Malloc problem\n" );
		goto wrapup;
	}

	for ( i = 0; i < nb_feet; i = i + 1 )
		new_feet[i] = feet_desc[i];

	strcpy( new_feet[i].name, new_desc[org_num_temp].name );
	strcpy( new_feet[i+1].name, new_desc[org_num_temp+1].name );
	new_feet[i].pos = org_num_temp;
	new_feet[i+1].pos = org_num_temp+1;

	for( ; i < (nb_feet+2); i = i+1 )
	{
		new_feet[i].prop = macro_generic;
		new_feet[i].chan = feet_in_template;
	}

	sts = ci$send( msg = message ACmacro_defn.ACtake_feet( nb_feet+2,
								 new_feet),
						targetid = hdr->objid,
						targetos = hdr->osnum );


	_MO_omerr_chk("PDUedit_macro() :ACtake_feet", sts, wrapup);

	msg = PAL_S_SUCCESS ;
wrapup:
	if( supptr != NULL )
		free( (char *) supptr );

	if( new_desc != NULL )
		free( (char *) new_desc );

	if( new_feet != NULL )
		free( (char *) new_feet );

	return(msg);
}

