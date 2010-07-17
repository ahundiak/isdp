# I/STRUCT
#
# This is a sample formatting file for reports generated from the model by
# the command "Generate Plate Report From Model" (VSGnPlRpMd)
# To format columns, use command
#	!col attr = <attribute> width = <number> title = <text>
# where:
#	<attribute> is the name of a plate attribute
#	<number>    is the width of the column (a positive number)
#	<title>     is the title of the column (a character string delimited
#		     by "'s )
#
# There must be one "!col" command per column to display.
# As this file is read, lines beginning with '#' will be ignored, any kind of
# text may be input after all the "!col" commands: it will be copied to the
# report file as is and will appear before the column output.
#
# The available attributes for a plate are
# - family_name		Family name of plate
# - part_num		Type of plate
# - memb_name		Name of plate
# - memb_class		Class of plate (primary,secondary,etc.)
# - memb_type		Qualifier of plate (solid,coated,etc.)
# - memb_geom		Geometry qualifier of plate (planar,etc.)
# - material		Material of plate
# - grade		Grade of material
# - notes		User comments
# - source_no		Source number
# - stock_no		Stock number
# - volume		Volume of plate
# - surface_area	Area of plate
# - cog_x		X of center of gravity of plate
# - cog_y		Y of center of gravity of plate
# - cog_z		Z of center of gravity of plate
# - plate_length	Length of plate
# - plate_width		Width of plate
# - plate_thk		Thickness of plate
# - fp_thick		Fireproofing thickness
# - apprv_stat		Approval status
# - constr_stat		Construction status
# - chg_no		Change request number
# - And all of the user attributes.
#
!col attr = family_name  width = 15 title = "Plate family"
!col attr = part_num     width = 15 title = "Plate type"
!col attr = memb_name    width = 10 title = "Plate name"
!col attr = material     width = 10 title = "Material"
!col attr = grade        width = 10 title = "Grade"

			===================
			SAMPLE PLATE REPORT
			===================

