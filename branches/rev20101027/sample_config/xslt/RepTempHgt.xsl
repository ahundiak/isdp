<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
      <table name="Template Height Report"
             description="Spine Template Report" >
	<layout>
	  <column title="Step Value" column_no="1"/>
	  <column title="Height"     column_no="2"/>
        </layout>
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_TEMPLATES/SMS_TEMPLATE">
          <xsl:for-each select="SMS_TEMPLATE_SET/SMS_TEMPLATE" order-by="INDEX">
	    <row>
	      <cell column_no="1" value="Template Index: {@INDEX}"/>
	      <cell column_no="2" value=""/>
            </row>
            <row>
	      <cell column_no="1" value="Step Value" />
	      <cell column_no="2" value="Height" />
            </row>
            <xsl:for-each select="SMS_STEP_INFO">
	       <row>
                  <cell column_no="1" value="{@STEP_VALUE}" />
                  <cell column_no="2" value="{@TEMP_HEIGHT}" />
               </row>
            </xsl:for-each>
          </xsl:for-each>
	</xsl:for-each>
     </table>
  </xsl:template>
</xsl:stylesheet>
