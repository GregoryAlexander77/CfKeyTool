<cfcomponent displayname="keytool" hint="Executes keytool to import or delete certs into the CF keystore">
	
	<!--- Created by Gregory Alexander --->

	  <!--- Global vars --->
    <cfset pathToKeyTool = 'C:\ColdFusion11\cfusion\jetty\jre\bin'>
    
    <!--- Function to create a new certificate and import it into the ColdFusion certificate store.  --->
    <cffunction access="public" name="createAndImportCert" output="yes" returntype="string">
		<cfargument name="keyStore" type="string" required="yes" hint="The location and name of the keystore, ie: C:\ColdFusion11\jre\lib\security\cacerts">
        <cfargument name="keyStorePassword" type="string" required="yes" hint="The keystore password. If you have not set it, it defaults to changeit">
        <cfargument name="keyPassword" type="string" required="yes">
        <cfargument name="certAlias" type="string" required="yes">
        <cfargument name="certName" type="string" required="yes">
        <cfargument name="certFile" type="string" required="yes">
        <cfargument name="certOu" type="string" required="yes">
        <cfargument name="certOrg" type="string" required="yes">
        <cfargument name="certState" type="string" required="yes">
        <cfargument name="certCountry" type="string" required="yes">
        <cfargument name="debug" type="boolean" default="false">
        
        <!--- To create a new cert, we will: generate the key, export the key, and import the created file into the keystore.  --->
        <cfinvoke component="#THIS#" method="generateKey" returnvariable="genKey">
                <cfinvokeargument name="keyStore" value="#keyStore#">
                <cfinvokeargument name="keyStorePassword" value="#keyStorePassword#">
                <cfinvokeargument name="keyPassword" value="#keyPassword#">
                <cfinvokeargument name="certAlias" value="#certAlias#">
                <cfinvokeargument name="certName" value="#certName#">
                <cfinvokeargument name="certOu" value="#certOu#">
                <cfinvokeargument name="certOrg" value="#certOrg#">
                <cfinvokeargument name="certState" value="#certState#">
                <cfinvokeargument name="certCountry" value="#certCountry#">
                <cfinvokeargument name="debug" value="#debug#">
        </cfinvoke>
        <!--- <cfdump var="#genkey#"> --->
        
        <!--- Export the created key --->
        <cfinvoke component="#THIS#" method="exportKey" returnvariable="export">
                <cfinvokeargument name="keyStore" value="#keyStore#">
                <cfinvokeargument name="keyStorePassword" value="#keyStorePassword#">
                <cfinvokeargument name="certAlias" value="#certAlias#">
                <cfinvokeargument name="certFile" value="#certFile#">
                <cfinvokeargument name="debug" value="#debug#">
        </cfinvoke>
        <!--- <cfdump var="#export#"> --->
        
        <!--- Import the file into the keystore. --->
        <cfinvoke component="#THIS#" method="importCert" returnvariable="import">
            <!--- Note: ommitting this argument works, using it creates an error for some reason.  --->
            <!--- <cfinvokeargument name="keyStore" value="#keyStore#"> --->
            <cfinvokeargument name="keyStorePassword" value="#keyStorePassword#">
            <cfinvokeargument name="certAlias" value="#certAlias#">
            <cfinvokeargument name="certFile" value="#certFile#">
            <cfinvokeargument name="debug" value="#debug#">
        </cfinvoke>
        <!--- <cfdump var="#import#"> ---> 
    </cffunction>
    
    <!--- Return value needs to be set to something when debugging --->
    <cfparam name="execution" default="" type="any">
    
    <cffunction access="public" name="generateKey" output="yes" returntype="string">
		<cfargument name="keyStore" type="string" required="yes" hint="The location and name of the keystore, ie: C:\ColdFusion11\jre\lib\security\cacerts">
        <cfargument name="keyStorePassword" type="string" required="yes" hint="The keystore password. If you have not set it, it defaults to changeit">
        <cfargument name="keyPassword" type="string" required="yes">
        <cfargument name="certAlias" type="string" required="yes">
        <cfargument name="certName" type="string" required="yes">
        <cfargument name="certOu" type="string" required="yes">
        <cfargument name="certOrg" type="string" required="yes">
        <cfargument name="certState" type="string" required="yes">
        <cfargument name="certCountry" type="string" required="yes">
        <cfargument name="debug" type="boolean" default="false">

		<cfif debug>
        	<cfoutput>keytool -genkeypair -dname "cn=#certName#,ou=#certOu#,o=#certOrg#,c=#certCountry#" -alias #certAlias# -keypass #keyPassword# -keyalg RSA -validity 360 -keystore #keyStore# -storepass #keyStorePassword# -noprompt<br/></cfoutput>
        <cfelse>
            <cfexecute timeout="15" variable="execution" name="#pathToKeyTool#\keytool" 
    arguments=' -genkeypair -dname "cn=#certName#,ou=#certOu#,o=#certOrg#,c=#certCountry#" -alias #certAlias# -keypass #keyPassword# -keyalg RSA -validity 360 -keystore #keyStore# -storepass #keyStorePassword# -noprompt' />
		</cfif>
    
    	<!--- Notes: Both IP and DNS can be specified with the keytool additional argument '-ext SAN=dns:abc.com,ip:1.1.1.1'
		Example: keytool -genkeypair -keystore keystore -dname "CN=test, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown" -keypass keypwd -storepass storepass -keyalg RSA -alias unknown -ext SAN=dns:test.abc.com,ip:1.1.1.1 --->


		<cfreturn execution>
	</cffunction>
    
    <cffunction name="exportKey" access="public" output="yes" returntype="string">
		<cfargument name="keyStore" type="string" required="yes" hint="The location and name of the keystore, ie: C:\ColdFusion11\jre\lib\security\cacerts">
        <cfargument name="keyStorePassword" type="string" required="yes" hint="The keystore password. If you have not set it, it defaults to changeit">
        <cfargument name="certAlias" type="string" required="yes">
        <cfargument name="debug" type="boolean" default="false">
        
        <cfif debug>
        	<cfoutput>keytool -export -alias #certAlias# -keystore #keyStore# -rfc -file #certFile# -storepass #keyStorePassword# -noprompt<br/></cfoutput>
        <cfelse>
        	<cfexecute timeout="15" variable="execution" name="#pathToKeyTool#\keytool" 
arguments=" -export -alias #certAlias# -keystore #keyStore# -rfc -file #certFile# -storepass #keyStorePassword# -noprompt" />
		</cfif>

		<!--- This should look like: keytool -genkeypair -alias testcert -keyalg RSA -validity 7 -keystore keystore.jks --->
        
		<cfreturn execution>
	</cffunction>
    
    <cffunction name="importCert" access="public" output="yes" returntype="string">
		<cfargument name="keyStore" type="string" default="" hint="The location and name of the keystore, ie: C:\ColdFusion11\jre\lib\security\cacerts. If this is omitted, it defaults to the default keystore.">
        <cfargument name="keyStorePassword" type="string" required="yes" hint="The keystore password. If you have not set it, it defaults to changeit">
        <cfargument name="certFile" type="string" required="yes">
        <cfargument name="certAlias" type="string" required="yes">
        <cfargument name="debug" type="boolean" default="false">
        
        <cfif keyStore neq ''>
        	<cfset argString = " -import -keystore #keyStore# -file #certFile#  -alias #certAlias# -storepass #keyStorePassword# -trustcacerts -noprompt">
        <cfelse>
        	<cfset argString = " -import -file #certFile#  -alias #certAlias# -storepass #keyStorePassword# -trustcacerts -noprompt">
        </cfif>
        
        <cfif debug>
        	<cfoutput>keytool #argString#<br/></cfoutput>
        <cfelse>
        	<cfexecute timeout="15" variable="execution" name="#pathToKeyTool#\keytool" 
arguments=" #argString#" />
		</cfif>

		<cfreturn execution>
	</cffunction>
    
    <!--- Helper functions.  --->
    <cffunction name="listCert" access="public" output="yes" returntype="string">
		<cfargument name="keyStore" type="string" required="yes" hint="The location and name of the keystore, ie: C:\ColdFusion11\jre\lib\security\cacerts">
        <cfargument name="keyStorePassword" type="string" required="yes" hint="The keystore password. If you have not set it, it defaults to changeit">
		
        <cfexecute timeout="15" variable="execution" name="#pathToKeyTool#\keytool" 
arguments=" -list -v -keystore #keyStore# -storepass #keyStorePassword# -noprompt" />

		<cfreturn execution>
	</cffunction>
	
    
    <cffunction name="deleteCert" access="public" output="yes" returntype="string">
		<cfargument name="keyStore" type="string" required="yes" hint="The location and name of the keystore, ie: C:\ColdFusion11\jre\lib\security\cacerts">
        <cfargument name="keyStorePassword" type="string" required="yes" hint="The keystore password. If you have not set it, it defaults to changeit">
        <cfargument name="certFile" type="string" required="yes">
        <cfargument name="certAlias" type="string" required="yes">
		
        <cfexecute timeout="15" variable="execution" name="#pathToKeyTool#\keytool" 
arguments=" -delete -keystore #keyStore# -file #certFile# -alias #certAlias# -storepass changeit -noprompt" />

		<cfreturn execution>
	</cffunction>
    
</cfcomponent>
