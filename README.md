# Towards Extreme-Scale Ising Machines with Distributed p-Computers
**Team AOHW25_750 — Adaptive Computing (PhD)**  
University of California, Santa Barbara (UCSB)  
Navid Anjum Aadit · Supervisor: Kerem Y. Camsari

<p align="center">
  <img src="matlab/gset_maxcut/images/distributed_PC.png" width="640" alt="Distributed p-computer">
</p>

## Summary
We demonstrate a **distributed p-computer** that partitions large Ising graphs across **six FPGAs**, enabling ~100k p-bits and >3,000 flips/ns. Graph partitioning (KaHIP/METIS) minimizes cut edges; asynchronous exchange leverages probabilistic error tolerance. We provide two demos:
- **GSET Max-Cut (G81)** — CPU SA with GUI + FPGA handoff
- **EA 3D Spin Glass (L=37)** — CPU SA with GUI + FPGA handoff

## Quick Links
- **Report (PDF):** `report/AOHW25_report.pdf`
- **Video (≤2 min):** <ADD_YOUTUBE_URL>
- **License:** BSD-3-Clause (see `LICENSE`)

## Repo Layout (minimal)
- `matlab/gset_maxcut/` — G81 CPU/FPGA MATLAB demos, instance, colormap, partitions  
- `matlab/spin_glass/` — EA3D CPU/FPGA MATLAB demos, instance, ground energies, colormap  
- `matlab/common/` — shared MATLAB helpers  
- `hardware/rtl/` — SystemVerilog sources for the distributed p-bit fabric  
- `hardware/constraints/constraints.xdc` — board constraints  
- `hardware/bd/bd_export.tcl` — **optional** (block design export); omit if you prefer  
- `report/` — short project report (PDF)

## How to Run (MATLAB GUI)
### A) CPU demo
1. Open MATLAB.  
2. Add the target folder to path:
   - **Max-Cut:** `matlab/gset_maxcut/`
   - **EA3D:** `matlab/spin_glass/`
3. Open and click **Run**:
   - **Max-Cut:** `CPU_MaxCut_GSET.m`
   - **EA3D:** `CPU_EA3D.m`

### B) FPGA handoff (after CPU)
1. Program **six FPGAs** with your per-board bitstreams (Vivado Hardware Manager GUI).  
2. Ensure host can reach boards on **192.168.0.x**.  
3. In the same MATLAB session, click **Run FPGA** in the GUI:
   - **Max-Cut:** `FPGA_MaxCut_GSET.m` (auto-called from CPU script)
   - **EA3D:** `FPGA_EA3D.m` (auto-called from CPU script)

> If bitstreams are uploaded as **GitHub Release assets**, download them before programming.

## Rebuild from HDL (optional)
Open **Vivado 2023.x** → *Create Project* → add all files in `hardware/rtl/` + `hardware/constraints/constraints.xdc` → Synthesize → Implement → Generate Bitstream.  
If you use Xilinx IP, add `.xci` files (not included by default); Vivado will regenerate IP.

## Acknowledgments / References
[1] K.Y. Camsari *et al.*, Phys. Rev. X 7 (2017), 031014  
[2] N.A. Aadit *et al.*, Nat. Electron. 5 (2022), 460–468  
[3] S. Niazi *et al.*, Nat. Electron. (2024)  
[4] N. Nikhar *et al.*, Nat. Commun. 15 (2024), 8977
