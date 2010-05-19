DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"

FUNCTION RWEquery ()

  LET w_reg =
" AND \"nfmadmin\".rway_dynamic.err_cmp_flg  = 'Y' ",
"AND (\"nfmadmin\".vds_units.param_name     = 'thk' ",
"AND \"nfmadmin\".vds_units.units_set       = ", p_vds.prj_units_set USING "<<", " ",
"AND \"nfmadmin\".vds_convert.units_in      = \"nfmadmin\".rway_spec.units_set ",
"AND \"nfmadmin\".vds_convert.units_out     = \"nfmadmin\".vds_units.units_code) ",
"AND \"nfmadmin\".rway_spec.prj_no = ",default_prj_no

  LET f_reg =
"\"nfmadmin\".rway_dynamic, ",
"\"nfmadmin\".rway_spec, ",
"OUTER \"nfmadmin\".vds_convert, ",
"\"nfmadmin\".vds_units"

##########################  Create RWE query ###################################
  LET s_stmt =
"\"nfmadmin\".rway_dynamic.spec_name, ",
"\"nfmadmin\".rway_dynamic.system_name, ",
"\"nfmadmin\".rway_dynamic.comp_code, ",
"\"nfmadmin\".rway_dynamic.width_g, ",
"\"nfmadmin\".rway_dynamic.depth_g, ",
"\"nfmadmin\".rway_dynamic.width_r, ",
"\"nfmadmin\".rway_dynamic.depth_r, ",
"\"nfmadmin\".rway_dynamic.rway_type, ",
"\"nfmadmin\".rway_dynamic.loc_x, ",
"\"nfmadmin\".rway_dynamic.loc_y, ",
"\"nfmadmin\".rway_dynamic.loc_z, ",
"\"nfmadmin\".rway_dynamic.err_cmp_flg, ",
"\"nfmadmin\".vds_convert.cnvr_fctr, ",
"\"nfmadmin\".vds_convert.cnvr_offset, ",
"\"nfmadmin\".vds_convert.rndoff_fctr"

   CASE drawing_flag
      WHEN 0 LET f_stmt = f_reg CLIPPED
      WHEN 1 LET f_stmt = "rway_cit, ", f_reg CLIPPED
   END CASE

   LET w_stmt = w_stmt CLIPPED, w_reg CLIPPED

   LET o_stmt =
"\"nfmadmin\".rway_dynamic.system_name, ",
"\"nfmadmin\".rway_dynamic.comp_code"

   CALL RPTquery ( 0, 1)
END FUNCTION
