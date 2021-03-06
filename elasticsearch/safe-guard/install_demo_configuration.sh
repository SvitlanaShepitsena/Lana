#!/bin/bash
#install_demo_configuration.sh [-y]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "## Search Guard Demo Installer ##"
echo "Warning: Do not use on production or public reachable systems"

if [ "$1" != "-y" ]; then
	read -r -p "Continue? [y/N] " response
	case "$response" in
	    [yY][eE][sS]|[yY])
	        ;;
	    *)
	        exit 0
	        ;;
	esac
fi

set -e
BASE_DIR="$DIR/../../.."
if [ -d "$BASE_DIR" ]; then
	CUR="$(pwd)"
	cd "$BASE_DIR"
	BASE_DIR="$(pwd)"
	cd "$CUR"
	echo "Basedir: $BASE_DIR"
else
    echo "DEBUG: basedir does not exist"
fi
ES_CONF_FILE="$BASE_DIR/config/elasticsearch.yml"
ES_BIN_DIR="$BASE_DIR/bin"
ES_PLUGINS_DIR="$BASE_DIR/plugins"
ES_LIB_PATH="$BASE_DIR/lib"
SUDO_CMD=""
BASE_64_DECODE_CMD="base64 -d"
ES_INSTALL_TYPE=".tar.gz"

#Check if its a rpm/deb install
if [ -f /usr/share/elasticsearch/bin/elasticsearch ]; then
    ES_CONF_FILE="/usr/share/elasticsearch/config/elasticsearch.yml"

    if [ ! -f "$ES_CONF_FILE" ]; then
        ES_CONF_FILE="/etc/elasticsearch/elasticsearch.yml"
    fi

    ES_BIN_DIR="/usr/share/elasticsearch/bin"
    ES_PLUGINS_DIR="/usr/share/elasticsearch/plugins"
    ES_LIB_PATH="/usr/share/elasticsearch/lib"

    if [ -x "$(command -v sudo)" ]; then
        SUDO_CMD="sudo"
        echo "This script maybe require your root password for 'sudo' privileges"
    fi

    ES_INSTALL_TYPE="rpm/deb"
fi

if [ $SUDO_CMD ]; then
    if ! [ -x "$(command -v $SUDO_CMD)" ]; then
        echo "Unable to locate 'sudo' command. Quit."
        exit 1
    fi
fi

if $SUDO_CMD test -f "$ES_CONF_FILE"; then
    :
else
    echo "Unable to determine elasticsearch config directory. Quit."
    exit -1
fi

if [ ! -d $ES_BIN_DIR ]; then
	echo "Unable to determine elasticsearch bin directory. Quit."
	exit -1
fi

if [ ! -d $ES_PLUGINS_DIR ]; then
	echo "Unable to determine elasticsearch plugins directory. Quit."
	exit -1
fi

if [ ! -d $ES_LIB_PATH ]; then
	echo "Unable to determine elasticsearch lib directory. Quit."
	exit -1
fi

ES_CONF_DIR=$(dirname "${ES_CONF_FILE}")
ES_CONF_DIR=`cd "$ES_CONF_DIR" ; pwd`

if [ ! -d "$ES_PLUGINS_DIR/search-guard-5" ]; then
  echo "Search Guard plugin not installed. Quit."
  exit -1
fi

ES_VERSION=("$ES_LIB_PATH/elasticsearch-*.jar")
ES_VERSION=$(echo $ES_VERSION | sed 's/.*elasticsearch-\(.*\)\.jar/\1/')

SG_VERSION=("$ES_PLUGINS_DIR/search-guard-5/search-guard-5-*.jar")
SG_VERSION=$(echo $SG_VERSION | sed 's/.*search-guard-5-\(.*\)\.jar/\1/')

OS=$(sb_release -ds 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 || uname -om)
echo "Elasticsearch install type: $ES_INSTALL_TYPE on $OS"
echo "Elasticsearch config dir: $ES_CONF_DIR"
echo "Elasticsearch config file: $ES_CONF_FILE"
echo "Elasticsearch bin dir: $ES_BIN_DIR"
echo "Elasticsearch plugins dir: $ES_PLUGINS_DIR"
echo "Elasticsearch lib dir: $ES_LIB_PATH"
echo "Detected Elasticsearch Version: $ES_VERSION"
echo "Detected Search Guard Version: $SG_VERSION"

if $SUDO_CMD grep --quiet -i searchguard $ES_CONF_FILE; then
  echo "$ES_CONF_FILE seems to be already configured for Search Guard. Quit."
  exit -1
fi

SG_ADMIN_KSEYSTORE_B64="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"
SG_KEYSTORE_B64="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"
SG_TRUSTSTORE_B64="/u3+7QAAAAIAAAABAAAAAgANcm9vdC1jYS1jaGFpbgAAAVR9hKmTAAVYLjUwOQAABAIwggP+MIIC5qADAgECAgEBMA0GCSqGSIb3DQEBBQUAMIGPMRMwEQYKCZImiZPyLGQBGRYDY29tMRcwFQYKCZImiZPyLGQBGRYHZXhhbXBsZTEZMBcGA1UECgwQRXhhbXBsZSBDb20gSW5jLjEhMB8GA1UECwwYRXhhbXBsZSBDb20gSW5jLiBSb290IENBMSEwHwYDVQQDDBhFeGFtcGxlIENvbSBJbmMuIFJvb3QgQ0EwHhcNMTYwNTA0MjA0NTI2WhcNMjYwNTA0MjA0NTI2WjCBjzETMBEGCgmSJomT8ixkARkWA2NvbTEXMBUGCgmSJomT8ixkARkWB2V4YW1wbGUxGTAXBgNVBAoMEEV4YW1wbGUgQ29tIEluYy4xITAfBgNVBAsMGEV4YW1wbGUgQ29tIEluYy4gUm9vdCBDQTEhMB8GA1UEAwwYRXhhbXBsZSBDb20gSW5jLiBSb290IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApw0wsnX8sgACv9Jb6C4WxkfyzG1jUynHCMQ9s+9B9enRyE2qpSA3zvPrAuKMt5h+iP4/kGhzQGq9erRdkYv86Lc5sKZR0pSgVwrtQutrX0eCgjClSj1txXcQQe3EXDp7rsfA++1LuhFtJuxc8DiSMz3cnMSF50/VXbe8Zk7w/0C9+Lxd8L3KmXMCDnymGR/sr1cZfT5cGk6Pzxs+MKyDaLnJr2drU/ZX2F4MZxEuRAc7pc2t1CPMi84I0iOi41vvVUo5PHp56E5BmS1cbFGsej2qQ8oI6RK0rfQBGMrpgdyGsQJtT62UFDb8cbEBy5a6wLLCpMBf03WN19I/AFRncwIDAQABo2MwYTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUUQOZoY3i0Tw5M0u/oKhvjGPTBLcwHwYDVR0jBBgwFoAUUQOZoY3i0Tw5M0u/oKhvjGPTBLcwDQYJKoZIhvcNAQEFBQADggEBADdJCbcDHPQd8hwUfaon+SRQMezvSDNRFY9sdCoVFNz6nWddPx+VxYOoASnuExVYLGrqt/42P0SPh4nhFa6aQXZTISdRH5iM+niBf+Thvj7M6wZAK+k/8snwSDWAjPpz8uKfW+7R12kZkwj6k9XKbsw2TGcpIzZPI5+PYA6uMPlIfNzcD1q+OtZh0c4XeOsX0nF+NfivObCHxKAnJJAqO0q5tL+bhtp+sntxwUItfFt6tbFSXcnhAxE1rHMtRrOo3CGctPD7/RmEeBbyFDkvTGF2upARGndHDpuEs4EvoC1qjGNpYcrZZ6mzrBngKN9lE/8AWWxwPqFaXba1Go63vGmOLKwWS4mSsOrNltzcBxs7eld1tA=="

if [ "$(uname)" == "Darwin" ]; then
    BASE_64_DECODE_CMD="base64 -D"
fi

echo "$SG_ADMIN_KSEYSTORE_B64" | $BASE_64_DECODE_CMD | $SUDO_CMD tee "$ES_CONF_DIR/kirk.jks" > /dev/null
echo "$SG_KEYSTORE_B64" | $BASE_64_DECODE_CMD | $SUDO_CMD tee "$ES_CONF_DIR/keystore.jks" > /dev/null
echo "$SG_TRUSTSTORE_B64" | $BASE_64_DECODE_CMD | $SUDO_CMD tee "$ES_CONF_DIR/truststore.jks" > /dev/null

echo "" | $SUDO_CMD tee -a  $ES_CONF_FILE
echo "######## Start Search Guard Demo Configuration ########" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
echo "searchguard.ssl.transport.keystore_filepath: keystore.jks" | $SUDO_CMD tee -a  $ES_CONF_FILE > /dev/null
echo "searchguard.ssl.transport.truststore_filepath: truststore.jks" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
echo "searchguard.ssl.transport.enforce_hostname_verification: false" | $SUDO_CMD tee -a  $ES_CONF_FILE > /dev/null
echo "searchguard.ssl.http.enabled: true" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
echo "searchguard.ssl.http.keystore_filepath: keystore.jks" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
echo "searchguard.ssl.http.truststore_filepath: truststore.jks" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
echo "searchguard.authcz.admin_dn:" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
echo "  - CN=kirk,OU=client,O=client,L=test, C=de" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
echo "" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null

if $SUDO_CMD grep --quiet -i "cluster.name" $ES_CONF_FILE; then
	: #already present
else
    echo "cluster.name: searchguard_demo" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
fi

if $SUDO_CMD grep --quiet -i "network.host" $ES_CONF_FILE; then
	: #already present
else
    echo "network.host: 0.0.0.0" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
fi

if $SUDO_CMD grep --quiet -i "discovery.zen.minimum_master_nodes" $ES_CONF_FILE; then
	: #already present
else
    echo "discovery.zen.minimum_master_nodes: 1" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
fi

echo 'node.max_local_storage_nodes: 3' | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null

if [ -d "$ES_PLUGINS_DIR/x-pack" ];then
	echo "xpack.security.enabled: false" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null
fi
echo "######## End Search Guard Demo Configuration ########" | $SUDO_CMD tee -a $ES_CONF_FILE > /dev/null

$SUDO_CMD chmod +x "$ES_PLUGINS_DIR/search-guard-5/tools/sgadmin.sh"

ES_PLUGINS_DIR=`cd "$ES_PLUGINS_DIR" ; pwd`

echo "### Success"
echo "### Execute this script now on all your nodes and then start all nodes"
echo "### After the whole cluster is up execute: "
echo "#!/bin/bash" | $SUDO_CMD tee sgadmin_demo.sh > /dev/null
echo $SUDO_CMD "$ES_PLUGINS_DIR/search-guard-5/tools/sgadmin.sh" -cd "$ES_PLUGINS_DIR/search-guard-5/sgconfig" -icl -ks "$ES_CONF_DIR/kirk.jks" -ts "$ES_CONF_DIR/truststore.jks" -nhnv | $SUDO_CMD tee -a sgadmin_demo.sh > /dev/null
$SUDO_CMD chmod +x sgadmin_demo.sh
$SUDO_CMD cat sgadmin_demo.sh | tail -1
echo "### or run ./sgadmin_demo.sh"
echo "### Then open https://localhost:9200 an login with admin/admin"
echo "### (Just ignore the ssl certificate warning because we installed a self signed demo certificate)"