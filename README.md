# GROUP 13 | Turbofan Optimisation

Adelaide University | Due 17 May 2026

---

## File Structure

```
project/
├── pipeline.m 
├── ideal_engine.m
├── real_engine.m
├── turbofan_objectives.m
├── real_turbofan_objectives.m 
└── atmosphere.m
```

---

## How to Run

1. Ensure all files in the same folder
2. Open MATLAB and `cd` to that folder
3. Run:
```matlab
pipeline
```

`atmosphere_rw.db` and `results.db` are generated automatically.

---

## Design Parameters

- Mach Number M0
- Altitude h
- Turbine temperature Tt4
- Fuel heating hPR
- Bypass ratio alpha
- Compressor pressure pi_c
- Fanpressure pi_f

## Performance Variables

- Specific thrust F/m0dot
- Thrust specific fuel consumption S (TSFC)
- Thermal efficiency eta_T
- Propulsive efficiency eta_P
- Overall efficiency eta_O

---

## Outputs

**Tables printed to console:**
- Optimal configuration per objective (ideal and real)

**9 figures generated:**
- Figures 1–7: each design parameter swept, ideal vs real
  - Top subplot: F/m0dot and TSFC
  - Bottom subplot: efficiencies
- Figure 8: optimal config swept over pi_c
- Figure 9: optimal config swept over pi_f

---

## Dependencies

- MATLAB R2022a
- Optimization Toolbox (fmincon)
- Database Toolbox (sqlite, sqlwrite, fetch)
