<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
     <table name="Pin Jig Position Report" description="Pin Jig Position Report">
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_PINJIGS/SMS_PINJIG">
           <layout>
	      <column title="Column No."       column_no="1"/>
	      <column title="Row No."          column_no="2"/>
	      <column title="Name"             column_no="3"/>
	      <column title="Pin X-Position"   column_no="4"/>
	      <column title="Pin Y-Position"   column_no="5"/>
	      <column title="Pin Z-Position"   column_no="6"/>
	      <column title="Pin Height Value" column_no="7"/>
	      <column title="Pin Angle"        column_no="8"/>
           </layout>
           <xsl:for-each select="SMS_PIN_DATA/PIN_DATA" order-by="NAME">
	      <row>
                 <cell column_no="1" value="{@COL_NO}" />
                 <cell column_no="2" value="{@ROW_NO}" />
                 <cell column_no="3" value="{@NAME}" />
	         <cell column_no="4" value="{@PIN_X_POS}" />
	         <cell column_no="5" value="{@PIN_Y_POS}" />
	         <cell column_no="6" value="{@PIN_Z_POS}" />
	         <cell column_no="7" value="{@PIN_HEIGHT}" />
                 <cell column_no="8" value="{@PIN_ANGLE}" />
              </row>
           </xsl:for-each>
        </xsl:for-each>
     </table>
  </xsl:template>
</xsl:stylesheet>
