<?xml version="1.0" encoding="UTF-8"?>
<Configuration xmlns="http://bbn.com/marti/xml/config"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="CoreConfig.xsd">
    <network multicastTTL="5">
        <input _name="stdssl" protocol="tls" port="8089"/>

        <!-- web connectors -->
        <connector port="8443" _name="https"/>
        <connector port="8444" useFederationTruststore="true" _name="fed_https"/>
        <connector port="8446" clientAuth="false" _name="cert_https"/>
    </network>
    <auth>
            <File location="UserAuthenticationFile.xml"/>
    </auth>
    <submission ignoreStaleMessages="false" validateXml="false"/>

    <subscription reloadPersistent="false">
    </subscription>

    <repository enable="true" numDbConnections="50" primaryKeyBatchSize="500" insertionBatchSize="500">
      <connection url="jdbc:postgresql://{{getenv "POSTGRES_ADDRESS" "tak-database"}}:5432/{{getenv "POSTGRES_DB" "cot"}}" username="{{.Env.POSTGRES_USER}}" password="{{.Env.POSTGRES_PASSWORD}}" />
    </repository>

    <repeater enable="true" periodMillis="3000" staleDelayMillis="15000">
        <!-- Examples -->
        <repeatableType initiate-test="/event/detail/emergency[@type='911 Alert']" cancel-test="/event/detail/emergency[@cancel='true']" _name="911"/>
        <repeatableType initiate-test="/event/detail/emergency[@type='Ring The Bell']" cancel-test="/event/detail/emergency[@cancel='true']" _name="RingTheBell"/>
        <repeatableType initiate-test="/event/detail/emergency[@type='Geo-fence Breached']" cancel-test="/event/detail/emergency[@cancel='true']" _name="GeoFenceBreach"/>
        <repeatableType initiate-test="/event/detail/emergency[@type='Troops In Contact']" cancel-test="/event/detail/emergency[@cancel='true']" _name="TroopsInContact"/>
    </repeater>

    <dissemination smartRetry="false" />

    <filter>
        <flowtag enable="false" text=""/>
        <streamingbroker enable="true"/>
        <scrubber enable="false" action="overwrite"/>
    </filter>

    <buffer>
        <latestSA enable="true"/>
        <queue/>
    </buffer>

    <security>
        <tls context="TLSv1.2"
            keymanager="SunX509"
            keystore="JKS" keystoreFile="/opt/tak/certs/files/takserver.jks" keystorePass="{{.Env.TAKSERVER_CERT_PASS}}"
            truststore="JKS" truststoreFile="/opt/tak/certs/files/truststore-root.jks" truststorePass="{{.Env.CA_PASS}}">
         <!-- <crl _name="TAKServer CA" crlFile="certs/files/ca.crl"/>  -->

        </tls>

    </security>

</Configuration>
