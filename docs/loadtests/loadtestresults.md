Below, we share the results of our load tests run in [IONOS Cloud](https://dcd.ionos.com/). <br/>
The loadtest test server configuration for both cases was set to 16 Cores Intel, 16 GB RAM, 8 server. All simulated participants did send a high-quality video-stream (1280x720 pixels, 60 frames per second)  and sound. There are two different test cases we investigated:

## 1 One big conference
All test servers are connecting to one conference. This was achieved by a slight variation of [run_loadtest.sh](loadtest/run_loadtest.sh).
We have tested two different setups for the limits and request of the JVB pods:

### 1.1 CPU limit is 4 cores, Memory limit is 1GB

We have further varied the number channelLastN in web-configmap.yaml. It decides how many video streams are forwarded to every conference participant, where only the video of the most active N users are used. 

#### 1.1.1 ChannelLastN not set
Here are the results for channelLastN not set, that means all videos are streamed to all participants:

| Participants total | CPU usage test server | video quality | frame rate      | sound     | num participants stable | Max Memory Usage per JVB | Max CPU usage per JVB | Network Transmitted max | CPU-Throttling | Run order | Error Messages JVB and Remarks |
|-------------------|----------------------------|--------------|---------------|---------|---------------------|--------------------------|-----------------------|---------|-----------------------------|----------------|----------------|-------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 8                 | ~ 7 %                      | very high     | very high  | very good | stable         | 830 MB                   | 1,9 cores             | 4,7 MB                      | 0%             | 2           |                                                                                                                                                                                                                                                                           |
| 14                | ~ 7 %                      | very high     | very high | very good | stable         | 830 MB                   | 3,5 cores             | 10,7 MB                     | 5%             | 1           |                                                                                                                                                                                                                                                                           |
| 24                | ~20 %                      | okay         | partly lagging | very good | stable         | 940 MB                   | 4 Cores (pod limit)               | 14,6 MB                     | 80%            |3           | Conference was moved to another JVB. Observed warnings: TCC packet contained received sequence numbers: 58852-59404. Couldn't find packet detail for the seq nums: 58852-59404. Latest seqNum was 63013, size is 1000. Latest RTT is 4310.241456 ms. |

#### 1.1.2 ChannelLastN set to 5

Here are the corresponding results for channelLastN set to 5:

| Participants total | CPU-usage test server | video quality | frame rate        | sound     | num participants stable | Max Memory Usage per JVB in MB | Max CPU-Usage per JVB | Max Network Transmitted MB | CPU-Throttling | Error Messages JVB and Remarks | Run order |
|-------------------|----------------------------|--------------|-----------------|---------|---------------------|--------------------------------|-----------------------|---------|-----------------------------------------------|----------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 8         | ~ 7% | very high | very high | very good | stable | 760 MB | 1,9 Cores                 |4,1 MB | 0%  | 5 |
| 16      | ~17% | very high | very high | very good | stable | 760 MB | 3,5 Cores                 |9,1 MB | 5%  | 4 |                                                                      |
| 24 | ~20% | high      | very high | very good | stable | 800 MB | 4 Cores (pod limit) | 8,4 MB | 80% | 6 | video quality still high, network traffic seems to be manageble for JVB|

### 1.2 CPU limit is 8 cores, Memory limit is 1GB

#### 1.2.1 ChannelLastN not set
Not tested.
#### 1.2.2 ChannelLastN set to 5
| Participants total | CPU-usage test server | video quality | frame rate        | sound     | num participants stable | Max Memory Usage per JVB in MB | Max CPU-Usage per JVB | Max Network Transmitted MB | CPU-Throttling | Error Messages JVB and Remarks | Run order |
|-------------------|----------------------------|--------------|-----------------|---------|---------------------|--------------------------------|-----------------------|---------|-----------------------------------------------|----------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 32                | 30%                        | very high     | partly lagging | very good | 3 participants leaving       | 910                            | 4,3                   | 17                                            | 0              |  WARNING: 1891053881 large jump in sequence numbers detected (highest received was 52436, current is 52603, jump of 166), not requesting retransmissions , WARNING: TCC packet contained received sequence numbers: 21287-21371. Couldn't find packet detail for the seq nums: 21287-21371. Latest seqNum was 24965, size is 1000. Latest RTT is 4568.5094 ms. , INFO: timeout for pair: 217.160.210.116:30301/udp/srflx -> 157.97.109.136:52047/udp/prflx (stream-59888d67.RTP), failing. Error Messages indicate network issues. The traffic might be already to high. Conference stays mostly stable, though| 1 |
| 16                | 15%                        | very high     | very high         | very good | stable            | 960                            | 1,8                   | 8,5                                           | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | CPU usage inconsistent with other observations  | 2 |

## 2: Eight smaller conferences in parallel

Each of the eight test servers start exactly one conference with a certain number of participants. The script [run_loadtest.sh](loadtest/run_loadtest.sh) was used for this purpose. 

### 2.1 CPU limit is 4 cores, Memory limit is 1GB

There were two JVBs running for this test.

| Participants per conference | CPU-usage test server | video quality | frame rate        | sound     | num participants stable | Max Memory Usage per JVB in MB | Max CPU-Usage per JVB | Max Network Transmitted MB (both JVBs) | CPU-Throttling | Error Messages JVB and Remarks | Run order |
|-------------------|----------------------------|--------------|-----------------|---------|---------------------|--------------------------------|-----------------------|---------|-----------------------------------------------|----------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 5  | ~ 50% | very high | very high | very good   | stable | ~ 900 MB | ~ 2.5 Cores                          | 9,1 MB; 6,0 MB    | 0%  | | 4|
| 10 | ~75%  | high      | high | very good | several participants lost | ~ 860 MB | ~ 3,9 Cores (nearly pod limit= | 12,5 MB ; 10,5 MB | 50% | |3 |

Tests with bigger conference sizes have not been carried out due to the high resource demands of the test servers.
