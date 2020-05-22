#!/usr/bin/env bash
set -eo pipefail

#/ Usage: run_loadtest.sh [option..]
#/ Description: Run array load test on a Jitsi Meet installation
#/ Examples: ./run_loadtest.sh -u wolfgang.moser@woodmark.de -pw Pa$$w0rd -p 10 -j https://jitsi.dev.messenger.schule -d 180 -k ~/.ssh/id_rsa
#/ Options:
#/   -u, --user: IONOS cloud user name
#/   -pw, --password: IONOS cloud user password
#/   -p, --participants: Number of video conference participants per worker
#/   -j, --jitsi-url: URL pointing to the Jitsi installation (optional, defaults to https://jitsi.dev.messenger.schule)
#/   -d, --duration: Duration of each conference in seconds
#/   -k, --ssh-key-path: Path to the SSH private key file used for connecting to the worker nodes (optional, defaults to ~/.ssh/id_rsa)
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() {
  for ip in "${ips[@]}"
  do
    ssh -o "StrictHostKeyChecking no" -i "$1" root@"$ip" docker-compose -f '~/jitsi-meet-torture/docker-compose.yml' down
  done
}

# Parse Parameters #
while [ "$#" -gt 1 ];
  do
  key="$1"

  case $key in
    -u|--user)
    user="$2"
    shift
    ;;
    -pw|--password)
    password="$2"
    shift
    ;;
    -p|--participants)
    participants="$2"
    shift
    ;;
    -j|--jitsi-url)
    jitsiUrl="$2"
    shift
    ;;
    -d|--duration)
    duration="$2"
    shift
    ;;
    -k|--ssh-key-path)
    sshKeyPath="$2"
    shift
    ;;
    *)
    ;;
  esac
  shift
done

if [ -z "$jitsiUrl" ]; then
  jitsiUrl="https://jitsi.dev.messenger.schule"
fi

if [ -z "$sshKeyPath" ]; then
  sshKeyPath='~/.ssh/id_rsa'
fi

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  info "Get IP addresses"
  mapfile -t ips < <( \
   curl -s -u "$user":"$password" 'https://api.ionos.com/cloudapi/v5/datacenters/df8bd51c-298f-4981-8df8-6fd07340b397/servers?depth=3' \
   | jq '.items[] | select(.properties.name | startswith("loadtest-server-")) | .entities.nics.items[].properties.ips[]' \
   | tr -d \" | tr -d \\r \
  )
  info "Found ${#ips[@]} IPs: ${ips[*]}"

  trap "cleanup $sshKeyPath $ips" EXIT

  info "Start docker-compose"
  for ip in "${ips[@]}"
  do
    ssh -o "StrictHostKeyChecking no" -i "$sshKeyPath" root@"$ip" docker-compose -f '~/jitsi-meet-torture/docker-compose.yml' up --build --scale chrome="$participants" -d
  done

  info "Start load test"
  for (( i = 0 ; i < ${#ips[@]} ; i=$i+1 ));
  do
    ssh -o "StrictHostKeyChecking no" -i "$sshKeyPath" root@"${ips[${i}]}" mvn -f '~/jitsi-meet-torture/pom.xml' \
      -Dthreadcount=1 \
      -Dorg.jitsi.malleus.conferences=1 \
      -Dorg.jitsi.malleus.participants="$participants" \
      -Dorg.jitsi.malleus.senders="$participants" \
      -Dorg.jitsi.malleus.audio_senders="$participants" \
      -Dorg.jitsi.malleus.duration="$duration" \
      -Dorg.jitsi.malleus.room_name_prefix=loadtest-"$i" \
      -Dorg.jitsi.malleus.regions="" \
      -Dremote.address="http://localhost:4444/wd/hub" \
      -Djitsi-meet.tests.toRun=MalleusJitsificus \
      -Dwdm.gitHubTokenName=jitsi-jenkins \
      -Dremote.resource.path='/usr/share/jitsi-meet-torture' \
      -Djitsi-meet.instance.url="$jitsiUrl" \
      -Djitsi-meet.isRemote=true \
      -Dchrome.disable.nosanbox=true \
      test &>/dev/null &
    info "Created conference: $jitsiUrl/loadtest-"$i"0"
  done

  # wait until load tests finishes (plus an additional startup time)
  sleep $((60+$duration))

  info "Clean up"
  cleanup $sshKeyPath $ips
fi
