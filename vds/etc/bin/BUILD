Main build process
------------------

vd_make
-------

   options:
   -------
	echo "Undone I/VDS protection ?"		chmod +w 
	echo "Clean all VDS executables ?"		vd_clean
	echo "Remove VDS mkfiles ?"			vd_rmmkf
	echo "Check against DEBUG options ?"		vd_debug
	echo "touch *.sl files to compile ?"		touch all *sl
	echo "Check *.sl files to compile ?"		compile all *sl
	echo "compile vds ?"				build
	echo "Change release number: ?"			vd_updproddef
	echo "Creation of VDS.o and OMprodinit.o ?"	vd_dload
	echo "Creation of the release on the server ?"	vd_release

   Actions
   -------
	script	     optional   action
	-----	     -------	------
			opt	change protection
   	vd_clean	opt	
   	vd_rmmkf	opt	remove mkfiles
	vd_debug	opt	check for debug flags in grmake
        msgbuild		build message files
				remove spec files
			opt	touch *.sl
			opt	compile all *.sl
				link all spec files
  	vd_stop			stop compile on selected dir
  	vd_reports 0		move makefile to _makefile
			opt	build
  	vd_updproddef	opt	change release number in product.def
  	vd_dload	opt	dload (update VDversion.o)
  	vd_release	opt	compress, send to newprod

Other Scripts
------------
	vd_move		move vds release to previous version of vds 

vd_release24    
vd_config       vd_make_t       vd_release_t    vd_tbl
vdmsgbuild


README
-----
	$VDS/etc/version/README
	$VDS/config/dload/init/VDversion.o
