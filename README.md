# Welcome to the LINs-Lab cluster

This is a manual for cluster users.

## Quick Guide

- [Getting Started](./docs/Getting_started.md)

- [Determined-AI User Guide](./docs/Determined_AI_User_Guide.md)

- [Custom Containerized Environment](./docs/Custom_Containerized_Environment.md)

## Introduction

Currently, we are hosting these services in the campus network (available after [configuring the `hosts`](./docs/Getting_started.md#hosts-modification)):

- [Web entry point](https://lins.lab)

- [Determined AI - Distributed Deep Learning and Hyperparameter Tuning Platform](https://gpu.lins.lab/)

- [Harbor - Container registry for GPU cluster](https://harbor.lins.lab/)

- [Grafana - Statistics and visualization](https://grafana.lins.lab/)

Our cluster is located in the core server room, E6-106.

We have been designated with an IP address range: `10.0.2.160-192/27`.

System Topology:

```text
┌───────────────────────────────────┐ ┌──────────────────────────────────┐
│             Login Node            │ │        NGINX Reverse Proxy       │
└─────────────┬─────────────────────┘ └────────┬────────┬────────────────┘
              │                                │        │
            Access      ┌────────Access────────┘      Access
              │         │                               │
┌─────────────▼─────────▼───────────┐ ┌─────────────────▼─────────────────┐
│     Determined AI GPU Cluster     │ │      Supplementary Services       │
├───────────────────────────────────┤ ├───────────────────────────────────┤
│                                   │ │                                   │
│ ┌──────┐ ┌────┐ ┌────┐ ┌────┐     │ │  ┌──────┐ ┌───────┐ ┌───────┐     │
│ │Master│ │GPU │ │GPU │ │GPU │     │ │  │      │ │       │ │       │     │
│ │      │ │    │ │    │ │    │ ... │ │  │Harbor│ │Grafana│ │ Other │ ... │
│ │ Node │ │Node│ │Node│ │Node│     │ │  │      │ │       │ │       │     │
│ └──────┘ └────┘ └────┘ └────┘     │ │  └──────┘ └───────┘ └───────┘     │
│                                   │ │                                   │
└───────────────────┬───────────────┘ └──────────┬────────────────────────┘
                    │                            │
                  Access                       Access
                    │                            │
┌───────────────────▼────────────────────────────▼────────────────────────┐
│                              TrueNAS - NFS                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│                              Storage Server                             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Hardware Information

GPU Node 1, 2:

|  Name  |  Spec  |
| :----: | :----  |
|  Model | Powerleader PR4910W (Supermicro SYS-420GP-TNR with X12DPG-OA6 motherboard)|
|  CPU   | Intel Xeon Platinum 8352Y*2 (64C/128T, 2.2-3.4GHz)|
| Memory | Samsung M393A4K40DB3-CWE DDR4 ECC REG 3200MHz 512G (32G * 16)|
|  GPU   | NVIDIA RTX 3090 Turbo * 8|
|  SSD   | Samsung PM883 (MZ7LH960) 960GB 2.5" SATA drive * 2|
|  NIC   | Intel X520-SR2 (82599ES) 10GbE Dual Port|
|  NIC   | Mellanox ConnectX-6 VPI HDR100 QSFP56 MCX653105A-ECAT 100Gb ETH/IB Single Port|
| RAID   | LSI 9361-8i|

Storage & Management Server:

|  Name  |  Spec  |
| :----: | :----  |
|  Model | Powerleader PR4036P3|
|  CPU   | Intel Xeon Silver 4210R*2  (20C/40T, 2.4-3.2GHz)|
| Memory | Samsung M393A8G40AB2-CWE DDR4 ECC REG 3200MHz 256G (64G * 4)|
|  SSD   | Samsung PM883 (MZ7LH960) 960GB 2.5" SATA drive * 2|
|  SSD   | Samsung PM983 (MZQLB7T6HMLA-00003) 7.68TB 2.5" NVMe U.2 drive|
|  NIC   | Intel X520-DA2 (82599) 10GbE Dual Port|
| RAID   | LSI 9361-8i * 2|
