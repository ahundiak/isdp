<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
      <table name="Regular Template Report"
             description="Regular Template Report" >
	<layout>
	  <column title="Template Name"  column_no="1"/>
	  <column title="Height"         column_no="2"/>
          <column title="Angle"          column_no="3"/>
          <column title="Lean Direction" column_no="4"/>
        </layout>
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_TEMPLATES/SMS_TEMPLATE">
	  <row>
	     <cell column_no="1" value="Number of Regular Templates: {SMS_REG_TEMP/@NUM_TEMP}"/>
	     <cell column_no="2" value=""/>
	     <cell column_no="3" value=""/>
	     <cell column_no="4" value=""/>
          </row>
          <row>
	     <cell column_no="1" value="Template Name" />
	     <cell column_no="2" value="Height" />
             <cell column_no="3" value="Angle"  />
             <cell column_no="4" value="Lean Direction"/>
          </row>
          <xsl:for-each select="SMS_REG_TEMP/REG_INFO">
	     <row>
                <cell column_no="1" value="{@NAME}" />
                <cell column_no="2" value="{@TEMP_HEIGHT}" />
	        <cell column_no="3" value="{@TEMP_ANGLE}" />
	        <cell column_no="4" value="{@TEMP_LEAN_DIR}" />
             </row>
          </xsl:for-each>
	</xsl:for-each>
     </table>
  </xsl:template>
</xsl:stylesheet>
