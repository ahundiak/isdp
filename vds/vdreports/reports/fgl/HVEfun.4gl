DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION HVEquery ()

   LET w_reg =
" AND \"nfmadmin\".hvac_dynamic.err_cmp_flg   = 'Y' ",
"AND (\"nfmadmin\".vds_units.param_name      = 'thk' ",
"AND \"nfmadmin\".vds_units.units_set        = ", p_vds.prj_units_set USING "<<", " ",
"AND \"nfmadmin\".vds_convert.units_in       = \"nfmadmin\".hvac_spec.units_set ",
"AND \"nfmadmin\".vds_convert.units_out      = \"nfmadmin\".vds_units.units_code) ",
"AND \"nfmadmin\".hvac_spec.prj_no = ",default_prj_no

   LET f_reg =
"\"nfmadmin\".hvac_dynamic, ",
"\"nfmadmin\".hvac_spec, ",
"OUTER (\"nfmadmin\".vds_convert), ",
"\"nfmadmin\".vds_units"

##########################  Create HVE query ###################################
   LET s_stmt =
"\"nfmadmin\".hvac_dynamic.spec_name, ",
"\"nfmadmin\".hvac_dynamic.system_name, ",
"\"nfmadmin\".hvac_dynamic.comp_code, ",
"\"nfmadmin\".hvac_dynamic.width_g, ",
"\"nfmadmin\".hvac_dynamic.depth_g, ",
"\"nfmadmin\".hvac_dynamic.width_r, ",
"\"nfmadmin\".hvac_dynamic.depth_r, ",
"\"nfmadmin\".hvac_dynamic.shape_code, ",
"\"nfmadmin\".hvac_dynamic.loc_x, ",
"\"nfmadmin\".hvac_dynamic.loc_y, ",
"\"nfmadmin\".hvac_dynamic.loc_z, ",
"\"nfmadmin\".hvac_dynamic.err_cmp_flg, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "hvac_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".hvac_dynamic.system_name, ",
"\"nfmadmin\".hvac_dynamic.comp_code"

   CALL RPTquery ( 0, 1)
END FUNCTION
