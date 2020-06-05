# Loadtest results

Below, we share the results of our load tests run in [IONOS Cloud](https://dcd.ionos.com/), which took place with a Jitsi single-shard-setup.  
The loadtest test server configuration for both cases was set to 16 Cores Intel, 16 GB RAM, 8 server. All simulated participants did send a high-quality video-stream (1280x720 pixels, 60 frames per second)  and sound. There are two different test cases we investigated:

## 1 One big conference

All test servers are connecting to one conference. This was achieved by a slight variation of [run_loadtest.sh](loadtest/run_loadtest.sh).
We have tested two different setups for the limits and request of the JVB pods:

### 1.1 CPU limit is 4 cores, Memory limit is 1 GB

We have further varied the number channelLastN in web-configmap.yaml. It decides how many video streams are forwarded to every conference participant, where only the video of the most active N users are used.

#### 1.1.1 ChannelLastN not set

Here are the results for channelLastN not set, that means all videos are streamed to all participants:

<table>
<thead>
<tr>
<th>Participants total</th>
<th>CPU usage test server</th>
<th>video quality</th>
<th>frame rate</th>
<th>sound</th>
<th>num participants stable</th>
<th>Max Memory Usage per JVB</th>
<th>Max CPU usage per JVB</th>
<th>Network Transmitted max</th>
<th>CPU-Throttling</th>
<th>Run order</th>
<th>Error Messages JVB and Remarks</th>
</tr>
</thead>
<tbody>
<tr>
<td>8</td>
<td>~ 7 %</td>
<td>very high</td>
<td>very high</td>
<td>very good</td>
<td>stable</td>
<td>830 MB</td>
<td>1,9 cores</td>
<td>4,7 MB</td>
<td>0%</td>
<td>2</td>
<td></td>
</tr>
<tr>
<td>14</td>
<td>~ 7 %</td>
<td>very high</td>
<td>very high</td>
<td>very good</td>
<td>stable</td>
<td>830 MB</td>
<td>3,5 cores</td>
<td>10,7 MB</td>
<td>5%</td>
<td>1</td>
<td></td>
</tr>
<tr>
<td>24</td>
<td>~20 %</td>
<td>okay</td>
<td>partly lagging</td>
<td>very good</td>
<td>stable</td>
<td>940 MB</td>
<td>4 Cores (pod limit)</td>
<td>14,6 MB</td>
<td>80%</td>
<td>3</td>
<td>Conference was moved to another JVB. Observed warnings: TCC packet contained received sequence numbers: 58852-59404. Couldn't find packet detail for the seq nums: 58852-59404. Latest seqNum was 63013, size is 1000. Latest RTT is 4310.241456 ms.</td>
</tr>
</tbody>
</table>

#### 1.1.2 ChannelLastN set to 5

Here are the corresponding results for channelLastN set to 5:

<table>
<thead>
<tr>
<th>Participants total</th>
<th>CPU-usage test server</th>
<th>video quality</th>
<th>frame rate</th>
<th>sound</th>
<th>num participants stable</th>
<th>Max Memory Usage per JVB in MB</th>
<th>Max CPU-Usage per JVB</th>
<th>Max Network Transmitted MB</th>
<th>CPU-Throttling</th>
<th>Error Messages JVB and Remarks</th>
<th>Run order</th>
</tr>
</thead>
<tbody>
<tr>
<td>8</td>
<td>~ 7%</td>
<td>very high</td>
<td>very high</td>
<td>very good</td>
<td>stable</td>
<td>760 MB</td>
<td>1,9 Cores</td>
<td>4,1 MB</td>
<td>0%</td>
<td>5</td>
</tr>
<tr>
<td>16</td>
<td>~17%</td>
<td>very high</td>
<td>very high</td>
<td>very good</td>
<td>stable</td>
<td>760 MB</td>
<td>3,5 Cores</td>
<td>9,1 MB</td>
<td>5%</td>
<td>4</td>
<td></td>
</tr>
<tr>
<td>24</td>
<td>~20%</td>
<td>high</td>
<td>very high</td>
<td>very good</td>
<td>stable</td>
<td>800 MB</td>
<td>4 Cores (pod limit)</td>
<td>8,4 MB</td>
<td>80%</td>
<td>6</td>
<td>video quality still high, network traffic seems to be manageble for JVB</td>
</tr>
</tbody>
</table>

### 1.2 CPU limit is 8 cores, Memory limit is 1 GB

#### 1.2.1 ChannelLastN not set
Not tested.
#### 1.2.2 ChannelLastN set to 5
<table>
<thead>
<tr>
<th>Participants total</th>
<th>CPU-usage test server</th>
<th>video quality</th>
<th>frame rate</th>
<th>sound</th>
<th>num participants stable</th>
<th>Max Memory Usage per JVB in MB</th>
<th>Max CPU-Usage per JVB</th>
<th>Max Network Transmitted MB</th>
<th>CPU-Throttling</th>
<th>Error Messages JVB and Remarks</th>
<th>Run order</th>
</tr>
</thead>
<tbody>
<tr>
<td>32</td>
<td>30%</td>
<td>very high</td>
<td>partly lagging</td>
<td>very good</td>
<td>3 participants leaving</td>
<td>910</td>
<td>4,3</td>
<td>17</td>
<td>0</td>
<td>WARNING: 1891053881 large jump in sequence numbers detected (highest received was 52436, current is 52603, jump of 166), not requesting retransmissions , WARNING: TCC packet contained received sequence numbers: 21287-21371. Couldn't find packet detail for the seq nums: 21287-21371. Latest seqNum was 24965, size is 1000. Latest RTT is 4568.5094 ms. , INFO: timeout for pair: 217.160.210.116:30301/udp/srflx -> 157.97.109.136:52047/udp/prflx (stream-59888d67.RTP), failing. Error Messages indicate network issues. The traffic might be already to high. Conference stays mostly stable, though</td>
<td>1</td>
</tr>
<tr>
<td>16</td>
<td>15%</td>
<td>very high</td>
<td>very high</td>
<td>very good</td>
<td>stable</td>
<td>960</td>
<td>1,8</td>
<td>8,5</td>
<td>0</td>
<td>CPU usage inconsistent with other observations</td>
<td>2</td>
</tr>
</tbody>
</table>

## 2 Eight smaller conferences in parallel

Each of the eight test servers start exactly one conference with a certain number of participants. The script [run_loadtest.sh](loadtest/run_loadtest.sh) was used for this purpose. 

### 2.1 CPU limit is 4 cores, Memory limit is 1GB

There were two JVBs running for this test.

<table>
<thead>
<tr>
<th>Participants per conference</th>
<th>CPU-usage test server</th>
<th>video quality</th>
<th>frame rate</th>
<th>sound</th>
<th>num participants stable</th>
<th>Max Memory Usage per JVB in MB</th>
<th>Max CPU-Usage per JVB</th>
<th>Max Network Transmitted MB (both JVBs)</th>
<th>CPU-Throttling</th>
<th>Error Messages JVB and Remarks</th>
<th>Run order</th>
</tr>
</thead>
<tbody>
<tr>
<td>5</td>
<td>~ 50%</td>
<td>very high</td>
<td>very high</td>
<td>very good</td>
<td>stable</td>
<td>~ 900 MB</td>
<td>~ 2.5 Cores</td>
<td>9,1 MB; 6,0 MB</td>
<td>0%</td>
<td></td>
<td>4</td>
</tr>
<tr>
<td>10</td>
<td>~75%</td>
<td>high</td>
<td>high</td>
<td>very good</td>
<td>several participants lost</td>
<td>~ 860 MB</td>
<td>~ 3,9 Cores (nearly pod limit=</td>
<td>12,5 MB ; 10,5 MB</td>
<td>50%</td>
<td></td>
<td>3</td>
</tr>
</tbody>
</table>

Tests with bigger conference sizes have not been carried out due to the high resource demands of the test servers.
