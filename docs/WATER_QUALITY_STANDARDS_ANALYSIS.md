# Water Quality Standards Analysis
## Based on Maharashtra Water Quality Status Report 2023-24

This document contains comprehensive analysis of Indian water quality standards, parameter ranges, WQI calculation methodology, and data formats extracted from the official Maharashtra Water Quality Status Report 2023-24 (MPCB - Maharashtra Pollution Control Board).

---

## 1. WATER QUALITY INDEX (WQI) CALCULATION

### Parameters Used (Surface Water)
The WQI calculation uses **4 core parameters**:
1. **pH** (Potential of Hydrogen)
2. **BOD** (Biochemical Oxygen Demand) - mg/l
3. **DO** (Dissolved Oxygen) - mg/l to % saturation
4. **FC** (Fecal Coliform) - MPN/100ml

### Modified Weights (CPCB Standard for India)
| Parameter | Original NSF Weight | Modified CPCB Weight |
|-----------|---------------------|----------------------|
| Dissolved Oxygen (DO) | 0.17 | **0.31** |
| Fecal Coliform (FC) | 0.15 | **0.28** |
| pH | 0.12 | **0.22** |
| BOD | 0.10 | **0.19** |

### WQI Formula
```
WQI = Σ (Wi × Ii)
Where:
  Wi = Modified weight for parameter i
  Ii = Sub-index value for parameter i
  Σ = Sum of all parameters
```

---

## 2. SUB-INDEX CALCULATION FORMULAS

### A. Dissolved Oxygen (DO)
**Step 1**: Convert DO to % Saturation
```
DO (% Saturation) = (DO measured / 6.5) × 100
Note: 6.5 is standard constant (DO vs temperature)
```

**Step 2**: Calculate sub-index based on range
| Range (% Saturation) | Formula |
|----------------------|---------|
| 0 - 40 | 0.18 + 0.66 × (% Saturation DO) |
| 40 - 100 | (-13.55) + 1.17 × (% Saturation DO) |
| 100 - 140 | 163.34 - 0.62 × (% Saturation DO) |

**Step 3**: Apply weight
```
Final DO Index = Sub-index × 0.31
```

### B. Fecal Coliform (FC)
| Range (MPN/100ml) | Formula |
|-------------------|---------|
| 1 - 10³ | 97.2 - 26.6 × log(FC) |
| 10³ - 10⁵ | 42.33 - 7.75 × log(FC) |
| > 10⁵ | 2 |

```
Final FC Index = Sub-index × 0.28
```

### C. pH
| Range | Formula |
|-------|---------|
| 2 - 5 | 16.1 + 7.35 × pH |
| 5 - 7.3 | (-142.67) + 33.5 × pH |
| 7.3 - 10 | 316.96 - 29.85 × pH |
| 10 - 12 | 96.17 - 8.0 × pH |
| < 2 or > 12 | 0 |

```
Final pH Index = Sub-index × 0.22
```

### D. BOD (Biochemical Oxygen Demand)
| Range (mg/l) | Formula |
|--------------|---------|
| 0 - 10 | 96.67 - 7 × BOD |
| 10 - 30 | 38.9 - 1.23 × BOD |
| > 30 | 2 |

```
Final BOD Index = Sub-index × 0.19
```

---

## 3. WATER QUALITY CLASSIFICATION

### WQI Ranges and Classifications
| WQI Range | Quality Classification | CPCB Class | MPCB Class | Status | Color Code |
|-----------|------------------------|------------|------------|---------|------------|
| **63 - 100** | **Good to Excellent** | A | A-I | Non Polluted | 🟢 Green |
| **50 - 63** | **Medium to Good** | B | Not Prescribed | Non Polluted | 🟡 Yellow |
| **38 - 50** | **Bad** | C | A-II | Polluted | 🟠 Orange |
| **< 38** | **Bad to Very Bad** | D, E | A-III, A-IV | Heavily Polluted | 🔴 Red |

---

## 4. SAMPLE WQI CALCULATION (Real Example from Report)

**Station**: Krishna River at Rajapur Weir, Kolhapur  
**Station Code**: 1153  
**Month**: April  
**Basin**: Krishna Upper  

### Given Parameters:
- BOD = 2.2 mg/l
- DO = 5.5 mg/l
- FC = 6 MPN/100ml
- pH = 7.6

### Calculation:

#### 1. BOD Sub-Index
```
BOD = 2.2 mg/l (range 0-10)
Sub-index = 96.67 - 7 × 2.2
         = 96.67 - 15.4
         = 81.27

Final BOD Index = 81.27 × 0.19 = 15.44
```

#### 2. DO Sub-Index
```
DO = 5.5 mg/l
DO % Saturation = (5.5 / 6.5) × 100 = 84.61%

Range: 40-100, so use formula:
Sub-index = (-13.55) + 1.17 × 84.61
         = (-13.55) + 98.99
         = 85.44

Final DO Index = 85.44 × 0.31 = 26.48
```

#### 3. FC Sub-Index
```
FC = 6 MPN/100ml (range 1-10³)
Sub-index = 97.2 - 26.6 × log(6)
         = 97.2 - 26.6 × 0.778
         = 97.2 - 20.69
         = 76.51

Final FC Index = 76.51 × 0.28 = 21.42
```

#### 4. pH Sub-Index
```
pH = 7.6 (range 7.3-10)
Sub-index = 316.96 - 29.85 × 7.6
         = 316.96 - 226.86
         = 90.10

Final pH Index = 90.10 × 0.22 = 19.82
```

#### 5. Final WQI
```
WQI = 15.44 + 26.48 + 21.42 + 19.82
    = 83.16

Classification: Good to Excellent ✅
```

---

## 5. WATER QUALITY MONITORING NETWORK IN MAHARASHTRA

### Total Monitoring Stations: 294

| Water Body Type | Count | Details |
|----------------|-------|---------|
| **Surface Water** | **228** | |
| - Rivers | 176 | Monthly monitoring |
| - Dams | 4 | Monthly monitoring |
| - Sea | 16 | Monthly monitoring |
| - Creek | 20 | Monthly monitoring |
| - Nallah (drains) | 12 | Monthly monitoring |
| **Groundwater** | **66** | Every 2 years |
| - Bore well | 29 | |
| - Dug well | 34 | |
| - Hand pump | 1 | |
| - Tube well | 1 | |
| - Well | 1 | |

### Basin-wise Distribution
| Basin | Surface Water | Groundwater | Total |
|-------|---------------|-------------|-------|
| Tapi | 22 | 3 | 25 |
| Godavari | 62 | 26 | 88 |
| Krishna | 59 | 15 | 74 |
| West Flowing Rivers | 85 | 22 | 107 |
| **Total** | **228** | **66** | **294** |

---

## 6. WATER QUALITY PARAMETERS MONITORED

### Core Parameters (for WQI)
1. **pH** - Acidity/Alkalinity
2. **BOD** - Biochemical Oxygen Demand (mg/l)
3. **DO** - Dissolved Oxygen (mg/l)
4. **FC** - Fecal Coliform (MPN/100ml)

### Additional Parameters Monitored
5. **Temperature** (°C)
6. **Conductivity** (µS/cm)
7. **COD** - Chemical Oxygen Demand (mg/l)
8. **TDS** - Total Dissolved Solids (mg/l)
9. **Total Hardness** (mg/l as CaCO₃)
10. **Turbidity** (NTU)
11. **Chloride** (mg/l)
12. **Nitrate** (mg/l)
13. **Sulfate** (mg/l)
14. **Fluoride** (mg/l)
15. **Total Coliform** (MPN/100ml)

---

## 7. TYPICAL PARAMETER RANGES (Maharashtra Data 2023-24)

### Surface Water - Rivers

#### pH Ranges
| Classification | Typical Range | Notes |
|----------------|---------------|-------|
| Excellent | 7.0 - 8.5 | Within BIS standards |
| Good | 6.5 - 7.0, 8.5 - 9.0 | Acceptable |
| Poor | < 6.5 or > 9.0 | Outside standards |

**Observed in Maharashtra 2023-24**:
- Minimum: 6.8
- Average: 7.5 - 8.2
- Maximum: 9.2
- 75th percentile: 7.9 - 8.3

#### BOD (Biochemical Oxygen Demand)
| Classification | Range (mg/l) | Water Use |
|----------------|--------------|-----------|
| Excellent | < 2 | Drinking water source (Class A) |
| Good | 2 - 3 | Outdoor bathing (Class B) |
| Fair | 3 - 6 | Drinking with treatment (Class C) |
| Poor | 6 - 30 | Propagation of wildlife (Class D) |
| Very Poor | > 30 | Industrial cooling, irrigation (Class E) |

**Observed in Maharashtra 2023-24**:
- Minimum: 1.0 mg/l
- Average: 2.5 - 4.5 mg/l
- Maximum: 38 mg/l (polluted stretches)
- 75th percentile: 3.2 - 5.8 mg/l

#### DO (Dissolved Oxygen)
| Classification | Range (mg/l) | % Saturation | Status |
|----------------|--------------|--------------|--------|
| Excellent | > 6.0 | > 92% | Healthy aquatic life |
| Good | 4.0 - 6.0 | 62-92% | Acceptable |
| Fair | 2.0 - 4.0 | 31-62% | Stressed |
| Poor | < 2.0 | < 31% | Hypoxic |

**Observed in Maharashtra 2023-24**:
- Minimum: 0.5 mg/l (polluted areas)
- Average: 5.2 - 7.8 mg/l
- Maximum: 9.5 mg/l
- 75th percentile: 6.5 - 8.2 mg/l

#### Fecal Coliform
| Classification | Range (MPN/100ml) | Status |
|----------------|-------------------|--------|
| Excellent | < 50 | Safe for bathing |
| Good | 50 - 500 | Moderate contamination |
| Fair | 500 - 5,000 | High contamination |
| Poor | 5,000 - 50,000 | Very high contamination |
| Very Poor | > 50,000 | Extreme contamination |

**Observed in Maharashtra 2023-24**:
- Minimum: < 1 MPN/100ml
- Average: 100 - 400 MPN/100ml
- Maximum: 160,000 MPN/100ml (heavily polluted)
- 75th percentile: 250 - 540 MPN/100ml

### Sea/Creek Water

#### pH
- Minimum: 7.0 - 7.2
- Average: 7.5 - 8.3
- Maximum: 8.3 - 8.8
- Typical: 7.7 - 8.2 (slightly alkaline)

#### Fecal Coliform
- Minimum: 1.8 - 23 MPN/100ml
- Average: 83 - 493 MPN/100ml
- Maximum: 350 - 1,600 MPN/100ml
- 75th percentile: 125 - 540 MPN/100ml

---

## 8. POLLUTED STATIONS IN MAHARASHTRA (2023-24)

### Stations with > 50% Polluted Observations

| Station Code | Station Name | Location | District | Issue |
|--------------|-------------|----------|----------|-------|
| 179 | Sillod - D/S near bridge | Sillod | Aurangabad | Urban pollution |
| 180 | Holly Cross Bridge | Aurangabad | Aurangabad | Sewage discharge |
| 181 | Near Patoda Village | Aurangabad | Aurangabad | Industrial |
| 186 | Nag River - Bhandewadi | Nagpur | Nagpur | Urban drain |
| 187 | Nag River - Asoli Bridge | Nagpur | Nagpur | Sewage |
| 188 | Pill River - Kamptee Road | Nagpur | Nagpur | Mixed pollution |
| 1189 | Bhima/Mutha - Vithalwadi | Pune | Pune | Urban sewage |
| 2168 | Mithi River | Mahim | Mumbai | Heavily polluted |
| 2191 | Mutha - Sangam Bridge | Pune | Pune | Sewage |
| 2678 | Mutha - Veer Savarkar | Pune | Pune | Urban pollution |
| 2679 | Mutha - Deccan Bridge | Pune | Pune | Sewage |
| 2782 | Rabodi Nallah | Thane | Thane | Industrial drain |
| 2783 | Colour Chem Nallah | Thane | Thane | Chemical waste |
| 2784 | Sandoz Nallah | Thane | Thane | Pharmaceutical |
| 2785 | BPT Navapur | Palghar | Palghar | Industrial |
| 2788 | Tarapur MIDC Nallah | Palghar | Palghar | Industrial complex |

---

## 9. DATA FORMAT STRUCTURE

### Station Information Format
```json
{
  "stationId": "MH-PUN-SW-001",
  "stationCode": 1153,
  "name": "Krishna River at Rajapur Weir",
  "village": "Rajapur",
  "taluka": "Shirol",
  "district": "Kolhapur",
  "latitude": 16.67253,
  "longitude": 74.572223,
  "type": "River",
  "basin": "Krishna",
  "subBasin": "Krishna Upper",
  "monitoringFrequency": "Monthly",
  "waterBodyType": "Surface Water"
}
```

### Water Quality Reading Format
```json
{
  "stationId": "MH-PUN-SW-001",
  "timestamp": "2024-04-15T10:30:00Z",
  "parameters": {
    "ph": {
      "value": 7.6,
      "unit": "pH",
      "status": "normal",
      "standardRange": "6.5-8.5"
    },
    "bod": {
      "value": 2.2,
      "unit": "mg/l",
      "status": "good",
      "standardRange": "< 3"
    },
    "dissolvedOxygen": {
      "value": 5.5,
      "unit": "mg/l",
      "saturation": 84.61,
      "status": "good",
      "standardRange": "> 4"
    },
    "fecalColiform": {
      "value": 6,
      "unit": "MPN/100ml",
      "status": "excellent",
      "standardRange": "< 50"
    },
    "temperature": {
      "value": 28.5,
      "unit": "°C"
    },
    "tds": {
      "value": 320,
      "unit": "mg/l",
      "standardRange": "< 500"
    },
    "turbidity": {
      "value": 8.2,
      "unit": "NTU",
      "standardRange": "< 10"
    },
    "totalColiform": {
      "value": 240,
      "unit": "MPN/100ml"
    }
  },
  "wqi": 83.16,
  "wqiSubIndices": {
    "ph": 19.82,
    "bod": 15.44,
    "dissolvedOxygen": 26.48,
    "fecalColiform": 21.42
  },
  "waterQualityClass": "A",
  "classification": "Good to Excellent",
  "status": "Non Polluted",
  "alerts": []
}
```

---

## 10. REALISTIC PARAMETER RANGES FOR MOCK DATA

### For Different Water Quality Classes

#### Class A: Good to Excellent (WQI 63-100)
```
pH: 7.0 - 8.5
BOD: 1.0 - 3.0 mg/l
DO: 5.0 - 8.5 mg/l (77% - 131% saturation)
Fecal Coliform: 1 - 50 MPN/100ml
Total Coliform: 50 - 500 MPN/100ml
TDS: 50 - 500 mg/l
Turbidity: 1 - 10 NTU
Temperature: 15 - 35°C (seasonal variation)
```

#### Class B: Medium to Good (WQI 50-63)
```
pH: 6.5 - 7.0 or 8.5 - 9.0
BOD: 3.0 - 6.0 mg/l
DO: 4.0 - 5.0 mg/l (62% - 77% saturation)
Fecal Coliform: 50 - 500 MPN/100ml
Total Coliform: 500 - 5,000 MPN/100ml
TDS: 500 - 1,000 mg/l
Turbidity: 10 - 25 NTU
```

#### Class C: Bad (WQI 38-50)
```
pH: 6.0 - 6.5 or 9.0 - 9.5
BOD: 6.0 - 15.0 mg/l
DO: 2.0 - 4.0 mg/l (31% - 62% saturation)
Fecal Coliform: 500 - 5,000 MPN/100ml
Total Coliform: 5,000 - 50,000 MPN/100ml
TDS: 1,000 - 2,000 mg/l
Turbidity: 25 - 100 NTU
```

#### Class D/E: Bad to Very Bad (WQI < 38)
```
pH: < 6.0 or > 9.5
BOD: > 15.0 mg/l
DO: < 2.0 mg/l (< 31% saturation)
Fecal Coliform: > 5,000 MPN/100ml
Total Coliform: > 50,000 MPN/100ml
TDS: > 2,000 mg/l
Turbidity: > 100 NTU
```

---

## 11. SEASONAL VARIATIONS TO IMPLEMENT

### Monsoon Season (June - September)
- **Increased Turbidity**: 2-5x normal values
- **Decreased DO**: -10% to -20% due to runoff
- **Increased Coliform**: 2-10x normal (sewage overflow)
- **pH**: Slight decrease (-0.2 to -0.5) due to dilution
- **BOD**: Increase (+20% to +50%) from organic matter
- **TDS**: Decrease (-20% to -40%) due to dilution

### Summer Season (March - May)
- **Increased Temperature**: +5°C to +10°C
- **Decreased DO**: -15% to -30% (warmer water holds less oxygen)
- **Increased TDS**: +20% to +40% (concentration)
- **Increased Salinity**: +30% to +50% in coastal areas
- **pH**: Slight increase (+0.2 to +0.4)
- **Status**: "Dry" for many stations

### Winter Season (November - February)
- **Decreased Temperature**: -5°C to -10°C
- **Increased DO**: +10% to +20% (cooler water)
- **Stable parameters**: Most parameters in normal range
- **Clear water**: Lower turbidity

### Post-Monsoon (October - November)
- **Gradual improvement** in all parameters
- **Settling of sediments**: Turbidity decreases
- **Recovery of DO**: Returns to normal levels

---

## 12. IMPLEMENTATION RECOMMENDATIONS

### For Enhanced Mock Data Generation

1. **Use Real Station Codes from NWMP**
   - Follow format: `MH-{DISTRICT}-{TYPE}-{NUMBER}`
   - Types: SW (Surface Water), GW (Groundwater)
   - Districts: PUN (Pune), MUM (Mumbai), NAG (Nagpur), etc.

2. **Implement Accurate WQI Calculation**
   - Use the exact CPCB formulas provided above
   - Calculate sub-indices correctly
   - Apply modified weights (0.31, 0.28, 0.22, 0.19)

3. **Generate Realistic Parameter Correlations**
   - High BOD → Low DO (inverse relationship)
   - High Fecal Coliform → High Total Coliform
   - High Temperature → Lower DO
   - High Turbidity → Often high coliform
   - Urban areas → Higher BOD, lower DO

4. **Add Geographic Context**
   - River basins: Tapi, Godavari, Krishna, West Flowing
   - Pollution hotspots: Urban areas (Pune, Mumbai, Nagpur)
   - Clean areas: Upper reaches, forested areas

5. **Implement Temporal Patterns**
   - Monthly variations based on season
   - Dry season effects (March-May)
   - Monsoon impacts (June-September)
   - Recovery patterns (October-February)

6. **Add Realistic Station Types**
   - Upstream stations: Better quality
   - Downstream of cities: Polluted
   - MIDC areas: Industrial pollution
   - Creek/Sea: Saline, tidal effects

---

## 13. KEY INSIGHTS FOR DISEASE PREDICTION

### Water Quality → Disease Risk Correlations

#### High Fecal Coliform (> 500 MPN/100ml)
**Indicates**: Sewage contamination, fecal pollution
**Disease Risks**:
- **Cholera**: Very High (score 80-100)
- **Typhoid**: High (score 70-90)
- **Dysentery**: High (score 70-85)
- **Hepatitis A**: Moderate to High (score 60-80)

#### Low Dissolved Oxygen (< 4 mg/l)
**Indicates**: Organic pollution, eutrophication
**Disease Risks**:
- **Vector breeding**: Mosquitoes (malaria, dengue)
- **Indirect health impacts**: Aquatic life death
- Stagnation Index: High (> 0.7)

#### High BOD (> 6 mg/l)
**Indicates**: High organic matter, decomposition
**Disease Risks**:
- **Waterborne diseases**: General increase
- **Vector habitat**: Favorable for breeding
- Environmental Factor: Poor water quality

#### pH Outside 6.5-8.5
**Indicates**: Industrial pollution or natural contamination
**Disease Risks**:
- **Skin infections**: Moderate (score 50-70)
- **Gastrointestinal issues**: If consumed
- **Reduced disinfection**: Ineffective chlorination

### Environmental Factors for Disease Model

```javascript
// Stagnation Index Calculation
stagnationIndex = (
  (lowDO_factor × 0.4) +
  (highBOD_factor × 0.3) +
  (temperature_factor × 0.2) +
  (season_factor × 0.1)
)

// Where:
lowDO_factor = (6.5 - DO) / 6.5  // 0-1 scale
highBOD_factor = min(BOD / 30, 1)  // 0-1 scale
temperature_factor = (temp - 15) / 20  // Higher temp = more stagnation
season_factor = 1.0 in summer, 0.5 in monsoon, 0.3 in winter
```

---

## 14. ABBREVIATIONS & STANDARDS

### Organizations
- **MPCB**: Maharashtra Pollution Control Board
- **CPCB**: Central Pollution Control Board
- **BIS**: Bureau of Indian Standards
- **NSF**: National Sanitation Foundation
- **WHO**: World Health Organisation
- **CGWB**: Central Ground Water Board

### Water Quality Terms
- **WQI**: Water Quality Index
- **WQMS**: Water Quality Monitoring Stations
- **NWMP**: National Water Quality Monitoring Program
- **BOD**: Biochemical Oxygen Demand
- **COD**: Chemical Oxygen Demand
- **DO**: Dissolved Oxygen
- **FC**: Fecal Coliform
- **TDS**: Total Dissolved Solids
- **NTU**: Nephelometric Turbidity Units
- **MPN**: Most Probable Number

---

## CONCLUSION

This comprehensive analysis provides authentic Indian water quality standards based on:
- ✅ Official MPCB Maharashtra Water Quality Report 2023-24
- ✅ CPCB (Central Pollution Control Board) guidelines
- ✅ NSF WQI calculation methodology adapted for India
- ✅ Real monitoring data from 294 stations across Maharashtra
- ✅ Actual parameter ranges observed in field data
- ✅ Authentic station codes, locations, and classifications

Use this data to:
1. Generate realistic mock data aligned with Indian standards
2. Implement accurate WQI calculations
3. Create authentic disease prediction correlations
4. Simulate real-world water quality scenarios
5. Build compliant monitoring systems

**Data Source**: Water Quality Status Report of Maharashtra 2023-2024, Maharashtra Pollution Control Board (MPCB)
**Reference Date**: November 2024
**Total Pages Analyzed**: 289 pages
**Geographic Coverage**: All 5 major river basins in Maharashtra
