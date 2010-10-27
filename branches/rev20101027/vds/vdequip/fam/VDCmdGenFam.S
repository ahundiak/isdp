/* $Id:   */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:       vdequip/fam/VDCmdGenFam.S 
 *
 * Description:
        This command creates .f (family) and .p (part) ascii files for
        the loading of a VDS data base. This command is used in place of
        the PDU create family and part commands. this command is to be used
        with the VDSloaddata.sh command. Operating summary is as follows:
        macro library list is displayed and a library is selected.
        A list of support files is displayed for the user to select one.
        macro is selected from macro/family list( macros with ~rep
        in the selected library appears on the list)
        Family data button appears on the form, which displays the family list.
        select the write button to create a .f (family file - macro.f in
        the local directory.  Toggle the Family button to part,enter part
        and revision number and other information.
        use the Write button to create part file(macro.p) in the local
        directory).
        Family file can be overwritten before the part file is created,
        but after the part file is created family file can only be reviewed.
        several parts can be created in the part file .
        the PART LIST button is used to display the number of parts created
        with their respective part numbers.
        when a particular part number is selected from the PART LIST the
        corresponding part file is displayed.

 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdGenFam.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/04/02  19:53:44  pinnacle
# Replaced: vdequip/fam/VDCmdGenFam.S for:  by yzhu for vds.240
#
# Revision 1.2  1996/03/01  17:35:56  pinnacle
# Replaced: vdequip/fam/VDCmdGenFam.S for:  by yzhu for vds.240
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class specification VDCmdGenFam (1:0) of VDS_LOCATE;

#include <stdlib.h>
#include <stdio.h>

/*+cmd
  Command Object Class  VDCmdGenFam

  Superclass
      VDS_LOCATE

  Methods
    evaluate_input            Private
		This message reads the information from the user and puts
		the information in the message field MESS2 which will be
		activated to treat that as input for evaluation.

    process_mac_lib           Private
                This method processes the macro library selected by
                the user,calls method set_macro_list to set up macro/family
                list on the form

    read_family_list_from_tmp Private
                This method reads  family/macro list from file
                /tmp/VDGnFmFl.fam

    get_server                Private
                This method connects to server,and calls for attaching
                attaching macro libraries.It also gives the user a
                warning initially to login to the server to avoid
                duplicate families

    VDgetFamilyFromServer     Private
                gets family tables  from DBS by executing vdb$RisSelect

    VDget_macro_objid         Private
                gets gets the macro id

    set_macro_list            Private
                sets up macro/family  list on the form

    process_macro             Private
                gets the selected  macro from the form,calls for
                getting macro id,calls method read_create_family for
                creating the family file on the form

    read_create_family        Private
                creates the family file and displays on the form

    process_family            Private
                This method is invoked  from the form_notification method
                if the family toggle button is selected.If the instance
                me->family has a value of 0,then processing for family,
                else processing for part is done>

    read_create_part          Private
                checks to see if a family file has already been created,
                else asks the user to create one using the write button,
                the file that has been displayed on the form.  It next
                set_up_part_list function to set up the part list

    reset_parts_list_of_names  Private
                checks to see the  number of parts that have been
                defined in the macro.p file,displays the part numbers
                in the part list.Depending on which part number is
                selected the corresponding part details are displayed
                on the form

    write_out_part_file       Private
                creates a part file macro.p from the part details
                displayed on the form

    check_out_family_file     Private
                This method gives the option to the user to the
                to review or overwrite a family file,and calls
                calls write_out_family file if the user wants to
                overwite the family file

  Overridden Methods

     init               Gets the name of the design file and the module
                        environment.The form of the command is displayed.
                        message is also  sent to connect to the server
                        and get macro libraries.>

     delete             deletes the form,clears up the status field
                        and frees memory that had been allocated for
                        some of the instance variables

     form_notification  notifies when the user selects/enters on
                        the form

  Forms
     Create equipment and family files        VDGenFamFil
             form has fields for selecting macro libraries,macros.
             The Family toggle button lets one select between parts or family.
             part or family data is displayed on multifield gadgets.There
             is a message field and  also a user input field on the form.
             A toggle button on the side of the  message field lets the
             user select data on the hidden multifield gadgets.The toggle
             button Add is used to add or modify a part. Write button is
             used to create part or family files.Overwrite button on the form
             lets the user overwrite a family file.

-cmd*/


instance VDCmdGenFam
{
	GRspacenum	cur_os;			/* current object space				*/
	IGRchar		filename[132],		/* design file name				*/
			initial_file[132],	/* user selected deflt file			*/
			macro_name[132],	/* selected macro name				*/
	/*		initial_file_pre[132],	 previous user selected deflt file			*/
			macro_lib[132],		/* selected library name			*/
			*big_list;		/* points to families				*/
	IGRchar		*big_parts_list,	/* holds part numbers				*/
			*big_rev_list,		/* holds revision numbers			*/
			*listing;		/* # of lines in the family			*/
	IGRchar		fam_file[132];		/* family file name				*/
	IGRchar		part_file[132];		/* part file name				*/
	IGRchar		errors[132];		/* error message string				*/
	IGRchar		error_msg[3*132];	/* error message string				*/
	IGRchar		buffer_msg[3*132];	/* buffer to hold error message			*/
	FILE		*outfile;		/* output file pointer				*/
	IGRint		numLines;		/* # of family names				*/
	IGRint		retmsg;			/* return message				*/
	IGRint		num_macros;		/* # of conditional macros in the library	*/
	IGRint		input_row;		/* gives user selected row			*/
	IGRint		num_parts,		/* number of parts that are defined		*/
			append,			/* flag to check if part needs to be added	*/
			family,			/* flag to check if toggle is family or part	*/
			review_only;		/* flag if family file is for review_only	*/
	IGRint		get_serv,		/* flag to see if server is connected		*/
			num_cpts;		/* number of connect points			*/
	struct GRid	macro_id;		/* object id of the macro			*/
        IGRint          unique_flag;            /* flag for unique of combination part name and vesion. unique = 1, other =0 */        
        IGRint  	modifyrownum;           /* record the modified row num */ 
};

override delete;
override init;
override form_notification;

message evaluate_input			( long * sts );
message process_mac_lib			( long * sts );
message VD_fill_deflt_list		( long * sts );
message process_selected_defile		( long * sts );
message read_family_list_from_tmp	( long * sts );
message get_server			( long * sts );
message VDgetFamilyFromServer		( long * sts );
message VDget_macro_objid		( long * sts );
message VDgetAttachedLibraries		( long * sts );
message set_macro_list			( long * sts );
message process_macro			(IGRlong *sts;IGRchar *selectMac);
message read_create_family		( long * sts );
message process_family			( long * sts );
message read_create_part		( long * sts );
message reset_parts_list_of_names	( long * sts );
message write_out_part_file		( long * sts );
message check_out_family_file		( long * sts );
message write_out_family_file		( long * sts );

end specification VDCmdGenFam;
