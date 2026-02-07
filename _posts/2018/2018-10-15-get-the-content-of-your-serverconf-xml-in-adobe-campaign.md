---
id: 1020
title: Get the content of your serverConf.xml in Adobe Campaign
date: 2018-10-15T14:39:53+00:00
layout: post
permalink: /2018/10/get-the-content-of-your-serverconf-xml-in-adobe-campaign/
categories:
  - opensource
  - neolane
  - adobe campaign
---
serverConf.xml holds a lot of information concerning the configuration of your instance. But there's no direct access from the console. You can read and dump its content using Linux commands through Javascript.

<!--more-->

## Get your serverConf.xml

Create a simple workflow with a JS activity and an End:

![todo](/assets/images/2018/08/js-activity.jpg)

Open up the JS activity and use this code:

```js
var result = execCommand('pwd'); // to get current dir
logInfo(result[1]);

result = execCommand('ls ../../conf'); // to display the content of the conf folder
logInfo(result[1]);

result = execCommand('cp ../../conf/serverConf.xml /sftp/your-incoming-ftp-folder/');
logInfo(result[1]);
```

```js
/**
 * @param command The command to execute with its parameters
 * @param bNoThrow true to get the output and the error code even if the command does not return zero (false by default).
 *
 * @return a table whose first element corresponds to the return code of the command (if the return code is different from zero, there is an anomaly) and the second element is a character string containing the standard output produced
 *
 * @note Depending on your installation, some commands can be blacklisted. For example: ln, dd, openssl, curl, wget, python, python3, perl, ruby, sh, bash, dash, zsh, base64, nlserver, node, phantomjs, java, awk, nc, telnet, ssh, scp, ftp
 */
function execCommand (command [, bNoThrow=false ])
```

See more JS commands [in this tutorial]({% post_url 2018/2018-08-02-find-a-file-on-the-server-of-adobe-campaign %})

## Sample of serverConf.xml

/usr/local/neolane/nl6/conf/ng/serverConf.xml.sample
```xml
<?xml version='1.0'?>
<serverConf>
  <shared>
<!-- Identification
         checkIPConsistent :  Enable IP address checking Default: false
         defaultMode :  Default identification mode Default: 'nl'
         longSessionTimeOutSec :  Timeout of long sessions in seconds Default: 1296000
         securityTimeOutSec :  Security token timeout in seconds Default: 86400
         sessionCacheSec :  Cache of session information in seconds Default: 600
         sessionTimeOutSec :  Session timeout in seconds Default: 86400 -->
    <authentication checkIPConsistent="false" defaultMode="nl" longSessionTimeOutSec="1296000"
                    securityTimeOutSec="86400" sessionCacheSec="600" sessionTimeOutSec="86400">

    <!-- XTK authentication mode
         internalPassword :  Password of internal account
         internalSecurityZone :  Authorized zone for the internal account Default: 'lan' -->
      <xtk internalPassword="" internalSecurityZone="lan"/>

    </authentication>

    <!-- Definitions of server data sources
         exportDirectory :  Path of destination directory for the exported data. Default: '$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/export/'
         formCacheTimeToLive :  Timeout in seconds after which a cache entry is invalidated. O means that cache entries are only refreshed at publication time. Default: 600
         hosts :  List of DNS masks that this instance serves (comma separated, can use * and ? patterns) Default: '*'
         interactionCacheTimeToLive :  Timeout in seconds after which a cache entry is invalidated. A negative value means that the cache is always invalidated. '0', empty or invalid values are considered to be 60. Default: 300
         lang :  Instance language
         uploadDirectory :  Path of destination directory for the uploaded data. Default: '$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/upload/'
         uploadWhitelist :  Authorized files to be downloaded separated by ','. The string must be a valid, regular java expression. Default: '.+'
         viewCacheTimeToLive :  Timeout in seconds after which a cache entry is invalidated. A negative value means that the cache is always invalidated. '0', empty or invalid values are considered to be 60. Default: 600
         workingDirectory :  XPath of the working directory. Default: '$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/workspace/' -->
    <dataStore exportDirectory="$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/export/"
               formCacheTimeToLive="600" hosts="*" interactionCacheTimeToLive="300"
               lang="" uploadDirectory="$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/upload/"
               uploadWhitelist=".+" viewCacheTimeToLive="600" workingDirectory="$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/workspace/">

    <!-- URLs matching the regular expression are regenerated based on the URL defined in urlBase
         urlBase :  Base to use when generating external URLs. Ex: https://server.domain.com
         urlRegEx :  Regular expression to match URLs. Ex: http://server\.lan\.net.* -->
      <proxyAdjust urlBase="" urlRegEx=""/>

    <!-- Data source
         -->
      <dataSource name="default">
        <dbcnx NChar="" bulkCopyUtility="" dbSchema="" encrypted="" login="" password=""
               provider="" server="" timezone="" unicodeData="" useTimestampTZ=""/>
        <sqlParams funcPrefix="">
          <postConnectSQL/>
        </sqlParams>
        <pool aliveTestDelaySec="600" freeCnx="0" maxCnx="50" maxIdleDelaySec="1200"/>
      </dataSource>

    <!-- Virtual-directory-to-real-directory mapping.
         name :  Name of the virtual directory
         path :  Full path of the actual directory -->
      <virtualDir name="images" path="$(XTK_INSTALL_DIR)/var/res/img/"/>
      <virtualDir name="formCache" path="$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/formCache/"/>
      <virtualDir name="publicFileRes" path="$(XTK_INSTALL_DIR)/var/res/$(INSTANCE_NAME)"/>

    </dataStore>

    <!-- DNS configuration
         localDomain :  Default domain name. Used by the SMTP HELO command.
         nameServers :  Comma separated list of domain name servers (DNS).
         retry :  Number of retries for a DNS query Default: 4
         timeout :  Timeout in milliseconds for a DNS query Default: 5000 -->
    <dnsConfig localDomain="" nameServers="" retry="4" timeout="5000"/>

    <!-- Command execution
         blacklistFile :  Path to the file containing the commands to blacklist
         user :  Execute commands as a different user -->
    <exec blacklistFile="" user=""/>

    <!-- Configuration of the service for converting web pages into PDF documents
         command :  Command line for running the conversion (in 'other' mode) example for phantomjs phantomjs - -ignore-ssl-errors=true '$(XTK_INSTALL_DIR)/bin/htmlToPdf.js' '-out:{outPdf}' '-post:{postFile}' '-url:{originUrl}' -sessiontoken:{sessiontoken} -format:{format} -orientation:{orientation} -marginTop:{marginTop} -marginLeft:{marginLeft} -marginRight:{marginRight} -marginBottom:{marginBottom}
         maxProcessusCount :  Max. number of conversion processes allowed at a time on one machine. Default: 5
         mode :  Tool to use for the conversion (phantomjs|wkhtmltopdf|other|disabled) Default: 'phantomjs'
         timeout :  Maximum conversion time in seconds. Beyond this threshold, the conversion process is stopped and an error is raised. Default: 120
         verbose :  Start in verbose mode to diagnose possible errors. Default: false
         waitTime :  Delay in seconds, when all processes are used at the same time and when waiting for a process to free up. If this delay is exceeded, conversion is stopped and an error is raised. Default: 15 -->
    <htmlToPdf command="" maxProcessusCount="5" mode="phantomjs" timeout="120" verbose="false"
               waitTime="15"/>

    <!-- Configuring the JavaScript interpreter
         maxMB :  Maximum size in megabytes before running the garbage collector Default: 64
         stackSizeKB :  Size of each stack chunk in kilo octets Default: 8 -->
    <javaScript maxMB="64" stackSizeKB="8"/>

    <!-- Configuration of the SMTP server
         mxAddress :  IP address of SMTP server for the transfer of emails.
         mxPort :  TCP port of SMTP server used for the Email transfer. Default: 25 -->
    <mailExchanger mxAddress="" mxPort="25"/>

    <!-- Namespaces configuration
         defaultNameSpace :  Default namespace used when creating a new entity Default: 'cus' -->
    <module defaultNameSpace="cus"/>

    <!-- Monitoring service configuration
         maxPreparationJobsSec :  Duration in seconds after which a delivery action should no longer be in preparation Default: 3600
         unixScript :  Unix script ran by the monitoring service
         winScript :  Windows script to be executed by the monitoring service -->
    <monitoring maxPreparationJobsSec="3600" unixScript="" winScript=""/>

    <!-- Configuration of the document conversion server
         maxConversions :  Maximum number of conversions which an OpenOffice server is allowed to perform. Beyond this number, the server is restarted. Default: 1000
         maxServerIdleSec :  Maximum idle time of OpenOffice server before forced closing. Default: 7200
         portRange :  Interval of ports on which the OpenOffice servers are listening Default: 8101-8110
         url :  URL of the document conversion server Default: 'http://localhost:8080/nl/jsp/ooconv.jsp' -->
    <ooconv maxConversions="1000" maxServerIdleSec="7200" portRange="8101-8110" url="http://localhost:8080/nl/jsp/ooconv.jsp"/>

    <!-- Configuration of proxy parameters
         enabled :  Use a proxy server Default: false
         override :  List of addresses for which proxy parameters shall be ignored. Default: 'localhost*'
         useSingleProxy :  Use the same configuration for all types of proxy Default: false -->
    <proxyConfig enabled="false" override="localhost*" useSingleProxy="false">

    <!-- HTTP Proxy
         -->
      <proxyHTTP address="" login="" password="" port=""/>

    <!-- Secure proxy
         -->
      <proxyHTTPS address="" login="" password="" port=""/>

    </proxyConfig>

    <!-- Configuration of the thread pool
         maxThreadCount :  Maximum number of threads in pool. Default: 10 -->
    <threadPool maxThreadCount="10"/>

    <!-- List of URLs that the Javascript code can access.
         action :  Default action if the URL is not in the authorized list. Values: deny (default), warn, ignore
         debugTrace :  Debugging trace of the URL selection mechanism Default: false -->
    <urlPermission action="" debugTrace="false">

    <!-- URL mask
         dnsSuffix :  Domain name, or domain parent, concerned by the URL
         urlRegEx :  Regular expression to refine validating URLs belonging to this domain. -->
      <url dnsSuffix="api.omniture.com" urlRegEx="https://api\.omniture\.com/genesis/i/3\.1.*"/>
      <url dnsSuffix="api.omniture.com" urlRegEx="https://api[1-5]\.omniture\.com/genesis/i/3\.1.*"/>
      <url dnsSuffix="marketing.adobe.com" urlRegEx="https://.*"/>
      <url dnsSuffix="gcm-http.googleapis.com" urlRegEx="https://gcm-http\.googleapis\.com/gcm/send.*"/>
      <url dnsSuffix="graph.facebook.com" urlRegEx="https://.*"/>
      <url dnsSuffix="api.line.me" urlRegEx="https://api\.line\.me/v1.*"/>
      <url dnsSuffix="api.twitter.com" urlRegEx="https://api\.twitter\.com/1\.1.*"/>
      <url dnsSuffix="adobeid-na1.services.adobe.com" urlRegEx="https://.*"/>
      <url dnsSuffix="adobeid-na1-stg1.services.adobe.com" urlRegEx="https://.*"/>
      <url dnsSuffix="deliverability.neolane.net" urlRegEx="https://deliverability\.neolane\.net/jssp/dm/renderingSeed\.jssp"/>
      <url dnsSuffix="deliverability.neolane.net" urlRegEx="https://deliverability\.neolane\.net/nl/jsp/soaprouter\.jsp"/>
      <url dnsSuffix="localhost" urlRegEx="http://localhost:8080/nms/jsp/.*"/>
      <url dnsSuffix="localhost" urlRegEx="http://localhost:8080/nl/jsp/.*"/>
      <url dnsSuffix="localhost" urlRegEx="http://localhost:8080/xtk/jsp/.*"/>

    </urlPermission>

    <!-- Server jobs
         parseLogsPeriod :  Memory status refresh period of server processing (in ms) Default: 500 -->
    <xtkJobs parseLogsPeriod="500"/>


  </shared>
<!-- Executes archiving operations in the background.
       acquireLimit :  Number of EMLs to process at the same time Default: 100
       archivingType :  Archiving strategy
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       compressBatchSize :  Max number of files in a compressed archive Default: 10000
       compressionFormat :  Compression format
       expirationDelay :  Number of days before unprocessed emails are archived Default: 2
       initScript :  ID of JavaScript to execute when starting the process
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       pollDelay :  Delay (in seconds) between each update event Default: 60
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       purgeArchivesDelay :  Number of days before unprocessed emails are deleted Default: 7
       runLevel :  Priority at start Default: 10
       smtpBccAddress :   
       smtpEnableTLS :  Activates the delivery of emails in safe mode (STARTTLS/SMTPS) when supported by the remote server. Default: false
       smtpRelayAddress :  Comma-separated list of DNS names or IP addresses of SMTP relays to use.
       smtpRelayPort :  IP port of SMTP server. Default: 25 -->
  <archiving acquireLimit="100" archivingType="" args="" autoStart="false" compressBatchSize="10000"
             compressionFormat="" expirationDelay="2" initScript="" maxProcessMemoryAlertMb="1800"
             maxProcessMemoryWarningMb="1600" pollDelay="60" processRestartTime="06:00:00"
             purgeArchivesDelay="7" runLevel="10" smtpBccAddress="" smtpEnableTLS="false"
             smtpRelayAddress="" smtpRelayPort="25"/>

    <!-- Configuration of the inbound Email management module
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       checkInstanceName :  If true, the name of the Adobe Campaign instance contained in the Message-ID headers must be the same as the current instance. Default: true
       defaultForwardAddress :  Default email transfer address not processed by a rule.
       errorForwardAddress :  Default address used to transfer invalid Emails (bad MIME encoding).
       ignoreSize :  Is used to ignore the size of a message returned by POP3 servers. In this case, the module expects a '.' at the end of the messages. Default: false
       inMailPeriodSec :  Message queue polling frequency. Default: 5
       initScript :  ID of JavaScript to execute when starting the process
       maxBroadLog :  Defines the maximum number of log messages to keep in memory before updating the database. Default: 20
       maxMsgPerSession :  Maximum number of messages to read during POP3 session. Default: 200
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       maxSessionTTLSec :  Maximum duration of message processing session Default: 100
       popMailPeriodSec :  POP3 polling period. Default: 300
       popQueueSize :  Queue size of read messages Default: 100
       popTimeoutSec :  Communication timeout with POP3 server. Default: 300
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       reloadPeriodSec :  Database reload frequency of accounts to be polled. Default: 600
       runLevel :  Priority at start Default: 10 -->
  <inMail args="" autoStart="false" checkInstanceName="true" defaultForwardAddress=""
          errorForwardAddress="" ignoreSize="false" inMailPeriodSec="5" initScript=""
          maxBroadLog="20" maxMsgPerSession="200" maxProcessMemoryAlertMb="1800"
          maxProcessMemoryWarningMb="1600" maxSessionTTLSec="100" popMailPeriodSec="300"
          popQueueSize="100" popTimeoutSec="300" processRestartTime="06:00:00" reloadPeriodSec="600"
          runLevel="10">

    <!-- Dump of processed messages
         dump :  Save all inbound messages in text format. Default: false
         msgPath :  Message dump path. Default: '/tmp/inMail' -->
    <msgDump dump="false" msgPath="/tmp/inMail"/>

  </inMail>

    <!-- Configuring the write daemon for inbound Interaction events
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       callDataSize :  Max. number of characters stored in the shared memory for call data Default: 0
       initScript :  ID of JavaScript to execute when starting the process
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       maxSharedEntries :  Max. number of events stored in the shared memory. Default: 25000
       nextOffersSize :  Maximum number of eligible offers sorted right after propositions, to be stored for statistics Default: 0
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       runLevel :  Priority at start Default: 10
       statsPeriod :  Aggregation duration in seconds for the response time statistics. 0 means statistic storage was deactivated. Default: 600
       targetKeySize :  Max. number of characters stored in the shared memory for identifying individuals Default: 16 -->
  <interactiond args="" autoStart="false" callDataSize="0" initScript="" maxProcessMemoryAlertMb="1800"
                maxProcessMemoryWarningMb="1600" maxSharedEntries="25000" nextOffersSize="0"
                processRestartTime="06:00:00" runLevel="10" statsPeriod="600" targetKeySize="16"/>

    <!-- Configuration of delivery agents
       args :  Start-up parameters Default: '-tracefilter:nlmta'
       autoStart :  Automatic start Default: false
       dataLogPath :  If not empty, the path where all source files of sent emails will be saved.
       debugPath :  If not empty, copy MIME envelopes of sent mail messages in this directory. Used for trouble shooting.
       dnsRequestLogDelayMs :  Time in milliseconds to display the logs
       errorPeriodSec :  Time between generation of statistics and storage in the database. Default: 300
       initScript :  ID of JavaScript to execute when starting the process
       logEmailErrors :  Generate error statistics and store them in the database. Default: true
       logLevel :  Display level of log messages. Default: 2
       maxMemoryMb :  Maximum memory size (in MB) that an mta process can use. Above this limit, the process is re-started so that the memory it uses is released to the system. Default: 1024
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       minConnectionsToLog :  Connection threshold to take into account Default: 100
       minErrorsToLog :  Error threshold to take into account Default: 1
       minMessagesToLog :  Message threshold to take into account Default: 1000
       notifRelay :  HostName:Port used to relay notifications
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       purgeDataLogDelay :  Number of days before archived emails in the directory specified in dataLogPath are purged. Default: 15
       retryLostMessages :  Parts of deliveries will be retried if the child process is dead Default: true
       runLevel :  Priority at start Default: 10
       statServerAddress :  Address of the delivery statistics server, given as <dns or ip>[:<port>]. If not defined, the default port is 7777.
       statServerTLSSupport :  Enables the TLS configurable by MX (requires an up-to-date statistics server) Default: true
       statServerVersion :  Communication protocol version (1 for a v5.11 and 6.0.2 server, 2 for a v6.1 server). If undefined, the latest version is used.
       verifyMode :  Activates the verify mode (no physical transmission of messages; used for simulation and tests). Default: false
       workingPath :  Location of temporary files used by the MTA to communicate with its child processes. Default: '$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/mta/'
       xMailer :  Value of field 'X-Mailer' in SMTP mail header. Default: 'nlserver, Build $(PRODUCT_VERSION)' -->
  <mta args="-tracefilter:nlmta" autoStart="false" dataLogPath="" debugPath="" dnsRequestLogDelayMs=""
       errorPeriodSec="300" initScript="" logEmailErrors="true" logLevel="2" maxMemoryMb="1024"
       maxProcessMemoryAlertMb="1800" maxProcessMemoryWarningMb="1600" minConnectionsToLog="100"
       minErrorsToLog="1" minMessagesToLog="1000" notifRelay="" processRestartTime="06:00:00"
       purgeDataLogDelay="15" retryLostMessages="true" runLevel="10" statServerAddress=""
       statServerTLSSupport="true" statServerVersion="" verifyMode="false" workingPath="$(XTK_INSTALL_DIR)/var/$(INSTANCE_NAME)/mta/"
       xMailer="nlserver, Build $(PRODUCT_VERSION)">

    <!-- Local file cache configuration
         maxPeriodSec :  Period, expressed in seconds, after which the file is automatically deleted from the cache to reclaim storage. Default: 244800
         maxSizeOnDiskMb :  Maximum cache size (Mb). Default: 1024
         purgePeriodSec :  Period in seconds between executions of the cache purge mechanism. Default: 3600 -->
    <cache maxPeriodSec="244800" maxSizeOnDiskMb="1024" purgePeriodSec="3600"/>

    <!-- Configuration of the mail server for the message delivery.
         address :  Comma-separated list of DNS names or IP addresses of SMTP relays to use.
         port :  IP port of SMTP server. Default: 25 -->
    <relay address="" port="25"/>

    <!-- Configuration of principal server
         dataBasePoolPeriodSec :  Database polling frequency of the jobs to be delivered. Default: 30
         dataBaseRetryDelaySec :  Waiting period after a database connection failure. Default: 60
         domainKeysReloadPeriodSec :  Validity period for the cache of private keys (DomainKeys). Default: 600
         maxSpareServers :  Maximum number of child servers. Default: 2
         minSpareServers :  Minimum number of child servers. Default: 0
         startSpareServers :  Number of child server at start-up. Default: 0 -->
    <master dataBasePoolPeriodSec="30" dataBaseRetryDelaySec="60" domainKeysReloadPeriodSec="600"
            maxSpareServers="2" minSpareServers="0" startSpareServers="0"/>

    <!-- Configuration of child servers
         extraArgs :  Optional command line arguments
         idleChildTimeoutSec :  Timeout until idle child servers are stopped. Default: 60
         maxAgeSec :  Maximum message retention time. Default: 600
         maxMsgPerChild :  Maximum count of messages per child server. Default: 5000000
         maxWaitingMessages :  Maximum number of messages waiting in memory to be delivered. Default: 2000
         maxWorkingSetMb :  Maximum memory size (in MB) that a child process can use. Above this limit, the process is stopped so that the memory it uses is released to the system. Default: 128
         soapConnectorTimeoutSec :  Timeout (in seconds) after which a SOAP connection for a delivery connector is abandoned. Default: 600
         startWithFirstMX :  Always start with the highest priority MX Default: false
         timeToLive :  Maximum number of consecutive attempts when resumed. Default: 48 -->
    <child extraArgs="" idleChildTimeoutSec="60" maxAgeSec="600" maxMsgPerChild="5000000"
           maxWaitingMessages="2000" maxWorkingSetMb="128" soapConnectorTimeoutSec="600"
           startWithFirstMX="false" timeToLive="48">

    <!-- Configuration of SMTP sessions
           enableTLS :  Activates the delivery of emails in safe mode (STARTTLS/SMTPS) when supported by the remote server. Default: false
           idleSessionTimeoutSec :  Idle session timeout. Default: 5
           initialDelaySec :  Initial delay before retrying connection. This delay is doubled each time connection fails. Default: 4
           maxSessionsPerChild :  Maximum number of SMTP sessions by child server. Default: 1000 -->
      <smtp enableTLS="false" idleSessionTimeoutSec="5" initialDelaySec="4" maxSessionsPerChild="1000">

    <!-- Management of affinities with IP addresses for optimized outgoing SMTP traffic.
             localDomain :  Local domain name linked to the IP address. Used when issuing an SMTP HELO command.
             name :  Names linked to the affinity by users. Names are separated using semicolons;  -->
            <!-- IP :  Outbound IP.
               address :  Associated physical address. Eg: '192.168.0.1'  
               excludeDomains :  Comma separated list of domain masks to exclude
               heloHost :  Computer name linked to the IP address. Used when issuing an SMTP HELO command.
               includeDomains :  Comma separated list of domain masks to include
               publicId :  Associated public address ID. Used as a key for the statistics server. Must be numeric.
               weight :  Specifies the frequency of use for this IP, relative to other IPs (bigger weights lead to higher frequencies). -->

      </smtp>

    </child>

  </mta>

    <!--  
       useHTTPProxy :  Use HTTP proxy defined in shared/proxyHTTP Default: false -->
  <nmac useHTTPProxy="false">

    <!-- Configuration to use a relay for the message delivery (connecteur ios http2).
         address :  DNS address or name of the relay to use.
         port :  Relay port. Default: 443
         trustedCertsChain :  Certificate chain (PEM file). Useful when using a mock server -->
    <relay address="" port="443" trustedCertsChain=""/>

  </nmac>

    <!-- Event processing module for the Pipeline Services
       appName :  Name of the application generated in the Developer connection when the public key is saved.
       args :  Start-up parameters
       authGatewayEndpoint :  URL to obtain a gateway token Default: 'https://api.omniture.com'
       authPrivateKey :  Private key to obtain tokens (encrypted in AES with the XtkKey option)
       autoStart :  Automatic start Default: false
       disableAuth :  Connect to Pipeline Services without authentication.
       discoverPipelineEndpoint :  URL to discover the Pipeline Services URL Default: 'https://producer-pipeline-pnw.adobe.net'
       dumpStatePeriodSec :  Frequency that the process's internal information is saved in a file. Inactive if 0. Default: 0
       forcedPipelineEndpoint :  Force the listening URL of the Pipeline Services.
       initScript :  ID of JavaScript to execute when starting the process
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       monitorServerPort :  HTTP server port allowing you to query the status of the process. Inactive if 0. Default: 7781
       pointerFlushMessageCount :  The pointer will be stored in the database every time that this number of messages are processed. Default: 1000
       pointerFlushPeriodSec :  The pointer will be stored in the database at least once during this period (useful in case of low activity). Default: 5
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       processingJSThreads :  Number of threads for event processing with a personalized JavaScript connector. Default: 4
       processingThreads :  Number of threads for event processing. Default: 4
       retryPeriodSec :  Delay between processing if there is a failure Default: 30
       retryValiditySec :  Abandon the event if the processing is still failing after this period. Default: 300
       runLevel :  Priority at start Default: 10 -->
  <pipelined appName="" args="" authGatewayEndpoint="https://api.omniture.com" authPrivateKey=""
             autoStart="false" disableAuth="" discoverPipelineEndpoint="https://producer-pipeline-pnw.adobe.net"
             dumpStatePeriodSec="0" forcedPipelineEndpoint="" initScript="" maxProcessMemoryAlertMb="1800"
             maxProcessMemoryWarningMb="1600" monitorServerPort="7781" pointerFlushMessageCount="1000"
             pointerFlushPeriodSec="5" processRestartTime="06:00:00" processingJSThreads="4"
             processingThreads="4" retryPeriodSec="30" retryValiditySec="300" runLevel="10"/>

    <!-- Application option: Predictive Marketing.
       kxenConfigFile :  Default path and name of the KXEN configuration file, used when no path is specified in the predictive model.
       url :  Root URL of the server to invoke the datamining connectors. Default: 'http://localhost:8080' -->
  <predictive kxenConfigFile="" url="http://localhost:8080"/>

    <!-- Database repair module.
       repairActionDelayMin :  Delay (in minutes) after which delivery actions can be processed by the repair module. Default: 60 -->
  <repair repairActionDelayMin="60"/>

    <!-- Security zone
       allowDebug :  Authorize debug mode for Web applications Default: false
       allowEmptyPassword :  Authorize the user to use the application without a password Default: false
       allowHTTP :  Authorize the use of HTTP for operator logon Default: false
       allowSQLInjection :  Authorize the use of SQLDATA in expressions Default: false
       allowUserPassword :  Authorize user/password session tokens Default: false
       label :  Label Default: NewLabel()
       name :  Internal name Default: NewName()
       sessionTokenOnly :  Do not use the security token Default: false
       showErrors :  Display error details Default: false -->
      <!-- subNetwork :  Sub-network
         label :  Label Default: NewLabel()
         mask :  Mask or address
         name :  Internal name Default: NewName()
         proxy :  Mask or address of (reverse) proxy used by this sub-network to access the instance. In this case, the 'X-Forwarded-For' header will be tested instead of this proxy. Default: 127.0.0.1 -->
      <!-- securityZone :   
         -->
  <securityZone allowDebug="false" allowHTTP="false" allowSQLInjection="false" label="Public Network"
                name="public">
    <subNetwork label="All addresses" mask="*" name="all" proxy="127.0.0.1, ::1"/>

    <securityZone allowDebug="true" allowHTTP="false" allowSQLInjection="false" label="Private Network (VPN)"
                  name="vpn" showErrors="true">

      <securityZone allowDebug="true" allowEmptyPassword="false" allowHTTP="true"
                    allowSQLInjection="false" allowUserPassword="false" label="Private Network (LAN)"
                    name="lan" sessionTokenOnly="true" showErrors="true">
        <subNetwork label="Lan 1" mask="192.168.0.0/16" name="lan1" proxy="127.0.0.1, ::1"/>
        <subNetwork label="Lan 2" mask="172.16.0.0/12" name="lan2" proxy="127.0.0.1, ::1"/>
        <subNetwork label="Lan 3" mask="10.0.0.0/8" name="lan3" proxy="127.0.0.1, ::1"/>
        <subNetwork label="Localhost" mask="127.0.0.0/8" name="localhost" proxy="127.0.0.1, ::1"/>
        <subNetwork label="Lan (IPv6)" mask="fc00::/7" name="lan6" proxy="127.0.0.1, ::1"/>
        <subNetwork label="Lan (IPv6)" mask="fe80::/10" name="lan6b" proxy="127.0.0.1, ::1"/>
        <subNetwork label="Localhost (IPv6)" mask="::1/128" name="localhost6" proxy="127.0.0.1, ::1"/>
      </securityZone>

    </securityZone>
  </securityZone>


    <!-- Configuration of the inbound SMS management module
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       dataRetentionDays :  Maximum number of days files working files kept by the SMPP connector. Default: 60
       dataSizeMo :  Maximum size in MB of the SMPP working files. Default: 512
       initScript :  ID of JavaScript to execute when starting the process
       keepAlivePeriod :  Max. period in seconds between two frames for notifying that the receiving session is still enabled Default: 25
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       pollPeriod :  SMS account poll period. Default: 300
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       reloadPeriod :  Database reload frequency of accounts to be polled. Default: 600
       runLevel :  Priority at start Default: 10
       srReadDelay :  Only SRs with a recovery date earlier than the current time minus the duration in seconds given by srReadDelay. Default: 600
       timeout :  Communication timeout with SMS gateway. Default: 300 -->
  <sms args="" autoStart="false" dataRetentionDays="60" dataSizeMo="512" initScript=""
       keepAlivePeriod="25" maxProcessMemoryAlertMb="1800" maxProcessMemoryWarningMb="1600"
       pollPeriod="300" processRestartTime="06:00:00" reloadPeriod="600" runLevel="10"
       srReadDelay="600" timeout="300">

    <!--  
         netsizeConnectionTimeout :  Timeout in seconds when establishing a connection with Netsize Default: 30 -->
    <netsize netsizeConnectionTimeout="30"/>

  </sms>

    <!-- MTA statistics module
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       initScript :  ID of JavaScript to execute when starting the process
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       port :  Server listening port
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       runLevel :  Priority at start Default: 10 -->
  <stat args="" autoStart="false" initScript="" maxProcessMemoryAlertMb="1800" maxProcessMemoryWarningMb="1600"
        port="" processRestartTime="06:00:00" runLevel="10"/>

    <!-- Log management module.
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       initScript :  ID of JavaScript to execute when starting the process
       maxFileSizeMb :  Maximum size in Mb for a log file Default: 10
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       runLevel :  Priority at start Default: 10 -->
  <syslogd args="" autoStart="false" initScript="" maxFileSizeMb="10" maxProcessMemoryAlertMb="1800"
           maxProcessMemoryWarningMb="1600" processRestartTime="06:00:00" runLevel="10"/>

    <!-- Configuration of the tracking server
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       consolidationPeriodSec :  Consolidation period Default: 300
       dedupOpenPeriodMin :  Remove duplicate open tracking logs to limit the effects of mail previews in mail readers like Outlook. Default: 1
       errorIgnorePercent :  Do not update tracking indicators as long as the ratio of journals not already taken into account does not reach this value. Default: 1
       errorIgnorePeriod :  Maximum duration before error indicators are recomputed. Default: 86400
       indicatorsDuration :  Duration after the validity date of a delivery after which consolidated indicators are no longer computed Default: 2592000
       initScript :  ID of JavaScript to execute when starting the process
       logCountPerRequest :  Number of logs requested by call to the remote tracking server Default: 1000
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       runLevel :  Priority at start Default: 10
       trackingIgnorePercent :  Do not update tracking indicators as long as the ratio of journals not already taken into account does not reach this value. Default: 1
       trackingIgnorePeriod :  Maximum duration before tracking indicators are recomputed. Default: 86400
       userAgentCacheSize :  Size of browser identifier cache. Default: 500 -->
  <tracking args="" autoStart="false" consolidationPeriodSec="300" dedupOpenPeriodMin="1"
            errorIgnorePercent="1" errorIgnorePeriod="86400" indicatorsDuration="2592000"
            initScript="" logCountPerRequest="1000" maxProcessMemoryAlertMb="1800"
            maxProcessMemoryWarningMb="1600" processRestartTime="06:00:00" runLevel="10"
            trackingIgnorePercent="1" trackingIgnorePeriod="86400" userAgentCacheSize="500"/>

    <!-- Configuration of the tracking log writing daemon
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       initScript :  ID of JavaScript to execute when starting the process
       maxCreateFileRetry :  Maximum number of files that can be created in case of writing failure in log files. Default: 5
       maxLogsSizeOnDiskMb :  Maximum space used by logs on disk (in MB). May not be less than 100 MB. Default: 500
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       maxSharedLogs :  Maximum number of logs stored in shared memory. Cannot be less than 10000. Default: 25000
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       purgeLogsPeriod :  Number of logs inserted before starting the purge of log files. May not be lower than 50000. Default: 50000
       runLevel :  Priority at start Default: 10
       webTrackingParamSize :  Maximum number of characters saved in shared memory for extra web tracking parameters Default: 64 -->
  <trackinglogd args="" autoStart="false" initScript="" maxCreateFileRetry="5" maxLogsSizeOnDiskMb="500"
                maxProcessMemoryAlertMb="1800" maxProcessMemoryWarningMb="1600" maxSharedLogs="25000"
                processRestartTime="06:00:00" purgeLogsPeriod="50000" runLevel="10"
                webTrackingParamSize="64"/>

    <!-- Configuration of the Web Module
       JVMOptions :  Options of the JVM passed as a string. Default:  
       MaxThreads :  Maximum number of threads. Default: 75
       MinSpareThreads :  Minimum number of threads. Default: 5
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       controlPort :  Tomcat listening control port Default: 8005
       httpPort :  Tomcat HTTP listening port Default: 8080
       initScript :  ID of JavaScript to execute when starting the process
       maxDeliveryQueueSize :  Maximum number of SubmitDelivery SOAP calls that can be queued. Default: 50
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       notifRelay :  HostName:Port enabling relay of notifications
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       runLevel :  Priority at start Default: 10
       startSoapRouterInModule :  Start the SOAP router in module mode. Default: false -->
  <web JVMOptions="" MaxThreads="75" MinSpareThreads="5" args="" autoStart="false"
       controlPort="8005" httpPort="8080" initScript="" maxDeliveryQueueSize="50"
       maxProcessMemoryAlertMb="1800" maxProcessMemoryWarningMb="1600" notifRelay=""
       processRestartTime="06:00:00" runLevel="10" startSoapRouterInModule="false">

    <!-- Parameters used by the JSPs
         debug :  Execution of JSP in debug mode or not
         downloadPath :  Download path of installation programs for the client consoles. Default: '$(XTK_INSTALL_DIR)/datakit/nl/fra/jsp'
         foFileName :  Path of .fo file.
         soapRouter :  URL of SOAP router (http://myserver/xxx, http://jni or mailto:xxx) Default: 'http://jni' -->
    <jsp debug="" downloadPath="$(XTK_INSTALL_DIR)/datakit/nl/fra/jsp" foFileName=""
         soapRouter="http://jni">

    <!-- Class Path to use when starting JVM
           -->
      <classpath>$(XTK_INSTALL_DIR)/tomcat-7/bin/bootstrap.jar
          $(XTK_INSTALL_DIR)/tomcat-7/bin/tomcat-juli.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/tomcat-coyote.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/tomcat-util.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/tomcat-api.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/servlet-api.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/jsp-api.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/el-api.jar
          $(XTK_INSTALL_DIR)/java/lib/log4j-1.2.11.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/annotations-api.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/catalina.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/websocket-api.jar
          $(XTK_INSTALL_DIR)/tomcat-7/lib/tomcat7-websocket.jar
          $(XTK_INSTALL_DIR)/java/lib/pdfbox-2.0.4.jar
          $(XTK_INSTALL_DIR)/java/lib/FontBox-0.1.0.jar
          $(XTK_INSTALL_DIR)/java/lib/AGJavaEndpoint.22.jar
          $(XTK_INSTALL_DIR)/java/lib/NSGConstants.jar
          $(XTK_INSTALL_DIR)/java/lib/smpp.jar
          $(XTK_INSTALL_DIR)/java/lib/nlweb.jar
          $(XTK_INSTALL_DIR)/java/lib/weka.jar
          $(XTK_INSTALL_DIR)/java/lib/KxCommonInterf.jar
          $(XTK_INSTALL_DIR)/java/lib/KxJni.jar
          $(XTK_INSTALL_DIR)/java/lib/KxJniInterf.jar
          $(XTK_INSTALL_DIR)/java/lib/KxUtils.jar
          $(XTK_INSTALL_DIR)/java/lib/jcaptcha-all.jar
          $(XTK_INSTALL_DIR)/java/lib/apns-1.0.0.Beta6-jar-with-dependencies.jar
          $(XTK_INSTALL_DIR)/java/lib/commons-collections-3.2.2.jar
          $(XTK_INSTALL_DIR)/java/lib/jcommon-1.0.16.jar
          $(XTK_INSTALL_DIR)/java/lib/jfreechart-1.0.13.jar
          $(XTK_INSTALL_DIR)/java/lib/barcode4j-light.jar
          $(XTK_INSTALL_DIR)/java/lib/zxing.jar
          $(XTK_INSTALL_DIR)/java/lib/raztec.jar
          $(XTK_INSTALL_DIR)/java/lib/gson-2.7.jar
          $(XTK_INSTALL_DIR)/java/lib/alpn-api-1.1.3.v20160715.jar
          $(XTK_INSTALL_DIR)/java/lib/netty-all-4.1.6.Final.jar
          $(XTK_INSTALL_DIR)/java/lib/netty-tcnative-boringssl-static-1.1.33.Fork22.jar
          $(XTK_INSTALL_DIR)/java/lib/pushy-0.8.1.jar
          $(XTK_INSTALL_DIR)/java/lib/slf4j-api-1.7.21.jar
          $(XTK_INSTALL_DIR)/java/lib/slf4j-simple-1.7.21.jar
          $(OOO_URE_INSTALL_DIR)/java/juh.jar
          $(OOO_URE_INSTALL_DIR)/java/ridl.jar
          $(OOO_URE_INSTALL_DIR)/java/jurt.jar
          $(OOO_BASIS_INSTALL_DIR)/program/classes/unoil.jar
          $(OOO_INSTALL_DIR)/classes/juh.jar
          $(OOO_INSTALL_DIR)/classes/ridl.jar
          $(OOO_INSTALL_DIR)/classes/unoil.jar
          $(OOO_INSTALL_DIR)/classes/jurt.jar</classpath>

    </jsp>

    <!-- Parameters used by the JSSPs
         collectsGarbageAfterRequest :  Enables the garbage collector of the JavaScript context after each query. Default: true
         timeToLive :  Maximum number of pages served by a JavaScript context. Default: 1000 -->
    <jssp collectsGarbageAfterRequest="true" timeToLive="1000"/>

    <!-- Relay for HTTP requests between two zones
         debugRelay :  Start the HTTP relay module within the Web server in debug mode Default: false
         forbiddenCharsInAuthority :  List of forbidden characters in the 'authority' section of a URI Default: '.?#@/:'
         forbiddenCharsInPath :  List of forbidden characters in the 'path' section of a URI Default: '?#/'
         modDir :  List of files to be used during a query on a folder Default: 'index.html'
         startRelay :  Start the HTTP relay module Default: false
         startRelayInModule :  Start the HTTP relay module within the Web server. Default: true
         timeout :  Wait time before deleting banned url Default: '60' -->
    <relay debugRelay="false" forbiddenCharsInAuthority=".?#@/:" forbiddenCharsInPath="?#/"
           modDir="index.html" startRelay="false" startRelayInModule="true" timeout="60">

    <!-- List of URLs to relay (insert order defines priority).
           IPMask :  Comma separated list of source IP addresses allowed to used the relay for this mask
           deny :  Deny access to these URLs (return an HTTP 403 error)
           hostMask :  Comma separated list of DNS alias masks to relay (ex: '*.adobe.com').
           httpAllowed :  Http access authorized no matter what the security zone (like webApps)
           relayHost :  use the HTTP 'Host' header of the original request when relaying.
           relayPath :  Append the complete path of the URLs to relay to the URL of the target page.
           status :  Url status for synchronization (blacklist, spare, normal)
           targetUrl :  URL of the target page.
           timeout :  Maximum execution time (in seconds) of the request being relayed
           urlPath :  Mask of URLs to relay (ex: '/nl*', '*.jsp'). -->
      <url IPMask="" deny="" hostMask="" relayHost="true" relayPath="true" status="normal"
           targetUrl="http://localhost:7781" timeout="" urlPath="/pipelined/*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/view/*"/>
      <url IPMask="" deny="true" hostMask="" httpAllowed="false" relayHost="true"
           relayPath="true" status="normal" targetUrl="http://localhost:8080" timeout=""
           urlPath="*ooconv.jsp*"/>
      <url IPMask="" deny="true" hostMask="" httpAllowed="false" relayHost="true"
           relayPath="true" status="normal" targetUrl="http://localhost:8080" timeout=""
           urlPath="/res/*.jsp*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="*/sc.jssp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="*/interactionProposal.jssp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="*/zoneJson.jssp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/nms/jsp/barcode.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/nms/jsp/captcha.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/nms/jsp/webForm.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/xtk/jsp/zoneinfo.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="*/facebookCallback.jssp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/nl/jsp/m.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/nl/jsp/s.jsp"/>

      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="blacklist" targetUrl="http://localhost:8080" timeout="" urlPath="/nms/jsp/*.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="blacklist" targetUrl="http://localhost:8080" timeout="" urlPath="/xtk/jsp/*.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="blacklist" targetUrl="http://localhost:8080" timeout="" urlPath="/nl/jsp/*.jsp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="blacklist" targetUrl="http://localhost:8080" timeout="" urlPath="*.jssp"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="blacklist" targetUrl="http://localhost:8080" timeout="" urlPath="/webApp/*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="blacklist" targetUrl="http://localhost:8080" timeout="" urlPath="/report/*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="blacklist" targetUrl="http://localhost:8080" timeout="" urlPath="/jssp/*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="false" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/strings/*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/interaction/*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/barcode/*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="true" relayPath="true"
           status="normal" targetUrl="http://localhost:8080" timeout="" urlPath="/lineImage/*"/>

      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="false" relayPath="false"
           status="spare" targetUrl="" timeout="" urlPath="/favicon.*"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="false" relayPath="false"
           status="spare" targetUrl="" timeout="" urlPath="/*.html"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="false" relayPath="false"
           status="spare" targetUrl="" timeout="" urlPath="/*.png"/>
      <url IPMask="" deny="" hostMask="" httpAllowed="true" relayHost="false" relayPath="false"
           status="spare" targetUrl="" timeout="" urlPath="/*.jpg"/>

    <!-- List of HTTP headers to add to replies forwarded to the relay.
           name :  Header name Default:  
           value :  Header value Default:  -->
      <responseHeader name="X-XSS-Protection" value="1; mode=block"/>

    </relay>

    <!-- Configuration of the redirection module
         IMSOrgId :  Unique organization identifier within the Adobe Marketing Cloud, used in particular for the VisitorID service and the IMS SSO.
         P3PCompactPolicy :  Value describing the policy used for permanent cookies (compliant with the P3P Compact Policy format). Default: 'CAO DSP COR CURa DEVa TAIa OUR BUS IND UNI COM NAV'
         databaseId :  Database identifier associated with the tracking instance
         defLogCount :  Number of logs returned by default upon a call of method GetTrackingLogs Default: 30
         expirationURL :  URL of Web page used by default by the redirection server when redirection for a delivery action has expired.
         maxJobsInCache :  Maximum number of delivery actions in cache. May not be lower than 50. Default: 100
         startRedirection :  Start the redirection service. Default: true
         startRedirectionInModule :  Start the redirection service in module mode. Default: true
         trackWebVisitors :  Creation of logs for the pages visited by unknown users. Default: false
         trackingPassword :  Password used by the redirection server -->
    <redirection IMSOrgId="" P3PCompactPolicy="CAO DSP COR CURa DEVa TAIa OUR BUS IND UNI COM NAV"
                 databaseId="" defLogCount="30" expirationURL="" maxJobsInCache="100"
                 startRedirection="true" startRedirectionInModule="true" trackWebVisitors="false"
                 trackingPassword="">

    <!--  
           enabledIf :  The tracking server is taken into account if the expression returns true
           id :  Name Default: 1
           url :  Extra redirection server URL -->
      <spareServer enabledIf="" id="1" url=""/>

    </redirection>

    <!-- Email anti-spam scoring evaluation parameters
         command :  Command to execute to evaluate the anti-spam score of an email (e.g. 'perl spamcheck.pl') Default: '' -->
    <spamCheck command=""/>

  </web>

    <!-- Workflow process configuration
       affinity :  Affinity Default:  
       args :  Start-up parameters
       autoStart :  Automatic start Default: false
       dataBasePoolPeriodSec :  Period Default: 20
       initScript :  ID of JavaScript to execute when starting the process
       maxProcessMemoryAlertMb :  Alert concerning the amount of RAM consumed (in Mb) by a given process Default: 1800
       maxProcessMemoryWarningMb :  Warning concerning the amount of RAM consumed (in Mb) by a given process Default: 1600
       notifRelay :  HostName:Port enabling relay of notifications
       processRestartTime :  Time of the day when the process is automatically restarted Default: '06:00:00'
       runLevel :  Priority at start Default: 10 -->
  <wfserver affinity="" args="" autoStart="false" dataBasePoolPeriodSec="20" initScript=""
            maxProcessMemoryAlertMb="1800" maxProcessMemoryWarningMb="1600" notifRelay=""
            processRestartTime="06:00:00" runLevel="10"/>

</serverConf>
```
