import pandas as pd
import numpy as np
from datetime import datetime, timedelta

def generate_training_data(n_samples=1000):
    """
    Generate realistic water quality training data
    """
    np.random.seed(42)
    
    data = {
        'pH': np.random.normal(7.0, 0.8, n_samples),  # Normal ~7.0, std 0.8
        'turbidity': np.random.exponential(2.0, n_samples),  # Right-skewed
        'dissolved_oxygen': np.random.normal(8.0, 1.5, n_samples),  # Normal ~8.0
        'temperature': np.random.normal(25.0, 5.0, n_samples),  # Normal ~25°C
        'conductivity': np.random.normal(500, 100, n_samples),  # Normal ~500
        'timestamp': [datetime.now() - timedelta(hours=i) for i in range(n_samples)],
    }
    
    df = pd.DataFrame(data)
    
    # Create labels based on water quality standards
    df['quality_status'] = 'Safe'  # Default
    
    # Apply quality rules
    df.loc[(df['pH'] < 6.5) | (df['pH'] > 8.5), 'quality_status'] = 'Warning'
    df.loc[(df['turbidity'] > 5), 'quality_status'] = 'Warning'
    df.loc[(df['dissolved_oxygen'] < 5), 'quality_status'] = 'Warning'
    
    df.loc[(df['pH'] < 5.5) | (df['pH'] > 9.5), 'quality_status'] = 'Critical'
    df.loc[(df['turbidity'] > 8), 'quality_status'] = 'Critical'
    df.loc[(df['dissolved_oxygen'] < 3), 'quality_status'] = 'Critical'
    
    # Create quality score (0-100)
    df['quality_score'] = 100
    
    # Penalize based on parameters
    df.loc[df['quality_status'] == 'Warning', 'quality_score'] = 70
    df.loc[df['quality_status'] == 'Critical', 'quality_score'] = 40
    
    # Add some variation within each status
    df['quality_score'] += np.random.normal(0, 5, n_samples)
    df['quality_score'] = df['quality_score'].clip(0, 100)
    
    return df

if __name__ == '__main__':
    df = generate_training_data(1000)
    df.to_csv('training_data.csv', index=False)
    print(f"Generated {len(df)} training samples")
    print(df.head(10))
    print(f"\nQuality Status Distribution:\n{df['quality_status'].value_counts()}")
    print(f"\nQuality Score Stats:\n{df['quality_score'].describe()}")
