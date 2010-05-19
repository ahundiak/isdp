DATABASE training12

GLOBALS "../lib/RPTglobal.4gl"


FUNCTION foot_and_inch (len)
   DEFINE       len     FLOAT
   DEFINE       foot    INTEGER,
                inch    INTEGER

   LET foot = len / 1
   LET inch = (len - foot) * 12

   RETURN foot, inch
END FUNCTION


FUNCTION element_length ( number, divider)

  DEFINE	number  	FLOAT,
        	divider 	INTEGER,
        	foot    	INTEGER,
         	inch    	FLOAT,
		meter		FLOAT,
         	str     	CHAR(10),
         	len     	CHAR(13)

  IF p_vds.prj_units_set = 1 THEN
     LET foot = number / 12.0
     LET inch = number - (foot * 12.0)
     CALL fraction_format (inch, divider) RETURNING str
     LET len = foot USING "<<<<&", "\'-", str CLIPPED, "\""
  ELSE
     LET meter = number / 1000.0
     LET len = meter USING "<<<<&.<<<"
  END IF

  RETURN len
END FUNCTION


FUNCTION element_size (f_args)
  DEFINE f_args RECORD e_code LIKE "nfmadmin".hvac_dynamic.shape_code,
		       e_desc LIKE "nfmadmin".hvac_codelist.long_txt,
		       dg     LIKE "nfmadmin".hvac_dynamic.depth_g,
		       dr     LIKE "nfmadmin".hvac_dynamic.depth_r,
		       wg     LIKE "nfmadmin".hvac_dynamic.width_g,
		       wr     LIKE "nfmadmin".hvac_dynamic.width_r
                END RECORD
  DEFINE green   INTEGER,
         red     INTEGER
  DEFINE e_size CHAR(30),
         g_size CHAR(30),
         r_size CHAR(30),
	 sign   CHAR(3)

#DISPLAY "\nshape_code = ", f_args.e_code USING "<<<&",
#	" | long_txt = ", f_args.e_desc CLIPPED,
#	" | width_g = ", f_args.wg USING "####.#",
#	" | depth_g = ", f_args.dg USING "####.#",
#	" | width_r = ", f_args.wr USING "####.#",
#	" | depth_r = ", f_args.dr USING "####.#"

  IF p_vds.prj_units_set = 1 THEN LET sign = "\""
  ELSE			          LET sign = ""
  END IF 

  IF f_args.e_code <= 1 THEN
     IF f_args.wr != f_args.wg THEN
        LET e_size = f_args.wg USING "<<<<&",
                     f_args.dg USING "x<<<<&", sign CLIPPED,
                     f_args.wr USING ",<<<<&",
                     f_args.dr USING "x<<<<&", sign CLIPPED
     ELSE
        LET e_size = f_args.wg USING "<<<<&", "x",
                     f_args.dg USING "<<<<&", sign CLIPPED
     END IF
  ELSE
     IF f_args.e_code = 2 THEN
        IF f_args.wr != f_args.wr THEN
           LET e_size = f_args.wg USING "<<<<&",
                        f_args.wr USING "x<<<<&", sign CLIPPED
        ELSE
           LET e_size = f_args.wg USING "<<<<&", sign CLIPPED
        END IF
     ELSE
        CALL shape_determination (f_args.e_desc, 1+length(f_args.e_desc))
             RETURNING green, red

        IF green <= 1 THEN
           LET g_size = f_args.wg USING "<<<<&",
                        f_args.dg USING "x<<<<&", sign CLIPPED
        ELSE
           LET g_size = f_args.wg USING "<<<<&", sign CLIPPED
        END IF

        IF f_args.wg > 0.0 THEN
           IF red <= 1  THEN
              LET r_size = f_args.wr USING "<<<<&",
                           f_args.dr USING "x<<<<&", sign CLIPPED
           ELSE
              LET r_size = f_args.wr USING "<<<<&", sign CLIPPED
           END IF

           LET e_size = g_size CLIPPED, ",", r_size CLIPPED
        ELSE
           LET e_size = g_size CLIPPED
        END IF
     END IF
  END IF

#DISPLAY "\telement_size returns <", e_size CLIPPED, ">"

  RETURN e_size
END FUNCTION


FUNCTION size_of_element (green, red)

  DEFINE 	green   FLOAT,
         	red     FLOAT,
	 	m_green	FLOAT,
	 	m_red	FLOAT,
  	 	e_size  CHAR(30),
         	str_g   CHAR(30),
         	str_r   CHAR(30),
         	divider INTEGER

  IF p_vds.prj_units_set = 20 THEN

     LET m_green = -1.0
     LET m_red   = -1.0

     SELECT UNIQUE npdg.npd_equiv, npdr.npd_equiv
     INTO m_green, m_red
     FROM "nfmadmin".piping_npd_allowed npdg, "nfmadmin".piping_npd_allowed npdr
     WHERE (npdg.tblno = 0 AND npdg.npd = green)
     AND   (npdr.tblno = 0 AND npdr.npd = red)

     IF m_green = -1.0 THEN LET m_green = green END IF
     IF m_red   = -1.0 THEN LET m_red   = red   END IF

     IF m_red = 0.0 THEN LET e_size = m_green USING "<<<<&"
     ELSE                LET e_size = m_green USING "<<<<&",
                                      m_red   USING "x<<<<&"
     END IF
  ELSE
     LET divider = 4
     CALL fraction_format ( green, divider) RETURNING str_g

     IF red = 0.0 THEN
       LET e_size = str_g CLIPPED, "\""
     ELSE
       CALL fraction_format ( red, divider) RETURNING str_r
       LET e_size = str_g CLIPPED, "x", str_r CLIPPED, "\""
     END IF

  END IF

  RETURN e_size

END FUNCTION


FUNCTION update_piping_on ()
  COMMIT WORK
  BEGIN WORK
     UPDATE "nfmadmin".piping_dynamic SET npd_r = npd_g WHERE npd_r = 0.00
  COMMIT WORK
END FUNCTION


FUNCTION update_piping_off ()
  COMMIT WORK
  BEGIN WORK
     UPDATE "nfmadmin".piping_dynamic SET npd_r = 0.00 WHERE npd_r = npd_g
  COMMIT WORK
END FUNCTION


FUNCTION update_hvac ()
  DEFINE hvac_dyn ARRAY[5000] OF RECORD
                         width_g        LIKE    "nfmadmin".hvac_dynamic.width_g,
                         depth_g        LIKE    "nfmadmin".hvac_dynamic.depth_g,
                         width_r        LIKE    "nfmadmin".hvac_dynamic.width_r,
                         depth_r        LIKE    "nfmadmin".hvac_dynamic.depth_r,
                         comp_seqno     LIKE    "nfmadmin".hvac_dynamic.comp_seqno,
                         assembly_cat   LIKE    "nfmadmin".hvac_dynamic.assembly_cat,
                         assembly_nam   LIKE    "nfmadmin".hvac_dynamic.assembly_nam,
                         assembly_ver   LIKE    "nfmadmin".hvac_dynamic.assembly_ver,
			 spec_name	LIKE	"nfmadmin".hvac_dynamic.spec_name
                  END RECORD
  DEFINE hv_cnt, i      INTEGER
  DEFINE hv_message	CHAR(80)
  DEFINE hv_spec	LIKE "nfmadmin".hvac_dynamic.spec_name

  DECLARE hv_curs CURSOR FOR
    SELECT width_g, depth_g, width_r, depth_r,
           comp_seqno, assembly_cat, assembly_nam, assembly_ver,
	   spec_name
    FROM   "nfmadmin".hvac_dynamic
    WHERE  assembly_cat LIKE q_hv.assembly_cat
    AND    assembly_nam LIKE q_hv.assembly_nam
    AND    assembly_ver LIKE q_hv.assembly_ver

  LET hv_cnt = 1

  FOREACH hv_curs INTO hvac_dyn[hv_cnt].*
    IF STATUS < 0 THEN
      LET hv_message = "No rows found in query"
      CALL ERRORLOG (hv_message)
      MESSAGE hv_message
      SLEEP 3
      EXIT FOREACH
    ELSE
      IF hv_cnt > 5000 THEN
        LET hv_message = "Can only update the 5000 first rows"
        CALL ERRORLOG (hv_message)
        MESSAGE hv_message
        EXIT FOREACH
      ELSE
        CALL correct_HVcheckin (hvac_dyn[hv_cnt].*) RETURNING hvac_dyn[hv_cnt].*
        LET hv_cnt = hv_cnt + 1
      END IF
    END IF
  END FOREACH

  LET hv_cnt = hv_cnt - 1
  LET hv_message = "Updating ", hv_cnt USING "<<<<", " rows ..."
  MESSAGE hv_message

  IF p_vds.prj_units_set = 1 THEN LET hv_spec = "SERV1"
  ELSE				  LET hv_spec = "SERV2" END IF


  FOR i = 1 TO hv_cnt
     IF hvac_dyn[i].spec_name != hv_spec OR hvac_dyn[i].spec_name IS NULL THEN
        COMMIT WORK
        BEGIN WORK
           UPDATE "nfmadmin".hvac_dynamic
              SET spec_name = hv_spec,
                  width_g   = hvac_dyn[i].width_g,
                  depth_g   = hvac_dyn[i].depth_g,
                  width_r   = hvac_dyn[i].width_r,
                  depth_r   = hvac_dyn[i].depth_r
              WHERE comp_seqno   = hvac_dyn[i].comp_seqno
                AND assembly_cat = hvac_dyn[i].assembly_cat
                AND assembly_nam = hvac_dyn[i].assembly_nam
                AND assembly_ver = hvac_dyn[i].assembly_ver
        COMMIT WORK
     END IF
  END FOR

END FUNCTION


FUNCTION correct_HVcheckin (hvac_dyn)
  DEFINE hvac_dyn RECORD width_g	 LIKE 	 "nfmadmin".hvac_dynamic.width_g,
			 depth_g         LIKE    "nfmadmin".hvac_dynamic.depth_g,
			 width_r         LIKE    "nfmadmin".hvac_dynamic.width_r,
			 depth_r         LIKE    "nfmadmin".hvac_dynamic.depth_r,
			 comp_seqno      LIKE    "nfmadmin".hvac_dynamic.comp_seqno,
			 assembly_cat    LIKE    "nfmadmin".hvac_dynamic.assembly_cat,
			 assembly_nam    LIKE    "nfmadmin".hvac_dynamic.assembly_nam,
			 assembly_ver    LIKE    "nfmadmin".hvac_dynamic.assembly_ver,
			 spec_name       LIKE    "nfmadmin".hvac_dynamic.spec_name
                  END RECORD
  DEFINE	wg, dg, wr, dr	FLOAT
	

  # find WIDTH_G : the higher value of the 4 entries
  IF ( hvac_dyn.width_g >= hvac_dyn.depth_g
  AND  hvac_dyn.width_g >= hvac_dyn.width_r
  AND  hvac_dyn.width_g >= hvac_dyn.depth_r ) THEN
  ELSE 
    IF ( hvac_dyn.depth_g >= hvac_dyn.width_g
    AND  hvac_dyn.depth_g >= hvac_dyn.width_r
    AND  hvac_dyn.depth_g >= hvac_dyn.depth_r ) THEN
      LET wg = hvac_dyn.depth_g
      LET hvac_dyn.depth_g = hvac_dyn.width_g
      LET hvac_dyn.width_g = wg
      LET wr = hvac_dyn.depth_r
      LET hvac_dyn.depth_r = hvac_dyn.width_r
      LET hvac_dyn.width_r = wr
    ELSE
      IF ( hvac_dyn.width_r >= hvac_dyn.width_g
      AND  hvac_dyn.width_r >= hvac_dyn.depth_g
      AND  hvac_dyn.width_r >= hvac_dyn.depth_r ) THEN
        LET wg = hvac_dyn.width_g
        LET dg = hvac_dyn.depth_g
        LET hvac_dyn.width_g = hvac_dyn.width_r
        LET hvac_dyn.depth_g = hvac_dyn.depth_r
        LET hvac_dyn.width_r = wg
        LET hvac_dyn.depth_r = dg
      ELSE
        LET wg = hvac_dyn.width_g
        LET dg = hvac_dyn.depth_g
        LET hvac_dyn.width_g = hvac_dyn.depth_r
        LET hvac_dyn.depth_g = hvac_dyn.width_r
        LET hvac_dyn.width_r = wg
        LET hvac_dyn.depth_r = dg
      END IF
    END IF
  END IF

  # convert to PDS agreement 
  IF hvac_dyn.width_g = hvac_dyn.width_r 
  AND  hvac_dyn.depth_g = hvac_dyn.depth_r THEN
     LET hvac_dyn.width_r = 0.00
     LET hvac_dyn.depth_r = 0.00
  END IF

  RETURN hvac_dyn.*

END FUNCTION


FUNCTION update_rway ()
  DEFINE rway_dyn ARRAY[5000] OF RECORD
                         width_g        LIKE    "nfmadmin".rway_dynamic.width_g,
                         depth_g        LIKE    "nfmadmin".rway_dynamic.depth_g,
                         width_r        LIKE    "nfmadmin".rway_dynamic.width_r,
                         depth_r        LIKE    "nfmadmin".rway_dynamic.depth_r,
                         comp_seqno     LIKE    "nfmadmin".rway_dynamic.comp_seqno,
                         assembly_cat   LIKE    "nfmadmin".rway_dynamic.assembly_cat,
                         assembly_nam   LIKE    "nfmadmin".rway_dynamic.assembly_nam,
                         assembly_ver   LIKE    "nfmadmin".rway_dynamic.assembly_ver,
                         spec_name      LIKE    "nfmadmin".rway_dynamic.spec_name
                  END RECORD
  DEFINE rw_cnt, i      INTEGER
  DEFINE rw_message	CHAR(80)
  DEFINE rw_spec	LIKE "nfmadmin".rway_dynamic.spec_name

  DECLARE rw_curs CURSOR FOR
    SELECT width_g, depth_g, width_r, depth_r,
           comp_seqno, assembly_cat, assembly_nam, assembly_ver,
	   spec_name
    FROM   "nfmadmin".rway_dynamic
    WHERE  assembly_cat LIKE q_rw.assembly_cat
    AND    assembly_nam LIKE q_rw.assembly_nam
    AND    assembly_ver LIKE q_rw.assembly_ver
  LET rw_cnt = 1

  FOREACH rw_curs INTO rway_dyn[rw_cnt].*
    IF STATUS < 0 THEN
      LET rw_message = "No rows found in query"
      CALL ERRORLOG (rw_message)
      MESSAGE rw_message
      SLEEP 3
      EXIT FOREACH
    ELSE
      IF rw_cnt > 5000 THEN
        LET rw_message = "Can only update the 5000 first rows"
        CALL ERRORLOG (rw_message)
        MESSAGE rw_message
        EXIT FOREACH
      ELSE
        CALL correct_RWcheckin (rway_dyn[rw_cnt].*) RETURNING rway_dyn[rw_cnt].*
        LET rw_cnt = rw_cnt + 1
      END IF
    END IF
  END FOREACH

  LET rw_cnt = rw_cnt - 1
  LET rw_message = "Updating ", rw_cnt USING "<<<<", " rows ..."
  MESSAGE rw_message

  IF p_vds.prj_units_set = 1 THEN LET rw_spec = "VEND1"
  ELSE				  LET rw_spec = "VEND2" END IF

  FOR i = 1 TO rw_cnt
     IF rway_dyn[i].spec_name != rw_spec OR rway_dyn[i].spec_name IS NULL THEN
        COMMIT WORK
        BEGIN WORK
           UPDATE "nfmadmin".rway_dynamic
              SET spec_name = rw_spec,
                  width_g   = rway_dyn[i].width_g,
                  depth_g   = rway_dyn[i].depth_g,
                  width_r   = rway_dyn[i].width_r,
                  depth_r   = rway_dyn[i].depth_r
              WHERE comp_seqno   = rway_dyn[i].comp_seqno
                AND assembly_cat = rway_dyn[i].assembly_cat
                AND assembly_nam = rway_dyn[i].assembly_nam
                AND assembly_ver = rway_dyn[i].assembly_ver
        COMMIT WORK
     END IF
  END FOR

END FUNCTION


FUNCTION correct_RWcheckin (rway_dyn)
  DEFINE rway_dyn RECORD width_g	 LIKE 	 "nfmadmin".rway_dynamic.width_g,
			 depth_g         LIKE    "nfmadmin".rway_dynamic.depth_g,
			 width_r         LIKE    "nfmadmin".rway_dynamic.width_r,
			 depth_r         LIKE    "nfmadmin".rway_dynamic.depth_r,
			 comp_seqno      LIKE    "nfmadmin".rway_dynamic.comp_seqno,
			 assembly_cat    LIKE    "nfmadmin".rway_dynamic.assembly_cat,
			 assembly_nam    LIKE    "nfmadmin".rway_dynamic.assembly_nam,
			 assembly_ver    LIKE    "nfmadmin".rway_dynamic.assembly_ver,
			 spec_name       LIKE    "nfmadmin".rway_dynamic.spec_name
                  END RECORD
  DEFINE        wg, dg, wr, dr  FLOAT

  # find WIDTH_G : the higher value of the 4 entries
  IF ( rway_dyn.width_g >= rway_dyn.depth_g
  AND  rway_dyn.width_g >= rway_dyn.width_r
  AND  rway_dyn.width_g >= rway_dyn.depth_r ) THEN
  ELSE 
    IF ( rway_dyn.depth_g >= rway_dyn.width_g
    AND  rway_dyn.depth_g >= rway_dyn.width_r
    AND  rway_dyn.depth_g >= rway_dyn.depth_r ) THEN
      LET wg = rway_dyn.depth_g
      LET rway_dyn.depth_g = rway_dyn.width_g
      LET rway_dyn.width_g = wg
      LET wr = rway_dyn.depth_r
      LET rway_dyn.depth_r = rway_dyn.width_r
      LET rway_dyn.width_r = wr
    ELSE
      IF ( rway_dyn.width_r >= rway_dyn.width_g
      AND  rway_dyn.width_r >= rway_dyn.depth_g
      AND  rway_dyn.width_r >= rway_dyn.depth_r ) THEN
        LET wg = rway_dyn.width_g
        LET dg = rway_dyn.depth_g
        LET rway_dyn.width_g = rway_dyn.width_r
        LET rway_dyn.depth_g = rway_dyn.depth_r
        LET rway_dyn.width_r = wg
        LET rway_dyn.depth_r = dg
      ELSE
        LET wg = rway_dyn.width_g
        LET dg = rway_dyn.depth_g
        LET rway_dyn.width_g = rway_dyn.depth_r
        LET rway_dyn.depth_g = rway_dyn.width_r
        LET rway_dyn.width_r = wg
        LET rway_dyn.depth_r = dg
      END IF
    END IF
  END IF

  # convert to PDS agreement 
  IF ( rway_dyn.width_g = rway_dyn.width_r 
  AND  rway_dyn.depth_g = rway_dyn.depth_r ) THEN
    LET rway_dyn.width_r = 0.00
    LET rway_dyn.depth_r = 0.00
  END IF

  RETURN rway_dyn.*

END FUNCTION

FUNCTION ROUTEunits_convert ( parameter, family, partnum, value, code)
  DEFINE	parameter       CHAR(20),
		family		LIKE "nfmadmin".piping_comps.family_name,
		partnum		CHAR(32),
		value		FLOAT,
		code		SMALLINT

  DEFINE	factor		LIKE "nfmadmin".vds_convert.cnvr_fctr,
		offset		LIKE "nfmadmin".vds_convert.cnvr_offset,
		roundoff	LIKE "nfmadmin".vds_convert.rndoff_fctr,
		query_str	CHAR(300)
  DEFINE p_usg	RECORD	 units_set	 CHAR(20)	 END RECORD

  LET query_str = "SELECT UNIQUE units_set FROM \"nfmadmin\".", family CLIPPED,
                  " WHERE n_itemname = \'", partnum CLIPPED, "\'"
  PREPARE usg FROM query_str
  DECLARE crs CURSOR FOR usg
  FOREACH crs INTO p_usg.*
     IF STATUS < 0 THEN
        EXIT FOREACH
     ELSE
        SELECT "nfmadmin".vds_convert.cnvr_fctr,
	       "nfmadmin".vds_convert.cnvr_offset,
	       "nfmadmin".vds_convert.rndoff_fctr
        INTO   factor,
               offset,
               roundoff
        FROM "nfmadmin".vds_convert,
             "nfmadmin".vds_units
        WHERE ("nfmadmin".vds_units.param_name LIKE parameter
        AND   "nfmadmin".vds_units.units_set   = p_usg.units_set)
        AND   ("nfmadmin".vds_convert.units_in  = "nfmadmin".vds_units.units_code)
        AND   ("nfmadmin".vds_convert.units_out = code)

	IF STATUS = NOTFOUND THEN
	   RETURN value
	END IF
 
        CALL unit_convert ( factor, offset, roundoff, value)
             RETURNING value
        EXIT FOREACH
     END IF
  END FOREACH
  RETURN value

END FUNCTION

FUNCTION  VDSunits_convert ( parameter, value )
  DEFINE	parameter	CHAR(20),
		value		FLOAT

  DEFINE	factor		LIKE "nfmadmin".vds_convert.cnvr_fctr,
		offset		LIKE "nfmadmin".vds_convert.cnvr_offset,
		roundoff	LIKE "nfmadmin".vds_convert.rndoff_fctr,
		units_in	LIKE "nfmadmin".vds_units.units_code,
		units_out	LIKE "nfmadmin".vds_units.units_code

# As currently the base units for the length are in mm for Metric and
# Inches for imperial they have to be converted to Mts and Feet respect..

	IF  (p_vds.prj_units_set = 1   OR 
	     p_vds.prj_units_set = 20 ) THEN
	     IF parameter = "v_length"  THEN
		CALL length_unit_convert (value, 1, p_vds.prj_units_set )
		  RETURNING value
	     ELSE 
		IF parameter = "v_area" THEN
		CALL length_unit_convert (value, 2, p_vds.prj_units_set )
		  RETURNING value
	     	ELSE 
		   IF parameter = "v_volume" THEN
		     CALL length_unit_convert (value, 3, p_vds.prj_units_set )
		       RETURNING value
		   END IF
		END IF
	     END IF
	   
	END IF

	IF units_in = units_out THEN RETURN value END IF

  	SELECT "nfmadmin".vds_units.units_code 
  	INTO   units_in
  	FROM   "nfmadmin".vds_units
  	WHERE  ("nfmadmin".vds_units.param_name LIKE parameter
  	AND    "nfmadmin".vds_units.units_set = p_vds.prj_units_set )

  	SELECT "nfmadmin".vds_units.units_code 
  	INTO   units_out
  	FROM   "nfmadmin".vds_units
  	WHERE  ("nfmadmin".vds_units.param_name LIKE parameter
  	AND    "nfmadmin".vds_units.units_set = p_vds.report_units )

        SELECT "nfmadmin".vds_convert.cnvr_fctr,
	       "nfmadmin".vds_convert.cnvr_offset,
	       "nfmadmin".vds_convert.rndoff_fctr
        INTO   factor,
               offset,
               roundoff
        FROM   "nfmadmin".vds_convert
	WHERE  ("nfmadmin".vds_convert.units_in = units_in
	AND	"nfmadmin".vds_convert.units_out = units_out )

        CALL unit_convert ( factor, offset, roundoff, value)
             RETURNING value

	RETURN value

END FUNCTION

FUNCTION unit_convert ( factor, offset, roundoff, input_value)
  DEFINE	factor		LIKE "nfmadmin".vds_convert.cnvr_fctr,
		offset		LIKE "nfmadmin".vds_convert.cnvr_offset,
		roundoff	LIKE "nfmadmin".vds_convert.rndoff_fctr,
		input_value	FLOAT

  DEFINE	value_rnd	FLOAT,
		value_out	FLOAT,
		value_int	INTEGER

  IF factor IS NULL OR offset IS NULL OR roundoff IS NULL THEN
     LET value_rnd = input_value
     RETURN value_rnd
  END IF

  LET value_out = (input_value * factor) + offset

  IF (roundoff != 0.0) THEN
     LET value_rnd = value_out / roundoff
     LET value_int = value_rnd
     IF ((value_rnd - value_int) < 0.5) THEN LET value_rnd = value_int
     ELSE				     LET value_rnd = value_int + 1.0
     END IF
     LET value_rnd = value_rnd * roundoff
  END IF
  
  RETURN value_rnd

END FUNCTION


FUNCTION PPunits_set (attr_name)

	DEFINE	attr_name	CHAR(80)

	DEFINE	spec_units	LIKE "nfmadmin".piping_spec.units_set,
		proj_code 	LIKE "nfmadmin".vds_units.units_code,
		spec_code 	LIKE "nfmadmin".vds_units.units_code,
		flag		SMALLINT

	IF drawing_flag = 0 THEN
           SELECT UNIQUE units_set
           INTO   spec_units
           FROM   "nfmadmin".piping_spec,
	          "nfmadmin".piping_dynamic
           WHERE  ("nfmadmin".piping_dynamic.assembly_cat LIKE q_pp.assembly_cat
	   OR     "nfmadmin".piping_dynamic.assembly_cat IS NULL)
           AND    ("nfmadmin".piping_dynamic.assembly_nam LIKE q_pp.assembly_nam
	   OR     "nfmadmin".piping_dynamic.assembly_nam IS NULL)
           AND    ("nfmadmin".piping_dynamic.assembly_ver LIKE q_pp.assembly_ver
	   OR     "nfmadmin".piping_dynamic.assembly_ver IS NULL)
           AND    ("nfmadmin".piping_dynamic.system_name  LIKE q_pp.system_name
	   OR     "nfmadmin".piping_dynamic.system_name IS NULL)
           AND    ("nfmadmin".piping_dynamic.zone_number  LIKE q_pp.zone_number
	   OR     "nfmadmin".piping_dynamic.zone_number IS NULL)
           AND    ("nfmadmin".piping_dynamic.apprv_stat   LIKE q_pp.apprv_stat
	   OR     "nfmadmin".piping_dynamic.apprv_stat IS NULL)
           AND    ("nfmadmin".piping_dynamic.constr_stat  LIKE q_pp.constr_stat
	   OR     "nfmadmin".piping_dynamic.constr_stat IS NULL)
           AND    "nfmadmin".piping_dynamic.spec_name    = "nfmadmin".piping_spec.spec_name
	ELSE
           SELECT UNIQUE units_set
           INTO   spec_units
           FROM   "nfmadmin".piping_spec,
	          "nfmadmin".piping_dynamic,
		  "nfmadmin".piping_cit
    	   WHERE  "nfmadmin".piping_cit.dwg_cat          LIKE q_pp.assembly_cat
    	   AND    "nfmadmin".piping_cit.dwg_nam          LIKE q_pp.assembly_nam
    	   AND    "nfmadmin".piping_cit.dwg_rev          LIKE q_pp.assembly_ver
    	   AND    "nfmadmin".piping_cit.assembly_cat     = "nfmadmin".piping_dynamic.assembly_cat
    	   AND    "nfmadmin".piping_cit.assembly_nam     = "nfmadmin".piping_dynamic.assembly_nam
    	   AND    "nfmadmin".piping_cit.assembly_rev     = "nfmadmin".piping_dynamic.assembly_ver
    	   AND    "nfmadmin".piping_cit.comp_seqno       = "nfmadmin".piping_dynamic.comp_seqno
           AND    ("nfmadmin".piping_dynamic.system_name  LIKE q_pp.system_name
	   OR     "nfmadmin".piping_dynamic.system_name IS NULL)
           AND    ("nfmadmin".piping_dynamic.zone_number  LIKE q_pp.zone_number
	   OR     "nfmadmin".piping_dynamic.zone_number IS NULL)
           AND    ("nfmadmin".piping_dynamic.apprv_stat   LIKE q_pp.apprv_stat
	   OR     "nfmadmin".piping_dynamic.apprv_stat IS NULL)
           AND    ("nfmadmin".piping_dynamic.constr_stat  LIKE q_pp.constr_stat
	   OR     "nfmadmin".piping_dynamic.constr_stat IS NULL)
	END IF

	IF spec_units = p_vds.prj_units_set THEN LET flag = 0
        ELSE
	   SELECT UNIQUE proj.units_code,
			 spec.units_code
	   INTO   proj_code,
                  spec_code
	   FROM   "nfmadmin".vds_units proj,
		  "nfmadmin".vds_units spec
           WHERE  (proj.param_name = attr_name
	   AND    proj.units_set   = p_vds.prj_units_set)
           AND    (spec.param_name = attr_name
	   AND    spec.units_set   = spec_units)

	   IF proj_code = spec_code THEN LET flag = 0
	   ELSE			         LET flag = 1
           END IF
	END IF

	RETURN flag

END FUNCTION
