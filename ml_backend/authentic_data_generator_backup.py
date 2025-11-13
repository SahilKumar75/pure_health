"""
Enhanced Water Quality Data Generator with Authentic Maharashtra Ranges
Based on Maharashtra Water Quality Status Report 2023-24 (MPCB)
Implements CPCB WQI calculation methodology
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import json
import math

class AuthenticWaterQualityGenerator:
    """
    Generates realistic water quality data based on actual Maharashtra monitoring data
    Follows CPCB standards and MPCB classifications
    """
    
    # CPCB Modified Weights for WQI
    WEIGHT_DO = 0.31
    WEIGHT_FC = 0.28
    WEIGHT_PH = 0.22
    WEIGHT_BOD = 0.19
    
    # DO Saturation Constant
    DO_SATURATION_CONSTANT = 6.5
    
    # Seasonal patterns from Maharashtra report
    SEASONS = {
        'monsoon': {  # June - September
            'months': [6, 7, 8, 9],
            'turbidity_multiplier': (2.0, 5.0),
            'fc_multiplier': (2.0, 10.0),
            'do_multiplier': (0.8, 0.9),
            'bod_multiplier': (1.2, 1.5),
            'tds_multiplier': (0.8, 1.2),  # Variable due to dilution
            'description': 'Heavy rainfall, high turbidity, increased bacterial contamination'
        },
        'summer': {  # March - May
            'months': [3, 4, 5],
            'temperature_increase': (5, 10),
            'do_multiplier': (0.7, 0.85),
            'tds_multiplier': (1.1, 1.3),
            'fc_multiplier': (1.2, 2.0),  # Concentrated in low flow
            'evaporation_effect': True,
            'description': 'High temperatures, low flow, concentrated pollutants'
        },
        'winter': {  # November - February
            'months': [11, 12, 1, 2],
            'temperature_decrease': (3, 8),
            'do_multiplier': (1.1, 1.2),
            'bod_multiplier': (0.8, 0.9),
            'fc_multiplier': (0.7, 0.9),
            'description': 'Best water quality, low biological activity'
        },
        'post_monsoon': {  # October
            'months': [10],
            'turbidity_multiplier': (1.2, 2.0),  # Declining
            'fc_multiplier': (1.0, 1.5),  # Normalizing
            'do_multiplier': (0.95, 1.05),
            'description': 'Transition period, quality improving'
        }
    }
    
    def __init__(self, seed=42):
        """Initialize generator with random seed for reproducibility"""
        np.random.seed(seed)
        self.seed = seed
    
    def calculate_wqi(self, ph, bod, dissolved_oxygen, fecal_coliform, temperature=None):
        """
        Calculate WQI using authentic CPCB methodology
        Matches formula from Maharashtra Water Quality Status Report 2023-24
        
        Args:
            ph: pH value
            bod: Biochemical Oxygen Demand (mg/l)
            dissolved_oxygen: Dissolved Oxygen (mg/l)
            fecal_coliform: Fecal Coliform count (MPN/100ml)
            temperature: Optional temperature for DO saturation adjustment
        
        Returns:
            float: WQI value (0-100)
        """
        # Calculate sub-indices
        do_sub_index = self._calculate_do_sub_index(dissolved_oxygen, temperature)
        fc_sub_index = self._calculate_fc_sub_index(fecal_coliform)
        ph_sub_index = self._calculate_ph_sub_index(ph)
        bod_sub_index = self._calculate_bod_sub_index(bod)
        
        # Apply weights
        wqi = (
            (do_sub_index * self.WEIGHT_DO) +
            (fc_sub_index * self.WEIGHT_FC) +
            (ph_sub_index * self.WEIGHT_PH) +
            (bod_sub_index * self.WEIGHT_BOD)
        )
        
        return max(0, min(100, wqi))  # Clamp to 0-100
    
    def _calculate_do_sub_index(self, do_value, temperature):
        """Calculate DO sub-index based on % saturation"""
        # Adjust saturation constant by temperature if provided
        saturation_constant = self.DO_SATURATION_CONSTANT
        if temperature is not None:
            saturation_constant = self.DO_SATURATION_CONSTANT * (1 - ((temperature - 20) * 0.015))
            saturation_constant = max(4.0, min(9.0, saturation_constant))
        
        do_saturation_percent = (do_value / saturation_constant) * 100
        
        if 0 <= do_saturation_percent <= 40:
            sub_index = 0.18 + (0.66 * do_saturation_percent)
        elif 40 < do_saturation_percent <= 100:
            sub_index = -13.55 + (1.17 * do_saturation_percent)
        elif 100 < do_saturation_percent <= 140:
            sub_index = 163.34 - (0.62 * do_saturation_percent)
        else:
            sub_index = 50.0 if do_saturation_percent > 140 else 2.0
        
        return max(0, min(100, sub_index))
    
    def _calculate_fc_sub_index(self, fc_value):
        """Calculate Fecal Coliform sub-index"""
        if fc_value < 1:
            return 97.0
        
        if 1 <= fc_value <= 1000:
            log_fc = math.log10(fc_value)
            sub_index = 97.2 - (26.6 * log_fc)
        elif 1000 < fc_value <= 100000:
            log_fc = math.log10(fc_value)
            sub_index = 42.33 - (7.75 * log_fc)
        else:
            sub_index = 2.0
        
        return max(0, min(100, sub_index))
    
    def _calculate_ph_sub_index(self, ph_value):
        """Calculate pH sub-index"""
        if 2 <= ph_value < 5:
            sub_index = 16.1 + (7.35 * ph_value)
        elif 5 <= ph_value < 7.3:
            sub_index = -142.67 + (33.5 * ph_value)
        elif 7.3 <= ph_value <= 10:
            sub_index = 316.96 - (29.85 * ph_value)
        elif 10 < ph_value <= 12:
            sub_index = 96.17 - (8.0 * ph_value)
        else:
            sub_index = 0.0
        
        return max(0, min(100, sub_index))
    
    def _calculate_bod_sub_index(self, bod_value):
        """Calculate BOD sub-index"""
        if 0 <= bod_value <= 10:
            sub_index = 96.67 - (7.0 * bod_value)
        elif 10 < bod_value <= 30:
            sub_index = 38.9 - (1.23 * bod_value)
        else:
            sub_index = 2.0
        
        return max(0, min(100, sub_index))
    
    def get_classification(self, wqi):
        """Get water quality classification based on WQI"""
        if wqi >= 63:
            return {
                'classification': 'Good to Excellent',
                'cpcbClass': 'A',
                'mpcbClass': 'A-I',
                'status': 'Non Polluted'
            }
        elif wqi >= 50:
            return {
                'classification': 'Medium to Good',
                'cpcbClass': 'B',
                'mpcbClass': 'Not Prescribed',
                'status': 'Non Polluted'
            }
        elif wqi >= 38:
            return {
                'classification': 'Bad',
                'cpcbClass': 'C',
                'mpcbClass': 'A-II',
                'status': 'Polluted'
            }
        else:
            return {
                'classification': 'Bad to Very Bad',
                'cpcbClass': 'D' if wqi >= 25 else 'E',
                'mpcbClass': 'A-III' if wqi >= 25 else 'A-IV',
                'status': 'Heavily Polluted'
            }
    
    def generate_parameter(self, param_type, quality_target='good', location_type='rural'):
        """
        Generate individual parameter based on quality target and location
        
        Args:
            param_type: 'ph', 'bod', 'do', 'fc', 'tds', 'turbidity', 'temperature', 'total_coliform'
            quality_target: 'excellent', 'good', 'medium', 'bad', 'very_bad'
            location_type: 'rural', 'urban', 'industrial', 'coastal'
        
        Returns:
            float: Generated parameter value
        """
        # Ranges based on Maharashtra WQR 2023-24
        ranges = {
            'ph': {
                'excellent': (7.0, 8.2, 0.3),  # (min, max, std)
                'good': (6.8, 8.5, 0.4),
                'medium': (6.5, 9.0, 0.5),
                'bad': (6.0, 9.5, 0.6),
                'very_bad': (5.5, 10.0, 0.8)
            },
            'bod': {  # mg/l
                'excellent': (1.0, 2.5, 0.4),
                'good': (2.0, 4.0, 0.6),
                'medium': (3.5, 8.0, 1.2),
                'bad': (6.0, 20.0, 3.0),
                'very_bad': (15.0, 38.0, 5.0)
            },
            'do': {  # mg/l
                'excellent': (6.5, 8.5, 0.6),
                'good': (5.0, 7.5, 0.8),
                'medium': (4.0, 6.0, 0.7),
                'bad': (2.5, 4.5, 0.6),
                'very_bad': (0.5, 3.0, 0.5)
            },
            'fc': {  # MPN/100ml - log scale
                'excellent': (1, 50, 1.5),
                'good': (10, 500, 2.0),
                'medium': (100, 5000, 2.5),
                'bad': (500, 50000, 3.0),
                'very_bad': (5000, 160000, 3.5)
            },
            'tds': {  # mg/l
                'excellent': (50, 300, 60),
                'good': (200, 500, 80),
                'medium': (400, 1000, 150),
                'bad': (800, 1500, 200),
                'very_bad': (1200, 2000, 250)
            },
            'turbidity': {  # NTU
                'excellent': (1, 5, 1.0),
                'good': (3, 10, 2.0),
                'medium': (8, 25, 4.0),
                'bad': (20, 50, 8.0),
                'very_bad': (40, 100, 15.0)
            },
            'temperature': {  # °C
                'excellent': (20, 30, 3.0),
                'good': (18, 32, 4.0),
                'medium': (15, 35, 5.0),
                'bad': (15, 35, 5.0),
                'very_bad': (15, 35, 5.0)
            },
            'total_coliform': {  # MPN/100ml - log scale
                'excellent': (50, 500, 2.0),
                'good': (200, 5000, 2.5),
                'medium': (1000, 50000, 3.0),
                'bad': (10000, 500000, 3.5),
                'very_bad': (100000, 1000000, 4.0)
            }
        }
        
        # Location adjustments
        location_factors = {
            'rural': 1.0,
            'urban': 1.3,  # More pollution
            'industrial': 1.6,  # High pollution
            'coastal': 1.1  # Saline effects
        }
        
        if param_type not in ranges:
            raise ValueError(f"Unknown parameter type: {param_type}")
        
        param_range = ranges[param_type].get(quality_target, ranges[param_type]['good'])
        min_val, max_val, std = param_range
        
        # Adjust for location
        location_factor = location_factors.get(location_type, 1.0)
        
        if param_type in ['fc', 'total_coliform']:
            # Log-normal distribution for coliform
            mean_log = (math.log(min_val) + math.log(max_val)) / 2
            value = np.random.lognormal(mean_log, std / 2) * location_factor
            value = max(min_val, min(max_val * 2, value))
        else:
            # Normal distribution
            mean = (min_val + max_val) / 2
            value = np.random.normal(mean, std) * location_factor
            
            # Special case for parameters that shouldn't exceed limits
            if param_type in ['ph', 'temperature']:
                value = max(min_val, min(max_val, value))
            else:
                value = max(min_val * 0.5, value)  # Allow some variation below min
        
        return value
    
    def apply_parameter_correlations(self, data):
        """
        Apply realistic parameter correlations
        High BOD → Low DO
        High FC → High Total Coliform
        High Temperature → Lower DO
        High Turbidity → Often high coliform
        """
        df = pd.DataFrame(data)
        
        # BOD and DO inverse relationship
        for i in range(len(df)):
            if df.loc[i, 'bod'] > 8:
                # High BOD reduces DO
                df.loc[i, 'dissolved_oxygen'] *= 0.7
            elif df.loc[i, 'bod'] > 5:
                df.loc[i, 'dissolved_oxygen'] *= 0.85
        
        # Temperature and DO inverse relationship
        for i in range(len(df)):
            if df.loc[i, 'temperature'] > 30:
                df.loc[i, 'dissolved_oxygen'] *= 0.85
            elif df.loc[i, 'temperature'] < 20:
                df.loc[i, 'dissolved_oxygen'] *= 1.15
        
        # Fecal Coliform and Total Coliform relationship
        for i in range(len(df)):
            fc = df.loc[i, 'fecal_coliform']
            # Total coliform is typically 3-10x fecal coliform
            df.loc[i, 'total_coliform'] = fc * np.random.uniform(3, 10)
        
        # High turbidity correlates with coliform
        for i in range(len(df)):
            if df.loc[i, 'turbidity'] > 20:
                df.loc[i, 'fecal_coliform'] *= np.random.uniform(1.5, 3.0)
                df.loc[i, 'total_coliform'] *= np.random.uniform(1.5, 3.0)
        
        return df
    
    def get_season_from_month(self, month):
        """Determine season from month number (1-12)"""
        for season_name, season_data in self.SEASONS.items():
            if month in season_data['months']:
                return season_name
        return 'post_monsoon'  # Default
    
    def apply_seasonal_patterns(self, data, season=None, month=None):
        """
        Apply realistic seasonal variations to water quality data
        Based on Maharashtra report seasonal findings
        
        Args:
            data: Dict or DataFrame with water quality parameters
            season: Season name ('monsoon', 'summer', 'winter', 'post_monsoon')
            month: Month number (1-12) - used if season not provided
        
        Returns:
            Modified data with seasonal adjustments
        """
        if isinstance(data, pd.DataFrame):
            df = data.copy()
            is_dataframe = True
        else:
            df = pd.DataFrame([data])
            is_dataframe = False
        
        # Determine season
        if season is None:
            if month is None:
                # Use current month if not specified
                month = datetime.now().month
            season = self.get_season_from_month(month)
        
        if season not in self.SEASONS:
            return data  # No changes if invalid season
        
        season_params = self.SEASONS[season]
        
        # Apply seasonal multipliers
        for i in range(len(df)):
            # Monsoon effects
            if season == 'monsoon':
                turb_mult = np.random.uniform(*season_params['turbidity_multiplier'])
                fc_mult = np.random.uniform(*season_params['fc_multiplier'])
                do_mult = np.random.uniform(*season_params['do_multiplier'])
                bod_mult = np.random.uniform(*season_params['bod_multiplier'])
                tds_mult = np.random.uniform(*season_params['tds_multiplier'])
                
                df.loc[i, 'turbidity'] *= turb_mult
                df.loc[i, 'fecal_coliform'] *= fc_mult
                df.loc[i, 'total_coliform'] *= fc_mult
                df.loc[i, 'dissolved_oxygen'] *= do_mult
                df.loc[i, 'bod'] *= bod_mult
                df.loc[i, 'tds'] *= tds_mult
            
            # Summer effects
            elif season == 'summer':
                temp_increase = np.random.uniform(*season_params['temperature_increase'])
                do_mult = np.random.uniform(*season_params['do_multiplier'])
                tds_mult = np.random.uniform(*season_params['tds_multiplier'])
                fc_mult = np.random.uniform(*season_params['fc_multiplier'])
                
                df.loc[i, 'temperature'] += temp_increase
                df.loc[i, 'dissolved_oxygen'] *= do_mult
                df.loc[i, 'tds'] *= tds_mult
                df.loc[i, 'fecal_coliform'] *= fc_mult
                df.loc[i, 'total_coliform'] *= fc_mult
            
            # Winter effects
            elif season == 'winter':
                temp_decrease = np.random.uniform(*season_params['temperature_decrease'])
                do_mult = np.random.uniform(*season_params['do_multiplier'])
                bod_mult = np.random.uniform(*season_params['bod_multiplier'])
                fc_mult = np.random.uniform(*season_params['fc_multiplier'])
                
                df.loc[i, 'temperature'] -= temp_decrease
                df.loc[i, 'dissolved_oxygen'] *= do_mult
                df.loc[i, 'bod'] *= bod_mult
                df.loc[i, 'fecal_coliform'] *= fc_mult
                df.loc[i, 'total_coliform'] *= fc_mult
            
            # Post-monsoon effects
            elif season == 'post_monsoon':
                turb_mult = np.random.uniform(*season_params['turbidity_multiplier'])
                fc_mult = np.random.uniform(*season_params['fc_multiplier'])
                do_mult = np.random.uniform(*season_params['do_multiplier'])
                
                df.loc[i, 'turbidity'] *= turb_mult
                df.loc[i, 'fecal_coliform'] *= fc_mult
                df.loc[i, 'total_coliform'] *= fc_mult
                df.loc[i, 'dissolved_oxygen'] *= do_mult
            
            # Ensure parameters stay within realistic bounds
            df.loc[i, 'ph'] = max(5.5, min(9.5, df.loc[i, 'ph']))
            df.loc[i, 'dissolved_oxygen'] = max(0.28, min(9.75, df.loc[i, 'dissolved_oxygen']))
            df.loc[i, 'bod'] = max(0.5, min(40.0, df.loc[i, 'bod']))
            df.loc[i, 'turbidity'] = max(0.5, min(150.0, df.loc[i, 'turbidity']))
            df.loc[i, 'temperature'] = max(10.0, min(40.0, df.loc[i, 'temperature']))
        
        if is_dataframe:
            return df
        else:
            return df.iloc[0].to_dict()
    
    def generate_dataset(self, n_samples=1000, quality_distribution=None, location_type='rural', season=None):
        """
        Generate complete dataset with authentic parameter ranges
        
        Args:
            n_samples: Number of samples to generate
            quality_distribution: Dict with quality targets and their proportions
                                 e.g., {'excellent': 0.3, 'good': 0.4, 'medium': 0.2, 'bad': 0.1}
            location_type: Type of location
        
        Returns:
            pandas.DataFrame: Generated dataset
        """
        if quality_distribution is None:
            quality_distribution = {
                'excellent': 0.25,
                'good': 0.40,
                'medium': 0.20,
                'bad': 0.10,
                'very_bad': 0.05
            }
        
        # Generate quality targets for each sample
        quality_targets = np.random.choice(
            list(quality_distribution.keys()),
            size=n_samples,
            p=list(quality_distribution.values())
        )
        
        # Generate timestamps (last year of data)
        end_date = datetime.now()
        start_date = end_date - timedelta(days=365)
        timestamps = [start_date + timedelta(hours=i * (365 * 24 / n_samples)) for i in range(n_samples)]
        
        # Initialize data dict
        data = {
            'timestamp': timestamps,
            'ph': [],
            'bod': [],
            'dissolved_oxygen': [],
            'fecal_coliform': [],
            'temperature': [],
            'tds': [],
            'turbidity': [],
            'total_coliform': []
        }
        
        # Generate parameters for each sample
        for quality_target in quality_targets:
            data['ph'].append(self.generate_parameter('ph', quality_target, location_type))
            data['bod'].append(self.generate_parameter('bod', quality_target, location_type))
            data['dissolved_oxygen'].append(self.generate_parameter('do', quality_target, location_type))
            data['fecal_coliform'].append(self.generate_parameter('fc', quality_target, location_type))
            data['temperature'].append(self.generate_parameter('temperature', quality_target, location_type))
            data['tds'].append(self.generate_parameter('tds', quality_target, location_type))
            data['turbidity'].append(self.generate_parameter('turbidity', quality_target, location_type))
            data['total_coliform'].append(self.generate_parameter('total_coliform', quality_target, location_type))
        
        # Apply correlations
        df = self.apply_parameter_correlations(data)
        
        # Apply seasonal patterns if specified
        if season is not None:
            df = self.apply_seasonal_patterns(df, season=season)
        
        # Calculate WQI for each sample
        df['wqi'] = df.apply(
            lambda row: self.calculate_wqi(
                row['ph'],
                row['bod'],
                row['dissolved_oxygen'],
                row['fecal_coliform'],
                row['temperature']
            ),
            axis=1
        )
        
        # Add classifications
        classifications = df['wqi'].apply(self.get_classification)
        df['classification'] = [c['classification'] for c in classifications]
        df['cpcb_class'] = [c['cpcbClass'] for c in classifications]
        df['mpcb_class'] = [c['mpcbClass'] for c in classifications]
        df['status'] = [c['status'] for c in classifications]
        
        return df


def main():
    """Generate sample datasets"""
    generator = AuthenticWaterQualityGenerator(seed=42)
    
    # Generate general dataset
    print("Generating general water quality dataset...")
    df_general = generator.generate_dataset(n_samples=1000)
    df_general.to_csv('ml_backend/water_quality_data.csv', index=False)
    
    print(f"\n✅ Generated {len(df_general)} samples")
    print(f"\n📊 Quality Distribution:")
    print(df_general['classification'].value_counts())
    
    print(f"\n📈 WQI Statistics:")
    print(f"mean: {df_general['wqi'].mean():.2f}, std: {df_general['wqi'].std():.2f}, min: {df_general['wqi'].min():.2f}, max: {df_general['wqi'].max():.2f}")
    
    print(f"\n🎯 Parameter Ranges:")
    print(f"pH: {df_general['ph'].min():.2f} - {df_general['ph'].max():.2f}")
    print(f"BOD: {df_general['bod'].min():.2f} - {df_general['bod'].max():.2f} mg/l")
    print(f"DO: {df_general['dissolved_oxygen'].min():.2f} - {df_general['dissolved_oxygen'].max():.2f} mg/l")
    print(f"FC: {df_general['fecal_coliform'].min():.0f} - {df_general['fecal_coliform'].max():.0f} MPN/100ml")
    print(f"TDS: {df_general['tds'].min():.0f} - {df_general['tds'].max():.0f} mg/l")
    print(f"Turbidity: {df_general['turbidity'].min():.2f} - {df_general['turbidity'].max():.2f} NTU")
    
    # Generate polluted urban dataset
    print("\n\n🏙️ Generating urban polluted water dataset...")
    df_urban = generator.generate_dataset(
        n_samples=500,
        quality_distribution={
            'good': 0.15,
            'medium': 0.30,
            'bad': 0.35,
            'very_bad': 0.20
        },
        location_type='urban'
    )
    df_urban.to_csv('ml_backend/water_quality_urban_polluted.csv', index=False)
    
    print(f"✅ Generated {len(df_urban)} urban samples")
    print(f"📊 Quality Distribution:")
    print(df_urban['classification'].value_counts())
    
    # Generate seasonal datasets
    print("\n\n🌦️ Generating seasonal datasets...")
    
    # Monsoon dataset (June-September) - High pollution, high turbidity
    print("\n☔ Monsoon Season (June-September):")
    df_monsoon = generator.generate_dataset(
        n_samples=300,
        quality_distribution={
            'good': 0.35,
            'medium': 0.35,
            'bad': 0.20,
            'very_bad': 0.10
        },
        location_type='rural',
        season='monsoon'
    )
    df_monsoon['season'] = 'monsoon'
    df_monsoon.to_csv('ml_backend/water_quality_monsoon.csv', index=False)
    print(f"✅ Generated {len(df_monsoon)} monsoon samples")
    print(f"Mean WQI: {df_monsoon['wqi'].mean():.2f}, Mean Turbidity: {df_monsoon['turbidity'].mean():.2f} NTU")
    
    # Summer dataset (March-May) - Low flow, concentrated pollutants
    print("\n☀️ Summer Season (March-May):")
    df_summer = generator.generate_dataset(
        n_samples=300,
        quality_distribution={
            'good': 0.40,
            'medium': 0.30,
            'bad': 0.20,
            'very_bad': 0.10
        },
        location_type='rural',
        season='summer'
    )
    df_summer['season'] = 'summer'
    df_summer.to_csv('ml_backend/water_quality_summer.csv', index=False)
    print(f"✅ Generated {len(df_summer)} summer samples")
    print(f"Mean WQI: {df_summer['wqi'].mean():.2f}, Mean Temp: {df_summer['temperature'].mean():.2f}°C")
    
    # Winter dataset (November-February) - Best quality
    print("\n❄️ Winter Season (November-February):")
    df_winter = generator.generate_dataset(
        n_samples=300,
        quality_distribution={
            'excellent': 0.25,
            'good': 0.45,
            'medium': 0.20,
            'bad': 0.08,
            'very_bad': 0.02
        },
        location_type='rural',
        season='winter'
    )
    df_winter['season'] = 'winter'
    df_winter.to_csv('ml_backend/water_quality_winter.csv', index=False)
    print(f"✅ Generated {len(df_winter)} winter samples")
    print(f"Mean WQI: {df_winter['wqi'].mean():.2f}, Mean DO: {df_winter['dissolved_oxygen'].mean():.2f} mg/l")
    
    # Combined all seasons dataset
    print("\n\n🔄 Creating combined multi-season dataset...")
    df_all_seasons = pd.concat([df_general, df_monsoon, df_summer, df_winter], ignore_index=True)
    
    # Add season column to general dataset (random distribution)
    general_mask = df_all_seasons['season'].isna() if 'season' in df_all_seasons.columns else [True] * len(df_general)
    if any(general_mask):
        seasons_list = ['monsoon', 'summer', 'winter', 'post_monsoon']
        df_all_seasons.loc[df_all_seasons.index[:len(df_general)], 'season'] = np.random.choice(
            seasons_list, 
            size=len(df_general),
            p=[0.33, 0.33, 0.25, 0.09]  # Realistic season distribution
        )
    
    df_all_seasons.to_csv('ml_backend/water_quality_all_seasons.csv', index=False)
    print(f"✅ Combined dataset: {len(df_all_seasons)} samples across all seasons")
    print(f"📊 Seasonal Distribution:")
    print(df_all_seasons['season'].value_counts())
    
    # Verify WQI calculation with Maharashtra report example
    print("\n\n🧪 Verifying WQI Calculation with Maharashtra Report Example")
    print("Station: Krishna River at Rajapur Weir, Kolhapur (April)")
    test_wqi = generator.calculate_wqi(
        ph=7.6,
        bod=2.2,
        dissolved_oxygen=5.5,
        fecal_coliform=6
    )
    print(f"Calculated WQI: {test_wqi:.2f}")
    print(f"Expected WQI: 83.16")
    print(f"Difference: {abs(test_wqi - 83.16):.2f}")
    print(f"✅ Match: {'Yes' if abs(test_wqi - 83.16) < 1.0 else 'No'}")
    
    print("\n\n✨ Phase 3 Complete: Seasonal Variations Implemented")
    print("📁 Generated files:")
    print("   - water_quality_data.csv (1,000 general samples)")
    print("   - water_quality_urban_polluted.csv (500 urban samples)")
    print("   - water_quality_monsoon.csv (300 monsoon samples)")
    print("   - water_quality_summer.csv (300 summer samples)")
    print("   - water_quality_winter.csv (300 winter samples)")
    print("   - water_quality_all_seasons.csv (1,900 combined samples)")


if __name__ == '__main__':
    main()Initialize data dict
        data = {
            'timestamp': timestamps,
            'ph': [],
            'bod': [],
            'dissolved_oxygen': [],
            'fecal_coliform': [],
            'temperature': [],
            'tds': [],
            'turbidity': [],
            'total_coliform': []
        }
        
        # Generate parameters for each sample
        for quality_target in quality_targets:
            data['ph'].append(self.generate_parameter('ph', quality_target, location_type))
            data['bod'].append(self.generate_parameter('bod', quality_target, location_type))
            data['dissolved_oxygen'].append(self.generate_parameter('do', quality_target, location_type))
            data['fecal_coliform'].append(self.generate_parameter('fc', quality_target, location_type))
            data['temperature'].append(self.generate_parameter('temperature', quality_target, location_type))
            data['tds'].append(self.generate_parameter('tds', quality_target, location_type))
            data['turbidity'].append(self.generate_parameter('turbidity', quality_target, location_type))
            data['total_coliform'].append(self.generate_parameter('total_coliform', quality_target, location_type))
        
        # Apply correlations
        df = self.apply_parameter_correlations(data)
        
        # Apply seasonal patterns if specified
        if season is not None:
            df = self.apply_seasonal_patterns(df, season=season)
        
        # Calculate WQI for each sample
        df['wqi'] = df.apply(
            lambda row: self.calculate_wqi(
                row['ph'],
                row['bod'],
                row['dissolved_oxygen'],
                row['fecal_coliform'],
                row['temperature']
            ),
            axis=1
        )
        
        # Add classifications
        classifications = df['wqi'].apply(self.get_classification)
        df['classification'] = [c['classification'] for c in classifications]
        df['cpcb_class'] = [c['cpcbClass'] for c in classifications]
        df['mpcb_class'] = [c['mpcbClass'] for c in classifications]
        df['status'] = [c['status'] for c in classifications]
        
        return df


def main():
    """Generate sample datasets"""
    generator = AuthenticWaterQualityGenerator(seed=42)
    
    # Generate general dataset
    print("Generating general water quality dataset...")
    df_general = generator.generate_dataset(n_samples=1000)
    df_general.to_csv('ml_backend/water_quality_data.csv', index=False)
    
    print(f"\n✅ Generated {len(df_general)} samples")
    print(f"\n📊 Quality Distribution:")
    print(df_general['classification'].value_counts())
    print(f"\n📈 WQI Statistics:")
    print(df_general['wqi'].describe())
    print(f"\n🎯 Parameter Ranges:")
    print(f"pH: {df_general['ph'].min():.2f} - {df_general['ph'].max():.2f}")
    print(f"BOD: {df_general['bod'].min():.2f} - {df_general['bod'].max():.2f} mg/l")
    print(f"DO: {df_general['dissolved_oxygen'].min():.2f} - {df_general['dissolved_oxygen'].max():.2f} mg/l")
    print(f"FC: {df_general['fecal_coliform'].min():.0f} - {df_general['fecal_coliform'].max():.0f} MPN/100ml")
    print(f"TDS: {df_general['tds'].min():.0f} - {df_general['tds'].max():.0f} mg/l")
    print(f"Turbidity: {df_general['turbidity'].min():.2f} - {df_general['turbidity'].max():.2f} NTU")
    
    # Generate polluted urban dataset
    print("\n\n🏙️ Generating urban polluted water dataset...")
    df_urban = generator.generate_dataset(
        n_samples=500,
        quality_distribution={
            'good': 0.15,
            'medium': 0.30,
            'bad': 0.35,
            'very_bad': 0.20
        },
        location_type='urban'
    )
    df_urban.to_csv('ml_backend/water_quality_urban_polluted.csv', index=False)
    
    print(f"✅ Generated {len(df_urban)} urban samples")
    print(f"📊 Quality Distribution:")
    print(df_urban['classification'].value_counts())
    
    # Verify WQI calculation with Maharashtra report example
    print("\n\n🧪 Verifying WQI Calculation with Maharashtra Report Example")
    print("Station: Krishna River at Rajapur Weir, Kolhapur (April)")
    test_wqi = generator.calculate_wqi(
        ph=7.6,
        bod=2.2,
        dissolved_oxygen=5.5,
        fecal_coliform=6
    )
    print(f"Calculated WQI: {test_wqi:.2f}")
    print(f"Expected WQI: 83.16")
    print(f"Difference: {abs(test_wqi - 83.16):.2f}")
    print(f"✅ Match: {'Yes' if abs(test_wqi - 83.16) < 1.0 else 'No'}")


if __name__ == '__main__':
    main()
